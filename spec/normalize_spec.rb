require "spec_helper"

describe NormalizeUrl do
  def n(*args)
    described_class.process(*args)
  end

  it "raises ArgumentError when input is not an abolute URL" do
    action = ->{ n("not@url") }
    message = "only absolute URLs can be normalized"
    expect(&action).to raise_error(ArgumentError, message)
  end

  it "raises ArgumentError when input is not an HTTP(S) URL" do
    action = ->{ n("ftp://example.com") }
    message = "only HTTP/HTTPS URLs can be normalized"
    expect(&action).to raise_error(ArgumentError, message)
  end

  it "normalizes punycode" do
    expect(n("http://www.詹姆斯.com/")).to eq("http://www.xn--8ws00zhy3a.com/")
  end

  it "normalizes dot-segments" do
    expect(n("http://example.com/foo/bar/../../")).to eq("http://example.com/")
  end

  it "strips trailing slash" do
    expect(n("http://example.com/products/")).to eq("http://example.com/products")
  end

  it "skips trailing slash when required" do
    expect(n("http://example.com/products/", remove_trailing_slash: false)).to eq("http://example.com/products/")
  end

  it "removes empty query" do
    expect(n("http://example.com/?")).to eq("http://example.com/")
  end

  it "sorts query params" do
    expect(n("http://example.com/?b=bar&a=foo")).to eq("http://example.com/?a=foo&b=bar")
  end

  it "doesn't modify query params" do
    expect(n("http://example.com/?foo=BAR+%26+BAZZ")).to eq("http://example.com/?foo=BAR+%26+BAZZ")
  end

  it "skips sorting query when required" do
    expect(n("http://example.com/?b=bar&a=foo", sort_query: false)).to eq("http://example.com/?b=bar&a=foo")
  end

  it "removes repeating slashes in path" do
    expect(n("http://example.com/foo///products")).to eq("http://example.com/foo/products")
  end

  it "skips removing repeating slashes when required" do
    expect(n("http://example.com/f///p", remove_repeating_slashes: false)).to eq("http://example.com/f///p")
  end

  it "removes hash fragment" do
    expect(n("http://example.com/foo#bar")).to eq("http://example.com/foo")
  end

  it "skips removing hash fragment when required" do
    expect(n("http://example.com/foo#bar", remove_hash: false)).to eq("http://example.com/foo#bar")
  end
end
