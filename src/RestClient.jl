
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
  function save(api::Api, collection::Collection, data::Dict; id::String="")

      uri = string(api.base_uri, "/", collection.name,
                   id == "" ? "" : string("/", id))

      if id == ""
          r = post(uri; data = data)
          if r.status == 201
              return parse(r.data)
          end
      else
          r = put(uri; data = data)
          if r.status == 200
              return parse(r.data)
          end
      end

      error(string("Unable to save object: ",
                   parse(r.data)["message"]))
  end

  # ---------------------------------------------------------------------------
  # Load an object from a collection given the id.
  function load(api::Api, collection::Collection, id::String)

      uri = string(api.base_uri, "/", collection.name, "/", id)

      r = get(uri)
      if r.status == 200
          return parse(r.data)
      end

      error(string("Unable to load object: ",
                   parse(r.data)["message"]))
  end

  # ---------------------------------------------------------------------------
  # List objects in a given collection.
  function list(api::Api, collection::Collection)

      uri = string(api.base_uri, "/", collection.name)

      r = get(uri)
      if r.status == 200
          return parse(r.data)
      end

      error(string("Unable to list objects: ",
                   parse(r.data)["message"]))
  end
end
