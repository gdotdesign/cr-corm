require "./spec_helper"

describe Corm do
  describe "#select" do
    it "should raise error if the table is not defined" do
      expect_raises do
        Corm.select("id")
      end
    end
  end

  it "build sql" do
    sql = Corm.select("id", "name")
              .to_sql

    sql[0].should eq(%(SELECT "users"."id", "users"."name" FROM "users"))
  end

  describe "SQL functions" do
    it "should build sql functions into select queries" do
      sql = Corm.table("users")
                .count("id")
                .to_sql

      sql[0].should eq(%(SELECT COUNT("users"."id") FROM "users"))
    end
  end

  describe "Arguments" do
    it "should collect arguments have palceholder for them" do
      sql = Corm.table("users")
                .select("id", "name")
                .where({"id" => 10})
                .to_sql

      sql[0].should eq(%(SELECT "users"."id", "users"."name" FROM "users" WHERE "users"."id" = $1))
      sql[1].should eq [10]
    end
  end
end
