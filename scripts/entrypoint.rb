#!/usr/bin/env ruby
# frozen_string_literal: true

def system!(*args)= (abort("\n== Command #{args} failed ==") unless system(*args))

system("mkdir -p ~/.tmp")
system!("gem install bundler --conservative")
system("bundle check") || system!("TMPDIR=~/.tmp bundle install")

require_relative "../config/boot"

require "oj"
require "active_support/core_ext/object/blank"

puts_env = -> { ENV.sort.to_h.each { |variable, value| puts " #{variable}=\"#{value}\"" } }
renv, profile = ENV.fetch("RAILS_ENV"), File.expand_path("~/.zprofile")
export_var = ->(var, val = nil) { "export #{var}=\"#{val.presence || ENV.fetch(var)}\"\n" }
build_command = ->(*array) { array.map { |c| '"' + c + '"' }.join(" ") }

puts "Running entrypoint..."
puts "Environment: #{renv}"

ENV.delete("RAILS_MASTER_KEY") if ENV["RAILS_MASTER_KEY"].blank?

unless [nil, "development", "test"].include?(renv)
  json_envs = Oj.load(
    '{}' # `aws secretsmanager ...`
  ).sort.to_h
  json_envs.each do |variable, value|
    next if variable.blank? || value.blank?
    File.write(".env.local", "#{variable}=#{value}\n", mode: "a+")
  end
  ENV["RUBY_USE_YJIT"] = "true"
end

if ["test"].include?(renv) && ENV["CI"]
  ENV["RUBY_USE_YJIT"] = "true"
  ENV["RUBY_YJIT_CALL_THRESHOLD"] = "30"
end

File.write(profile, export_var.call("RAILS_ENV"), mode: "a+")

if ENV["RUBY_USE_YJIT"].present?
  threshold = ENV["RUBY_YJIT_CALL_THRESHOLD"].presence || "512"
  exec_mem_size = ENV["RUBY_YJIT_EXEC_MEM_SIZE"].presence || "128"
  ENV["YJIT_RUBYOPT"] = [
    "--yjit-call-threshold=#{threshold}",
    "--yjit-code-gc",
    "--yjit-exec-mem-size=#{exec_mem_size}",
    "--yjit"
  ].join(" ")
end

puts "Current environment variables:"
puts_env.call

command_real = build_command.call("bundle", "exec", *ARGV)
command = command_real.gsub('"', '\"') + "; exit \\$?;"
command, setup = build_command.call("zsh", "-cel", command), build_command.call("zsh", "-cel", "bin/setup")
puts "Executing setup:\n\t=> #{setup}"
system!({"DROP_TO_SHELL" => "true"}, setup)
puts "Executing command:\n\t=> #{command_real}"
exec(command)
