require "./corm/*"

class Corm
  # A class for reusing an already built partial query,
  # it forwards all calls to the given builder clone.
  class Scope
    def initialize(@builder : Orm)
    end

    macro method_missing(call)
      @builder.clone.{{call}}
    end
  end

  # Makes a class method crates an instance and delegates
  # the call to that
  macro instanced_method(name)
    def self.{{name}}(*args, **options)
      instance = new
      instance.{{name}}(*args, **options)
    end
  end

  enum SQLFunction
    Max
    Count
  end

  class Function
    def_clone

    @function : SQLFunction
    @column : Column

    getter! function, column

    def initialize(@function = function, @column = column)
    end
  end

  @table : String | Nil
  @method : Symbol | Nil

  alias Column = Tuple(String, String)
  alias Join = Tuple(String, Column, Column)
  alias Where = Tuple(Column, String, PG::PGValue)

  def_clone

  getter! selects, joins, groups, wheres

  def initialize
    @selects = [] of Column | Function
    @joins = [] of Join
    @groups = [] of Column
    @wheres = [] of Where
  end

  # ----------------- COUNT -----------------------
  instanced_method maximum

  def maximum(column : String)
    raise NoTableDefined.new unless @table
    maximum({@table.not_nil!, column})
  end

  def maximum(column : Column)
    @selects << Function.new(SQLFunction::Max, column)
    self
  end

  # ----------------- COUNT -----------------------
  instanced_method count

  def count(column : String)
    raise NoTableDefined.new unless @table
    count({@table.not_nil!, column})
  end

  def count(column : Column)
    @selects << Function.new(SQLFunction::Count, column)
    self
  end

  # ----------------- GROUP -----------------------
  instanced_method group

  def group(column : String)
    raise NoTableDefined.new unless @table
    group({@table.not_nil!, column})
  end

  def group(column : Column)
    @groups << column
    self
  end

  # ----------------- SELECTS ----------------------
  instanced_method select

  def select(*args)
    args.each do |arg|
      case arg
      when String
        select arg
      when Column
        select arg
      else
        raise IllegalSelect.new
      end
    end
    self
  end

  def select(column : String)
    raise NoTableDefined.new unless @table
    select({@table.not_nil!, column})
  end

  def select(column : Column)
    method :select
    @selects << column
    self
  end

  # ----------------- INNER JOIN -------------------
  instanced_method inner_join

  def inner_join(table, from, to)
    @joins << {table, from, to}
    self
  end

  # ----------------- WHERE ------------------------
  def where(column : Column, operator : String, value : PG::PGValue)
    @wheres << {column, operator, value}
    self
  end

  def where(column : String, operator : String, value : PG::PGValue)
    raise NoTableDefined.new unless @table
    where({@table.not_nil!, column}, operator, value)
  end

  def where(hash : Hash(String, PG::PGValue))
    hash.each do |key, value|
      where key, "=", value
    end
    self
  end

  # ----------------- TABLE ------------------------
  instanced_method table

  def table(value)
    @table = value
    self
  end

  def table
    @table
  end

  def scope
    Scope.new self
  end

  def method(value : Symbol)
    raise MethodAlreadyDefined.new if @method && @method != value
    @method = value
  end

  def method
    @method
  end

  def to_sql
    Builder.build(self)
  end

  def one
    Builder.one(self)
  end

  def all
    Builder.all(self)
  end

  def all(types)
    Builder.all(types, self)
  end
end
