require 'mkmf'
dir = File.dirname(__FILE__)
$CPPFLAGS << " -I#{dir}/../../pth/pth-2.0.7"
$LDFLAGS << " -L#{dir}/../../pth/pth-2.0.7/.libs"
have_library('pth') or fail "need pth"
create_makefile('pth_stack_fix/pth_stack_fix')

