import conan
from conan.tools.layout import basic_layout

class ConanFile(conan.ConanFile):

    name = 'pv_proc_image'
    user = 'xtuml'

    python_requires = 'xtuml_deployer/[>=1.0 <2]@xtuml'

    def requirements(self):
        self.requires(f'pv_proc/{self.version}@xtuml')
        self.requires('xtuml_activemq/[>=1.0 <2]@xtuml')

    def deploy(self):
        deployer = self.python_requires['xtuml_deployer'].module.Deployer(self, 'apps/pv_proc')
        deployer.executable('PV_PROC_transient')

        deployer.library('ActiveMQ')
        deployer.library('sasl2/libplain.so', wrap=False)

        # TODO roll these up in a single PV_PROC_idm library
        deployer.library('AEOrdering_idm')
        deployer.library('IStore_idm')
        deployer.library('JobManagement_idm')
        deployer.library('AESequenceDC_idm')
        deployer.library('VerificationGateway_idm')
        deployer.library('CommandLine_idm')
        deployer.library('Environment_idm')
        deployer.library('FReception_idm')
        deployer.library('Filesystem_idm')
        deployer.library('Format_idm')
        deployer.library('Hash_idm')
        deployer.library('Host_idm')
        deployer.library('JSONValidation_idm')
        deployer.library('JSON_idm')
        deployer.library('Logger_idm')
        deployer.library('Math_idm')
        deployer.library('Regex_idm')
        deployer.library('Strings_idm')
        deployer.library('UUID_idm')

        deployer.resource('config/*', packages=['masl_json_validation'], dest='config')
        deployer.resource('schema/*', packages=['aeordering', 'jobmanagement', 'freception'], dest='schema')
        deployer.deploy()
