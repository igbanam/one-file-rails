# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 8"
  gem "puma"
  gem "sqlite3"
end

require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

database = "development.sqlite3"

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

class Post < ActiveRecord::Base; end

class WelcomeController < ActionController::Base
  def index
    render inline: <<-HTML
      <h1>Welcome#index</h1>
    HTML
  end
end

class PostsController < ActionController::Base
  def index
    render inline: <<-HTML
    <h1>Posts</h1>
    HTML
  end
end

OneFileRails.initialize!

Rails.application.routes.routes.map do |route|
  {
    verb: route.verb,
    path: route.path.spec.to_s,
    controller: route.defaults[:controller],
    action: route.defaults[:action],
  }
end.each { |route| p route }

run OneFileRails
