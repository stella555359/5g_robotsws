#!/bin/bash
sudo apt update && sudo apt -y install ute-ca
sleep 10s
sudo systemctl start ute-ca
sudo systemctl status ute-ca | grep Active: