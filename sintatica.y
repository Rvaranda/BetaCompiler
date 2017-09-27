%{
#include <vector>
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tipo;
	string val;
};
struct variaveis
{
	string name;
	string tipo;
	string tk;
};
static int lastvar = 0;
static int lastnum = 0;
string proximo(string nome)
{
	string s ("aux");
	ostringstream convert;
	nome=="Aux"?convert << lastvar:convert << lastnum; 
	s = convert.str();
	nome=="Aux"?lastvar++:lastnum++;
	return nome+s;
}
variaveis popular(string s1,string s2,string s3)
{
	variaveis val ={s1,s2,s3};
	return val;
}

string cast(struct atributos *a,struct atributos *b)
{
	if(a->tipo == b->tipo)return "";
	else
	{
		if(a->tipo=="double")
		{
			b->tipo = "double";
			string s =b->label;
			b->label = proximo("num");
			return b->label+" = ("+ b->tipo +") " + s + ";\n\t";
		}
		else
		{
			a->tipo = "double";
			string s =a->label;
			a->label = proximo("num");
			return a->label+" = ("+ a->tipo +") " + s + ";\n\t";
		}
	}
}

int yylex(void);
void yyerror(string);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT
%token TK_REAL
%token TK_FIM TK_ERROR
%token TK_LOG_AND
%token TK_LOG_OR
%token TK_CONTROL_IF
%token TK_OP_EQ

%start S


%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador FOCA*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl; 
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{

				$$.traducao = $$.traducao + $2.traducao;
			}
			|
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
				$$.label = proximo("Aux");
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label + " + " + $3.label + ";\n";
				$$.tipo =$1.tipo;
			}
			|
			E '-' E
			{

				$$.label = proximo("Aux");
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) + $$.label+" = "+ $1.label + " - " + $3.label + ";\n";
				$$.tipo=$1.tipo;
			}
			|
			E '*' E
			{
				$$.label = proximo("Aux");
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label + " * " + $3.label + ";\n";
				$$.tipo = $1.tipo;
			}
			|
			E '/' E
			{
				$$.label = proximo("Aux");
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label + " / " + $3.label + ";\n";
				$$.tipo=$1.tipo;
			}
			|
			'('E')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			|
			TK_TIPO_INT TK_ID TK_OP_EQ TK_NUM 
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			|
			'-'E
			{
				$$.label=proximo("num");
				$$.traducao= $2.traducao+"\t" + proximo("num") + "=" + " -1 * " + $2.label + "\n";
			}
			| TK_NUM
			{
				variaveis s = popular("1","2","3");
				cout<<s.name;
				$$.label = proximo("num");
				$$.tipo = "int";
				$$.val=$$.traducao;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			|
			TK_REAL
			{
				$$.label = proximo("num");
				$$.tipo = "double";
				$$.val=$$.traducao;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			|
			TK_LOG_AND
			{

			}
			| TK_ID
			{

			}
			;
%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
