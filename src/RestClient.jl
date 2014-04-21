
module RestClient
  import Requests: post, put, get
  import JSON: json, parse

  # Export public types and functions
  export Api, Collection, save, load, list

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Api type
  type Api
      base_uri::String

      #  Strip trailing slashes from the base URI
      Api(base_uri) = new(base_uri[end] == '/' ? base_uri[1:end-1] : base_uri)
  end


  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Collection type
  type Collection
      name::String
  end

  # ---------------------------------------------------------------------------
  # Save an object in a collection either updating the object or creating a new
  # one.
  function save(api::Api, collection::Collection, data::Dict; id::String="",
                json::Bool=true)

      uri = string(api.base_uri, "/", collection.name,
                   id == "" ? "" : string("/", id))

      if id == ""
          r = post(uri; data = data)
          if r.status == 201
              return json ? parse(r.data) : r.data
          end
      else
          r = put(uri; data = data)
          if r.status == 200
              return json ? parse(r.data) : r.data
          end
      end

      error("Save faild: $(r.data)")
  end

  # ---------------------------------------------------------------------------
  # Load an object from a collection given the id.
  function load(api::Api, collection::Collection, id::String;
                sub_resource::String="", json::Bool=true)

      uri = string(api.base_uri, "/", collection.name, "/", id, 
                   sub_resource != "" ? string("/", sub_resource) : "")

      r = get(uri)
      if r.status == 200
          return json ? parse(r.data) : r.data
      end

      error("Load failed: $(r.data)")
  end

  # ---------------------------------------------------------------------------
  # List objects in a given collection.
  function list(api::Api, collection::Collection; json::Bool=true)

      uri = string(api.base_uri, "/", collection.name)

      r = get(uri)
      if r.status == 200
          return json ? parse(r.data) : r.data
      end

      error("List failed: $(r.data)")
  end
end
