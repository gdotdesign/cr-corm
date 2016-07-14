class Corm
  class Function
    def_clone

    @function : SQLFunction
    @column : Column

    getter! function, column

    def initialize(@function = function, @column = column)
    end
  end
end
