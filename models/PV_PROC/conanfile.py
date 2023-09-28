import conan


class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    version = '1.1.0'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=4.1.1]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def requirements(self):
        self.requires('masl_core/[>=4.1.1]@xtuml/stable')
        self.requires('masl_utils/[>=4.1.1]@xtuml/stable')
        self.requires('aeordering/[>=1.1.0]@xtuml/stable')
        self.requires('aereception/[>=1.1.0]@xtuml/stable')
        self.requires('freception/[>=1.1.0]@xtuml/stable')
        self.requires('istore/[>=1.1.0]@xtuml/stable')
        self.requires('aesequencedc/[>=1.1.0]@xtuml/stable')
        self.requires('verificationgateway/[>=1.1.0]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=4.1.1]@xtuml/stable')
