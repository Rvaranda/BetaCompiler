all: 	
		clear
		flex lexica.l
		bison -d sintatica.y
		g++ -std=c++11 -o glf sintatica.tab.c -lfl

		./glf < exemplo.foca
