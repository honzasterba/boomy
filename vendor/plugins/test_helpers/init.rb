# include the model in all test cases, comment this if it bothers you
Test::Unit::TestCase.send(:include, TestHelpers::ModelTestHelper)