# plus2json

### Install

```
pip install plus2json
```

### Usage

```
Usage
=====
  python plus2json.pyz <PLUS PlantUML file> [options]

  With no options, plus2json will check the syntax of the input PlantUML file.

Options
=======
--help, -h                 show this help message and exit
--json, -j                 output PLUS Job Definition (JSON)    default: off
--print, -p                print human readable output          default: off
```

Example:

```
python plus2json.pyz examples/Tutorial_1.puml -json        # convert Tutorial_1.puml into JSON
python -m plus2json examples/Tutorial_1.puml -p           # show job in human readable view
```

### Interesting Files

src/plus2json.g4 - anltr4 grammar for PLUS
src/plus_job_defn.py - primary source for the tree walker listener JSON generator
src/__main__.py

### Package for release

```
from src folder:  antlr4 -Dlanguage=Python3 plus2json.g4
python -m pip install -r requirements.txt --target src
python -m zipapp src -p "/usr/bin/env python3" -o plus2json.pyz -c
after learning how to publish:
python setup.py sdist
twine upload dist/*
```
