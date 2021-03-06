module GoCLI
  # View is a class that show menus and forms to the screen
  class View
    # This is a class method called ".registration"
    # It receives one argument, opts with default value of empty hash
    # TODO: prompt user to input name and email
    def self.registration(opts = {})
      form = opts

      puts 'Registration'
      puts ''

      print 'Your Name: '
      form[:name] = gets.chomp

      print 'Your Email: '
      form[:email] = gets.chomp

      print 'Your phone: '
      form[:phone] = gets.chomp

      print 'Your password: '
      form[:password] = gets.chomp

      form[:steps] << { id: __method__ }

      form
    end

    def self.login(opts = {})
      form = opts

      puts 'Login'
      puts ''

      print 'Enter your Phone Number or Email: '
      form[:login] = gets.chomp

      print 'Enter your password: '
      form[:password] = gets.chomp

      form[:steps] << { id: __method__ }

      form
    end

    def self.main_menu(opts = {})
      form = opts

      puts 'Welcome to Go-CLI!'
      puts ''

      puts 'Main Menu'
      puts '1. View Profile'
      puts '2. Order Go-Ride'
      puts '3. View Order History'
      puts '4. Exit'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    # TODO: Complete view_profile method
    def self.view_profile(opts = {})
      form = opts

      puts 'View Profile'
      puts ''

      # Show user data here

      puts "name : #{form[:user].name}"
      puts "email : #{form[:user].email}"
      puts "phone : #{form[:user].phone}"
      puts "password : #{form[:user].password}"

      puts ''

      puts '1. Edit Profile'
      puts '2. Back'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    # TODO: Complete edit_profile method
    # This is invoked if user chooses Edit Profile menu when viewing profile
    def self.edit_profile(opts = {})
      form = opts

      puts 'Edit Profile'
      puts ''
      print 'Your Name: '
      form[:name] = gets.chomp

      print 'Your Email: '
      form[:email] = gets.chomp

      print 'Your phone: '
      form[:phone] = gets.chomp

      print 'Your password: '
      form[:password] = gets.chomp

      puts ''

      puts '1. Save Profile'
      puts '2. Discard'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }

      form
    end

    # TODO: Complete order_goride method
    def self.order_goride(opts = {})
      form = opts

      puts 'Order a Go-Ride'
      puts ''

      print 'Service : 1. Go-Jek  2. Go-Car'
      puts ''
      form[:service] = gets.chomp

      print 'Your Location: '
      form[:order_location] = gets.chomp

      print 'Your destination: '
      form[:order_destination] = gets.chomp
      form
    end

    # TODO: Complete order_goride_confirm method
    # This is invoked after user finishes inputting data in order_goride method
    def self.order_goride_confirm(opts = {})
      form = opts
      
      puts "Go-Ride from #{form[:order_location]} to #{form[:order_destination]}"
      puts 'Your order price'
      puts "Rp #{form[:order_price]}"
      puts ''
      puts '1. Confirm order'
      puts '2. Reset '
      puts '3. Cancel'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }
      form
    end

    def self.order_goride_complete(opts = {})
      form = opts

      puts '1. main menu'

      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }
      form
    end

    # TODO: Complete view_order_history method
    def self.view_order_history(opts = {})
      require 'date'
      form = opts
      i = 1
      form[:all_orders].each do |e|
        d = DateTime.parse(e['timestamp'])
        puts "|#{i}|time: #{d.strftime('%d-%m-%Y %H:%M')} | from: #{e['origin']} --> to: #{e['destination']} | price: Rp #{e['est_price']}"
        i += 1
      end

      puts '1. Back'
      print 'Enter your option: '
      form[:steps] << { id: __method__, option: gets.chomp }
      form
    end
  end
end
