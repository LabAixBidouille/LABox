# vi: set ft=ruby :

$script = <<SCRIPT
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y

# switch to French keyboard layout
sudo sed -i 's/"us"/"fr"/g' /etc/default/keyboard
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y console-common
sudo install-keymap fr

# set timezone to French timezone
echo "Europe/Paris" | sudo tee /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata

# install Ubuntu desktop
sudo apt-get install -y --no-install-recommends ubuntu-desktop
sudo apt-get install -y gnome-panel
sudo apt-get install -y unity-lens-applications
gconftool -s /apps/gnome-terminal/profiles/Default/use_system_font -t bool false

# install Chromium  browser
sudo apt-get install -y chromium-browser

# install java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update -y
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get -y install oracle-java8-installer maven

# install Arduino IDE
sudo apt-get install -y arduino arduino-core
sudo adduser vagrant dialout

# install development: 
sudo apt-get install -y git
sudo apt-get install -y vim vim-gnome

# install ARM GNU Toolchain
sudo apt-get -y install build-essential gcc-arm-none-eabi gdb-arm-none-eabi

# install moserial
sudo apt-get -y install moserial

# install openocd 0.9
sudo apt-get -y install libhidapi-dev libusb-1.0-0-dev libusb-dev libtool autotools-dev automake
git clone https://github.com/ntfreak/openocd.git;
cd openocd
./bootstrap
./configure --enable-stlink --enable-jlink --enable-ftdi  --enable-cmsis-dap
make
sudo make install
cd
sudo cp /usr/local/share/openocd/contrib/99-openocd.rules /etc/udev/rules.d/99-openocd.rules
sudo udevadm control --reload-rules
sudo usermod -a -G plugdev vagrant

# install guest addition
# sudo apt-get -y install virtualbox-guest-dkms virtualbox-guest-x11 virtualbox-guest-utils

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
    config.vm.box_url = "https://s3.eu-central-1.amazonaws.com/ffuenf-vagrantboxes/ubuntu/ubuntu-14.10-server-amd64_virtualbox.box"
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

