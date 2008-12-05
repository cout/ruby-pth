#include <ruby.h>
#include <pth.h>
#include <pth_p.h>

extern VALUE *rb_gc_stack_start;

static void on_pth_thread_switch(pth_t new_thread)
{
  rb_gc_stack_start = (VALUE *)(new_thread->stack + new_thread->stacksize);
  printf("setting stack start to %p\n", rb_gc_stack_start);
}

void Init_pth_stack_fix()
{
  set_pth_thread_switch_event(on_pth_thread_switch);
}

