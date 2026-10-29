*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B4b}=   5m

*** Keywords ***
CB008717-D_B4b_UL_data_set_to_MCGSCG_UE_capable_of_UL_data_split
    Register Nrdc Ue With Default Pdu Session With A4
    UE UL Data Distribution    percent_value=50
    Start 160Mbps Traffic In UL
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=1    pdu_id=1    traffic_duration=${TRAFFIC_DURATION_SEC_D_B4b}
    ...    expected_throughput=160    expected_ul=79    scell=1    cell_group=SCG

Start 160Mbps Traffic In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=160

Set Ul Data Split Primary Path MCG
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/CB008717/delta_NRDRB-11_ul_Data_Split_Primary_Path_MCG.json
