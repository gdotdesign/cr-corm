require "./spec_helper"

describe Corm do
  it "build sql" do
    sql = Corm.table("users")
              .select("id", "name")
              .to_sql

    sql[0].should eq(%(SELECT "users"."id", "users"."name" FROM "users"))
  end
end
