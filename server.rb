#!/usr/bin/env ruby

this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'runtime_services_pb'

class RuntimeServiceServer < Runtime::RuntimeService::Service
  def version(request, _unused_call)
    Runtime::VersionResponse.new(version: "1.1", runtime_name:"foobar_runtime", runtime_version:"2.2.3", runtime_api_version:"9999")
  end
  def run_pod_sandbox(request, _unused_call)
    Runtime::RunPodSandboxResponse.new(pod_sandbox_id: "c605182c-ca3b-11e4-ad0b-525400c788eb")
  end
  def create_container(request, _unused_call)
    pipe_cmd_in, pipe_cmd_out = IO.pipe
    @pid = Process.spawn("haconiwa run #{File.dirname(__FILE__)}/container.haco", :out => pipe_cmd_out, :err => pipe_cmd_out)
    Process.wait @pid
    pipe_cmd_out.close
    out = pipe_cmd_in.read
    Process.detach @pid
    Runtime::CreateContainerResponse.new(container_id: "container-#{out.match(/(\d+)/).to_s}")
  end
end

# main starts an RpcServer that receives requests to RuntimeServiceServer
def main
  s = GRPC::RpcServer.new
  s.add_http2_port('unix:/var/run/k8s_cri_prototype.sock', :this_port_is_insecure)
  s.handle(RuntimeServiceServer)
  s.run_till_terminated
end

main
