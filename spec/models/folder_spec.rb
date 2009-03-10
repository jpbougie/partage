require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Folder do

  it "should not be valid without a name" do
    @folder = Folder.new
    @folder.should_not be_valid
  end
  
  it "should be valid with a name" do
    @folder = Folder.new(:name => "xyz")
    @folder.should be_valid
  end
  
  describe "when you have a valid folder," do
    before(:each) do
      @folder = Folder.create!(:name => "xyz")
    end
    
    it "shouldn't have any children at first" do
      @folder.children.count.should == 0
    end
    
    it "should have one if you add it" do
      subfolder = @folder.children.create(:name => "abc")
      
      @folder.children.count.should == 1
      @folder.children.should == [subfolder]
    end
    
    it "should be able to navigate to a subfolder" do
      subfolder = @folder.children.create(:name => "abc")

      (@folder / "abc").should == subfolder
    end
  end

end