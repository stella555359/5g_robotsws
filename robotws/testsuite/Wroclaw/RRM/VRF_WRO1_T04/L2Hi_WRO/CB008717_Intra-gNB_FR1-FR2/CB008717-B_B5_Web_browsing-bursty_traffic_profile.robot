*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...    CONFIGS_L2Hi_WRO/2_CELLS_FR1_FR2_TDD/2_CELLS_FR1_FR2_TDD.yaml

*** Variables ***
${TRAFFIC_DURATION_SEC_B_B5}=   10s

*** Keywords ***
CB008717-B_B5_Web_browsing-bursty_traffic_profile
    Register Nrdc Ue With Default Pdu Session With A4
    Start Bursty Traffic And Check Traffic Statistic

Start Bursty Traffic And Check Traffic Statistic
    FOR  ${index}  IN RANGE  50
        Start Udp Traffic 450Mbps In DL
        Check Dl Data Traffic On Mcg And Scg Leg    traffic_duration=${TRAFFIC_DURATION_SEC_B_B5}    expected_throughput=450
        Decrease Udp Traffic to 3Mbps In DL
        Sleep    ${TRAFFIC_DURATION_SEC_B_B5}
        Log    ${index}
    END

Decrease Udp Traffic to 3Mbps In DL
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 trf_id=3
