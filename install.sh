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
sudo apt upgrade -y

# Install needed packages and python3 modules
sudo apt install nginx python3 python3-pip -y
sudo python3 -m pip install flask uwsgi -U

# Create installation directory
sudo mkdir /etc/elab_birdhouse/
sudo chown www-data /etc/elab_birdhouse/
# cd /etc/elab_birdhouse/

# Get source path
SOURCE="${BASH_SOURCE:-0}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# FILE="${DIR}/settings.py"
# if [ -f "$FILE" ]; then
#     echo "$FILE exists (you can edit the settings later, using this file)"
# else 
#     cp "${DIR}/settings_default.py" "${DIR}/settings.py"
#     echo "You must edit the settings in: ${FILE}."
# fi

# Add service and start it
TEMPLATE="${DIR}/sunset.service"
ROUTINE_PATH="${DIR}/routine.py"

systemctl stop sunset
sed -e "s|\${path}|${ROUTINE_PATH}|" "${TEMPLATE}" > "/lib/systemd/system/sunset.service"
systemctl daemon-reload
systemctl start sunset
#echo "$DIR"