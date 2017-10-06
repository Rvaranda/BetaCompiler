%{


#include <vector>
#include <map>
#include <iostream>
#include <string>
#include <sstream>
#include <stdlib.h>

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


extern  int linha ;
extern void closeContext();
vector<variaveis> variables_to_declare;
vector<variaveis> variaveisDeclaradas;
static int lastvar = 0;
static int lastnum = 0;
static int abc = 0;

variaveis match(string);


string proximo(string nome)
{
	string s ("aux");
	nome=="Aux"?s=to_string(lastvar):s=to_string(lastnum); 
	nome=="Aux"?lastvar++:lastnum++;
	return nome+s;
}

variaveis popular(string name, string tipo, string tk)
{
	variaveis val = {name, tipo, tk};
	return val;
}
void closeContext()
{
	cout<<"bla"<<endl;
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
		else if(b->tipo=="double")
		{
			a->tipo = "double";
			string s =a->label;
			a->label = proximo("num");
			variaveis var = {"", a->tipo, a->label};
			variables_to_declare.push_back(var);
			return a->label+" = ("+ a->tipo +") " + s + ";\n\t";
		}
		else
		{
			return "";
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
			string aux =variables_to_declare[i].tipo;
			aux = aux=="bool"?"int":aux;
			s += "\t" + aux + " " + variables_to_declare[i].tk + ";\n";
		}
	}

	return s;
}


void checkError(void (*f)(string),struct atributos *a,struct atributos *b,string s)
{
	if(a->tipo !="int" && a->tipo !="double" || b->tipo !="int" && b->tipo !="double")
	{
		(*f)("Operador '"+s+"' nao existe para " + a->tipo +" e "+b->tipo+", na linha "+to_string(linha));
	}
	else if(a->tipo==""||b->tipo=="")
	{
		variaveis v1=match(a->label);
		variaveis v2 = match(b->label);
		if(v1.tk==""||v2.tk=="")
		{

			
			string msg ;
			if(v1.tk=="")
			{
				msg ="A variavel "+v1.tk+" nao foi declarada,na linha "+to_string(linha);
			}
			else
			{
				msg ="A variavel "+v2.tk+" nao foi declarada,na linha "+to_string(linha);
			}
			(*f)(msg);
		}
	}
}
string relational(int x,struct atributos *a,struct atributos *b)
{
	string s;
	int v1,v2;
	double v3,v4;
	cout<<a->tipo;
	if(a->tipo=="char"||b->tipo=="char")
	{
		
	}
	else
	{
		v3=stod(a->val);
		v4=stod(b->val);
	}
	if(x==1)
	{
		s=to_string( v3==v4);
	}
	else if(x==2)
	{
		s=to_string(v3!=v4);
	}
	else if(x==3)
	{
		s=to_string(v3>v4);
	}
	else if(x==4)
	{
		s=to_string(v3<v4);
	}
	else if(x==5)
	{
		s=to_string(v3>=v4);
	}
	else if(x==6)
	{
		s=to_string(v3<=v4);
	}
	return s;
}
string boolHandler(char op,string s1,string s2)
{
	int v1 = stoi(s1);
	int v2 = stoi(s2);
	int result =0;
	if(op == '&' )
	{
		result = v1 && v2;
	}
	else
	{
		result = v1 || v2;
	}
	string s = to_string(result);
	return s+";\n";
}
int declareHelper(string s,variaveis v)
{
	for (int i = 0; i < variables_to_declare.size(); i++)
	{
		if(variables_to_declare[i].name==v.name)
		{
			if(variables_to_declare[i].tipo==v.tipo)
			{
				break;
			}
			else
			{
				return 0;	
			}
		}
	}
	variables_to_declare.push_back(v);
	return 1;
}


variaveis match(string s)
{
	variaveis v={"","",""};
	for (int i = 0; i < variaveisDeclaradas.size(); i++)
	{
		if(variaveisDeclaradas[i].name==s)
		{
			v=variaveisDeclaradas[i];
		}
	}
	return v;
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
%token TK_BOOL
%token TK_TIPO_DOUBLE
%token TK_CHAR
%token TK_REL_EQ
%token TK_REL_NEQ
%token TK_REL_GT
%token TK_REL_LT
%token TK_REL_GE
%token TK_REL_LE
%token TK_TIPO
%start S


%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: TK_TIPO TK_MAIN '(' ')' BLOCO
			{
				if($1.traducao != "int")
				{
					yyerror("Erro de sintaxe");
					return 1;
				}
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
				$$.traducao = $1.traducao + $2.traducao;
			}
			| {
				$$.traducao="";
			}
			;

COMANDO 	: E ';'
			{
				
			}
			|
			BLOCO
			{
				
			}
			;

E 			: E '+' E
			{
				$$.label = proximo("Aux");
				string op ="+";
				checkError(yyerror,&$1,&$3,op);
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label +" "+op+" " + $3.label + ";\n";
				$$.tipo = $1.tipo;
				variaveis var = popular("", $$.tipo, $$.label);
			}
			|
			E '-' E
			{

				$$.label = proximo("Aux");
				string op ="-";
				checkError(yyerror,&$1,&$3,op);
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label +" "+op+" " + $3.label + ";\n";
				$$.tipo = $1.tipo;
				variaveis var = popular("", $$.tipo, $$.label);
			}
			|
			E '*' E
			{
				$$.label = proximo("Aux");
				string op ="*";
				checkError(yyerror,&$1,&$3,op);
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label +" "+op+" " + $3.label + ";\n";
				$$.tipo = $1.tipo;
				variaveis var = popular("", $$.tipo, $$.label);
			}
			|
			E '/' E
			{
				$$.label = proximo("Aux");
				string op ="/";
				checkError(yyerror,&$1,&$3,op);
				$$.traducao = $1.traducao + $3.traducao + "\t" + cast(&$1,&$3) +$$.label+" = "+ $1.label +" "+op+" " + $3.label + ";\n";
				$$.tipo = $1.tipo;
				variaveis var = popular("", $$.tipo, $$.label);
			}
			|
			'('E')'
			{
				$$.label = $2.label;
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao;
			}
			|
			'-'E
			{
				$$.label=proximo("num");
				$$.traducao= $2.traducao+"\t" + proximo("num") + "=" + " -1 * " + $2.label + "\n";
			}
			|
			E TK_REL_EQ E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" == "+ $3.label + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
			}
			|
			E TK_REL_NEQ E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" != "+ $3.label + + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			E TK_REL_GT E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" > "+ $3.label + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			E TK_REL_LT E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" < "+ $3.label + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			E TK_REL_GE E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" >= "+ $3.label + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			E TK_REL_LE E
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.traducao = $1.traducao + $3.traducao+"\t" + $$.label + " = " + $1.label +" <= "+ $3.label + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			TK_ID TK_OP_EQ E 
			{
				variaveis s = match($1.label);
				if(s.tk=="")
				{
					$$.label = proximo("cust");
					$$.tipo = "int";
					variaveis var = popular($1.label, $$.tipo, $$.label);
					variables_to_declare.push_back(var);
					variaveisDeclaradas.push_back(var);
					$$.traducao = $3.traducao +"\t"+$$.label + " = " + $3.label + ";\n";
				}
				else
				{
					if(s.tipo != $3.tipo){yyerror("Tipo da variavel '"+s.name+"' invalido para o valor "+$3.val+" na linha "+to_string(linha));}
					$$.label = s.tk;
					$$.traducao = $3.traducao + "\t" + s.tk + " = " + $3.label + ";\n";
				}
			}
			|
			 '(' TK_TIPO ')' E
			{
				$$.label = proximo("num");
				$$.tipo = $2.traducao;; 
				$$.traducao =$4.traducao + "\t" + $$.label + " = " +"("+$2.traducao+")" +$4.label+ ";\n";
				variaveis var = popular($1.label, $2.traducao, $$.label);
				variables_to_declare.push_back(var);
			}
			| TK_NUM
			{
				$$.label = proximo("num");
				$$.tipo = "int";
				$$.val = $$.traducao;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			TK_REAL
			{
				$$.label = proximo("num");
				$$.tipo = "double";
				$$.val=$$.traducao;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			|
			E TK_LOG_AND E
			{
				variaveis var = {$1.label, "int", proximo("num")};
				$$.label = var.tk;
				$$.traducao =   $1.traducao + $3.traducao+ +"\t"+$$.label + " = " + $1.label +" && "+$3.label +" ;\n";
				variables_to_declare.push_back(var);

			}
			| E TK_LOG_OR E
			{
				variaveis var = {$1.label, "int", proximo("num")};
				$$.label = var.tk;
				$$.traducao =   $1.traducao + $3.traducao+ +"\t"+$$.label + " = " + $1.label +" || "+$3.label +" ;\n";
				variables_to_declare.push_back(var);

			}
			|TK_CHAR
			{
				$$.label = proximo("num");
				$$.tipo = "char";
				$$.val = $$.traducao;
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				variaveis var = popular($1.label, $$.tipo, $$.label);
				variables_to_declare.push_back(var);
			}
			| TK_ID
			{
				variaveis s = match($$.label);
				if(s.tk!="")
				{
					$$.label = proximo("cust");
					$$.tipo = s.tipo;
					$$.val = $$.traducao;
					variaveis var = popular($$.label, $$.tipo, $$.label);
					variables_to_declare.push_back(var);
					$$.traducao = "\t" + $$.label + " = " + s.tk + ";\n";
				}
				else
				{

					yyerror("variavel '"+$$.label+"'' nao declarada ,na linha " +to_string(linha));
				}
			
			}
			|TK_BOOL
			{
				$$.label = proximo("num");
				$$.tipo = "bool";
				$$.val = $$.traducao == "true" ? "1" : "0";
				$$.traducao = "\t" + $$.label + " = " + $$.val + ";\n";
				variaveis var = popular("", $$.tipo, $$.label);
				variables_to_declare.push_back(var);
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
