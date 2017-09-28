%{

// MALDITO BUG DO NUMERO VOADOR
// CORRIJA ISSO LOGO

#include <vector>
#include <map>
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

map<string, string> var_op =
{
	{ "int,int", "int" },
	{ "int,double", "double" },
	{ "double,int", "double" },
	{ "double,double", "double" }
};

vector<variaveis> variables_to_declare;
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
variaveis popular(string name, string tipo, string tk)
{
	variaveis val = {name, tipo, tk};
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
			variaveis var = {"", b->tipo, b->label};
			variables_to_declare.push_back(var);
			return b->label+" = ("+ b->tipo +") " + s + ";\n\t";
		}
		else
		{
			a->tipo = "double";
			string s =a->label;
			a->label = proximo("num");
			variaveis var = {"", a->tipo, a->label};
			variables_to_declare.push_back(var);
			return a->label+" = ("+ a->tipo +") " + s + ";\n\t";
		}
	}
}

string declareVariables()
{
	string s("");

	if (variables_to_declare.size() > 0)
	{
		for (int i = 0; i < variables_to_declare.size(); i++)
		{
			s += "\t" + variables_to_declare[i].tipo + " " + variables_to_declare[i].tk + ";\n";
		}
	}

	return s;
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
				$$.traducao = declareVariables() + "\n" + $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				string s = $2.traducao;
				s = (s.find("num") == string::npos || s.find("Aux") == string::npos) ? "":s;
				$$.traducao = $1.traducao + s;
			}
			| {}
			;

COMANDO 	: E ';'
			;

E 			: E '+' E
			{
				$$.label = proximo("Aux");
				$$.tipo = var_op[$1.tipo+","+$3.tipo];
				
				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) + $$.label+" = "+ $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{

				$$.label = proximo("Aux");
				$$.tipo = $$.tipo = var_op[$1.tipo+","+$3.tipo];

				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) + $$.label+" = "+ $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.label = proximo("Aux");
				$$.tipo = $$.tipo = var_op[$1.tipo+","+$3.tipo];

				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.label = proximo("Aux");
				$$.tipo = $$.tipo = var_op[$1.tipo+","+$3.tipo];

				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label + " / " + $3.label + ";\n";
			}
			| '('E')'
			{
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
			}
			| TK_TIPO_INT TK_ID TK_OP_EQ TK_NUM 
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			| '-'E
			{
				$$.label = proximo("num");
				$$.traducao = $2.traducao+"\t" + proximo("num") + "=" + " -1 * " + $2.label + "\n";
			}
			| TK_NUM
			{
				$$.label = proximo("num");
				$$.tipo = "int";
				$$.val=$$.traducao;

				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_REAL
			{
				$$.label = proximo("num");
				$$.tipo = "double";
				$$.val=$$.traducao;

				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);

				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_LOG_AND
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
