*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY310    RF50
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Variables    ta5g_global_var
Library      taf.sw.reporting_portal
Library      ../resources/NameChanger.py
Resource     CB010545_Keywords.robot
Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot

Suite Setup        Run Keywords    Enable Cloud
...                AND             Reach Onair Aic           lua_cfg=/opt/wts/latest/basic_setup.cfg          check_edaemon_port=${TRUE}


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_PM_5min}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_5}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_5}     ${CURDIR}/configs/CU_Delta_5min_miNrUeQuan.xml
${DELTA_VDU_5}     ${CURDIR}/configs/DU_Delta_5min_miNrUeQuan.xml
${GOLDEN_SCF_VCU}      ${CURDIR}/resources/golden_scf_vcu.xml
${GOLDEN_SCF_VDU}      ${CURDIR}/resources/golden_scf_vdu.xml
${RANNIC_DIST_NAME}    MRBTS-1/EQM-1/APEQM-1/RNICMOD-1
${cell_nr}         1
${ue_nr}           1
${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}=    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
...                                                    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200



*** Test Cases ***
2_CB010545-F_Verify_M2M_Remote_Command_getDuCell_SA
    [Documentation]    Verify the command getCuCell in addition to existing output
    ...                is provided number of active 5G UE's (based on new counter AVG_ACTIVE_UE_DU)
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Perform Parameter Commissioning Aic
    ...     parameter=miNrUeQuan    value=5min    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...     AND    Perform Parameter Commissioning Vdu Aic
    ...     parameter=miNrUeQuan    value=5min    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    [Teardown]    Run Keywords    Perform Parameter Commissioning Aic
    ...     parameter=miNrUeQuan    value=15min    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1
    ...     AND    Perform Parameter Commissioning Vdu Aic
    ...     parameter=miNrUeQuan    value=15min    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1

    Wait For Next Full Pm Interval Aic    vdu=1
    Log to console    SET_AMF
    Execute Egate Command    cmd=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD}
    Log to console    ue_register id=1
    Execute Egate Command    cmd=ue_register id=1
    Sleep    2s
    Verify Egate Content    UE performed Registration type INITIAL_REGISTRATION
    Log to console    set_pdu
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Log to console    ue_pdu_session_setup
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Sleep    1s
    Log to console    trf_data_
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl

    Wait For Next Full Pm Interval Aic    vdu=1

    Log to console    Get Next vRAN XML PM Counters Files
    Sleep    10s
    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    output_dirpath=${dirpath}    vdu=1

    Log to console    Verify M55181C00007
    verify last counters in file
    ...  M55181C00007   1       AVG_ACTIVE_UE_DU
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_counter_file}

    Report pm counter    M55181C00007  1           Passed

    ${cell}    ${cell_info}    Get vDu Cells nr1
    Log to console    Cell ID: ${cell}, Active UEs: ${cell_info}
    Should Be True		${cell} == ${cell_nr} and ${cell_info} == ${ue_nr}

    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=1
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    Add Scout External Execution ID To Reporting Portal
