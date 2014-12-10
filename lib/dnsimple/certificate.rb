module DNSimple

  # Represents an SSL certificate that has been purchased.
  #
  # The certificate must also be submitted using the #submit method
  # before the Certificate Authority will issue a signed certificate.
  class Certificate < Base

    # The certificate ID in DNSimple
    attr_accessor :id

    attr_accessor :domain

    # The subdomain on the certificate
    attr_accessor :name

    attr_accessor :state

    # The Certificate Signing Request
    attr_accessor :csr

    # The SSL certificate, if it has been issued by the Certificate Authority
    attr_accessor :ssl_certificate

    # The private key, if DNSimple generated the Certificate Signing Request
    attr_accessor :private_key

    # The approver email address
    attr_accessor :approver_email

    # When the certificate was purchased
    attr_accessor :created_at

    # When the certificate was last updated
    attr_accessor :updated_at

    attr_accessor :configured_at

    # An array of all emails that can be used to approve the certificate
    attr_accessor :available_approver_emails

    # The Certificate status
    attr_accessor :certificate_status

    # The date the Certificate order was placed
    attr_accessor :order_date

    # The date the Certificate will expire
    attr_accessor :expires_on

    # Purchase a certificate under the given domain with the given name. The
    # name will be appended to the domain name, and thus should only be the
    # subdomain part.
    #
    # Example: DNSimple::Certificate.purchase(domain, 'www', contact)
    #
    # Please note that by invoking this method DNSimple will immediately charge
    # your credit card on file at DNSimple for the full certificate price.
    #
    # For wildcard certificates an asterisk must appear in the name.
    #
    # Example: DNSimple::Certificate.purchase(domain, '*', contact)
    def self.purchase(domain, name, contact, options={})
      certificate_hash = {
        :name => name,
        :contact_id => contact.id
      }

      options.merge!({:body => {:certificate => certificate_hash}})

      response = DNSimple::Client.post("/v1/domains/#{domain.name}/certificates", options)

      case response.code
      when 201
        new({ :domain => domain }.merge(response["certificate"]))
      when 406
        raise RecordExists, "Certificate for #{domain.name} already exists"
      else
        raise RequestError.new("Error purchasing certificate", response)
      end
    end

    # Get an array of all certificates for the given domain.
    def self.all(domain, options={})
      response = DNSimple::Client.get("/v1/domains/#{domain.name}/certificates", options)

      case response.code
      when 200
        response.map { |r| new({:domain => domain}.merge(r["certificate"])) }
      else
        raise RequestError.new("Error listing certificates", response)
      end
    end

    # Find a specific certificate for the given domain.
    def self.find(domain, id, options = {})
      response = DNSimple::Client.get("/v1/domains/#{domain.name}/certificates/#{id}", options)

      case response.code
      when 200
        new({:domain => domain}.merge(response["certificate"]))
      when 404
        raise RecordNotFound, "Could not find certificate #{id} for domain #{domain.name}"
      else
        raise RequestError.new("Error finding certificate", response)
      end
    end


    # Get the fully-qualified domain name for the certificate. This is the
    # domain.name joined with the certificate name, separated by a period.
    def fqdn
      [name, domain.name].delete_if { |p| p !~ DNSimple::BLANK_REGEX }.join(".")
    end

    def submit(approver_email, options={})
      raise DNSimple::Error, "Approver email is required" unless approver_email

      options.merge!(:body => {:certificate => {:approver_email => approver_email}})

      response = DNSimple::Client.put("/v1/domains/#{domain.name}/certificates/#{id}/submit", options)

      case response.code
        when 200
          Certificate.new({ :domain => domain }.merge(response["certificate"]))
        else
          raise RequestError.new("Error submitting certificate", response)
      end
    end

  end
end
