module Yogurt
  UUID_REGEX       = /(.{8})(.{4})(.{4})(.{4})(.{12})/
  UUID_REPLACEMENT = "\\1-\\2-\\3-\\4-\\5"
  UPPERCASE_RANGES = [{'A', 'Z', false}, {'Z', 'A', true}]
  LOWERCASE_RANGES = [{'a', 'z', false}, {'z', 'a', true}]
  SYMBOL_RANGES    = [{'!', '/', false}, {'@', ':', true}]
  NUMBER_RANGES    = [{'0', '9', false}, {'9', '0', true}]
  ILLEGAL_SYMBOLS  = ['"', '\'', '/', '\\']

  enum CharacterCast : UInt8
    LowercaseToUppercase = 0_u8
    LowercaseToSymbol    = 1_u8
    LowercaseToNumber    = 2_u8
    UppercaseToLowercase = 3_u8
    UppercaseToSymbol    = 4_u8
    UppercaseToNumber    = 5_u8
    NumberToLowercase    = 6_u8
    NumberToUppercase    = 7_u8
    NumberToSymbol       = 8_u8
  end

  class BadCreate < Exception
  end

  # Calculate over or under Multiple of four Characters (I.e. Number, Lowercase, Uppercase, Symbol).
  # Yogurt.total "abcd" => {-1, 3, -1, -1}.
  # Negative numbers are missing quantities, positive numbers are excess quantities.

  def self.total(text : String, space : Int32 = 1_i32) : Tuple(Int32, Int32, Int32, Int32)
    ___number = text.scan(/[0-9]/).size
    lowercase = text.scan(/[a-z]/).size
    uppercase = text.scan(/[A-Z]/).size

    Tuple.new ___number - space, lowercase - space, uppercase - space,
      text.size - space - (___number + lowercase + uppercase)
  end

  # Get the center left and right offset value
  # (E.g. Full length: 10, limit: 5 => 1 2 [3 4 5 6 7] 8 9 10)

  def self.center(full : Int32, limit : Int32) : Tuple(Int32, Int32)
    _left = (full - limit) / 2_i32
    right = full - _left

    differ = right - _left + 1_i32 - limit

    right -= 1_i32 if 2_i32 > differ
    right -= 2_i32 if 2_i32 <= differ

    Tuple.new Int32.new(_left), Int32.new(right)
  end

  def self.center(text : String, limit : Int32) : Tuple(Int32, Int32)
    center text.size, limit
  end

  def self.cast_to_ranges(cast : CharacterCast, with_symbol : Bool) : Array(Tuple(Char, Char, Bool))?
    case cast
    when .lowercase_to_uppercase?
      UPPERCASE_RANGES
    when .lowercase_to_symbol?
      with_symbol ? SYMBOL_RANGES : NUMBER_RANGES
    when .lowercase_to_number?
      NUMBER_RANGES
    when .uppercase_to_lowercase?
      LOWERCASE_RANGES
    when .uppercase_to_symbol?
      with_symbol ? SYMBOL_RANGES : NUMBER_RANGES
    when .uppercase_to_number?
      NUMBER_RANGES
    when .number_to_uppercase?
      UPPERCASE_RANGES
    when .number_to_lowercase?
      LOWERCASE_RANGES
    when .number_to_symbol?
      with_symbol ? SYMBOL_RANGES : LOWERCASE_RANGES
    end
  end

  def self.cast_character(tuple : Tuple(Array(Char), Int32), cast : CharacterCast, with_symbol : Bool)
    character = tuple.first[tuple.last]
    return character unless ranges = cast_to_ranges cast, with_symbol

    # Calculation
    characters_sum = (tuple.first.map &.ord).sum
    tuple_range = characters_sum.even? ? ranges.first : ranges.last
    left_range, right_range, reverse = tuple_range

    # Calculation
    _left = -(character - left_range)
    right = -(character - right_range)
    range = reverse ? (right.._left) : (_left..right)
    width = range.size

    # (E.g. CharacterOrd: 11, Width: 7,  Result: 2)
    # 0  1  2  3  4  5  6  7
    # 0  1 [2]
    offset = character.ord - ((character.ord // width) * width)
    offset = width if offset.zero?

    # Because it is an array (starting at zero), So subtract one.
    offset -= 1_i32

    # Iterator
    iterator = reverse ? range.reverse_each : range

    iterator.each_with_index do |ord, index|
      next unless index == offset
      offset_character = character + ord

      break offset_character unless ILLEGAL_SYMBOLS.includes? offset_character

      offset_character = offset_character - 1_i32
      break offset_character unless ILLEGAL_SYMBOLS.includes? offset_character

      offset_character = offset_character + 2_i32
      break offset_character unless ILLEGAL_SYMBOLS.includes? offset_character

      break character
    end
  end

  def self.fill_text(text : String, with_symbol : Bool = true) : String
    text.chars.each_slice(4_i32).map do |slice|
      number, lowercase, uppercase, symbol = total slice.join

      slice.each_with_index.map do |characters|
        tuple = Tuple.new slice, characters.last

        case {lowercase > 0_i32, uppercase, symbol, number}
        when {true, -1_i32, symbol, number}
          lowercase -= 1_i32
          uppercase += 1_i32

          next cast_character tuple, CharacterCast::LowercaseToUppercase, with_symbol
        when {true, uppercase, -1_i32, number}
          lowercase -= 1_i32
          symbol += 1_i32

          next cast_character tuple, CharacterCast::LowercaseToSymbol, with_symbol
        when {true, uppercase, symbol, -1_i32}
          lowercase -= 1_i32
          number += 1_i32

          next cast_character tuple, CharacterCast::LowercaseToNumber, with_symbol
        else
        end

        case {uppercase > 0_i32, lowercase, symbol, number}
        when {true, -1_i32, symbol, number}
          uppercase -= 1_i32
          lowercase += 1_i32

          next cast_character tuple, CharacterCast::UppercaseToLowercase, with_symbol
        when {true, lowercase, -1_i32, number}
          uppercase -= 1_i32
          symbol += 1_i32

          next cast_character tuple, CharacterCast::UppercaseToSymbol, with_symbol
        when {true, lowercase, symbol, -1_i32}
          uppercase -= 1_i32
          number += 1_i32

          next cast_character tuple, CharacterCast::UppercaseToNumber, with_symbol
        else
        end

        case {number > 0_i32, uppercase, symbol, lowercase}
        when {true, -1_i32, symbol, lowercase}
          number -= 1_i32
          uppercase += 1_i32

          next cast_character tuple, CharacterCast::NumberToUppercase, with_symbol
        when {true, uppercase, symbol, -1_i32}
          number -= 1_i32
          lowercase += 1_i32

          next cast_character tuple, CharacterCast::NumberToLowercase, with_symbol
        when {true, uppercase, -1_i32, lowercase}
          number -= 1_i32
          symbol += 1_i32

          next cast_character tuple, CharacterCast::NumberToSymbol, with_symbol
        else
        end

        next characters.first
      end.join
    end.join
  end

  def self.create_secure_id(value : String, length : Int32 = 32_i32)
    sha384_digest = OpenSSL::Digest.new "sha384"
    sha384_digest.update value
    value = sha384_digest.final.hexstring

    left, right = center value, length
    value[left..right].gsub(UUID_REGEX, UUID_REPLACEMENT).upcase
  end

  def self.create_email(domain : String, user_name : String, secure_id : String, length : Int32 = 15_i32, iterations : Int64 = 131072_i64,
                        pbkdf2_iterations : Int64 = 2_i64 ** 5_i64, callback : Proc(Int64, String, Nil)? = nil) : String
    mixed = String.build { |io| io << "emailAddress" << ":" << domain << ":" << user_name }
    value = create_secret_key mixed, secure_id, length, iterations, false, pbkdf2_iterations, callback: callback

    String.build { |io| io << format_user_name(value) << "@" << domain }
  end

  def self.format_user_name(text : String) : String
    text = text.downcase.chars
    start = text[0_i32..3_i32].sort_by { |character| -(character.ord) }
    text.delete_at 0_i32..3_i32

    String.build { |io| io << start.join << text.join }
  end

  def self.create_user_name(secret_key : String, secure_id : String, length : Int32 = 15_i32, iterations : Int64 = 131072_i64,
                            pbkdf2_iterations : Int64 = 2_i64 ** 5_i64, callback : Proc(Int64, String, Nil)? = nil) : String
    mixed = String.build { |io| io << "userName" << ":" << secret_key }
    value = create_secret_key mixed, secure_id, length, iterations, false, pbkdf2_iterations, callback: callback

    format_user_name value
  end

  def self.create_pin(secret_key : String, secure_id : String, iterations : Int64 = 131072_i64, pbkdf2_iterations : Int64 = 2_i64 ** 5_i64) : String
    mixed = String.build { |io| io << "pinCode" << ":" << secret_key }
    value = create_secret_key mixed, secure_id, 20_i32, iterations, false, pbkdf2_iterations

    adler32_master_key = Digest::Adler32.checksum data: value
    adler32_master_key = adler32_master_key.to_s
    left, right = center adler32_master_key.size, 6_i32

    adler32_master_key[left..right]
  end

  def self.create_secret_key(master_key : String, secure_id : String, length : Int32 = 20_i32, iterations : Int64 = 131072_i64,
                             with_symbol : Bool = true, pbkdf2_iterations : Int64 = 2_i64 ** 5_i64,
                             callback : Proc(Int64, String, Nil)? = nil) : String
    raise BadCreate.new "length" if length.zero? || 50_i32 < length
    raise BadCreate.new "iterations" if iterations.zero?

    # Create Blake2B512 & HMAC Offset
    __blake2b512_offset = Offset.new Offset::Operator::Increase
    hmac_message_offset = Offset.new Offset::Operator::Decrease

    # Adler32 SecureId
    adler32_secure_id = Digest::Adler32.checksum data: secure_id
    adler32_secure_id_hexadecimal = adler32_secure_id.to_s 16_i32

    # Duplicate MasterKey
    secret_key = master_key.dup

    # Iterative
    iterations.times do |time|
      # Blake2B512 MasterKey
      blake2b512_master_key = OpenSSL::Digest.new(name: "blake2b512").update data: secret_key
      blake2b512_master_key = Base64.strict_encode blake2b512_master_key.final
      blake2b512_message = String.build { |io| io << blake2b512_master_key << ":" << adler32_secure_id }

      # Standard HMAC Message
      standard_hmac = OpenSSL::HMAC.base64digest algorithm: OpenSSL::Algorithm::SHA512,
        key: __blake2b512_offset.fetch(blake2b512_message), data: adler32_secure_id_hexadecimal
      _hmac_message = String.build { |io| io << adler32_secure_id << ":" << standard_hmac }

      # PKCS5 Pbkdf2 HMAC
      pbkdf2_hmac = OpenSSL::PKCS5.pbkdf2_hmac secret: hmac_message_offset.fetch(_hmac_message),
        salt: blake2b512_message, iterations: pbkdf2_iterations, algorithm: OpenSSL::Algorithm::SHA512

      # Update Blake2B512 Offset
      __blake2b512_offset.update blake2b512_message if time.zero?
      time.zero? ? __blake2b512_offset.touch! : __blake2b512_offset.touch

      # Update Pbkdf2 HMAC Offset
      hmac_message_offset.update pbkdf2_hmac.hexstring if time.zero?
      time.zero? ? hmac_message_offset.touch! : hmac_message_offset.touch

      # Result
      secret_key = Base64.strict_encode(String.new pbkdf2_hmac).delete &.in?('=', '/', '+')
      _master_key_left, _master_key_right = center secret_key, length
      secret_key = fill_text secret_key[_master_key_left.._master_key_right], with_symbol

      callback.try &.call time, secret_key
    end

    secret_key
  end
end
