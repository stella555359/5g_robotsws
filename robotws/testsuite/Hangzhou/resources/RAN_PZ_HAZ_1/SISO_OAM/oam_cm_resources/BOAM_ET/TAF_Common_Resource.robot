*** Settings ***
Documentation
...    TAF Common Resource file

Resource          TAF_Common_BTS.robot
Resource          TAF_Common_Admin.robot
Resource          TAF_Common_Emss.robot
#    Resource          ${CURDIR}/TAF_Common_Wtssim.robot
Library    Gzip_uncompress.py
Library    file.py
Library    utils.py
Library    emssim.py
Library    connection.py
Library    ta_emss





*** Keywords ***
Cell Setup With Airphone
    Run    sudo ip addr add 10.0.1.131/24 dev eth3 && sudo ip addr add 10.0.1.132/24 dev eth3 && sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3 && sudo ip addr add 10.0.1.135/24 dev eth3 && sudo ip addr add 10.0.1.136/24 dev eth3
	Run    sudo ip addr add 10.0.1.137/24 dev eth3 && sudo ip addr add 10.0.1.99/24 dev eth3 && sudo ip addr add 10.0.2.99/24 dev eth4
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
	${password}    Run    sudo cat /etc/ute/vncpasswd
    SSHLibrary.Open Connection    host=127.0.0.1    port=22    timeout=60
    SSHLibrary.Login    username=ute    password=${password}   delay=1s
	SSHLibrary.Write   sudo pkill -9 edaemon && pkill -9 egate
	Sleep    3s
    SSHLibrary.Write   cd /opt/iphy/latest && sudo ./edaemon --port 22222 && ./egate --port 20000
	Sleep    3s
    SSHLibrary.Write   telnet 0 20000
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write   reset
	Sleep    5s
	Wait Until Keyword Succeeds    60    10   ADMIN Check Bts Status    status=Configured
    SSHLibrary.Write   cfg file=/opt/iphy/latest/basic_setup.cfg
	Wait Until Keyword Succeeds    30    5   ADMIN Check Bts Status    status=OnAir

Cell Setup With Wtssim
    Run    sudo ip addr add 10.0.1.131/24 dev eth3 && sudo ip addr add 10.0.1.132/24 dev eth3 && sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3 && sudo ip addr add 10.0.1.135/24 dev eth3 && sudo ip addr add 10.0.1.136/24 dev eth3
	Run    sudo ip addr add 10.0.1.137/24 dev eth3 && sudo ip addr add 10.0.1.99/24 dev eth3 && sudo ip addr add 10.0.2.99/24 dev eth4
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
	Run Keyword And Ignore Error    Teardown egate and edaemon
    Setup egate and edaemon
    Start egate process with lua configuration file
    Start egate services     timeout=300    alias=wts1
    Execute egate command with all arguments
    Execute egate command and wait for data with all arguments
