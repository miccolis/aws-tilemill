Facter.add("web_password") do
    setcode do
        %x{cat /etc/mapbox/webpassword}.chomp
    end
end
