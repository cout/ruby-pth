require 'rubygems'
require 'ffi'

module FFI
  def self.create_invoker(lib, name, args, ret, convention = :default)
    # Mangle the library name to reflect the native library naming conventions
    if lib and lib !~ /\//
      lib = Platform::LIBPREFIX + lib unless lib =~ /^#{Platform::LIBPREFIX}/
      lib += Platform::LIBSUFFIX unless lib =~ /#{Platform::LIBSUFFIX}/
    end
    # Current artificial limitation based on JRuby::FFI limit
    raise SignatureError, 'FFI functions may take max 32 arguments!' if args.size > 32

    invoker = FFI::Invoker.new(lib, name, args.map { |e| find_type(e) },
      find_type(ret), convention.to_s)
    raise NotFoundError.new(name, lib) unless invoker
    return invoker
  end
end

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

  dir = File.dirname(__FILE__)
  # lib = "#{dir}/../pth/pth-2.0.7/.libs/libpth.so"

  ffi_lib 'pth'
  # ffi_lib lib
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

  # callback :pth_thread_switch_event, [ :pth_t ], :void
  # attach_function :set_pth_thread_switch_event, [ :pth_thread_switch_event ], :void

  require 'pth_stack_fix'
end

if __FILE__ == $0 then
  Pth.pth_init
  attr = Pth.pth_attr_new
  # Pth.set_pth_thread_switch_event do |thread|
  #   puts "switching threads to #{thread}"
  # end
  th = Pth.pth_spawn(attr, 0) do |arg|
    puts "in thread:"
    p arg
  end
  puts "join:"
  p Pth.pth_join(th, 0)
end

