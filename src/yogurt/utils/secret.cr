module Yogurt::Utils
  module Secret
    enum KeyFlag
      Delete
      REnter
      NEnter
      Left
      Right
      Up
      Down
      Exit
      Typing
    end

    def self.gets(prompt : String = String.new, hint : String = "*", empty_warning : String? = nil, retry : Int32? = nil) : String
      print prompt
      input = [] of String
      counter = 0_i32

      loop do
        typing = stdin_gets
        action = to_action typing

        case action
        when .delete?
          next if input.empty?

          input.pop

          # Masked
          print String.build { |io| io << '\u{8}' << ' ' << '\u{8}' }
        when .exit?
          abort "\n"
        when .n_enter?
          break unless input.empty?
          break if retry <= counter if retry

          puts empty_warning if empty_warning
          counter += 1_i32
        when .r_enter?
          break unless input.empty?
          break if retry <= counter if retry

          puts empty_warning if empty_warning
          counter += 1_i32
        else
          input << typing
          print hint * typing.size
        end
      end

      puts
      input.join
    end

    def self.to_action(input : String)
      return KeyFlag::Exit if input.empty?

      case input
      when "\u007F"
        KeyFlag::Delete
      when "\e[D"
        KeyFlag::Left
      when "\e[C"
        KeyFlag::Right
      when "\e[A"
        KeyFlag::Up
      when "\e[B"
        KeyFlag::Down
      when "\r", "\r\r", "\r\r\r"
        KeyFlag::REnter
      when "\n", "\n\n", "\n\n\n"
        KeyFlag::NEnter
      when "\u0003"
        KeyFlag::Exit
      else
        KeyFlag::Typing
      end
    end

    def self.stdin_gets : String
      buffer = uninitialized UInt8[3_i32]

      STDIN.raw do |io|
        length = io.read buffer.to_slice
        String.new buffer.to_slice[0_i32, length]
      end
    end
  end
end
