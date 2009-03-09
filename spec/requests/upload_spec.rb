require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/upload" do
  before(:each) do
    @response = request("/upload")
  end
end