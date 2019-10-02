class Integer

  # todo: complete
  def human_ordinalize(map={})
    map.key?(self) ? map[self] : (begin
      if self < -1
        "#{(-self).human_ordinalize} to last"
      else
        case self
        when -1;  "last"
        when 1;   "first"
        when 2;   "second"
        when 3;   "third"
        when 4;   "fourth"
        when 5;   "fifth"
        when 6;   "sixth"
        when 7;   "seventh"
        when 8;   "eighth"
        when 9;   "ninth"
        when 10;  "tenth"
        when 11;  "eleventh"
        when 12;  "twelfth"
        when 13;  "thirteenth"
        when 14;  "fourteenth"
        when 15;  "fifteenth"
        when 16;  "sixteenth"
        when 17;  "seventeeth"
        when 18;  "eighteenth"
        when 19;  "nineteenth"
        when 20;  "twentieth"
        else;     self.ordinalize
        end
      end
    end)
  end

end
