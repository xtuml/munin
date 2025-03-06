import conan
import os


class ConanFile(conan.ConanFile):
    name = 'verificationgateway'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'xtuml_masl_conan/[>=5.0 <6]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    def requirements(self):
        self.requires('masl_json/[>=1.0 <2]@xtuml')
        self.requires('masl_logger/[>=1.0 <2]@xtuml')
        self.requires('masl_uuid/[>=1.0 <2]@xtuml')
        super().requirements()

    def omit_requirements(self):
        return ['nlohmann_json']
