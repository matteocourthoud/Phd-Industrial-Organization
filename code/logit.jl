# Logit Demand Simulationa and Estimation
# Notation: I use underscore to denote empirical counterparts

# Import packages
using Optim
using Distributions
using DataFrames
using CSV

function demand(p::Vector, X::Matrix, β::Vector, ξ::Vector)::Tuple{Vector, Number}
    """Compute demand"""
    δ = [X p] * β                   # Mean value
    u = [δ; 0] + ξ                  # Utility
    e = exp.(u)                     # Take exponential
    q = e ./ sum(e)                 # Compute demand
    return q[1:end-1], q[end]
end;

function profits(p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Vector)::Vector
    """Compute profits"""
    q, _ = demand(p, X, β, ξ)       # Compute demand
    pr = (p - c) .* q               # Compute profits
    return pr
end;

function profits_j(pj::Number, j::Int, p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Vector)::Number
    """Compute profits of firm j"""
    p[j] = pj                       # Insert price of firm j
    pr = profits(p, c, X, β, ξ)     # Compute profits
    return pr[j]
end;

function equilibrium(c::Vector, X::Matrix, β::Vector, ξ::Vector)::Vector
    """Compute equilibrium prices and profits"""
    p = 2 .* c;
    dist = 1;
    iter = 0;

    # Until convergence
    while (dist > 1e-8) && (iter<1000)

        # Compute best reply for each firm
        p1 = copy(p);
        for j=1:length(p)
            obj_fun(pj) = - profits_j(pj[1], j, p, c, X, β, ξ);
            optimize(x -> obj_fun(x), [1.0], LBFGS()).minimizer[1];
        end

        # Update distance
        dist = max(abs.(p - p1)...);
        iter += 1;
    end
    return p
end;

function draw_data(J::Int, K::Int, rangeJ::Vector, varX::Number, varξ::Number)::Tuple
    """Draw data for one market"""
    J_ = rand(rangeJ[1]:rangeJ[2])              # Number of firms (products)
    X_ = rand(Exponential(varX), J_, K)         # Product characteristics
    ξ_ = rand(Normal(0, varξ), J_+1)            # Product-level utility shocks
    w_ = rand(Uniform(0, 1), J_)                # Cost shifters
    ω_ = rand(Uniform(0, 1), J_)                # Cost shocks
    c_ = w_ + ω_                                # Cost
    j_ = sort(sample(1:J, J_, replace=false))   # Subset of firms
    return X_, ξ_, w_, c_, j_
end;

function compute_mkt_eq(J::Int, b::Vector, rangeJ::Vector, varX::Number, varξ::Number)::DataFrame
    """Compute equilibrium one market"""

    # Initialize variables
    K = size(β, 1) - 1
    X_, ξ_, w_, c_, j_ = draw_data(J, K, rangeJ, varX, varξ)

    # Compute equilibrium
    p_ = equilibrium(c_, X_, β, ξ_)      # Equilibrium prices
    q_, q0 = demand(p_, X_, β, ξ_)       # Demand with shocks
    pr_ = (p_ - c_) .* q_                # Profits

    # Save to data
    q0_ = ones(length(j_)) .* q0
    df = DataFrame(j=j_, w=w_, p=p_, q=q_, q0=q0_, pr=pr_)
    for k=1:K
      df[!,"x$k"] = X_[:,k]
      df[!,"z$k"] = sum(X_[:,k]) .- X_[:,k]
    end
    return df
end;

function simulate_data(J::Int, b::Vector, T::Int, rangeJ::Vector, varX::Number, varξ::Number)
    """Simulate full dataset"""
    df = compute_mkt_eq(J, β, rangeJ, varX, varξ)
    df[!, "t"] = ones(nrow(df)) * 1
    for t=2:T
        df_temp = compute_mkt_eq(J, β, rangeJ, varX, varξ)
        df_temp[!, "t"] = ones(nrow(df_temp)) * t
        append!(df, df_temp)
    end
    CSV.write("../data/logit.csv", df)
end;



## Main
J = 10;                 # Number of firms
K = 2;                  # Product caracteristics
T = 500;                # Markets
β = [.5, 2, -1];        # Preferences
rangeJ = [2, 6];        # Min and max firms per market
varX = 1;               # Variance of X
varξ = 2;               # Variance of xi

# Simulate
df = simulate_data(J, β, T, rangeJ, varX, varξ)
