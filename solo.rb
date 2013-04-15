servicepacks_cookbooks = []
servicepacks_roles     = []

Dir.foreach "" do |servicepack|
  if File.directory?(servicepack) && servicepack != "." && servicepack != ".." && File.directory?("#{servicepack}/.git")
    servicepacks_cookbooks << "#{servicepack}/chef/cookbooks"
    servicepacks_roles << "#{servicepack}/chef/roles"
  end
end

cookbook_path [ "#{File.dirname(__FILE__)}/cookbooks", "#{File.dirname(__FILE__)}/site-cookbooks" ] + servicepacks_cookbooks
role_path [ "#{File.dirname(__FILE__)}/roles" ] + servicepacks_roles
