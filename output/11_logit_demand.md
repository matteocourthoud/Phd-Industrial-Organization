---
author: Matteo Courthoud
bibliography: references.bib
date: 2021-11-10
link-citations: true
output:
  html_notebook:
    toc: true
    toc_depth: 2
  ioslides_presentation:
    css: custom.css
    slide_level: 3
    smaller: true
    transition: 0
    widescreen: true
  md_document:
    preserve_yaml: true
    variant: markdown_mmd
title: "Coding: Logit Demand"
type: book
weight: 11
---

### Intro

In this session, I am going to cover demand estimation.

-   Compute equilibrium outcomes with Logit demand
-   Simulate a dataset
-   Estimate Logit demand
-   Compare different instruments
-   Include supply

### Model

In this first part, we are going to assume that consumer
$i \in \lbrace1,...,I\rbrace$ utility from good
$j \in \lbrace1,...,J\rbrace$ in market $t \in \lbrace1,...,T\rbrace$
takes the form

$$
u_{ijt} = \boldsymbol x_{jt} \boldsymbol \beta_{it} - \alpha p_{jt} + \xi_{jt} + \epsilon_{ijt}
$$

where

-   $\xi_{jt}$ is type-1 extreme value distributed
-   $\boldsymbol \beta$ has dimension $K$
    -   i.e. goods have $K$ characteristics

### Setup

We have $J$ firms and each product has $K$ characteristics

``` julia
J = 3;                  # 3 firms == products
K = 2;                  # 2 product characteristics
c = rand(J);            # Random uniform marginal costs
ξ = randn(J+1);         # Random normal individual shocks
X = randexp(J, K);      # Random exponential product characteristics
β = [.5, 2, -1];        # Preferences (last one is for prices, i.e. alpha)
```

### Code Demand

``` julia
function demand(p::Vector, X::Matrix, β::Vector, ξ::Vector)::Tuple{Vector, Number}
    """Compute demand"""
    δ = 1 .+ [X p] * β              # Mean value
    u = [δ; 0] + ξ                  # Utility
    e = exp.(u)                     # Take exponential
    q = e ./ sum(e)                 # Compute demand
    return q[1:end-1], q[end]
end;
```

We can try with an example.

``` julia
p = 2 .* c;
demand(p, X, β, ξ)
```

    ## ([0.44282166557805924, 0.4329575261829157, 0.03455588766499231], 0.08966492057403269)

### Code Supply

``` julia
function profits(p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Vector)::Vector
    """Compute profits"""
    q, _ = demand(p, X, β, ξ)       # Compute demand
    pr = (p - c) .* q               # Compute profits
    return pr
end;
```

We can try with an example.

``` julia
profits(p, c, X, β, ξ)
```

    ## 3-element Array{Float64,1}:
    ##  0.11718935500023371
    ##  0.2490524565039799
    ##  0.01804249513802408

### Code Best Reply

We first code the best reply of firm $j$

``` julia
function profits_j(pj::Number, j::Int, p::Vector, c::Vector, X::Matrix, β::Vector, ξ::Vector)::Number
    """Compute profits of firm j"""
    p[j] = pj                       # Insert price of firm j
    pr = profits(p, c, X, β, ξ)     # Compute profits
    return pr[j]
end;
```

Let’s test it.

``` julia
j = 1;
obj_fun(pj) = - profits_j(pj[1], j, copy(p), c, X, β, ξ);
pj = optimize(x -> obj_fun(x), [1.0], LBFGS()).minimizer[1]
```

    ## 1.5507952670554126

What are the implied profits now?

``` julia
print("Profits old: ",  round.(profits(p, c, X, β, ξ), digits=4))
```

    ## Profits old: [0.1172, 0.2491, 0.018]

``` julia
p_new = copy(p);
p_new[j] = pj;
print("Profits new: ",  round.(profits(p_new, c, X, β, ξ), digits=4))
```

    ## Profits new: [0.2862, 0.3475, 0.0252]

Indeed firm 1 has increased its profits.

### Code Equilibrium

We can now compute equilibrium prices

``` julia
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
```

### Code Equilibrium

Let’s test it

``` julia
# Compute equilibrium prices
p_eq = equilibrium(c, X, β, ξ);
print("Equilibrium prices: ",  round.(p_eq, digits=4))
```

    ## Equilibrium prices: [1.7605, 2.2054, 1.577]

``` julia
# And profits
pi_eq = profits(p_eq, c, X, β, ξ);
print("Equilibrium profits: ",  round.(pi_eq, digits=4))
```

    ## Equilibrium profits: [0.4959, 0.6302, 0.0549]

As expected the prices of the first 2 firms are lower and their profits
are higher.

### DGP

Let’s generate our Data Generating Process (DGP).

-   $\boldsymbol x \sim exp(V_{x})$
-   $\xi \sim N(0, V_{\xi})$
-   $w \sim N(0, 1)$
-   $\omega \sim N(0, 1)$

``` julia
function draw_data(J::Int, K::Int, rangeJ::Vector, varX::Number, varξ::Number)::Tuple
    """Draw data for one market"""
    J_ = rand(rangeJ[1]:rangeJ[2])
    X_ = randexp(J_, K) * varX
    ξ_ = randn(J_+1) * varξ
    w_ = rand(J_)
    ω_ = rand(J_)
    c_ = w_ + ω_
    j_ = sort(sample(1:J, J_, replace=false))
    return X_, ξ_, w_, c_, j_
end;
```

### Equilibrium

We first compute the equilibrium in one market.

``` julia
function compute_mkt_eq(J::Int, b::Vector, rangeJ::Vector, varX::Number, varξ::Number)::DataFrame
    """Compute equilibrium one market"""

    # Initialize variables
    K = size(β, 1) - 1
    X_, ξ_, w_, c_, j_ = draw_data(J, K, rangeJ, varX, varξ)

    # Compute equilibrium
    p_ = equilibrium(c_, X_, β, ξ_)      # Equilibrium prices
    q_, q0 = demand(p_, X_, β, ξ_)       # Demand with shocks
    pr_ = (p_ - c_) .* q_               # Profits

    # Save to data
    q0_ = ones(length(j_)) .* q0
    df = DataFrame(j=j_, w=w_, p=p_, q=q_, q0=q0_, pr=pr_)
    for k=1:K
      df[!,"x$k"] = X_[:,k]
      df[!,"z$k"] = sum(X_[:,k]) .- X_[:,k]
    end
    return df
end;
```

### Simulate Dataset

We can now write the code to simulate the whole dataset.

``` julia
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
```

### Simulate Dataset (2)

We generate the dataset by simulating many markets that differ by

-   number of firms (and their identity)
-   their marginal costs
-   their product characteristics

``` julia
# Set parameters
J = 10;                 # Number of firms
K = 2;                  # Product caracteristics
T = 500;                # Markets
β = [.5, 2, -1];        # Preferences
rangeJ = [2, 6];        # Min and max firms per market
varX = 1;               # Variance of X
varξ = 2;               # Variance of xi

# Simulate
df = simulate_data(J, β, T, rangeJ, varX, varξ);
```

### The Data

What does the data look like? Let’s switch to R!

``` r
# Read data
df = fread("../data/logit.csv")
kable(df[1:5,1:7], digits=4)
```

|   j |      w |      p |      q |     q0 |     pr |     x1 |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|
|   1 | 0.3865 | 1.9051 | 0.0792 | 0.5606 | 0.0860 | 0.4512 |
|   2 | 0.9304 | 3.3145 | 0.3302 | 0.5606 | 0.4930 | 1.9509 |
|   6 | 0.5821 | 1.8083 | 0.0085 | 0.5606 | 0.0086 | 0.4579 |
|  10 | 0.4043 | 2.0834 | 0.0215 | 0.5606 | 0.0220 | 0.4671 |
|   7 | 0.6320 | 2.2955 | 0.3306 | 0.3039 | 0.4940 | 0.2493 |

### Estimation

First we need to compute the dependent variable

``` r
df$y = log(df$q) - log(df$q0)
```

Now we can estimate the logit model. The true values are $alpha=1$.

``` r
ols <- lm(y ~ x1 + x2 + p, data=df)
kable(tidy(ols), digits=4)
```

| term        | estimate | std.error | statistic | p.value |
|:------------|---------:|----------:|----------:|--------:|
| (Intercept) |  -1.5386 |    0.1623 |   -9.4802 |       0 |
| x1          |   0.4537 |    0.0587 |    7.7220 |       0 |
| x2          |   1.2863 |    0.0704 |   18.2709 |       0 |
| p           |   0.2985 |    0.0697 |    4.2795 |       0 |

The estimate of $\alpha = 1$ is biased (positive and significant) since
$p$ is endogenous. We need instruments.

### IV 1: Cost Shifters

First set of instruments: **cost shifters**.

``` r
fm_costiv <- ivreg(y ~ x1 + x2 + p | x1 + x2 + w, data=df)
kable(tidy(fm_costiv), digits=4)
```

| term        | estimate | std.error | statistic | p.value |
|:------------|---------:|----------:|----------:|--------:|
| (Intercept) |   0.8247 |    0.4743 |    1.7387 |  0.0822 |
| x1          |   0.6131 |    0.0702 |    8.7291 |  0.0000 |
| x2          |   2.0288 |    0.1580 |   12.8388 |  0.0000 |
| p           |  -0.9950 |    0.2527 |   -3.9380 |  0.0001 |

Now the estimate of $\alpha$ is negative and significant.

### IV 2: BLP Instruments

Second set of instruments: **product characteristics of other firms in
the same market**.

``` r
fm_blpiv <- ivreg(y ~ x1 + x2 + p | x1 + x2 + z1 + z2, data=df)
kable(tidy(fm_blpiv), digits=4)
```

| term        | estimate | std.error | statistic | p.value |
|:------------|---------:|----------:|----------:|--------:|
| (Intercept) |   0.3754 |    0.4375 |    0.8581 |  0.3909 |
| x1          |   0.5828 |    0.0677 |    8.6100 |  0.0000 |
| x2          |   1.8876 |    0.1467 |   12.8690 |  0.0000 |
| p           |  -0.7491 |    0.2323 |   -3.2248 |  0.0013 |

Also the BLP instruments deliver an estimate of $\alpha$ is negative and
significant.

## References

------------------------------------------------------------------------
