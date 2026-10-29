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
Library    resources/KPI_related_keywords.py
Library    resources/tput_scen.py
Library    resources/Python/webem_alarms.py
#Resource     resources/configuration_id.robot

Suite Setup    Run Keywords    Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/KPI_UE.lua

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Deregister 1 UEs
...    AND    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#...    AND    Send Configuration ID To Scout

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2

*** Test Cases ***
NR_5101b_CHECK
    Find Scfc and Send Delta Commissioning    scfc_filename=UEInactiveState.json
    Wait For Next Raw Pm Interval
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    Attach For Ues
    ...    ues=${1}
    Pdu Session For Ues
    ...    ues=${1}
    ...    pass_regex=Established PDU session
    Start 1 Mbps Uplink Traffic For UEs 1-1
    Start Downlink Traffic 10 Mbps For UEs 1-1
    Sleep    5s
    Display Actual Traffic For UEs 1-1

    Stop Data And Wait For Inactive State
    ...    ue_id=${1}
    ...    pdu_id=${1}

    Find Scfc and Send Delta Commissioning    scfc_filename=RemoveRanAC.json
    Send Rrcresume
    ...    ue_id=${1}
    ...    pdu_id=${1}

    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55124C00014
    ...    value=1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS}


*** Keywords ***
Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]   ${amf_id}=1   ${plmn_id}=311:489   ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=1 ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command   cmd=${command}
