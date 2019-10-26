## Description

Simulation of large amount of balls. [preview](https://www.shadertoy.com/view/wdG3Wd)

## Controls:
Click on top right corner to reset
Click and hold mouse on left side for temporary zoom
Click anywhere else for interacting with balls

Let me know if you find a parameters that produce smaller, longer lasting grain.


## Implementation details

Movement for each ball is based on basic physics equations.

```
Pos = V * t
V' = V + at
a = F / m
F = F_g + F_e = G * m + sum(k_e * overlap)
```

### Fast collision check

I got the vague idea from approach used for fast voronoi diagram - keeping nodes in a grid and checking only nearest neighbors from the grid.

Having a ball size  sqrt(2)/2 < R means that each cell in a grid can't contain more than one ball.
Having ball size R < 1 means that only closest 5x5 cells need to be checked for collisions.

It works as long as there are no large forces pushing two balls too close together it works. It took some time to tune the parameters so that balls move sufficiently dynamically without exploding from fast collision or the pressure at bottom. If you increase G you can observe that bottom balls start popping.  

It also took a few tries to get the transition between cells right without duplicates and disappearing.