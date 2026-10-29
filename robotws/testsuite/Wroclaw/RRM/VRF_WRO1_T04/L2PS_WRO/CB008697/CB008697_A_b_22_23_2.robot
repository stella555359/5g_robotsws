*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           CONFIGS_L2PS_WRO/CA_4CC_FDD_TDD_20M/iphy_and_scfc.yaml    #tag not supported on common agent

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      CB008697_keywords.py
Resource     CB008697_variables.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_CA_4CC_FDD_TDD_20M.xml
...    AND                     Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...    AND                     Find Scfc And Fix And Send Full Commissioning
...                            scfc_filename=scfc_CA_4CC_FDD_TDD_20M.xml
...    AND                     Check Radios Availability
...    AND                     Reach Onair
...                            lua_cfg=${CURDIR}/config/egate_4c_CA_FDD-TDD_20mhz.lua
...    AND                     Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${PCELL_FDD_LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${TRAFFIC_DURATION_SEC}=    30

*** Test Cases ***
CB008697_A_b_22-23_2_TDD_TDD_2xFDD_Scell_re-activation_for_data_activity_when_UE_is_overheated
    Send Delta Commissioning
    Set Internal Traffic Type To Ue With Multiple Pdu Sessions    ue_id=31
    Attach Ue    ue_id=31
    Establish Pdu Session    ue_id=31    pdu_id=1    gw_id=1
    Create Csi Profile
    Start Big Dl Data Transfer And Check If All SCell Are Activated    ue_id=31
    Activate Csi Profile For UE31
    Sleep    5s
    Send Overheating Assistance And Check If SCell3 Is Deactivated    ue_id=31
    Check Activation Of OAI
    Reduce Dl Data Transfer And Check If Scell2 Is Deactivated    ue_id=31
    Increase DL Data Transfer And Check If Scell3 Is Activated and Scell2 Is Still Deactived    ue_id=31
    End UE Overheating State
    Attach Ues And Establish Session
    Start Data Traffic To Multiple Ues
    Verify Value of PM counter Scell Deact Ue Ovh Reports     local_moid=${PCELL_FDD_LOCAL_MOID}
    [Teardown]     Stop All Data Transfers And Detach UE

*** Keywords ***
End UE Overheating State
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=31 forOverheating=yes
    ...    pass_regexp=ueAssistanceInformation
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_END_OH}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_END_OH}
    Sleep    200s

Start Data Traffic To Multiple Ues
    Execute Egate Command
    ...    cmd=trf_data_start ue=22 dir=dl mbps=20 pdu=2 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=23 dir=dl mbps=20 pdu=3 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=24 dir=dl mbps=20 pdu=4 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=25 dir=dl mbps=20 pdu=5 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=26 dir=dl mbps=20 pdu=6 trf_id=1
    Sleep    ${TRAFFIC_DURATION_SEC}

Attach Ues And Establish Session
    Attach Multiple Ues    first_ue_id=22    last_ue_id=26
    Establish Pdu Session    ue_id=22    pdu_id=2   gw_id=2
    Establish Pdu Session    ue_id=23    pdu_id=3   gw_id=3
    Establish Pdu Session    ue_id=24    pdu_id=4   gw_id=4
    Establish Pdu Session    ue_id=25    pdu_id=5   gw_id=5
    Establish Pdu Session    ue_id=26    pdu_id=6   gw_id=6
    Sleep   5s

Stop All Data Transfers And Detach UE
     Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
     Execute Egate Command    cmd=trf_data_stop ue=22 pdu=2
     Execute Egate Command    cmd=trf_data_stop ue=23 pdu=3
     Execute Egate Command    cmd=trf_data_stop ue=24 pdu=4
     Execute Egate Command    cmd=trf_data_stop ue=25 pdu=5
     Execute Egate Command    cmd=trf_data_stop ue=26 pdu=6
     Sleep    5s
     Execute Egate Command    cmd=ue_deregister id=31 ue_deregister_type=switch_off
     Execute Egate Command    cmd=ue_deregister id=22 ue_deregister_type=switch_off
     Execute Egate Command    cmd=ue_deregister id=23 ue_deregister_type=switch_off
     Execute Egate Command    cmd=ue_deregister id=24 ue_deregister_type=switch_off
     Execute Egate Command    cmd=ue_deregister id=25 ue_deregister_type=switch_off
     Execute Egate Command    cmd=ue_deregister id=26 ue_deregister_type=switch_off

Send Delta Commissioning
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_iniNumSCellsToActivate.json

Add Scells
    Execute Egate Command   cmd=ue_measurement_send_nr event=A1 meas_id=1 id=1 srsrp_nr=127 srsrq_nr=127 ssinr_nr=127

Reduce Dl Data Transfer And Check If Scell2 Is Deactivated
    [Arguments]    ${ue_id}
    Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} dir=dl mbps=99 pdu=1 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} dir=dl mbps=1 pdu=1 trf_id=2
    ...    pass_regexp=SCellIndex 2 deactivated successfully at airphone.
    ...    timeout=5


Stop All Data Transfer For Ue31
    Execute Egate Command    cmd=trf_data_stop ue=31 pdu=1
    Sleep    15s

Stop All Data Transfer For Ue
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Execute Egate Command    cmd=trf_data_stop ue=22 pdu=2
    Execute Egate Command    cmd=trf_data_stop ue=23 pdu=3
    Execute Egate Command    cmd=trf_data_stop ue=24 pdu=4
    Execute Egate Command    cmd=trf_data_stop ue=25 pdu=5
    Execute Egate Command    cmd=trf_data_stop ue=26 pdu=6
    Sleep   10s

Increase DL Data Transfer And Check If Scell3 Is Activated and Scell2 Is Still Deactived
    [Arguments]    ${ue_id}
    Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} dir=dl mbps=150 pdu=1 trf_id=1
    Sleep    5
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} dir=dl mbps=150 pdu=1 trf_id=2
    ...    pass_regexp=SCellIndex 2 deactivated successfully at airphone.
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone.
    ...    timeout=60

Activate Csi Profile For UE1
   Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=10 scell=3

Activate Csi Profile For UE31
   Execute Egate Command   cmd=ue_testmode_set_nr id=31 testmode=csi_override action=activate profile_id=10 scell=3

Start Big Dl Data Transfer And Check If All SCell Are Activated
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data   cmd=trf_data_start ue=${ue_id} dir=dl mbps=175 pdu=1 trf_id=1
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone.
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone.
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone.
    ...    timeout=10

Set Internal Traffic Type To Ue With Multiple Pdu Sessions
    [Arguments]    ${ue_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

Create Csi profile
    Execute Egate Command   cmd=csi_override_testmode_nr profile_id=10 cqi=2 cqi_mode=fixed

Send Overheating Assistance And Check If SCell3 Is Deactivated
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=2
    ...    pass_regexp=SCellIndex 3 deactivated successfully at airphone.
    ...    timeout=10

Send Overheating Assistance And Check If SCell Is Deactivated
    Execute Egate Command
    ...    cmd=ue_assistance_send_nr ue_id=1 forOverheating=yes reducedCCsDL=1

Check Activation Of OAI
    Sleep    15s
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_2}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE}


Verify Value of PM counter Scell Deact Ue Ovh Reports
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File

    Log to console     expected M55316C12001 value for interval 5min = 1
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55316C12001
    ...    value=1
    ...    local_moid=${local_moid}
    ...    filepath=${PM_COUNTERS}
