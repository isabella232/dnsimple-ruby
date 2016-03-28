module Dnsimple
  class Client
    module Identity

      # Gets the information about the current authenticated context.
      #
      # @see https://developer.dnsimple.com/v2/identity/#whoami
      #
      # @param  [Hash] options
      # @return [Dnsimple::Response<Hash>]
      # @raise  [Dnsimple::RequestError]
      def whoami(options = {})
        response = client.get(Client.versioned("/whoami"), options)

        data = response["data"]
        account = data["account"] ? Struct::Account.new(data["account"]) : nil
        user = data["user"] ? Struct::User.new(data["user"]) : nil
        Response.new(response, account: account, user: user)
      end


      module StaticHelpers
        # Calls {Identity#whoami} and directly returns the response data.
        #
        # @see https://developer.dnsimple.com/v2/identity/#whoami
        #
        # @param  [Dnsimple::Client] client the DNSimple client instance to use
        # @param  [Array] args the args for the {Identity#whoami} call
        # @return [Hash]
        # @raise  [Dnsimple::RequestError]
        def whoami(client, *args)
          client.identity.whoami(*args).data
        end
      end

    end
  end
end
