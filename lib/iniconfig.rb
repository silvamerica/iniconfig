class IniConfig
  def self.load(file_paths, overrides=[], opts={})
    paths = file_paths.dup
    paths = [paths] if paths.is_a? String
    configuration = false
    while !configuration && !paths.empty? do
      path = paths.shift
      begin
        configuration = new(path, overrides, opts).data
      rescue Errno::ENOENT => e
      end
    end
    if configuration
      configuration
    else
      raise Errno::ENOENT, [file_paths].join(" or ")
    end
  end
    
  attr_accessor :data
  
  def initialize(file_path, overrides=[], opts={})
    @fp = file_path
    @overrides = overrides.map{|o|o.to_s}
    @override = opts[:override] || '<>'
    @comment = opts[:comment] || ';#'
    @param = opts[:assigner] || '='
    @quote = opts[:quote] || '\'"'
    @array_sep = opts[:array_separator] || ','
    @boolean_true = opts[:boolean_true] || ["yes", "true"]
    @boolean_false = opts[:boolean_false] || ["no", "false"]    
    
    @data = ConfigGroup.new {|h,k| h[k] = ConfigGroup.new}
    
    @rgxp_comment = %r/^\s*\z|\A\s*[#{@comment}]/
    @rgxp_inline  = %r/(.*?)(?:\s*[#{@comment}]|$)/
    @rgxp_section = %r/^\s*\[([^\]]+)\]/
    @rgxp_quote   = %r/^\s*[#{@quote}]([^#{@quote}]*?)[#{@quote}]/
    @rgxp_param   = %r/^([\w\.\_\-\:]+)(?:#{@override[0,1]}([\w\d\_\-\:}]+)#{@override[1,1]})?\s*#{@param}(.*)/

    parse
  end
  
  def parse
    section = nil    
    File.open(@fp, 'r') do |f|
      while line = f.gets
        line = line.chomp

        case line
        # ignore blank lines and comment lines
        when @rgxp_comment; next

        # this is a section declaration
        when @rgxp_section; section = @data[$1.strip.to_sym]

        # otherwise we have a parameter
        when @rgxp_param
          raise Exception, "line '#{line} is not inside a section" if not section
          process_line(section, $1, $2, $3)

        else
          raise Exception, "could not parse line '#{line}'"
        end
      end # while
    end # File.open
  end
  
  def process_line(section, key, override, value)
    section[key.strip.to_sym] = process_value(value) unless override && !@overrides.include?(override)
  end
  
  def process_value(value)
    value.strip!
    return $1 if value =~ @rgxp_quote
    value = $1 if value =~ @rgxp_inline # strip out inline comments and return whatever is left
    return value[1..-1].to_sym if value.is_a_symbol?
    return value.split(@array_sep).collect{|v|v.strip} if value.include?(@array_sep)
    return false if @boolean_false.include?(value)
    return true if @boolean_true.include?(value)
    return value.to_i if value.is_a_number?
    value
  end
end

class String
  def is_a_number?
    self.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
  
  def is_a_symbol?
    self.to_s.match(/^\:/) == nil ? false : true
  end
end  

class ConfigGroup < Hash
  def method_missing(mid, *args)
    self[mid]
  end
end
