# RoadsConstructionOpt
Agent-based Simulator for optimization of road network construction works


**Documentation**

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://OpalskiM.github.io/RoadsConstructionOpt.jl/latest)

**Build status**

[![Build Status](https://travis-ci.org/OpalskiM/RSUOptimization.svg?branch=master)](https://travis-ci.org/OpalskiM/RoadsConstructionOpt)
[![codecov](https://img.shields.io/codecov/c/gh/OpalskiM/RoadsConstructionOpt.svg)](https://codecov.io/gh/OpalskiM/RoadsConstructionOpt)

## Package installation

### Prerequisites

Plotting road system requires `Conda`'s folium and matplotlib to be present in Julia:

```julia
using Conda
Conda.runconda(`install folium -c conda-forge --yes`)
Conda.runconda(`install matplotlib --yes`)
```
