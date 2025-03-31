import conan
import os


class ConanFile(conan.ConanFile):
    name = 'benchmarkingprobe'
    user = 'xtuml'
    python_requires = 'xtuml_masl_conan/[>=5.0 <6]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'
