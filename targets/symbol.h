#ifndef __MML_TARGETS_SYMBOL_H__
#define __MML_TARGETS_SYMBOL_H__

#include <string>
#include <memory>
#include <cdk/types/basic_type.h>

namespace mml {

  class symbol {
    std::shared_ptr<cdk::basic_type> _type;
    std::string _name;
    long _value; // hack!
    bool _isFunction;
    int _offset;
    std::vector<std::shared_ptr<cdk::basic_type>> _argument_types;

  public:
    symbol(std::shared_ptr<cdk::basic_type> type, const std::string &name, long value, bool isFunction = false) :
        _type(type), _name(name), _value(value), _isFunction(isFunction) {
    }

    virtual ~symbol() {
      // EMPTY
    }

    std::shared_ptr<cdk::basic_type> type() const {
      return _type;
    }
    void type(std::shared_ptr<cdk::basic_type> type) {
      _type = type;
    }
    bool is_typed(cdk::typename_type name) const {
      return _type->name() == name;
    }
    const std::string &name() const {
      return _name;
    }
    long value() const {
      return _value;
    }
    long value(long v) {
      return _value = v;
    }
    bool isFunction() const {
        return _isFunction;
    }
    void isFunction(bool isFunction) {
        _isFunction = isFunction;
    }
    int offset() const {
      return _offset;
    }
    void offset(int offset) {
      _offset = offset;
    }
    std::shared_ptr<cdk::basic_type> argument_type(size_t i) const {
      return _argument_types[i];
    }
    size_t number_of_arguments() const {
      return _argument_types.size();
    }

  };
  inline auto make_symbol(std::shared_ptr<cdk::basic_type> type, const std::string &name,
                          long value, bool isFunction) {
    return std::make_shared<symbol>(type, name, value, isFunction );
  }

} // mml

#endif
