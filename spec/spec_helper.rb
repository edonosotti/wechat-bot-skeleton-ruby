require 'dotenv'
require 'webmock/rspec'

$SPEC_PATH = File.dirname(__FILE__)

Dotenv.load("#{$SPEC_PATH}/../.env")
