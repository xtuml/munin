grammar PlusAct;

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
                 | loop
                 | split
                 | // empty line
                 ) NEWLINE
               ;

event_defn     : ( HIDE NEWLINE )?
                 ':' event_name
                 (
                   ',' ( IINV | EINV | BCNT | LCNT ) ',' ( SRC | USER )
                   ( ',' ( USER '=' event_parm
                           | NAME '=' identifier
                         )
                   )*
                 )?
                 ';'
                 ( NEWLINE ( break | detach ) )?
               ;

event_name     : identifier ( '(' NUMBER ')' )?
               ;

event_parm     : identifier ( '(' NUMBER ')' )?
               ;

break          : BREAK
               ;

detach         : DETACH
               ;

if             : IF '(' condition ')' THEN ( '(' identifier ')' )? NEWLINE
                 statement*
                 ( ELSEIF ( '(' identifier ')' )? NEWLINE )?
                 statement*
                 ( ELSE ( '(' identifier ')' )? NEWLINE )?
                 statement*
                 ENDIF
               ;

condition      : ( IOR | XOR )
               ;

loop           : REPEAT NEWLINE
                 statement+
                 REPEAT WHILE
               ;

split          : SPLIT NEWLINE
                 statement+
                 ( SPLITAGAIN NEWLINE statement+ )+
                 ENDSPLIT
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
ENDGROUP       : 'end group';
ENDIF          : 'endif' | 'end if';
ENDSPLIT       : 'end split';
ENDUML         : '@enduml';
GROUP          : 'group';         // sequence
HIDE           : '-[hidden]->';
IF             : 'if';
IINV           : 'iinv' | 'IINV'; // intra-job invariant
IOR            : 'ior' | 'IOR';
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
XOR            : 'xor' | 'XOR';

NEWLINE        : [\r\n];

NOTE           : 'note' .*? 'end note' NEWLINE -> channel(HIDDEN);
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


