defmodule ReportFreelance do
  alias ReportFreelance.Parser

  @months [
    "janeiro",
    "fevereiro",
    "marco",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> calc_hours(line, report) end)
  end

  defp calc_hours([name, hour, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    key = String.downcase(name)

    all_hours = calc_all_hours(all_hours, key, hour)
    hours_per_month = calc_hours_per_month(hours_per_month, key, month, hour)
    hours_per_year = calc_hours_per_year(hours_per_year, key, year, hour)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp calc_all_hours(report, key, hour) do
    total_hours = get_total_hours(report[key])

    report
    |> Map.put(key, total_hours + hour)
  end

  defp calc_hours_per_month(report, key, month, hour) do
    user_key = get_user_key(report[key])
    month_key = Enum.at(@months, month - 1)
    total_hours = get_total_hours(report[key][month_key])

    months = Map.put(user_key, month_key, total_hours + hour)

    report
    |> Map.put(key, months)
  end

  defp calc_hours_per_year(report, key, year, hour) do
    user_key = get_user_key(report[key])
    total_hours = get_total_hours(report[key][year])

    years = Map.put(user_key, year, total_hours + hour)

    report
    |> Map.put(key, years)
  end

  defp get_total_hours(prev_hours), do: if(is_nil(prev_hours), do: 0, else: prev_hours)

  defp get_user_key(username), do: if(is_nil(username), do: %{}, else: username)

  defp report_acc, do: build_report(%{}, %{}, %{})

  defp build_report(all_hours, hours_per_month, hours_per_year),
    do: %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
end
