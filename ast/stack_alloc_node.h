#ifndef __MML_AST_STACK_ALLOC_NODE_H__
#define __MML_AST_STACK_ALLOC_NODE_H__

#include <cdk/ast/unary_operation_node.h>
#include <cdk/ast/expression_node.h>

namespace mml {

  /**
   * Class for describing the memory allocate node.
   */
  class stack_alloc_node: public cdk::unary_operation_node {
  public:
    inline stack_alloc_node(int lineno, cdk::expression_node *size) :
      cdk::unary_operation_node(lineno, size) {
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_stack_alloc_node(this, level);
    }

  };

} // mml

#endif