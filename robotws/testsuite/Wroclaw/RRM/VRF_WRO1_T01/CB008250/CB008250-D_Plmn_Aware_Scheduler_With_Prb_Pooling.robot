*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Resource    CB008250_keywords.robot
Library     ../resources/common_keywords.py
Library     keywords_CB008250.py

Documentation
...    author: Lukasz Filipek (lukasz.filipek@nokia.com)
...    maintainer: Lukasz Filipek
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 26R1

Suite Setup      Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Modify Sansa Config File
    ...       AND    Disable Actrat1alloc
    ...       AND    Set Minrcellutilperplmn And Nrg To 5min
    ...       AND    Enable Slice Aware Scheduler
    ...       AND    Enable Plmn Aware Scheduler
    ...       AND    Enable Actslicenumext
    ...       AND    Enable Plmn Spid And Resource Groups
    ...       AND    Enable PRB Pooling
    ...       AND    Enable DSS Feature On Gnb-2 Cell-3
    ...       AND    Configure SA VM interfaces
    ...       AND    Reach Onair Without Confirmation    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Activate XP Link
    ...       AND    Proceed With DSS Activation Script
    ...       AND    Wait For Next Full Pm Interval

Test Teardown     Run Keywords    Deregister Multiple Ues    start_ue_id=${FIRST_UE_ID}    end_ue_id=${LAST_UE_ID}
    ...       AND    Send Configuration ID To Scout

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=    20s
${LOCAL_MOID_BTS_CELL3}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${FIRST_UE_ID}=    20
${LAST_UE_ID}=    29

*** Test Cases ***
CB008250-D-B1_B2_Interaction_Between_PLMN-Aware_Scheduler_With_PRB_Pooling_And_DSS
    Register Multiple SA Ues With Default Pdu Session    start_ue_id=${FIRST_UE_ID}    end_ue_id=${LAST_UE_ID}
    Start Data Traffic For Multiple Ues    start_ue_id=${FIRST_UE_ID}    end_ue_id=${LAST_UE_ID}    dl_tput=100    ul_tput=20
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats For Multiple Ues    start_ue_id=${FIRST_UE_ID}    end_ue_id=${LAST_UE_ID}
    Wait For Next Full Pm Interval
    Check If Resource Groups Have Incremented Pm Counters    localmoid=${LOCAL_MOID_BTS_CELL3}
    Check If All Plmns Have Incremented Pm Counters    localmoid=${LOCAL_MOID_BTS_CELL3}
    Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl

*** Keywords ***
Enable PRB Pooling
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_actSlowPrbPooling.json
    Wait for gNB Configured state

Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Wait For Next Full Pm Interval
    Check If Values Of Counters Covers Set Target Share    local_moid=${LOCAL_MOID_BTS_CELL3}    margin=0.1
    Check If Values Of Counters Covers Set Target Share    local_moid=${LOCAL_MOID_BTS_CELL3}    margin=0.1
    ...    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}

Enable DSS Feature On Gnb-2 Cell-3
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_dss.json
    Wait for gNB Configured state
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_bwp_profile_dss_align.json
    Wait for gNB Configured state

Activate XP Link
    Execute egate command    cmd=sim_trace enb=1 protocol=xp
    Sleep  2s
    Execute egate command    cmd=enb_xp_param id=1 xp_listening_socket=on ignore_xp=off
    Sleep  2s
    Execute egate command    cmd=enb_xp_param id=1 xp_peers=2
    Sleep  2s
    Execute egate command    cmd=enb_xp_link_up enb=1 target=2
    Sleep  200s

Modify Sansa Config File
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_enb id=1     enb_id_macro=0x00001 xp_management=on xp=$ENB1_X2_ADDR:32742 xpu=$ENB1_X2_ADDR:32742 local_crm=on
    wts.Delete    set_cell id=1 enb=1
    wts.Insert    ${SET_DSS_ENB_CELL}    after    enb_param id=1
    wts.Modify    set_gnb id=2    xp_management=on xp=$GNB_X2_ADDR:32742 xpu=$GNB_X2_ADDR:32742
    wts.Modify    set_cell id=3 gnb=2    nr_arfcn=135580:126380
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Proceed With DSS Activation Script
    Log to console  \n*** DSS activation script started ***
    Execute Egate Command    cmd=script file=${CURDIR}/../resources/config/dss_start.cfg
    ...   fail_regexp=DSS_SETUP_FAILURE Not matching cell Ids - NR DSS Setup Req not received yet   timeout=120
    Log to console  \n*** DSS activation script completed ***

