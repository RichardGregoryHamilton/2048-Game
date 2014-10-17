class Cell

  attr_accessor :state
  attr_reader :row, :column, :search_paths
	
  def initialize(args)
    @state        = " " 
		@row          = args[:row] 
		@column       = args[:column]
		@search_paths = [] 
  end

  def sequence(path)
		@search_paths << path
  end
	
end