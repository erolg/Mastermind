describe "#give_feedback" do
  let(:output) { double('output').as_null_object } 
  let(:user) { User.new(output) } 
  
  it "should prompt for correct hits" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(0)
    
    user.give_feedback
  end

  it "should prompt for close hits" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(0)

    user.give_feedback
  end

  it "should prompt again when there is incorrect input" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(5)
    output.should_receive(:puts).with("Incorrect input try again. How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(0)
    user.give_feedback
  end

  it "should prompt again when there is incorrect close input" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(5)
    output.should_receive(:puts).with("Incorrect input try again. How many were correct?")
    output.should_receive(:gets).and_return(0)
    user.give_feedback
  end

  it "should not prompt for guess when correct = 4" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(4)
    output.should_not_receive(:puts).with("How many were close?")
    output.should_not_receive(:gets)

    user.give_feedback
  end

  it "should return array with feedback" do
    output.should_receive(:gets).and_return(3)
    output.should_receive(:gets).and_return(1)
    user.give_feedback.should eql([3,1])
  end
end