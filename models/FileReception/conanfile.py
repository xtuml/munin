import conan
import os

from conan.tools.files import copy


class ConanFile(conan.ConanFile):
    name = 'freception'
    user = 'xtuml'
    channel = 'stable'
    python_requires = f'masl_conan/{os.environ["MASL_VERSION"]}@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires(f'masl_core/{os.environ["MASL_VERSION"]}@xtuml/stable')
        self.requires(f'masl_utils/{os.environ["MASL_VERSION"]}@xtuml/stable')
        self.requires(f'asynclogger/{self.version}@xtuml/stable')

    def build_requirements(self):
        self.tool_requires(f'masl_codegen/{os.environ["MASL_VERSION"]}@xtuml/stable')

    def package(self):
        super().package()
        res_dir = os.path.join(self.package_folder, 'res')
        copy(self, 'schema/*', src=self.source_folder, dst=res_dir)

    def package_info(self):
        super().package_info()
        self.runenv_info.define_path('FILE_RECEPTION_CONFIG_SCHEMA_PATH', os.path.join(self.package_folder, 'res', 'schema', 'file_reception_config_schema.json'))
