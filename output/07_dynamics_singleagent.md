---
author: Matteo Courthoud
bibliography: references.bib
date: 2021-10-29
editor_options:
  markdown:
    wrap: 72
link-citations: true
output:
  html_document:
    keep_md: true
    toc: true
    toc_collapsed: true
    toc_depth: 3
    toc_float: true
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
title: Single Agent Dynamics
type: book
weight: 7
---

## Introduction

### Motivation

Agents take decisions that affect payoffs in the future

This is very common in empirical IO:

-   Durable goods

    -   Gowrisankaran and Rysman
        ([2012](#ref-gowrisankaran2012dynamics))

-   “Stockpiling” during sales

    -   Erdem, Imai, and Keane ([2003](#ref-erdem2003brand)), Handel
        ([2013](#ref-handel2013adverse))

-   Learning

    -   Erdem and Keane ([1996](#ref-erdem1996decision)), Crawford and
        Shum ([2005](#ref-crawford2005uncertainty))

-   Switching costs

    -   Handel ([2013](#ref-handel2013adverse))

### Motivation

But also in other applied micro fields:

-   Labor economics

    -   Should you go to college? ([Keane and Wolpin
        1997](#ref-keane1997career))

-   Health economics

    -   Which health insurance to pick given there are switching costs?
        ([Handel 2013](#ref-handel2013adverse))

    -   Addiction ([Becker and Murphy 1988](#ref-becker1988theory))

-   Public finance

    -   How should you set optimal taxes in a dynamic environment?
        ([Golosov et al. 2006](#ref-golosov2006new))

### Dynamic Models

In some cases, we can reduce a dynamic problem to a:

1.  Static problem
2.  Reduced-form problem

E.g., Investment decision

-   Dynamic problem, as gains are realized after costs

-   “Static” Solution: Invest if $\mathbb E (NPV ) > TC$

-   Decision variable today ($i_t=0$ or $1$) does not affect the amount
    of future payoffs (NPV)

But many cases where it’s hard to evaluate dynamic questions in a
static/reduced-form setting.

-   Typically, cases where decision today would affect payoffs tomorrow

### Dynamic Models

Examples

1.  Learning by doing ([Benkard 2000](#ref-benkard2000learning))

    -   Selling today decreases marginal cost tomorrow

2.  Investment ([Ericson and Pakes 1995](#ref-ericson1995markov))

    -   Investment today reduces marginal cost tomorrow

### Advantages and Disadvantages

Advantages

-   We are able to exploit the information contained in agents’
    decisions

-   We are able to address policy questions that cannot be addressed
    with reduced-form methods

    -   (e.g. Because the policy does not currently exist)

    -   Standard advantage of structural estimation

### Advantages and Disadvantages

Disadvantages

-   We typically need more assumptions

    -   Robustness testing will therefore be important

-   Identification in dynamic models is less transparent

    -   Thus time should be spent articulating what variation in the
        data identifies our parameters of interest)

-   It is often computationally intensive (i.e., slow / unfeasible)

### Single- vs Multi-Agent

-   Typically in IO we study agents in strategic environments

-   Much more complicated in structural dynamics

    -   Why? State space blows up

    -   Single agent: need to track what the agent sees ($K$ states)

    -   Multi-agent: need to keep track what every agent sees ($K^N$
        states)

### Single Agent Setting

Single agent decision problems can be viewed as a “game against nature”

We will discuss dynamic models within a framework of Markov decision
processes (MDP)

Formally, a discrete-time MDP consists of the following objects

-   A time index $t \in \lbrace 0,1,2,...,T \rbrace$, for
    $T \leq \infty$;

    -   (Could have continuous time, but uses a different set of tools)

-   A state space $\mathcal S$

-   A decision space $\mathcal D$

-   A family of constraint sets
    $\lbrace \mathcal D_t(s_t) \subseteq \mathcal D \rbrace$

    -   (Omitted if set of possible decisions is the same in every
        state)

## Rust (1987)

### Setting

Rust ([1987](#ref-rust1987optimal)): *An Empirical Model of Harold
Zurcher*

-   Harold Zurcher (HZ) is the city bus superintendant in Madison, WI

-   As bus engines get older, the probability of malfunctions increases

-   HZ decides when to replace old bus engines with new ones

    -   Approx. every 4 or 5 years, 250,000 miles

    -   Simplest investment problem

-   **Tradeoff**

    -   Cost of a new engine (fixed, stock)

-   Repair costs (continuous, flow)

### Data

Rust observes about 150 buses over time

For each bus, he sees

-   monthly mileage (RHS, state variable)
-   and whether the engine was replaced (LHS, choice variable),
-   in a given month

### Model

Assumptions of structural model

-   **State**: $x_t \in \lbrace 0, ... , x_{max} \rbrace$
    -   engine mileage at time $t$
-   **Decision**: $i_t \in \lbrace 0, 1 \rbrace$
    -   replace engine at month $t$
-   **State transitions**:
    $\Pr ( x_{t+1} | x_{0}, ... , x_{t} ; \theta)= \Pr (x_{t+1} | x_{t} ; \theta )$
    -   $x_t$ evolves exogenously according to a 1st-order Markov
        process
    -   The transition function is the same for every bus.
    -   If HZ replaces in period $t$ ($i_t = 1$), then $x_t = 0$

### Model (2)

HZ **static utility function** (for a single bus) $$
u\left(x_{t}, i_{t} ; \theta\right)= \begin{cases}-c\left(x_{t} ; \theta\right) & \text { if } i_{t}=0 \text { (not replace) } \newline -R-c(0 ; \theta) & \text { if } i_{t}=1 \text { (replace) }\end{cases}
$$ where

-   $c(x_t ; \theta)$: expected costs of operating a bus with mileage
    $x_t$ (including maintenance costs & social costs of breakdown).
    -   We would expect $\frac{\partial c}{\partial x}>0$
-   $R$ is the cost of replacement (i.e., a new engine)
    -   Note that replacement occurs immediately
-   $u(x_t , i_t ; \theta)$: expected current utility from operating a
    bus with mileage $x_t$ and making replacement decision $i_t$

### Model (3)

HZ **objective function** is to maximize the expected present discounted
sum of future utilities $$
V(x_t ; \theta) = \max_{\Pi} \mathbb E_{x_{t+1}} \left[\sum_{\tau=t}^{\infty} \beta^{\tau-t} u\left(x_{\tau}, i_{\tau} ; \theta\right) \Bigg| x_{t}, \Pi ; \theta\right]
$$ where

-   The expectation $\mathbb E$ is over future $x$, which evolve
    according to Markov process
-   $\max$ is over future choices $i_{t+1}, ... ,i_{\infty}$,
    -   because HZ will observe future $x_{\tau}$s before choosing
        future $i_\tau$s, this is a functional
    -   $\Pi$ maps future states into future choices: policy function

**Notes**

-   This is for one bus (but multiple engines).
-   HZ has an infinite horizon for his decision making
-   $x_t$ summarizes state at time $t$, i.e., the expected value of
    future utilities only depends on $x_t$

### Bellman Equation

This (sequential) representation of HZ’s problem is very cumbersome to
work with.

Theory of dynamic programming (see SLP) says that under regularity
conditions, $V (x_t; \theta)$ satisfies the following Bellman equation
$$
V\left(x_{t} ; \theta\right) = \max_{i_{t}} \Bigg\lbrace u\left(x_{t}, i_{t} ; \theta\right)+\beta \mathbb E_{x_{t+1}} \Big[V\left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t} ; \theta\Big] \Bigg\rbrace
$$ Basically we are dividing the ifinite sum (in the sequential form)
into a present component and a future component.

Notes:

-   Same $V$ on both sides of equation because of infinite horizon - the
    future looks the same as the present for a given x (i.e., it doesn’t
    matter where you are in time).
-   The expectation $\mathbb E$ is over the state-transition
    probabilities, $\Pr (x_{t+1} | x_t, i_t ; \theta)$

### Order of Markow Process

Suppose for a moment that $x_t$ follows a second-order markov process $$
x_{t+1}=f\left(x_{t}, {\color{red}{x_{t-1}}}, \varepsilon ; \theta\right)
$$ Now $x_t$ is not sufficient to describe current $V$

-   We need both $x_t$ and $x_{t-1}$ in the state space (i.e.,
    $V (x_t , {\color{red}{x_{t-1}}}; \theta)$ contains $x_{t-1}$, too),
-   and the expectation is over the transition probability
    $\Pr (x_{t+1} | x_t, {\color{red}{x_{t-1}}}, i_t ; \theta)$

General rule about what needs to be in the state space of a Bellman
equation:

-   Variables in state space need to:
    -   define expected current payoff, and
    -   define expectations over next period state (i.e., distribution
        of $x_{t+1}$)
-   **Memo**: in the 2nd-order Markov process, $x_{t-1}$ does not enter
    current utility but is still necessary for defining expectations
    over $x_{t+1}$.

### Policy Function

Along with this value function is a corresponding **policy (or choice)
function** mapping the state $x_t$ into HZ’s optimal replacement choice
$i_t$ $$
i_{t} \left(x_{t} ; \theta\right) =  \max_{i_{t}} \Bigg\lbrace u\left(x_{t}, i_{t} ; \theta\right) + \beta \mathbb E_{x_{t+1}} \Big[ V \left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t} ; \theta\Big] \Bigg\rbrace
$$ Given $\frac{\partial c}{\partial x}>0$, the optimal policy function
has the form $$
i_{t}\left(x_{t} ; \theta\right) =  \begin{cases}1 & \text { if } x_{t} \geq \gamma(\theta) \newline 0 & \text { if } x_{t}<\gamma(\theta)\end{cases}
$$ where $\gamma$ is the replacement mileage.

How would this compare with the optimal replacement mileage if HZ was
myopic?

-   Answer: HZ would wait until $R \leq c$ for the replacement action

### Solving the Model

Why do we want to solve for the value and policy functions?

-   We want to know the agentís optimal behavior and the equilibrium
    outcomes
-   and be able to conduct comparative statics/dynamics (a.k.a.
    counterfactual simulations)

We have the Bellman equation $$
V\left(x_{t} ; \theta\right) = \max_{i_{t}} \Bigg\lbrace u\left(x_{t}, i_{t} ; \theta\right)+\beta \mathbb E_{x_{t+1}} \Big[V\left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t} ; \theta\Big] \Bigg\rbrace
$$ Which we can compactly write as $$
V\left(x_{t} ; \theta\right) = T \Big( V\left(x_{t+1} ; \theta\right) \Big)
$$ **Blackwell’s Theorem** (Contraction Mapping Theorem): under
regularity conditions (i.e., $u(\cdot)$ bounded and $\beta<1$), $T$ is a
contraction mapping with modulus $\beta$.

### Solving the Model (2)

What does **Blackwell’s Theorem** allow us to do?

1.  Start with any arbitrary function $V^0(\cdot)$
2.  Apply the mapping $T$ to get $V^1(\cdot) = T (V^0(\cdot))$
3.  Apply again $V^2(\cdot) = T (V^1(\cdot))$
4.  Continue applying $T$ , and $V^n$ will converge to the unique fixed
    point of $T$
    -   i.e., the true value function $V(x_t; \theta)$
5.  Once we have $V(x_t; \theta)$, it’s fairly trivial to compute the
    policy function $i(x_t; \theta)$

This process is called **value function iteration**

## Estimation - Rust (1987)

### Estimation Routine

1.  Pick a parameter value $\theta$
2.  Solve value and policy function (*inner loop*)
3.  Match *predicted choices* with *observed choices*
4.  Find the parameter value $\hat \theta$ that best fits the data
    (*outer loop*)
    -   Makes the observed choices ìclosestî to the predicted choices
    -   (or maximizes the likelihood of the observed choices)

**Issue**

-   The model results in a policy function of the form: replace iff
    $x_t \geq \gamma(\theta)$
    -   Can’t explain the coexistence of e.g. “*a bus without
        replacement at 22K miles*” and “*another bus being replaced at
        17K mile*s” in the data
    -   We need some unobservables in the model to explain why observed
        choices do not exactly match predicted choices

### Unobservables

Rust uses the utility specification: $$
\begin{aligned}
u\left(x_{t}, i_{t}, \epsilon_{t} ; \theta\right) &=u\left(x_{t}, i_{t} ; \theta\right)+\epsilon_{i_{t} t} \newline
&= \begin{cases}-c\left(x_{t} ; \theta\right)+\epsilon_{0 t} & \text { if } \ i_{t}=0 \newline
-R-c(0 ; \theta)+\epsilon_{1 t} & \text { if } \ i_{t}=1\end{cases}
\end{aligned}
$$

-   The $\epsilon_i$s are components of utility from each alternative
    that are observed by HZ but not by us as econometrician.
    -   E.g., the fact that an engine is running unusually smoothly
        given its mileage, or the fact that HZ is sick and doesn’t feel
        like replacing the engine this month
-   The $\epsilon_i$s also affect HZ’s replacement decision
-   Since **both observed and relevant**: part of the state space:
    $V(x_t, \epsilon_t, \theta)$
    -   Do past $\epsilon$ also enter the state space?
    -   Same question we had for $x$
    -   We ruled it out with the Markow Assumption

### Assumptions

Rust makes **4 assumptions** to make the problem tractable:

1.  First order Markow process of $\epsilon$
2.  Conditional independence of $\epsilon_t$ from $\epsilon_{t-1}$ and
    $x_{t-1}$ on $x_t$
3.  Independence of $\epsilon_t$ from $x_t$
4.  Logit distribution of $\epsilon$

We analyze them one by one

### Assumption 1

**Assumption 1**: first-order markov process of $\epsilon$ $$
\Pr \Big(x_{t+1}, \epsilon_{t+1} \Big| x_{1}, ..., x_{t}, \epsilon_{1}, ..., \epsilon_{t}, i_{t} ; \theta\Big) = \Pr \Big(x_{t+1}, \epsilon_{t+1} \Big| x_{t}, \epsilon_{t}, i_{t} ; \theta \Big)
$$

-   **What it buys**
    -   $x$ and $\epsilon$ prior to current period are irrelevant
-   **What it still allows**:
    -   serial correlation in the variables
    -   allows $x_t$ to be correlated with $\epsilon_t$

### Assumption 1 - Implications

The Bellman equation is $$
V\left(x_{t}, {\color{red}{\epsilon_{t}}} ; \theta\right) = \max_{i_{t}} \Bigg\lbrace u\left(x_{t}, i_{t} ; \theta\right) + {\color{red}{\epsilon_{i_{t} t}}} + \beta \mathbb E_{x_{t+1}, {\color{red}{\epsilon_{t+1}}}} \Big[V(x_{t+1}, {\color{red}{\epsilon_{t+1}}} ; \theta) \Big| x_{t}, i_{t}, {\color{red}{\epsilon_{t}}} ; \theta \Big] \Bigg\rbrace
$$

-   Now the state is $(x_t, \epsilon_t)$
    -   sufficient, because defines both current utility and (the
        expectation of) next-period state, under the first-order Markov
        assumption.
    -   $\epsilon_t$ is now analogous to $x_t$
-   Solution method: as before
    -   If $\epsilon_t$ is continuous, has to be discretised

### Assumption 1 - Issues

**Issues**

1.  **Curse of dimensionality in the state space**

    -   Before, there were $K$ points in state space (the number of
        possible $x$)
    -   Now, for the same grid size, there are $K^3$ : $K$ each for $x$,
        $\epsilon_0$, $\epsilon_1$
        -   **Memo**: $\epsilon$ is 2-dimensional
    -   Generally, number of points in state space (and thus
        computational time) increases exponentially in the number of
        variables

2.  **Curse of dimensionality in the expected value**

    -   For each point in state space (at each iteration of the
        contraction mapping), need to compute

    $$
    \mathbb E_{x_{t+1}, \epsilon_{t+1}} \Big[V (x_{t+1}, \epsilon_{t+1} ; \theta) \Big|  x_{t}, i_{t}, \epsilon_{t} ; \theta \Big]
    $$

    -   Before, this was a 1-dimensional integral (or sum), not it’s
        3-dimensional

3.  **Initial conditions**

### Assumption 2

**Assumption 2**: conditional independence of $\epsilon_t$ from
$\epsilon_{t-1}$ and $x_{t-1}$ on \$ $$
\Pr \Big( x_{t+1}, \epsilon_{t+1} \Big| x_{1}, ..., x_{t}, \epsilon_{1}, ..., \epsilon_{t}, i_{t} ; \theta \Big) = \Pr \Big( \epsilon_{t+1} \Big| x_{t+1} ; \theta \Big) \Pr \Big( x_{t+1} \Big| x_{t}, i_{t} ; \theta \Big)
$$

-   **What it buys**
    -   $x_{t+1}$ is independent of $\epsilon_t$
    -   $\epsilon_{t+1}$ is independent of $\epsilon_t$ and $x_t$,
        conditional on $x_{t+1}$
-   **What it still allows**:
    -   $\epsilon$ can be correlated across time, but only through the
        $x$ process

### Assumption 2 - Implications

The Bellman equation is $$
V\left(x_{t}, {\color{red}{\epsilon_{t}}} ; \theta\right) = \max_{i_{t}} \Bigg\lbrace u\left(x_{t}, i_{t} ; \theta\right) + {\color{red}{\epsilon_{i_{t} t}}} + \beta \mathbb E_{x_{t+1}, {\color{red}{\epsilon_{t+1}}}} \Big[V (x_{t+1}, {\color{red}{\epsilon_{t+1}}} ; \theta) \Big| x_{t}, i_{t} ; \theta \Big] \Bigg\rbrace
$$

-   Now $\epsilon_{t}$ is noise that doesnít affect the future
    -   That is, conditional on $x_{t+1}$, $\epsilon_{t+1}$ is
        uncorrelated with $\epsilon_{t}$
-   We have solved the second issue: **curse of dimensionality in the
    expected value**
-   However, we still have the **curse of dimensionality in the state
    space**

### Rust Shortcut: ASV

Rust: define the **alternative-specific value function** $$
\begin{aligned}
&\bar V_0 \left(x_{t} ; \theta\right) = u\left(x_{t}, 0 ; \theta\right) + \beta \mathbb E_{x_{t+1}, \epsilon_{t+1}} \Big[V\left(x_{t+1}, \epsilon_{t+1} ; \theta\right) | x_{t}, i_{t}=0 ; \theta\Big] \newline
&\bar V_1 \left(x_{t} ; \theta\right) = u\left(x_{t}, 1 ; \theta\right) + \beta \mathbb E_{x_{t+1}, \epsilon_{t+1}} \Big[V\left(x_{t+1}, \epsilon_{t+1} ; \theta\right) | x_{t}, i_{t}=1 ; \theta\Big]
\end{aligned}
$$

-   $\bar V_0 (x_t)$ is the present discounted value of not replacing,
    net of $\epsilon_{0t}$

-   It does **not** depend on $\epsilon_{0t}$

-   What is the relationship with the value function? $$
    V\left(x_{t}, \epsilon_{t} ; \theta\right) = \max_{i_{t}} \Bigg\lbrace \begin{array}{l}
    \bar V_0 \left(x_{t} ; \theta\right)+\epsilon_{0 t} \newline
    \bar V_1 \left(x_{t} ; \theta\right)+\epsilon_{1 t}
    \end{array} \Bigg\rbrace
    $$

-   We have a 1-to-1 mapping between
    $V\left(x_{t}, \epsilon_{t} ; \theta\right)$ and
    $\bar V_i \left(x_{t} ; \theta\right)$ !

### Rust Shortcut

Can we solve for ?

Yes! They have a **Bellman Equation** formulation $$
\begin{aligned}
&
\bar V_0 \left(x_{t} ; \theta\right) = u\left(x_{t}, 0 ; \theta\right) + \beta \mathbb E_{x_{t+1}, \epsilon_{t+1}} \Bigg[ \max_{i_{t+1}} \Bigg\lbrace \begin{array}{l}
\bar V_0 \left(x_{t+1} ; \theta\right)+\epsilon_{0 t+1} \newline
\bar V_1 \left(x_{t+1} ; \theta\right)+\epsilon_{1 t+1}
\end{array} \Bigg\rbrace \Bigg| x_{t}, i_{t}=0 ; \theta \Bigg] \newline
&
\bar V_1 \left(x_{t} ; \theta\right) = u\left(x_{t}, 1 ; \theta\right) + \beta \mathbb E_{x_{t+1}, \epsilon_{t+1}} \Bigg[ \max_{i_{t+1}} \Bigg\lbrace \begin{array}{l}
\bar V_0 \left(x_{t+1} ; \theta\right)+\epsilon_{0 t+1} \newline
\bar V_1 \left(x_{t+1} ; \theta\right)+\epsilon_{1 t+1}
\end{array} \Bigg\rbrace \Bigg| x_{t}, i_{t}=1 ; \theta \Bigg] \newline
\end{aligned}
$$

-   Rust ([1988](#ref-rust1988maximum)) shows that it’s a joint
    contraction mapping
-   **Memo**: the state space now is $2K$
    -   Much much faster!
-   **Lesson**: any state variable that does not affect continuation
    values (the future) does not have to be in the “actual” state space

### Assumption 3

**Assumption 3**: independence of $\epsilon_t$ from $x_t$ $$
\Pr \Big( x_{t+1}, \epsilon_{t+1} \Big| x_{1}, ..., x_{t}, \epsilon_{1}, ..., \epsilon_{t}, i_{t} ; \theta \Big) = \Pr \big( \epsilon_{t+1} \big| \theta \big) \Pr \Big( x_{t+1} \Big| x_{t}, i_{t} ; \theta \Big)
$$

-   **What it buys**
    -   $\epsilon$ not correlated with anything
-   **What it still allows**
    -   any distribution of $\epsilon$

### Assumption 4

**Assumption 4**: $\epsilon$ is type 1 extreme value distributed (logit)

In the Bellman Equation of the alternative-specific value function we
had $$
\mathbb E_{x_{t+1}, \epsilon_{t+1}} \Bigg[ \max_{i_{t+1}} \Bigg\lbrace \begin{array}{l}
\bar V_0 \left(x_{t+1} ; \theta\right)+\epsilon_{0 t+1} \newline
\bar V_1 \left(x_{t+1} ; \theta\right)+\epsilon_{1 t+1}
\end{array} \Bigg\rbrace \Bigg| x_{t}, i_{t}=0 ; \theta \Bigg]
$$ Hard to compute for general distribution of $\epsilon$ (simulation).

**Logit magic** $$
\mathbb E_{\epsilon} \Bigg[ \max_n \bigg( \Big\lbrace \delta_n + \epsilon_n \Big\rbrace_{n=1}^N \bigg) \Bigg] = 0.5772 + \ln \bigg( \sum_{n=1}^N e^{\delta_n} \bigg)
$$

-   Where $0.5772$ is Euler’s constant

### Assumption 4 - Implication

The Bellman equation becomes $$
\begin{aligned}
&
\bar V_0 \left(x_{t} ; \theta\right) = u\left(x_{t}, 0 ; \theta\right) + \beta \mathbb E_{x_{t+1}} \Bigg[ 0.5772 + \ln \Bigg( \begin{array}{l}
\bar V_0 \left(x_{t+1} ; \theta\right) \newline
\bar V_1 \left(x_{t+1} ; \theta\right)
\end{array} \Bigg) \Bigg| x_{t}, i_{t}=0 ; \theta \Bigg] \newline
&
\bar V_1 \left(x_{t} ; \theta\right) = u\left(x_{t}, 1 ; \theta\right) + \beta \mathbb E_{x_{t+1}} \Bigg[ 0.5772 + \ln \Bigg( \begin{array}{l}
\bar V_0 \left(x_{t+1} ; \theta\right)+ \newline
\bar V_1 \left(x_{t+1} ; \theta\right)
\end{array} \Bigg) \Bigg| x_{t}, i_{t}=1 ; \theta \Bigg] \newline
\end{aligned}
$$

-   We got **fully rid of $\epsilon$**!
-   How?
    -   We have decomposed $\mathbb E_{x_{t+1}, \epsilon_{t+1}} [\cdot]$
        into \$`\mathbb `{=tex}E\_{x\_{t+1}}
        `\Big[ \mathbb E_{\epsilon_{t+1}}[\cdot] `{=tex}`\Big`{=tex}\]
        \$
    -   And exploited the availability of an analytical solution for the
        $\mathbb E_{\epsilon_{t+1}}[\cdot]$ part

### Likelihood Function

What is the impact of Assumptions 1-4 on the likelihood function? $$
\mathcal L = \Pr \Big(x_{2}, ... , x_{T}, i_{1}, ... , i_{T} \Big| x_{1} ; \theta\Big)
$$

1.  First order Markow process of $\epsilon$ $$
    \mathcal L = \prod_{t=1}^T \Pr \Big(i_{t+1} , x_{t+1} \Big| x_t, i_t ; \theta\Big)
    $$

2.  Conditional independence of $\epsilon_t$ from $\epsilon_{t-1}$ and
    $x_{t-1}$ on $x_t$ $$
    \mathcal L = \prod_{t=1}^T \Pr \big(i_t \big| x_t ; \theta\big) \Pr \Big(x_{t+1} \Big| x_t, i_t ; \theta\Big)
    $$

### Likelihood Function (2)

We have decomposed the likelihood in pieces of form
$\Pr \big(x_{t+1} \big| x_t, i_t ; \theta\big)$ and
$\Pr \big(i_t \big| x_t ; \theta\big)$

-   $\Pr \big(x_{t+1} \big| x_t, i_t ; \theta\big)$ can be estimated
    from the data
-   for $\Pr \big(i_t \big| x_t ; \theta\big)$ we need the two remaining
    assumptions

With the last 2 assumptions:

1.  Independence of $\epsilon_t$ from $x_t$

$$
\Pr \big(i_t=0 \big| x_t ; \theta \big) = \Pr \Big( \bar V_0 (x_{t+1} ; \theta) + \epsilon_{0 t+1} \geq \bar V_1 (x_{t+1} ; \theta) +\epsilon_{0 t+1} \Big| x_t ; \theta \Big)
$$

1.  Logit distribution of $\epsilon$

$$
\Pr \big(i_t=0 \big| x_t ; \theta \big) = \frac{e^{\bar V_0 (x_{t+1} ; \theta)}}{e^{\bar V_0 (x_{t+1} ; \theta)} + e^{\bar V_1 (x_{t+1} ; \theta)}}
$$

### Estimation

Now we have all the pieces to estimate $\theta$!

**Procedure**

1.  Select a value of $\theta$
2.  Estimate the state transition probabilities
    $\Pr \big(x_{t+1} \big| x_t, i_t ; \theta\big)$
3.  Init a choice-specific value function
    $\bar V^0_i (x_{t+1} ; \theta)$
    1.  Apply the Bellman operator to compute
        $\bar V^1_i (x_{t+1} ; \theta)$
    2.  Iterate until convergence to $\bar V_i (x_{t+1} ; \theta)$
        (*inner loop*)
4.  Compute the choice probabilities
    $\Pr \big(i_t\big| x_t ; \theta \big)$
5.  Compute the likelihood
    $\mathcal L = \prod_{t=1}^T \Pr \big(i_t \big| x_t ; \theta\big) \Pr \Big(x_{t+1} \Big| x_t, i_t ; \theta\Big)$
6.  Iterate until you are have found a (possibly global) minimum (*outer
    loop*)

## Estimation - Hotz & Miller (1993)

### Motivation

-   Look at the same Harold Zurcker problem

-   There are two main equations

    -   **Bellman equation** $$
        V(\cdot; \theta) = f(V(\cdot; \theta))
        $$

    -   **Expected policy function** $$
        P(\cdot; \theta) = g(V(\cdot; \theta); \theta)
        $$

        -   Given state, shock, & parameters, you decide whether to
            invest or not

        -   Expectation taken w.r.t. $\epsilon_t$: before the shocks are
            realized

        -   Easier to work with: not a deterministic policy, but a
            stochastic one

            -   Similar to a likelihood function

### Example

-   Consider the Harold Zurcker problem

-   Probability of replacement $$
    \begin{align}
    P\left(x_{t} ; \theta\right) &= \Pr \left(i_{t}=1 | x_{t} ; \theta \right) \newline
    &= \Pr \left(\begin{array}{c}
    u\left(x_{t}, 0 ; \theta\right)+\epsilon_{0 t}+\beta \mathbb E \Big[V\left(x_{t+1}, \epsilon_{t+1} ; \theta\right) \Big| x_{t}, \epsilon_{t}, i_{t}=0 ; \theta \Big] \newline
    \leq u\left(x_{t}, 1 ; \theta\right) + \epsilon_{1 t}+\beta \mathbb E \Big[ V\left(x_{t+1}, \epsilon_{t+1} ; \theta \right) \Big| x_{t}, \epsilon_{t}, i_{t}=1 ; \theta \Big]
    \end{array}\right)
    \end{align}
    $$

-   Depends on a simple inequality comparing

    -   Static utility
    -   Random shock
    -   Future value

    Conditional on each outcome $[0, 1 ]$

-   Before $P(x_t, \epsilon_t; \theta)$ was giving a mapping from
    $x_t \times \epsilon$ to $[0, 1]$

-   Now $P(x_t; \theta)$ maps from $x_t$ to $[0,1]$

-   Mathematically, $P(x_t; \theta)$ is equal to the integral of
    $P(x_t, \epsilon_t; \theta)$ over the distribution of $\epsilon_t$

### Compare with Rust

-   Rust solves the whole problem

-   Issue (that HM try to solve): step 2 of solving the value function
    is time consuming

    -   Especially when the state space is large

-   Also step 4 can be done differently

    -   Rust uses ML

    -   Can be used with GMM $$
        \mathbb E [i_t - P(x_t, \theta) | x_t] = 0 \quad \text{ at } \quad \theta = \theta_0
        $$

    -   How do we choose between GMM and MLE?

        -   Ask an econometrician

### Hotz, Miller (1993) idea

There is an alternative representation of $V$ and $P$

$$
\begin{aligned}
V(\cdot ; \theta) & =h(P(\cdot ; \theta) ; \theta) \newline
P(\cdot ; \theta) & =g(V(\cdot ; \theta) ; \theta)
\end{aligned}
$$

-   it’s an equally valid representation

-   but more convenient

    -   You can substitute the second equantion into the first

$$
P(\cdot ; \theta) = g(h(P(\cdot ; \theta); \theta); \theta)
$$

We can use that to estimate $\theta$

-   Guess $\theta$
-   Insert $\theta$ in the equation above and solve for
    $P(\cdot ; \theta)$
-   Use $P(\cdot ; \theta)$ to form a likelihood

However, the **problem is not solved**

-   solving for $P(\cdot ; \theta)$ still requires to solve a
    contraction mapping

### Hotz and Miller Idea

Idea: Replace $P$ on the RHS with a *consistent* estimator $\hat P$

$$
\bar P(\cdot ; \theta) = g(h(\hat P(\cdot) ; \theta); \theta)
$$

-   $\bar P(\cdot ; \theta_0)$ will converge to the true\$
    P(`\cdot `{=tex}; `\theta`{=tex}\_0)\$, because $\hat P (\cdot)$ is
    converging to $P(\cdot ; \theta_0)$ asymptotically.

    -   **Note**: pay attention to $\theta_0$ vs $\theta$ here:
        $\bar P(\cdot ; \theta)$ does NOT generally converge to
        $P(\cdot ; \theta)$for arbitrary $\theta$, because
        $\hat P(\cdot)$ is converging to $P(\cdot ; \theta_0)$ but NOT
        $P(\cdot ; \theta)$ with any $\theta$.

How to compute $\hat P(\cdot)$?

-   From the data, you observe states and decisions

-   You can compute frequency of decisions given states

    -   In Rust: frequency of engine replacement, given a mileage
        (discretized)

-   Assumption: you have enough data

    -   What if a state is not realised?
    -   Use frequencies in observed states to extrapolate frequencies in
        observed states

### Estimation

Estimation steps

-   Estimate $\hat P$ from the data

-   $g$ and $h$ are easy to compute given $\hat P$

-   Then we can compute $\bar P$

-   Which can be use to build an estimating equation

    -   Hotz and Miller ([1993](#ref-hotz1993conditional)) use GMM $$
        \mathbb E \Big[i_t - \bar P(x_t, \theta) \Big| x_t \Big] = 0 \quad \text{ at } \quad \theta = \theta_0
        $$

    -   Aguirregabiria and Mira
        ([2002](#ref-aguirregabiria2002swapping)) use MLE

        -   by putting $\bar P(x_t, \theta)$ in the likelihood functioni
            nstead of $P(x_t, \theta)$

### Expected Value Function

Recall Rust value function $$
V\left(x_t, \epsilon_t ; \theta\right) = \max_{i_{t}} \Bigg\lbrace u \left( x_{t}, i_{t} ; \theta \right)  + \epsilon_{i_{t} t} + \beta \mathbb E \Big[V\left(x_{t+1}, \epsilon_{t+1} ; \theta\right) \Big| x_{t}, i_{t} ; \theta\Big] \Bigg\rbrace
$$ We can express it in terms of **expected value function**

$$
V\left(x_t ; \theta\right) = \int \max_{i_{t}} \Bigg\lbrace u\left(x_t, i_t ; \theta\right)+\epsilon_{i_{t} t}+ \beta \mathbb E \Big[V\left(x_{t+1}, \epsilon_{t+1} ; \theta\right) \Big| x_{t}, i_{t} ; \theta\Big] \Bigg\rbrace g(\epsilon_t | x_t)
$$

-   Value of being in state $x_t$ without knowing the realization of the
    shock $\epsilon_t$

-   Analogous to the relationship between policy funciton and expected
    policy function

-   **Note**

    -   expectation on the RHS now is only over $x_{t+1}$
    -   $V\left(x_t ; \theta\right)$ can be solved via value function
        iterator as the operator on the RHS is a contraction

### Representation Equivalence

These alternative formulations are isomorphic

-   Value function
-   Expected value funciton
-   Alternative-specific value funciton

Recall the **alternative-specific value function** of Rust

$$
\begin{align}
\bar V_i \left( x_{t} ; \theta\right) &=u\left(x_{t}, i ; \theta\right)+\beta \mathbb E \Big[ V \left( x_{t+1}, \epsilon_{t+1} ; \theta \right) \Big| x_{t}, i_{t}=i ; \theta \Big] 
\newline
&= u \left( x_{t}, i ; \theta \right) + \beta \mathbb E \Big[ V \left( x_{t+1} ; \theta \right) \Big| x_{t}, i_{t}=i; \theta \Big]
\end{align}
$$

Relationship with the **value function**

$$
V \left(x_{t}, \epsilon_{t} ; \theta \right) = \max_{i_{t}} \Big\lbrace \bar V_0 \left( x_{t} ; \theta \right) + \epsilon_{0t}, \bar V_1 \left( x_{t} ; \theta \right) + \epsilon_{1t} \Big\rbrace
$$

Relationship with the **expected value function** $$
V\left(x_t ; \theta\right) = \int V\left(x_{t}, \epsilon_{t} ; \theta\right) g(\epsilon_t | x_t)
$$

### Goal

The standard representation of the value and policy functions is $$
\begin{align}
V(x_t ; \theta) & = f(V(x_t ; \theta) x_t ; \theta) \newline
P(x_t ; \theta) & = g(V(x_t ; \theta) x_t ; \theta)
\end{align}
$$ We first want to modify it to $$
\begin{align}
V(x_t ; \theta) & = h(P(x_t ; \theta) x_t ; \theta) \newline
P(x_t ; \theta) & = g(V(x_t ; \theta) x_t ; \theta)
\end{align}
$$ and lastly, substitute into one $$
P(x_t ; \theta) = g(h(P(x_t ; \theta) x_t ; \theta) x_t ; \theta)
$$ Last step is straightforward, first is complex.

### Express EV in terms of EP (1)

First, let’s ged rid of one operator: the **max** operator $$
\begin{aligned}
V\left(x_{t} ; \theta\right)
= \left(1-P\left(x_{t} ; \theta\right)\right) * & \left[\begin{array}{c}
u\left(x_{t}, 0 ; \theta\right) + \mathbb E \Big[\epsilon_{0 t} \Big| i_{t}=0, x_{t}\Big] \newline + \beta \mathbb E \Big[V\left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t}=0 ; \theta\Big]
\end{array}\right] 
\newline + P\left(x_{t} ; \theta\right) * & \left[\begin{array}{c}
u\left(x_{t}, 1 ; \theta\right) + \mathbb E \Big[\epsilon_{1} \Big| i_{t}=1, x_{t}\Big] \newline + \beta \mathbb E \Big[V\left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t}=1 ; \theta\Big]
\end{array}\right]
\end{aligned}
$$

-   We are just substituting the $\max$ with the policy
    $P\left(x_{t} ; \theta\right)$

-   Important: we got rid of the $\max$ operator

-   But we are still taking the expectation over

    -   Future states $x_{t+1}$
    -   Shocks $\epsilon_t$

### Express EV in terms of EP (2)

Now we get rid of another operator: the expectation over $x_{t+1}$ $$
\mathbb E \Big[V\left(x_{t+1} ; \theta\right) \Big| x_{t}, i_{t}=1 ; \theta\Big] \qquad \to \qquad \sum_{x_{t+1}} V\left(x_{t+1} ; \theta\right) \Pr \Big(x_{t+1} \Big| x_{t},_{t}=i ; \theta \Big)
$$ where

-   $\sum_{x_{t+1}}$ is the summation over the next states
-   $\Pr \left(x_{t+1} | x_{t},_{t}=i ; \theta\right)$ is the transition
    probability (conditional on a particular choice)

so that the expected value function becomes $$
\begin{aligned}
V\left(x_{t} ; \theta\right)
= \left(1-P\left(x_{t} ; \theta\right)\right) * & \left[\begin{array}{c}
u\left(x_{t}, 0 ; \theta\right) + \mathbb E \Big[\epsilon_{0 t} \Big| i_{t}=0, x_{t}\Big] \newline + \beta \sum_{x_{t+1}} V\left(x_{t+1} ; \theta\right) \Pr\Big(x_{t+1} \Big| x_{t},_{t}=0 ; \theta\Big)
\end{array}\right] 
\newline + P\left(x_{t} ; \theta\right) * & \left[\begin{array}{c}
u\left(x_{t}, 1 ; \theta\right) + \mathbb E \Big[\epsilon_{1} \Big| i_{t}=1, x_{t}\Big] \newline + \beta \sum_{x_{t+1}} V\left(x_{t+1} ; \theta\right) \Pr\Big(x_{t+1} \Big| x_{t},_{t}=1 ; \theta\Big)
\end{array}\right]
\end{aligned}
$$

### Express EV in terms of EP (3)

The previous equation, was defined at the state level $x_t$ (system of
$k$ equations, 1 for each state). If we stack them, we can write them as

$$
\begin{aligned}
V(\cdot ; \theta) =(1-P(\cdot ; \theta)) * & \left[ \begin{array}{c}
u(\cdot, 0 ; \theta) + \mathbb E\Big[\epsilon_{0 t} \Big| i_{t}=0, \cdot\Big] \newline
+\beta \ T(0 ; \theta) \ V(\cdot ; \theta)
\end{array}\right] 
\newline + P(\cdot ; \theta) * & \left[\begin{array}{c}
u(\cdot, 1 ; \theta) + \mathbb E \Big[\epsilon_{1 t} \Big| i_{t}=1, \cdot\Big] \newline
+\beta \ T(1 ; \theta) \ V(\cdot ; \theta)
\end{array}\right]
\end{aligned}
$$

where $T$: $k \times k$ matrix of transition probabilities from state\$
x_t\$ to $x_{t+1}$, given decision $i$

We can write it more compactly as $$
V(\cdot ; \theta) = \sum_i P(i;\theta) .* \bigg[ u(\cdot, i ; \theta) + \mathbb E \Big[\epsilon_{i t} \Big| i_{t}=i, \cdot\Big] + \beta \ T(i ; \theta) \ V(\cdot ; \theta) \bigg]
$$ where $.*$ is the dot product operator (or element-wise matrix
multiplication)

### Express EV in terms of EP (4)

Now we have a system of $k$ equations in $k$ unknowns that we can solve.

Tearing down notation to the bare minimum, we have $$
V = \sum_i P_i .* \bigg[ u_i + \mathbb E [\epsilon_i ] + \beta \ T_i \ V \bigg]
$$ which we can rewrite as (since the choice probabilities $P_i$ sum to
1 $$
V - \beta \ T_i \ V = \sum_i P_i .* \bigg[ u_i + \mathbb E [\epsilon_i ] \bigg]
$$

and finally we can solve for $V$ through the famous **Hotz and Miller
inversion** $$
V = \Big[I - \beta \ T_i \Big]^{-1} \ * \ \sum_i P_i \ .* \ \bigg[ u_i + \mathbb E [\epsilon_i] \bigg]
$$ Solved? No. We still need to do something about
$\mathbb E [\epsilon_i]$.

### Express EV in terms of EP (5)

We are one step away from solving from $V$

-   Given $P$ and $\theta$, everything on the RHS is a primitive of the
    model $$
    T(0 ; \theta), \ T(1 ; \theta), \ u(\cdot, 0 ; \theta), \ u(\cdot, 1 ; \theta)
    $$

    Except for $\mathbb E [\epsilon_i]$

What is $\mathbb E [\epsilon_i]$? Let’s consider for example
$\mathbb E \Big[\epsilon_{1 t} \Big| i_{t}=1, \cdot\Big]$ $$
\begin{aligned}
\mathbb E \Big[\epsilon_{1 t} \Big| i_{t}=1, \cdot\Big] &= \mathbb E \Big[\epsilon_{ t} | \bar{V_1}\left(x_{t} ; \theta\right)+\epsilon_{1 t}>\bar{V}_{0}\left(x_{t} ; \theta\right)+\epsilon_{0 t}\Big] \newline
& = \mathbb E\Big[\epsilon_{1 t} \Big| \bar{V_1}\left(x_{t} ; \theta\right)  - \bar V_0 \left(x_{t} ; \theta\right)>\epsilon_{0 t}-\epsilon_{1 t} \Big]
\end{aligned}
$$ which, in the logit world is $$
\mathbb E\left[\epsilon_{1 t} | i_{t}=1, x_{t}\right] = 0.5772 - \ln \left(P\left(x_{t} ; \theta\right)\right)
$$

-   where $0.5772$ is Euler’s constant.

We again got rid of a $\max$ operator!

### Express EV in terms of EP (6)

Now we can substitute it back and we have an equation which is *just* a
function of primitives $$
\begin{aligned}
V(\cdot ; \theta) =& \Big[I-(1-P(\cdot ; \theta)) \beta T(0 ; \theta)-P(\cdot ; \theta) \beta T(1 ; \theta)\Big]^{-1} 
\newline * & \left[ 
\begin{array}{c}
(1-P(\cdot ; \theta))\Big[u(\cdot, 0 ; \theta)+0.5772-\ln (1-P(\cdot ; \theta))\Big] \newline + P(\cdot ; \theta)\Big[u(\cdot, 1 ; \theta) + 0.5772 - \ln (P(\cdot ; \theta))\Big]
\end{array}
\right]
\end{aligned}
$$

### From V to P

In general $$
P(\cdot ; \theta)= \int I\left[\begin{array}{c}
u(\cdot, 1 ; \theta)+\epsilon_{1 t}+\beta \mathbb E \Big[V(\cdot ; \theta) \Big| \cdot, i_{t}=1 ; \theta \Big]> \newline
u(\cdot, 0 ; \theta)+\epsilon_{0 t}+\beta \mathbb E \Big[V(\cdot ; \theta) \Big| \cdot, i_{t}=0 ; \theta \Big]
\end{array}\right] g\left(\epsilon_{t} | x_{t}\right)
$$

With the logit assumption, simplifies to $$
P(\cdot ; \theta)=\frac{\exp \Big(u(\cdot, 1 ; \theta)+\beta T(1 ; \theta) V(\cdot ; \theta) \Big)}{\left(\begin{array}{c}
\exp \Big(u(\cdot, 0 ; \theta)+\beta T(0 ; \theta) V(\cdot ; \theta) \Big) \newline
+\exp \Big(u(\cdot, 1 ; \theta)+\beta T(1 ; \theta) V(\cdot ; \theta) \Big)
\end{array}\right)}
$$

This is our building block for a likelihood function.

### Estimation

Our estimation loks something like $$
P(\cdot ; \theta)= \kappa \Big( \widehat{P}(\cdot), \ T(1 ; \theta), \ T(0 ; \theta), \ u(\cdot, 1 ; \theta), \ u(\cdot, 0 ; \ \theta), \ \beta \Big)
$$ where

-   $\hat P$ comes from data
-   $T$ we can build from the data, given $\theta$
-   $u$ we should know given $\theta$
-   $\beta$ cannot be identified, has to be assumed

### Estimation

Now that you have $\hat P$, you need to combine everything to build an
estimating equation

-   log pseudo-likelihood function

$$
\sum_{i} \sum_{t} \ln \left(\begin{array}{c}
{\left[\kappa\left(\widehat{P}\left(x_{i t}\right), \widehat{T}(1), \widehat{T}(0), u\left(x_{i t}, 1 ; \theta\right), u\left(x_{i t}, 0 ; \theta\right), \beta\right)\right]^{i_{i t}}} \newline
*\left[1-\kappa\left(\widehat{P}\left(x_{i t}\right), \widehat{T}(1), \widehat{T}(0), u\left(x_{i t}, 1 ; \theta\right), u\left(x_{i t}, 0 ; \theta\right), \beta\right)\right]^{1-i_{i t}}
\end{array}\right)
$$

### Comments

There is still 1 bottleneck in HM: the inversion step $$
V = \Big[I - \beta \ T_i \Big]^{-1} \ * \ \sum_i P_i \ .* \ \bigg[ u_i + 0.5772 - \ln (P_i) \bigg]
$$ The $[I - \beta \ T_i]$ matrix has dimension $k \times k$

-   With large state space, hard to invert
-   Even with modern computational power
-   Their solution (HMSS94): forward simulation of the value function

### Identification

Work on identification

-   Magnac and Thesmar ([2002](#ref-magnac2002identifying))
-   Aguirregabiria and Suzuki
    ([2014](#ref-aguirregabiria2014identification))
-   Kalouptsidi, Scott, and Souza-Rodrigues
    ([2017](#ref-kalouptsidi2017non))
-   Kalouptsidi et al. ([2020](#ref-kalouptsidi2020partial))

## References

------------------------------------------------------------------------

<div id="refs" class="references csl-bib-body hanging-indent"
markdown="1">

<div id="ref-aguirregabiria2002swapping" class="csl-entry" markdown="1">

Aguirregabiria, Victor, and Pedro Mira. 2002. “Swapping the Nested Fixed
Point Algorithm: A Class of Estimators for Discrete Markov Decision
Models.” *Econometrica* 70 (4): 1519–43.

</div>

<div id="ref-aguirregabiria2014identification" class="csl-entry"
markdown="1">

Aguirregabiria, Victor, and Junichi Suzuki. 2014. “Identification and
Counterfactuals in Dynamic Models of Market Entry and Exit.”
*Quantitative Marketing and Economics* 12 (3): 267–304.

</div>

<div id="ref-becker1988theory" class="csl-entry" markdown="1">

Becker, Gary S, and Kevin M Murphy. 1988. “A Theory of Rational
Addiction.” *Journal of Political Economy* 96 (4): 675–700.

</div>

<div id="ref-benkard2000learning" class="csl-entry" markdown="1">

Benkard, C Lanier. 2000. “Learning and Forgetting: The Dynamics of
Aircraft Production.” *American Economic Review* 90 (4): 1034–54.

</div>

<div id="ref-crawford2005uncertainty" class="csl-entry" markdown="1">

Crawford, Gregory S, and Matthew Shum. 2005. “Uncertainty and Learning
in Pharmaceutical Demand.” *Econometrica* 73 (4): 1137–73.

</div>

<div id="ref-erdem2003brand" class="csl-entry" markdown="1">

Erdem, Tülin, Susumu Imai, and Michael P Keane. 2003. “Brand and
Quantity Choice Dynamics Under Price Uncertainty.” *Quantitative
Marketing and Economics* 1 (1): 5–64.

</div>

<div id="ref-erdem1996decision" class="csl-entry" markdown="1">

Erdem, Tülin, and Michael P Keane. 1996. “Decision-Making Under
Uncertainty: Capturing Dynamic Brand Choice Processes in Turbulent
Consumer Goods Markets.” *Marketing Science* 15 (1): 1–20.

</div>

<div id="ref-ericson1995markov" class="csl-entry" markdown="1">

Ericson, Richard, and Ariel Pakes. 1995. “Markov-Perfect Industry
Dynamics: A Framework for Empirical Work.” *The Review of Economic
Studies* 62 (1): 53–82.

</div>

<div id="ref-golosov2006new" class="csl-entry" markdown="1">

Golosov, Mikhail, Aleh Tsyvinski, Ivan Werning, Peter Diamond, and
Kenneth L Judd. 2006. “New Dynamic Public Finance: A User’s Guide \[with
Comments and Discussion\].” *NBER Macroeconomics Annual* 21: 317–87.

</div>

<div id="ref-gowrisankaran2012dynamics" class="csl-entry" markdown="1">

Gowrisankaran, Gautam, and Marc Rysman. 2012. “Dynamics of Consumer
Demand for New Durable Goods.” *Journal of Political Economy* 120 (6):
1173–1219.

</div>

<div id="ref-handel2013adverse" class="csl-entry" markdown="1">

Handel, Benjamin R. 2013. “Adverse Selection and Inertia in Health
Insurance Markets: When Nudging Hurts.” *American Economic Review* 103
(7): 2643–82.

</div>

<div id="ref-hotz1993conditional" class="csl-entry" markdown="1">

Hotz, V Joseph, and Robert A Miller. 1993. “Conditional Choice
Probabilities and the Estimation of Dynamic Models.” *The Review of
Economic Studies* 60 (3): 497–529.

</div>

<div id="ref-kalouptsidi2020partial" class="csl-entry" markdown="1">

Kalouptsidi, Myrto, Yuichi Kitamura, Lucas Lima, and Eduardo A
Souza-Rodrigues. 2020. “Partial Identification and Inference for Dynamic
Models and Counterfactuals.” National Bureau of Economic Research.

</div>

<div id="ref-kalouptsidi2017non" class="csl-entry" markdown="1">

Kalouptsidi, Myrto, Paul T Scott, and Eduardo Souza-Rodrigues. 2017. “On
the Non-Identification of Counterfactuals in Dynamic Discrete Games.”
*International Journal of Industrial Organization* 50: 362–71.

</div>

<div id="ref-keane1997career" class="csl-entry" markdown="1">

Keane, Michael P, and Kenneth I Wolpin. 1997. “The Career Decisions of
Young Men.” *Journal of Political Economy* 105 (3): 473–522.

</div>

<div id="ref-magnac2002identifying" class="csl-entry" markdown="1">

Magnac, Thierry, and David Thesmar. 2002. “Identifying Dynamic Discrete
Decision Processes.” *Econometrica* 70 (2): 801–16.

</div>

<div id="ref-rust1987optimal" class="csl-entry" markdown="1">

Rust, John. 1987. “Optimal Replacement of GMC Bus Engines: An Empirical
Model of Harold Zurcher.” *Econometrica: Journal of the Econometric
Society*, 999–1033.

</div>

<div id="ref-rust1988maximum" class="csl-entry" markdown="1">

———. 1988. “Maximum Likelihood Estimation of Discrete Control
Processes.” *SIAM Journal on Control and Optimization* 26 (5): 1006–24.

</div>

</div>
