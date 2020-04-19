class Yogurt::Config
  property iterations : Int64
  property createFlag : CreateFlag
  property titleFlag : TitleFlag
  property withSymbol : Bool
  property length : Int32
  property pinCode : PinCode?
  property emailAddress : EmailAddress?
  property userName : UserName?
  property showMasterKey : Bool?

  enum TitleFlag : UInt8
    Title    = 0_u8
    SecureId = 1_u8
  end

  enum CreateFlag : UInt8
    Default  = 0_u8
    SecureId = 1_u8
  end

  def initialize
    @iterations = 131072_i64
    @createFlag = CreateFlag::Default
    @titleFlag = TitleFlag::Title
    @withSymbol = true
    @length = 20_i32
    @pinCode = nil
    @emailAddress = nil
    @userName = nil
    @showMasterKey = false
  end

  def self.parse(args : Array(String))
    config = new
    config.parse args

    config
  end

  def parse(args : Array(String))
    OptionParser.parse args do |parser|
      parser.on("-i +", "--iterations +", "Specify the number of Iterations (E.g. 16384, 32768)") do |value|
        abort "> Invalid iterations." unless iterations = value.to_i?
        abort "> The number of iterations cannot be less than zero." if iterations.zero? || 0_i32 > iterations

        @iterations = iterations.to_i64
      end

      parser.on("--username +", "Create UserName (E.g. 16384:12, 32768:15)") do |value|
        iterations, delimiter, length = value.rpartition ":"

        abort "> Invalid iterations." unless _iterations = iterations.to_i?
        abort "> Invalid length." unless _length = length.to_i?
        abort "> The number of iterations cannot be less than zero." if _iterations.zero? || 0_i32 > _iterations
        abort "> The number of length cannot be less than zero." if _length.zero? || 0_i32 > _length
        abort "> The maximum length cannot exceed 50." if 50_i32 < _length

        user_name = UserName.new
        user_name.iterations = _iterations.to_i64
        user_name.length = _length

        @userName = user_name
      end

      parser.on("--email +", "Create Email Address (E.g. 16384:12:example.com)") do |value|
        iterations_length, delimiter, domain = value.rpartition ":"
        iterations, delimiter, length = iterations_length.rpartition ":"

        abort "> Invalid iterations." unless _iterations = iterations.to_i?
        abort "> Invalid length." unless _length = length.to_i?
        abort "> The number of iterations cannot be less than zero." if _iterations.zero? || 0_i32 > _iterations
        abort "> The number of length cannot be less than zero." if _length.zero? || 0_i32 > _length
        abort "> The maximum length cannot exceed 50." if 50_i32 < _length

        email_address = EmailAddress.new
        email_address.iterations = _iterations.to_i64
        email_address.length = _length
        email_address.domain = domain

        @emailAddress = email_address
      end

      parser.on("--pin-code + ", "Create Secure PIN Code (E.g. 16384)") do |value|
        abort "> Invalid iterations." unless iterations = value.to_i?
        abort "> The number of iterations cannot be less than zero." if iterations.zero? || 0_i32 > iterations

        pin_code = PinCode.new
        pin_code.iterations = iterations.to_i64

        @pinCode = pin_code
      end

      parser.on("--show-master-key", "Display the inputted MasterKey value") do
        @showMasterKey = true
      end

      parser.on("--create-secure-id", "Switch to creating SecureId only") do
        @createFlag = CreateFlag::SecureId
      end

      parser.on("--by-secure-id", "Use SecureId instead of TitleName") do
        @titleFlag = TitleFlag::SecureId
      end

      parser.on("--without-symbol", "Generate SecretKey without Symbol (Reduce Security)") do
        @withSymbol = true
      end

      parser.on("-l +", "--length +", "Specify the length of SecretKey (Between 10 To 50)") do |value|
        abort "> Invalid length" unless length = value.to_i?
        abort "> The number of length cannot be less than zero." if length.zero? || 0_i32 > length
        abort "> The maximum length cannot exceed 50." if 50_i32 < length

        @length = length
      end
    end
  end

  class UserName
    property iterations : Int64
    property length : Int32
    property domain : String

    def initialize
      @iterations = 16384_i32
      @length = 15_i32
      @domain = String.new
    end
  end

  class PinCode
    property iterations : Int64

    def initialize
      @iterations = 16384_i32
    end
  end

  class EmailAddress < UserName
    property domain : String

    def initialize
      @iterations = 16384_i32
      @length = 15_i32
      @domain = String.new
    end
  end
end
