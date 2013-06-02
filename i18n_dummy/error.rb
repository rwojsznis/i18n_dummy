module I18nDummy
  class Error < Exception
    attr_accessor :msg

    def initialize(msg)
      @msg = msg
    end

    def to_s
      msg
    end
  end
end