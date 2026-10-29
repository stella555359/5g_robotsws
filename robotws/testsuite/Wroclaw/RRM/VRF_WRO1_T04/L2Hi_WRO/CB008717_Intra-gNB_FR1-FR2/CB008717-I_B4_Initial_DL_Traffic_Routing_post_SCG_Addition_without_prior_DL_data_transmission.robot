*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...    release:

*** Variables ***
${TRAFFIC_DURATION_SEC_I_B4}=   5m
${INITIAL_DL_TRAFFIC_DUR_MS}=  100

*** Keywords ***
CB008717-I_B4_Initial_DL_Traffic_Routing_post_SCG_Addition_without_prior_DL_data_transmission
    Register Ue With Default Pdu Session
    Send A4 Measurement
    Start Udp Traffic 150Mbps In DL
    Initial DL Traffic Routing Should Be Visible On Scg
    Increase DL Data Traffic To 450Mbps
    Check Data Traffic With Qfi Stats On Mcg And Scg Leg

Initial DL Traffic Routing Should Be Visible On Scg
    Sleep    10s    Waiting for new packets
    Run Keyword And Continue On Failure    Check Number Of Received Packets
    ...    ue_id=1    pdu_id=1    qfi_id=1    packet_number=1325
    ...    direction=dl    optional_params=dc_cell_group=scg

Check Data Traffic With Qfi Stats On Mcg And Scg Leg
    Sleep    ${TRAFFIC_DURATION_SEC_I_B4}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl dc_cell_group=scg
    Execute Egate Command And Wait For Data    cmd=uec_stats id=1 enb=2 cell=1 type=cell_data_pdcp format=long
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=450    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl