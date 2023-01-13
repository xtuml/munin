grammar PlusAct;

plusdefn       : NEWLINE* umlblock+
               ;

umlblock       : STARTUML ( '(' 'id' '=' identifier ')' )? NEWLINE
                 ( job | sequence | statement | NEWLINE )+
                 ENDUML NEWLINE?
               ;

job            : partition
               ;

partition      : PARTITION identifier '{' NEWLINE sequence* '}' NEWLINE
               ;

sequence       : GROUP identifier NEWLINE statement* ENDGROUP NEWLINE
               ;

statement      : ( audit_event
                 | break
                 | detach
                 | if
                 | loop
                 | split
                 | // empty line
                 ) NEWLINE
               ;

audit_event    : ( HIDE NEWLINE )?
                 ':' identifier ';' // TODO:  add attribute value pairs
               ;

break          : BREAK
               ;

detach         : DETACH
               ;

if             : IF '(' condition ')' THEN ( '(' identifier ')' )? NEWLINE
                 statement*
                 ( ELSE ( '(' identifier ')' )? NEWLINE )?
                 statement*
                 ENDIF
               ;

condition      : ( IOR | XOR ) // TODO:  There will likely be an enumerated list of conditions.
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


number         : IDENT
               ;

// keywords
BREAK          : 'break';
DETACH         : 'detach';
ELSE           : 'else';
ENDGROUP       : 'end group';
ENDIF          : 'endif' | 'end if';
ENDSPLIT       : 'end split';
ENDUML         : '@enduml';
GROUP          : 'group';
HIDE           : '-[hidden]->';
IF             : 'if';
IOR            : 'ior' | 'IOR';
PARTITION      : 'partition';
REPEAT         : 'repeat';
SPLITAGAIN     : 'split again';
SPLIT          : 'split';
STARTUML       : '@startuml';
THEN           : 'then';
WHILE          : 'while';
XOR            : 'xor' | 'XOR';

NEWLINE        : [\r\n];

NOTE           : 'note' .*? 'end note' NEWLINE -> channel(HIDDEN);
COLOR          : '#' LABEL -> channel(HIDDEN);
IDENT          : NONDIGIT ( NONDIGIT | DIGIT )*;
LABEL          : ( NONDIGIT | DIGIT )+;
COMMENT        : ( '\'' .*? NEWLINE | '/\'' .*? '\'/' NEWLINE ) -> channel(HIDDEN);
WS             : [ ]+ -> skip ; // toss out whitespace

//=========================================================
// Fragments
//=========================================================
fragment NONDIGIT : [_a-zA-Z*];
fragment DIGIT :  [0-9];
fragment UNSIGNED_INTEGER : DIGIT+;


