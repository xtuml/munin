import conan
import os

class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    version = '1.2.0'
    user = 'xtuml'
    channel = 'stable'
    python_requires = f'masl_conan/[>={os.environ["MASL_VERSION"]}]@xtuml/stable'
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
        self.requires(f'masl_core/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
        self.requires(f'masl_utils/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
        self.requires('asynclogger/[>=1.1.1]@xtuml/stable')
        self.requires('aeordering/[>=1.1.1]@xtuml/stable')
        self.requires('aereception/[>=1.1.1]@xtuml/stable')
        self.requires('freception/[>=1.1.1]@xtuml/stable')
        self.requires('istore/[>=1.1.1]@xtuml/stable')
        self.requires('aesequencedc/[>=1.1.1]@xtuml/stable')
        self.requires('verificationgateway/[>=1.1.1]@xtuml/stable')

    def build_requirements(self):
        self.tool_requires(f'masl_codegen/[>={os.environ["MASL_VERSION"]}]@xtuml/stable')
