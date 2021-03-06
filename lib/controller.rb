require_relative './models/user'
require_relative './models/location'
require_relative './models/order'
require_relative './view'

module GoCLI
  # Controller is a class that call corresponding models and methods for every action
  class Controller
    # This is an example how to create a registration method for your controller
    def registration(opts = {})
      # First, we clear everything from the screen
      clear_screen(opts)

      # Second, we call our View and its class method called "registration"
      # Take a look at View class to see what this actually does
      form = View.registration(opts)

      # This is the main logic of this method:
      # - passing input form to an instance of User class (named "user")
      # - invoke ".save!" method to user object
      # TODO: enable saving name and email
      user = User.new(
        name:    form[:name],
        email:    form[:email],
        phone:    form[:phone],
        password: form[:password]
      )

      if user.validate == true
        user.save!
        form[:user] = user
        form
      else
        form[:flash_msg] = 'Form cannot be empty.'
        registration(form)
      end
    end

    def login(opts = {})
      halt = false
      while !halt
        clear_screen(opts)
        form = View.login(opts)
        # Check if user inputs the correct credentials in the login form
        if credential_match?(form[:user], form[:login], form[:password])
          halt = true
        else
          form[:flash_msg] = 'Wrong login or password combination'
        end
      end
      return form
    end

    def main_menu(opts = {})
      clear_screen(opts)
      form = View.main_menu(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1
        view_profile(form)
      when 2
        # Step 4.2
        order_goride(form)
      when 3
        # Step 4.3
        view_order_history(form)
      when 4
        exit(true)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        main_menu(form)
      end
    end

    def view_profile(opts = {})
      clear_screen(opts)
      form = View.view_profile(opts)

      case form[:steps].last[:option].to_i
      when 1
        # Step 4.1.1
        edit_profile(form)
      when 2
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        view_profile(form)
      end
    end

    # TODO: Complete edit_profile method
    # This will be invoked when user choose Edit Profile menu in view_profile screen
    def edit_profile(opts = {})
      clear_screen(opts)
      form = View.edit_profile(opts)

      case form[:steps].last[:option].to_i
      when 1
        user = User.new(
          name:    form[:name],
          email:    form[:email],
          phone:    form[:phone],
          password: form[:password]
        )

        if user.validate == true
          user.save!
          form[:user] = user
          view_profile(form)
        else
          form[:flash_msg] = 'Form cannot be empty.'
          edit_profile(form)
        end
      when 2
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        edit_profile(form)
      end
      form
    end

    # TODO: Complete order_goride method
    def order_goride(opts = {})
      clear_screen(opts)
      form = View.order_goride(opts)
      form[:loc1] = Location.find(form[:order_location])
      form[:loc2] = Location.find(form[:order_destination])

      if (form[:loc1] == false || form[:loc2] == false)
        form[:flash_msg] = 'Sorry our services for your location not available'
        order_goride(form)

      elsif (['1', '2'].include?(form[:service]) == false)
        form[:flash_msg] = 'Please input a valid service number'
        order_goride(form)

      elsif (form[:loc1].is_a?(Location) && form[:loc2].is_a?(Location))
        price = 0
        if form[:service] == '1'
          price = 1500
        elsif form[:service] == '2'
          price = 2500
        end

        form[:order_price] = ((Location.length(form[:loc1], form[:loc2]) * price).round)
      end

      order_goride_confirm(form)
    end

    def order_goride_confirm(opts = {})
      clear_screen(opts)
      form = View.order_goride_confirm(opts)

      case form[:steps].last[:option].to_i
      when 1
        nearest_driver = find_driver(form)
        if nearest_driver[1] <= 1.0
          # puts "mr #{nearest_driver[0]} akan mengantar anda"
          form[:driver] = nearest_driver[0]
          order = Order.new(form[:order_location], form[:order_destination], form[:order_price])
          order.insert_order
          form[:flash_msg] = "Order Complete #{form[:driver]} will drive you to #{form[:order_destination]}"
          Location.move_driver(form[:driver], form[:loc2])
          order_goride_complete(form)
        else
          form[:flash_msg] = 'Sorry we cant find a driver right now.'
          order_goride_complete(form)
        end

      when 2
        order_goride(form)
      when 3
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        order_goride_confirm(form)
      end
      form
    end

    def order_goride_complete(opts = {})
      clear_screen(opts)
      form = View.order_goride_complete(opts)

      case form[:steps].last[:option].to_i
      when 1
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        order_goride_complete(form)
      end
      form
    end

    def find_driver(opts = {})
      form = opts
      all_driver = Location.get_driver

      go_type = ''
      if form[:service] == '1'
        go_type = 'gojek'
      elsif form[:service] == '2'
        go_type = 'gocar'
      end

      vehicle = []
      all_driver.each do |d|
        vehicle << d if d['type'] == go_type
      end

      hsh = {}
      vehicle.each do |d|
        hsh[d['driver']] = Location.new(d['coord'][0], d['coord'][1])
      end
      driver_length = {}
      hsh.each do |k, v|
        driver_length[k] = Location.length(form[:loc1], v)
      end
      nearest = driver_length.min_by { |k, v| v }
      nearest
    end

    def view_order_history(opts = {})
      clear_screen(opts)
      form = opts
      form[:all_orders] = Order.get_all_orders
      form = View.view_order_history(form)
      case form[:steps].last[:option].to_i
      when 1
        main_menu(form)
      else
        form[:flash_msg] = 'Wrong option entered, please retry.'
        view_order_history(form)
      end
    end

    protected

      # You don't need to modify this
    def clear_screen(opts = {})
      Gem.win_platform? ? (system "cls") : (system "clear")
      if opts[:flash_msg]
        puts opts[:flash_msg]
        puts ''
        opts[:flash_msg] = nil
      end
    end

    # TODO: credential matching with email or phone
    def credential_match?(user, login, password)
      return false unless user.email == login || user.phone == login
      return false unless user.password == password
      return true
    end
  end
end
