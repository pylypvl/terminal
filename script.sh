#!/bin/bash
if [ ! $(which zsh 2>/dev/null) ] 2>/dev/null;
then
sudo yum install zsh -y
sudo  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
yes | sudo sh install.sh
sudo chmod +x .oh-my-zsh
sudo chmod +x .zshrc
sudo mv /root/.oh-my-zsh /usr/share
sudo mv /usr/share/.oh-my-zsh /usr/share/oh-my-zsh
sudo mv /root/.zshrc /usr/share/oh-my-zsh
sudo mv /usr/share/oh-my-zsh/.zshrc /usr/share/oh-my-zsh/zshrc
sudo sed -i 's|export ZSH="'"$HOME"'/.oh-my-zsh"|export ZSH="\/usr\/share\/oh-my-zsh"|g' /usr/share/oh-my-zsh/zshrc
sudo sed -i 's/robbyrussell/crunch/g' /usr/share/oh-my-zsh/zshrc
sudo sed -i 's|# export PATH=$HOME/bin:/usr/local/bin:$PATH|export PATH=/usr/share/bin:/usr/local/bin:$PATH|g' /usr/share/oh-my-zsh/zshrc
sudo sed -i 's|# alias zshconfig="mate ~/.zshrc"|alias toolsdeploy="cd ~/common_tools/ && source set-env.sh common_tools.tfvars && terraform apply -var-file=$DATAFILE"|g' /usr/share/oh-my-zsh/zshrc
sudo sed -i 's|# alias ohmyzsh="mate ~/.oh-my-zsh"|alias clusterdeploy="cd ~/cluster-infrastructure/kube-cluster/ && source set-env.sh cluster.tfvars &&  terraform apply -var-file=$DATAFILE"|g' /usr/share/oh-my-zsh/zshrc
sudo mv ~/.bash_profile ~/.bash_profile.old
(echo :; echo exec /bin/zsh -il) > ~/.bash_profile
sudo sed -i 's|# .bashrc|exec zsh|g' ~/.bashrc
yes| sudo cp /usr/share/oh-my-zsh/zshrc  /etc/skel/.zshrc
sudo sed -i 's|SHELL=/bin/bash|SHELL=/bin/zsh|g' /etc/default/useradd
sudo sed -i 's/bin\/bash/bin\/zsh/g' /etc/passwd
getent passwd | while IFS=: read -r name password uid gid gecos home shell; do
    # only users that own their home directory
    if [ -d "$home" ] && [ "$(stat -c %u "$home")" = "$uid" ]; then
        # only users that have a shell, and a shell is not equal to /bin/false or /usr/sbin/nologin
        if [ ! -z "$shell" ] && [ "$shell" != "/bin/false" ] && [ "$shell" != "/usr/sbin/nologin" ]; then
            echo "$name" >> user_list.txt
        fi
    fi
done
count=0
for i in $(cat ./user_list.txt)
  do
     sudo chsh -s /bin/zsh $i
     sudo -i -u $i zsh << EOF
     cp /usr/share/oh-my-zsh/zshrc ~/.zshrc
     echo "sudo username" | chsh -s /bin/zsh
EOF
 done
reboot
fi
