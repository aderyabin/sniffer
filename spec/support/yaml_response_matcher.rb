# frozen_string_literal: true

require 'yaml'

RSpec::Matchers.define :match_yaml_file do |name|
  match do |actual|
    yaml_directory = "#{Dir.pwd}/spec/yaml"
    file_path = "#{yaml_directory}/#{name}.yaml"

    file = File.read(file_path)
    expected_hash = YAML.load(file)
    expect(actual).to eq(expected_hash)
  end
end
