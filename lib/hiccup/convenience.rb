module Hiccup
  module Convenience


    def never?
      kind == :never
    end

    def weekly?
      kind == :weekly
    end

    def monthly?
      kind == :monthly
    end

    def annually?
      kind == :annually
    end


    def ends?
      return %w{true 1 t}.member?(ends) if ends.is_a?(String)
      !!ends
    end


  end
end
