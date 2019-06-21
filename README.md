# FieldMaskedModel

FieldMaskedModel provides masked accessor methods to model classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'field_masked_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install field_masked_model

## Usage

For example, you have .proto file shown below.

```proto
// proto
syntax = "proto3";
package organization.service;

option ruby_package = "UsersPb";

message User {
  int64 id = 1;
  string name = 2;
  int32 age = 3;
  Profile profile = 4;
}

message Profile {
  int64 id = 1;
  string introduction = 2;
}
```

By using `FieldMaskedModel::Base`, you can get model classes with masked accessor methods.

```ruby
# user.rb
class User < FieldMaskedModel::Base
  msgclass UsersPb::User
end

# profile.rb
class Profile < FieldMaskedModel::Base
  msgclass UsersPb::Profile
end
```

```ruby
$ u = User.new(
*   field_mask: Google::Protobuf::FieldMask.new(paths: ["id", "name", "profile.id", "profile.introduction"]),
*   message:    UsersPb::User.new(id: 3, name: "Taro", profile: UsersPb::Profile.new(id: 4, introduction: "My name is Taro")),
* )
=> <User
 id: 3,
 name: "Taro",
 age: -,
 profile: Profile>

$ u.id
=> 3

$ u.name
=> "Taro"

$ u.age
=> FieldMaskedModel::NotAccessibleError: age is not specified as paths in field_mask!

$ u.profile
=> <Profile
 id: 4,
 introduction: "My name is Taro">
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake true` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/south37/field_masked_model.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
