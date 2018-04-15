# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'io/console'

@print_section_divider = lambda do |section_title|
  horizontal_border = ("*" * section_title.length) * 2
  title_spacer = (" " * (section_title.length / 2))[0..-2]
  spacer = ((" " * section_title.length) * 2)[1..-2]

  return "


  ( ( ( ( ( ( ( ( ( (     #{section_title}     ) ) ) ) ) ) ) ) ) )


  "
end

Vagrant.configure(2) do |config|
  config.vm.box = "debian/stretch64"
  config.vm.box_version = "9.2.0" # 9.3.0 was failing when this comment was added

  config.vm.provider "virtualbox" do |v|
     v.customize ["modifyvm", :id, "--memory", "3072"]
     v.customize ["modifyvm", :id, "--cpus", "2"]
     v.name = "Debian Stretch64"
  end

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 3001, host: 3001
  config.vm.network "forwarded_port", guest: 3002, host: 3002
  config.vm.network "forwarded_port", guest: 5432, host: 5432 # postgres
  config.vm.network "forwarded_port", guest: 5433, host: 5433 # postgres

  # config.vm.network "private_network", ip: "172.28.128.20"
  config.vm.network "private_network", type: "dhcp"

  # folder syncing - NFS does not work with Windows
  config.vm.synced_folder "./", "/home/vagrant/dev"

  options = ['nolock,vers=3,udp,noatime,actimeo=1']

  config.vm.provision "shell" do |s|
    # run as vagrant user, which has sudo privileges
    s.privileged = false
    s.inline = <<-SCRIPT
      date1=$(date +"%s")

      echo "#{@print_section_divider.call('Dev Directory & Permissions')}"
      sudo chmod 777 -R /home/vagrant/dev

      echo "#{@print_section_divider.call('Git')}"
      # install and configure git
      sudo apt-get -y install git bash-completion
      git config --global color.diff auto
      git config --global color.status auto

      echo "#{@print_section_divider.call('Provisioning - OS Updates & Config')}"
      sudo apt-get -y clean all
      # sudo apt-get -y install kernel-devel
      sudo apt-get -y update

      echo "#{@print_section_divider.call('Provisioning - Dependencies')}"
      sudo apt-get -y install zip
      sudo apt-get -y install gcc
      sudo apt-get -y install g++
      sudo apt-get -y install git
      sudo apt-get -y install expect
      sudo apt-get -y install libpq-dev
      sudo apt-get -y install apt-transport-https
      sudo apt-get -y install curl
      sudo apt-get -y install wget
      sudo apt-get -y install vim

      echo "#{@print_section_divider.call('Provisioning - Aliases & Paths')}"
      printf "alias burninate='rake db:drop db:create db:migrate db:seed'
      alias allclear='echo -e "\033c\e[3J"'
      " > /home/vagrant/.bash_aliases
      echo " " >> /home/vagrant/.profile
      echo "source /home/vagrant/.bash_aliases" >> /home/vagrant/.profile

      echo "#{@print_section_divider.call('Provisioning - Custom Prompt')}"
      cd /home/vagrant
      wget https://raw.githubusercontent.com/dkoloditch/simple_bash_prompt_2/master/.bash_prompt
      echo "" >> /home/vagrant/.profile
      echo "source /home/vagrant/.bash_prompt" >> /home/vagrant/.profile
      echo "" >> /home/vagrant/.profile
      source /home/vagrant/.profile

      echo "#{@print_section_divider.call('Provisioning - Avoid Guard Watchers Error')}"
      echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

      echo "#{@print_section_divider.call('Provisioning - Install NVM / Node & NPM / Yarn')}"
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
      source /home/vagrant/.profile
      source /home/vagrant/.nvm/nvm.sh
      nvm ls-remote > $HOME/node_versions.txt
      LATEST_NODE=$((tail -n1) < $HOME/node_versions.txt)
      nvm install $LATEST_NODE
      sudo rm $HOME/node_versions.txt
      nvm alias latest $LATEST_NODE
      nvm use latest
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt-get -y update && sudo apt-get -y install yarn
      yarn install

      echo "#{@print_section_divider.call('Provisioning - RVM & Ruby')}"
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
      \\curl -sSL https://get.rvm.io | bash
      source /home/vagrant/.rvm/scripts/rvm
      sudo touch /home/vagrant/.rvm/scripts/version # handling annoying rvm bug
      rvm install '2.5.1'

      echo "#{@print_section_divider.call('Provisioning - PostgreSQL')}"
      sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
      wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
      sudo apt-get -y update
      sudo apt-get -y install postgresql postgresql-contrib
      sudo printf 'localhost:*:*:postgres:
      127.0.0.1:*:*:postgres:' > /home/vagrant/.pgpass
      sudo chmod 0600 /home/vagrant/.pgpass
      PG_CONF_PATH=$(sudo find / -name pg_hba.conf)
      sudo perl -pi -e 's/ident/trust/g' $PG_CONF_PATH
      sudo perl -pi -e 's/peer/trust/g' $PG_CONF_PATH
      sudo perl -pi -e 's/md5/trust/g' $PG_CONF_PATH
      sudo /etc/init.d/postgresql restart
      sudo -u postgres psql -c "alter user postgres password ''"
      sudo -u postgres psql -c "create user vagrant"
      sudo -u postgres psql -c "alter user vagrant password ''"
      sudo -u postgres psql -c "alter user vagrant with Superuser"
      sudo -u postgres psql -c "alter user vagrant with CreateROLE"
      sudo -u postgres psql -c "alter user vagrant with CreateDB"
      sudo -u postgres psql -c "alter user vagrant with Replication"

      echo "#{@print_section_divider.call('Provisioning - Install Bundler for Rubies')}"
      rvm use 2.5.1
      gem install bundler --no-ri --no-rdoc

      # calculate provisioning time
      date2=$(date +"%s")
      diff=$(($date2-$date1))
      echo " "
      echo "****************************"
      echo "Provisioning completed in:"
      echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds."
      echo "****************************"
      echo " "
    SCRIPT
  end
end
