# frozen_string_literal: true

# Positive values: height of water, negatives: height of blocks.
LAKE1 = [
  [-5, -1, -1, 99],
  [0, 0, 0, 0],
  [0, -8, -5, -5],
  [0, 0, 0, 0]
]

LAKE2 = [
  [30, 0, -14, -8, 0],
  [30, 0, -14, -8, 0],
  [30, 0, -14, -8, 0],
  [30, 0, -20, 0, 0],
  [30, 0, -14, -8, 0]
]

LAKE3 = [
  [20, 0, -20, -8, 0],
  [20, 0, -20, -8, 0],
  [20, 0, -20, -8, 0],
  [20, 0, -2, 0, 0],
  [20, 0, -20, -8, 0]
]

# Display a lake using the puts function to output results.
def display_lake(lake)
  return if lake.empty?

  width = lake.length
  puts '-' * (width * 4 + 2)
  0.upto(lake.length - 1) do |y|
    row_printable = []
    (0..width - 1).each do |x|
      cell = lake[y][x]
      # formats string so as to align column values
      row_printable << format(' %<cell>.2i ', cell: cell) unless cell.negative?
      row_printable << format('[%<cell>.2i]', cell: -cell) if cell.negative?
    end
    puts "|#{row_printable.join('')}|"
  end
  puts '-' * (width * 4 + 2)
end

# Check if the coordinates are valid.
def coordValid(lake, x, y)
  y.between?(0, lake.length - 1) &&
    x.between?(0, lake[0].length - 1) &&
    !lake[y][x].nil? &&
    (lake[y][x].is_a? Integer)
end

# Simulate the flow of water in the lake.
def flow(lake, dx, dy, wind)

  # iterate over the lake
  lake.each_with_index do |row, y|
    row.each_with_index do |current_cell, x|
      next unless coordValid(lake, x + dx, y + dy) && coordValid(lake, x, y)

      # calculate the height difference and check if positive and cells are >=0
      next_cell = lake[y + dy][x + dx]
      height_diff = current_cell - next_cell + wind
      next unless height_diff.positive? && current_cell >= 0 && next_cell >= 0

      # calculate the flow amount and update the lake
      flow_amount = 1 + (height_diff / 4)
      flow_amount = [flow_amount, current_cell].min
      lake[y][x] -= flow_amount
      lake[y + dy][x + dx] += flow_amount
    end
  end
end

# Simulate the wave over blocks in the lake.
def waveOverBlocks(lake, x, y, dx, dy)
  max_block_height = 0
  s = 1

  # loop over the lake
  loop do

    # calculate the target coordinates and check if they are valid
    target_x = x + s * dx
    target_y = y + s * dy
    break unless coordValid(lake, target_x, target_y) && coordValid(lake, x, y)

    cell = lake[target_y][target_x]
    break unless cell.negative?

    max_block_height = [max_block_height, -cell].max
    s += 1
  end

  # checks if there are no blocks to wave over
  return if max_block_height.zero?

  # recalculate the target coordinates and check if they are valid
  target_x = x + s * dx
  target_y = y + s * dy
  return unless coordValid(lake, target_x, target_y) && coordValid(lake, x, y)

  height_diff = lake[y][x] - max_block_height
  return unless height_diff.positive? && lake[y][x] > lake[target_y][target_x]

  # calculate the transfer amount and update the lake
  transfer_amount = height_diff / 4
  lake[y][x] -= transfer_amount
  lake[target_y][target_x] += transfer_amount
end

# Simulate the wave in the lake.
def waveSim(lake)
  return if lake.empty?

  sizeY = lake.length
  sizeX = lake[0].length

  0.upto(sizeY - 1) do |y|
    0.upto(sizeX - 1) do |x|
      waveOverBlocks(lake, x, y, 0, -1)
      waveOverBlocks(lake, x, y, -1, 0)
      waveOverBlocks(lake, x, y, 0, 1)
      waveOverBlocks(lake, x, y, 1, 0)
    end
  end
end

# calculate the gradient of the lake
def gradient(lake, x, y, dx, dy)
  return 0 unless lake[y][x].negative?

  # calculate the coordinates and check if they are valid
  x1 = x + dx
  y1 = y + dy
  x2 = x - dx
  y2 = y - dy
  return 0 unless coordValid(lake, x1, y1) &&
                  coordValid(lake, x2, y2) &&
                  lake[y1][x1] >= 0 &&
                  lake[y2][x2] >= 0

  # calculate the gradient
  (lake[y1][x1] - lake[y2][x2]).abs
end

# Simulate the crush in the lake.
def crush(lake, strength)
  max_pressure = 0
  collapse_coords = nil

  # loop over the lake
  lake.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next unless coordValid(lake, x, y) && cell.negative?

      # calculate gradients and block pressure to check if block should collapse
      horizontal_gradient = gradient(lake, x, y, 1, 0)
      vertical_gradient = gradient(lake, x, y, 0, 1)
      block_pressure = [horizontal_gradient, vertical_gradient].max
      collapse_threshold = -cell * strength
      next unless block_pressure > collapse_threshold

      # update the maximum pressure and collapse coordinates
      if block_pressure > max_pressure
        max_pressure = block_pressure
        collapse_coords = [x, y]
      end
    end
  end
  return unless collapse_coords

  # collapse the block
  x, y = collapse_coords
  lake[y][x] = 0
end

# Run the simulation for the lake.
def runSimulation(lake, steps, wind, strength)
  0.upto(steps - 1) do
    flow(lake, 0, -1, 0)
    flow(lake, -1, 0, 0)
    flow(lake, 0, 1, 0)
    flow(lake, 1, 0, wind)
    waveSim(lake)
    crush(lake, strength)
  end
end

if __FILE__ == $PROGRAM_NAME
  lake = LAKE1
  0.upto(5) do
    runSimulation(lake, 18, 2, 3)
    display_lake(lake)
  end

  lake = LAKE2
  0.upto(5) do
    runSimulation(lake, 1, 0, 8)
    display_lake(lake)
  end

  lake = LAKE2
  0.upto(5) do
    runSimulation(lake, 1, 4, 8)
    display_lake(lake)
  end

  lake = LAKE3
  0.upto(5) do
    runSimulation(lake, 1, 4, 2)
    display_lake(lake)
  end
end
