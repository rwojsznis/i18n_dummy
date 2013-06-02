RSpec::Matchers.define :have_node_count do |expected|
  match do |subject|
    subject.value.size == expected
  end
end

RSpec::Matchers.define :have_node_key do |expected|
  match do |subject|
    subject.key == expected
  end
end

RSpec::Matchers.define :have_node_path do |expected|
  match do |subject|
    subject.path == expected
  end
end

RSpec::Matchers.define :have_node_content do |node_value_number, expected|
  match do |subject|
    subject.value[node_value_number].content == expected
  end
end