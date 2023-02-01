# plusact

### Install

```
pip install plusact
```

### Usage

```
Usage
=====
  python -m plusact [options] <PlusAct PlantUML file>

Options
=======
--help, -h                                        show this help message and exit
--print, -p                                       print human readable output          default: off
```

Example:

```
python -m plusact examples/Tutorial_1.puml                         # convert Tutorial_1.puml into JSON
python -m plusact -p examples/Tutorial_1.puml                      # convert Tutorial_1.puml into JSON
```

### Package for release

```
python setup.py sdist
twine upload dist/*
```
