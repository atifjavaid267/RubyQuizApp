require 'date'

class Teacher
  attr_accessor :name, :id

  def initialize(id = nil, name = nil)
    @id = id
    @name = name
  end

  def menu
    system('clear')
    puts "Teacher Menu Choices ...\n\n"
    puts '1. Create a Quiz'
    puts '2. Edit a Quiz'
    puts '3. View Attempts'
    puts '4. Logout'
  end

  def take_choices_and_answers(i)
    puts "\nQuestion##{i + 1}"
    puts '-------------'
    print "\nEnter the question: "
    prompt = gets.chomp
    print 'Enter option (a): '
    choice_a = gets.chomp
    print 'Enter option (b): '
    choice_b = gets.chomp
    print 'Enter option (c): '
    choice_c = gets.chomp
    print 'Enter option (d): '
    choice_d = gets.chomp
    print 'Enter correct answer choice (a/b/c/d): '
    answer = gets.chomp
    until %w[a b c d A B C D].include? answer
      print "\nEnter correct answer choice (a/b/c/d): "
      answer = gets.chomp
    end
    [prompt, choice_a, choice_b, choice_c, choice_d, answer]
  end

  def get_valid_questions
    print "\nHow many questions you want to add in this quiz (1-20): "
    number_of_questions = gets.to_i

    while number_of_questions < 1 || number_of_questions > 20
      print 'Enter valid number of questions (1-20): '
      number_of_questions = gets.to_i
    end
    number_of_questions
  end

  def store_new_quiz(total_quizzes)
    file_name = "quiz#{total_quizzes + 1}.csv"
    quiz_file_obj = File.open(file_name, 'w')

    number_of_questions = get_valid_questions

    number_of_questions.times do |i|
      arr = take_choices_and_answers(i)
      quiz_file_obj.write("#{i + 1},#{arr[0]},#{arr[1]},#{arr[2]},#{arr[3]},#{arr[4]},#{arr[5].downcase},\n")
    end
    quiz_file_obj.close
    file_name
  end

  def set_lock
    print "\nYou want to lock this quiz? [y/n]: "
    lock = gets.chomp
    until %w[y n Y N].include? lock
      print "\nPlease enter y or n: "
      lock = gets.chomp
    end
    lock.downcase
  end

  def take_user_date
    loop do
      print 'Please enter valid date (YYYY-MM-DD): '
      date = gets.chomp
      Date.parse(date)
      return date
    rescue ArgumentError
      puts "Invalid date entered!\n"
    end
  end

  def create_quiz
    lock_file_obj = File.open('lock.csv', 'a+')
    lock_file_lines = lock_file_obj.readlines
    total_quizzes = lock_file_lines.length
    file_name = store_new_quiz(total_quizzes)
    puts "\n\nQuiz created successfully in #{file_name}\n\n"
    user_date = take_user_date
    lock = set_lock
    lock_file_obj.write("#{@id},#{total_quizzes + 1},#{lock.downcase},#{user_date},\n")
    lock_file_obj.close
  end

  def set_locked_unlocked_array
    locked_array = []
    unlocked_array = []

    begin
      lock_file_obj = File.open('lock.csv', 'r')
    rescue StandardError
      return '', '', ''
    end
    lock_file_lines = lock_file_obj.readlines
    lock_file_obj.close

    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      if @id.to_s == arr[0].to_s
        arr[2].to_s == 'y' ? locked_array << arr[1] : unlocked_array << arr[1]
      end
    end
    [locked_array, unlocked_array, lock_file_lines]
  end

  def edit_quiz
    locked_array, unlocked_array, lock_file_lines = set_locked_unlocked_array

    if locked_array.empty? && unlocked_array.empty?
      puts "\n\tYou created no quiz yet!"
      sleep 3
      system('clear')
      return
    end

    locked_count = locked_array.length
    unlocked_count = unlocked_array.length
    total_quizzes = locked_count + unlocked_count

    if total_quizzes.zero?
      puts "\nYou created no quiz yet!"
      sleep 3
      system('clear')
      return
    end

    puts "\nThere are total #{total_quizzes} quizzes that you created.\n\n"

    unless locked_count.zero?
      puts "Total Locked Quizes: #{locked_count}"

      print 'Do you want to unlock a quiz? (y/n): '
      get_lock = gets.chomp

      until %w[y Y n N].include? get_lock
        print 'Do you want to unlock a quiz? (y/n): '
        get_lock = gets.chomp
      end

      if %w[y Y].include? get_lock
        print 'Locked Quizes: '
        locked_array.each do |quiz|
          print "#{quiz} "
        end
        puts "\n"

        print "\nEnter quiz number to unlock: "
        quiz_number = gets.chomp

        until locked_array.include? quiz_number
          print 'Please enter the correct quiz number: '
          quiz_number = gets.chomp
        end

        lock_file_obj = File.open('lock.csv', 'w')

        lock_file_lines.each do |line|
          arr = Array.new(line.split(','))
          if @id.to_s == arr[0].to_s && quiz_number == arr[1] && arr[2].to_s == 'y'
            lock_file_obj.write("#{arr[0]},#{arr[1]},n,#{arr[3]},\n")
          else
            lock_file_obj.write("#{arr[0]},#{arr[1]},y,#{arr[3]},\n")
          end
        end
        lock_file_obj.close

        system('clear')
        puts "\nQuiz##{quiz_number} is unlocked successfully..."
        sleep 2
        system('clear')
      end
    end

    return if unlocked_count.zero?

    puts "Total Unlocked Quizes: #{unlocked_count}"

    print 'Do you want to lock a quiz? (y/n): '
    get_lock = gets.chomp

    until %w[y Y n N].include? get_lock
      print 'Do you want to lock a quiz? (y/n): '
      get_lock = gets.chomp
    end

    return unless %w[y Y].include? get_lock

    print 'Unlocked Quizes: '
    unlocked_array.each do |quiz|
      print "#{quiz} "
    end
    puts "\n"

    print "\nEnter quiz number to lock: "
    quiz_number = gets.chomp

    until unlocked_array.include? quiz_number
      print 'Please enter the correct quiz number: '
      quiz_number = gets.chomp
    end

    lock_file_obj = File.open('lock.csv', 'w')

    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      if @id.to_s == arr[0].to_s && quiz_number == arr[1] && arr[2].to_s == 'n'
        lock_file_obj.write("#{arr[0]},#{arr[1]},y,#{arr[3]},\n")
      else
        lock_file_obj.write("#{arr[0]},#{arr[1]},n,#{arr[3]},\n")
      end
    end
    lock_file_obj.close

    system('clear')
    puts "\nQuiz##{quiz_number} is locked successfully..."
    sleep 2
    system('clear')
  end

  def print_attempt_details(attempt_file_lines, your_quizzes)
    timer = 2

    if attempt_file_lines.empty?
      puts "No attempts yet!!\n\n"
      sleep(2)
    else
      puts "\nYour attempts to view:"
      puts "=======================\n\n"
    end

    attempt_file_lines.each do |line|
      arr = Array.new(line.split(','))
      next unless your_quizzes.include? arr[0]

      puts "Attempt Date: #{arr[5]}"
      puts "Quiz: #{arr[0]}"
      puts "ID  : #{arr[1]}"
      puts "Name: #{arr[2]}"
      puts "Score: #{arr[3]} => #{arr[4]}"
      puts "\n"
      timer += 3
    end
    timer
  end

  def view_attempts
    system('clear')
    begin
      lock_file_obj = File.open('lock.csv', 'r')
    rescue StandardError
      puts "\n\tNo Quiz created yet!"
      sleep 2
      return
    end
    lock_file_lines = lock_file_obj.readlines
    lock_file_obj.close

    your_quizzes = []
    lock_file_lines.each do |line|
      arr = Array.new(line.split(','))
      your_quizzes << arr[1] if @id.to_s == arr[0]
    end

    if your_quizzes.empty?
      puts "\nNo attempts found"
      sleep 3
      system('clear')
      return
    end
    begin
      attempt_file_obj = File.open('attempts.csv', 'r')
    rescue StandardError
      puts "\n\tNo attempts found!"
      sleep(2)
      return
    end
    attempt_file_lines = attempt_file_obj.readlines
    attempt_file_obj.close

    timer = print_attempt_details(attempt_file_lines, your_quizzes)
    sleep timer
    system('clear')
  end
end
