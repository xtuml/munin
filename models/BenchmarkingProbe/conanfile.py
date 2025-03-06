import conan
import os


class ConanFile(conan.ConanFile):
    name = 'benchmarkingprobe'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'xtuml_masl_conan/[>=1.0 <2]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'
