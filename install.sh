#!/bin/bash
# You might need to:
# chmod +x install.sh

# Check for sudo permissions
if [ "$EUID" != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Update and upgrade packages
sudo apt update
sudo apt full-upgrade -y

# Install needed packages and python3 modules
sudo apt remove --purge nginx nginx-common nginx-full -y
sudo apt install nginx python3 python3-pip -y
sudo python3 -m pip install flask picamera uwsgi -U
sudo rm -r /var/www/.local
sudo rm -r /var/www/.cache
sudo mkdir /var/www/.local
sudo mkdir /var/www/.cache
sudo chown www-data.www-data /var/www/.local
sudo chown www-data.www-data /var/www/.cache
sudo -H -u www-data python3 -m pip install flask picamera uwsgi -U

# Add log folder
sudo rm -r /var/log/uwsgi
sudo mkdir -p /var/log/uwsgi
sudo chown -R www-data:www-data /var/log/uwsgi

# Create installation directory
sudo rm -r /etc/elab_birdhouse/
sudo mkdir /etc/elab_birdhouse/

# Makes www-data own the directory and add it to the video group
sudo chown www-data /etc/elab_birdhouse/
sudo usermod -aG video www-data

# Get source path
SOURCE="${BASH_SOURCE:-0}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Copy all the installation content to the specified destination
cp -a "${DIR}/." "/etc/elab_birdhouse/"
# cp "${DIR}/uwsgi.ini" "/etc/nginx/sites-available/uwsgi.ini"

sudo rm -r /etc/nginx/sites-enabled/
sudo rm -r /etc/nginx/sites-available/

# Copy flaskmain_proxy
sudo mkdir /etc/nginx/sites-enabled/
sudo mkdir /etc/nginx/sites-available/
sudo cp "${DIR}/flaskmain_proxy" "/etc/nginx/sites-available/flaskmain_proxy"

# FILE="${DIR}/settings.py"
# if [ -f "$FILE" ]; then
#     echo "$FILE exists (you can edit the settings later, using this file)"
# else 
#     cp "${DIR}/settings_default.py" "${DIR}/settings.py"
#     echo "You must edit the settings in: ${FILE}."
# fi
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
# sudo systemctl status uwsgi.service
sudo systemctl enable uwsgi.service
sudo apt autoremove -y
sudo reboot
# systemctl daemon-reload
# systemctl start sunset
#echo "$DIR"
