
class Cost < Base
  self.attributes = {
    red: 0,
    white: 0,
    black: 0,
    green: 0,
    blue: 0,
    colorless: 0,
    x: 0,
    other: nil
  }

  # √
  def converted
    red + white + black + green + blue + colorless
  end
end