# Ariadne

Follow your code with the Ariadne's Thread! 🧵

![example](public/output.png)

## Usage

Run it with:

```ruby
require 'ariadne/thread'

# Initialize a new Ariadne Thread
thread = Ariadne::Thread.new

# Or if you want to output only when the code is in specific paths or when it is not,
# use the params `include_paths` and `exclude_paths`/
# The default path is the root of the repository,
# in order not to display logs from the gems.
thread = Ariadne::Thread.new(
  include_paths: ["app/models", "app/services"],
  exclude_paths: ["app/services/helpers"],
)

# Then, pass a block to the #call method to output the thread
thread.call do
  Services::CreateUsers.new(names: ["Jane Doe"]).call do |user|
    user.role = :engineer
    user.admin = true
  end
end
#  0 Services::CreateUsers#initialize(names: Array) -> Array
#  1 Services::CreateUsers#call -> Boolean
#  2 - User.build(name: String) -> User
#  3 -- User#initialize(name: String) -> String
#  4 -- User.generate_access_key -> Integer
#  5 -- User#access_key=(value: Integer) -> Integer
#  6 - User#role=(value: Symbol) -> Symbol
#  7 - User#admin=(value: Boolean) -> Boolean
#  8 - Services::CreateUsers#generate_email(user: User) -> String
#  9 -- Services::GenerateEmail#initialize(user: User) -> User
# 10 -- Services::GenerateEmail#call -> String
# 11 --- Services::GenerateEmail#domain -> String
# 12 - User#email=(value: String) -> String
# 13 - User.import(users: Array) -> Boolean
# 14 -- User#validate -> Boolean
# 15 --- User#access_key? -> Boolean

# read the seams (1 method call -> 1 seam)
seams = thread.seams
seams.size # 16
seams.map(&:depth).max # 3
seams.map(&:klass).uniq # [Services::CreateUsers, User, Services::GenerateEmail]
```

Reading the logs:

* `8` is the iteration. Each time a method is called, it adds 1.
* `-` is the depth (one dash by level of depth). It starts at 0. Each time a method is called inside another method, it adds a level of depth.
* `Services::CreateUsers` is the name of the class.
* `#` is the method prefix (`.` for a class method, `#` for an instance method).
* `generate_email` is the name of the method.
* `user` is the name of the parameter.
* `User` is the type of the argument passed for this parameter.
* `-> String` is the type of the value returned by the method.

The logs are outputed in the terminal and in the `thread.log` file.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem "ariadne"
end
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install ariadne
```

## Contributing

This gem is still a work in progress. You can use GitHub issue to start a discussion.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
