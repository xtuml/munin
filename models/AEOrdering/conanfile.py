import conan
import os

from conan.tools.files import copy


class ConanFile(conan.ConanFile):
    name = 'aeordering'
    version = '1.1.1'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=4.2.2]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def requirements(self):
        self.requires('masl_core/[>=4.2.2]@xtuml/stable')
        self.requires('masl_utils/[>=4.2.2]@xtuml/stable')
        self.requires('asynclogger/[>=1.1.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=4.2.2]@xtuml/stable')

    def package(self):
        super().package()
        res_dir = os.path.join(self.package_folder, 'res')
        copy(self, 'schema/*', src=self.source_folder, dst=res_dir)

    def package_info(self):
        super().package_info()
        self.runenv_info.define_path('JOB_DEFINITION_SCHEMA_PATH', os.path.join(self.package_folder, 'res', 'schema', 'job_definition_schema.json'))
        self.runenv_info.define_path('ORDERING_CONFIG_SCHEMA_PATH', os.path.join(self.package_folder, 'res', 'schema', 'ordering_config_schema.json'))
