# BLP Demand Simulationa and Estimation
# Notation: I use underscore to denote empirical counterparts


# Import packages
using Optim
using Distributions
using Statistics
using Random
using DataFrames
using StatsBase
using Econometrics
using CSV
using BenchmarkTools

function demand(p::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Tuple{Vector, Number}
    """Compute demand"""
    δ = 1 .+ [X p] * (β .+ ζ)               # Mean value
    δ0 = zeros(1, size(ζ, 2))               # Mean value of the outside option
    u = [δ; δ0] + ξ                         # Utility
    e = exp.(u)                             # Take exponential
    q = mean(e ./ sum(e, dims=1), dims=2)   # Compute demand
    return q[1:end-1], q[end]
end;

function profits(p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Vector
    """Compute profits"""
    q, _ = demand(p, X, β, ξ, ζ)            # Compute demand
    pr = (p - c) .* q                       # Compute profits
    return pr
end;

function profits_j(pj::Number, j::Int, p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Number
    """Compute profits of firm j"""
    p[j] = pj                               # Insert price of firm j
    pr = profits(p, c, X, β, ξ, ζ)          # Compute profits
    return pr[j]
end;

function equilibrium(c::Vector, X::Matrix, β::Vector, ξ::Matrix, ζ::Matrix)::Vector
    """Compute equilibrium prices and profits"""
    p = 2 .* c;
    dist = 1;
    iter = 0;

    # Iterate until convergence
    while (dist > 1e-8) && (iter<1000)

        # Compute best reply for each firm
        p_old = copy(p);
        for j=1:length(p)
            obj_fun(pj) = - profits_j(pj[1], j, p, c, X, β, ξ, ζ);
            optimize(x -> obj_fun(x), [1.0], LBFGS()).minimizer[1];
        end

        # Update distance
        dist = max(abs.(p - p_old)...);
        iter += 1;
    end
    return p
end;

function draw_data(I::Int, J::Int, K::Int, rangeJ::Vector, varζ::Number, varX::Number, varξ::Number)::Tuple
    """Draw data for one market"""
    J_ = rand(rangeJ[1]:rangeJ[2])
    X_ = randexp(J_, K) * varX
    ξ_ = randn(J_+1, I) * varξ
    ζ_ = [randexp(1,I) * varζ; zeros(K,I)]
    w_ = rand(J_)
    ω_ = rand(J_)
    c_ = w_ + ω_
    j_ = sort(sample(1:J, J_, replace=false))
    return X_, ξ_, ζ_, w_, c_, j_
end;

function compute_mkt_eq(I::Int, J::Int, β::Vector, rangeJ::Vector, varζ::Number, varX::Number, varξ::Number)::DataFrame
    """Compute equilibrium one market"""

    # Initialize variables
    K = size(β, 1) - 1
    X_, ξ_, ζ_, w_, c_, j_ = draw_data(I, J, K, rangeJ, varζ, varX, varξ)

    # Compute equilibrium
    p_ = equilibrium(c_, X_, β, ξ_, ζ_)    # Equilibrium prices
    q_, q0 = demand(p_, X_, β, ξ_, ζ_)     # Demand with shocks
    pr_ = (p_ - c_) .* q_                       # Profits

    # Save to data
    q0_ = ones(length(j_)) .* q0
    df = DataFrame(j=j_, w=w_, p=p_, q=q_, q0=q0_, pr=pr_)
    for k=1:K
      df[!,"x$k"] = X_[:,k]
      df[!,"z$k"] = sum(X_[:,k]) .- X_[:,k]
    end
    return df
end;

function simulate_data(I::Int, J::Int, β::Vector, T::Int, rangeJ::Vector, varζ::Number, varX::Number, varξ::Number)
    """Simulate full dataset"""
    df = compute_mkt_eq(I, J, β, rangeJ, varζ, varX, varξ)
    df[!, "t"] = ones(nrow(df)) * 1
    for t=2:T
        df_temp = compute_mkt_eq(I, J, β, rangeJ, varζ, varX, varξ)
        df_temp[!, "t"] = ones(nrow(df_temp)) * t
        append!(df, df_temp)
    end
    CSV.write("../data/blp.csv", df)
    return df
end;

function implied_shares(Xt_::Matrix, ζt_::Matrix, δ::Vector)::Vector
    """Compute shares implied by deltas and shocks"""
    δ0 = zeros(1, size(ζt_, 2))                # Mean value of the outside option
    u = [δ .+ (Xt_ * ζt_); δ0]             # Utility
    e = exp.(u)                                 # Take exponential
    q = mean(e ./ sum(e, dims=1), dims=2)       # Compute demand
    return q[1:end-1]
end

function inner_loop(qt_::Vector, Xt_::Matrix, ζt_::Matrix)::Vector
    """Solve the inner loop: compute delta, given the shares"""
    δ = ones(size(qt_))
    dist = 1
    iter = 0

    # Iterate until convergence
    while (dist > 1e-8) && (iter<1000)
        q = implied_shares(Xt_, ζt_, δ)
        δ1 = δ + log.(qt_) - log.(q)
        dist = max(abs.(δ1 - δ)...)
        iter += 1
        δ = δ1
    end
    return δ
end

function compute_xi(β::Vector, q_::Vector, X_::Matrix, ζ_::Array, T::Vector)::Vector
    """Compute residuals"""
    ξ_ = zeros(size(T))

    # Loop over each market
    for t in unique(T)
        qt_ = q_[T.==t]                             # Quantity in market t
        Xt_ = X_[T.==t,:]                           # Characteristics in mkt t
        ζt_ = ζ_[:, :, t]                           # Preference shocks in mkt t
        δ = inner_loop(qt_, Xt_, ζt_)               # Solve inner loop
        ξ_[T.==t] = δ - Xt_ * β                     # Compute residuals
    end
    return ξ_
end

function GMM(param::Vector, q_::Vector, X_::Matrix, ζ_::Array, Z_::Matrix, T::Vector)::Number
    """Compute GMM objective function"""
    β = param[1:3]
    varζ = param[4]
    ζ_ *= varζ
    ξ_ = compute_xi(β, q_, X_, ζ_, T)      # Compute errors
    gmm = ξ_' * Z_ * Z_' * ξ_ / length(ξ_)^2 # Compute ortogonality condition
    return gmm
end




## Main

I = 1000;               # Number of consumers
J = 10;                 # Number of firms
K = 2;                  # Product caracteristics
T = 100;                # Number of markets
β = [.5, 2, -1];        # Preferences
varζ = 2;               # Variance of the random taste
rangeJ = [2, 6];        # Min and max firms per market
varX = 1;               # Variance of X
varξ = 2;               # Variance of xi

# Simulate
df = simulate_data(I, J, β, T, rangeJ, varζ, varX, varξ)

# Retrieve data
T = Int.(df.t)
X_ = [df.x1 df.x2 df.p]
q_ = df.q
Z_ = [df.z1 df.z2]

# Draw shocks
ζ_ = zeros(K+1, I, max(T...))
for t in unique(T)
    ζ_[:, :, t] = [randexp(1,I); zeros(K,I)]
end

# Test at true values
param0 = [β; varζ]
@time gmm = GMM(param0, q_, X_, ζ_, Z_, T)


# Minimize GMM objective function
#obj_fun(param) = - GMM(param, q_, X_, ζ_, Z_, T);
#opt = optimize(x -> obj_fun(x), param0, LBFGS())
