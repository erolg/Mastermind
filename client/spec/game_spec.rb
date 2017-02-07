require "spec_helper"
describe "Mastermind" do
  let(:output) { double('output').as_null_object } 
  let(:game) { Game.new(output, Computer.new, user) } 
  let(:user) { User.new(output) }

  it "should start the game" do
    game.should respond_to(:start)
  end

  it "should play the game correctly" do
    output.should_receive(:puts).with("Starting new game...")
    output.should_receive(:puts).with("\n[\"R\", \"R\", \"G\", \"G\"]")
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(0)
    output.should_receive(:puts).with("\n[\"B\", \"R\", \"G\", \"G\"]")
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(4)
    
    game.start
  end

  it "should end game if correct was four" do
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(4)
    output.should_receive(:puts).with("Yay! Game over in 1 try")
    game.start
  end

  it "should show new guess if correct was not four" do
    output.should_receive(:puts).with("Starting new game...")
    output.should_receive(:puts).with("\n[\"R\", \"R\", \"G\", \"G\"]")
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(3)
    output.should_receive(:puts).with("How many were close?")
    output.should_receive(:gets).and_return(0)
    output.should_receive(:puts).with("\n[\"B\", \"R\", \"G\", \"G\"]")
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(4)

    game.start
  end

  it "should build the board on every turn" do
    output.should_receive(:puts).with("Starting new game...")
    output.should_receive(:puts).with("\n[\"R\", \"R\", \"G\", \"G\"]")
    output.should_receive(:puts).with("How many were correct?")
    output.should_receive(:gets).and_return(4)
    output.should_receive(:puts).with("||  [\"R\", \"R\", \"G\", \"G\"]  || [4, 0]")

    game.start
  end
end