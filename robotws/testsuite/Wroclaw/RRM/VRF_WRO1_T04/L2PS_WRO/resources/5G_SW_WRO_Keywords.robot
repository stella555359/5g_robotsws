*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Michal Fluder
...              :contact: michal.fluder@nokia.com


Variables    ta5g_global_var
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Library      ta5g_tshark
Library      ta5g_commissioning
Library      ta5g_enb
Library      ta5g_file_system
Library      ta5g_cell_operations
Library      ta5g_iphy
Library      ta5g_testline_management
Library      ta5g_setups_and_teardowns
Library      ta5g_egate
Library      ta5g_ue_mobility
Library      ta5g_ue_measurements
Library      ta5g_pm_counters


*** Variables ***
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO
    ...    /resources/config/5G21A/delta_set_collecting_counters_to_five_minutes.json

*** Keywords ***

# Tshark keywords

Verify Ngap Messages
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Loopback Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_LOOPBACK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= ${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

# ANR Keywords

Verify Created NRADJNRCELL Object
    [Documentation]    Validate NRADJNRCELL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRADJNRCELL}    ${mcc}    ${mnc}    ${mncLength}    ${physCellId}    ${cellDepType}    ${nrarfcn}    ${ssbFrequency}
    ...            ${gNbId}    ${gNbIdLength}    ${lcrId}    ${fiveGsTac}=788
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJNRCELL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRADJNRCELL.physCellId}     ${physCellId}
    Should Be Equal    ${NRADJNRCELL.cellDepType}     ${cellDepType}
    Should Be Equal As Integers    ${NRADJNRCELL.nrarfcn}    ${nrarfcn}
    Should Be Equal As Integers    ${NRADJNRCELL.ssbFrequency}    ${ssbFrequency}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbId}    ${gNbId}
    Should Be Equal As Integers    ${NRADJNRCELL.gNbIdLength}    ${gNbIdLength}
    Should Be Equal As Integers    ${NRADJNRCELL.lcrId}    ${lcrId}
    Should Be Equal As Integers    ${NRADJNRCELL.fiveGsTac}    ${fiveGsTac}

Verify Created NRREL Object
    [Documentation]    Validate NRREL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRREL}    ${mcc}    ${mnc}    ${mncLength}    ${gNbId}    ${gNbIdLength}    ${lcrId}    ${removeNotAllowed}=${False}
    ...            ${cellIndividualSsbRsrpOffset}=0dB    ${cellIndividualSsbRsrqOffset}=0dB
    Should Be Equal    ${NRREL.cellIndividualSsbRsrpOffset}    ${cellIndividualSsbRsrpOffset}
    Should Be Equal    ${NRREL.cellIndividualSsbRsrqOffset}    ${cellIndividualSsbRsrqOffset}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRREL.gnbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRREL.gNbId}     ${gNbId}
    Should Be Equal As Integers    ${NRREL.gNbIdLength}     ${gNbIdLength}
    Should Be Equal As Integers    ${NRREL.lcrId}    ${lcrId}
    Should Be Equal    ${NRREL.removeNotAllowed}    ${removeNotAllowed}

# Counters

Set Counter Collecting Interval To Five Minutes
    Send Delta Commissioning    input_filepath=${delta_set_collecting_counters_to_five_minutes}
