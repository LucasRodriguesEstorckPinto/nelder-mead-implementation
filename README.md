# Nelder-Mead Optimization Method

This project implements the **Nelder-Mead method**, a derivative-free optimization technique proposed by **John Nelder** and **Roger Mead** in 1965. The method uses the concept of a **simplex** to iteratively approach local minima (or maxima, though this implementation focuses on minimization).

The algorithm was implemented in **Python**, a language widely used in academia due to its rich ecosystem of libraries like `SymPy`, `NumPy`, and `Matplotlib`, which greatly facilitate numerical and graphical computations.

---

## 📌 Overview

The Nelder-Mead method searches for a local minimum of a function \( f: \mathbb{R}^n \rightarrow \mathbb{R} \) by evaluating it at the vertices of a geometric figure called a **simplex**:

- In 1D, a simplex is a line segment (2 points).
- In 2D, it's a triangle (3 points).
- In 3D, it's a tetrahedron (4 points), and so on.

The method updates the simplex through geometric operations such as reflection, expansion, contraction, and reduction, aiming to move toward regions with lower function values.

---

## 🧠 How the Nelder-Mead Algorithm Works

### Step 1: Initialization

Start with \( n+1 \) points forming a simplex in \( \mathbb{R}^n \). Evaluate the function \( f \) at each vertex:

- Let \( x_1, x_2, \ldots, x_{n+1} \) be the simplex points.
- Sort them such that:

  $$
  f(x_1) \leq f(x_2) \leq \cdots \leq f(x_{n+1})
  $$

Here, \( x_1 \) is the **best** point and \( x_{n+1} \) is the **worst**.

---

### Step 2: Compute the Centroid

Calculate the **centroid** \( x_c \) of all points except the worst:

$$
x_c = \frac{1}{n} \sum_{i=1}^{n} x_i
$$

---

### Step 3: Reflection

Reflect the worst point \( x_{n+1} \) across the centroid:

$$
x_r = x_c + \alpha(x_c - x_{n+1})
$$

Typical value: \( \alpha = 1 \)

Evaluate \( f(x_r) \):

- If \( f(x_1) \leq f(x_r) < f(x_n) \): Accept the **reflection** and replace \( x_{n+1} \) with \( x_r \).

---

### Step 4: Expansion

If \( f(x_r) < f(x_1) \), try going further in the same direction:

$$
x_e = x_c + \gamma(x_r - x_c)
$$

Typical value: \( \gamma = 2 \)

- If \( f(x_e) < f(x_r) \): Accept **expansion**, replace \( x_{n+1} \) with \( x_e \).
- Else: Accept **reflection**, replace with \( x_r \).

---

### Step 5: Contraction

If \( f(x_r) \geq f(x_n) \), try **contraction**:

- **Outside contraction** (if \( f(x_n) \leq f(x_r) < f(x_{n+1}) \)):

  $$
  x_{oc} = x_c + \beta(x_r - x_c)
  $$

- **Inside contraction** (if \( f(x_r) \geq f(x_{n+1}) \)):

  $$
  x_{ic} = x_c - \beta(x_c - x_{n+1})
  $$

Typical value: \( \beta = 0.5 \)

If contraction is successful (i.e., \( f \) improves), accept the new point. Otherwise, go to reduction.

---

### Step 6: Reduction

Shrink the simplex toward the best point \( x_1 \):

$$
x_i' = x_1 + \delta(x_i - x_1), \quad \text{for } i = 2, \ldots, n+1
$$

Typical value: \( \delta = 0.5 \)

---

### Step 7: Termination

Repeat the above steps until a stopping criterion is met:

- **Maximum number of iterations**
- **Function value tolerance** or **simplex size tolerance**

---

## 📈 Visualization

A visualization of a single iteration in 2D (triangle simplex) can help illustrate:

- The movement of the worst point
- How the simplex adapts to the function landscape

![Nelder-Mead Iteration](https://upload.wikimedia.org/wikipedia/commons/e/e8/Nelder-Mead_Algorithm.png)  
*Representation of a Nelder-Mead iteration. Source: Wikipedia*

---

## 🔧 Parameters Summary

| Parameter     | Description                  | Typical Value |
|---------------|------------------------------|----------------|
| \( \alpha \)  | Reflection coefficient        | 1              |
| \( \gamma \)  | Expansion coefficient         | 2              |
| \( \beta \)   | Contraction coefficient       | 0.5            |
| \( \delta \)  | Reduction coefficient         | 0.5            |

---

## 💡 Final Thoughts

The Nelder-Mead algorithm is particularly useful when:

- The function is **non-differentiable** or **noisy**
- The gradient is **unavailable**
- A quick and intuitive local optimization method is needed

While it does not guarantee a global minimum and may fail for high-dimensional or non-convex problems, it remains a powerful tool in many practical engineering and scientific applications.

---

## 📎 References

- Nelder, J. A., & Mead, R. (1965). A Simplex Method for Function Minimization. *The Computer Journal*, 7(4), 308–313.
- Wikipedia contributors. *Nelder–Mead method*. [https://en.wikipedia.org/wiki/Nelder–Mead_method](https://en.wikipedia.org/wiki/Nelder–Mead_method)

