grammar plus2json;

plusdefn       : NEWLINE* umlblock+
               ;

umlblock       : STARTUML ( '(' 'id' '=' identifier ')' )? NEWLINE
                 ( job_defn      // primary use case defining full job
                 | sequence_defn // sequence to be referenced from elsewhere
                 | statement+    // simple grouping of statements to be !included
                 )
                 ENDUML NEWLINE?
               ;

job_defn       : PARTITION job_name '{' NEWLINE sequence_defn* '}' NEWLINE
               ;

job_name       : identifier
               ;

sequence_defn  : GROUP sequence_name NEWLINE statement* ENDGROUP NEWLINE
               ;

sequence_name  : identifier
               ;

statement      : ( event_defn
                 | if
                 | fork
                 | split
                 | loop
                 | // empty line
                 ) NEWLINE
               ;

event_defn     : ( HIDE NEWLINE )?
                 ':' event_name
                   ( branch_count
                   | loop_count
                   | invariant
                   )?
                 ( ';' | '<' | '>' | ']' )
                 ( NEWLINE ( break | detach ) )?
               ;

event_name     : identifier ( '(' NUMBER ')' )?
               ;

branch_count   : ',' BCNT
                 ( ',' SRC ( '=' sname=identifier ( '(' socc=NUMBER ')' )? )? )?
                 ( ',' USER ( '=' uname=identifier ( '(' uocc=NUMBER ')' )? )? )?
                 ',' NAME '=' bcname=identifier
               ;

loop_count     : ',' LCNT
                 ( ',' SRC ( '=' sname=identifier ( '(' socc=NUMBER ')' )? )? )?
                 ( ',' USER ( '=' uname=identifier ( '(' uocc=NUMBER ')' )? )? )?
                 ',' NAME '=' lcname=identifier
               ;

invariant      : ',' ( IINV | EINV )
                 ( ',' SRC ( '=' sname=identifier ( '(' socc=NUMBER ')' )? )? )?
                 ( ',' USER ( '=' uname=identifier ( '(' uocc=NUMBER ')' )? )? )?
                 ',' NAME '=' invname=identifier
               ;

break          : BREAK
               ;

detach         : DETACH
               ;

if             : IF '(' if_condition ')' THEN ( '(' identifier ')' )? NEWLINE
                 statement*
                 elseif*
                 else?
                 ENDIF
               ;

elseif         : ELSEIF ( '(' identifier ')' )? NEWLINE
                 statement*
               ;

else           : ELSE ( '(' identifier ')' )? NEWLINE
                 statement*
               ;

if_condition   : ( identifier )
               ;

loop           : REPEAT NEWLINE
                 statement+
                 REPEAT WHILE
                 ( '(' identifier ')' )?
               ;

fork           : FORK NEWLINE
                 statement+
                 fork_again+
                 ENDFORK
               ;

fork_again     : FORKAGAIN NEWLINE statement+
               ;

split          : SPLIT NEWLINE
                 statement+
                 split_again+
                 ENDSPLIT
               ;

split_again    : SPLITAGAIN NEWLINE statement+
               ;

identifier     : IDENT
               | StringLiteral // allowing blanks delimited with double-quotes
               ;

StringLiteral  : '"' ( ~('\\'|'"') )* '"'
               ;


// keywords
BCNT           : 'bcnt' | 'BCNT'; // branch count
BREAK          : 'break';
DETACH         : 'detach';
EINV           : 'einv' | 'EINV'; // extra-job invariant
ELSE           : 'else';
ELSEIF         : 'elseif';
ENDFORK        : 'end fork';
ENDGROUP       : 'end group';
ENDIF          : 'endif' | 'end if';
ENDSPLIT       : 'end split';
ENDUML         : '@enduml';
FORKAGAIN      : 'fork again';
FORK           : 'fork';
GROUP          : 'group';         // sequence
HIDE           : '-[hidden]->';
IF             : 'if';
IINV           : 'iinv' | 'IINV'; // intra-job invariant
LCNT           : 'lcnt' | 'LCNT'; // loop count
NAME           : 'name' | 'NAME'; // marking target event
PARTITION      : 'partition';     // job
REPEAT         : 'repeat';
SPLITAGAIN     : 'split again';
SPLIT          : 'split';
SRC            : 'src' | 'SRC';
STARTUML       : '@startuml';
THEN           : 'then';
USER           : 'user' | 'USER';
WHILE          : 'while';

NEWLINE        : [\r\n]+;

NOTE           : ( 'floating' )? ' '+ 'note' .*? 'end note' NEWLINE -> channel(HIDDEN);
COLOR          : '#' LABEL -> channel(HIDDEN);
NUMBER         : DIGIT+;
IDENT          : NONDIGIT ( NONDIGIT | DIGIT )*;
LABEL          : ( NONDIGIT | DIGIT )+;
COMMENT        : ( '\'' .*? NEWLINE | '/\'' .*? '\'/' NEWLINE ) -> channel(HIDDEN);
WS             : [ \t]+ -> skip ; // toss out whitespace

//=========================================================
// Fragments
//=========================================================
fragment NONDIGIT : [_a-zA-Z*];
fragment DIGIT :  [0-9];
fragment UNSIGNED_INTEGER : DIGIT+;


