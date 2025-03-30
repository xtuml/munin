import conan

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
        deployer.library('PV_PROC_idm')
        deployer.library('ActiveMQ')
        deployer.library('sasl2/libplain.so', wrap=False)
        deployer.resource('config/*', packages=['masl_json_validation'], dest='config')
        deployer.resource('schema/*', packages=['aeordering', 'jobmanagement', 'freception'], dest='schema')
        deployer.deploy()
