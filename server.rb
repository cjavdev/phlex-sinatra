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

class GravatarComponent < Phlex::Component
  def initialize(email:)
    @email = email
  end

  def template
    # Generate a gravatar url
    hash = Digest::MD5.hexdigest(@email)
    image_src = "https://www.gravatar.com/avatar/#{hash}"
    img class: "h-6 w-6 rounded-full", src: image_src
  end
end

class FormComponent < Phlex::Component
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
        button "Send it!", class: "inline-flex items-center rounded-md border border-transparent bg-cyan-400 px-6 py-3 text-base font-medium text-gray-900 shadow-sm hover:bg-cyan-400 focus:outline-none focus:ring-2 focus:ring-cyan-500 focus:ring-offset-2"
      end
    end
  end
end

class HeadComponent < Phlex::Component
  def template
    head do
      script src: "https://cdn.tailwindcss.com"
    end
  end
end

class IndexComponent < Phlex::Component
  def initialize
    @tweets = Tweet.order(id: :desc)
  end

  def template
    h1 "Updates", class: "text-3xl font-bold"
    render FormComponent.new

    ul role: "list", class: "divide-y divide-gray-200" do
      @tweets.each do |tweet|
        li class: "py-4" do
          div class: "flex space-x-3" do
            render GravatarComponent.new(email: tweet.user.email)
            # img class: "h-6 w-6 rounded-full", src: "https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=3&w=256&h=256&q=80"
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
      end; nil # Needed this so I didn't render `[]` 
    end
  end
end

class LayoutComponent < Phlex::Component
  def template(&)
    render HeadComponent.new
    body class: "mt-8" do
      div class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" do
        div class: "mx-auto max-w-3xl" do
          content(&)  
        end
      end
    end
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
  LayoutComponent.new.call do |parent|
    parent.render IndexComponent.new
  end
end

post '/tweets' do
  current_user.tweets.create(content: params[:content])
  redirect '/'
end