class Board
	
  attr_accessor :paths
  attr_reader :rows, :columns, :winner, :grid
	
  def initialize
		@grid    = create_board
		@rows    = [*"A".."F"]
		@columns = [*"1".."7"]
		@paths   = {:N  => [-1,0],
								:NE => [-1,1],
								:E  => [0,1],
								:SE => [1,1],
								:S  => [1,0],
								:SW => [1,-1],
								:W  => [0,-1],
								:NW => [-1,-1]}
  end

  def cell(a1,column = nil)
		a1.is_a?(String) ? @grid[@rows.index(a1[0].upcase)][@columns.index(a1[1])] : @grid[a1][column]
  end

  def offset(cell_x_y, x_offset, y_offset)
		@grid[cell_x_y.row + x_offset][cell_x_y.column + y_offset]
  end

  private
	
  def look_for_wins(cell)
    cell.sequence(:N)  if cell.row > 2    
    cell.sequence(:NE) if (cell.row > 2) && (cell.column < 4)
    cell.sequence(:E)  if cell.column < 4
    cell.sequence(:SE) if (cell.row < 3) && (cell.column < 4)
    cell.sequence(:S)  if cell.row < 3
		cell.sequence(:SW) if (cell.row < 3) && (cell.column > 2)
		cell.sequence(:W)  if (cell.column > 2)
		cell.sequence(:NW) if (cell.row > 2) && (cell.column > 2)
  end
  
  def create_board
		board = Array.new(6){Array.new(7)}
		board.each_with_index do |row,rindex|
			row.each_index do |cindex|
				board[rindex][cindex] = Cell.new({:row => rindex,:column => cindex})
				look_for_wins(board[rindex][cindex])
			end
		end
		board
  end
  
end