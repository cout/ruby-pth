require 'rubygems'
require 'ffi'
require 'ruby_stack'

module Pth
  def self.silent
    orig_verbose = $VERBOSE
    begin
      $VERBOSE = false
      yield
    ensure
      $VERBOSE = orig_verbose
    end
  end

  extend FFI::Library

  ffi_lib 'pth'
  ffi_convention 'cdecl'

  attach_function :pth_init, [ ], :int
  attach_function :pth_kill, [ ], :int

  FFI.add_typedef :pointer, :pth_t
  FFI.add_typedef :pointer, :pth_attr_t

  attach_function :pth_attr_new, [ ], :pth_attr_t

  silent { callback :pth_spawn_entry, [ :pointer ], :pointer }
  attach_function :pth_spawn, [ :pth_attr_t, :pth_spawn_entry, :pointer ], :pth_t

  attach_function :pth_self, [ ], :pth_t
  attach_function :pth_suspend, [ :pth_t ], :int
  attach_function :pth_resume, [ :pth_t ], :int
  attach_function :pth_yield, [ :pth_t ], :int

  # TODO: pointer-to-pointer
  attach_function :pth_join, [ :pth_t, :pointer ], :int

  attach_function :pth_exit, [ :pth_t ], :int

  def self.maybe_switch_threads(m, *args, &block)
    GC.disable
    orig_self = Pth.pth_self
    set_trace_func proc { |*x|
      begin
        if orig_self.address != Pth.pth_self.address then
          # We switched threads; fix the stack and return to normal
          # execution
          RubyStack.set_stack_start_address()
          set_trace_func nil
          GC.enable
        end
      rescue Exception
        p $!
      end
    }
    begin
      if block then
        block = proc { block.call(); GC.disable }
      end
      return Pth.send(m, *args, &block)
    ensure
      # Nope, we didn't switch threads; turn the GC back on, but fix the
      # stack just in case we switched when the method returned
      RubyStack.set_stack_start_address()
      set_trace_func nil
      GC.enable
    end
  end
end

if __FILE__ == $0 then
  Pth.pth_init
  attr = Pth.pth_attr_new
  th = Pth.pth_spawn(attr, 0) do |arg|
    puts "in thread:"
    p arg
  end
  puts "join:"
  # p Pth.pth_join(th, 0)
  p Pth.maybe_switch_threads(:pth_self)
  p Pth.maybe_switch_threads(:pth_join, th, 0)
end

