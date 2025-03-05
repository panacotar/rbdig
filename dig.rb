#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'rbdig'

DOMAIN = ARGV[0]

# answer = RbDig::NS.new.lookup(DOMAIN)
p answer
