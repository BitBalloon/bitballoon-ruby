require 'test_helper'
require 'digest/sha1'

class MultipassTest < MiniTest::Unit::TestCase
  def setup
    @mp = BitBalloon::Multipass.new("secret")
  end

  def test_generate_and_decode_token
    data = {"email" => "test@example.com", "uid" => "1234"}
    token = @mp.generate_token(data)
    assert_equal data, @mp.decode_token(token), "Data should be the same after generating and decoding"
  end
end
