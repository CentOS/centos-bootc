text
# NOTE: As of the time of this writing, this kickstart only
# works with a Fedora 40+ (or ELN) installer ISO as it requires
# https://github.com/rhinstaller/anaconda/pull/5342
# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
part /boot --size=1000  --fstype=ext4 --label=boot
part / --grow --fstype xfs
reqpart

ostreecontainer --url quay.io/centos-bootc/fedora-bootc:eln	--no-signature-verification
# Or: quay.io/centos-bootc/centos-bootc-dev:stream9

firewall --disabled
services --enabled=sshd

# Only inject a SSH key for root
rootpw --iscrypted locked
# Add your example SSH key here!
#sshkey --username root "ssh-ed25519 <key> demo@example.com"
reboot
