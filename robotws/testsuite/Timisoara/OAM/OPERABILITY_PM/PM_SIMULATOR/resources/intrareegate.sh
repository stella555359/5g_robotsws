#!/bin/bash
cd /opt/iphy/latest 
./egate --port 20000 
sudo -S ./edaemon --port 22222
telnet 0 20000
