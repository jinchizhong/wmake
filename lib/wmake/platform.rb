case RUBY_PLATFORM
when /mingw32/
  require_relative 'platform/windows'
when /linux/
  require_relative 'platform/linux'
else
  raise 'Unknown platform!'
end
