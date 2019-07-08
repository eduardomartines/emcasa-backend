defmodule Mix.Tasks.Re.Addresses.AddDistrictTest do
  use Re.ModelCase

  alias Mix.Tasks.Re.Addresses.AddDistrict

  alias Re.{
    Addresses.District,
    Repo
  }

  setup do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end

  describe "run/1" do
    test "inserts district" do
      AddDistrict.run([])

      partially_covered_districts = [
        "Chácara Klabin"
      ]

      covered_districts = [
        "Paraíso",
        "Pompeia",
        "Jardim Luzitania",
        "Vila Clementino",
        "Jardim Vila Mariana",
        "Jardim da Gloria"
      ]

      Enum.each partially_covered_districts, fn district ->
        assert Repo.get_by(District, name: district)
      end

      Enum.each covered_districts, fn district ->
        assert Repo.get_by(District, name: district)
      end
    end
  end
end
