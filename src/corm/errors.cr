class Corm
  class NoTableDefined < Exception
    MESSAGE = %(There is no table defined at this point so
calling "[method]"" wouldn't know which table it references.\n)

    def initialize(method)
      @message = MESSAGE.gsub("[method]", method)
    end
  end

  class MethodAlreadyDefined < Exception
  end

  class IllegalSelect < Exception
  end
end
