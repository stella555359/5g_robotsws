*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py
Library     ../resources/common_keywords.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...    release:

*** Variables ***
${TRAFFIC_DURATION_SEC_B_B3}=   5m

*** Keywords ***
CB008717-B_B3_DL_and_UL_data_handling
    Register Nrdc Ue With DL And Ul Udp Traffic With A4
    Check Data Traffic And Packets Lost On Mcg And Scg Leg

Register Nrdc Ue With DL And Ul Udp Traffic With A4
    Register Ue With Default Pdu Session
    Start Udp Traffic 450Mbps In DL and 50Mbps In Ul
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2
    Send A4 Measurement
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2

Start Udp Traffic 450Mbps In DL and 50Mbps In Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=50

Check Data Traffic And Packets Lost On Mcg And Scg Leg
    Sleep    ${TRAFFIC_DURATION_SEC_B_B3}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=ul
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=450    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1
    ...    pdu_id=1    qfi_id=1
    ...    expected_throughput=50    unit=mbps    margin=0.2    direction=ul
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=dl
    Run Keyword And Continue On Failure    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1
    ...    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=ul
