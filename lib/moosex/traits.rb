require 'delegate'

module MooseX
  module Traits
    class Counter < SimpleDelegator
      def initialize(value)
        @value = value
        super(@value)
      end

      def inc(by=1)
        @value += by
        __setobj__(@value)
        @value
      end
      
      def dec(by=1)
        @value -= by
        __setobj__(@value)
        @value        
      end

      def reset(to=0)
        @value = to
        __setobj__(@value)
        @value 
      end
    end

    class Pair < SimpleDelegator
      attr_reader :first, :second

      def initialize(pair)
        @first, @second = pair
        super([@first, @second ])
      end

      def first=(first_value)
        @first = first_value
        __setobj__([@first, @second ])
      end
      def second=(second_value)
        @second = second_value
        __setobj__([@first, @second ])
      end      
    end

    class Bool < SimpleDelegator
      def initialize(value)
        @value = value
        super(value)
      end  

      def toggle!
        @value = !@value
        __setobj__(@value)
      end

      def not
        ! @value
      end

      def set!
        @value = true
        __setobj__(@value)
      end

      def unset!
        @value = false
        __setobj__(@value)
      end
    end    
  end
end