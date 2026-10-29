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
    Find Scfc and Send Delta Commissioning    scfc_filename=viaRRCSetup.json
    ${list_of_all_ues}=    Create Ues List
    ...  ue_start=${1}
    ...  ue_stop=${40}
    Wait For Next Raw Pm Interval
    Attach For Ues
    ...    ues=${40}
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupRequest_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=nr-rrc.rrcSetupComplete_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=ngap.InitialUEMessage_element  number_of_messages=40
    Pdu Session For Ues
    ...    ues=${40}
    ...    pass_regex=Established PDU session
    Verify Tcpdump Log  packet_filter=ngap.InitialContextSetupRequest_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=ngap.InitialContextSetupResponse_element  number_of_messages=40
    Start 1 Mbps Uplink Traffic For UEs 1-40
    Start Downlink Traffic 10 Mbps For UEs 1-40
    Verify Tcpdump Log  packet_filter=ngap.InitialContextSetupRequest_element  number_of_messages=40
    Verify Tcpdump Log  packet_filter=ngap.InitialContextSetupResponse_element  number_of_messages=40
    Sleep    5s
    Display Actual Traffic For UEs 1-40
    ${list_of_reest_ues}=    Send RrcReestablish To Random 4 Ues among all 40 Ues
    Sleep    5s
    FOR    ${item}     IN      @{list_of_reest_ues}
        Start Downlink Traffic 10 Mbps For UEs ${item}-${item}
        Start 1 Mbps Uplink Traffic For UEs ${item}-${item}
    END
    Sleep    5s
    Display Actual Traffic For UEs 1-40


    Modify Rrc Setup Cause And Drop One Ue For Every Cause

    Attach For Ues
    ...    ues=${10}
    Pdu Session For Ues
    ...    ues=${10}
    ...    pass_regex=Established PDU session
    Start 1 Mbps Uplink Traffic For UEs 1-10
#   Start Downlink Traffic 10 Mbps For UEs 1-10
    Display Actual Traffic For UEs 1-40



    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55124C01031
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    filepath=${PM_COUNTERS}
#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55124C01031
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
#    ...    filepath=${PM_COUNTERS}
#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55124C01001
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    filepath=${PM_COUNTERS}
#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55124C01001
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
#    ...    filepath=${PM_COUNTERS}
#    ${initial_cell1}=    Get Latest Pm Counter Value
#    ...    counter_id=M55125C00001
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    filepath=${PM_COUNTERS}
#    ${initial_cell2}=    Get Latest Pm Counter Value
#    ...    counter_id=M55125C00001
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
#    ...    filepath=${PM_COUNTERS}
#    ${sum_of_initials}    Evaluate    ${initial_cell1} + ${initial_cell2}
#    Should Be Equal As Numbers  ${44}  ${sum_of_initials}

    ${M55309C02001}=    Get Sum Of M55309C02001 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55309C02001 = ${M55309C02001}
    ${M55308C02002}=    Get Sum Of M55308C02002 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55308C02002 = ${M55308C02002}
    ${M55308C00009}=    Get Sum Of M55308C00009 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55308C00009 = ${M55308C00009}
    ${M55308C00006}=    Get Sum Of M55308C00006 Counter Values From 4 Cells From ${PM_COUNTERS}
    Log to console  Sum of M55308C00006 = ${M55308C00006}
    ${NR_5101b}=    Calculate NR 5101b
    ...    M55309C02001=${M55309C02001}
    ...    M55308C02002=${M55308C02002}
    ...    M55308C00009=${M55308C00009}
    ...    M55308C00006=${M55308C00006}
    Log to console  Calculated NR_5101b = ${NR_5101b} [Mbit/s]

#"8 * Sum([M55309C02001])/(Sum([M55308C02002]) * Sum([M55308C00009]) / Sum([M55308C00006]))"





#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55125C00001
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#    ...    filepath=${PM_COUNTERS}
#    Verify If Latest Pm Counter Has Exact Value
#    ...    counter_id=M55125C00001
#    ...    value=20
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
#    ...    filepath=${PM_COUNTERS}
#    Start TTI trace
#    Sleep    1s
#    Stop TTI trace
#    Convert TTI trace from pcap to excelCsv

#    Deregister 40 UEs
