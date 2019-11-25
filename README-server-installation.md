# Installation of the lexique server 

% Time-stamp: <2019-11-20 08:20:13 christophe@pallier.org>

The interactive apps on www.lexique.org are programmed in RShiny.  Their source code is in http://www.github.com/chrplr/openlexicon/apps

After following the instructions below, it is enough to do a ``git clone https://github.com/chrplr/openlexicon.git shiny-server` in the home directory on the server to get it up an running.

(Note: the files containing the lexical datasets must be installed at the locations described in the `.json` files located in  `datasets-info/_json`. At lexique.org, we installed the atabases in `/var/www/databases`)


## Shiny server

Here, we explain how to deploy a [shiny server](https://www.rstudio.com/products/shiny/shiny-server/) on a Ubuntu 18.04 Linux server.

The following commands must be executed on the computer that will be used as the server.

### Installation of R

    sudo apt install -y apt-transport-https software-properties-common
    sudo apt install -y build-essential
    
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

    sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

    sudo apt update
    sudo apt install -y r-base

### Installaion of RShiny and Shiny server

Following the instructions at <https://www.rstudio.com/products/shiny/download-server/>

    sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
    sudo su - -c "R -e \"install.packages('DT','rmarkdown')\""

    sudo apt-get install -y gdebi-core
    sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
    sudo gdebi shiny-server-1.5.9.923-amd64.deb


You can run the server by accessing `http://servername:3838` where `servername` it the name or the IP address of your server. For a local installation, it would be `localhost`.

If you want to setup the server main page (http://servername) to point on
rshiny, you need to edit `/etc/shiny-server/shiny-server.conf` to modify the
port from `3838` to `80`

    nano /etc/shiny-server/shiny-server.conf  # change port from 3838 to 80
    systemctl restart shiny-server


## Add the openlexicon shiny apps to the shiny-server

Execute:

    cd 
    git clone https://github.com/chrplr/openlexicon.git shiny-server
    cd shiny-server/


Edit `/etc/shiny-server/shiny-server.conf`:

    server {
    listen 3838;

    # For root shiny server (in shinyapps user home folder)
    location / {

    # The shiny-server process would run by user `chrplr`
    run_as chrplr;

    # Save logs here
    log_dir /var/log/shiny-server;

    # Path to shiny server for separate apps
    site_dir /home/chrplr/shiny-server;

    # List contents of a (non-Shiny-App) directory when clients visit corresponding URIs
    directory_index on;
    }

    # Allow users to host their own apps in `~/ShinyApps`
    location /users {
      run_as :HOME_USER:;
      user_dirs;
     }
    }


## proxying shiny server through nginx

If you use a web server like apache2 or nginx, you can configure them to proxy the shiny-server. For nginx, for example, I added the following inside the `http` directive in `/etc/nginx/nginx.conf`


     map $http_upgrade $connection_upgrade {
         default upgrade;
         ''      close;
     }

      server {
         listen 80;
    
         rewrite ^/shiny$ $scheme://$http_host/shiny/ permanent;

         root /var/www/html;
         autoindex on;
 
         index index.html index.htm index.php;
         
         location /shiny/ {
             rewrite ^/shiny/(.*)$ /$1 break;
             proxy_pass http://localhost:3838;
             proxy_redirect / $scheme://$http_host/shiny/;
             proxy_http_version 1.1;
             proxy_set_header Upgrade $http_upgrade;
             proxy_set_header Connection $connection_upgrade;
             proxy_read_timeout 20d;
             proxy_buffering off;
         }


         location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
         }

         location ~ /\.ht {
                deny all;
         }

         location / {
             root /var/www/html;
             autoindex on;
         }




---- 

Back to [main page](README.md)
