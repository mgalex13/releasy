def win32_project
  project = Relapse::Project.new
  project.name = "Test App"
  project.version = "0.1"
  project.files = source_files
  project.exposed_files = %w[README.txt LICENSE.txt]
  project.add_link "http://spooner.github.com/libraries/relapse/", "Relapse website"

  project
end

def link_file
  <<END
[InternetShortcut]
URL=http://spooner.github.com/libraries/relapse/
END
end

# Hack to allow test to work using a different gemfile than Relapse's.
def redirect_bundler_gemfile
  bundle_gemfile = ENV['BUNDLE_GEMFILE']
  ENV['BUNDLE_GEMFILE'] = File.expand_path("test_project/Gemfile", $original_path)
  ret_val = yield
  ENV['BUNDLE_GEMFILE'] = bundle_gemfile
  ret_val
end