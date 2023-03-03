require_relative 'teacher'
require 'date'
require 'minitest/autorun'

#####################
# for teacher methods
#####################
describe Teacher do
  before do
    @teacher = Teacher.new('1', 'Abrar')
    @questions_answers_arr = ['2+2?', '4', '6', '7', '8', 'a']
    @lock_file_lines = ["1,1,n,2023-11-22,\n", "1,2,n,2023-02-19,\n", "1,3,y,2023-02-25,\n"]
    @attempt_file_lines = ["1,1,Atif Javaid,2/2,100%,2023-02-20,\n"]

    @locked_unlocked_array = [['3'], %w[1 2]]

    @take_choices_and_answers_mock = Minitest::Mock.new
    @take_choices_and_answers_mock.expect(:take_choices_and_answers, @questions_answers_arr, [0])

    @get_valid_questions_mock = Minitest::Mock.new
    @get_valid_questions_mock.expect(:get_valid_questions, 1)
    # @get_valid_questions_mock.get_valid_questions
    # @get_valid_questions_mock.verify

    @store_new_quiz_mock = Minitest::Mock.new
    @store_new_quiz_mock.expect(:store_new_quiz, 'quiz4.csv', [3])

    @take_user_date_mock = Minitest::Mock.new
    @take_user_date_mock.expect(:take_user_date, '2023-10-10')

    @set_lock_mock = Minitest::Mock.new
    @set_lock_mock.expect(:set_lock, 'y')

    # @create_quiz_mock = Minitest::Mock.new
    # @create_quiz_mock.expect(:create_quiz, nil)

    @get_lock_file_lines_mock = Minitest::Mock.new
    @get_lock_file_lines_mock.expect(:get_lock_file_lines, @lock_file_lines)

    @set_locked_unlocked_array_mock = Minitest::Mock.new
    @set_locked_unlocked_array_mock.expect(:set_locked_unlocked_array, @locked_unlocked_array)
  end

  def test_take_choices_and_answers
    input = StringIO.new("2+2?\n4\n6\n7\n8\ne\na\n")
    $stdin = input
    assert_equal(@questions_answers_arr, @teacher.take_choices_and_answers(0))
  end

  def test_get_valid_questions
    input = StringIO.new("21\n100\n50\n1\n")
    $stdin = input
    assert_equal(1, @teacher.get_valid_questions)
  end

  def test_store_new_quiz
    assert_equal('quiz4.csv', @teacher.store_new_quiz(3))
  end

  def test_set_lock
    input = StringIO.new("x\nm\no\ny\n")
    $stdin = input
    assert_equal('y', @teacher.set_lock)
  end

  def test_take_user_date
    input = StringIO.new("abc-as-ss\n2015-qw-12\n2023-10-10\n")
    $stdin = input
    assert_equal('2023-10-10', @teacher.take_user_date)
  end

  def test_create_quiz
    assert(@teacher.create_quiz)
  end

  def test_lock_file_lines
    assert_equal(@lock_file_lines, @teacher.get_lock_file_lines)
  end

  def test_set_locked_unlocked_array
    assert_equal(@locked_unlocked_array, @teacher.set_locked_unlocked_array)
  end
end
