import conan
import os

from conan.tools.files import copy


class ConanFile(conan.ConanFile):
    name = 'freception'
    version = '0.1'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=0.1]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires('masl_core/[>=0.1]@xtuml/stable')
        self.requires('masl_utils/[>=0.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=0.1]@xtuml/stable')

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def package(self):
        super().package()
        res_dir = os.path.join(self.package_folder, 'res')
        copy(self, 'schema/*', src=self.source_folder, dst=res_dir)

    def package_info(self):
        super().package_info()
        self.runenv_info.define_path('FILE_RECEPTION_CONFIG_SCHEMA_PATH', os.path.join(self.package_folder, 'res', 'schema', 'file_reception_config_schema.json'))
