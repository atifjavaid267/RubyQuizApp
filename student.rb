require 'date'

class Student
  attr_accessor :id, :name

  def initialize(id = nil, name = nil)
    @id = id
    @name = name
  end

  def menu
    system('clear')
    puts "Student Menu Choices ...\n\n"
    puts '1. Attempt a Quiz'
    puts '2. View your Attempts'
    puts '3. View Quizzes'
    puts '4. Logout'
  end

  def verify_valid_date(lock_file_lines, quiz_num)
    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      return true if quiz_num.to_i == arr[1].to_i && arr[3].to_s >= Date.today.to_s
    end
    false
  end

  def able_to_attempt?(lock_file_lines, attempt_file_lines, quiz_number)
    value = quiz_number
    attempt_file_lines.each do |line|
      arr = Array.new(line.split(','))
      next unless quiz_number == arr[0].to_i && @id.to_i == arr[1].to_i

      value = 0
      puts "Sorry, you already attempted this quiz.\n\n"
      sleep(3)
    end

    return 0 if value.zero?

    # TODO: for date
    if verify_valid_date(lock_file_lines, quiz_number) == false
      puts "\n\nQuiz #{quiz_number} date is passed!\n"
      puts "You cannot attempt this quiz\n\n"
      sleep 3
      return 0
    end

    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      next unless quiz_number == arr[1].to_i && arr[2].to_s == 'y'

      puts "Quiz #{quiz_number} is locked!\n\n"
      puts "You cannot attempt this quiz\n\n"
      value = 0
      sleep 3
      system('clear')
      break
    end
    value
  end

  def print_question(arr)
    puts "Question##{arr[0]}"
    puts '-------------'
    puts arr[1]
    puts "a) #{arr[2]}"
    puts "b) #{arr[3]}"
    puts "c) #{arr[4]}"
    puts "d) #{arr[5]}"
  end

  def get_score(quiz_lines)
    score = 0
    quiz_lines.each do |line|
      arr = Array.new(line.split(','))
      print_question(arr)
      print "\nEnter your answer choice (a/b/c/d): "
      ans = gets.chomp
      until %w[a b c d A B C D].include? ans
        print "\nEnter correct answer choice (a/b/c/d): "
        ans = gets.chomp
      end
      puts "\n"
      score += 1 if ans.downcase == arr[6].downcase
    end
    score.to_i
  end

  def get_quiz_filename(quiz_num)
    "quiz#{quiz_num}.csv"
  end

  def attempt_quiz
    begin
      lock_file_obj = File.open('lock.csv', 'r')
    rescue StandardError
      puts 'No Quiz Found!'
      return 'file not opened'
    end
    lock_file_lines = lock_file_obj.readlines
    total_quizzes = lock_file_lines.length

    return 'No quiz is available to attempt' if total_quizzes.zero?

    puts "There are total #{total_quizzes} quizzes"

    print "\nEnter quiz number to attempt: "
    quiz_num = gets
    quiz_num = quiz_num.to_i

    if quiz_num < 1 || quiz_num > total_quizzes
      puts "\nSorry #{@name} you entered an invalid quiz number to attempt"
      return "Invalid quiz num##{quiz_num} you entered"
    end

    attempt_file_obj = File.open('attempts.csv', 'a+')
    attempt_file_lines = attempt_file_obj.readlines

    quiz_num = able_to_attempt?(lock_file_lines, attempt_file_lines, quiz_num)

    if quiz_num == 0
      lock_file_obj.close
      attempt_file_obj.close
      return 'You are not able to attempt the quiz.'
    end
    quiz_filename = get_quiz_filename(quiz_num)

    begin
      quiz_file_obj = File.open(quiz_filename, 'r')
    rescue StandardError
      puts "Quiz##{quiz_num} not Found!"
      return 'Quiz not Found!'
    end
    quiz_lines = quiz_file_obj.readlines
    score = get_score(quiz_lines)
    attempt_file_obj.write(quiz_num.to_s + ',' + @id.to_s + ',' + @name.to_s + ',' + "#{score}/#{quiz_lines.length}" + ',' + (((score.to_i * 100) / quiz_lines.length.to_i).to_s + '%') + ',' + Date.today.to_s + ",\n")
    lock_file_obj.close
    attempt_file_obj.close
    quiz_file_obj.close
    true
  end

  def view_attempts
    system('clear')
    begin
      attempt_file_obj = File.open('attempts.csv', 'r')
    rescue StandardError
      puts "\n\tNo attempt found!!"
      sleep 2
      return
    end
    attempt_file_lines = attempt_file_obj.readlines
    attempt_file_obj.close

    timer = 2
    total_attempts = 0

    attempt_file_lines.each do |line|
      arr = Array.new(line.split(','))
      next unless arr[1].to_s == @id.to_s

      puts "Quiz: #{arr[0]}"
      puts "Date: #{arr[5]}"
      puts "Score: #{arr[3]} => #{arr[4]}"
      puts "\n"
      timer += 2
      total_attempts += 1
    end

    if total_attempts.zero?
      puts "Hi #{name},"
      puts 'Sorry, you have not attempted any quizzes yet.'
    end
    sleep(timer)
    system('clear')
  end

  def view_quizzes
    begin
      lock_file_obj = File.open('lock.csv', 'r')
    rescue StandardError
      system('clear')
      puts "\n\tNo Quiz Found!"
      sleep(2)
      return
    end
    lock_file_lines = lock_file_obj.readlines
    lock_file_obj.close
    if lock_file_lines.empty?
      puts "Sorry, #{name}, no quiz is available."
      sleep 2
      system('clear')
      return
    end
    system('clear')
    puts 'Following quizzes are available:'
    puts "==================================\n\n"
    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      get_lock = (arr[2] == 'y' ? 'Locked' : 'Unlocked')
      if verify_valid_date(lock_file_lines, arr[1].to_i)
        puts "Quiz: #{arr[1]} => #{get_lock}"
      else
        puts "Quiz: #{arr[1]} => Out of Date"
      end
    end
    puts "\n"
    sleep 5
    system('clear')
  end
end
