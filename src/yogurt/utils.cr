module Yogurt::Utils
  def self.input(prompt : String = String.new) : String
    String.new LibReadline.readline prompt
  end
end
