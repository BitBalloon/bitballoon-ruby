require 'test_helper'

class ClientTest < MiniTest::Unit::TestCase
  attr_reader :client

  def setup
    @client = BitBalloon::Client.new(:client_id => "client_id", :client_secret => "client_secret")
  end

  def test_authorize_url
    expected = URI.parse("https://www.bitballoon.com/oauth/authorize?response_type=code&client_id=client_id&redirect_uri=http%3A%2F%2Fexample.com%2Fcallback")
    actual   = URI.parse(client.authorize_url(:redirect_uri => "http://example.com/callback"))
    assert_equal expected.scheme, actual.scheme
    assert_equal expected.host,   actual.host
    assert_equal expected.port,   actual.port
    assert_equal expected.query.split("&").sort, actual.query.split("&").sort
  end

  def test_authorize_from_code
    stub_request(:post, "https://www.bitballoon.com/oauth/token").to_return(
      :headers => {'Content-Type' => 'application/json'},
      :body => {
        "access_token" => "2YotnFZFEjr1zCsicMWpAA"
      })
    client.authorize_from_code!("authorization_code", :redirect_uri => "http://example.com/callback")
    assert_equal "2YotnFZFEjr1zCsicMWpAA", client.access_token
  end

  def test_authorize_from_credentials
    stub_request(:post, "https://client_id:client_secret@www.bitballoon.com/oauth/token").to_return(
      :headers => {'Content-Type' => 'application/json'},
      :body => {
        "access_token" => "2YotnFZFEjr1zCsicMWpAA"
      })

    client.authorize_from_credentials!
    assert_equal "2YotnFZFEjr1zCsicMWpAA", client.access_token
  end

  def test_simple_get_request
    stub_request(:get, "https://www.bitballoon.com/api/v1/sites")
      .with(:headers => {'Authorization' => "Bearer access_token"})
      .to_return(
        :headers => {'Content-Type' => 'application/json'},
        :body => []
      )

    client.access_token = "access_token"
    response = client.request(:get, "/sites")
    assert_equal [], response.parsed
  end

  def test_sites
    stub_request(:get, "https://www.bitballoon.com/api/v1/sites")
      .with(:headers => {'Authorization' => "Bearer access_token"})
      .to_return(
        :headers => {'Content-Type' => 'application/json'},
        :body => JSON.generate([{:url => "http://www.example.com"}])
      )
    client.access_token = "access_token"
    sites = client.sites.all
    assert_equal "http://www.example.com", sites.first.url
  end

  def test_get_site
    stub_request(:get, "https://www.bitballoon.com/api/v1/sites/1234")
      .with(:headers => {'Authorization' => "Bearer access_token"})
      .to_return(
        :headers => {'Content-Type' => 'application/json'},
        :body => {:url => "http://www.example.com"}
      )

    client.access_token = "access_token"
    site = client.sites.get("1234")
    assert_equal "http://www.example.com", site.url
  end
end
