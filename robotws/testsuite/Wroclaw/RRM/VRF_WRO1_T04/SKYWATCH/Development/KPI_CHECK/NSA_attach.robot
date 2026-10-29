*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Variables    ta5g_global_var
Resource    resources/5G_SW_WRO_Keywords.robot
Resource    resources/Skywatch_keywords.robot
Resource    resources/NSA_release.robot
Resource    resources/KPI_related_keywords.robot
Resource    resources/BIP_logs.robot
#Resource    ../../../../Ulm/resources/Common/bip_trace.robot
#Resource    ../../../../Ulm/resources/Common/bip_trace_ap.robot
Library    resources/KPI_related_keywords.py
Library    resources/tput_scen.py
Library    resources/Python/webem_alarms.py
Library    resources/TA_mobility.py
Library    taf.collectors.dcap


Suite Setup    Run Keywords    Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/KPI_UE.lua

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Deregister 60 UEs
...    AND    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2

*** Test Cases ***
NR_5101b_CHECK
    Wait For Next Raw Pm Interval

    Attach For NSA Ues
    ...    first_ue=${41}
    ...    last_ue=${60}
    NSA Start 1 Mbps Uplink Traffic For UEs 41-60
    NSA Start Downlink Traffic 10 Mbps For UEs 41-60

    Display Actual Traffic NSA For UEs 41-60
    Display Actual Uplink Traffic NSA For UEs 41-60

    NSA RLF
    ...    first_ue=${45}
    ...    last_ue=${48}
    ...    failure=T310_expiry
    ...    at=gnb

    NSA RLF
    ...    first_ue=${49}
    ...    last_ue=${55}
    ...    failure=random_access_problem
    ...    at=gnb


    Dc Release For NSA
    ...    first_ue=${41}
    ...    last_ue=${44}
    ...    cause=RN_CauseRadioNetwork_unspecified



    Execute Egate Command
#    ...    cmd=enb_endc_param id=1 sgnb_release_confirm_delay=10000
    ...    cmd=enb_endc_param id=1 menb_failure_scenario=dont_send_sgnb_release_confirm

    NSA RLF
    ...    first_ue=${56}
    ...    last_ue=${60}
    ...    failure=synch_reconfiguration_failure_scg
    ...    at=gnb

    Sleep    10s
    Execute Egate Command
    ...    cmd=enb_endc_param id=1 reset


    ${list_of_counters}=    Create List    M55112C00002    M55112C00003    M55112C00004    M55114C00008
                            ...    M55116C00009    M55116C00012    M55112C00007    M55112C00005    M55112C00015
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File

    FOR    ${counter}     IN      @{list_of_counters}
        ${counter_value}=    Get Latest Pm Counter Value
    ...    counter_id=${counter}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}
        Log to console    ${counter} = ${counter_value}
    END


*** Keywords ***
Paging for 5UEs from AMF and expect one paging
    BuiltIn.Log    begin to trigger the paging for NEs from AMF    console=${True}
    ${cmd}    Catenate    amf_paging_param id\=1 default_drx=128 max_paging_retries\=1
    Execute Egate Command   cmd=${cmd}
    ${cmd}    Catenate    amf_paging_start id\=1 ue\=all
    Execute Egate Command   cmd=${cmd}


