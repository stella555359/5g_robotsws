*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release:

*** Variables ***
${TRAFFIC_DURATION_SEC_B_B2}=   10m

*** Keywords ***
CB008717-B_B2_Start_of_DL_data_transmission_over_secondary_path
    Register Nrdc Ue With Default Pdu Session With A4
    Start Udp Traffic 750Mbps In DL
    Check Dl Data Traffic On Mcg And Scg Leg    traffic_duration=${TRAFFIC_DURATION_SEC_B_B2}    expected_throughput=750

Start Udp Traffic 750Mbps In DL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=4
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=5
