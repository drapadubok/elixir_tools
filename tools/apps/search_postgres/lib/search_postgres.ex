defmodule SearchPostgres do

  alias Contact # Ecto model

  def search(query, ""), do: query
  def search(query, search_query) do
    search_query = ts_query_format(search_query)

    query
    |> where(
      fragment(
        """
        (to_tsvector(
        'english',
        coalesce(first_name, '') || ' ' ||
        coalesce(last_name, '') || ' ' ||
        coalesce(location, '') || ' ' ||
        coalesce(headline, '') || ' ' ||
        coalesce(email, '') || ' ' ||
        coalesce(phone_number, '')
        ) @@ to_tsquery('english', ?))
        """,
        ^search_query
      )
    )
  end

  defp ts_query_format(search_query) do
    search_query
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&("#{&1}:*"))
    |> Enum.join(" & ")
  end

  def index(conn, params) do
    search = Map.get(params, "search", "")

    page = Contact
      |> Contact.search(search)
      |> order_by(:first_name)
      |> Repo.paginate(params)

    page
  end
end
