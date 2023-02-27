require_relative 'teacher'
require_relative 'student'

def main_menu
  puts "\n\n"
  puts '*** WELCOME TO THE PORTAL ***'
  puts "\n"
  puts "\t1. LogIn"
  puts "\t2. SignUp"
  puts "\t3. Exit Portal"
end

def login_menu
  system('clear')
  puts '1. Login as Teacher'
  puts '2. Login as Student'
  puts '3. Return to main menu'
end

def signup_menu
  system('clear')
  puts '1. Sign up as Teacher'
  puts '2. Sign up as Student'
  puts '3. Return to main menu'
end

def sleep_and_clear(timer)
  sleep(timer)
  system('clear')
end

def cls
  system('clear')
end

def get_choice(num)
  arr = Array(1..num)
  print "\nEnter your choice #{arr}: "
  choice = gets.to_i
  arr = Array(1..num)
  until arr.include? choice
    print "\nPlease enter a valid choice: "
    choice = gets.to_i
  end
  puts "\n\n"
  choice
end

def validate_signup(lines, type, username)
  flag = false
  lines.each do |line|
    arr = Array.new(line.split(','))
    if arr[2] == type && arr[3] == username
      flag = true
      break
    end
  end
  flag
end

def get_signup(type)
  return false unless %w[s t].include? type

  begin
    file_obj = File.open('credentials.csv', 'a+')
  rescue StandardError
    return false
  end
  lines = file_obj.readlines

  print 'Enter your name: '
  name = gets.chomp
  puts "\n"
  print 'Enter username: '
  username = gets.chomp

  while validate_signup(lines, type, username)
    puts "\n\tUsername you entered is not available!\n\n"
    print 'Enter new username: '
    username = gets.chomp
  end

  print 'Enter password: '
  password1 = gets.chomp
  print 'Confirm password: '
  password2 = gets.chomp
  failed_attempts = 0

  until password1 == password2
    failed_attempts += 1
    puts "Failed to sign up!\n" if failed_attempts > 2
    puts "Sorry, Passwords did not match!\n"
    print 'Please enter a new password: '
    password1 = gets.chomp
    print 'Confirm new password: '
    password2 = gets.chomp
  end
  count = 1
  lines.each do |line|
    arr = Array.new(line.split(','))
    count += 1 if arr[2] == type
  end
  file_obj.write("#{count},#{name},#{type},#{username},#{password1},\n")
  file_obj.close
  true
end

def get_credentials_details
  begin
    file_obj = File.open('credentials.csv', 'r')
  rescue StandardError
    return ''
  end
  lines = file_obj.readlines
  file_obj.close
  lines
end

def get_login(type, obj, lines, username, password)
  if lines.empty?
    puts "\n\n\tFailed to login!\n"
    sleep(2)
    return false
  end

  flag = false
  lines.each do |line|
    arr = Array.new(line.split(','))
    next unless arr[2] == type && arr[3] == username && arr[4] == password

    flag = true
    obj.id = arr[0]
    obj.name = arr[1]
    break
  end

  if flag
    puts "\n\n\tLogged in successsfully!\n\n"
  else
    puts "\n\n\tFailed to login!\n"
  end
  sleep(2)
  flag
end

def perform_teacher_actions(teacher, choice)
  flag = true
  case choice
  when 1
    teacher.create_quiz
  when 2
    teacher.edit_quiz
  when 3
    teacher.view_attempts
  when 4
    flag = false
    system('clear')
    puts "\nYou are logging out ...\n\n"
    sleep 2
  end
  flag
end

def perform_student_actions(student, choice)
  flag = true
  case choice
  when 1
    puts 'Attempted quiz successfuly!' if student.attempt_quiz
  when 2
    student.view_attempts
  when 3
    student.view_quizzes
  when 4
    flag = false
    puts "\nYou are logging out ...\n\n"
    sleep 2
  end
  flag
end

# main menu iteration method
def main
  main_menu_flag = true
  while main_menu_flag
    main_menu
    main_menu_choice = get_choice(3)

    puts "\n\n"

    if main_menu_choice == 1

      login_menu_flag = true
      while login_menu_flag
        login_menu
        login_menu_choice = get_choice(3)
        puts "\n"
        case login_menu_choice
        when 1
          teacher = Teacher.new
          teacher_menu_flag = false
          lines = get_credentials_details
          print 'Enter username: '
          username = gets.chomp
          print 'Enter password: '
          password = gets.chomp
          teacher_menu_flag = get_login('t', teacher, lines, username, password)
          while teacher_menu_flag
            system('clear')
            teacher.menu
            teacher_menu_flag = perform_teacher_actions(teacher, get_choice(4))
          end
        when 2
          student = Student.new
          lines = get_credentials_details
          print 'Enter username: '
          username = gets.chomp
          print 'Enter password: '
          password = gets.chomp
          student_menu_flag = get_login('s', student, lines, username, password)
          while student_menu_flag
            student.menu
            student_menu_flag = perform_student_actions(student, get_choice(4))
          end
        else
          login_menu_flag = false
          system('clear')
        end
      end

    elsif main_menu_choice == 2
      cls
      signup_menu
      signup_menu_choice = get_choice(3)

      case signup_menu_choice
      when 1
        puts "\nSigned up successfully as teacher.\n\n" if get_signup('t')
      when 2
        puts "\nSigned up successfully as student.\n\n" if get_signup('s')
      else
        puts "\nReturning to the main menu..."
      end
      sleep_and_clear 2

    elsif main_menu_choice == 3
      main_menu_flag = false
      system('clear')
      puts "\n\n\tYou exited the portal!\n\n"
      puts "\tHave a great day...\n\n"
      sleep_and_clear 2
    end
  end
end
