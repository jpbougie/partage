require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe SharedFile do

  it "should not be valid without a filename" do
    file = SharedFile.new(:content_type => "xyz", :hash => "1" * 40)
    file.should_not be_valid
  end
  
  it "should not be valid without a content_type" do
    file = SharedFile.new(:filename => "xyz", :hash => "1" * 40)
    file.should_not be_valid
  end
  
  it "should not be valid without a hash" do
    file = SharedFile.new(:filename => "xyz", :content_type => "xyz")
    file.should_not be_valid
  end
  
  it "should not be valid without a 40-character hash" do
    file = SharedFile.new(:filename => "xyz", :content_type => "xyz", :hash => "1" * 30)
    file.should_not be_valid
  end

  it "should not be valid without a hex hash" do
    file = SharedFile.new(:filename => "xyz", :content_type => "xyz", :hash => "x" * 40)
    file.should_not be_valid
  end
  
  it "should accept a valid hash" do
    file = SharedFile.new(:filename => "xyz", :content_type => "xyz",
                          :hash => "1502776e6b7650b06764db69db0c889216696d7b")
    file.should be_valid
  end

end