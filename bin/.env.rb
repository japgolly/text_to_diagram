# Bundler init
require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile", Pathname.new(__FILE__).realpath)
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

# Add lib/ to load path
$:<< File.expand_path('../../lib',__FILE__)

