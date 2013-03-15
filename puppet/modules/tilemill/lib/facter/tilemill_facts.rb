Facter.add("public_hostname") do
    setcode do
        %x{curl -s http://...}.chomp
    end
end

Facter.add("web_password") do
    setcode do
        %x{cat /etc/mapbox/webpassword}.chomp
    end
end
