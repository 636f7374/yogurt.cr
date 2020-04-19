module Yogurt::CommandLine
  module Render
    def self.secure_id(text : String)
      STDOUT.puts String.build { |io| io << "Secure_Id" << ": " << "[" << text << "]" }
    end

    def self.master_key(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "MasterKey" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end

    def self.title_name(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "TitleName" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end

    def self.secret_key(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "SecretKey" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end

    def self.user_name(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "User_Name" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end

    def self.email(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "__Email__" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end

    def self.pin_code(text : String, print : Bool = false, clean : Bool = false)
      value = String.build do |io|
        io << "\r" if clean
        io << "_PinCode_" << ": " << "[" << text << "]"
      end

      print ? STDOUT.print(value) : STDOUT.puts(value)
    end
  end
end
