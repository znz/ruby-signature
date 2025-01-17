require "ruby/signature"
require "ruby/signature/test"
require "minitest/autorun"

class StdlibTest < Minitest::Test
  DEFAULT_LOGGER = Logger.new(STDERR)
  DEFAULT_LOGGER.level = ENV["RBS_TEST_LOGLEVEL"] || "info"

  loader = Ruby::Signature::EnvironmentLoader.new
  DEFAULT_ENV = Ruby::Signature::Environment.new
  loader.load(env: DEFAULT_ENV)

  def self.target(klass)
    @target = klass
  end

  def self.env
    @env || DEFAULT_ENV
  end

  def self.library(*libs)
    loader = Ruby::Signature::EnvironmentLoader.new
    libs.each do |lib|
      loader.add library: lib
    end

    @env = Ruby::Signature::Environment.new
    loader.load(env: @env)
  end

  def self.hook
    @hook ||= Ruby::Signature::Test::Hook.new(env, @target, logger: DEFAULT_LOGGER).verify_all
  end

  def hook
    self.class.hook
  end

  def setup
    super
    self.hook.errors.clear
    @assert = true
  end

  def teardown
    super
    assert_empty self.hook.errors.map {|x| Ruby::Signature::Test::Hook::Errors.to_string(x) }
  end
end
