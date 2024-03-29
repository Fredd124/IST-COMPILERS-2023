#ifndef __MML_TARGETS_POSTFIX_WRITER_H__
#define __MML_TARGETS_POSTFIX_WRITER_H__

#include "targets/basic_ast_visitor.h"

#include <sstream>
#include <stack>
#include <set>
#include <cdk/emitters/basic_postfix_emitter.h>

namespace mml {

  //!
  //! Traverse syntax tree and generate the corresponding assembly code.
  //!
  class postfix_writer: public basic_ast_visitor {
    cdk::symbol_table<mml::symbol> &_symtab;

    std::set<std::string> _to_declare;
    std::vector<int> _whileStartLabels;
    std::vector<int> _whileEndLabels;
    std::stack<std::string> _currentBodyRetLabels; // where to jump when a return occurs of an exclusive section ends
    std::vector<mml::function_definition_node *> _functions_to_define;
    bool _nextSeen;
    bool _stopSeen;
    bool _returnSeen; // when building a function
    bool _inFunctionBody;
    bool _inFunctionArgs;

    int _funcCount;

    std::stack<std::shared_ptr<mml::symbol>> _functions; // for keeping track of the current function and its arguments
    int _offset; // for keeping track of local variable offsets
    
    
    cdk::basic_postfix_emitter &_pf;
    int _lbl;

  public:
    postfix_writer(std::shared_ptr<cdk::compiler> compiler, cdk::symbol_table<mml::symbol> &symtab,
                   cdk::basic_postfix_emitter &pf) :
        basic_ast_visitor(compiler), _symtab(symtab), _nextSeen(false), _stopSeen(false),  _returnSeen(false), _inFunctionBody(false), 
        _inFunctionArgs(false), _funcCount(0), _offset(0), _pf(pf), _lbl(0) {
    }

  public:
    ~postfix_writer() {
      os().flush();
    }

  private:
    /** Method used to generate sequential labels. */
    inline std::string mklbl(int lbl) {
      std::ostringstream oss;
      if (lbl < 0)
        oss << ".L" << -lbl;
      else
        oss << "_L" << lbl;
      return oss.str();
    }

  public:
  // do not edit these lines
#define __IN_VISITOR_HEADER__
#include ".auto/visitor_decls.h"       // automatically generated
#undef __IN_VISITOR_HEADER__
  // do not edit these lines: end

  };

} // mml

#endif
