#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'byebug'
require 'rbdig'

DOMAIN = ARGV[0]
ROOT_DNS_SERVER = '199.7.83.42' # l.root-servers.net

answer = RbDig::Resolver.new.query(DOMAIN)
# answer = RbDig::Response.new(File.read('./resp_dns_lookup_auth.txt'))
RbDig::Display.new(answer).pretty_print
# p answer.pretty_print
