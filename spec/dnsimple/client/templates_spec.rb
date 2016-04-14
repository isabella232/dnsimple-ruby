require 'spec_helper'

describe Dnsimple::Client, ".templates" do

  subject { described_class.new(base_url: "https://api.dnsimple.test", access_token: "a1b2c3").templates }


  describe "#list_templates" do
    let(:account_id) { 1010 }

    before do
      stub_request(:get, %r{/v2/#{account_id}/templates$}).
          to_return(read_http_fixture("listTemplates/success.http"))
    end

    it "builds the correct request" do
      subject.list_templates(account_id)

      expect(WebMock).to have_requested(:get, "https://api.dnsimple.test/v2/#{account_id}/templates").
          with(headers: { "Accept" => "application/json" })
    end

    it "returns the list of templates" do
      response = subject.list_templates(account_id)
      expect(response).to be_a(Dnsimple::CollectionResponse)

      response.data.each do |result|
        expect(result).to be_a(Dnsimple::Struct::Template)
        expect(result.id).to be_a(Numeric)
        expect(result.account_id).to be_a(Numeric)
        expect(result.name).to be_a(String)
        expect(result.short_name).to be_a(String)
        expect(result.description).to be_a(String)
      end
    end
  end

  describe "#template" do
    let(:account_id) { 1010 }
    let(:template_id) { 1 }

    before do
      stub_request(:get, %r{/v2/#{account_id}/templates/#{template_id}$}).
          to_return(read_http_fixture("getTemplate/success.http"))
    end

    it "builds the correct request" do
      subject.template(account_id, template_id)

      expect(WebMock).to have_requested(:get, "https://api.dnsimple.test/v2/#{account_id}/templates/#{template_id}").
          with(headers: { "Accept" => "application/json" })
    end

    it "returns the list of templates" do
      response = subject.template(account_id, template_id)
      expect(response).to be_a(Dnsimple::Response)

      template = response.data
      expect(template).to be_a(Dnsimple::Struct::Template)
      expect(template.id).to eq(1)
      expect(template.account_id).to eq(1010)
      expect(template.name).to eq("Alpha")
      expect(template.short_name).to eq("alpha")
      expect(template.description).to eq("An alpha template.")
    end
  end
end
