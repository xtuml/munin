import conan
import os


class ConanFile(conan.ConanFile):
    name = 'istore'
    user = 'xtuml'
    python_requires = 'xtuml_masl_conan/[>=5.0 <6]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    def requirements(self):
        self.requires('masl_command_line/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_filesystem/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_logger/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_strings/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        super().requirements()
