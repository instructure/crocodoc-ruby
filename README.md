# Crocodoc Ruby

This is a ruby library for interacting with v2 of the [Crocodoc](https://crocodoc.com) API.

## Rails Installation

Add this line to your application's Gemfile:

    gem 'crocodoc-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crocodoc-ruby

## Configuration

    $ rails g crocodoc:install --api-token your_token_here

The generator adds two files for your rails project:

* config/crocodoc.yml
* config/initializers/crocodoc.rb

Customise the config/crocodoc.yml config file if you wish to use different API tokens per environment (by default it uses the same token in development, test and production).

### Rails application

The Crocodoc API is configured during rails initialization, and no further configuration is nessecary before use.

### Non-rails application

When using the Crocodoc gem in a non-rails application, you must configure it to use your Crocodoc Token manually:

```ruby
Crocodoc.configure do |config|
    config.token = 'MY_CROCODOC_TOKEN'
end
```

## Usage

Once configured, you can start using the API:

### Upload a document

```ruby
crocodoc = Crocodoc::API.new
doc = crocodoc.upload("http://www.example.com/test.doc")

# => {"uuid"=>"732b17dd-1fd6-49b1-8a2f-58ec9f6dc381"}
```

### Get the status of a document

```ruby
crocodoc.status('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')

# => {"status"=>"DONE", "viewable"=>true, "uuid"=>"732b17dd-1fd6-49b1-8a2f-58ec9f6dc381"}
```

### Delete a document

```ruby
crocodoc.delete('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')

# => true
```

### Create a session

```ruby
crocodoc_session = crocodoc.session('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')

# => { "session": "CFAmd3Qjm_2ehBI7HyndnXKsDrQXJ7jHCuzcRv_V4FAgbSmaBkFrDRS8KX8m-Ur9MdZFbH3ykKdZ7cZswFqrDKX965nba9-MW0DiiA" }
```

### View a document

```ruby
url = crocodoc.view('CFAmd3Qjm_2ehBI7HyndnXKsDrQXJ7jHCuzcRv_V4FAgbSmaBkFrDRS8KX8m-Ur9MdZFbH3ykKdZ7cZswFqrDKX965nba9-MW0DiiA')
```

### Download a document

```ruby
download_url = crocodoc.download('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')
```

### Download a document thumbnail

```ruby
download_url = crocodoc.thumbnail('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')
```

### Download extracted text

```ruby
document_text = crocodoc.text('732b17dd-1fd6-49b1-8a2f-58ec9f6dc381')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
