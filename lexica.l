%{
#include <string>
int linha = 1;
void closeContext();
%}



ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{linha++;}


{DELIM} 	{}

"main"		{return TK_MAIN;}

"&&"		{return TK_LOG_AND;}

"||"		{return TK_LOG_OR;}

"true"		{yylval.traducao=yytext;return TK_BOOL;}

"false"		{yylval.traducao=yytext;return TK_BOOL;}

"int"		{yylval.traducao=yytext;return TK_TIPO;}

"double"	{yylval.traducao=yytext;return TK_TIPO;}

"char"		{yylval.traducao=yytext;return TK_TIPO;}

"="			{return TK_OP_EQ;}

"=="		{return TK_REL_EQ;}

"!="		{return TK_REL_NEQ;}

">"			{return TK_REL_GT;}

"<"			{return TK_REL_LT;}

">="		{return TK_REL_GE;}

"<="		{return TK_REL_LE;}

"{"			{return *yytext;}

"}"			{closeContext() ;return *yytext;}
[()[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{CHAR}		{yylval.traducao=yytext;return TK_CHAR;}
{ID}		{ yylval.label = yytext; return TK_ID; }
{REAL}		{ yylval.traducao = yytext; return TK_REAL;}

.			{ *yytext; }

%%
