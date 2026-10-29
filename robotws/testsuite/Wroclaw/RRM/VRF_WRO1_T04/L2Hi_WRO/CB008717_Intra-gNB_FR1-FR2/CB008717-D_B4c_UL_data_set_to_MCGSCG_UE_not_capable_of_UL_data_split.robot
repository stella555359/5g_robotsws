*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B4c}=   5m

*** Keywords ***
CB008717-D_B4c_UL_data_set_to_MCGSCG_UE_not_capable_of_UL_data_split
    Register Nrdc Ue With Ul Traffic With A4
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=4    pdu_id=4    traffic_duration=${TRAFFIC_DURATION_SEC_D_B4c}
    ...    expected_throughput=130    expected_ul=129    scell=0    cell_group=MCG

Register Nrdc Ue With Ul Traffic With A4
    Register Ue With Default Pdu Session    ue_id=4    pdu_id=4
    UE UL Data Distribution    ue_id=4    percent_value=50
    Set expected messages flows for A4 measurement based PSCell addition for UE4, gNB2
    Send A4 Measurement    ue_id=4
    Verify expected messages flows for A4 measurement based PSCell addition for UE4, gNB2
    Start 130Mbps Traffic In UL

Start 130Mbps Traffic In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=4 qfi=1 dir=ul mbps=130

Set Ul Data Path For Ul Split Not Capable Ue
    Send Delta Commissioning
    ...    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_ul_Data_Path_Ul_Split_Not_Cap_Ue_NrDc.json
    ...    skip_relation_errors=True
