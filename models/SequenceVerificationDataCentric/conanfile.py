import conan
import os


class ConanFile(conan.ConanFile):
    name = 'aesequencedc'
    user = 'xtuml'
    channel = 'stable'
    python_requires = f'masl_conan/{os.environ["MASL_VERSION"]}@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires(f'masl_core/{os.environ["MASL_VERSION"]}@xtuml/stable')
        self.requires(f'masl_utils/{os.environ["MASL_VERSION"]}@xtuml/stable')

    def build_requirements(self):
        self.tool_requires(f'masl_codegen/{os.environ["MASL_VERSION"]}@xtuml/stable')
