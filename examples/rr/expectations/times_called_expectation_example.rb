dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe "RR::Expectations::TimesCalledExpectation", :shared => true do
  before do
    @space = RR::Space.new
    @object = Object.new
    @method_name = :foobar
    @double = @space.create_double(@object, @method_name) {}
    def @double.times_called=(value); @times_called = value; end
  end

  def raises_expectation_error(&block)
    proc {block.call}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end
end

describe "RR::Expectations::TimesCalledExpectation", "#verify_double" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"
  
  it "matches an integer" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(5)

    @double.times_called = 5
    @expectation.verify_double(@double)

    @double.times_called = 3
    raises_expectation_error {@expectation.verify_double(@double)}
    @double.times_called = 6
    raises_expectation_error {@expectation.verify_double(@double)}
  end

  it "matches a range" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(1..2)
    @double.times_called = 1
    @expectation.verify_double(@double)
    @double.times_called = 2
    @expectation.verify_double(@double)
    raises_expectation_error do
      @double.times_called = 0
      @expectation.verify_double(@double)
    end
    raises_expectation_error do
      @double.times_called = 3
      @expectation.verify_double(@double)
    end
  end

  it "matches a block" do
    @expectation = RR::Expectations::TimesCalledExpectation.new {|value| value == 2}

    @double.times_called = 2
    @expectation.verify_double(@double)

    raises_expectation_error {@double.times_called = 1; @expectation.verify_double(@double)}
    raises_expectation_error {@double.times_called = 0; @expectation.verify_double(@double)}
    raises_expectation_error {@double.times_called = 3; @expectation.verify_double(@double)}
  end

  it "doesn't accept both an argument and a block" do
    proc do
      RR::Expectations::TimesCalledExpectation.new(2) {|value| value == 2}
    end.should raise_error(ArgumentError, "Cannot pass in both an argument and a block")
  end
end

describe "RR::Expectations::TimesCalledExpectation", "#verify_input for an integer expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"
  
  it "does not exceed expectation" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(1)
    @expectation.verify_input
    raises_expectation_error {@expectation.verify_input}
  end
end

describe "RR::Expectations::TimesCalledExpectation", "#verify_input for a range expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "does not exceed expectation" do
    @expectation = RR::Expectations::TimesCalledExpectation.new(1..2)
    @expectation.verify_input
    @expectation.verify_input
    raises_expectation_error {@expectation.verify_input}
  end
end

describe "RR::Expectations::TimesCalledExpectation", "#verify_input for a proc expectation" do
  it_should_behave_like "RR::Expectations::TimesCalledExpectation"

  it "does nothing" do
    @expectation = RR::Expectations::TimesCalledExpectation.new {|times| times == 1}
    @object.foobar
    @object.foobar
    @object.foobar
  end
end