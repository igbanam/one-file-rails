<p align="center">
    <img height="300px" src="https://github.com/user-attachments/assets/01bcb959-b688-465b-b7e9-f6c3e26a6771" style="border: 2px solid grey;">
    <br>
</p>

<h1 align="center">One File Rails</h1>

This is a truly minimalist Rails application which has every thing in one
file. Rails is a one-person framework which allows you move fast from zero to
one. This takes the "quickly prototype" aspect of that previous statement and
puts it on steroids. Now, you can test that small idea you had without
dealing with everything `rails new` comes with. If you're like me, you're
thinking multiple things at once at this point. Microservices can now be
easily spun up and deaded with concepts like this. And… (my favourite)… it
may be possible to run Rails within shared hosting, if you can execute a ruby
script. Lastly, this shows you all it takes to get something on-screen using
Rails. Note that this is far from a secure application. You should never
NEVER do this in production. Use this as a learning tool, or a minimalist's
beginning; but build on it to use Rails in the way which best fits your
paradigm.

> [!CAUTION]
> Never run `OneFileRails`, as is, in production.

In this example, I create a file with a simple landing page, and a posts
resource. Posts here only has the index action which simply renders its
heading; but you can see how this could be easily built into the full
resource.

## How to Run

Running one-file-rails is simple. 

1. Clone
1. Run `rackup -p [PORT]`
    1. You should have the `rackup` gem installed

## The OneFileRails Application

### Dependencies

```ruby
require "bundler/inline"
```

Bring in all the gems we need.

This is made possible by bundler-inline.

Think of this the same way you would your Gemfile. This section can be as
verbose as that if you wish

```ruby
gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 8"
  gem "puma"
  gem "sqlite3"
end
```

Rails has grown over the years into a huge framework. Its convention brings in
a lot of best practices on what the framework thinks your app may need. With
OneFileRails you can choose to only bring in the parts of Rails you would need.

Here, I'm building a simple `M` (active_record), `V` (action_view), `C`
(action_controller) application. If you're building something which does not
have a view — say a service which only speaks JSON, and you can handle your
JSON templating in your own way — you don't need the V bit.

```ruby
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
```

### Data Store

I'd like to store my `M`s in a database. For simplicity, I'm using SQLite3.
This simply specifies the location of the database we would be using. If this
was MySQL or PostgreSQL, this would be the connection string without the
protocol. For other data management systems, this would be the identifier
string to your schema instance.

```ruby
database = "development.sqlite3"
```

#### rails db:setup

Ever wondered what happens when you run :point-up: this command when you're
starting a new application? Well, here's some barebones version of oit. We
create the database, connect to it, and ensure the schema is loaded. Now in
main Rails, there's the migrate step which would take your migration files
and create a schema out of it. That also manages our schema; giving us all
that goodness of rolling back changes to our schema structure. In this setup,
we do not have such goodness. We must ensure that our schema is up to date by
ourselves. We still have the beauty of specifying the schema using the DSL
Rails provides; so the regression is not at old-school PHP yet.

```ruby
ENV["DATABASE_URL"] = "sqlite3://#{database}"
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: database)
ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.text :body
    t.timestamps
  end
end
```

### Defining the OneFileRails application

Now we have our "infra" setup, we can define our application. Look how little
we need to get up and running! Now, compared to main rails, there are configs
for three different environments, and special initializers for specific
tooling we may need. In OneFileRails, we have one file, one environment, one
configuration. For now, all requests are local requests. If you're taking
OneFileRails to production, ensure you remove that. OneFileRails is also
based on Rails 8.0; which means you have all the nice things of Rails 8 with
OneFileRails.

```ruby
class OneFileRails < Rails::Application
  config.root = __dir__
  config.consider_all_requests_local = true
  config.secret_key_base = "b05c717ee236c33644094b2f32daf4a27a4f335adbec083c3be786cff353cb71bcbcc064036ffcf29ba5e35eb3ee60cbaf55fc3b66569ec47c90a7485d9a8172"
  config.load_defaults 8.0
  config.eager_load = true

  routes.append do
    root to: "welcome#index"
    resources :posts
  end
end
```

### The MVC Components

This section should be readily recognizable to modern web developers.  But to
flog a dead horse — and because _more content is good content_ — this section
defines the handlers behind what you see in the `routes.append` block above.
For simplicity, the response is from an inline rendering. How main Rails
handles this is to write the templated response in some other file, and use a
templating engine (most preferably ERB) to render this file to the response
format. Remember that what matters is the response sent through the HTTP
connection; it can be anything. In OneFileRails you have the flexibility to
design your responses in the best way you deem fit; free from the templating
engines, free from the view hierarchies, and other factors you may deem
constricting.

```ruby
class WelcomeController < ActionController::Base
  def index
    render inline: <<-HTML
      <h1>Welcome#index</h1>
    HTML
  end
end
```

Our Post model without any model-specific logic. 

```ruby
class Post < ActiveRecord::Base; end
```

This bit is the most exciting to me because this here is technically the data
layer in the application. There has been too much talk about ORM vs.
DataMapper, entities vs. models, and some other vs. battles which you're never
the one pushing the buttons or holding the controller (no pun intended). Now,
you can be free from all that noise and design your data layer the way you deem
fit. Notice that main Rails uses `ApplicationRecord` as a catch-all for all
model definitions; and that's conveniently missing here. With this, there's now
the possibility of having an `ApplicationRecord` if you deem fit, but also the
possibility of having a `SomeRecord`, `SomeMapper`, or `SomeRepository` as base
class.

```ruby
class PostsController < ActionController::Base
  def index
    render inline: <<-HTML
    <h1>Posts</h1>
    HTML
  end
end
```

With all that setup, we then initialize our application and run it as a Rack application. Sinatra folks would appreciate this, because this is how most Sinatra apps end up being run.

```ruby
OneFileRails.initialize!

run OneFileRails
```

## Why OneFileRails?

- Prototype ideas quicker
- Learn Rails internals
- Re-pattern the framework
  - Event-driven,
  - bounded-contexts,
  - modular-monolith,
  - fun-follows-function,
  - …are all possible
- Cherrypick ideas 

## Why not OneFileRails?

…basically invert everything in the previous section
