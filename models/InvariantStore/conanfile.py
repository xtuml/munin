import conan


class ConanFile(conan.ConanFile):
    name = 'istore'
    version = '1.1.1'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=4.2.2]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def requirements(self):
        self.requires('masl_core/[>=4.2.2]@xtuml/stable')
        self.requires('masl_utils/[>=4.2.2]@xtuml/stable')
        self.requires('asynclogger/[>=1.1.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=4.2.2]@xtuml/stable')
