*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../resourcesKRK/krk3_common/main_vran.robot
Resource      ../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Library      ta5g_pm_counters
Library       ute_reporting_portal
Resource    CB010545_Keywords.robot
Resource    ../resourcesKRK/krk3_common/pm_counters_vran.robot

Suite Setup       Testline Setup
#Suite Teardown    Testline Teardown
#Test Teardown     Test Case Teardown     pod_logs=no    oam_logs=no


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_PM_5min}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_5}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_5}     ${CURDIR}/configs/CU_Delta_5min_miNrUeQuan.xml
${DELTA_VDU_5}     ${CURDIR}/configs/DU_Delta_5min_miNrUeQuan.xml
${cell_nr}         1
${ue_nr}           1
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200



*** Test Cases ***
1_CB010545-F_Verify_M2M_Remote_Command_getCuCell
    [Documentation]    Verify the command getCuCell in addition to existing output
    ...                is provided number of active 5G UE's (based on new counter AVG_ACTIVE_UE_CU)
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup    config=&{CONFIG_PM_5min}
    ...     AND    Test Case Setup    reach_on_air=yes  config=&{CONFIG_PM_5min}  reboot_after_config=no
     Log to console    SET_AMF
     Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}
     Log to console    Sleep 2S
     sleep    2s
     Log to console    ue_register id=1
     Execute Egate Command    cmd=ue_register id=1
     Log to console    Sleep 2S
     sleep    2s
     Log to console    set_pdu
     Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
     Log to console    Sleep 2S
     sleep    2s
     Log to console    ue_pdu_session_setup
     Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
     Log to console    Sleep 2S
     sleep    2s
     Log to console    trf_data_
     Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    Log to console    Sleep 600S
    sleep    600s
#
    Log to console    Get Next vRAN XML PM Counters Files
    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    Log to console    sleep 30s
    Log to console    Verify M55181C00006
    verify last counters in file
    ...  M55181C00006   1       AVG_ACTIVE_UE_CU
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    sleep    10s

    Report pm counter    M55181C00006  1           Passed

    ${cell}    ${cell_info}    Get vCu Cells nr1
    Log to console    Cell ID: ${cell}, Active UEs: ${cell_info}
    Should Be True		${cell} == ${cell_nr} and ${cell_info} == ${ue_nr}

    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=1
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s
