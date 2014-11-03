# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "trusty64-LABox"
  
  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--vram", 64]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
    #       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x1781", "--productid", "0x0C9F", "--name", "adafruittrinket"]
    #       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x0403", "--productid", "0x6015", "--name", "rfduino"]
  end

  #config.vbguest.auto_update = false

  # Automatically use local apt-cacher-ng if available
  if File.exists? "/etc/apt-cacher-ng"
    # If apt-cacher-ng is installed on this machine then just use it.
    require 'socket'
    guessed_address = Socket.ip_address_list.detect{|intf| !intf.ipv4_loopback?}
    if guessed_address
      config.vm.provision :shell, :inline => "echo 'Acquire::http { Proxy \"http://#{guessed_address.ip_address}:3142\"; };' > /etc/apt/apt.conf.d/00proxy"
    end
  end
  
  # Provision the machine with puppet
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'manifests'
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
  end
  
  # Do post-provisioning cleanup
  config.vm.provision :shell, :inline => "apt-get autoremove --purge --yes"
  config.vm.provision :shell, :inline => "apt-get clean"
  config.vm.provision :shell, :inline => "rm -f /etc/apt/apt.conf.d/00proxy"
end
