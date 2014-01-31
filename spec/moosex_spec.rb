#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'moosex'

class Point
	include MooseX
	
	has :x , {
		:is => :rw,
		:isa => Integer,
		:default => 0,
	}

	has :y , {
		:is => :rw,
		:isa => Integer,
		:default => lambda { 0 },
	}
	
	def clear 
		self.x= 0
		self.y= 0
	end
end

class Foo
	include MooseX

	has :bar, {
		:is => :rwp,
		:isa => Integer,
		:required => true
	}
end

class Baz
	include MooseX

	has :bam, {
		:is => :ro,
		:isa => lambda {|bam| raise 'bam should be less than 100' if bam > 100},
		:required => true
	}
	has :boom, {
		:is => :rw,
		:predicate => true,
		:clearer => true,
	}
end

class Lol 
	include MooseX

	has [:a, :b], {
		:is => :ro,
		:default => 0,		
	}

	has :c => {
		:is => :ro,
		:default => 1,
		:predicate => :has_option_c?,
		:clearer => "reset_option_c", # force coerce
	}

	has [:d, :e] => {
		:is => "ro",
		:default => 2,		
	}	
end

class Target 
	def method_x
		1024
	end

	def method_y(a,b,c)
		a + b + c
	end
end

class Proxy
	include MooseX

	has :target, {
		:is => :ro,
		:isa => Target,
		:default => lambda { Target.new() },
		:handles => {
			:my_method_x => :method_x,
			:my_method_y => :method_y,	
		},
	}
end

describe "Proxy" do
	it "should delegate method_x to the target" do
		p = Proxy.new

		p.target.method_x.should == 1024
		p.my_method_x.should == 1024
	end

	it "should delegate method_y to the target" do
		p = Proxy.new

		p.target.method_y(1,2,3).should == 6
		p.my_method_y(1,2,3).should == 6
	end	
end

describe "Point" do
	describe "should has an intelligent constructor" do
		it "without arguments, should initialize with default values" do
			p = Point.new
			p.x.should be_zero
			p.y.should be_zero
		end
	
		it "should initialize only y" do
			p = Point.new( :x => 5 )
			p.x.should == 5
			p.y.should be_zero
		end
	
		it "should initialize x and y" do
			p = Point.new( :x => 5, :y => 4)
			p.x.should == 5
			p.y.should == 4
		end
	end
	
	describe "should create a getter and a setter" do
		it "for x" do
			p = Point.new
			p.x= 5
			p.x.should == 5
		end		
		
		it "for x, with type check" do
			p = Point.new
			expect { 
				p.x = "lol" 
			}.to raise_error('isa check for "x" failed: is not instance of Integer!')
		end	
		
		it "for x, with type check" do			
			expect { 
				Point.new(:x => "lol") 
			}.to raise_error('isa check for "x" failed: is not instance of Integer!')
		end	

		it "clear should clean attributes" do
			p = Point.new( :x => 5, :y => 4)
			p.clear
			p.x.should be_zero
			p.y.should be_zero			
		end	
	end	
end

describe "Foo" do
	it "should require bar if necessary" do 
		expect {
			Foo.new
		}.to raise_error("attr \"bar\" is required")
	end

	it "should require bar if necessary" do 
		foo = Foo.new( :bar => 123 )
		foo.bar.should == 123
	end

	it "should not be possible update bar (setter private)" do 
		foo = Foo.new( :bar => 123 )
		expect {
			foo.bar = 1024
		}.to raise_error(NoMethodError)
	end
end 

describe "Baz" do
	it "should require bam if necessary" do 
		baz = Baz.new( :bam => 99 )
		baz.bam.should == 99
	end

	it "should not be possible update baz (read only)" do 
		baz = Baz.new( :bam => 99 )
		expect {
			baz.bam = 1024
		}.to raise_error(NoMethodError)
	end

	it "should run the lambda isa" do 
		expect {
			Baz.new( :bam => 199 )
		}.to raise_error(/bam should be less than 100/)
	end

	it "rw acessor should has nil value, supports predicate" do
		baz = Baz.new( :bam => 99 )
		
		baz.has_boom?.should be_false
		baz.boom.should be_nil
		baz.boom= 0
		baz.has_boom?.should be_true
		baz.boom.should be_zero
	end

	it "rw acessor should has nil value, supports clearer" do
		baz = Baz.new( :bam => 99, :boom => 0 )
		
		baz.has_boom?.should be_true
		baz.boom.should be_zero
		
		baz.reset_boom!

		baz.has_boom?.should be_false
		baz.boom.should be_nil
	end	

	it "should be possible call the clearer twice" do
		baz = Baz.new( :bam => 99, :boom => 0 )
		
		baz.reset_boom!
		baz.reset_boom!
		
		baz.has_boom?.should be_false
		baz.boom.should be_nil
	end		
end

describe "Lol" do
	it "Lol should has five arguments" do
		lol = Lol.new(:a => 5, :d => -1)
		lol.a.should == 5
		lol.b.should be_zero
		lol.c.should == 1
		lol.d.should == -1
		lol.e.should == 2
	end

	it "Lol should support custom predicate and clearer" do
		lol = Lol.new(:a => 5, :d => -1)

		lol.has_option_c?.should be_true
		lol.reset_option_c
		lol.has_option_c?.should be_false
	end
end