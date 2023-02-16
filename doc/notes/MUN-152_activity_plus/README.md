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
--help, -h               show this help message and exit
--job, -j                output PLUS Job Definition (JSON)      default: off
--audit_event_data, -d   output PLUS audit event data           default: off
--play                   interpret the job and produce events   default: off
--print, -p              print human readable output            default: off
```

Example:

```
python plus2json.pyz Tutorial_1.puml --job                # convert Tutorial_1.puml into JSON
python plus2json.pyz Tutorial_13.puml -d                  # produce audit event data definition as JSON
python plus2json.pyz myjobdefn.puml --play                # interpret the job producing event instances
python -m plus2json Tutorial_1.puml --job -p              # show job in human readable view
python plus2json.pyz j.puml --job | python -m json.tool   # format output JSON
```

### Interesting Files

src/plus2json.g4 - anltr4 grammar for PLUS
src/plus2son_run.py - source for the tree walker listener JSON generator
src/plus_job_defn.py - data model for the job definition with output routines
src/__main__.py
bin/plus2json.pyz - Python 3 executable with dependencies included

### Package for release

```
from src folder:  antlr4 -Dlanguage=Python3 plus2json.g4
python -m pip install -r requirements.txt --target src
python -m zipapp src -p "/usr/bin/env python3" -o plus2json.pyz -c
after learning how to publish:
python setup.py sdist
twine upload dist/*
```
