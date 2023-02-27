$LOAD_PATH << '.'
require 'pry'
require 'methods'
require 'minitest/autorun'

class TestQuizzes < Minitest::Test
  def test_get_choice_method
    input = StringIO.new("5\n3\n")
    output = StringIO.new
    $stdin = input
    $stdout = output
    assert_equal 3, get_choice(4)
    arr = Array(1..4)
    assert_equal "\nEnter your choice #{arr}: \nPlease enter a valid choice: \n\n", output.string
  end

  def test_valid_signup
    lines = ["1,Atif Javaid,s,atif,123,\n", "1,Farhan,t,teacher,123,\n"]
    assert_equal(true, validate_signup(lines, 's', 'atif'))
  end

  def test_invalid_signup
    lines = ["1,Atif Javaid,s,atif,123,\n", "1,Farhan,t,teacher,123,\n"]
    assert_equal(false, validate_signup(lines, 't', 'atif'))
  end

  def test_get_signup
    assert_equal(false, get_signup('a'))
  end

  def test_get_login
    lines = ''
    assert_equal(false, get_login('t', Teacher.new, lines, 'teacher', '123'))

    lines = ['1,Atif Javaid,s,atif,123,', ' 1,Farhan,t,teacher,123,']
    assert_equal(true, get_login('t', Teacher.new, lines, 'teacher', '123'))
  end

  def test_cases_methods
    assert_equal(false, perform_teacher_actions(Teacher.new, 4))
    assert_equal(false, perform_student_actions(Student.new, 4))
  end
end
