require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a set exists" do
  Set.all.destroy!
  request(resource(:sets), :method => "POST", 
    :params => { :set => { :id => nil }})
end

describe "resource(:sets)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:sets))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of sets" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a set exists" do
    before(:each) do
      @response = request(resource(:sets))
    end
    
    it "has a list of sets" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Set.all.destroy!
      @response = request(resource(:sets), :method => "POST", 
        :params => { :set => { :id => nil }})
    end
    
    it "redirects to resource(:sets)" do
      @response.should redirect_to(resource(Set.first), :message => {:notice => "set was successfully created"})
    end
    
  end
end

describe "resource(@set)" do 
  describe "a successful DELETE", :given => "a set exists" do
     before(:each) do
       @response = request(resource(Set.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:sets))
     end

   end
end

describe "resource(:sets, :new)" do
  before(:each) do
    @response = request(resource(:sets, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@set, :edit)", :given => "a set exists" do
  before(:each) do
    @response = request(resource(Set.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@set)", :given => "a set exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Set.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @set = Set.first
      @response = request(resource(@set), :method => "PUT", 
        :params => { :set => {:id => @set.id} })
    end
  
    it "redirect to the set show action" do
      @response.should redirect_to(resource(@set))
    end
  end
  
end

