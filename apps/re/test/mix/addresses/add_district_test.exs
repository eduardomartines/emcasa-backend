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
      covered_districts = [
        "Paraíso",
        "Pompeia",
        "Jardim Luzitania",
        "Vila Clementino",
        "Jardim Vila Mariana",
        "Jardim da Gloria",
        "Chácara Klabin"
      ]

      Enum.each covered_districts, fn district ->
        assert Repo.get_by(District, name: district)
      end
    end
  end
end
