require "spec_helper"
describe "computer tasks" do
  let(:computer) { Computer.new }
  let(:user)  { User.new }
  let(:s) { ["R","G","B","Y","P","O"].repeated_permutation(4).to_a.sort!}

  it "should be RRGG" do
    computer.current_guess(Array.new(1296)).should eql(["R", "R", "G", "G"])       
  end 

  it "should select the first from array" do
    computer.current_guess([["R", "R", "R", "R"],["R", "R", "G", "G"]]).should eql(["R", "R", "R", "R"])
  end

  it "should raise exception if no patterns left" do
     expect { computer.current_guess([]) }.to raise_error
  end

  it "should generate all possible outcomes" do
    generate = computer.generate_patterns
    generate.should have(1296).items
  end 

  it "should generate feedback for input" do
    computer.guess(["B","Y","P","O"], ["R", "R", "G", "G"]).should eql([0,0])
    computer.guess(["R","R","G","G"], ["R","B","B","Y"]).should eql([1,0])
    computer.guess(["R","R","G","Y"], ["R","B","B","Y"]).should eql([2,0])
    computer.guess(["R", "R", "G", "G"],["R", "R", "G", "B"]).should eql([3,0])
    computer.guess(["R", "R", "G", "G"],["R", "R", "G", "G"]).should eql([4,0])
    computer.guess(["R", "R", "G", "G"],["R","G","B","Y"]).should eql([1,1])
    computer.guess(["O","B","B","Y"], ["B", "B", "B", "Y"]).should eql([3,0])
    computer.guess(["B", "R", "G", "O"], ["R","B","Y","G"]).should eql([0,3])     
  end

  it "should eliminate code that would not have given the same response" do
    code = ["O","B","B","Y"]
    feedback = [3,0]
    computer.eliminate_patterns(s,code,feedback).should eql([["B", "B", "B", "Y"], ["G", "B", "B", "Y"], 
                                                          ["O", "B", "B", "B"], ["O", "B", "B", "G"], 
                                                          ["O", "B", "B", "O"], ["O", "B", "B", "P"], 
                                                          ["O", "B", "B", "R"], ["O", "B", "G", "Y"], 
                                                          ["O", "B", "O", "Y"], ["O", "B", "P", "Y"], 
                                                          ["O", "B", "R", "Y"], ["O", "B", "Y", "Y"], 
                                                          ["O", "G", "B", "Y"], ["O", "O", "B", "Y"], 
                                                          ["O", "P", "B", "Y"], ["O", "R", "B", "Y"], 
                                                          ["O", "Y", "B", "Y"], ["P", "B", "B", "Y"], 
                                                          ["R", "B", "B", "Y"], ["Y", "B", "B", "Y"]])
  end
end

