#include <string.h>
#include <malloc.h>
#include "symboltable.h"

static const int coef1 = 1021;
static const int coef2 = 977;
static char* t[TMAX];

static int hash(char* key, unsigned int i) {
    unsigned int v = 13;
    int h;
    while (*key != '\0') {
        v = v*coef1 + *key * coef2;
        key++;
    }
    h = (v + (i * i)) % TMAX;
    return h;
}

int getSymbolPosition(char* symbol) {
    int i = 0;
    int h = hash(symbol, i);
    while (t[h] != NULL && strcmp(t[h], symbol) != 0) {
        i++;
        h = hash(symbol, i);
    }
    return h;
}

int containsSymbol(char* symbol){
    int h = getSymbolPosition(symbol);
    return (t[h] != NULL);
}

int addSymbol(char* symbol) {
    int h = getSymbolPosition(symbol);
    if (t[h] == NULL) {
        t[h] = strdup(symbol);
    }
    return h;
}

char* getSymbolAt(int k) {
    return t[k];
}

