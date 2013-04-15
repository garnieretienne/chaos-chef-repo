servicepacks_path      = "/srv/addons/servicepacks"
servicepacks_cookbooks = []

Dir.foreach servicepacks_path do |servicepack|
  if File.directory?("#{servicepacks_path}/#{servicepack}") && servicepack != "." && servicepack != ".." && File.directory?("#{servicepacks_path}/#{servicepack}/.git")
    servicepacks_cookbooks << "#{servicepacks_path}/#{servicepack}/chef/cookbooks"
  end
end

cookbook_path [ "#{File.dirname(__FILE__)}/cookbooks", "#{File.dirname(__FILE__)}/site-cookbooks" ] + servicepacks_cookbooks
role_path "#{File.dirname(__FILE__)}/roles"
