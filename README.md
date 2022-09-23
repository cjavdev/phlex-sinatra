# Phlex Sinatra app

This is a short exploration of the [Phlex](https://www.phlex.fun/) framework using Sinatra. I wanted to
play around with Phlex after hearing about it on [Remote Ruby](https://dev.to/remote-ruby/phlexing-with-joel-drapper).

There isn't much documentation yet, so I hope this will be a simple way for others to get started.

### How I did layouts

Not sure if this is how it's intended to be used, but this is what worked for me for layouts:

```rb
class LayoutComponent < Phlex::Component
  def template(&)
    body do
      div do
        content(&)
      end
    end
  end
end

class IndexComponent < Phlex::Component
  def template
    h1 "Test!"
  end
end

get '/' do
  LayoutComponent.new.call do |parent|
    parent.render IndexComponent.new
  end
end
```

### How to run

```bash
git clone git@github.com:cjavdev/phlex-sinatra.git
cd phlex-sinatra
bundle install
bundle exec rake db:create db:migrate
ruby server.rb
```

Browse to http://localhost:4567/