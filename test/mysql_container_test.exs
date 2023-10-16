defmodule Testcontainers.MySqlContainerTest do
  use ExUnit.Case, async: true

  import Testcontainers.ExUnit
  alias Testcontainers.Container.MySqlContainer

  @tag timeout: 300_000

  describe "with default configuration" do
    container(:mysql, MySqlContainer.new())

    test "provides a ready-to-use mysql container", %{mysql: mysql} do
      {:ok, pid} = MyXQL.start_link(MySqlContainer.connection_parameters(mysql))

      assert %{num_rows: 1} = MyXQL.query!(pid, "SELECT 1", [])
    end
  end

  describe "with custom configuration" do
    @custom_mysql MySqlContainer.new("mysql/mysql-server:8.0.32-1.2.11-server",
                    username: "custom-user",
                    password: "custom-password",
                    database: "custom-database"
                  )
    container(:mysql, @custom_mysql)

    test "provides a mysql container compliant with specified configuration", %{mysql: mysql} do
      {:ok, pid} =
        MyXQL.start_link(
          username: "custom-user",
          password: "custom-password",
          database: "custom-database",
          hostname: "localhost",
          port: MySqlContainer.port(mysql)
        )

      query_result = MyXQL.query!(pid, "SELECT version()", [])

      version_info = query_result.rows |> Enum.at(0) |> Enum.at(0)
      assert version_info =~ "8.0.32"
    end
  end
end
