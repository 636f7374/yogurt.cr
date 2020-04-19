module Yogurt::CommandLine
  def self.create(config : Config) : Nil
    return create_secure_id if config.createFlag.secure_id?

    # Create SecretKey & UserName
    master_key, secure_id = get_master_key_secure_id config
    secret_key = create_secret_key master_key, secure_id, config
    __pin_code = create_pin secret_key, secure_id, config
    _user_name = create_user_name secret_key, secure_id, config

    # Create Email Address & Pin Code
    _user_name.try do |_name|
      create_email _name, secure_id, config
    end

    nil
  end

  def self.get_input_master_key(config : Config) : String
    value = Utils::Secret.gets prompt: "Enter MasterKey: "

    value
  end

  def self.get_input_secure_id(config : Config) : String
    return Utils.input prompt: "Enter Secure_Id: " if config.titleFlag.secure_id?

    value = Yogurt.create_secure_id get_input_title_name
    Render.secure_id text: value

    value
  end

  def self.get_input_title_name : String
    value = Utils.input prompt: "Enter TitleName: "

    value
  end

  def self.get_master_key_secure_id(config : Config) : Tuple(String, String)
    master_key = get_input_master_key config
    _secure_id = get_input_secure_id config

    Tuple.new master_key, _secure_id
  end

  def self.create_secure_id : Nil
    input = get_input_title_name
    value = Yogurt.create_secure_id input

    Render.secure_id text: value
    value
  end

  def self.create_secret_key(master_key, secure_id, config : Config) : String
    callback = ->(time : Int64, value : String) { Render.secret_key text: value, print: true, clean: true }
    value = Yogurt.create_secret_key master_key, secure_id, config.length, config.iterations,
      with_symbol: config.withSymbol, callback: callback

    Render.secret_key text: value, print: false, clean: true
    value
  end

  def self.create_user_name(secret_key, secure_id, config : Config) : String?
    return unless user_name = config.userName

    callback = ->(time : Int64, value : String) { Render.user_name text: value, print: true, clean: true }
    value = Yogurt.create_user_name secret_key, secure_id, user_name.length, user_name.iterations, callback: callback

    Render.user_name text: value, print: false, clean: true
    value
  end

  def self.create_email(secret_key, secure_id, config : Config) : String?
    return unless email = config.emailAddress

    callback = ->(time : Int64, value : String) { Render.email text: value, print: true, clean: true }
    value = Yogurt.create_email email.domain, secret_key, secure_id, email.length, email.iterations, callback: callback

    Render.email text: value, print: false, clean: true
    value
  end

  def self.create_pin(secret_key, secure_id, config : Config) : String?
    return unless pin_code = config.pinCode

    callback = ->(time : Int64, value : String) { Render.pin_code text: value, print: true, clean: true }
    value = Yogurt.create_pin secret_key, secure_id, pin_code.iterations

    Render.pin_code text: value, print: false, clean: true
    value
  end
end
