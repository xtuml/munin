import sys
from antlr4 import *
from PlusActJobDefn import *
from PlusActLexer import PlusActLexer
from PlusActParser import PlusActParser
from PlusActListener import PlusActListener

def main(argv):

    if ( "--help" in argv or "-h" in argv or len(argv) < 2 ):
        print("""
Usage
=====
  python3 plusact.pyz <PlusAct PlantUML file> [options]

  With no options, plusact will check the syntax of the input PlantUML file.

Options
=======
--help, -h                 show this help message and exit
--json, -j                 output PLUS Job Definition (JSON)    default: off
--print, -p                print human readable output          default: off
        """)
        exit()

    input_stream = FileStream(argv[1])
    lexer = PlusActLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = PlusActParser(stream)
    tree = parser.plusdefn()
    if ( "--print" in argv or "-p" in argv or "--json" in argv or "-j" in argv ):
        run = PlusActRun() # custom listener
        walker = ParseTreeWalker()
        walker.walk(run, tree)
 
if __name__ == '__main__':
    main(sys.argv)

