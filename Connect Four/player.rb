class Player
  attr_accessor :symbol, :name, :color, :moves

  def initialize
    @name   = nil
		@symbol = nil
		@moves  = []
  end

  def add_move(cell)
		@moves << cell
  end
end