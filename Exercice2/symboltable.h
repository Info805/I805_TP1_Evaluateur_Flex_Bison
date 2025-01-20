#ifndef SYMBOLTABLE_H_INCLUDED
#define SYMBOLTABLE_H_INCLUDED

#define TMAX 200

int containsSymbol(char* symbol);
int addSymbol(char* symbol);
int getSymbolPosition(char* symbol);
char* getSymbolAt(int k);

#endif /* !SYMBOLTABLE_H_INCLUDED */
