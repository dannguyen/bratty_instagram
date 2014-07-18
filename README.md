Batch search Instagram for users. Based off of [propublica/qis](//github.com/propublica/qis)

## Dev installation

0. `bundle install`

1. Register for a new [Instagram client application](http://instagram.com/developer/clients/register/) and set your OAuth redirect_uri to `http://localhost:4567/`.

2. Create a `keys.yml` file in the root of the app:

```
client_id: clientIDID8324434
client_secret: clientSECRET908324
redirect_uri: http://localhost:4567/
```

2. To start up a server:         
   ```
   $  thin start
   ```

3. To play with in `pry`:
   ```
   $   pry
   > require './app'   
   ```

## Quick Dev stuff

Once in `pry`, you can use this shortcut to quickly instantiate one of the online service API clients to test things out:

```ruby

  # load up the entire Sinatra app, including the routes to the
  # auth key files
  require './app' 
  # instantiate an instance of the Twitter::Client
  tclient = BrattyDev.init_client('twitter')
  # get Skift user profile from Twitter API
  raw_user_object = tclient.user('skift')  
  
  puts raw_user_object.to_h
  # {:id=>374822255,
  #  :id_str=>"374822255",
  # :name=>"Skift",
  # :screen_name=>"skift",
  # :location=>"New York City, NY",
  # :description=>
  #  "Global travel industry intelligence: News, info, data and analysis on airlines, hotels, tourism, cruises, startups, tech and more. Follow @SkiftStats for stats.",
  # :url=>"http://t.co/nLTVfbYR5u",
  # ...

```



TODO:
- HTTP interface via simple_api_endpoint does not pass in options
- Write Ruby methods to transform JSON to flattened values
