# frozen_string_literal: true

require 'yaml'

RSpec::Matchers.define :match_yaml_file do |path|
  def expected(path = nil)
    @expected ||= begin
      yaml_directory = "#{Dir.pwd}/spec/yaml"
      file_path = "#{yaml_directory}/#{path}.yaml"
      file = File.read(file_path)
      YAML.load(file)
    end
  end

  match do |actual|
    def transform_hash(hash)
      {}.tap { |h| hash.each_pair { |(k, v)| h[k.downcase] = v } }
    end

    actual[:request][:headers] = transform_hash(actual[:request][:headers]) if actual[:request][:headers]
    actual[:response][:headers] = transform_hash(actual[:response][:headers]) if actual[:response][:headers]
    expect(actual).to eq(expected(path))
  end

  failure_message do |actual|
    "expected that actual \n#{actual}\nwould be equal to\n#{expected}"
  end
end
