# Rust (1987) bus engine replacement problem
# Notation: I use underscore to denote empirical counterparts

# Import packages
using Optim
using Distributions
using Statistics
using DataFrames
using CSV
using LinearAlgebra

function compute_U(θ::Vector, s::Vector)::Matrix
    """Compute static utility"""
    u1 = - θ[1]*s - θ[2]*s.^2       # Utility of not investing
    u2 = - θ[3]*ones(size(s))       # Utility of investing
    U = [u1 u2]                     # Combine in a matrix
    return U
end;

function compute_Vbar(θ::Vector, λ::Number, β::Number, s::Vector)::Matrix
    """Compute value function by Bellman iteration"""
    k = length(s)                                 # Dimension of the state space
    U = compute_U(θ, s)                           # Static utility
    index_λ = Int[1:k [2:k; k]];                  # Mileage index
    index_A = Int[1:k ones(k,1)];                 # Investment index
    γ = Base.MathConstants.eulergamma             # Euler's gamma

    # Iterate the Bellman equation until convergence
    Vbar = zeros(k, 2);
    Vbar1 = Vbar;
    dist = 1;
    iter = 0;
    while dist>1e-8
        V = γ .+ log.(sum(exp.(Vbar), dims=2))     # Compute value
        expV = V[index_λ] * [1-λ; λ]               # Compute expected value
        Vbar1 =  U + β * expV[index_A]             # Compute v-specific
        dist = max(abs.(Vbar1 - Vbar)...);         # Check distance
        iter += 1;
        Vbar = Vbar1                               # Update value function
    end
    return Vbar
end;

function generate_data(θ::Vector, λ::Number, β::Number, s::Vector, N::Int)::Tuple
    """Generate data from primitAes"""
    Vbar = compute_Vbar(θ, λ, β, s)             # Solve model
    ε = rand(Gumbel(0,1), N, 2)                 # Draw shocks
    St = rand(s, N)                             # Draw states
    A = (((Vbar[St,:] + ε) * [-1;1]) .> 0)     # Compute investment decisions
    δ = (rand(Uniform(0,1), N) .< λ)            # Compute mileage shock
    St1 = min.(St .* (A.==0) + δ, max(s...))   # Compute nest state
    df = DataFrame(St=St, A=A, St1=St1)
    CSV.write("../data/rust.csv", df)
    return St, A, St1
end;

function logL_Rust(θ0::Vector, λ::Number, β::Number, s::Vector, St::Vector, A::BitVector)::Number
    """Compute log-likelihood functionfor Rust problem"""
    # Compute value
    Vbar = compute_Vbar(θ0, λ_, β, s)

    # Implied choice probabilities
    EP = exp.(Vbar[:,2]) ./ (exp.(Vbar[:,1]) + exp.(Vbar[:,2]))

    # Likelihood
    logL = sum(log.(EP[St[A.==1]])) + sum(log.(1 .- EP[St[A.==0]]))
    return -logL
end;

function compute_T(k::Int, λ_::Number)::Array
    """Compute transition matrix"""
    T = zeros(k, k, 2);

    # Conditional on not investing
    T[k,k,1] = 1;
    for i=1:k-1
        T[i,i,1] = 1-λ_
        T[i,i+1,1] = λ_
    end

    # Conditional on investing
    T[:,1,2] .= 1-λ_;
    T[:,2,2] .= λ_;

    return(T)
end;

function HM_inversion(CCP::Matrix, T::Array, U::Matrix, β::Number)::Vector
    """Perform HM inversion"""

    # Compute LHS (to be inverted)
    γ = Base.MathConstants.eulergamma
    LEFT = I - β .* (CCP[:,1] .* T[:,:,1] + CCP[:,2] .* T[:,:,2])

    # Compute LHS (not to be inverted)
    RIGHT = γ .+ sum(CCP .* (U .- log.(CCP)) , dims=2)

    # Compute V
    EV_ = inv(LEFT) * RIGHT
    return vec(EV_)
end;

function from_EV_to_EP(EV_::Vector, T::Array, U::Matrix, β::Number)::Vector
    """Compute expected policy from expected value"""
    E = exp.( U + β .* [(T[:,:,1] * EV_) (T[:,:,2] * EV_)] )
    EP_ = E[:,2] ./ sum(E, dims=2)
    return vec(EP_)
end;

function logL_HM(θ0::Vector, λ::Number, β::Number, s::Vector, St::Vector, A::BitVector, T::Array, CCP::Matrix)::Number
    """Compute log-likelihood function for HM problem"""
    # Compute static utility
    U = compute_U(θ0, s)

    # Espected value by inversion
    EV_ = HM_inversion(CCP, T, U, β)

    # Implies choice probabilities
    EP_ = from_EV_to_EP(EV_, T, U, β)

    # Likelihood
    logL = sum(log.(EP_[St[A.==1]])) + sum(log.(1 .- EP_[St[A.==0]]))
    return -logL
end;

function logL_AM(θ0::Vector, λ::Number, β::Number, s::Vector, St::Vector, A::BitVector, T::Array, CCP::Matrix, K::Int)::Number
    """Compute log-likelihood function for AM problem"""
    # Compute static utility
    U = compute_U(θ0, s)
    EP_ = CCP[:,2]

    # Iterate HM mapping
    for _=1:K
        EV_ = HM_inversion(CCP, T, U, β)    # Espected value by inversion
        EP_ = from_EV_to_EP(EV_, T, U, β)   # Implies choice probabilities
        CCP = [(1 .- EP_) EP_]
    end

    # Likelihood
    logL = sum(log.(EP_[St[A.==1]])) + sum(log.(1 .- EP_[St[A.==0]]))
    return -logL
end;



## Main

# Set parameters
θ = [0.13; -0.004; 3.1];
λ = 0.82;
β = 0.95;

# State space
k = 10;
s = Vector(1:k);

# Compute value function
Vbar = compute_Vbar(θ, λ, β, s);

# Generate data
N = Int(1e5);
St, A, St1 = generate_data(θ, λ, β, s, N);
print("\n\nwe observe ", sum(A), " investment decisions in ", N, " observations")

# Estimate lambda
Δ = St1 - St;
λ_ = mean(Δ[(A.==0) .& (St.<10)]);

print("\n\nEstimated lambda: $λ_ (true = $λ)")

# True likelihood value
logL_trueθ = logL_Rust(θ, λ, β, s, St, A);
print("\n\nThe likelihood at the true parameter is $logL_trueθ")

# Select starting values
θ0 = Float64[0,0,0];

# Optimize
θ_R = optimize(x -> logL_Rust(x, λ, β, s, St, A), θ0).minimizer;
print("\n\nEstimated thetas: $θ_R (true = $θ)")

# Not all initial values are equally good
θ0 = Float64[1,1,1];

# Optimize
θ_R2 = optimize(x -> logL_Rust(x, λ, β, s, St, A), θ0).minimizer;
print("\n\nEstimated thetas: $θ_R2 (true = $θ)")

# Estimate CCP
P = [mean(A[St.==i]) for i=s]
CCP = [(1 .- P) P]

# Compute T
T = compute_T(k, λ_)

# Optimize
θ0 = Float64[0,0,0];
θ_HM = optimize(x -> logL_HM(x, λ, β, s, St, A, T, CCP), θ0).minimizer;
print("\n\nEstimated thetas: $θ_HM (true = $θ)")

# Aguirregabiria & Mira (2002)
K = 2

# Optimize
θ0 = Float64[0,0,0];
θ_AM = optimize(x -> logL_AM(x, λ, β, s, St, A, T, CCP, K), θ0).minimizer;
print("\n\nEstimated thetas: $θ_AM (true = $θ)")


# Compare times
θ0 = Float64[0,0,0];
time_Rust = optimize(x -> logL_Rust(x, λ, β, s, St, A), θ0).time_run;
time_HM = optimize(x -> logL_HM(x, λ, β, s, St, A, T, CCP), θ0).time_run;
time_AM = optimize(x -> logL_AM(x, λ, β, s, St, A, T, CCP, K), θ0).time_run;
print("Time Rust: $time_Rust\nTime HM: $time_HM\nTime AM: $time_AM")
