# Update and upgrade packages
sudo apt-get update
sudo apt-get full-upgrade -y

# Install needed packages and python3 modules
sudo apt-get install nginx python3 python3-pip -y
sudo python3 -m pip install flask picamera uwsgi -U
sudo rm -rf /var/www/.local > /dev/null 2>&1
sudo rm -rf /var/www/.cache > /dev/null 2>&1
sudo mkdir /var/www/.local
sudo mkdir /var/www/.cache
sudo chown www-data.www-data /var/www/.local
sudo chown www-data.www-data /var/www/.cache
sudo -H -u www-data python3 -m pip install flask picamera uwsgi -U

# Add log folder
sudo rm -rf /var/log/uwsgi > /dev/null 2>&1
sudo mkdir /var/log/uwsgi
sudo touch /var/log/uwsgi/uwsgi.log
sudo chown -R www-data:www-data /var/log/uwsgi

sudo rm -rf /var/log/nginx > /dev/null 2>&1
sudo mkdir /var/log/nginx
sudo touch /var/log/nginx/error.log
sudo chown -R www-data:www-data /var/log/nginx           

# Create installation directory
sudo rm -rf /etc/elab_birdhouse/ > /dev/null 2>&1
sudo mkdir /etc/elab_birdhouse/

# Makes www-data own the directory and add it to the video group
sudo chown www-data /etc/elab_birdhouse/
sudo usermod -aG video www-data

# Copy all the installation content to the specified destination
cp -a "${DIR}/." "/etc/elab_birdhouse/"

sudo rm -rf /etc/nginx/sites-enabled/ > /dev/null 2>&1
sudo rm -rf /etc/nginx/sites-available/ > /dev/null 2>&1

# Copy flaskmain_proxy
sudo mkdir /etc/nginx/sites-enabled/
sudo mkdir /etc/nginx/sites-available/
sudo cp "${DIR}/flaskmain_proxy" "/etc/nginx/sites-available/flaskmain_proxy"
sudo ln -s /etc/nginx/sites-available/flaskmain_proxy /etc/nginx/sites-enabled
sudo systemctl restart nginx

# Enable camera after next reboot
sudo raspi-config nonint do_camera 0

# Activate SSH, change hostname and password
sudo raspi-config nonint do_ssh 0
sudo raspi-config nonint do_hostname elab-birdhouse
echo -e "birdslab\nbirdslab" | sudo passwd pi

# Copy uwsgi.service, add service and start it
TEMPLATE="${DIR}/uwsgi.service"
UWSGI_PATH=$(which uwsgi)

sed -e "s|\${path}|${UWSGI_PATH}|" "${TEMPLATE}" > "/etc/systemd/system/uwsgi.service"
sudo systemctl daemon-reload
sudo systemctl start uwsgi.service
sudo systemctl enable uwsgi.service
sudo apt-get autoremove -y

sudo rm -rf /home/pi/birdhouse_application/
sudo reboot
echo "Restarted"

sudo systemctl status uwsgi
sudo systemctl status nginx
