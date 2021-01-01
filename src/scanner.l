%{
#include <stdint.h>
#include <string.h>

#define LIST                strCat(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>\n", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>\n", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
char buffer[MAX_LINE_LENG];

static int32_t opt_src = 1;
static int32_t opt_tok = 1;
static char *buffer_ptr = buffer;

static void strCat(const char *Text);

%}

%s IN_COMMENT
%s COM1
%s COM2
%s COM3
%s COM4
%s COM5
%s COM6

%% 

" " {LIST;}
"	" {LIST;}


<INITIAL>"//&S" {
    LIST;
    BEGIN(COM3);
}
<COM3>"+" {
    LIST;
    BEGIN(COM5);
    opt_src = 1;
}
<COM3>"-" {
    LIST;
    BEGIN(COM5);
    opt_src = 0;
}
<COM5>.+ {
    LIST;
}
<COM5>\n {
    BEGIN (INITIAL);
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}


<INITIAL>"//&T" {
    LIST;
    BEGIN(COM4);
}
<COM4>"+" {
    LIST;
    BEGIN(COM6);
    opt_tok = 1;
}
<COM4>"-" {
    LIST;
    BEGIN(COM6);
    opt_tok = 0;
}
<COM6>.+ {
    LIST;
}
<COM6>\n {
    BEGIN (INITIAL);
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

<INITIAL>"//" {
    LIST;
    BEGIN(COM1);
}
<COM1>.+ {
    LIST;
    BEGIN(COM2);
}
<COM2>\n {
    BEGIN (INITIAL);
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

<INITIAL>"/*" {
    LIST;
    BEGIN(IN_COMMENT);
}
<IN_COMMENT>. {
    LIST;
}
<IN_COMMENT>"*/" {
    LIST;
    BEGIN (INITIAL);
    
}





<INITIAL>{
"(" { TOKEN_CHAR('('); }

")" { TOKEN_CHAR(')'); }

"," { TOKEN_CHAR(','); }

";"  { TOKEN_CHAR(';'); }

":" { TOKEN_CHAR(':'); }

"[" { TOKEN_CHAR('['); }

"]" { TOKEN_CHAR(']'); }

"+" { TOKEN_CHAR('+'); }

"-" { TOKEN_CHAR('-'); }

"*" { TOKEN_CHAR('*'); }

"/" { TOKEN_CHAR('/'); }

"mod" { TOKEN(mod); }

":=" { TOKEN(:=); }

"<" { TOKEN_CHAR('<'); }

"<=" { TOKEN(<=); }

"<>" { TOKEN(<>); }

">=" { TOKEN(>=); }

">" { TOKEN_CHAR('>'); }

"=" { TOKEN_CHAR('='); }

"and" { TOKEN(and); }

"or" { TOKEN(or); }

"not" { TOKEN(not); }

"array" { TOKEN(KWarray); }

"begin" { TOKEN(KWbegin); }

"boolean" { TOKEN(KWboolean); }

"def" { TOKEN(KWdef); }

"do" { TOKEN(KWdo); }

"else" { TOKEN(KWelse); }

"end" { TOKEN(KWend); }

"false" { TOKEN(KWfalse); }

"for" { TOKEN(KWfor); }

"integer" { TOKEN(KWinteger); }

"if" { TOKEN(KWif); }

"of" { TOKEN(KWof); }

"print" { TOKEN(KWprint); }

"read" { TOKEN(KWread); }

"real" { TOKEN(KWreal); }

"string" { TOKEN(KWstring); }

"then" { TOKEN(KWthen); }

"to" { TOKEN(KWto); }

"true" { TOKEN(KWtrue); }

"return" { TOKEN(KWreturn); }

"var" { TOKEN(KWvar); }

"while" { TOKEN(KWwhile); }

[a-zA-Z]+[a-zA-Z0-9]* { TOKEN_STRING(id,yytext); }

[1-9]+[0-9]* { TOKEN_STRING(integer,yytext); }

[0-9] { TOKEN_STRING(integer,yytext); }

[0][.][1-9]+ { TOKEN_STRING(float,yytext); }

[0][.][0-9]+[1-9]* { TOKEN_STRING(float,yytext); }

[1-9]+[0-9]*[.][0-9]*[1-9]+ { TOKEN_STRING(float,yytext); }

[0]+[0-7]+ { TOKEN_STRING(oct_integer,yytext); }

[1-9]+[0-9]*[.][0-9]+[eE][+-]?[1-9]+[0]* { TOKEN_STRING(scientific,yytext); }

[1-9]+[0-9]*[.][0-9]+[eE][+-]?[0] { TOKEN_STRING(scientific,yytext); }

[1-9]+[0-9]*[eE][+-]?[1-9]+[0]* { TOKEN_STRING(scientific,yytext); }

[1-9]+[0-9]*[eE][+-]?[0] { TOKEN_STRING(scientific,yytext); }

["][^\"]*(\"\")+([^\"]*(\"\")*)*["] {
    char yy2[yyleng-2];
    int i;
    int j=0;
    char tem;
    tem = yytext[0];
    for(i=1;i<yyleng-1;i++){
        if(tem==yytext[i] && tem== '\"' && i!=1){   
            tem = '0';
        }
        else {
            yy2[j] = yytext[i];
            j++;
            tem = yy2[j-1];
        }
    }
    yy2[j] = 0;
    TOKEN_STRING(string,yy2); }


["][^\"]*["] {
    char yy2[yyleng-1];
    strncpy(yy2,yytext+1,yyleng-2);
    yy2[yyleng-2] = 0;
    TOKEN_STRING(string,yy2); }

}

\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}



    /* Catch the character
    
     which is not accepted by rules above */
. {
    printf("Error at line %d: bad character \"%s\"\n", line_num, yytext);
    exit(-1);
}

%% 

static void strCat(const char *Text) {
    while (*Text) {
        *buffer_ptr++ = *Text++;
    }
    *buffer_ptr = '\0';
}

int main(int argc, const char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./scanner [filename]\n");
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Open file error\n");
        exit(-1);
    }

    yylex();

    return 0;
}
