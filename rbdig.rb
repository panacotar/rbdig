#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'rbdig'

DOMAIN = ARGV[0]

answer = RbDig::Resolver.new(dns_server: 'a.iana-servers.net').query(DOMAIN)
# answer = RbDig::Response.new(File.read('./resp_dns_lookup_auth.txt'))
RbDig::Display.new(answer).pretty_print
# p answer.pretty_print
