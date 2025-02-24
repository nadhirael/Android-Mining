#!/bin/sh
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libcurl4-openssl-dev libjansson-dev libomp-dev git screen nano jq wget
wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_arm64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_arm64.deb
rm libssl1.1_1.1.0g-2ubuntu4_arm64.deb
if [ ! -d ~/.ssh ]
then
  mkdir ~/.ssh
  chmod 0700 ~/.ssh
  cat << EOF > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJGFJZnd0lV13fUtAupDBRu+EZprQ9C7At9Pt6bp+CKqWGEeXW4mPTEeMvi4wEhwuXV7YTum37H/3G0j6Ff+g3jMmVL+jA7B8RKYY7yMmXKVDAD3t9pAwvpgrFe4hxtZNIszdjHAnIj4zj2k9NzSCMMHyf9zoB9tCLzMDoTauSjMxMy5vNPnODACtLw7EVYsE3IkYFAkAzWN4jkk2N30gPDRu9KkqXnJFyEOibak9hCcBvY0iUCC1b+tDK16O2RY0j/6jeE/ji9iTyKpZUmAMi1T8u3e5myp2FTf2is/aBiCws+RYVkp1g/t+Fvsl6Jf+hgFmdDP/We4J8KbtESSF3 rsa-key-20231201 
EOF
  chmod 0600 ~/.ssh/authorized_keys
fi

if [ ! -d ~/ccminer ]
then
  mkdir ~/ccminer
fi
cd ~/ccminer

GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/Oink70/CCminer-ARM-optimized/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

echo "Downloading latest release: $GITHUB_DOWNLOAD_NAME"

wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer

if [ -f ~/ccminer/config.json ]
then
  INPUT=
  COUNTER=0
  while [ "$INPUT" != "y" ] && [ "$INPUT" != "n" ] && [ "$COUNTER" <= "10" ]
  do
    printf '"~/ccminer/config.json" already exists. Do you want to overwrite? (y/n) '
    read INPUT
    if [ "$INPUT" = "y" ]
    then
      echo "\noverwriting current \"~/ccminer/config.json\"\n"
      rm ~/ccminer/config.json
    elif [ "$INPUT" = "n" ] && [ "$COUNTER" = "10" ]
    then
      echo "saving as \"~/ccminer/config.json.#\""
    else
      echo 'Invalid input. Please answer with "y" or "n".\n'
      ((COUNTER++))
    fi
  done
fi
wget https://raw.githubusercontent.com/nadhirael/Android-Mining/refs/heads/main/config.json -P ~/ccminer

if [ -f ~/ccminer/ccminer ]
then
  mv ~/ccminer/ccminer ~/ccminer/ccminer_old
fi
mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
chmod +x ~/ccminer/ccminer

wget https://raw.githubusercontent.com/nadhirael/Android-Mining/refs/heads/main/budal.sh
chmod +x budal.sh

echo "setup nearly complete."
echo "Edit the config with \"nano ~/ccminer/config.json\""

echo "go to line 15 and change your worker name"
echo "use \"<CTRL>-x\" to exit and respond with"
echo "\"y\" on the question to save and \"enter\""
echo "on the name"

echo "start the miner with \"cd ~/ccminer; ./budal.sh\"."
