require 'sinatra'
require 'sinatra/reloader'
require 'phlex'
require 'sinatra/activerecord'
require 'faker'
require 'digest/md5'

class User < ActiveRecord::Base
  has_many :tweets
end

class Tweet < ActiveRecord::Base
  belongs_to :user
end

set :database, {adapter: "sqlite3", database: "tweets.sqlite3"}

module Views
  class Layout < Phlex::HTML
    def initialize(title:)
      @title = title
    end

    def template
      doctype
      head_template

      body class: "mt-8" do
        div class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" do
          div class: "mx-auto max-w-3xl" do
            yield
          end
        end
      end
    end

    def head_template
      head do
        title { @title }
        script src: "https://cdn.tailwindcss.com"
      end
    end
  end

  class Index < Phlex::HTML
    def initialize(tweets:)
      @tweets = tweets
    end

    def template
      render Layout.new(title: "Phlex/Sinatra Twitter Clone") do
        h1 class: "text-3xl font-bold" do
          "Updates"
        end

        render Tweets::Form.new
        render Tweets::List.new(@tweets)
      end
    end
  end

  module Tweets
    class List < Phlex::HTML
      def initialize(tweets)
        @tweets = tweets
      end

      def template(&)
        ul role: "list", class: "divide-y divide-gray-200" do
          @tweets.each { |tweet| item_template(tweet) }
        end
      end

      private

      def item_template(tweet)
        li class: "py-4" do
          div class: "flex space-x-3" do
            render Gravatar.new(email: tweet.user.email)
            div class: "flex-1 space-y-1" do
              div class: "flex items-center justify-between" do
                h3(class: "text-sm font-medium") { tweet.user.name }
                p class: "text-sm text-gray-500" do
                  text tweet.created_at
                end
              end
              p class: "text-sm text-gray-500" do
                text tweet.content
              end
            end
          end
        end
      end
    end

    class Form < Phlex::HTML
      def template
        form action: "/tweets", method: "post" do
          div do
            label for: "comment", class: "block text-sm font-medium text-gray-700 mt-4" do
              text "What's on your mind?"
            end
            div class: "mt-1" do
              textarea rows: "4", name: "content", class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-cyan-400 focus:ring-cyan-400 sm:text-sm"
            end
          end
          div class: "mt-4" do
            button class: "inline-flex items-center rounded-md border border-transparent bg-cyan-400 px-6 py-3 text-base font-medium text-gray-900 shadow-sm hover:bg-cyan-400 focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:ring-offset-2" do
              "Send it!"
            end
          end
        end
      end
    end
  end

  class Gravatar < Phlex::HTML
    def initialize(email:)
      @email = email
    end

    def template
      img class: "h-6 w-6 rounded-full", src: image_src
    end

    private

    def image_src = "https://www.gravatar.com/avatar/#{hash}"
    def hash = Digest::MD5.hexdigest(@email)
  end
end

def current_user
  # Generate random users
  User.find_or_create_by!(
    email: Faker::Internet.email,
    name: Faker::Name.name,
    username: Faker::Internet.username,
  )

  @current_user ||= User.find(User.ids.sample)
end

get '/' do
  Views::Index.new(
    tweets: Tweet.order(id: :desc)
  ).call
end

post '/tweets' do
  current_user.tweets.create(content: params[:content])
  redirect '/'
end
