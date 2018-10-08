#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'aws-sdk'

def DescribeLimits(*args)
  puts "Calling task operation DescribeLimits" 

  argstring=args[0]
  argstring=argstring.delete('\\')

  arg_hash=JSON.parse(argstring)
  #Remove task name from arguments  
  arg_hash.delete("_task")

  client = Aws::Kinesis::Client.new(region: get_region)

  if arg_hash.empty?
    response = client.describe_limits()
  else 
    call_hash={}
    arg_hash.each do |k,v|
	  key=k.to_sym
	  if k.to_s.end_with?"s"
	    call_hash[key]=v.split(",")
	  else
	    #Parameter formatting for hash like structures - example: parameter_name="{:item=>[i1,i2];:item2=>stringElement}"
	    if v.include? "{"
		  requestHash=Hash.new
		  msg=v.gsub("{","").gsub("}","")
		  arr = msg.split(";")
		  arr.each do |item| 
		   vals=item.split("=>")
		    if vals[1].include? "["
              valarr=[]
              elements = vals[1].gsub("[","").gsub("]","").split(",")
              elements.each do |e|
                valarr << e
              end
              requestHash[vals[0].gsub(":","").strip.to_sym]=valarr
            else
 		      requestHash[vals[0].gsub(":","").strip.to_sym]=vals[1].gsub("'","").strip
            end
		  end
		   
          call_hash[key]=requestHash
		else
	      call_hash[key]=v
		end
	  end
	end
	
    response = client.describe_limits(call_hash)
  end
  
  hash_response = response_to_hash(response)
  
  return hash_response
end

def response_to_hash(response)
  hashed = {}
  hashed = hashed.merge!(response)
  hashed
end

def get_region
  ENV['AWS_REGION'] || 'us-west-2'
end

#Get operation parameters from an input JSON
params = STDIN.read

begin
  result = DescribeLimits(params)
  puts JSON.pretty_generate(result)
  exit 0
rescue Aws::Kinesis::Errors::ServiceError => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end