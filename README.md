# Hello

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

    sudo -i -u webapp env `grep -h "^\s*[A-Z]\{1,\}" /etc/default/webapp* | xargs` /data/webapp/public/current/bin/kx_widget console
    sudo -i -u webapp env `grep -h "^\s*[A-Z]\{1,\}" /etc/default/webapp* | grep -v 'GOOGLE' | xargs` /data/webapp/public/current/bin/kx_widget start_iex
    
    
    docker build -t hello-elixir .
    docker run --rm -p 127.0.0.1:8080:8080 -it hello-elixir
    