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

Test Teardown    Run Keywords    Deregister 40 UEs
...    AND    Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#...    AND    Send Configuration ID To Scout

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2

*** Test Cases ***
NR_5101b_CHECK
    Find Scfc and Send Delta Commissioning    scfc_filename=SameGnb.json
    Wait For Next Raw Pm Interval
    Attach For Ues
    ...    ues=${40}
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupRequest_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupComplete_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=ngap.InitialUEMessage_element  number_of_messages=40
    Pdu Session For Ues
    ...    ues=${40}
    ...    pass_regex=Established PDU session
    Start 1 Mbps Uplink Traffic For UEs 1-40
    Start Downlink Traffic 10 Mbps For UEs 1-40

    Sleep    5s
    Display Actual Traffic For UEs 1-40

    ${list_of_all_ues}=    Create Ues List
    ...  ue_start=${1}
    ...  ue_stop=${40}

    Send Rrcreestablish To Random Ues
    ...  ue_list=${list_of_all_ues}
    Sleep    20s
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcReestablishmentRequest_element && nr-rrc.c_RNTI
    ...  number_of_messages=1
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcReestablishmentComplete_element
    ...  number_of_messages=1
    Sleep    5s

    Display Actual Traffic For UEs 1-40
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    ${M55124C00510}=    Get Sum Of M55124C00510 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00510 = ${M55124C00510}
    ${M55124C00511}=    Get Sum Of M55124C00511 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00511 = ${M55124C00511}
    ${M55124C00512}=    Get Sum Of M55124C00512 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00512 = ${M55124C00512}
    ${M55124C00515}=    Get Sum Of M55124C00515 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00515 = ${M55124C00515}
    ${M55124C00503}=    Get Sum Of M55124C00503 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00503 = ${M55124C00503}
    ${M55124C00504}=    Get Sum Of M55124C00504 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00504 = ${M55124C00504}
    ${M55124C00505}=    Get Sum Of M55124C00505 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55124C00505 = ${M55124C00505}
    ${NR_5400b}=    Calculate NR 5400b
    ...    M55124C00510=${M55124C00510}
    ...    M55124C00511=${M55124C00511}
    ...    M55124C00512=${M55124C00512}
    ...    M55124C00515=${M55124C00515}
    ...    M55124C00503=${M55124C00503}
    ...    M55124C00504=${M55124C00504}
    ...    M55124C00505=${M55124C00505}

    Log to console  Calculated NR_5400b = ${NR_5400b} [%]

#    Start TTI trace
#    Sleep    1s
#    Stop TTI trace
#    Convert TTI trace from pcap to excelCsv

#    Deregister 40 UEs
