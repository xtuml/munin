grammar PlusAct;

plusdefn       : umlblock+
               ;

umlblock       : '@startuml' ( '(' 'id' '=' identifier ')' )? NEWLINE
                 ( job | sequence+ | statement+ )+
                 '@enduml'
               ;

job            : partition
               ;

partition      : 'partition' identifier '{' NEWLINE sequence* '}' NEWLINE
               ;

sequence       : 'group' identifier NEWLINE statement* 'end group' NEWLINE
               ;

statement      : ( audit_event
                 | break
                 | if
                 | note
                 | split
                 | comment
                 ) NEWLINE
               ;

break          : 'break'
               ;

if             : 'if' '(' condition ')' 'then' ( '(' identifier ')' )? NEWLINE
                 statement*
                 ( 'else' ( '(' identifier ')' )? NEWLINE )?
                 statement*
                 'end if'
               ;

condition      : identifier
               ;

note           : 'note' ( 'right' | 'left' | 'floating' )? NEWLINE
                 .*
                 'end note'
               ;

split          : 'split' NEWLINE statement* 'detach' NEWLINE
                 ( 'split again' NEWLINE statement* 'detach' NEWLINE )+
                 'end split'
               ;

audit_event    : ':' identifier ';'
               ;

comment        : '\'' .*? NEWLINE
               | '/\'' .*? '\'/'
               ;


identifier     : IDENT
               | StringLiteral // allowing blanks delimited with double-quotes
               ;

StringLiteral                 : '"' ( ~('\\'|'"') )* '"'
                              ;


number         : IDENT
               ;

COLOR          : '#' LABEL -> skip
               ;

NEWLINE  :   [\r\n];

IDENT : NONDIGIT ( NONDIGIT | DIGIT )*;
LABEL : ( NONDIGIT | DIGIT )+;
COMMENT :
    ('/' '/' .*? '\n' | '/*' .*? '*/') -> channel(HIDDEN)
    ;
WS  :   [ ]+ -> skip ; // toss out whitespace

//=========================================================
// Fragments
//=========================================================
fragment NONDIGIT : [_a-zA-Z*];
fragment DIGIT :  [0-9];
fragment UNSIGNED_INTEGER : DIGIT+;


