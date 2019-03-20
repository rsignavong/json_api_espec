defmodule JsonApiEspec.Core.SubjectParser do
  alias JsonApiEspec.Core.Subject

  def parse(subject) do
    with {:ok, document} <- parse_document(subject),
         {:ok, jsonapi_version} <- parse_jsonapi_object(subject, "version"),
         {:ok, jsonapi_meta} <- parse_jsonapi_object(subject, "meta"),
         {:ok, meta} <- parse_meta(subject),
         {:ok, data_ids} <- parse_data_ids(subject, document),
         {:ok, data_meta} <- parse_data_field(subject, document, "meta"),
         {:ok, data_types} <- parse_data_field(subject, document, "type"),
         {:ok, data_attributes} <- parse_data_field(subject, document, "attributes"),
         {:ok, links_self} <- parse_links_self(subject, document),
         {:ok, links_self_href} <- parse_links_self_object(subject, document, "href"),
         {:ok, links_self_meta} <- parse_links_self_object(subject, document, "meta"),
         {:ok, relationships} <- parse_relationships(subject, document),
         {:ok, relationships_ids} <- parse_relationships_ids(subject, document),
         {:ok, relationships_meta} <- parse_relationships_meta(subject, document),
         {:ok, relationships_types} <- parse_relationships_types(subject, document),
         {:ok, relationships_links_self} <-
           parse_relationships_links_object(subject, document, "self"),
         {:ok, relationships_links_self_href} <-
           parse_relationships_links_object(subject, document, "self", "href"),
         {:ok, relationships_links_self_meta} <-
           parse_relationships_links_object(subject, document, "self", "meta"),
         {:ok, relationships_links_related} <-
           parse_relationships_links_object(subject, document, "related"),
         {:ok, relationships_links_related_href} <-
           parse_relationships_links_object(subject, document, "related", "href"),
         {:ok, relationships_links_related_meta} <-
           parse_relationships_links_object(subject, document, "related", "meta"),
         {:ok, included_ids} <- parse_included_ids(subject),
         {:ok, included_meta} <- parse_included_field(subject, "meta"),
         {:ok, included_types} <- parse_included_field(subject, "type"),
         {:ok, included_attributes} <- parse_included_field(subject, "attributes"),
         {:ok, included_links_self} <- parse_included_links_self(subject),
         {:ok, included_links_self_href} <- parse_included_links_self_object(subject, "href"),
         {:ok, included_links_self_meta} <- parse_included_links_self_object(subject, "meta"),
         {:ok, included_relationships} <- parse_included_relationships(subject),
         {:ok, included_relationships_ids} <- parse_included_relationships_ids(subject),
         {:ok, included_relationships_meta} <- parse_included_relationships_meta(subject),
         {:ok, included_relationships_types} <- parse_included_relationships_types(subject),
         {:ok, included_relationships_links_self} <-
           parse_included_relationships_links_object(subject, "self"),
         {:ok, included_relationships_links_self_href} <-
           parse_included_relationships_links_object(subject, "self", "href"),
         {:ok, included_relationships_links_self_meta} <-
           parse_included_relationships_links_object(subject, "self", "meta"),
         {:ok, included_relationships_links_related} <-
           parse_included_relationships_links_object(subject, "related"),
         {:ok, included_relationships_links_related_href} <-
           parse_included_relationships_links_object(subject, "related", "href"),
         {:ok, included_relationships_links_related_meta} <-
           parse_included_relationships_links_object(subject, "related", "meta"),
         {:ok, errors_ids} <- parse_errors_ids(subject),
         {:ok, errors_links_about} <- parse_errors_links_about(subject),
         {:ok, errors_status} <- parse_errors_object(subject, "status"),
         {:ok, errors_codes} <- parse_errors_object(subject, "code"),
         {:ok, errors_titles} <- parse_errors_object(subject, "title"),
         {:ok, errors_details} <- parse_errors_object(subject, "detail"),
         {:ok, errors_sources} <- parse_errors_object(subject, "source"),
         {:ok, errors_sources_pointers} <- parse_errors_source_object(subject, "pointer"),
         {:ok, errors_sources_parameters} <- parse_errors_source_object(subject, "parameter"),
         {:ok, errors_meta} <- parse_errors_meta(subject) do
      %Subject{
        document: document,
        jsonapi_version: jsonapi_version,
        jsonapi_meta: jsonapi_meta,
        meta: meta,
        data_ids: data_ids,
        data_meta: data_meta,
        data_types: data_types,
        data_attributes: data_attributes,
        links_self: links_self,
        links_self_href: links_self_href,
        links_self_meta: links_self_meta,
        relationships: relationships,
        relationships_ids: relationships_ids,
        relationships_meta: relationships_meta,
        relationships_types: relationships_types,
        relationships_links_self: relationships_links_self,
        relationships_links_self_href: relationships_links_self_href,
        relationships_links_self_meta: relationships_links_self_meta,
        relationships_links_related: relationships_links_related,
        relationships_links_related_href: relationships_links_related_href,
        relationships_links_related_meta: relationships_links_related_meta,
        included_ids: included_ids,
        included_meta: included_meta,
        included_types: included_types,
        included_attributes: included_attributes,
        included_links_self: included_links_self,
        included_links_self_href: included_links_self_href,
        included_links_self_meta: included_links_self_meta,
        included_relationships: included_relationships,
        included_relationships_ids: included_relationships_ids,
        included_relationships_meta: included_relationships_meta,
        included_relationships_types: included_relationships_types,
        included_relationships_links_self: included_relationships_links_self,
        included_relationships_links_self_href: included_relationships_links_self_href,
        included_relationships_links_self_meta: included_relationships_links_self_meta,
        included_relationships_links_related: included_relationships_links_related,
        included_relationships_links_related_href: included_relationships_links_related_href,
        included_relationships_links_related_meta: included_relationships_links_related_meta,
        errors_ids: errors_ids,
        errors_links_about: errors_links_about,
        errors_status: errors_status,
        errors_codes: errors_codes,
        errors_titles: errors_titles,
        errors_details: errors_details,
        errors_sources: errors_sources,
        errors_sources_pointers: errors_sources_pointers,
        errors_sources_parameters: errors_sources_parameters,
        errors_meta: errors_meta
      }
      |> (&{:ok, &1}).()
    else
      {:error, code} -> {:parse_error, code}
    end
  end

  defp parse_document(subject) do
    data = subject["data"]

    cond do
      is_map(data) ->
        {:ok, :primary}

      is_list(data) ->
        {:ok, :compound}

      true ->
        {:error, :document_type}
    end
  end

  defp parse_jsonapi_object(subject, field) when is_binary(field) do
    {:ok, subject["jsonapi"][field]}
  end

  defp parse_meta(subject) do
    {:ok, subject["meta"]}
  end

  defp parse_data_ids(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [data["id"]]

      :compound ->
        data
        |> map_ids()
    end
    |> (&{:ok, &1}).()
  end

  defp parse_data_field(subject, document, field)
       when is_atom(document) and field in ["type", "attributes", "meta"] do
    data = subject["data"]

    case document do
      :primary ->
        [{data["id"], data[field]}]

      :compound ->
        data
        |> map1_field(field)
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_links_self(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [{data["id"], subject["links"]["self"]}]

      :compound ->
        data
        |> map2_resources_field("links", "self")
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_links_self_object(subject, document, field)
       when is_atom(document) and field in ["href", "meta"] do
    data = subject["data"]

    case document do
      :primary ->
        [{data["id"], subject["links"]["self"][field]}]

      :compound ->
        data
        |> map3_resources_field("links", "self", field)
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [{data["id"], Map.keys(data["relationships"])}]

      :compound ->
        data
        |> map_resources_relationships()
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships_ids(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [map_relation_ids(data)]

      :compound ->
        data
        |> Enum.map(&map_relation_ids/1)
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships_meta(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [map_relation_meta(data)]

      :compound ->
        data
        |> Enum.map(&map_relation_meta/1)
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships_types(subject, document) when is_atom(document) do
    data = subject["data"]

    case document do
      :primary ->
        [map_relation_type(data)]

      :compound ->
        data
        |> Enum.map(&map_relation_type/1)
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships_links_object(subject, document, field)
       when is_atom(document) and field in ["self", "related"] do
    data = subject["data"]

    case document do
      :primary ->
        [map_relation_links_object(data, field)]

      :compound ->
        data
        |> Enum.map(&map_relation_links_object(&1, field))
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_relationships_links_object(subject, document, field1, field2)
       when is_atom(document) and field1 in ["self", "related"] and field2 in ["href", "meta"] do
    data = subject["data"]

    case document do
      :primary ->
        [map_relation_links_object(data, field1, field2)]

      :compound ->
        data
        |> Enum.map(&map_relation_links_object(&1, field1, field2))
    end
    |> tuples_list_to_ok_map()
  end

  defp parse_included_ids(subject) do
    included = subject["included"] || []

    included
    |> map_ids()
    |> (&{:ok, &1}).()
  end

  defp parse_included_field(subject, field)
       when field in ["type", "attributes", "meta"] do
    included = subject["included"] || []

    included
    |> map1_resources_field(field)
    |> tuples_list_to_ok_map()
  end

  defp parse_included_links_self(subject) do
    included = subject["included"] || []

    included
    |> map2_resources_field("links", "self")
    |> tuples_list_to_ok_map()
  end

  defp parse_included_links_self_object(subject, field) when field in ["href", "meta"] do
    included = subject["included"] || []

    included
    |> map3_resources_field("links", "self", field)
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships(subject) do
    included = subject["included"] || []

    included
    |> map_resources_relationships()
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships_ids(subject) do
    included = subject["included"] || []

    included
    |> Enum.map(&map_relation_ids/1)
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships_meta(subject) do
    included = subject["included"] || []

    included
    |> Enum.map(&map_relation_meta/1)
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships_types(subject) do
    included = subject["included"] || []

    included
    |> Enum.map(&map_relation_type/1)
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships_links_object(subject, field)
       when field in ["self", "related"] do
    included = subject["included"] || []

    included
    |> Enum.map(&map_relation_links_object(&1, field))
    |> tuples_list_to_ok_map()
  end

  defp parse_included_relationships_links_object(subject, field1, field2)
       when field1 in ["self", "related"] and field2 in ["href", "meta"] do
    included = subject["included"] || []

    included
    |> Enum.map(&map_relation_links_object(&1, field1, field2))
    |> tuples_list_to_ok_map()
  end

  defp parse_errors_ids(subject) do
    errors = subject["errors"] || []

    errors
    |> map_ids()
    |> (&{:ok, &1}).()
  end

  defp parse_errors_links_about(subject) do
    errors = subject["errors"] || []

    errors
    |> map2_field("links", "about")
    |> tuples_list_to_ok_map()
  end

  defp parse_errors_object(subject, field)
       when field in ["status", "code", "title", "detail", "source"] do
    errors = subject["errors"] || []

    errors
    |> map1_field("status")
    |> tuples_list_to_ok_map()
  end

  defp parse_errors_source_object(subject, field)
       when field in ["pointer", "parameter"] do
    errors = subject["errors"] || []

    errors
    |> map2_field("source", field)
    |> tuples_list_to_ok_map()
  end

  defp parse_errors_meta(subject) do
    errors = subject["errors"] || []

    errors
    |> map1_field("meta")
    |> tuples_list_to_ok_map()
  end

  defp map_ids(resources) when is_list(resources) do
    resources
    |> Enum.map(& &1["id"])
  end

  defp map1_field(resources, field) when is_list(resources) and is_binary(field) do
    resources
    |> Enum.map(& &1[field])
  end

  defp map2_field(resources, field1, field2)
       when is_list(resources) and is_binary(field1) and is_binary(field2) do
    resources
    |> Enum.map(&(&1 |> get_deep([field1, field2])))
  end

  defp map_resources_relationships(resources) when is_list(resources) do
    resources
    |> Enum.map(&{&1["id"], Map.keys(&1["relationships"])})
  end

  defp map1_resources_field(resources, field)
       when is_list(resources) and is_binary(field) do
    resources
    |> Enum.map(&{&1["id"], &1[field]})
  end

  defp map2_resources_field(resources, field1, field2)
       when is_list(resources) and is_binary(field1) and is_binary(field2) do
    resources
    |> Enum.map(&{&1["id"], &1 |> get_deep([field1, field2])})
  end

  defp map3_resources_field(resources, field1, field2, field3)
       when is_list(resources) and is_binary(field1) and is_binary(field2) and is_binary(field3) do
    resources
    |> Enum.map(&{&1["id"], &1 |> get_deep([field1, field2, field3])})
  end

  defp map_relation_meta(resource) when is_map(resource) do
    resource["relationships"]
    |> Enum.map(fn {relation, relation_object} ->
      {relation, relation_object["meta"]}
    end)
    |> Enum.into(%{})
    |> (&{resource["id"], &1}).()
  end

  defp map_relation_type(resource) when is_map(resource) do
    resource["relationships"]
    |> Enum.map(fn {relation, relation_object} ->
      data = relation_object["data"]

      cond do
        is_map(data) ->
          data["type"]

        is_list(data) ->
          data
          |> List.first()
          |> case do
            nil -> nil
            first -> first["type"]
          end

        is_nil(data) ->
          nil
      end
      |> (&{relation, &1}).()
    end)
    |> Enum.into(%{})
    |> (&{resource["id"], &1}).()
  end

  defp map_relation_links_object(resource, field)
       when is_map(resource) and is_binary(field) do
    resource["relationships"]
    |> Enum.map(fn {relation, relation_object} ->
      links_field = relation_object |> get_deep(["links", field])

      if is_binary(links_field) do
        links_field
      else
        nil
      end
      |> (&{relation, &1}).()
    end)
    |> Enum.filter(fn {_, w} -> not is_nil(w) end)
    |> Enum.into(%{})
    |> (&{resource["id"], &1}).()
  end

  defp map_relation_links_object(resource, field1, field2)
       when is_map(resource) and is_binary(field1) and is_binary(field2) do
    resource["relationships"]
    |> Enum.map(fn {relation, relation_object} ->
      links_field = relation_object |> get_deep(["links", field1, field2])

      if is_binary(links_field) do
        links_field
      else
        nil
      end
      |> (&{relation, &1}).()
    end)
    |> Enum.filter(fn {_, w} -> not is_nil(w) end)
    |> Enum.into(%{})
    |> (&{resource["id"], &1}).()
  end

  defp map_relation_ids(resource) when is_map(resource) do
    resource["relationships"]
    |> Enum.map(fn {relation, relation_object} ->
      data = relation_object["data"]

      cond do
        is_map(data) ->
          [data["id"]]

        is_list(data) ->
          data
          |> Enum.map(& &1["id"])

        is_nil(data) ->
          []
      end
      |> (&{relation, &1}).()
    end)
    |> Enum.into(%{})
    |> (&{resource["id"], &1}).()
  end

  defp tuples_list_to_ok_map(tuples) when is_list(tuples) do
    tuples
    |> Enum.filter(fn {_, w} -> not is_nil(w) end)
    |> Enum.into(%{})
    |> (&{:ok, &1}).()
  end

  defp get_deep(object, fields) when is_map(object) and is_list(fields) do
    try do
      object |> get_in(fields)
    rescue
      _ -> nil
    end
  end
end
