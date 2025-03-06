import conan
import os


class ConanFile(conan.ConanFile):
    name = 'istore'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'xtuml_masl_conan/[>=1.0 <2]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires('masl_command_line/[>=1.0 <2]@xtuml')
        self.requires('masl_filesystem/[>=1.0 <2]@xtuml')
        self.requires('masl_logger/[>=1.0 <2]@xtuml')
        self.requires('masl_strings/[>=1.0 <2]@xtuml')
        super().requirements()
