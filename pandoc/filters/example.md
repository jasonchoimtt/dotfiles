---
title: Pandoc filters test file
author: Jason Choi
geometry: a5paper,margin=1.27cm,bottom=1.92cm,footskip=0.65cm
---

Hello, World!

![#include](example.py){.python listing="yes"}

<!--
```{.python exec="plot,echo,inline" listing="yes" caption="Hello"}
x = np.arange(0, 4*np.pi, 0.1)
plt.plot(x, np.sin(x), 'r')
1 + 1
```

```{.python exec="output"}
22*2
```
-->

$$& f(x) &= x+1 \\
    f'(x) + 0.0000 &= 1. $$

$θ$

```{.graphviz exec="plot"}
digraph G {Hello->World}
```
