import sys
from antlr4 import *
from plus_job_defn import *
from plus2jsonLexer import plus2jsonLexer
from plus2jsonParser import plus2jsonParser
from plus2jsonListener import plus2jsonListener
from plus2json_run import plus2json_run

def main(argv):

    if ( "--help" in argv or "-h" in argv or len(argv) < 2 ):
        print("""
Usage
=====
  python3 plus2json.pyz <PLUS PlantUML file> [options]

  With no options, plus2json will check the syntax of the input PlantUML file.

Options
=======
--help, -h               show this help message and exit
--job, -j                output PLUS Job Definition (JSON)      default: off
--audit_event_data, -d   output PLUS audit event data           default: off
--play                   interpret the job and produce events   default: off
--print, -p              print human readable output            default: off

Examples:

python plus2json.pyz Tutorial_1.puml --job                # convert Tutorial_1.puml into JSON
python plus2json.pyz Tutorial_13.puml -d                  # produce audit event data definition as JSON
python plus2json.pyz myjobdefn.puml --play                # interpret the job producing event instances
python -m plus2json Tutorial_1.puml --job -p              # show job in human readable view
python plus2json.pyz j.puml --job | python -m json.tool   # format output JSON

        """)
        exit()

    input_stream = FileStream(argv[1])
    lexer = plus2jsonLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = plus2jsonParser(stream)
    tree = parser.plusdefn()
    if ( "--print" in argv or "-p" in argv or "--job" in argv or "-j" in argv or
         "--audit_event_data" in argv or "-d" in argv or "--play" in argv ):
        run = plus2json_run() # custom listener
        walker = ParseTreeWalker()
        walker.walk(run, tree)
    if "--job" in sys.argv or "-j" in sys.argv:
        if "--print" in sys.argv or "-p" in sys.argv:
            JobDefn.population[-1].pretty_print()
        else:
            JobDefn.population[-1].output_json()
    elif "--audit_event_data" in sys.argv or "-d" in sys.argv:
        Invariant.output_json()
    elif "--play" in sys.argv:
        if "--print" in sys.argv or "-p" in sys.argv:
            JobDefn.population[-1].play(True)
        else:
            JobDefn.population[-1].play(False)

 
if __name__ == '__main__':
    main(sys.argv)

