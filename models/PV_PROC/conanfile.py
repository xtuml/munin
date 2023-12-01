import conan


class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    version = '1.1.1'
    user = 'xtuml'
    channel = 'stable'
    python_requires = 'masl_conan/[>=4.2.2]@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'
    persistent_procs = ['ISTORE_PROC.prj']

    def masl_extras(self):
        return ['-skiptranslator', 'Sqlite']

    def masl_src(self):
        return filter(lambda s: any(map(lambda p: not s.endswith(p), self.persistent_procs)), super().masl_src())

    def persistent_masl_src(self):
        return filter(lambda s: any(map(lambda p: s.endswith(p), self.persistent_procs)), super().masl_src())

    def build(self):
        # build all non-persistent procs
        super().build()

        # build all persistent procs
        self.masl_extras = lambda: []
        self.masl_src = self.persistent_masl_src
        super().build()

    def requirements(self):
        self.requires('masl_core/[>=4.2.2]@xtuml/stable')
        self.requires('masl_utils/[>=4.2.2]@xtuml/stable')
        self.requires('asynclogger/[>=1.1.1]@xtuml/stable')
        self.requires('aeordering/[>=1.1.1]@xtuml/stable')
        self.requires('aereception/[>=1.1.1]@xtuml/stable')
        self.requires('freception/[>=1.1.1]@xtuml/stable')
        self.requires('istore/[>=1.1.1]@xtuml/stable')
        self.requires('aesequencedc/[>=1.1.1]@xtuml/stable')
        self.requires('verificationgateway/[>=1.1.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires('masl_codegen/[>=4.2.2]@xtuml/stable')
