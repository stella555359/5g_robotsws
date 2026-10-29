*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Mariusz Wacznski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...    CONFIGS_L2Hi_WRO/2_CELLS_FR1_FR2_TDD/2_CELLS_FR1_FR2_TDD.yaml

*** Variables ***
${TRAFFIC_DURATION_SEC_B_B8}=   60s

*** Keywords ***
CB008717-B_B8_Verification_of_dlDataSplitMode_with_dlOverF1Uonly
    Register Nrdc Ue With Default Pdu Session With A4
    Start Udp Traffic 450Mbps In DL
    Check Dl Data Traffic On Mcg And Scg Leg    traffic_duration=${TRAFFIC_DURATION_SEC_B_B8}    expected_throughput=205
