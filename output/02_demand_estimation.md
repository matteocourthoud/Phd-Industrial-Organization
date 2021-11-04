---
author: Matteo Courthoud
bibliography: references.bib
date: 2021-10-29
output:
  html_document:
    toc: true
    toc_collapsed: true
    toc_depth: 3
    toc_float: true
  ioslides_presentation:
    slide_level: 3
    smaller: true
    transition: 0
    widescreen: true
  md_document:
    preserve_yaml: true
    variant: markdown_mmd
  ml_notebook:
    toc: true
    toc_depth: 2
title: Demand Estimation
type: book
weight: 2
---

## Supply

### Setting

Oligopoly Supply

-   firms produce differentiated goods/products

-   selling to consumers with heterogeneous preferences

-   static model, complete information

    -   products are given

    -   equilibrium: NE for each product/market

Workhorse model: Berry, Levinsohn, and Pakes (1995)

### Cost Function

Variable cost of product $j$: $C_j (Q_j , w_{jt} , \omega_{jt}, \gamma)$

-   $Q_j$: total quantity of good j sold

-   $w_{jt}$ observable cost shifters; may include product
    characteristics $x_{jt}$ that will affect demand (later)

-   $\omega_{jt}$ unobserved cost shifters (“cost shocks”); may be
    correlated with latent demand shocks (later)

-   $\gamma$: parameters

Notes

-   for multi-product firms, we’ll assume variable cost additive across
    products for simplicity

-   we ignore fixed costs: these affect entry/exit/innovation but not
    pricing, *conditional on these things*

### Notation

-   $J_t$: products/goods/choices in market t (for now $J_t = J$)

-   $\boldsymbol p_t = (p_{1t},...,p_{Jt})$: prices of all goods

-   $\boldsymbol \chi_t = ( \chi_{1t} , … , \chi_{Jt})$ : other
    characteristics of goods affecting demand (observed and unobserved
    to us)

### Equilibrium Pricing

-   Demand system:

    $$
    q_{jt} = \boldsymbol q_j (\boldsymbol p_t, \boldsymbol \chi_t) \quad \text{for} \quad j = 1,...,J.
    $$

-   Profit function

    $$
    \pi_{jt} = \boldsymbol q_j (\boldsymbol p_t, \boldsymbol \chi_t) [p_{jt} − mc_j (w_{jt}, \omega_{jt}, \gamma)]
    $$

-   FOC wrt to $p_{jt}$:

    $$
    p_{jt} = mc_{jt} - q_j (\boldsymbol p_t, \boldsymbol \chi_t) \left(\frac{\partial \boldsymbol q_j}{\partial p_{jt}}\right)^{-1}
    $$

-   Inverse elasticity pricing (i.e., monopoly pricing) against the
    “residual demand curve” $q_j (\boldsymbol p_t, \boldsymbol \chi_t)$:

    $$
    \frac{p_{jt} - mc_{jt}}{p_{jt}} = - \frac{q_j (\boldsymbol p_t, \boldsymbol \chi_t)}{p_{jt}} \left(\frac{\partial \boldsymbol q_j}{\partial p_{jt}}\right)^{-1}
    $$

### What do we get?

1.  Holding all else fixed, markups/prices depend on the own-price
    elasticities of residual demand. Equilibrium depends, further, on
    how a change in price of one good affects the quantities sold of
    others, i.e., on cross-price demand elasticities

2.  If we known demand, we can also perform a **small miracle**:

    -   Re-arrange FOC

        $$
        mc_{jt} = p_{jt} + q_j (\boldsymbol p_t, \boldsymbol \chi_t) \left(\frac{\partial \boldsymbol q_j}{\partial p_{jt}}\right)^{-1}
        $$

    -   Supply model + estimated demand→estimates of marginal costs!

3.  If we know demand and marginal costs, we can”predict” a lot of
    stuff—i.e., give the quantitative implications of the model for
    counterfactual worlds

### Issues

-   Typically we need to know levels/elasticities of demand at
    particular points; i.e., effects of one price change holding all
    else fixed

-   The main challenge: unobserved demand shifters (“demand shocks”) at
    the level of the good×market (e.g., unobserved product char or
    market-specific variation in mean tastes for products)

-   demand shocks are among the things that must be held fixed to
    measure the relevant demand elasticities etc.

-   explicit modeling of these demand shocks central in the applied IO
    literature following Berry-Levinsohn-Pakes 1995 (often ignored
    outside this literature).

### Key Challenge

Let’s ignore $t$.

The demand of product $j$

$$
q_j (\boldsymbol x, \boldsymbol p, \boldsymbol \xi)
$$

depends on:

-   $\boldsymbol p$: $J$-vector of *all* goods’ prices

-   $\boldsymbol x$: $J \times k$ matrix of *all* non-price observables

-   $\boldsymbol \xi$: J-vector of demand shocks for *all* goods

**Key insight**: we have an endogeneity problem even if prices were
exogenous!

### Price Endogeneity Adds to the Challenge

-   all $J$ endogenous prices are on RHS of demand for each good

-   equilibrium pricing implies that each price depends on all demand
    shocks and all cost shocks

    -   prices endogenous

    -   control function generally is not a valid solution

-   clear that we need sources of exogenous price variation, but

    -   what exactly is required?

    -   how do we proceed?

## BLP Model

### Goals of BLP

Model of Berry, Levinsohn, and Pakes (1995)

1.  parsimonious specification to generate the distribution
    $F_U (\cdot| \boldsymbol p, \boldsymbol \xi)$ of random utilities
2.  sufficiently rich heterogeneity in preferences to permit
    reasonable/flexible substitution patterns
3.  be explicit about unobservables, including the nature of endogeneity
    “problem(s)”
4.  use the model to reveal solutions to the identification problem,
    including appropriate instruments
5.  computationally feasible (in early 1990s!) algorithm for consistent
    estimation of the model and standard errors.

### Utility Specification

Utility of consumer $i$ for product $j$

$$
u_{ij} = x_j \beta_i - \alpha p_j + \xi_j + \epsilon_{ij}
$$

Where

-   $x_j$: $K$-vector of characteristics of product $j$

-   $\beta_{i} = (\beta_{i}^{1}, \ldots, \beta_{i}^K)$: vector of tastes
    for characteristics $1,…,K$

    -   $\beta_{i}^k = \beta_0^k + \sigma_k \zeta_{i}^k$

        -   $\beta_0^k$: usual taste for characteristic $k$

        -   $\zeta_{i}^k$: random taste, i.i.d. across consumers and
            markets

-   $\alpha$: price elasticity

-   $p_{j}$ price of product $j$

-   $\xi_{j}$: unobservable product shock at the level of products
    $\times$ market

-   $\epsilon_{ij}$: idiosyncratic (and latent) taste

### Exogenous and Endogenous Product Characteristics

Utility of consumer $i$ for product $j$

$$
u_{ij} = x_j \beta_i - \alpha p_j + \xi_j + \epsilon_{ij}
$$

-   exogenous characteristics: $x_{j} \perp \xi_{j}$

-   endogenous characteristics: $p_{j}$ (usually a scalar, price)

    -   typically each $p_j$ will depend on whole vector
        $\boldsymbol \xi = (\xi_1 , . . . , \xi_J )$ (and on own and
        others’ costs)

    -   we need to distinguish true effects of prices on demand from the

    -   effects of $\boldsymbol \xi$ ; this will require instruments

    -   of course the equation above is not an estimating equation
        ($u_{ij}$ not observed)

    -   because prices and quantities are all endogenous - indeed
        determined - simultaneously, you may suspect (correctly) that
        instruments for prices alone may not suffice.

### Utility Specification, Rewritten

Rewrite

$$
\begin{align}
u_{ij} &= x_j \beta_i - \alpha p_j + \xi_j + \epsilon_{ij} = \newline
&= \delta_j + \nu_{ij}
\end{align}
$$

where

-   $\delta_j = x_j \beta_0 - \alpha p_j + \xi_j + \epsilon_{ij}$: mean
    utility of good $j$ in market $t$
-   $\nu_{i j}=\sum_{k} x_{j t}^{k} \sigma^{k} \zeta_{i t}^{k}+\epsilon_{i j} \equiv x_{j} \tilde{\beta}_{i} + \epsilon_{i j}$
    -   We split $\beta_i$ into its random ($\tilde{\beta}_{i}$) and
        non-random ($\beta_0$) part

## References

------------------------------------------------------------------------

<div id="refs" class="references csl-bib-body hanging-indent"
markdown="1">

<div id="ref-berry1995automobile" class="csl-entry" markdown="1">

Berry, Steven, James Levinsohn, and Ariel Pakes. 1995. “Automobile
Prices in Market Equilibrium.” *Econometrica: Journal of the Econometric
Society*, 841–90.

</div>

</div>