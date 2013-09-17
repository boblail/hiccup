module Hiccup
  module Inferable
    
    class Score < Struct.new(:prediction_rate, :brick_rate, :complexity_rate)
      
      # as brick rate rises, our confidence in this guess drops
      def brick_penalty
        brick_penalty = brick_rate * 0.33
        brick_penalty = 1 if brick_penalty > 1
        brick_penalty
      end
      
      # as the complexity rises, our confidence in this guess drops
      # this hash table is a stand-in for a proper formala
      #
      # A complexity of 1 means that 1 rule is required per input
      # date. This means we haven't really discovered a pattern.
      def complexity_penalty
        complexity_rate
      end
      
      # our confidence is weakened by bricks and complexity
      def confidence
        confidence = 1.0
        confidence *= (1 - brick_penalty)
        confidence *= (1 - complexity_penalty)
        confidence
      end
      
      # a number between 0 and 1
      def to_f
        prediction_rate * confidence
      end
      
    end
    
  end
end
