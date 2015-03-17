require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      smush(@params, parse_www_encoded_form(req.query_string)) if req.query_string
      smush(@params, parse_www_encoded_form(req.body)) if req.body
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      partial_params_hash = {}

      URI.decode_www_form(www_encoded_form).each do |a|
          vals = parse_key(a[0]) << a[1]
          smush(partial_params_hash, nest(vals))
      end

      partial_params_hash
    end

    def nest(array)
      return array.first if array.length == 1
      {}.tap do |hash|
        hash[array.shift] = nest(array)
      end
    end

    # expects input as in @params
    def smush(hash1, hash2)
      hash1.merge!(hash2) do |key, val1, val2|
        smush(val1, val2)
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
