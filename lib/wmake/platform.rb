case RUBY_PLATFORM
when /mingw32/
  require_relative 'platform/windows'
else
  raise 'Unknown platform!'
end