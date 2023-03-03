require 'date'
require 'stringio'
require 'minitest/autorun'
require_relative 'student'

describe Student do
  before do
    @student = Student.new('2', 'student')

    @lock_file_lines = ["1,1,n,2023-11-25,\n", "1,2,n,2023-02-19,\n", "1,3,y,2023-02-25,\n"]
    @attempt_file_lines = ["1,1,Atif Javaid,2/2,100%,2023-02-20,\n"]
    @quiz_file_lines = ["1,2+3 = ?,4,5,6,7,b,\n", "2,10*10 = ?,100,200,300,400,a,\n"]
    @questions_arr = ['1', '2+2?', '4', '5', '6', '7']

    @valid_date_mock = Minitest::Mock.new
    @valid_date_mock.expect(:verify_valid_date, true, [@lock_file_lines, 1])
    # @valid_date_mock.verify_valid_date(@lock_file_lines, 1)
    # @valid_date_mock.verify

    @print_question_mock = Minitest::Mock.new
    @print_question_mock.expect(:print_question, nil, [@questions_arr])
    # @print_question_mock.print_question(@questions_arr)
    # @print_question_mock.verify
  end

  def test_valid_date
    assert_equal(true, @student.verify_valid_date(@lock_file_lines, 1))
  end

  def test_able_to_attempt
    assert_equal(1, @student.able_to_attempt?(@lock_file_lines, @attempt_file_lines, 1))
  end

  def test_get_score
    input = StringIO.new("a\na\n")
    $stdin = input
    assert_equal(1, @student.get_score(@quiz_file_lines))
  end

  def test_attempt_quiz
    @lock_file_mock = Minitest::Mock.new
    @lock_file_mock.expect(:readlines, @lock_file_lines)
    # @lock_file_mock.readlines
    # @lock_file_mock.verify

    input = StringIO.new("1\n")
    $stdin = input

    # @gets_mock = Minitest::Mock.new
    # @gets_mock.expect(:gets, "1\n")

    @attemp_file_mock = Minitest::Mock.new
    @attemp_file_mock.expect(:readlines, @attempt_file_lines)
    # @attemp_file_mock.readlines
    # @attemp_file_mock.verify

    @able_to_attempt_mock = Minitest::Mock.new
    @able_to_attempt_mock.expect(:able_to_attempt?, 1, [@lock_file_lines, @attempt_file_lines, 1])
    # @able_to_attempt_mock.able_to_attempt?(@lock_file_lines, @attempt_file_lines, 1)
    # @able_to_attempt_mock.verify

    @get_quiz_filename_mock = Minitest::Mock.new
    @get_quiz_filename_mock.expect(:get_quiz_filename, 'quiz1.csv', [1])
    # @get_quiz_filename_mock.get_quiz_filename(1)
    # @get_quiz_filename_mock.verify

    @quiz_file_mock = Minitest::Mock.new
    @quiz_file_mock.expect(:readlines, @quiz_file_lines)
    # @quiz_file_mock.readlines
    # @quiz_file_mock.verify

    input = StringIO.new("a\na\n")
    $stdin = input

    @get_score_mock = Minitest::Mock.new
    @get_score_mock.expect(:get_score, 1, [@quiz_file_lines])
    # @get_score_mock.get_score(@quiz_file_lines)
    # @get_score_mock.verify

    # write to file mocking
    @write_attempt_file_mock = Minitest::Mock.new
    @write_attempt_file_mock.expect(:write, "1,2,Abrar,1/2,50%,2023-02-23,\n")
    # @write_attempt_file_mock.write
    # @write_attempt_file_mock.verify

    assert_equal(true, @student.attempt_quiz)
  end
end
