require 'date'
require 'minitest/autorun'
require 'minitest/spec'
require File.expand_path(File.dirname(__FILE__) + '/../persistence')
require File.expand_path(File.dirname(__FILE__) + '/../data_validation')
require File.expand_path(File.dirname(__FILE__) + '/../../identity/identity')







class SomeClass  < CommandPost::Persistence 
  include CommandPost::Identity

  def initialize
    super
  end

  def self.schema 
    fields = Hash.new
    fields[ :first_name        ] = { :required => true,       :type => String,    :location => :local  } 
    fields[ :last_name         ] = { :required => true,       :type => String,    :location => :local  } 
    fields[ :birth_date        ] = { :required => true,       :type => Date,      :location => :local  } 
    fields[ :favorite_number   ] = { :required => true,       :type => Fixnum,    :location => :local  } 
    fields 
  end
end

describe CommandPost::DataValidation do 
  
   let(:obj) { SomeClass.new }

   it 'should be valid if all required fields are present and types are correct' do
      obj.first_name = 'Joe'
      obj.last_name = 'Schmoe'
      obj.birth_date = Date.new(1980,1,1)
      obj.favorite_number = 3
      obj.valid?.must_equal true
    end

    it 'should not be valid if missing required fields ' do
      obj.first_name = 'Joe'
      obj.last_name = 'Schmoe'
      obj.birth_date = Date.new(1980,1,1)
      # ===>  missing      obj.favorite_number = 3      
      obj.valid?.must_equal false
    end

    it 'should not be valid if a type is incorrect ' do
      obj.first_name = 'Joe'
      obj.last_name = 'Schmoe'
      obj.birth_date = Date.new(1980,1,1)
      obj.favorite_number = "3"  # <---- should be Fixnum      
      obj.valid?.must_equal false
    end

end


 
