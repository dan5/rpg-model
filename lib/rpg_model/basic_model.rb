class RpgModel
  class BasicModel
    attr_reader :id
  
    def initialize(id, manager)
      @id = id
      @manager = manager
      @base_dir = self.class.base_dir
    end
  
    def default_params(params)
      params.each do |k, v|
        value = v.respond_to?(:call) ? v.call : v
        instance_variable_set "@#{k}", value
        self.class.__send__ :attr_accessor, k
      end
      @default_params = params
    end
  
    def data_name
      "#{@base_dir}/#{self.class.to_s.downcase}_#{@id or raise}"
    end

    def data_id
      @id
    end
  
    def save
      values = {}
      @default_params.keys.each do |k|
        values[k] = instance_variable_get "@#{k}"
      end
      Dir.mkdir @base_dir unless File.exist?(@base_dir)
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
  
    def self.load(id, manager)
      new(id, manager).load
    end

    def self.all
      {}
    end

    @@base_dir = nil

    def scope
      @@base_dir = id
      r = yield
      @@base_dir = nil
      r
    end

    def self.base_dir
      @@base_dir ? "data/#{@@base_dir}" : 'data'
    end

    def self.ids
      ptn = "#{self.base_dir}/#{self.to_s.downcase}_"
      Dir.glob(ptn + '*').map {|e| e.sub ptn, '' }
    end
  end
end
