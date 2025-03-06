import conan
import os

class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'xtuml_masl_conan/[>=1.0 <2]@xtuml'
    python_requires_extend = 'xtuml_masl_conan.MaslConanHelper'

    exports_sources = 'src/*', 'masl/*', 'schedule/*', 'config/*', 'schema/*'

    def requirements(self):
        self.requires(f'aeordering/{self.version}@xtuml/stable')
        self.requires(f'freception/{self.version}@xtuml/stable')
        self.requires(f'istore/{self.version}@xtuml/stable')
        self.requires(f'aesequencedc/{self.version}@xtuml/stable')
        self.requires(f'verificationgateway/{self.version}@xtuml/stable')
        self.requires(f'jobmanagement/{self.version}@xtuml/stable')
        self.requires('masl_json/[>=1.0 <2]@xtuml')
        self.requires('masl_logger/[>=1.0 <2]@xtuml')
        self.requires('masl_uuid/[>=1.0 <2]@xtuml')
