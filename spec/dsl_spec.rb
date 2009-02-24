require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::Xml::Dsl do
  A = Objectify::Atom

  class D < Objectify::DocumentParser
    def initialize; end
  end

  class MyAuthor < A::Author
    attributes :weight
    attribute 'attr', 'ns:realname'
    attribute 'attrs', nil, true
    attribute 'ns_something'
  end

  it 'should init the metadata' do
    D.metadata.each do |k, v|
      v.should_not be_nil
    end
  end
  describe 'inheritance' do
    it 'should include the parent metadata' do
      MyAuthor.metadata[:attributes].should include('name')
    end
    it 'should include the new metadata' do
      MyAuthor.metadata[:attributes].should include('weight')
    end
    it "should not affect the parent's metadata" do
      A::Author.metadata[:attributes].should include('name')
      A::Author.metadata[:attributes].should_not include('weight')
    end
  end

  describe 'has_one' do
    it 'should set the metadata correctly' do
      A::Feed.metadata[:attributes].should_not include('generator')
      A::Feed.metadata[:qualified_attributes].should include('generator')
      A::Feed.metadata[:collections].should_not include('generator')
      A::Feed.metadata[:types]['generator'].should == A::Generator
    end
  end

  describe 'has_many' do
    it 'should set the metadata correctly' do
      A::Feed.metadata[:attributes].should_not include('links')
      A::Feed.metadata[:qualified_attributes].should include('link')
      A::Feed.metadata[:collections].should include('link')
      A::Feed.metadata[:types]['link'].should == :Link
    end
  end

  describe 'attributes' do
    it 'should call attribute for each item' do
      D.expects(:attribute).with(:one)
      D.expects(:attribute).with(:two)
      D.attributes :one, :two
    end
  end

  describe 'attribute' do
    it 'should set up an attribute with namespace' do
      #attribute 'attr', 'ns:realname'
      MyAuthor.metadata[:attributes].should_not include('attr')
      MyAuthor.metadata[:qualified_attributes]['ns:realname'].should == 'attr'
      MyAuthor.metadata[:collections].should_not include('ns:realname')
      MyAuthor.metadata[:collections].should_not include('attr')
      MyAuthor.metadata[:types]['ns:realname'].should be_nil
      MyAuthor.metadata[:types]['attr'].should be_nil
      d = MyAuthor.new('')
      d.attr.should be_nil
      d.attr = true
      d.attr.should be_true
    end
    it 'should set up a collection attribute' do
      #attribute 'attr2', nil, true
      MyAuthor.metadata[:attributes].should include('attrs')
      MyAuthor.metadata[:qualified_attributes].keys.should_not include('attrs')
      MyAuthor.metadata[:qualified_attributes].values.should_not include('attrs')
      MyAuthor.metadata[:collections].should include('attrs')
      MyAuthor.metadata[:types]['attr'].should be_nil
      d = MyAuthor.new('')
      d.attrs.should == []
      d.attrs = [:something]
      d.attrs.should == [:something]
    end
  end

  describe 'find_attribute' do
    it 'should find the attribute with namespace' do
      MyAuthor.find_attribute('ns:realname', 'ns', 'realname').should == 'attr'
    end
    it 'should find the attribute' do
      MyAuthor.find_attribute('attrs', nil, 'attrs').should == 'attrs'
    end
    it 'should pluralize and find the attribute' do
      A::Entry.find_attribute('link', nil, 'link').should == 'links'
    end
    it 'should not find attr with a wrong namespace' do
      MyAuthor.find_attribute('attr', nil, 'attr').should be_nil
    end
    it 'should find the attribute with implicit namespaced name' do
      MyAuthor.find_attribute('ns:something', 'ns', 'something').should == 'ns_something'
    end
  end

#   describe 'attribute_type' do
#     it 'should return an object'
#     it 'should parse a symbol type definition'
#     it 'should parse a string type definition'
#     it 'should parse a type definition in a module'
#     it 'should find an object in the current object scope'
#   end

#   describe 'flatten?' do
#     it 'should be true for flatten definitions'
#     it 'should be nil otherwise'
#   end

#   describe 'collection?' do
#     it 'should be true for has_many definitions'
#     it 'should be nil otherwise'
#   end
#   describe 'namespace' do
#     it 'should return nil if no default namespace url is defined'
#     it 'should return the default namespace url if defined'
#     it 'should return the url of a named namespace'
#   end

#   describe 'namespaces' do
#     it 'should return a hash containing defined named and unnamed namespaces'
#   end

#   describe 'attribute' do
#     it 'should return the method name of the given attribute'
#     it 'should return the method name of the given attribute in a namespace'
#     it 'should return nil if the attribute is not defined'
#     it 'should return nil if the attribute is in the wrong namespace'
#   end

end
