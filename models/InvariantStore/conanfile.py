import conan


class ConanFile(conan.ConanFile):
    name = 'istore'
    version = '0.1'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=0.1]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def requirements(self):
        self.requires('masl_core/[>=0.1]@xtuml/stable')
        self.requires('masl_utils/[>=0.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=0.1]@xtuml/stable')