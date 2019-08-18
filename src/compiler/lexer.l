/*
 * Lexer kompilatora do projektu z JFTT2018
 *
 * Autor: Wojciech Rafałowski
 * 236616
 * 2018-12-20
*/
%option noyywrap
%option yylineno
%option nounput
%{
#define YYSTYPE std::string
#include<string>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include<tuple>
#include<vector>
#include "parser.hh"

	using namespace std;
	int yylex();
%}
IDENTIFIER [_a-z]+
NUMBER [0-9]+
%%
(\[[^\]]*\]) 		;
[ \t]+    			;
[0-9]+ 				{ yylval = yytext; return num; 			}; 
[_a-z]+    			{ yylval = yytext; return pidentifier; 	};
DECLARE     		{ return DECLARE; 	};
IN          		{ return IN; 		};
END         		{ return END; 		};
IF          		{ return IF; 		};
THEN        		{ return THEN; 	};
ELSE        		{ return ELSE; 	};
ENDIF       		{ return ENDIF; 	};
WHILE       		{ return WHILE; 	};
DO          		{ return DO; 		};
ENDWHILE    		{ return ENDWHILE; };
ENDDO       		{ return ENDDO; 	};
FOR         		{ return FOR; 		};
FROM        		{ return FROM; 	};
TO          		{ return TO; 		};
ENDFOR      		{ return ENDFOR; 	};
DOWNTO      		{ return DOWNTO; 	};
READ        		{ return READ; 	};
WRITE       		{ return WRITE; 	};
\;                  { return ';'; 		};
\:                  { return ':'; 		};
\+					{ return '+'; 		};
\-					{ return '-'; 		};
\* 					{ return '*'; 		};
\/ 					{ return '/'; 		};
\% 					{ return '%'; 		};
\(					{ return '('; 		};
\)					{ return ')'; 		};
\=					{ return '='; 		};
\!                  { return '!'; 		};
\<                  { return '<'; 		};
\>                  { return '>'; 		};
\n					;
.               	{ printf("ERROR\n"); return ERROR;	};
%%