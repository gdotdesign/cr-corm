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
end
