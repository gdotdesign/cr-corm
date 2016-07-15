require "./ext/*"
require "./corm/classes/*"
require "./corm/*"

class Corm
  # Makes a class method crates an instance and delegates
  # the call to that
  macro instanced_method(name)
    def self.{{name}}(*args, **options)
      instance = new
      instance.{{name}}(*args, **options)
    end
  end

  # Creates methods for handling SQL functions like COUNT, MAX, MIN etc...
  macro sql_function(name, value)
    instanced_method {{name}}

    def {{name}}(*columns)
      columns.each do |column|
        case column
        when String
          {{name}} column
        when Column
          {{name}} column
        else
          raise IllegalSelect.new
        end
      end
      self
    end

    def {{name}}(column : String)
      raise NoTableDefined.new("{{name}}") unless @table
      {{name}}({@table.not_nil!, column})
    end

    def {{name}}(column : Column)
      method :select
      @selects << Function.new({{value}}, column)
      self
    end
  end

  # Available SQLFunctions
  enum SQLFunction
    Max
    Min
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

  getter! selects, joins, groups, wheres, columns, insert_values

  def initialize
    @selects = [] of Column | Function
    @insert_values = [] of PG::PGValue
    @columns = [] of Column
    @joins = [] of Join
    @groups = [] of Column
    @wheres = [] of Where
  end

  sql_function min, SQLFunction::Min
  sql_function max, SQLFunction::Max
  sql_function count, SQLFunction::Count

  # ----------------- GROUP -----------------------
  instanced_method group

  def group(column : String)
    raise NoTableDefined.new("group") unless @table
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
    raise NoTableDefined.new("select") unless @table
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
    raise NoTableDefined.new("where") unless @table
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
    raise TableAlreadyDefined.new(@table, value) if @table && @table != value
    @table = value
    self
  end

  def table
    @table
  end

  # ----------------- SCOPE ------------------------
  def scope
    Scope.new self
  end

  # ----------------- INSERT -----------------------
  instanced_method insert

  def insert(values = [] of PG::PGValue)
    method :insert
    raise "The size of columns and values don't match!" if values.size != @columns.size
    @insert_values.clear
    @insert_values.concat values
    self
  end

  # ----------------- COLUMNS ------------------------
  instanced_method columns

  def columns(*args)
    args.each do |arg|
      case arg
      when String
        columns arg
      when Column
        columns arg
      else
        raise "IllegalColumns"
        # raise IllegalSelect.new
      end
    end
    self
  end

  def columns(column : String)
    raise NoTableDefined.new("columns") unless @table
    columns({@table.not_nil!, column})
  end

  def columns(column : Column)
    @columns << column
    self
  end

  # ----------------- METHOD ------------------------
  private def method(value : Symbol)
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
