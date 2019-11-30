%{
    /* definition */
    #include <stdio.h>
    #include <ctype.h>
    #include <cmath>
    #include <iostream>
    #include <iomanip>
    #include <map>
    #include <string>
    #include <vector>
    #include "minipy-lab.h"
    using namespace std;
    typedef struct value
    {
        Type type;
        int integerValue;               /* value for int type */
        double realValue;               /* value for real type */
        string stringValue;             /* value for string type */
        vector<struct value> listValue; /* value for list type */
        string variableName;            /* name of the Variable */
    } Value;

    /*
        符号表 Symbol Table
        variableName(string) -> Value(not Variable)
    */
    map<string, Value> Symbol;

    #define YYSTYPE Value
    #include "lex.yy.c"
    void yyerror(char*);
    // int yylex(void);
%}

%token ID INT REAL STRING_LITERAL
%token DIV
%left  '+' '-'
%left  '*' '/' '%' DIV
%right UMINUS

%%
Start:
    prompt Lines
;

Lines:
    Lines stat '\n'
        {
            Value temp;
            if ($2.type == Variable) /* 单独的变量 */
                temp = Symbol[$2.variableName];
            else
                temp = $2;
            /* temp 是变量的内容或者是直接内容 */
            switch(temp.type)
            {
                case Integer:
                    cout << temp.integerValue << endl;
                    break;
                case Real:
                    if (temp.realValue - floor(temp.realValue) == 0)
                        cout << temp.realValue <<".0"<< endl;
                    else
                        cout << setprecision(15) << temp.realValue << endl;
                    break;
                case String:
                    cout << '\'' << temp.stringValue << '\'' << endl;
                    break;
            }
        }
    prompt |
    Lines '\n' prompt |
    /*  empty production */ |
    error '\n'
        { yyerrok; }
;

prompt:
	{ cout << "miniPy> "; }
;

stat:
	assignExpr
;

assignExpr:
    atom_expr '=' assignExpr
    {
        if ($1.type == Variable)
        {
            Symbol[$1.variableName] = $3; /* 加入符号表 */
        }
        $$.type = LeftValueChanged;
    }|
    add_expr
;

number:
    INT { $$ = $1;} |
    REAL { $$ = $1;}
;

factor:
    '+' factor
        { $$ = $2; } |
    '-' factor %prec UMINUS
        {
            $$.type = $2.type;
            if ($2.type == Integer)
                $$.integerValue = -$2.integerValue;
            else if ($2.type == Real)
                $$.realValue = -$2.realValue;
        } |
    atom_expr
        {
            if ($1.type == Variable) // atom 是变量
                $$ = Symbol[$1.variableName]; // 取变量内容
            else
                $$ = $1;
        }
;

atom:
    ID
    {

    }|
    STRING_LITERAL |
    List |
    number
        { $$ = $1;}
;

slice_op:
    /*  empty production */ |
    ':' add_expr
;

sub_expr:
    /*  empty production */ |
    add_expr
;

atom_expr:
    atom |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']' |
    atom_expr  '[' add_expr ']' |
    atom_expr  '.' ID |
    atom_expr  '(' arglist opt_comma ')' |
    atom_expr  '('  ')'
;

arglist:
    add_expr |
    arglist ',' add_expr
;

List:
    '[' ']' |
    '[' List_items opt_comma ']' /* 注意 [1, 2, 3, ] == [1, 2, 3] */
;

opt_comma:
    /*  empty production */ |
    ','
;

List_items:
    add_expr |
    List_items ',' add_expr
;

add_expr:
    add_expr '+' mul_expr
        {
            if (($1.type == Integer) && ( $3.type == Integer ))
            {
			    $$.type = Integer;
                $$.integerValue = $1.integerValue + $3.integerValue;
            }
            else
            {
		        $$.type = Real;
                if ( $1.type == Integer )
                    $1.realValue = (double) $1.integerValue;
                if ( $3.type == Integer )
                    $3.realValue = (double) $3.integerValue;
                $$.realValue = $1.realValue + $3.realValue;
            }
        }|
    add_expr '-' mul_expr
        {
            if (($1.type == Integer) && ( $3.type == Integer ))
            {
			    $$.type = Integer;
                $$.integerValue = $1.integerValue - $3.integerValue;
            }
            else
            {
		        $$.type = Real;
                if ( $1.type == Integer )
                    $1.realValue = (double) $1.integerValue;
                if ( $3.type == Integer )
                    $3.realValue = (double) $3.integerValue;
                $$.realValue = $1.realValue - $3.realValue;
            }
        }|
    mul_expr
;

mul_expr:
    mul_expr '*' mul_expr
        {
            if (($1.type == Integer) && ( $3.type == Integer ))
            {
			    $$.type = Integer;
                $$.integerValue = $1.integerValue * $3.integerValue;
            }
            else
            {
		        $$.type = Real;
                if ( $1.type == Integer )
                    $1.realValue = (double) $1.integerValue;
                if ( $3.type == Integer )
                    $3.realValue = (double) $3.integerValue;
                $$.realValue = $1.realValue * $3.realValue;
            }
        }|
    mul_expr '/' mul_expr
        {
            $$.type = Real;
            if ( $1.type == Integer )
                $1.realValue = (double) $1.integerValue;
            if ( $3.type == Integer )
                $3.realValue = (double) $3.integerValue;
            $$.realValue = $1.realValue / $3.realValue;
        }|
    mul_expr DIV mul_expr
        {
            // 整除
            if ( $1.type == Real )
                $1.integerValue = round($1.realValue);
            if ( $3.type == Real )
                $3.integerValue = round($3.realValue);
            $$.type = Integer;
            $$.integerValue = $1.integerValue / $3.integerValue;
        }|
    mul_expr '%' mul_expr
        {
            if (($1.type == Integer) && ( $3.type == Integer ))
            {
			    $$.type = Integer;
                $$.integerValue = $1.integerValue % $3.integerValue;
                if ($1.integerValue * $3.integerValue < 0) // 取余的符号问题
                    $$.integerValue += $3.integerValue;
            }
            else
            {
		        $$.type = Real;
                if ( $1.type == Integer )
                    $1.realValue = (double) $1.integerValue;
                if ( $3.type == Integer )
                    $3.realValue = (double) $3.integerValue;
                int temp = (int)($1.realValue / $3.realValue); // 手动实现实数取余
                $$.realValue = $1.realValue - ($3.realValue * temp);
                if ($1.realValue * $3.realValue < 0)
                    $$.realValue += $3.realValue;
            }
        }|
    '(' add_expr ')' { $$ = $2; } |
    '(' mul_expr ')' { $$ = $2; } |
    factor
;

%%

int main()
{
	return yyparse();
}

void yyerror(char *s)
{
	cout << s << endl << "miniPy> ";
}

int yywrap()
{
	return 1;
}
