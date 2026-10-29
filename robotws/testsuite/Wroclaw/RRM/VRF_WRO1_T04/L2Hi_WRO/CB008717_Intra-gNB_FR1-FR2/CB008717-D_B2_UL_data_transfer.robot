*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py
Library     ta5g_pm_counters

Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B2}=   5m

*** Keywords ***
CB008717-D_B2_UL_data_transfer
    Register Nrdc Ue With Default Pdu Session With A4
    UE UL Data Distribution
    Start 135Mbps Traffic In UL
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=1    pdu_id=1    traffic_duration=${TRAFFIC_DURATION_SEC_D_B2}
    ...    expected_throughput=135    expected_ul=134    scell=0    cell_group=MCG
    Verify If Pm Counters Arent Incremented

Start 135Mbps Traffic In UL
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=135
