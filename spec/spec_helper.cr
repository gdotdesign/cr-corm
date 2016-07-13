require "spec"
require "../src/corm"

macro assert_sql(statement, value, args)
  sql, args = {{statement}}.to_sql
  sql.should eq({{value}})
  args.should eq({{args}})
end

macro expects_to_change(expr, from, to)
  start_value = {{expr}}
  start_value.should eq({{from}})
  {{yield}}
  end_value = {{expr}}
  end_value.should eq({{to}})
end
