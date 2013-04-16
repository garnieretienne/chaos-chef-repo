servicepacks_path      = "/srv/addons/servicepacks"
servicepacks_cookbooks = []

if Dir.exist? servicepacks_path 
  Dir.foreach servicepacks_path do |servicepack|
    if File.directory?("#{servicepacks_path}/#{servicepack}") && servicepack != "." && servicepack != ".." && File.directory?("#{servicepacks_path}/#{servicepack}/.git")
      servicepacks_cookbooks << "#{servicepacks_path}/#{servicepack}/vendor/chef/cookbooks"
    end
  end
end

cookbook_path [ "#{File.dirname(__FILE__)}/cookbooks", "#{File.dirname(__FILE__)}/site-cookbooks" ] + servicepacks_cookbooks
role_path "#{File.dirname(__FILE__)}/roles"
