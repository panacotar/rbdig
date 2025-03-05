#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'rbdig'

opts = RbDig::Options.parse(ARGV)
RbDig::Resolver.new(opts).query(ARGV[0])
