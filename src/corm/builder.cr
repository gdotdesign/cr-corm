class Corm
  module Builder
    struct Context
      property index
      property args

      def initialize(@index = 0, @args = [] of PG::PGValue)
      end

      def reset
        @index = 0
        @args.clear
      end
    end

    extend self

    @@context : Context | Nil

    def all(query)
      sql, args = build(query)

      Orm::Runner.run(sql, args).rows
    end

    def all(types, query)
      sql, args = build(query)

      Orm::Runner.run(types, sql, args).rows
    end

    def one(query)
      all(query).first
    end

    def column(column : Column)
      %("#{column[0]}"."#{column[1]}")
    end

    def column(obj : Function)
      "#{obj.function.to_s.upcase}(#{column obj.column})"
    end

    def build(query)
      context.reset

      sql = case query.method
            when :select
              ["SELECT",
                build_selects(query),
                "FROM",
                %("#{query.table}"),
                build_joins(query),
                build_wheres(query, context),
                build_groups(query),
              ].compact.join(" ").strip
            else
              ""
            end

      {sql, context.args}
    end

    def build_groups(query)
      return "" if query.groups.empty?

      groups = query.groups
                    .map { |group| column group }
                    .join(", ")

      %(GROUP BY #{groups})
    end

    def build_selects(query)
      query.selects.map { |col| column col }.join(", ")
    end

    def build_joins(query)
      query.joins.map do |join|
        %(INNER JOIN "#{join[0]}" ON #{column(join[1])} = #{column(join[2])})
      end.join(" ")
    end

    def build_wheres(query, context)
      return "" if query.wheres.empty?

      conditions = query.wheres.map do |where|
        context.index += 1
        context.args << where[2]
        %(#{column(where[0])} #{where[1]} $#{context.index})
      end.join(" AND ")

      %(WHERE #{conditions})
    end

    def context
      @@context ||= Context.new 0, [] of PG::PGValue
    end
  end
end
