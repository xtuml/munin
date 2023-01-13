grammar PlusAct;

plusdefn       : umlblock+
               ;

umlblock       : '@startuml' ( '(' 'id' '=' identifier ')' )? NEWLINE
                 ( job | sequence | statement | NEWLINE )+
                 '@enduml' NEWLINE?
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
                 | split
                 ) NEWLINE
               ;

audit_event    : ':' identifier ';' // TODO:  add attribute value pairs
               ;

break          : 'break'
               ;

if             : 'if' '(' condition ')' 'then' ( '(' identifier ')' )? NEWLINE
                 statement*
                 ( 'else' ( '(' identifier ')' )? NEWLINE )?
                 statement*
                 'end if'
               ;

condition      : identifier // TODO:  There will likely be an enumerated list of conditions.
               ;

split          : 'split' NEWLINE statement* 'detach' NEWLINE
                 ( 'split again' NEWLINE statement* 'detach' NEWLINE )+
                 'end split'
               ;

identifier     : IDENT
               | StringLiteral // allowing blanks delimited with double-quotes
               ;

StringLiteral  : '"' ( ~('\\'|'"') )* '"'
               ;


number         : IDENT
               ;

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


