*** Settings ***
Documentation       Keywords used for wts simulator
Library  taf.sw.wtssim
Library	 Telnet
Library	 OperatingSystem

*** Keywords ***
Setup EPCSim
    Run Process  /home/ute/sbts_qt/epcsim_scripts/epc_start_robotws.sh  shell=True
    Check If WTS Is Active

Setup WTS
    Run Keyword And Ignore Error   Teardown Egate
    Run Keyword And Ignore Error  Teardown Edaemon  alias=edaemon1
    Setup Egate  egate_port=${EGATE_PORT}
    Setup Edaemon  edaemon_port=${EDAEMON_PORT}  alias=edaemon1
    Link Edaemons To Egate  edaemon1

Teardown WTS
    [Arguments]  ${subdirectory}=${OUTPUT_DIR}
    Collect Egate Log Files  subdirectory=${subdirectory}
    Collect Edaemon Log Files  subdirectory=${subdirectory}  alias=edaemon1
    Teardown Egate
    Teardown Edaemon  alias=edaemon1
    Kill ePC SIM Processes

Kill ePC SIM Processes
    Run  sudo killall egate
    Run  sudo killall edaemon

Reach OnAir WTS
    Setup WTS
    Reach OnAir With WTS
    Check If WTS Is Active
