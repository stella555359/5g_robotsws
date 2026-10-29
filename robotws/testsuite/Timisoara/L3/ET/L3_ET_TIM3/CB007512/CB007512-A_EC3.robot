*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CONFIGURED    RAN_5G_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Julia Szymczak
...              :contact: julia.szymczak@nokia.com

Resource     CB007512_Keywords.robot

Suite Setup     Run Keywords    Start Default Logging
    ...         AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_7512_EC3.json
    ...         AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7512.lua

Suite Teardown    Run Keywords    Find Scfc and Send Delta Commissioning    scfc_filename=delta_revert_7512_EC3.json
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB007512_A_EC3_1_Unsuccessful_addition_of_SN_terminated_split_bearers_without_PDCP_anchor_change_by_SgNB_Addition_Preparation_Feature_On

    [Documentation]   This user scenario describes unsuccessful addition of SN terminated split bearer(s)
    ...               which do not need PDCP anchor change from MeNB to SgNB by MeNB initiated SgNB modification
    ...               preparation procedure when CB007512 is disabled.

    ${X2-C_UE_SIGNALING_TIMER} =   Get Admin Object Parameter Value    parameter_name=timerX2UeProcGuard
    Turn On 7512 Error Case Functionality
    Attach Ue And Perform SgNBAdditionRequest   ue_id=11
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log    packet_filter=${X2AP_SN_STATUS_TRANSFER}
    Wait For Timer Expiration And Verify Messages    timer=${X2-C_UE_SIGNALING_TIMER}
	Start And Check Data Traffic    ues=11   bearer_id=4   direction=both    throughput=5mbps    traffic_period=10

*** Keywords ***
Turn On 7512 Error Case Functionality
    Execute Egate Command    cmd=enb_endc_param id=1 direct_bearer_sn_addition_error=on

Wait For Timer Expiration And Verify Messages
    [Arguments]    ${timer}
    Sleep    ${timer}ms
    Verify Tcpdump Log    packet_filter=${X2AP_SN_STATUS_TRANSFER}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_RELEASE_REQUIRED}
