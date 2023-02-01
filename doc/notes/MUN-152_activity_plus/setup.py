#!/usr/bin/env python

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md')) as f:
    long_description = f.read()

setup(name='plusact',
      version='0.0.1',
      description='PLUS Activity PlantUML Parser/Processor',
      long_description=long_description,
      long_description_content_type='text/markdown',
      author='Cortland Starrett',
      author_email='cort@roxsoftware.com',
      url='https://github.com/munin/doc/notes/MUN-152_activity_plus',
      license='Apache 2.0',
      download_url='https://github.com/xtuml/mc/releases/download/1.0.4/pymc3020-1.0.4.tar.gz',
      keywords='xtuml bridgepoint protocol verifier',
      packages=['src'],
      install_requires=['antlr4-python3-runtime'],
      include_package_data=True,
      zip_safe=True)
