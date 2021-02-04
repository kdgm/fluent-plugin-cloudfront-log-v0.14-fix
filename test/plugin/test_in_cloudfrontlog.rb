require_relative '../helper'
require 'fluent/test'
require 'fluent/test/driver/input'

class Cloudfront_LogInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  MINIMAL_CONFIG = %[
    region     ap-northeast-1
    log_bucket bucket-name
    log_prefix a/b/c

    # aws_key_id       AKIAZZZZZZZZZZZZZZZZ
    # aws_sec_key      1234567890qwertyuiopasdfghjklzxcvbnm
    # moved_log_bucket bucket-name-moved
    # moved_log_prefix a/b/c_moved
    # tag              cloudfront
    # interval         500
    # verbose          true
    # thread_num 8
    # parse_date_time false
  ]

  def create_driver(conf = MINIMAL_CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Cloudfront_LogInput).configure(conf)
  end

  test "create_driver doesn't raise error" do
    assert_nothing_raised { create_driver }
  end

  sub_test_case "required parameters" do
    test "region is required" do
      exception = assert_raise(Fluent::ConfigError) {
        create_driver(MINIMAL_CONFIG.gsub(/region.*$/, ''))
      }
      assert_equal("'region' parameter is required", exception.message)
    end

    test "log_bucket is required" do
      exception = assert_raise(Fluent::ConfigError) {
        create_driver(MINIMAL_CONFIG.gsub(/log_bucket.*$/, ''))
      }
      assert_equal("'log_bucket' parameter is required", exception.message)
    end

    test "log_prefix is required" do
      exception = assert_raise(Fluent::ConfigError) {
        create_driver(MINIMAL_CONFIG.gsub(/log_prefix.*$/, ''))
      }
      assert_equal("'log_prefix' parameter is required", exception.message)
    end
  end

  sub_test_case "default values" do
    test "moved_log_bucket is set to log_bucket" do
      driver = create_driver(MINIMAL_CONFIG)
      assert_equal(driver.instance.log_bucket, driver.instance.moved_log_bucket)
    end

    test "moved_log_prefix is set to '_moved'" do
      driver = create_driver(MINIMAL_CONFIG)
      assert_equal('_moved', driver.instance.moved_log_prefix)
    end

  end

  test 'verbose flag is set to true (boolean)' do
    driver = create_driver(MINIMAL_CONFIG + %[
      verbose true
    ])
    assert_equal(true, driver.instance.verbose)
  end

end
