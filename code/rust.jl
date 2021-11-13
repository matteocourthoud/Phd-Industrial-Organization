# Rust (1987) bus engine replacement problem
# Notation: I use underscore to denote empirical counterparts

# Import packages
using Optim
using Distributions
using Statistics
using DataFrames
using CSV

function compute_U(θ::Vector, x::Vector)::Matrix
    """Compute static utility"""
    u1 = - θ[1]*x - θ[2]*x.^2       # Utility of not investing
    u2 = - θ[3]*ones(size(x))       # Utility of investing
    U = [u1 u2]                     # Combine in a matrix
    return U
end;

function compute_V(θ::Vector, λ::Number, β::Number, x::Vector)::Matrix
    """Compute value function by Bellman iteration"""
    K = length(x)                                 # Dimension of the state space
    U = compute_U(θ, x)                           # Static utility
    index_λ = Int[1:K [2:K; K]];                  # Mileage index
    index_I = Int[1:K ones(K,1)];                 # Investment index

    # Iterate the Bellman equation until convergence
    V_bar = zeros(K, 2);
    V_bar1 = V_bar;
    dist = 1;
    iter = 0;
    while dist>1e-8
        V = log.(sum(exp.(V_bar), dims=2))          # Compute value
        Exp_V = V[index_λ] * [1-λ; λ]               # Compute exponential value
        V_bar1 = β * (U + Exp_V[index_I])           # Compute v-specific
        dist = max(abs.(V_bar1 - V_bar)...);        # Check distance
        iter += 1;
        V_bar = V_bar1                              # Update value function
    end
    return V_bar
end;

function generate_data(θ::Vector, λ::Number, β::Number, x::Vector, N::Int)::Tuple
    """Generate data from primitives"""
    V_bar = compute_V(θ, λ, β, x)               # Solve model
    ε = rand(Gumbel(0,1), N, 2)                 # Draw shocks
    Xt = rand(x.+1, N)                          # Draw states
    Iv = (((V_bar[Xt,:] + ε) * [-1;1]) .> 0)    # Compute investment decisions
    δ = (rand(Uniform(0,1), N) .< λ)            # Compute mileage shock
    Xt1 = min.(Xt .* (Iv.==0) + δ, max(x...))   # Compute next state
    df = DataFrame(Xt=Xt, Iv=Iv, Xt1=Xt1)
    CSV.write("../data/rust.csv", df)
    return Xt, Iv, Xt1
end;

function logL(θ0::Vector)::Number
    """Compute log-likelihood function"""
    # Compute value
    V_bar = compute_V(θ0, λ_, β, x)

    # Implied choice probabilities
    pr_I = exp.(V_bar[:,2]) ./ (exp.(V_bar[:,1]) + exp.(V_bar[:,2]))

    # Likelihood
    logL = sum(log.(pr_I[x_t[Iv.==1]])) + sum(log.(1 .- pr_I[x_t[Iv.==0]]))
    return -logL
end;



## Main

# Set parameters
θ = [0.13; -0.004; 3.1];
λ = 0.82;
β = 0.95;

# State space
x = Vector(0:10);

# Compute value function
V_bar = compute_V(θ, λ, β, x);

# Generate data
N = Int(1e5);
x_t, Iv, x_t1 = generate_data(θ, λ, β, x, N);
print("we observe ", sum(Iv), " investment decisions in ", N, " observations")


# Estimate lambda
Δ = x_t1 - x_t;
λ_ = mean(Δ[(Iv.==0) .& (x_t.<10)]);

print("Estimated lambda: $λ_ (true = $λ)")

# True likelihood value
print("The likelihood at the true parameter is ", logL(θ))

# Select starting values
θ0 = Float64[0,0,0];

# Optimize
θ_ = optimize(logL, θ0).minimizer;
print("Estimated thetas: $θ_ (true = $θ)")

# Not all initial values are equally good
θ0 = Float64[1,1,1];

# Optimize
opt = optimize(logL, θ0);
print("Estimated thetas: $θ_ (true = $θ)")
