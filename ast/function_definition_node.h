#ifndef __MML_AST_FUNCTION_DEFINITION_NODE_H__ 
#define __MML_AST_FUNCTION_DEFINITION_NODE_H__ 

#include <cdk/ast/sequence_node.h>

namespace mml {

   /**
   * Class for describing function definition nodes.
   */
  class function_definition_node: public cdk::typed_node {
    int _access;
    std::string _identifier;
    cdk::sequence_node *_parameters;
    mml::block_node *_block;

  public:
    inline function_definition_node(int lineno, int access, std::shared_ptr<cdk::basic_type> functionType, const std::string &identifier,
            cdk::sequence_node *parameters, mml::block_node *block) :
        cdk::typed_node(lineno), _access(access), _identifier(identifier), _parameters(parameters), _block(block) {
      type(functionType);
    }

  public:
    inline cdk::sequence_node *parameters() {
      return _parameters;
    }

    inline int access() {
        return _access;
    }

    inline std::string& identifier() {
      return _identifier;
    }

    
    inline mml::block_node *block() {
        return _block;
    }
   

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_definition_node(this, level);
    }

  };

} // mml

#endif