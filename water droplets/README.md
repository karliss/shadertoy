Simulation of rain on window.

[Preview](https://www.shadertoy.com/view/tddSD7)

## Usage
Click to add more water.

## Implementation
State:
* Buff D - amount of water in cell
* Buff B - amount of water moving between cells

State changes:
* spreading - water moves to cells with less water
* attraction - water attracts to water
* gravity