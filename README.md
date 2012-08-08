# Crocodoc Ruby

This is a ruby library for interacting with v2 of the [Crocodoc](https://crocodoc.com) API.

## Installation

The gem is packaged as the `crocodoc-ruby` gem, so you could install it with
a gemfile + bundler:

  gem 'crocodoc-ruby', :require => 'crocodoc'

## Usage

```ruby
crocodoc = Crocodoc::API.new(:token => 'your-api-token')
doc = crocodoc.upload("http://www.example.com/test.doc")
stat = crocodoc.status(doc['uuid'])
sesh = crocodoc.session(doc['uuid'])
url = crocodoc.view(sesh['session'])
crocodoc.delete(doc['uuid'])
```
