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
      (ends == true) || %w{true 1 t}.member?(ends)
    end
    
    
  end
end
