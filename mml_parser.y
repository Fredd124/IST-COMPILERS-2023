%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <algorithm>
#include <memory>
#include <cstring>
#include <cdk/compiler.h>
#include <cdk/types/types.h>
#include ".auto/all_nodes.h"
#define LINE                         compiler->scanner()->lineno()
#define yylex()                      compiler->scanner()->scan()
#define yyerror(compiler, s)         compiler->scanner()->error(s)
//-- don't change *any* of these --- END!
%}

%parse-param {std::shared_ptr<cdk::compiler> compiler}

%union {
  //--- don't change *any* of these: if you do, you'll break the compiler.
  YYSTYPE() : type(cdk::primitive_type::create(0, cdk::TYPE_VOID)) {}
  ~YYSTYPE() {}
  YYSTYPE(const YYSTYPE &other) { *this = other; }
  YYSTYPE& operator=(const YYSTYPE &other) { type = other.type; return *this; }

  std::shared_ptr<cdk::basic_type> type;        /* expression type */
  //-- don't change *any* of these --- END!

  int                   i;	/* integer value */
  std::string          *s;	/* symbol name or string literal */
  cdk::basic_node      *node;	/* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
};

%token <i> tINTEGER
%token <s> tIDENTIFIER tSTRING
%token tPUBLIC tPRIVATE tFOREIGN tFORWARD
%token tTYPE_STRING tTYPE_INTEGER tTYPE_REAL tTYPE_AUTO
%token tWHILE tIF tINPUT tBEGIN tEND tNEXT tSTOP tPRINTLN tRETURN tSIZEOF tNULL 

%nonassoc tIFX
%nonassoc tELIF tELSE

%right '='
%left tGE tLE tEQ tNE '>' '<' tAND tOR
%left '+' '-'
%left '*' '/' '%'
%nonassoc tUNARY

%type <node> stmt vardec declaration
%type <sequence> list exprs opt_decls declarations
%type <expression> expr opt_initializer
%type <lvalue> lval
%type <s> string

%type<type> data_type

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program : opt_decls tBEGIN list tEND {compiler->ast(new mml::function_definition_node(LINE, tPRIVATE, cdk::primitive_type::create(4, cdk::TYPE_INT), new cdk::sequence_node(LINE), new mml::block_node(LINE, $3, $3) , true)); } ;

list : stmt	     { $$ = new cdk::sequence_node(LINE, $1); }
	   | list stmt { $$ = new cdk::sequence_node(LINE, $2, $1); }
	   ;

stmt : expr ';'                              { $$ = new mml::evaluation_node(LINE, $1); }
     | vardec                                { $$ = $1; }
     | tINPUT                                { $$ = new mml::input_node(LINE); }
     | exprs '!'                             { $$ = new mml::print_node(LINE, $1, false); }
     | exprs '!''!'                          { $$ = new mml::print_node(LINE, $1, true); }
     | tWHILE '(' expr ')' stmt              { $$ = new mml::while_node(LINE, $3, $5); }
     | tIF '(' expr ')' stmt %prec tIFX      { $$ = new mml::if_node(LINE, $3, $5); }
     | tIF '(' expr ')' stmt tELSE stmt      { $$ = new mml::if_else_node(LINE, $3, $5, $7); }
     | tNEXT tINTEGER ';'                    { $$ = new mml::next_node(LINE, $2); }
     | '{' list '}'                          { $$ = $2; }
     | tRETURN expr ';'                      { $$ = new mml::return_node(LINE, $2); }
     ;

opt_decls : /* empty */ { $$ = new cdk::sequence_node(LINE); }
          | declarations { $$ = $1; }
          ;

declarations   : declaration              { $$ = new cdk::sequence_node(LINE, $1);     }
               | declarations declaration { $$ = new cdk::sequence_node(LINE, $2, $1); }
               ;

declaration    : vardec { $$ = $1; }
               ;

vardec    : tFORWARD data_type tIDENTIFIER ';'                        { $$ = new mml::variable_declaration_node(LINE, tPUBLIC, $2, *$3, nullptr); }
          | tPUBLIC data_type tIDENTIFIER opt_initializer ';'         { $$ = new mml::variable_declaration_node(LINE, tPUBLIC, $2, *$3, $4); }
          | data_type tIDENTIFIER opt_initializer ';'                 { $$ = new mml::variable_declaration_node(LINE, tPRIVATE, $1, *$2, $3); }
          ;

opt_initializer     : /* empty */  { $$ = NULL; }
                    | '=' expr     { $$ = $2; }
                    ;

data_type : tTYPE_STRING      { $$ = cdk::primitive_type::create(4, cdk::TYPE_STRING); }
          | tTYPE_INTEGER     { $$ = cdk::primitive_type::create(4, cdk::TYPE_INT);   }
          | tTYPE_REAL        { $$ = cdk::primitive_type::create(8, cdk::TYPE_DOUBLE); }
          ;

exprs     : expr                   { $$ = new cdk::sequence_node(LINE, $1);     }
          | exprs ',' expr         { $$ = new cdk::sequence_node(LINE, $3, $1); }

expr : tINTEGER                   { $$ = new cdk::integer_node(LINE, $1); }
     | string                     { $$ = new cdk::string_node(LINE, $1); }
     | '-' expr %prec tUNARY      { $$ = new cdk::neg_node(LINE, $2); }
     | '+' expr %prec tUNARY      { $$ = new mml::identity_node(LINE, $2); }
     | expr '+' expr	         { $$ = new cdk::add_node(LINE, $1, $3); }
     | expr '-' expr	         { $$ = new cdk::sub_node(LINE, $1, $3); }
     | expr '*' expr	         { $$ = new cdk::mul_node(LINE, $1, $3); }
     | expr '/' expr	         { $$ = new cdk::div_node(LINE, $1, $3); }
     | expr '%' expr	         { $$ = new cdk::mod_node(LINE, $1, $3); }
     | expr '<' expr	         { $$ = new cdk::lt_node(LINE, $1, $3); }
     | expr '>' expr	         { $$ = new cdk::gt_node(LINE, $1, $3); }
     | expr tGE expr	         { $$ = new cdk::ge_node(LINE, $1, $3); }
     | expr tLE expr              { $$ = new cdk::le_node(LINE, $1, $3); }
     | expr tNE expr	         { $$ = new cdk::ne_node(LINE, $1, $3); }
     | expr tEQ expr	         { $$ = new cdk::eq_node(LINE, $1, $3); }
     | expr tAND expr             { $$ = new cdk::and_node(LINE, $1, $3); }
     | expr tOR expr              { $$ = new cdk::or_node(LINE, $1, $3); }
     | '~' expr                   { $$ = new cdk::not_node(LINE, $2); }
     | tSIZEOF '(' expr ')'       { $$ = new mml::sizeof_node(LINE, $3); }
     | lval '?'                   { $$ = new mml::address_of_node(LINE, $1); }
     | '(' expr ')'            { $$ = $2; }
     | lval                    { $$ = new cdk::rvalue_node(LINE, $1); }  //FIXME
     | lval '=' expr           { $$ = new cdk::assignment_node(LINE, $1, $3); }
     ;

string    : tSTRING                  { $$ = $1; }
          | string tSTRING           { $$ = $1; $$->append(*$2); delete $2; }
          ;

lval : tIDENTIFIER             { $$ = new cdk::variable_node(LINE, $1); }
     ;

/*void_type   : tVOID { $$ = cdk::primitive_type::create(0, cdk::TYPE_VOID);   }
            ;*/

%%
