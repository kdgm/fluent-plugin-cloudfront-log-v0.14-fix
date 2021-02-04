require_relative '../helper'
require 'fluent/test'
require 'fluent/test/driver/input'

class Cloudfront_LogInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  DEFAULT_CONFIG = {
    :aws_key_id        => 'AKIAZZZZZZZZZZZZZZZZ',
    :aws_sec_key       => '1234567890qwertyuiopasdfghjklzxcvbnm',
    :log_bucket        => 'bucket-name',
    :log_prefix        => 'a/b/c',
    :moved_log_bucket  => 'bucket-name-moved',
    :moved_log_prefix  => 'a/b/c_moved',
    :region            => 'ap-northeast-1',
    :tag               => 'cloudfront',
    :interval          => '500',
    :delimiter         => nil,
    :verbose           => true,
  }

  def parse_config(conf = {})
    ''.tap{|s| conf.each { |k, v| s << "#{k} #{v}\n" } }
  end

  def create_driver(conf = DEFAULT_CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Cloudfront_LogInput).configure(parse_config conf)
  end

  test "create_driver doesn't raise error" do
    assert_nothing_raised { create_driver }
  end

  test "log_bucket is required" do
    exception = assert_raise(Fluent::ConfigError) {
      conf = DEFAULT_CONFIG.clone
      conf.delete(:log_bucket)
      create_driver(conf)
    }
    assert_equal("'log_bucket' parameter is required", exception.message)
  end

  test "region is required" do
    exception = assert_raise(Fluent::ConfigError) {
      conf = DEFAULT_CONFIG.clone
      conf.delete(:region)
      create_driver(conf)
    }
    assert_equal("'region' parameter is required", exception.message)
  end

  test "log_prefix is required" do
    exception = assert_raise(Fluent::ConfigError) {
      conf = DEFAULT_CONFIG.clone
      conf.delete(:log_prefix)
      create_driver(conf)
    }
    assert_equal("'log_prefix' parameter is required", exception.message)
  end

  test "unspecified moved_log_bucket is set to log_bucket" do
    conf = DEFAULT_CONFIG.clone
    conf.delete(:moved_log_bucket)
    driver = create_driver(conf)
    assert_equal(driver.instance.log_bucket, driver.instance.moved_log_bucket)
  end

  test "unspecified moved_log_prefix is set to '_moved'" do
    conf = DEFAULT_CONFIG.clone
    conf.delete(:moved_log_prefix)
    driver = create_driver(conf)
    assert_equal('_moved', driver.instance.moved_log_prefix)
  end

  test 'verbose flag is set to true (boolean)' do
    conf = DEFAULT_CONFIG.clone
    driver = create_driver(conf)
    assert_equal(true, driver.instance.verbose)
  end

end
