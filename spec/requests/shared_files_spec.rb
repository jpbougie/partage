require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a shared_file exists" do
  SharedFile.all.destroy!
  request(resource(:shared_files), :method => "POST", 
    :params => { :shared_file => { :id => nil }})
end

describe "resource(:shared_files)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:shared_files))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of shared_files" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a shared_file exists" do
    before(:each) do
      @response = request(resource(:shared_files))
    end
    
    it "has a list of shared_files" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      SharedFile.all.destroy!
      @response = request(resource(:shared_files), :method => "POST", 
        :params => { :shared_file => { :id => nil }})
    end
    
    it "redirects to resource(:shared_files)" do
      @response.should redirect_to(resource(SharedFile.first), :message => {:notice => "shared_file was successfully created"})
    end
    
  end
end

describe "resource(@shared_file)" do 
  describe "a successful DELETE", :given => "a shared_file exists" do
     before(:each) do
       @response = request(resource(SharedFile.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:shared_files))
     end

   end
end

describe "resource(:shared_files, :new)" do
  before(:each) do
    @response = request(resource(:shared_files, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@shared_file, :edit)", :given => "a shared_file exists" do
  before(:each) do
    @response = request(resource(SharedFile.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@shared_file)", :given => "a shared_file exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(SharedFile.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @shared_file = SharedFile.first
      @response = request(resource(@shared_file), :method => "PUT", 
        :params => { :shared_file => {:id => @shared_file.id} })
    end
  
    it "redirect to the shared_file show action" do
      @response.should redirect_to(resource(@shared_file))
    end
  end
  
end

