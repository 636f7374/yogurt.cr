class Yogurt::Offset
  enum Operator : Int32
    Increase =  1_i32
    Decrease = -1_i32
  end

  property operator : Operator
  property left : Int32
  property right : Int32
  property all : Int32

  def initialize(@operator : Operator = Operator::Increase)
    @left = 0_i32
    @right = 0_i32
    @all = 0_i32
  end

  def update(value : String) : Bool?
    return nil unless all.zero?

    update! value
  end

  def update!(value : String) : Bool
    self.left = 0_i32
    self.right = (value.size / 2_i32).to_i32
    self.all = value.size

    true
  end

  def touch : Bool?
    return nil if all.zero?
    self.operator = Operator::Decrease if operator.increase? && right == all
    self.operator = Operator::Increase if operator.decrease? && left.zero?

    touch!
  end

  def touch! : Bool
    self.left += operator.to_i
    self.right += operator.to_i

    true
  end

  def fetch(value : String) : String
    return value if all.zero?
    update! value if value[left]?.nil? || value[right]?.nil?

    value[left..right]
  end
end
