require 'win32/registry'

Win32::Registry::HKEY_CURRENT_USER.open('Software\Microsoft\VisualStudio\10.0_Config') do |reg|
  WMake::FIND["nmake"] = File.join(reg['ShellFolder'], "VC/bin/nmake.exe").gsub('/', '\\')
end