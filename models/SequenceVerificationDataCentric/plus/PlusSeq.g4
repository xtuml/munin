grammar PlusSeq;

plusdefn       : umlblock+
               ;

umlblock       : '@startuml' ( '(' 'id' '=' identifier ')' )?
                 ( job | statement+ | NEWLINE )+
                 '@enduml'
               ;

job            : 'title' identifier statement+
               ;

statement      : 'title' identifier
               | participation
               | sequence
               ;

participation  : 'participant' identifier
               | 'actor' identifier
               ;

sequence       : audit_event+
               | 'box' identifier NEWLINE sequence 'end box'
               | 'autonumber' sequence 'autonumber stop'
               | comment
               ;

audit_event    : number? ( actor | participant ) ( '->' | '<-' ) ( actor | participant ) ':' event_type
               ;

comment        : '\'' .*? NEWLINE
               | '/\'' .*? '\'/'
               ;

event_type     : identifier
               ;

participant    : identifier
               ;

actor          : identifier
               ;

identifier     : IDENT
               | StringLiteral // allowing blanks delimited with double-quotes
               ;

StringLiteral                 : '"' ( ~('\\'|'"') )* '"'
                              ;


number         : IDENT
               ;

NEWLINE  :   [\r\n];

IDENT : NONDIGIT ( DIGIT | NONDIGIT )*;
COMMENT :
    ('/' '/' .*? '\n' | '/*' .*? '*/') -> channel(HIDDEN)
    ;
WS  :   [ ]+ -> skip ; // toss out whitespace

//=========================================================
// Fragments
//=========================================================
fragment NONDIGIT : [_a-zA-Z];
fragment DIGIT :  [0-9];
fragment UNSIGNED_INTEGER : DIGIT+;


