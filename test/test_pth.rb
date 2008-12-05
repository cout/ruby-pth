require 'test/unit'
require 'pth'

class TestPth < Test::Unit::TestCase
  @@initialized = false

  def setup
    Pth.pth_init if not @@initialized
    at_exit { Pth.pth_kill }
    @@initialized = true
  end

  def test_pth_attr_new
    attr = Pth.pth_attr_new
  end

  def test_spawn
    attr = Pth.pth_attr_new
    th = Pth.maybe_switch_threads(:pth_spawn, attr, 0) { }
  end

  def test_join
    attr = Pth.pth_attr_new
    th = Pth.maybe_switch_threads(:pth_spawn, attr, 0) { }
    Pth.maybe_switch_threads(:pth_join, th, 0)
  end

  def disabled__test_local_variable_set_in_thread
    attr = Pth.pth_attr_new
    run = false
    th = Pth.maybe_switch_threads(:pth_spawn, attr, 0) { run = true }
    Pth.maybe_switch_threads(:pth_join, th, 0)
    assert run
  end

  def test_gc_in_thread
    attr = Pth.pth_attr_new
    p RubyStack.stack_start_address
    th = Pth.maybe_switch_threads(:pth_spawn, attr, 0) {
      p RubyStack.stack_start_address
      GC.start
    }
  end
end

