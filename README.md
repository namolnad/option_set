# OptionSet

OptionSet is a Ruby gem that provides a powerful and flexible way to handle sets of binary options (flags/permissions) in ActiveRecord models using bitmasks. It offers a clean DSL for defining and managing sets of options with efficient storage and rich set operations. Inspired by [Swift's OptionSet](https://developer.apple.com/documentation/swift/optionset) type.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'option_set'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Define Your Option Set

First, create a class that inherits from `OptionSet::Base` and define your options:

```ruby
class AdminPermission < OptionSet::Base
  view 1 << 0    # 1
  edit 1 << 1    # 2
  delete 1 << 2  # 4
end
```

### Set Up Your Model

Add an integer column to store the bitmask:

```ruby
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :admin_permissions_mask
    end
  end
end
```

Include the option set in your model:

```ruby
class User < ActiveRecord::Base
  option_set AdminPermission
end
```

### Using the Option Set

Basic operations:

```ruby
user = User.new
user.admin_permissions = [:view, :edit]  # Set multiple permissions
user.has_admin_permission?(:view)        # => true
user.admin_permission_view?              # => true
user.admin_permission_delete?            # => false

# Add/Remove individual permissions
user.add_admin_permission(:delete)
user.remove_admin_permission(:edit)

# Bang methods for immediate save
user.admin_permission_edit!  # Adds :edit permission and saves
```

Set Operations:

```ruby
# Intersection
user.admin_permissions_intersection([:view, :delete])

# Union
user.admin_permissions_union([:delete])

# Difference
user.admin_permissions_difference([:view, :delete])

# Symmetric Difference
user.admin_permissions_symmetric_difference([:view, :delete])

# Set Comparisons
user.admin_permissions_subset?([:view, :edit, :delete])
user.admin_permissions_superset?([:view])
user.admin_permissions_disjoint?([:delete])

# Bulk Operations
user.merge_admin_permissions([:edit, :delete])
user.subtract_admin_permissions([:view, :edit])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/namolnad/option_set. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/namolnad/option_set/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OptionSet project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/option_set/blob/main/CODE_OF_CONDUCT.md).
