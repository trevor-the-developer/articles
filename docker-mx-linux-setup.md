# MX Linux Developer Setup

## Introduction
Hello welcome to this guide where we go through the process of setting up Docker on
an MX Linux system (Debian 12 based).

By the end of this guide you will have
- Docker installed
- lazydocker tool installed
- an MSSQL 2022 container running

This will prepare your Linux environment to work with ASP.NET Core and other development
environments that can leverage MSSQL 2022 Server.

We briefly go over setting up the latest dotnet SDK (version 9 as of the time of writing)
and a create a very simple application to test connectivity and operation of the MSSQL database
server.

## Prerequisites and installation
I recommend MX Linux as lightweight but powerful distro its based on Debian 12 currently and has
a lot to offer out of the box, you can download it here: https://mxlinux.org/download-links/.

MX Linux was my choice because I also wanted to revive an older laptop and experience what its like to have to battle resources and fine tune your Linux distro for best performance and I have to say I am quite impressed with this little Linux.   Doesn't require too much to setup most guides for Debian and
Ubuntu are relevant however MX Linux users however do note MX Linux uses `SysVinit` as its default init system, though it also includes `systemd` and allows users to choose between the two using the `systemd-shim` package.

Installation was fairly straightforward I chose the USB boot method and again was impressed by the performance of the Live USB version of MX Linux where you can find the MX Linux installer icon on the desktop and here the setup is painless the usual options for a typical Debian distro.

Here is the spec of the test laptop if anyone is curious:

- Samsung i5 NP370R UK spec
- 16GB DDR 1600 ram (max for this laptop)
- Samsung 870 EVO SSD 500GB
- Intel Graphics chipset

The EVO SDD drive is a big improvement makes the laptop very usable especially due to the light footprint of MX Linux.

As this laptop is for development purposes I wanted to ensure it was capable of performing development tasks.   The following is a list of things to install and the steps required to setup your distro:

### sudo
We need to ensure the sudoer file which controls which users can use the `sudo` command to execute commands with elevated privileges:
```
# User privilege specification
root    ALL=(ALL:ALL) ALL
your_username_here  ALL=(ALL:ALL) ALL
```
You will only see the root line, copy this line to next one and then change the root user to whatever your
logged in username is.   These lines are telling the system those users run any command as any user on any host i.e. giving them admin privileges.

### Essential Development Tools
First make sure the system is up to date:
```
sudo apt update && sudo apt upgrade && sudo apt dist-upgrade
```
This will ensure everything is up to date and you have the latest distro.

Next we need the basic development tools:
```
sudo apt install build-essential git curl wget
```

### Version Control
Git is essential for any development work:
```
sudo apt install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```
Where `Your Name` is your git username and `your.email@example.com` is the email address registered to your git account.

### Programming Languages and Environments
Depending on your development needs, you might want to install a few components I like to have the nodejs, python, Ruby (and Rails using asdf, see below for steps).

#### nodejs
I prefer to use nvm for version management:
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
```
The install script will run and display the following:
```
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 15916  100 15916    0     0    98k      0 --:--:-- --:--:-- --:--:--   98k
=> Downloading nvm from git to '/home/trevor/.config/nvm'
=> Cloning into '/home/trevor/.config/nvm'...
remote: Enumerating objects: 382, done.
remote: Counting objects: 100% (382/382), done.
remote: Compressing objects: 100% (325/325), done.
remote: Total 382 (delta 43), reused 178 (delta 29), pack-reused 0 (from 0)
Receiving objects: 100% (382/382), 386.80 KiB | 4.03 MiB/s, done.
Resolving deltas: 100% (43/43), done.
* (HEAD detached at FETCH_HEAD)
  master
=> Compressing and cleaning up git repository

=> Appending nvm source string to /home/trevor/.bashrc
=> Appending bash_completion source string to /home/trevor/.bashrc
=> You currently have modules installed globally with `npm`. These will no
=> longer be linked to the active version of Node when you install a new node
=> with `nvm`; and they may (depending on how you construct your `$PATH`)
=> override the binaries of modules installed with `nvm`:

/home/trevor/.asdf/installs/nodejs/18.19.0/lib
├── corepack@0.22.0
└── yarn@1.22.22
=> If you wish to uninstall them at a later point (or re-install them under your
=> `nvm` Nodes), you can remove them from the system Node as follows:

     $ nvm use system
     $ npm uninstall -g a_module

=> Close and reopen your terminal to start using nvm or run the following to use it now:

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
The export command is useful if you don't want to have to restart your terminal session:
```
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
Finally run `exec $SHELL -l` to reload the (login) shell.

#### C/C++ Development Tools
```
sudo apt install gcc g++ cmake gdb
```

#### Installing Ruby, Node.js, and Rails

##### Dependencies
```
sudo apt update
sudo apt install -y build-essential autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev libgdbm-dev curl git
```

##### asdf
Clone asdf into your home directory:
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
```

Add asdf to the shell (bash or zsh):
```
# For bash

echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
source ~/.bashrc
```

```
# For zsh

echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
source ~/.zshrc
```

##### Ruby plugin and latest Ruby
```
asdf plugin add ruby
asdf list all ruby
asdf install ruby latest
asdf global ruby latest
```
This can take a few minutes depending on your hardware specifications.  Once complete you
can test Ruby with the following command:
```
ruby -v
```
This should display the latest version number of Ruby that is installed (3.4.2 at the time of writing).

##### nodejs
```
asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest
```

##### Rails
Install the latest Rails
```
gem install rails
```
You may be prompted to upgrade RubyGems you can do this now if needed:
```
gem update --system 3.6.7
```
Verify the installation:
```
ruby -v
node -v
rails -v
```

### Code Editors
I like to edit code both in the terminal and using VS Code.
```
# install micro editor
sudo apt install micro
```

```
# VS Code (via .deb package)
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo apt install ./vscode.deb
```

### Docker for containerisation
```
sudo apt install apt-transport-https ca-certificates gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update apt
sudo apt update

# install docker components
sudo apt install docker-ce docker-ce-cli containerd.io

# add your user to docker group
sudo usermod -aG docker $USER
```

### Miscellaneous items

#### Databases
I didn't bother with a local database server as per this guide, any DB will be hosted in a docker container of my choice whether its postgres or MSSQL or something else.   It is worth having `sqlite3` installed locally for lightweight storage handing when you're scripting or writing some apps like Ruby for automation (or just fun).
```
# SQLite
sudo apt install sqlite3
```

#### Terminal stuff
I like having split windows in a terminal and first came across this feature when I was testing out the awesome [Omakub](https://omakub.org/) for Ubuntu created by the awesome [DHH](https://dhh.dk/).  Thankfully we have TMUX a terminal multiplexer that lets you manage your terminal split it into panes and do other wonderful things be sure to checkout their repo at https://github.com/tmux/tmux/wiki and a handy [cheat sheet](https://cheatography.com/alexandreceolin/cheat-sheets/tmux-terminal-multiplexer/) on [cheatography.com](cheatography.com) that covers all the useful commands (thankfully not as mind numbing as learning VIM or Emacs).

#### Postman
Postman is a handy API testing tool and quite easy to setup:
```
# download Postman tarball
cd ~/Downloads
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

# extract the archive into the /opt folder
sudo tar -xzf postman.tar.gz -C /opt

# create a symlink
sudo ln -s /opt/Postman/Postman /usr/bin/postman
```

##### Postman menu setup
_add_screenshot_here_

MX Linux menu is quite configurable and you can add Postman to the Development tab with the following steps:

- Right click the MX Linux start button and select `Edit Applications` option.
- From the MenuLibre dialog expand the Development category and select the `Development` tab
- Press the + icon at the top left to create a new entry
- Left-click on the icon to select the Postman icon located in `/opt/Postman/Postman`
- Left-click New Launcher name to rename to `Postman`
- Left-click the Description and change to `Make and view REST API calls and responses`
- Set the Command to `/opt/Postman/Postman`
- Left-click the disk icon to save (next to the + button)

You should now see the Postman icon displayed under the Development category.   Close the MenuLibre window
and then left click the MX Linux launcher button navigate to Development and click on the Postman icon
to launch Postman (you will be prompted to sign-in or register).

## Setup
This section covers setting up the MSSQL 2022 docker image container and configuring to work with MX Linux
and for development tasks.

### Docker Compose File
This example creates a docker-compose file that spins up an MSSQL 2022 Server container with the data folder as a volume and logs as a bind mount.

#### Create the `docker-compose.yaml` file
Lets use micro to create the file in the test folder (I created a new folder called `mssql-2022` under `/home/trevor/Development/Docker`):
```
micro docker-compose.yaml
```
This will open a new blank document, press `Ctrl + s` keys once to save this new document and then copy and paste (`Ctrl + v`) the contents into the micro editor in your terminal window:
```
services:
  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: mssql-dev
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_PID=Developer
      - MSSQL_SA_PASSWORD=Passw0rd1_99!
    ports:
      - "1433:1433"
    volumes:
      - mssql-data:/var/opt/mssql
      - ./mssql-logs:/var/opt/mssql/log
    restart: unless-stopped
    shm_size: 2gb
    networks:
      - crudapp-network

networks:
  crudapp-network:
    driver: bridge

volumes:
  mssql-data:
```
Press `Ctrl + s` once again to save and then press `Ctrl + q` to quit the editor.

#### Prepare the log folder
Now create the log folder and set the permissions for the `mssql` user:
```
mkdir -p ./mssql-logs
```

You can find the UID with the following command:
```
docker exec -it mssql-dev id mssql
```
Which should display the UID for `mssql`
```
uid=10001(mssql) gid=10001(mssql) groups=10001(mssql)
```

Finally set the permission to avoid issues when SQL server tries to write the logs to this location:
```
sudo chown -R 10001:0 ./mssql-logs
```

#### Build and start the container
The following command will start everything clean, destroying an old containers and volumes and rebuilds using the docker-compose file:
```
docker compose down -v
docker compose up -d --force-recreate
```
The `-d` switch starts the container in the background.

To inspect the container logs we can use the following command:
```
tail -f ./mssql-logs/errorlog
```

##### What is this command doing
This command is monitoring the SQL Server error log file in real-time.

The tail command is a Unix/Linux utility that displays the last part of a file. By default, it shows the last 10 lines of a file.

The `-f` flag (which stands for "follow") is what makes this particularly useful.   It causes tail to continuously monitor the file and display new lines as they're added to the file.   This creates a real-time stream of the log content as it's being written.

`./mssql-logs/errorlog` is the relative path to Microsoft SQL Server's error log file. The `./` indicates that the `mssql-logs` directory is located in the current working directory.

#### Git Ignore (optional)
If you are adding your `docker-compose.yaml` file to your project folder that is using github then you need to exclude the logs folder (if its located in the same location, best practice would be to locate this folder somewhere else like `/var/log`, if you do this remember to set the appropriate permission as detailed previously):
```
echo "mssql-logs/" >> .gitignore
```

This command adds a directory to the `.gitignore` file, which tells Git to ignore certain files and directories when tracking changes in your project.

#### Confirm Docker Volume is used for data
The following command should show a mount point:
```
docker volume inspect mssql-data
```
In this example the output is in JSON when the above command executed:
```
[
    {
        "CreatedAt": "2025-04-11T12:18:18+01:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mssql-data/_data",
        "Name": "mssql-data",
        "Options": null,
        "Scope": "local"
    }
]
```

### Wrapping up
We successfully setup Docker and created a docker-compose file to spin up the latest MSSQL 2022 Server container using a hybrid setup using Docker Volume and Bind Mounts.

### Setting up lazydocker
[lazydocker](https://github.com/jesseduffield/lazydocker?tab=readme-ov-file) is a great app for managing Docker containers and its fairly easy to setup with various [methods](https://github.com/jesseduffield/lazydocker#installation).

Once installed you can simply run it by typing `lazydocker` to launch the terminal GUI.
