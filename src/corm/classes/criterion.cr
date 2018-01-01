class Orm
  class Criterion
    @column : Column
    @operator : Symbol
    @siblings : Array(Criterion)
    @value : PG::PGValue

    def initialize(@column = column, @operator = @operator, @value = value)
      @siblings = [] of Criterion
    end

    def gt(value)
      @criterions << Criterion.new(@column, :gt, value)
    end
  end
end
