defmodule JsonApiEspecTest do
  use ExUnit.Case
  doctest JsonApiEspec

  test "greets the world" do
    assert JsonApiEspec.hello() == :world
  end
  
  it(
          do:
            expect(
              json_api_response
              |> Jason.decode!()
            )
            |> to(
              have_resource_object(
                resource_object(post())
                |> with_type("posts")
                |> with_attributes([
                  :body,
                  :inserted_at,
                  :nb_descendants,
                  :title,
                  :vote_score,
                  :updated_at
                ])
                |> map_attribute({:nb_descendants, 0})
                |> map_attribute({:inserted_at, NaiveDateTime.to_iso8601(post().inserted_at)})
                |> map_attribute({:updated_at, NaiveDateTime.to_iso8601(post().updated_at)})
              )
            )
        )

        # it(
        #   do:
        #     expect(
        #       shared.response.resp_body
        #       |> Jason.decode!()
        #     )
        #     |> to(
        #       have_relationships(
        #         resource_object(post().id)
        #         |> with_relation(
        #           [relation: "organization",
        #            id: organization().id,
        #            type: "organizations",
        #            meta: %{},
        #            links:
        #           ]
        #         )
        #         |> with_relation(
        #           {"post-vote",
        #            relationship_object(vote_user_two().id)
        #            |> with_resource_type("post-votes")}
        #         )
        #         |> with_relation(
        #           {"user",
        #            relationship_object(user_one().id)
        #            |> with_resource_type("users")}
        #         )
        #       )
        #     )
        # )
      
  
end
