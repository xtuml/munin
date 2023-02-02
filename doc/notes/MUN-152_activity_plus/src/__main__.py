import sys
from antlr4 import *
from PlusJobDefn import *
from plus2jsonLexer import plus2jsonLexer
from plus2jsonParser import plus2jsonParser
from plus2jsonListener import plus2jsonListener

def main(argv):

    if ( "--help" in argv or "-h" in argv or len(argv) < 2 ):
        print("""
Usage
=====
  python3 plus2json.pyz <PLUS PlantUML file> [options]

  With no options, plusact will check the syntax of the input PlantUML file.

Options
=======
--help, -h                 show this help message and exit
--json, -j                 output PLUS Job Definition (JSON)    default: off
--print, -p                print human readable output          default: off
        """)
        exit()

    input_stream = FileStream(argv[1])
    lexer = plus2jsonLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = plus2jsonParser(stream)
    tree = parser.plusdefn()
    if ( "--print" in argv or "-p" in argv or "--json" in argv or "-j" in argv ):
        run = plus2jsonRun() # custom listener
        walker = ParseTreeWalker()
        walker.walk(run, tree)
 
if __name__ == '__main__':
    main(sys.argv)

