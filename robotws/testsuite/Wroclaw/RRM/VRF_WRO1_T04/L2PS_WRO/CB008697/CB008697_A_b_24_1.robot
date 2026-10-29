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

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TIMER_VALUE}=    30
${LOCAL_MOID_PCELL_TDD}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${LOCAL_MOID_PCELL_FDD}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB008697_A_b_24_1_FDD_FDD_2xTDD_OAI_activation_more_Scells_than_currently_allowed_to_be_active_for_overheating_while_timerPostOH_is_running
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND    Change value of timerPostOverheating to 30s
    Set Internal Traffic Type To UE     ue_id=31    pdu_id=3
    Attach Ue    ue_id=31
    Establish Pdu Session    ue_id=31    pdu_id=3    gw_id=3
    Start DL Data Traffic For 4CC    ue_id=31    pdu_id=3
    Verify DL Tput For 4CC    ue_id=31    num_scells=3
    Trigger UE Overheating with reducedCCsDL=1    ue_id=31
    Verify Tput For 4CC And ReducedCCsDL 1     ue_id=31     num_scells=1
    Trigger UE Overheating with reducedCCsDL=2    ue_id=31
    Verify Tput For 4CC And ReducedCCsDL 2 Before Timer Expiration
    End UE Overheating State
    Wait For Timer Expiration
    Verify 4CC Tput After Timer Expiration    ue_id=31    num_scells=3
    Verify SCELL_DEACT_UE_OVH_REPORTS Counter Value   local_moid=${LOCAL_MOID_PCELL_FDD}
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE    ue_id=31    pdu_id=3
    ...    AND    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Start DL Data Traffic For 4CC
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=175 trf_id=1
    ...    pass_regexp=Started Downlink Internal traffic over UDP on Ue:31.*TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=175 trf_id=2
    ...    pass_regexp=Started Downlink Internal traffic over UDP on Ue:31.*TrfId:2
    Sleep    20s

Verify DL Tput For 4CC
    [Arguments]    ${ue_id}    ${num_scells}
    FOR    ${cc}    IN RANGE    ${0}    ${${num_scells}+${1}}
        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
        Should Be True    ${cc_tput} > ${70}
    END

Verify Tput For 4CC And ReducedCCsDL 1
    [Arguments]    ${ue_id}    ${num_scells}
    FOR    ${cc}    IN RANGE    ${0}    ${${num_scells}+${1}}
        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
        Should Be True    ${cc_tput} > ${70}
    END
    Verify There Is No Tput On Scell    ue_id=${ue_id}    cc=2
    Verify There Is No Tput On Scell    ue_id=${ue_id}    cc=3

Verify Tput For 4CC And ReducedCCsDL 2 Before Timer Expiration
    Verify Tput For 4CC And ReducedCCsDL 1    ue_id=31     num_scells=1

Verify 4CC Tput After Timer Expiration
    [Arguments]    ${ue_id}    ${num_scells}
    FOR    ${cc}    IN RANGE    ${0}    ${${num_scells}+${1}}
        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
        Should Be True    ${cc_tput} > ${50}
    END

Trigger UE Overheating with reducedCCsDL=1
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=1
    ...    pass_regexp=ueAssistanceInformation
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_1}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_1}
    Sleep    5s

Trigger UE Overheating with reducedCCsDL=2
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=2
    ...    pass_regexp=ueAssistanceInformation
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_2}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_2}
    Sleep    5s

End UE Overheating State
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=31 forOverheating=yes
    ...    pass_regexp=ueAssistanceInformation
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_END_OH}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_END_OH}
    Sleep    5s

Wait For Timer Expiration
    Sleep    20s

Verify SCELL_DEACT_UE_OVH_REPORTS Counter Value
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Full Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55316C12001
    ...    value=${2}
    ...    local_moid=${local_moid}
    ...    filepath=${pm_counters_filepath}

Stop All Data Transfers And Detach UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id}
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Change value of timerPostOverheating to 30s
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_timerPostOverheating.json
    Sleep    3s
