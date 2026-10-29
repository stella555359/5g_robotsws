*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_cell_operations
Library      ta5g_enb
Library      ta5g_pm_counters
Library      ta5g_delta

*** Variables ***
${SIB_2_RELAXED_MEASUREMENT}    ${SIB2} && nr-rrc.relaxedMeasurement_r16_element
${SIB_2_RELAXED_MEASUREMENT_CELL_ID_1}    ${SIB_2_RELAXED_MEASUREMENT} && iphy.cell_id == 1
${SIB_2_WITHOUT_MEAS_COND_RELAX}    ${SIB_2_RELAXED_MEASUREMENT_CELL_ID_1} && not (nr-rrc.combineRelaxedMeasCondition_r16) &&
...                                 not (nr-rrc.highPriorityMeasRelax_r16)
${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX}    ${SIB_2_RELAXED_MEASUREMENT_CELL_ID_1} && (nr-rrc.combineRelaxedMeasCondition_r16) &&
...                                      not (nr-rrc.highPriorityMeasRelax_r16)
${SIB_2_WITH_MEAS_COND_RELAX}    ${SIB_2_RELAXED_MEASUREMENT_CELL_ID_1} && (nr-rrc.combineRelaxedMeasCondition_r16) &&
...                              (nr-rrc.highPriorityMeasRelax_r16)

*** Keywords ***
Verify Uu Messages For Subcase
    [Arguments]    ${packet_filter}    ${subcase_name}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16
    ...            ${relation_symbol}= ==    ${alias}=${DEFAULT_UU_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    ...    subcase=${subcase_name}
