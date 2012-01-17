require File.expand_path("../../teststrap", File.dirname(__FILE__))
require File.expand_path("helpers/win32", File.dirname(__FILE__))

context "win32 folder as zip" do
  setup { win32_project }

  teardown do
    Rake::Task.clear
    Dir.chdir $original_path
  end

  hookup do
    Dir.chdir project_path
    topic.add_output :win32_folder do |o|
      o.add_archive_format :zip
      o.ocra_parameters = "--no-enc"
      o.icon = "test_app.ico"
      o.executable_type = :console
    end
  end

  active_builders_valid

  if RUBY_PLATFORM =~ /win32|mingw/
    context "on Windows" do
      hookup { topic.generate_tasks }

      tasks = [
          [ :Task, "package", %w[package:win32] ],
          [ :Task, "package:win32", %w[package:win32:folder] ],
          [ :Task, "package:win32:folder", %w[package:win32:folder:zip] ],
          [ :Task, "package:win32:folder:zip", %w[pkg/test_app_0_1_WIN32.zip] ],

          [ :Task, "build", %w[build:win32] ],
          [ :Task, "build:win32", %w[build:win32:folder] ],
          [ :Task, "build:win32:folder", %w[pkg/test_app_0_1_WIN32] ],

          [ :FileCreationTask, "pkg", [] ], # byproduct of using #directory
          [ :FileCreationTask, "pkg/test_app_0_1_WIN32", source_files ],
          [ :FileTask, "pkg/test_app_0_1_WIN32.zip", %w[pkg/test_app_0_1_WIN32] ],
      ]

      test_tasks tasks

      context "generate folder + zip" do
        hookup do
          redirect_bundler_gemfile { Rake::Task["package:win32:folder:zip"].invoke }
        end

        asserts("files copied to folder") { source_files.all? {|f| File.read("pkg/test_app_0_1_WIN32/src/#{f}") == File.read(f) } }
        asserts("folder includes link") { File.read("pkg/test_app_0_1_WIN32/Relapse website.url") == link_file }
        asserts("executable created in folder and is of reasonable size") { File.size("pkg/test_app_0_1_WIN32/test_app.exe") > 0 }
        asserts("archive created and of reasonable size") { File.size("pkg/test_app_0_1_WIN32.zip") > 2**20 }
        asserts("uninstaller files have been removed") { FileList["pkg/test_app_0_1_WIN32/unins000.*"].empty? }
      end
    end
  else
    context "NOT on Windows" do
      asserts(:active_builders).empty
    end
  end
end