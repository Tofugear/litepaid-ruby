# LitePaid API Client for Ruby

Accept Bitcoin, Litecoin, Dogecoin, DigiBytes and more through the LitePaid service - a fast and easy way to accept digital currencies.

Before you use this Gem you must create a [LitePaid](https://litepaid.com/) account and setup a Website Profile to obtain your API key.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'litepaid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install litepaid

## Usage

Require the LitePaid API Client:

```ruby
require 'litepaid'
```

Initialize the LitePaid API Client with your API key:

```ruby
litepaid = Litepaid::Client.new("628fe07656a3ab97eaed93e799d4c64118913248814adbeb92f07abc3752de00")
```

Create a Payment:

```ruby
payment = litepaid.payments.create(
  value: 10.0,
  description: 'My Test Payment',
  currency: 'usd',
  return_url: 'https://shop.mysite.com/payment/result'
)
```

Check payment status:

```ruby
payment = litepaid.payments.get('2521c073c096921cebfe')
```

Refund a payment:

``` ruby
refund = litepaid.refunds.create(
  id: '2521c073c096921cebfe'
  address: 'DLvbw3sEcjBs8e6YGnb123456789012345'
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/tofugear/litepaid-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
