FactoryGirl::SyntaxRunner.class_eval do
  # included for fixture_file_upload mixin for FactoryGirl
  include ActionDispatch::TestProcess
end
