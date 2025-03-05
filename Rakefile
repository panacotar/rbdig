require 'minitest/test_task'

# test
Minitest::TestTask.create

# test_local
Minitest::TestTask.create(:test_local) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.warning = false
  all_tests = FileList['test/**/*_test.rb']
  excluded_tests = FileList['test/**/resolver_test.rb']

  t.test_globs = (all_tests - excluded_tests).to_a
end

task default: :test_local
