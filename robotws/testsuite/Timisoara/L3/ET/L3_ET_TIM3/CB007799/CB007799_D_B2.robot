*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36
...           CONFIGURED    CRT    RAN_5G_FDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Julia Szymczak
...              :contact: julia.szymczak@nokia.com

Resource    ../resources/5G_SW_WRO_Keywords.robot
Library     ta5g_pm_counters

Suite Setup    Run Keywords    Start Default Logging
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7799_nsa.lua
...            AND             Perform Parameter Commissioning    parameter=act3gppBL22R2    value=true
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=act3gppBL22R2    value=false
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB007799-C_B2_X2AP_SgNB_Release_Request_For_Normal_Release_Success
    [Documentation]    Testcase verifies gNB behavior when X2AP: SGNB RELEASE REQUEST is received
    ...                from MeNB with cause value normal release.

    Attach Ue to eNB And gNB    ue_id=11
    Detach Ue    ue_id=11
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${X2AP_SGNB_RELEASE_ACKNOWLEDGE}
    Verify Tcpdump Log    packet_filter=${X2AP_UE_CONTEXT_RELEASE}
    Verify Loopback Messages    packet_filter=${S1_UE_CONTEXT_RELEASE_COMMAND}
    Verify Loopback Messages    packet_filter=${S1AP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Wait For Next Full Pm Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55112C06501  +1  X2_SGNB_REL_REQ_RCVD_NORM_REL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}

*** Keywords ***

Attach Ue to eNB And gNB
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1   bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Sleep    5    reason=Lack of break between Attach And Detach triggers error indication

