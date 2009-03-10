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
    
    it "should have a child if you add it" do
      subfolder = @folder.children.create(:name => "abc")
      
      @folder.children.count.should == 1
      @folder.children.should == [subfolder]
    end
  end
  
  describe "when you have a tree of folders," do
    before(:each) do
      @root = Folder.create(:name => "/")
        @sub1 = Folder.create(:name => "def", :parent => @root)
          @subsub1 = Folder.create(:name => "ghi", :parent => @sub1)
          @subsub2 = Folder.create(:name => "jkl", :parent => @sub1)
        @sub2 = Folder.create(:name => "mno", :parent => @root)
    end
    
    it "should be able to navigate to a child" do
      (@root / "def").should == @sub1
      (@root / "def" / "jkl").should == @subsub2
    end
    
    it "should give a full path" do
      @root.full_path.should == "/"
      @sub1.full_path.should == "/def"
      @subsub1.full_path.should == "/def/ghi"
    end
  end
end