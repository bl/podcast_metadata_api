# TODO: cleaner method of initializing only in development and test environments
if Rails.env.development? || Rails.env.test?
  FactoryGirl::SyntaxRunner.class_eval do
    # included for fixture_file_upload mixin for FactoryGirl
    include ActionDispatch::TestProcess
  end
end
