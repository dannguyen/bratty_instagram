Batch search Instagram for users. Based off of [propublica/qis](//github.com/propublica/qis)

## Dev instalation

0. `bundle install`

1. Register for a new [Instagram client application](http://instagram.com/developer/clients/register/) and set your OAuth redirect_uri to `http://localhost:4567/`.

2. Create a `keys.yml` file in the root of the app:

```
client_id: clientIDID8324434
client_secret: clientSECRET908324
redirect_uri: http://localhost:4567/
```

2. Run using `ruby app.rb` or however you like running Sinatra apps.

## License (MIT)

Copyright (c) 2013 ProPublica

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
