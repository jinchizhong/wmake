require 'yaml'

module WMake
  def self.help
    puts <<EOF
Usage: wmake <path_to_source_dir_or_binary_dir_or_wmake_file> [args...]
EOF
    exit 0
  end
  def self.die msg, code = 1
    $stderr.puts msg
    exit code
  end
end

require 'wmake/front'
require 'wmake/project'
