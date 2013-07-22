
require_relative '../persistence/persistence.rb'
require_relative '../identity/identity.rb'
require_relative '../command/command.rb'

# Now we'll redo the first example and have an Address field on the Person class. In this example, we'll 'embed the address with the person'
# We'll treat it like a DDD value Object



class Address < Persistence
  def initialize
    super
    fields = Hash.new
    fields[ 'address1'       ] = { :required => true,       :type => String,         :location => :local  } 
    fields[ 'address2'       ] = { :required => false,      :type => String,         :location => :local  } 
    fields[ 'city'           ] = { :required => true,       :type => String,         :location => :local  } 
    fields[ 'state'          ] = { :required => true,       :type => String,         :location => :local  } 
    fields[ 'zipcode'        ] = { :required => true,       :type => String,         :location => :local  } 
    fields[ 'contact_info'   ] = { :required => true,       :type => ContactInfo,    :location => :local  } 
   

    Address.init_schema fields 
  end
end


class ContactInfo < Persistence
  def initialize
    super
    fields = Hash.new
    fields[ 'email_address'   ] = { :required => true,       :type => String,    :location => :local  } 
    fields[ 'phone_number'    ] = { :required => true,       :type => String,    :location => :local  } 
    fields[ 'cell_phone'      ] = { :required => false,      :type => String,    :location => :local  } 
    ContactInfo.init_schema fields 
  end
end








class Person < Persistence
  include Identity
  def initialize
    super
    fields = Hash.new
    fields[ 'first_name'        ] = { :required => true,       :type => String,        :location => :local  } 
    fields[ 'last_name'         ] = { :required => true,       :type => String,        :location => :local  } 
    fields[ 'date_of_birth'     ] = { :required => true,       :type => Date,          :location => :local  } 
    fields[ 'ssn'               ] = { :required => true,       :type => String,        :location => :local  } 
    fields[ 'address'           ] = { :required => true,       :type => Address,       :location => :local  } 
    Person.init_schema fields     
  end
 
  def set_aggregate_lookup_value 
    @data['aggregate_lookup_value'] =  ssn
  end
end



class CommandPersonAdd < Command
  
  def initialize  person 
    raise  ArgumentError.new("Expected Person") if (person.class != Person)
    @person = person
  end

  def execute  

    errors = validate_persistent_fields @person, []
    if errors.length > 0
      raise "validation errors occurred:  #{pp errors}"
    end 

    event = AggregateEvent.new  
    event.aggregate_id = SequenceGenerator.aggregate_id
    event.aggregate_type = Person.to_s
    event.event_description = "person created"
    event.object = @person
    event.user_id = 'joe'
    @person.set_aggregate_lookup_value

    if Aggregate.get_aggregate_by_lookup_value(Person, @person.ssn).empty? == false
      raise "Person with this SSN already exists "
    end

    hashify_persistent_objects_before_save @person
    event.publish 
    Aggregate.get_by_aggregate_id(Person, event.aggregate_id)

  end 
end

 

  # create person object here...

  per = Person.new 
  per.first_name = 'Jane'
  per.last_name = 'Doe'
  per.date_of_birth = Date.new(1971,3,18)
  per.ssn =  "%09d" % SequenceGenerator.misc


  # create address object here

  addr = Address.new 
  addr.address1 = '215 Main Street'
  addr.city = 'Romeo'
  addr.state = 'MI'
  addr.zipcode = '48065'

  contact = ContactInfo.new 
  contact.email_address = 'some.person@gmail.com'
  contact.phone_number = '555-555-1212'

  addr.contact_info = contact

  # set the address field on person to the address object just created
  per.address = addr 

  
  # execute the command to create the person
  cmd = CommandPersonAdd.new per 
  person =  cmd.execute 


  puts "person first_name  : #{person.first_name}"
  puts "person city        : #{person.address.city}"
  puts "person phone       : #{person.address.contact_info.phone}"









