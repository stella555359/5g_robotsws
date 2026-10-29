*** Settings ***
Library     ta_emss
Library     ute_wtssim
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot

Documentation
...    This file contains general keywords used for testing Feature CB008158.

*** Keywords ***
Enable Latency And PMQAP Counters
    Enable Latency Pm Counters
    Enable Pmqap Sa 5qi6 Nsa Qci6

Enable Pmqap Sa 5qi6 Nsa Qci6
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_sa_5qi6_nsa_qci6.json

Enable Intra Gnb Ho And A3 Meas
    Configure    ${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.yaml

Enable Sansa Pmqap
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_sansa_pmqap_range_from_1_to_9.json

Set Dl Delay Threshold to 10ms
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_delay_threshold_value_10ms.json

Set Dl Delay Threshold to 60ms
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_delay_threshold_value_60ms.json

Prepare Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=100,50,20,10

Prepare Bler Testmode In Ul
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 ul_bler=10,10,0,0,0,0,0,0

Activate Bler Testmode
    [Arguments]    ${ue_id}    ${scell}    ${profile_id}=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=${profile_id} scell=${scell}

Deactivate Bler Testmode
    [Arguments]    ${ue_id}    ${scell}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=deactivate profile_id=1 scell=${scell}

Start 60Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Activate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60

Start 450Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
