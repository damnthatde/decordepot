sudo chmod 777 -R /home/vagrant/dev

# install and configure git
sudo apt-get -y install git bash-completion
git config --global color.diff auto
git config --global color.status auto

sudo apt-get -y clean all
# sudo apt-get -y install kernel-devel
sudo apt-get -y update

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

printf "alias burninate='rake db:drop db:create db:migrate db:seed'
alias allclear='echo -e "\033c\e[3J"'
" > /home/vagrant/.bash_aliases
echo " " >> /home/vagrant/.profile
echo "source /home/vagrant/.bash_aliases" >> /home/vagrant/.profile

cd /home/vagrant
wget https://raw.githubusercontent.com/dkoloditch/simple_bash_prompt_2/master/.bash_prompt
echo "" >> /home/vagrant/.profile
echo "source /home/vagrant/.bash_prompt" >> /home/vagrant/.profile
echo "" >> /home/vagrant/.profile
source /home/vagrant/.profile

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

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

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\\curl -sSL https://get.rvm.io | bash
source /home/vagrant/.rvm/scripts/rvm
sudo touch /home/vagrant/.rvm/scripts/version # handling annoying rvm bug
rvm install '2.5.1'

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

rvm use 2.5.1
gem install bundler --no-ri --no-rdoc
