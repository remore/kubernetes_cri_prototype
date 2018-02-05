#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'runtime_services_pb'

def main
  stub = Runtime::RuntimeService::Stub.new('unix:/var/run/k8s_cri_prototype.sock', :this_channel_is_insecure)
  message = stub.version(Runtime::VersionRequest.new(version: 'dummy'))
  p "Reponse Message: #{message}"
end

main
