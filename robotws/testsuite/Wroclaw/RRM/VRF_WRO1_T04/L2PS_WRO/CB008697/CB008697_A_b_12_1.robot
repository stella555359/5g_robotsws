*** Settings ***
Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      CB008697_keywords.py
Resource     CB008697_variables.robot

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    release: 25R2


*** Variables ***
${iphy_CB0008697_A_b_12_1}     ${CURDIR}/config/iphy_CA_4CC_FDD_TDD_20M_ABIP.xml
${scf_CB0008697_A_b_12_1}      ${CURDIR}/config/SBTS00/scfc_CA_4CC_FDD_TDD_20M_ABIP.xml
${cfg_CB0008697_A_b_12_1}      ${CURDIR}/config/egate_4c_CA_FDD-TDD_20mhz.lua
${LOCAL_MOID_PCELL_TDD}        PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${LOCAL_MOID_PCELL_FDD}        PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Keywords ***
CB008697_A_b_12_1_FDD_FDD_2xTDD_OAI_activation_more_Scells_than_currently_allowed_to_be_active_for_overheating
    Set Internal Traffic Type To UE     ue_id=31    pdu_id=3
    Attach Ue    ue_id=31
    Establish Pdu Session    ue_id=31    pdu_id=3    gw_id=3
    Start DL Data Traffic For 4CC    ue_id=31    pdu_id=3
    Verify DL Tput For 4CC    ue_id=31    num_scells=3
    Trigger UE Overheating with reducedCCsDL=1    ue_id=31
    Verify Tput For 4CC And ReducedCCsDL 1    ue_id=31    num_scells=1
    Trigger UE Overheating with reducedCCsDL=2    ue_id=31
    Verify Tput For 4CC And ReducedCCsDL 2    ue_id=31    num_scells=2
    Verify SCELL_DEACT_UE_OVH_REPORTS Counter Value   local_moid=${LOCAL_MOID_PCELL_FDD}


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
        Should Be True    ${cc_tput} > ${60}
    END

Verify Tput For 4CC And ReducedCCsDL 1
    [Arguments]    ${ue_id}    ${num_scells}
    FOR    ${cc}    IN RANGE    ${0}    ${${num_scells}+${1}}
        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
        Should Be True    ${cc_tput} > ${60}
    END
    Check How Many Scells Are Not Scheduled    ue_id=31    last_cc_id=3   exp_scells=2

Verify Tput For 4CC And ReducedCCsDL 2
    [Arguments]    ${ue_id}    ${num_scells}
    FOR    ${cc}    IN RANGE    ${0}    ${${num_scells}+${1}}
        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
        Should Be True    ${cc_tput} > ${0}
    END
    Sleep    1s
    Check How Many Scells Are Not Scheduled    ue_id=31    last_cc_id=3   exp_scells=1

#Verify Tput For 4CC And ReducedCCsDL 2
#    [Arguments]    ${ue_id}    ${num_scells}
#    @{cell_list}    Create List   0  1  3
#    FOR    ${cc}    IN    @{cell_list}
#        ${cc_tput}=      Get Current Dl Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    unit=Mbps
#        Should Be True    ${cc_tput} > ${0}
#    END
#    Sleep    1s
#    Check How Many Scells Are Not Scheduled    ue_id=31    last_cc_id=3   exp_scells=1

Trigger UE Overheating with reducedCCsDL=1
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=1
    ...    pass_regexp=SCellIndex.* deactivated successfully.*SCellIndex.* deactivated successfully
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_1}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_1}
    Sleep    35s    Time For Traffic Stabilization

Trigger UE Overheating with reducedCCsDL=2
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=2
    ...    pass_regexp=SCellIndex.* activated successfully
    Verify Tcpdump Log       packet_filter=${RRC_UE_ASSISTANCE_MAX_CC_2}
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_MOD_UE_ASSISTANCE_MAX_CC_2}
    Sleep    35s    Time For Traffic Stabilization

Verify SCELL_DEACT_UE_OVH_REPORTS Counter Value
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counters_filepath}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55316C12001
    ...    value=${2}
    ...    local_moid=${local_moid}
    ...    filepath=${pm_counters_filepath}
