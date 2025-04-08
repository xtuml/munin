import conan

class ConanFile(conan.ConanFile):

    name = 'aeo_svdc_proc_image'
    user = 'xtuml'

    python_requires = 'xtuml_deployer/[>=1.0 <2]@xtuml'

    def requirements(self):
        self.requires(f'pv_proc/{self.version}@xtuml')
        self.requires('xtuml_activemq/[>=1.0 <2]@xtuml')

    def deploy(self):
        deployer = self.python_requires['xtuml_deployer'].module.Deployer(self, 'apps/aeo_svdc_proc')
        deployer.executable('AEO_SVDC_PROC_transient')
        deployer.library('AEO_SVDC_PROC_idm')
        deployer.library('ActiveMQ')
        deployer.library('sasl2/libplain.so', wrap=False)
        deployer.resource('config/*', packages=['masl_json_validation'], dest='config')
        deployer.resource('schema/*', packages=['aeordering'], dest='schema')
        deployer.deploy()
