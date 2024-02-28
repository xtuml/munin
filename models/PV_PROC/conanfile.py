import conan
import os

class ConanFile(conan.ConanFile):
    name = 'pv_proc'
    user = 'xtuml'
    channel = 'stable'
    python_requires = f'masl_conan/{os.environ["MASL_VERSION"]}@xtuml/stable'
    python_requires_extend = 'masl_conan.MaslConanHelper'

    def requirements(self):
        self.requires(f'masl_core/{os.environ["MASL_VERSION"]}@xtuml/stable')
        self.requires(f'masl_utils/{os.environ["MASL_VERSION"]}@xtuml/stable')
        self.requires(f'asynclogger/{self.version}@xtuml/stable')
        self.requires(f'benchmarkingprobe/{self.version}@xtuml/stable')
        self.requires(f'aeordering/{self.version}@xtuml/stable')
        self.requires(f'freception/{self.version}@xtuml/stable')
        self.requires(f'istore/{self.version}@xtuml/stable')
        self.requires(f'aesequencedc/{self.version}@xtuml/stable')
        self.requires(f'verificationgateway/{self.version}@xtuml/stable')
        self.requires(f'jobmanagement/{self.version}@xtuml/stable')

    def build_requirements(self):
        self.tool_requires(f'masl_codegen/{os.environ["MASL_VERSION"]}@xtuml/stable')
