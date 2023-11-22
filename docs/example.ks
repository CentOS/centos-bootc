text

# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
part prepboot  --size=4    --fstype=prepboot
part biosboot  --size=1    --fstype=biosboot
part /boot/efi --size=100  --fstype=efi
part /boot     --size=1000  --fstype=ext4 --label=boot
part / --grow --fstype xfs

ostreecontainer --url quay.io/centos-bootc/fedora-bootc:eln	--no-signature-verification
# Or: quay.io/centos-bootc/centos-bootc-dev:stream9

firewall --disabled
services --enabled=sshd

# Only inject a SSH key for root
rootpw --iscrypted locked
# Add your example SSH key here!
#sshkey --username root "ssh-ed25519 <key> demo@example.com"
reboot

# Workarounds until https://github.com/rhinstaller/anaconda/pull/5298/ lands
bootloader --location=none --disabled
%post --erroronfail
set -euo pipefail
# Work around anaconda wanting a root password
passwd -l root
rootdevice=$(findmnt -nv -o SOURCE /)
device=$(lsblk -n -o PKNAME ${rootdevice})
/usr/bin/bootupctl backend install --auto --with-static-configs --device /dev/${device} /
%end
