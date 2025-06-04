import conan
import os

from conan.tools.files import copy


class ConanFile(conan.ConanFile):
    name = 'jobmanagement'
    user = 'xtuml'
    python_requires = 'xtuml_masl_conan/[>=5.0 <6]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires('masl_command_line/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_environment/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_filesystem/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_json/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_json_validation/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_logger/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        self.requires('masl_uuid/[>=1.0 <2]@xtuml', transitive_libs=True, transitive_headers=True)
        super().requirements()

    def package(self):
        super().package()
        res_dir = os.path.join(self.package_folder, 'res')
        copy(self, 'schema/*', src=self.source_folder, dst=res_dir)

    def package_info(self):
        super().package_info()
        self.runenv_info.define_path('JM_CONFIG_SCHEMA_PATH', os.path.join(self.package_folder, 'res', 'schema', 'jm_config_schema.json'))
