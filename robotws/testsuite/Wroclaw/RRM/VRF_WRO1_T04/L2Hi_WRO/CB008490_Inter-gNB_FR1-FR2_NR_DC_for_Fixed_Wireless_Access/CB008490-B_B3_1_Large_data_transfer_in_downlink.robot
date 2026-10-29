*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC_B3_1}=   10m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}=   2m

*** Keywords ***
CB008490-B_B3_1_Large_udp_data_transfer_in_downlink
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_B3_1}
    Send A4 Measurement And Trigger Pscell Addition
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_B3_1}
    Check Data Traffic On Mcg And Scg Leg    expected_throughput=450
