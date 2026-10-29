*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Variables    ta5g_global_var
Resource    resources/5G_SW_WRO_Keywords.robot
Resource    resources/Skywatch_keywords.robot
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

Test Teardown    Run Keywords    Deregister 10 UEs
...    AND    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2

*** Test Cases ***
NR_5101b_CHECK
    Find Scfc and Send Delta Commissioning    scfc_filename=Paging.json
    Wait For Next Raw Pm Interval
    Attach For Ues
    ...    ues=${10}
    Pdu Session For Ues
    ...    ues=${10}
    ...    pass_regex=Established PDU session
    FOR    ${ue_id}     IN RANGE    1    11
        Wait Until Keyword Succeeds  2 min  5 sec  Verify Ue State
                                                    ...  ue_id=${ue_id}
                                                    ...  expected_state=idle
    END
    Paging for 5UEs from AMF and expect one paging


    FOR    ${ue_id}     IN RANGE    1    11
        Wait Until Keyword Succeeds  2 min  5 sec  Verify Ue State
                                                    ...  ue_id=${ue_id}
                                                    ...  expected_state=active
    END
    ${list_of_counters}=    Create List    M55331C00001    M55331C00002
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