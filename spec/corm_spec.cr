require "./spec_helper"

describe Corm do
  describe "#select" do
    context "single string vlaue" do
      context "no table defined" do
        it "should raise error" do
          expect_raises(Corm::NoTableDefined) { Corm.select("id") }
        end
      end

      context "table defined" do
        it "should add a new column" do
          statement = Corm.table("users")

          expects_to_change(
            statement.selects,
            from: [] of Corm::Column,
            to: [{"users", "id"}]) { statement.select("id") }
        end
      end
    end

    context "single column value" do
      it "should add a new column" do
        statement = Corm.new

        expects_to_change(
          statement.selects,
          from: [] of Corm::Column,
          to: [{"users", "id"}]) { statement.select({"users", "id"}) }
      end
    end

    context "multiple varied arguments" do
      context "invalid argument" do
        it "should throw an error" do
          expect_raises(Corm::IllegalSelect) do
            Corm.table("users")
                .select(32)
          end
        end
      end
    end
  end

  describe "#table" do
    context "not yet set" do
      it "should set table" do
        statement = Corm.new

        expects_to_change(statement.table, nil, "users") do
          statement.table("users")
        end
      end
    end

    context "already set" do
      it "should raise error" do
        expect_raises(Corm::TableAlreadyDefined) do
          Corm.table("users")
              .table("projects")
        end
      end
    end
  end

  describe "#max, #min, #count" do
    context "no table defined" do
      it "should raise error" do
        expect_raises(Corm::NoTableDefined) { Corm.count("id") }
      end
    end

    context "table defined" do
      it "should build sql functions into select queries" do
        statement = Corm.table("users")

        expects_to_change(statement.selects.size, from: 0, to: 1) do
          statement.count("id")
        end
      end
    end
  end

  describe "#where" do
    it "should collect arguments have palceholder for them" do
      statement = Corm.table("users")
                      .select("id", "name")

      expects_to_change(
        statement.wheres,
        from: [] of Tuple(Corm::Column, String, PG::PGValue),
        to: [{ {"users", "id"}, "=", 10 }]) do
        statement.where({"id" => 10})
      end
    end
  end
end
