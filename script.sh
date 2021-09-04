#!/usr/bin/bash

# Program killer using name
# Usage: killProgram <process_name>
echo "ps -A | grep $1 | xargs kill 2> /dev/null" > /usr/local/bin/killProgram
chmod +x /usr/local/bin/killProgram

# Conservation mode toggler
g++ toggleConservation.cpp -o toggleConservationMode
sudo chown root toggleConservationMode
sudo chmod u+s toggleConservationMode
mv toggleConservationMode /usr/local/bin/

desContent="[Desktop Entry]
Name=Toggle Battery Mode
Type=Application
Icon=/home/$USER/.local/share/icons/battery.png
Exec=toggleConservationMode"

echo $desContent > /home/$USER/.local/share/applications/ToggleBtteryMode.desktop
mv assets/battery.png /home/$USER/.local/share/icons/


# SSH Configuration
echo "Do you want to configure openssh?(y/n)"
read ans
if [ [ans=="y"] ]; then
	
	echo "[+] Installing ssh"
	sudo pacman -S openssh -y
	
	echo "[+] Enabling ssh at system start"
	sudo systemctl enable sshd
	
	echo "[+] Generating secret keys"
	ssh-keygen
	cat /home/$USER/.ssh/id_rsa.pub >> authorized_keys
	rm /home/$USER/.ssh/id_rsa.pub
	echo "Now move the /home/$USER/.ssh/id_rsa to a secure client machine"

	echo "Updating sshd configuration file"
	sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

	echo "The default port is 22 (Unchanged) change it?(y/n)"
	read op
	if [ [op=="y"] ]; then
		while : ; do
			echo "Enter port number:"
			read portNum
			if grep -q "^.* $portNum" /etc/services; then
				echo "Port already in use. Enter another port."
			else
				sed -i "s/^#Port .*/Port $portNum/" sshd_config
				break
			fi
		done
	fi
	sudo mv sshd_config /etc/ssh/sshd_config

	sudo systemctl start sshd
fi

# Local port forwarding for portmap rule
sudo pacman -S socat -y
#echo "alias ps='socat tcp-l:9999,reuseaddr,fork tcp:localhost:8100'"