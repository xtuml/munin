import conan
import os


class ConanFile(conan.ConanFile):
    name = 'verificationgateway'
    version = '1.2.0'
    user = 'xtuml'
    channel = 'stable'
    python_requires = f'masl_conan/[>={os.environ["MASL_VERSION"]}]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def requirements(self):
        self.requires(f'masl_core/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
        self.requires(f'masl_utils/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
        self.requires('asynclogger/[>=1.1.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires(f'masl_codegen/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
