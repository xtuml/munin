# plusact

### Install

```
pip install plusact
```

### Usage

```
Usage
=====
  python plusact.pyz <PlusAct PlantUML file> [options]

  With no options, plusact will check the syntax of the input PlantUML file.

Options
=======
--help, -h                 show this help message and exit
--json, -j                 output PLUS Job Definition (JSON)    default: off
--print, -p                print human readable output          default: off
```

Example:

```
python -m plusact examples/Tutorial_1.puml -json                   # convert Tutorial_1.puml into JSON
python -m plusact examples/Tutorial_1.puml -p                      # show job in human readable view
```

### Interesting Files

src/__main__.py
src/PlusActJobDefn.py - primary source for the tree walker JSON generator
src/PlusAct.g4 - anltr4 grammar for PLUS

### Package for release

```
from src folder:  antlr4 -Dlanguage=Python3 PlusAct.g4
python -m pip install -r requirements.txt --target src
python -m zipapp src -p "/usr/bin/env python3" -o plusact.pyz -c
after learning how to publish:
python setup.py sdist
twine upload dist/*
```
