import 
  std/random,
  std/strformat,
  std/strutils

const SIDE = 25

type Pixel = object
  r: uint8
  g: uint8
  b: uint8

proc `$`(self: Pixel): string =
  result &= char(self.r)
  result &= char(self.g)
  result &= char(self.b)

proc to_pixel(self: string): Pixel =
  result.r = uint8(parse_hex_int(self[0 .. 1]))
  result.g = uint8(parse_hex_int(self[2 .. 3]))
  result.b = uint8(parse_hex_int(self[4 .. 5]))

type WangTile = uint8

proc up(self: WangTile): uint8 =
  (self and 0b1000) shr 3

proc right(self: WangTile): uint8 =
  (self and 0b0100) shr 2

proc down(self: WangTile): uint8 =
  (self and 0b0010) shr 1

proc left(self: WangTile): uint8 =
  (self and 0b0001)

type WangRender = seq[string]
type WangGrid = seq[seq[WangTile]]
type WangRenderGrid = seq[seq[WangRender]]

proc gen_tile(tile: WangTile, side: int, col1, col2: Pixel): WangRender =
  let 
    up_col    = if tile.up == 1: col1 else: col2 
    right_col = if tile.right == 1: col1 else: col2 
    down_col  = if tile.down == 1: col1 else: col2 
    left_col  = if tile.left == 1: col1 else: col2 
  
  var 
    middle = side
    sides = 0
    top_half = true

  for row in 0..<side:
    var cur_row = ""
    for col in 0..<side:
      if col < sides:
        cur_row &= $left_col
      elif col < sides + middle:
        if top_half:
          cur_row &= $up_col
        else:
          cur_row &= $down_col
      else:
        cur_row &= $right_col

    result.add(cur_row)

    if top_half:
      middle -= 2
      sides += 1
      if middle < 2:
        top_half = false
    else:
      middle += 2
      sides -= 1


proc generate_ppm(filename: string, tile_grid: WangRenderGrid) =
  let f = open(filename & ".ppm", fmWrite)
  defer: f.close

  let
    height = tile_grid.len * SIDE
    width = tile_grid[0].len * SIDE

  f.write_line("P6")
  f.write_line(fmt"{width} {height}")
  f.write_line("255")
  for i in 0..<tile_grid.len:
    var strings: seq[string] = tile_grid[i][0]
    for j in 1..<tile_grid[i].len:
      for idx, str in tile_grid[i][j]:
        strings[idx] &= str
    for str in strings:
      f.write(str)


proc random_tile_with(left, up: uint8): WangTile =
  let
    right = rand(1)
    down = rand(1)
  
  result += uint8(left)
  result += uint8(down * 2)
  result += uint8(right * 4)
  result += uint8(up * 8)

proc random_tile_with_left(left: uint8): WangTile =
  let up = rand(1).uint8
  random_tile_with(left, up)

proc random_tile_with_up(up: uint8): WangTile =
  let left = rand(1).uint8
  random_tile_with(left, up)

proc gen_tile_grid(rows, cols: int): WangGrid =
  if rows == 0 or cols == 9: return
  randomize()
  # Prepare the seq, there must be a better way 
  # to do this, but my head is tired
  result = newSeq[seq[WangTile]](rows)
  for i in 0..<rows:
    result[i] = newSeq[WangTile](cols)
  for row in 0..<rows:
    for col in 0..<cols:
      if row + col == 0:
        # start with a random tile
        result[row][col] = rand(1..15).uint8
      elif row == 0:
        let left = result[row][col - 1].right
        result[row][col] = random_tile_with_left(left)
      elif col == 0:
        let up = result[row - 1][col].down
        result[row][col] = random_tile_with_up(up)
      else:
        let
          left = result[row][col - 1].right
          up = result[row - 1][col].down
        result[row][col] = random_tile_with(left, up)

  
proc render(grid: WangGrid, col1, col2: Pixel): WangRenderGrid =
  for row in grid:
    var cur_col: seq[WangRender] = @[]
    for tile in row:
      cur_col.add(gen_tile(tile, SIDE, col1, col2))
      #cur_col.add(gen_tile(1u8, SIDE, col1, col2))
    result.add(cur_col)

proc main =
  let col1 = "bf616a".to_pixel
  let col2 = "ebcb8b".to_pixel
  echo "Generating wang-grid.ppm"
  echo " - Randomizing grid"
  let grid = gen_tile_grid(40, 70)
  echo " - Rendering grid"
  let render_grid = render(grid, col1, col2)
  echo " - Creating file"
  generate_ppm("wang-grid", render_grid)

if isMainModule:
  main()
