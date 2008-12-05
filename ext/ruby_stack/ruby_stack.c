#include <ruby.h>

extern VALUE * rb_gc_stack_start;

VALUE set_stack_start_address(VALUE self)
{
  VALUE stack_start;
  rb_gc_stack_start = &stack_start;
}

VALUE stack_start_address(VALUE self)
{
  return ULONG2NUM((unsigned long)rb_gc_stack_start);
}

VALUE stack_end_address(VALUE self)
{
  VALUE stack_end;
  return ULONG2NUM(&stack_end - (VALUE*)0);
}

void Init_ruby_stack()
{
  VALUE rb_mRubyStack = rb_define_module("RubyStack");
  rb_define_module_function(rb_mRubyStack, "set_stack_start_address", set_stack_start_address, 0);
  rb_define_module_function(rb_mRubyStack, "stack_start_address", stack_start_address, 0);
  rb_define_module_function(rb_mRubyStack, "stack_end_address", stack_end_address, 0);
}

