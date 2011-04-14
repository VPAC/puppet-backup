Facter.add("rootsshkey") do
  setcode do
    value = nil
    filename = "/root/.ssh/id_rsa.pub"
    if FileTest.file?(filename)
      begin
        File.open(filename) { |f|
          value = f.read.chomp.split(/\s+/)[1]
        }
      rescue
        value = nil
      end
    end
    value
  end
end

