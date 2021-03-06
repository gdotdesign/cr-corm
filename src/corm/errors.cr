class Corm
  class NoTableDefined < Exception
    MESSAGE = %(There is no table set at this point so calling
"[METHOD]"" wouldn't know which table to reference.\n)

    def initialize(method)
      @message = MESSAGE.gsub("[METHOD]", method)
    end
  end

  class TableAlreadyDefined < Exception
    MESSAGE = %(Tried to set the table for this statement to "[NEW]"
but it has been already set to "[TABLE]"!\n)

    def initialize(table, value)
      @message = MESSAGE.gsub("[TABLE]", table)
                        .gsub("[NEW]", value)
    end
  end

  class MethodAlreadyDefined < Exception
    MESSAGE = %(Tried to set the type of the statement to "[NEW]"
but it has been alread set to "[METHOD]")

    def initialize(method, value)
      @message = MESSAGE.gsub("[METHOD]", method)
                        .gsub("[NEW]", value)
    end
  end

  class IllegalSelect < Exception
  end
end
