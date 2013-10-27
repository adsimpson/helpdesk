class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end
  
  def matches?(req)
    accept_header = req.headers['Accept']
    @default || accept_header && accept_header.include?("application/vnd.example-v#{@version}+json")    
  end
end