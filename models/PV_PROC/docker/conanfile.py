import conan
from conan.tools.layout import basic_layout

class ConanFile(conan.ConanFile):

    name = 'pv_proc_image'
    version = '1.4.0-45-gb663cb82'
    user = 'xtuml'

    python_requires = 'xtuml_deployer/[>=1.0 <2]@xtuml'

    def layout(self):
        basic_layout(self)

    def requirements(self):
        self.requires(f'pv_proc/{self.version}@xtuml')

    def deploy(self):
        deployer = self.python_requires['xtuml_deployer'].module.Deployer(self, 'apps/pv_proc')
        deployer.executable('PV_PROC_transient')
        deployer.library('MetaData')
        deployer.library('PV_PROC_metadata')
        deployer.resource('config/*', packages=['masl_json_validation'], dest='config')
        deployer.resource('schema/*', packages=['aeordering', 'freception', 'jobmanagement'], dest='schema')
        deployer.deploy()
