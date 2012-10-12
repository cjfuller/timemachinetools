Gem::Specification.new do |s|
  s.name        = 'time_machine_tools'
  s.version     = '1.0.0'
  s.executables << 'tm_copy'
  s.date        = '2012-08-30'
  s.summary     = "Tools for copying data off of Apple time machine backups"
  s.description = "Tools that copy data off Apple time machine backups on systems that do not support the style of directory hard links used by those backups"
  s.authors     = ["Colin J. Fuller"]
  s.email       = 'cjfuller@gmail.com'
  s.homepage    = 'http://code.google.com/p/timemachinetools'
  s.files       = Dir['lib/**/*.rb'] + Dir['bin/**/*.rb']
  s.license     = 'MIT'
end