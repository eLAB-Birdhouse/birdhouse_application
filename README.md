# birdhouse_application
Application for the birdhouse camera | application pour la caméra du nichoir.



## Installation for developpment purpose

- Download [Raspberry OS](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit);

- Install it on the SD card using [Balena Etcher](https://www.balena.io/etcher/);

- Copy the content of the folder `boot` (from <https://github.com/eLAB-Birdhouse/birdhouse_application>) to the `boot` partition of the SD card;

- Then change the SSID and password in `wpa_supplicant.conf`;

- Put the SD card in your RPI and start it;

- `ssh pi@raspberrypi.local`, password `raspberry`, then :

  - `sudo apt install git -y && git clone https://github.com/eLAB-Birdhouse/birdhouse_application.git`;
  - `chmod +x ~/birdhouse_application/install.sh && ~/birdhouse_application/install.sh`.

  The last command can take some time to run and the Raspberry will reboot at the end. Wait 1 to 2 minute for the card the restart.

Now the password is  `birdslab` and the hostname is `elab-birdhouse`. In other words, you will need to use: `ssh pi@elab-birdhouse` and the password `birdslab` to open a new ssh terminal.

The application is located within the `/etc/elab_birdhouse/`, and in order to restart the service you can use `sudo systemctl restart uwsgi`  or `sudo systemctl stop uwsgi` and `sudo systemctl start uwsgi`. Eventually you can check the service status with `systemctl status uwsgi`.

If all is working as expected you will be able to open <http://elab-birdhouse.local/> in your browser.



