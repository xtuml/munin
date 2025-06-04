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

        # required for dev run, but not for build.
        # Should be visible=False, but seems to be a conan bug which makes its 
        # dependencies invisible even though they are used by other libs.
        self.requires('xtuml_activemq/[>=1.0 <2]@xtuml')

    def omit_requirements(self):
        return ['boost', 'nlohmann_json', 'xtuml_asn1', 'xtuml_sql', 'xtuml_sqlite', 'xtuml_transient']

    def package_info(self):
        super().package_info()
        # stop it complaining about unused library
        self.cpp_info.components["dummy"].requires.append("xtuml_activemq::xtuml_activemq")
