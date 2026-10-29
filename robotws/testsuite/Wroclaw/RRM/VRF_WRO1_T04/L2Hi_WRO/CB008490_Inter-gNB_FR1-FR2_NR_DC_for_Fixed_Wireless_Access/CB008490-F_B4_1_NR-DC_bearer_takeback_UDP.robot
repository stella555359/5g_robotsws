*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_B4_1}=   10m
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}=   2m

*** Keywords ***
CB008490-F_B4_1_NR-DC_bearer_takeback_UDP
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}
    Send A4 Measurement And Trigger Pscell Addition
    Start Traffic 450Mbps In DL
    Check Data Traffic On Mcg And Scg Leg    traffic_duration_sec=${TRAFFIC_DURATION_SEC_B4_1}    expected_throughput=450
    Trigger Max Rlc Retx
    Check Data After Takeback
    Send A4 Measurement And Trigger Pscell Addition
    Check Data Traffic On Mcg And Scg Leg    traffic_duration_sec=${TRAFFIC_DURATION_SEC_B4_1}    expected_throughput=450

Check Data After Takeback
    Sleep    ${TRAFFIC_DURATION_BEFORE_PSCELL_SEC}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=300    unit=mbps    margin=0.2    direction=dl




