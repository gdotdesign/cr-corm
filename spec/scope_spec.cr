require "./spec_helper"

describe Corm::Scope do
  it "should create a clone to build a new statement" do
    statement = Corm.table("users")
                    .select("id", "name")

    scope = statement.scope
    new_statement = scope.count("id")
    statement.should_not eq(new_statement)

    assert_sql(
      statement,
      %(SELECT "users"."id", "users"."name" FROM "users"),
      [] of PG::PGValue
    )

    assert_sql(
      new_statement,
      %(SELECT "users"."id", "users"."name", COUNT("users"."id") FROM "users"),
      [] of PG::PGValue
    )
  end
end
