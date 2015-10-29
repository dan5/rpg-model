class RpgModel
  class BasicModel
    attr_reader :id

    def initialize(id, manager)
      @id = id
      @manager = manager
      @dir_base = self.class.dir_base
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
      "#{@dir_base}/#{self.class.to_s.downcase}_#{@id or raise}"
    end

    def destroy
      p data_name
      File.delete data_name
    end

    def save
      values = {}
      @default_params.keys.each do |k|
        values[k] = instance_variable_get "@#{k}"
      end
      Dir.mkdir @dir_base unless File.exist?(@dir_base)
      File.write data_name, values.to_yaml
      self
    end

    def load
      data = load_yaml
      @default_params.keys.each do |k|
        if value = data[k]
          instance_variable_set("@#{k}", value)
        end
      end
      self
    end

    def load_yaml
      YAML.load_file data_name
    end

    def self.load(id, manager)
      new(id, manager).load
    end

    def self.create(manager)
      id = ((self.ids.map(&:to_i).max or 0) + 1).to_s
      new(id, manager).save
    end

    @@dir_scope = nil

    def scope
      @@dir_scope = id
      r = yield
      @@dir_scope = nil
      r
    end

    def self.dir_base
      @@dir_scope ? 'data/' + @@dir_scope : 'data'
    end

    def self.ids
      ptn = "#{self.dir_base}/#{self.to_s.downcase}_"
      Dir.glob(ptn + '*').map {|e| e.sub ptn, '' }
    end

    def self.all(manager)
      self.ids.inject({}) {|h, id| h[id] = self.load(id, manager); h }
    end
  end
end
