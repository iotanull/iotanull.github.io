---
title: "Sample Specialized Article"
date: 2026-09-08T10:00:00+03:30
description: "A demonstration research note showing technical typography, equations, references, and citation tools."
articleType: "specialized"
topics: ["Mathematics", "Geometry"]
draft: false
math: true
toc: true
abstract: "This is placeholder content created solely to demonstrate the specialized article template. It makes no claim to be original research."
citation: "IO. ‘Sample Specialized Article.’ IO, 2026."
bibtex: |
  @article{io2026sample,
    title={Sample Specialized Article},
    author={IO},
    year={2026},
    note={Demonstration content}
  }
---

> **Demonstration content.** Replace this page bundle with an actual research note before treating it as published scholarship.

## 1. A geometric question

Technical writing needs a calm surface. Let $M$ be a compact, connected manifold and let $g$ be a Riemannian metric. The display below tests responsive mathematical typesetting:

$$
\operatorname{Ric}(g) - \frac{1}{2}R(g)g + \Lambda g = 8\pi T.
$$

The notation is illustrative rather than part of a new result. Inline expressions such as $\pi_1(M)$ should sit naturally within a sentence, while longer displays should remain scrollable on narrow screens.

## 2. A small proposition

**Proposition.** If $f\colon M\to\mathbb{R}$ is smooth and $M$ is compact, then $f$ attains a maximum and a minimum.

**Sketch.** Compactness makes $f(M)$ compact; compact subsets of $\mathbb{R}$ are closed and bounded. The endpoint values therefore belong to the image.[^1]

| Object | Role | Example |
|---|---|---|
| $M$ | space | compact manifold |
| $g$ | structure | Riemannian metric |
| $f$ | observable | smooth function |

[^1]: This footnote exists to demonstrate footnote styling and back-links.

## 3. Computation

```python
def euler_characteristic(vertices, edges, faces):
    """A tiny demonstration, not a research implementation."""
    return vertices - edges + faces
```

## References

1. J. M. Lee, *Introduction to Smooth Manifolds*. Springer, 2013.
2. Placeholder reference included for layout testing only.

{{< citation >}}
