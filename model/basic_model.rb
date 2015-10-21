class BasicModel
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def default_params(params)
    params.each do |k, v|
      value = v.respond_to?(:call) ? v.call : v
      instance_variable_set "@#{k}", value
      self.class.__send__ :attr_reader, k
    end
    @default_params = params
  end

  def data_name
    "data/#{self.class.to_s.downcase}_#{@id or raise}"
  end

  def save
    values = {}
    @default_params.keys.each do |k|
      values[k] = instance_variable_get "@#{k}"
    end
    File.write data_name, values.to_yaml
    self
  end

  def load
    data = _load
    @default_params.keys.each do |k|
      if value = data[k]
        instance_variable_set("@#{k}", value)
      end
    end
    self
  end

  def _load
    YAML.load_file data_name
  end

  def self.load(id)
    new(id).load
  end
end
