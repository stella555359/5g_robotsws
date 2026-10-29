*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release: 25R2

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B13}=   5m
${TRAFFIC_DURATION_BEFORE_PSCELL_D_B13}=   2m

*** Keywords ***
CB008490-D_B13_NR-DC_PSCell_Addition_with_the_DL_Transmission_at_SN_starting_post_the_reception_of_PDCP_Status_Report
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_D_B13}
    Start L1l2bip Mirroring
    Send A4 Measurement And Trigger Pscell Addition
    Stop L1l2bip Mirroring
    Start Traffic 450Mbps In DL
    Check Data Traffic On Mcg And Scg Leg    ue_id=1   traffic_duration_sec=${TRAFFIC_DURATION_SEC_D_B13}    expected_throughput=450
