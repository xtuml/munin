import conan
import os

class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    user = 'xtuml'
    python_requires = 'xtuml_masl_conan/[>=5.0 <6]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    def requirements(self):
        super().requirements()
        self.requires(f'aeordering/{self.version}@xtuml')
        self.requires(f'freception/{self.version}@xtuml')
        self.requires(f'istore/{self.version}@xtuml')
        self.requires(f'aesequencedc/{self.version}@xtuml')
        self.requires(f'verificationgateway/{self.version}@xtuml')
        self.requires(f'jobmanagement/{self.version}@xtuml')
        self.requires('masl_json/[>=1.0 <2]@xtuml')
        self.requires('masl_logger/[>=1.0 <2]@xtuml')
        self.requires('masl_uuid/[>=1.0 <2]@xtuml')

        # required for dev run, but not for build
        self.requires('xtuml_activemq/[>=1.0 <2]@xtuml', visible=False)

    def omit_requirements(self):
        return ['boost', 'nlohmann_json', 'xtuml_asn1', 'xtuml_sql', 'xtuml_sqlite', 'xtuml_transient', 'xtuml_idm']
