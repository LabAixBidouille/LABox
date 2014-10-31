# vi: set ft=ruby :

$script = <<SCRIPT
# switch to French keyboard layout
sudo sed -i 's/"us"/"fr"/g' /etc/default/keyboard
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y console-common
sudo install-keymap fr

# set timezone to French timezone
echo "Europe/Paris" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# install java
#sudo add-apt-repository ppa:webupd8team/java
#sudo apt-get update -y
#echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
#sudo apt-get -y install oracle-java8-installer maven


# install ARM GNU Toolchain
#sudo apt-get -y install build-essential gcc-arm-none-eabi gdb-arm-none-eabi

# start desktop
#DISPLAY=:0.0 gsettings set com.canonical.Unity.Launcher favorites "['nautilus-home.desktop', 'ubuntu-software-center.desktop', 'gnome-control-center.desktop', 'gnome-terminal.desktop', 'chromium-browser.desktop', 'arduino.desktop']"
SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "trusty64-LABox"
  
  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--vram", 64]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
    #       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x1781", "--productid", "0x0C9F", "--name", "adafruittrinket"]
    #       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x0403", "--productid", "0x6015", "--name", "rfduino"]
  end

  # Automatically use local apt-cacher-ng if available
  if File.exists? "/etc/apt-cacher-ng"
    # If apt-cacher-ng is installed on this machine then just use it.
    require 'socket'
    guessed_address = Socket.ip_address_list.detect{|intf| !intf.ipv4_loopback?}
    if guessed_address
      config.vm.provision :shell, :inline => "echo 'Acquire::http { Proxy \"http://#{guessed_address.ip_address}:3142\"; };' > /etc/apt/apt.conf.d/00proxy"
    end
  end
  
  #config.vm.provision "shell", privileged: false, inline: $script
  #config.vm.provision :shell, :inline => "apt-get update"
  #config.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --yes"
  
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
