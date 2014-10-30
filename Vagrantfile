# vi: set ft=ruby :

$script = <<SCRIPT
sudo apt-get update -y

# switch to French keyboard layout
sudo sed -i 's/"us"/"fr"/g' /etc/default/keyboard
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y console-common
sudo install-keymap fr

# set timezone to German timezone
echo "Europe/Paris" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# install Ubuntu desktop
sudo apt-get install -y --no-install-recommends ubuntu-desktop
sudo apt-get install -y gnome-panel
sudo apt-get install -y unity-lens-applications
gconftool -s /apps/gnome-terminal/profiles/Default/use_system_font -t bool false

# install Chromium  browser
sudo apt-get install -y chromium-browser

# install Arduino IDE
sudo apt-get install -y arduino arduino-core
sudo adduser vagrant dialout

# install development: 
sudo apt-get install -y git
sudo apt-get install -y vim vim-gnome

# start desktop
echo "autologin-user=vagrant" | sudo tee -a /etc/lightdm/lightdm.conf
sudo service lightdm restart
sleep 15
sudo /etc/init.d/vboxadd-x11 setup
DISPLAY=:0.0 gsettings set com.canonical.Unity.Launcher favorites "['nautilus-home.desktop', 'ubuntu-software-center.desktop', 'gnome-control-center.desktop', 'gnome-terminal.desktop', 'chromium-browser.desktop', 'arduino.desktop']"
sudo service lightdm restart
SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ffuenf/ubuntu-14.10-server-amd64"
    config.vm.hostname = "utopic-LABox"
    config.vm.provision "shell", privileged: false, inline: $script

    config.vm.provider :virtualbox do |vb|
        vb.gui = true
        # Use VBoxManage to customize the VM. For example to change memory:
        vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "1"]
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        vb.customize ["modifyvm", :id, "--usb", "on"]
        vb.customize ["modifyvm", :id, "--usbehci", "on"]
#       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x1781", "--productid", "0x0C9F", "--name", "adafruittrinket"]
#       vb.customize ["usbfilter", "add", "1", "--target", :id, "--vendorid", "0x0403", "--productid", "0x6015", "--name", "rfduino"]
    end
end

