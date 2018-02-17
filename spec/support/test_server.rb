require 'stub_server'

class TestServer
  class << self
    def with_server(&block)
      port = get_next_free_port

      Capybara.app_host = "http://127.0.0.1:#{port}"
      StubServer.open(port, replies) do |server|
        server.wait
        block.call
      end
    end

    private

    def get_next_free_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      port = socket.local_address.ip_port
      socket.close

      port
    end

    def replies
      defaults = {
        '/favicon.ico' => [200, {}, ['']]
      }

      %i[severe info none].reduce(defaults) do |replies, template|
        replies["/#{template}"] = [200, {}, [send(template)]]
        replies
      end
    end

    def severe
      template <<~JS
        console.error("A console error");
      JS
    end

    def info
      template <<~JS
        console.log("A console log");
      JS
    end

    def none
      template
    end

    def insert_element
      <<~JS
        var elementDiv = document.createElement("div");
        var content = document.createTextNode("Inserted element");
        elementDiv.appendChild(content);

        document.body.appendChild(elementDiv);
      JS
    end

    def template(js = "")
      <<~HTML
        <!DOCTYPE html>
        <html>
          <head>
            <title>test page</title>
          </head>
          <body>
            <h1>Hello</h1>

            <script type="text/javascript">
              #{js};
              #{insert_element}
            </script>
          </body>
        </html>
      HTML
    end
  end

  module Matchers
    def expect_to_have_inserted_element
      expect(page).to have_selector('div', text: 'Inserted element')
    end
  end
end

RSpec.configure do |config|
  config.include TestServer::Matchers

  config.around(:each, with_server: true) do |example|
    TestServer.with_server { example.run }
  end
end
