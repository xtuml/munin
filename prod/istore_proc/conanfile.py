import conan

class ConanFile(conan.ConanFile):

    name = 'istore_proc_image'
    user = 'xtuml'

    python_requires = 'xtuml_deployer/[>=1.0 <2]@xtuml'

    def requirements(self):
        self.requires(f'pv_proc/{self.version}@xtuml')
        self.requires('xtuml_activemq/[>=1.0 <2]@xtuml')

    def deploy(self):
        deployer = self.python_requires['xtuml_deployer'].module.Deployer(self, 'apps/istore_proc')
        deployer.executable('ISTORE_PROC_sqlite')
        deployer.library('ISTORE_PROC_idm')
        deployer.library('ActiveMQ')
        deployer.library('sasl2/libplain.so', wrap=False)
        deployer.deploy()
