require "pry"
# require "pry-rescue"
require "json"
require "facets"
require "retries"


require "aws-sdk-ec2"


Puppet::Type.type(:aws_vpc).provide(:arm) do
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
    @is_create = false
    @is_delete = false
  end
    
  def namevar
    :vpc_id
  end

  # Properties

  def amazon_provided_ipv6_cidr_block=(value)
    Puppet.info("amazon_provided_ipv6_cidr_block setter called to change to #{value}")
    @property_flush[:amazon_provided_ipv6_cidr_block] = value
  end

  def cidr_block=(value)
    Puppet.info("cidr_block setter called to change to #{value}")
    @property_flush[:cidr_block] = value
  end

  def cidr_block_association_set=(value)
    Puppet.info("cidr_block_association_set setter called to change to #{value}")
    @property_flush[:cidr_block_association_set] = value
  end

  def dhcp_options_id=(value)
    Puppet.info("dhcp_options_id setter called to change to #{value}")
    @property_flush[:dhcp_options_id] = value
  end

  def dry_run=(value)
    Puppet.info("dry_run setter called to change to #{value}")
    @property_flush[:dry_run] = value
  end

  def filters=(value)
    Puppet.info("filters setter called to change to #{value}")
    @property_flush[:filters] = value
  end

  def instance_tenancy=(value)
    Puppet.info("instance_tenancy setter called to change to #{value}")
    @property_flush[:instance_tenancy] = value
  end

  def ipv6_cidr_block_association_set=(value)
    Puppet.info("ipv6_cidr_block_association_set setter called to change to #{value}")
    @property_flush[:ipv6_cidr_block_association_set] = value
  end

  def is_default=(value)
    Puppet.info("is_default setter called to change to #{value}")
    @property_flush[:is_default] = value
  end

  def state=(value)
    Puppet.info("state setter called to change to #{value}")
    @property_flush[:state] = value
  end

  def tags=(value)
    Puppet.info("tags setter called to change to #{value}")
    @property_flush[:tags] = value
  end

  def vpc_id=(value)
    Puppet.info("vpc_id setter called to change to #{value}")
    @property_flush[:vpc_id] = value
  end

  def vpc_ids=(value)
    Puppet.info("vpc_ids setter called to change to #{value}")
    @property_flush[:vpc_ids] = value
  end


  def name=(value)
    Puppet.info("name setter called to change to #{value}")
    @property_flush[:name] = value
  end

  def self.get_region
    ENV['AWS_REGION'] || 'us-west-2'
  end

  def self.has_name?(hash)
    !hash[:name].nil? && !hash[:name].empty?
  end
  def self.instances
    Puppet.debug("Calling instances for region #{self.get_region}")
    client = Aws::EC2::Client.new(region: self.get_region)

    all_instances = []
    client.describe_vpcs.each do |response|
      response.vpcs.each do |i|
        hash = instance_to_hash(i)
        all_instances << new(hash) if has_name?(hash)
      end
    end
    all_instances
  end

  def self.prefetch(resources)
    instances.each do |prov|
      tags = prov.respond_to?(:tags) ? prov.tags : nil
      tags = prov.respond_to?(:tag_set) ? prov.tag_set : tags
      if tags 
        name = tags.find { |x| x[:key] == "Name" }[:value]
        if (resource = (resources.find { |k, v| k.casecmp(name).zero? } || [])[1])
          resource.provider = prov
        end
      end
    end
  end

  def self.name_from_tag(instance)
    tags = instance.respond_to?(:tags) ? instance.tags : nil
    tags = instance.respond_to?(:tag_set) ? instance.tag_set : tags
    name = tags.find { |x| x.key == 'Name' } unless tags.nil?
    name.value unless name.nil?
  end

  def self.instance_to_hash(instance)
    amazon_provided_ipv6_cidr_block = instance.respond_to?(:amazon_provided_ipv6_cidr_block) ? (instance.amazon_provided_ipv6_cidr_block.respond_to?(:to_hash) ? instance.amazon_provided_ipv6_cidr_block.to_hash : instance.amazon_provided_ipv6_cidr_block ) : nil
    cidr_block = instance.respond_to?(:cidr_block) ? (instance.cidr_block.respond_to?(:to_hash) ? instance.cidr_block.to_hash : instance.cidr_block ) : nil
    cidr_block_association_set = instance.respond_to?(:cidr_block_association_set) ? (instance.cidr_block_association_set.respond_to?(:to_hash) ? instance.cidr_block_association_set.to_hash : instance.cidr_block_association_set ) : nil
    dhcp_options_id = instance.respond_to?(:dhcp_options_id) ? (instance.dhcp_options_id.respond_to?(:to_hash) ? instance.dhcp_options_id.to_hash : instance.dhcp_options_id ) : nil
    dry_run = instance.respond_to?(:dry_run) ? (instance.dry_run.respond_to?(:to_hash) ? instance.dry_run.to_hash : instance.dry_run ) : nil
    filters = instance.respond_to?(:filters) ? (instance.filters.respond_to?(:to_hash) ? instance.filters.to_hash : instance.filters ) : nil
    instance_tenancy = instance.respond_to?(:instance_tenancy) ? (instance.instance_tenancy.respond_to?(:to_hash) ? instance.instance_tenancy.to_hash : instance.instance_tenancy ) : nil
    ipv6_cidr_block_association_set = instance.respond_to?(:ipv6_cidr_block_association_set) ? (instance.ipv6_cidr_block_association_set.respond_to?(:to_hash) ? instance.ipv6_cidr_block_association_set.to_hash : instance.ipv6_cidr_block_association_set ) : nil
    is_default = instance.respond_to?(:is_default) ? (instance.is_default.respond_to?(:to_hash) ? instance.is_default.to_hash : instance.is_default ) : nil
    state = instance.respond_to?(:state) ? (instance.state.respond_to?(:to_hash) ? instance.state.to_hash : instance.state ) : nil
    tags = instance.respond_to?(:tags) ? (instance.tags.respond_to?(:to_hash) ? instance.tags.to_hash : instance.tags ) : nil
    vpc_id = instance.respond_to?(:vpc_id) ? (instance.vpc_id.respond_to?(:to_hash) ? instance.vpc_id.to_hash : instance.vpc_id ) : nil
    vpc_ids = instance.respond_to?(:vpc_ids) ? (instance.vpc_ids.respond_to?(:to_hash) ? instance.vpc_ids.to_hash : instance.vpc_ids ) : nil

    hash = {}
    hash[:ensure] = :present
    hash[:object] = instance
    hash[:name] = name_from_tag(instance)
    hash[:tags] = instance.tags if instance.respond_to?(:tags) and instance.tags.size > 0
    hash[:tag_set] = instance.tag_set if instance.respond_to?(:tag_set) and instance.tag_set.size > 0

    hash[:amazon_provided_ipv6_cidr_block] = amazon_provided_ipv6_cidr_block unless amazon_provided_ipv6_cidr_block.nil?
    hash[:cidr_block] = cidr_block unless cidr_block.nil?
    hash[:cidr_block_association_set] = cidr_block_association_set unless cidr_block_association_set.nil?
    hash[:dhcp_options_id] = dhcp_options_id unless dhcp_options_id.nil?
    hash[:dry_run] = dry_run unless dry_run.nil?
    hash[:filters] = filters unless filters.nil?
    hash[:instance_tenancy] = instance_tenancy unless instance_tenancy.nil?
    hash[:ipv6_cidr_block_association_set] = ipv6_cidr_block_association_set unless ipv6_cidr_block_association_set.nil?
    hash[:is_default] = is_default unless is_default.nil?
    hash[:state] = state unless state.nil?
    hash[:tags] = tags unless tags.nil?
    hash[:vpc_id] = vpc_id unless vpc_id.nil?
    hash[:vpc_ids] = vpc_ids unless vpc_ids.nil?
    hash
  end

  def create
    @is_create = true
    Puppet.info("Entered create for resource #{resource[:name]} of type Instances")
    client = Aws::EC2::Client.new(region: self.class.get_region)
    response = client.create_vpc(build_hash)
    res = response.respond_to?(:vpc) ? response.vpc : response
    with_retries(:max_tries => 5) do  
      client.create_tags(
        resources: [res.to_hash[namevar]],
        tags: [{ key: 'Name', value: resource.provider.name}]
      )
    end
    @property_hash[:ensure] = :present
  rescue Exception => ex
    Puppet.alert("Exception during create. The state of the resource is unknown.  ex is #{ex} and backtrace is #{ex.backtrace}")
    raise
  end

  def flush
    Puppet.info("Entered flush for resource #{name} of type <no value> - creating ? #{@is_create}, deleting ? #{@is_delete}")
    if @is_create || @is_delete
      return # we've already done the create or delete
    end
    @is_update = true
    hash = build_hash
    Puppet.info("Calling Update on flush")
    @property_hash[:ensure] = :present
    response = []
  end

  def build_hash
    vpc = {}
    if @is_create || @is_update
      vpc[:amazon_provided_ipv6_cidr_block] = resource[:amazon_provided_ipv6_cidr_block] unless resource[:amazon_provided_ipv6_cidr_block].nil?
      vpc[:cidr_block] = resource[:cidr_block] unless resource[:cidr_block].nil?
      vpc[:dry_run] = resource[:dry_run] unless resource[:dry_run].nil?
      vpc[:filters] = resource[:filters] unless resource[:filters].nil?
      vpc[:instance_tenancy] = resource[:instance_tenancy] unless resource[:instance_tenancy].nil?
      vpc[:vpc_id] = resource[:vpc_id] unless resource[:vpc_id].nil?
      vpc[:vpc_ids] = resource[:vpc_ids] unless resource[:vpc_ids].nil?
    end
    return symbolize(vpc)
  end

  def destroy
    Puppet.info("Entered delete for resource #{resource[:name]}")
    @is_delete = true
    Puppet.info("Calling operation delete_vpc")
    client = Aws::EC2::Client.new(region: self.class.get_region)
    client.delete_vpc({namevar => resource.provider.property_hash[namevar]})
    @property_hash[:ensure] = :absent
  end


  # Shared funcs
  def exists?
    return_value = @property_hash[:ensure] && @property_hash[:ensure] != :absent
    Puppet.info("Checking if resource #{name} of type <no value> exists, returning #{return_value}")
    return_value
  end

  def property_hash
    @property_hash
  end


  def symbolize(obj)
    return obj.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = symbolize(v) }
    end if obj.is_a? Hash

    return obj.reduce([]) do |memo, v|
      memo << symbolize(v); memo
    end if obj.is_a? Array
    obj
  end
end

# this is the end of the ruby class
