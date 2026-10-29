*** Settings ***
Documentation
...    author: Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com

Library        ute_ue
Library        resources/test_specific_keywords.py

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       resources/test_specific_keywords.robot

Variables      resources/test_constants.py


*** Keywords ***
5G20B_0501_RRM_001
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N25}
    Set Cell To Barred    41
    Set Graceful Cell Shutdown Parameters
    Deattenuate Attach Cell   ${tl.attenuators}
    Attach UE With Data Transfer   ${THROUGHPUT_DURATION_501}   ${UE_ALIAS}
    Set Cell To NotBarred    41
    Check Cell And Signal Strength For Ue    ${UE_ALIAS}
    Shutdown Cell
    Check Cell And Signal Strength For Ue    ${UE_ALIAS}
    Finish Data Transfer Call   ${UE_ALIAS}
    [Teardown]    Run Keywords
    ...    Unlock Cell After Shutdown    AND
    ...    Set Cell To NotBarred    41

23R2_8745_OAM_002
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N25}
    Switch On Power Saving
    ${nrpgrp}=   Set Cell Switch Off Params And Get Relevant Capacity Cells    cell switch off
    ${capacity_cells}=   Determine Capacity Cells    ${nrpgrp}
    Log To Console   Sleeping for ${SWITCH_OFF_TIMEOUT} to ensure capacity cells are switched off
    Wait Until Capacity Cells Switch Off   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Deattenuate Attach Cell   ${tl.attenuators}
    ${reference_counters}=   Get Cell Switch Off Counters
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}
    Wait Until Capacity Cells Switch On   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Finish Data Transfer Call   ${UE_ALIAS}
    Analyze Cell Switch Off Counters   ${reference_counters}   ${capacity_cells}   ${0}
    [Teardown]    Suspend LBPS Current Period After Test   ${nrpgrp}

23R2_8745_OAM_003
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N25}
    Deattenuate Attach Cell   ${tl.attenuators}
    Switch On Power Saving
    ${reference_counters}=   Get Cell Switch Off Counters
    ${nrpgrp}=   Set Cell Switch Off Params And Get Relevant Capacity Cells    cell switch off
    ${capacity_cells}=   Determine Capacity Cells    ${nrpgrp}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}
    Finish Data Transfer Call   ${UE_ALIAS}
    Wait Until Capacity Cells Switch Off   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Analyze Cell Switch Off Counters    ${reference_counters}   ${capacity_cells}   ${1}
    [Teardown]    Suspend LBPS Current Period After Test   ${nrpgrp}

5G23R2_8133_RRM_002
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Require UE   ${UE_ALIAS_2}   capabilities=${UE_ALIAS_2}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Enable Band Config    ${UE_ALIAS_2}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N41_302}
    Switch On Power Saving
    ${nrpgrp}=   Set Cell Switch Off Params And Get Relevant Capacity Cells   TX switch off
    ${capacity_cells}=   Determine Capacity Cells    ${nrpgrp}
    Wait Until Capacity Cells TX Switch Off   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Deattenuate Attach Cell   ${tl.attenuators}
    ${reference_counters}=   Get TX Switch Off Counters
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS_2}
    Wait Until Capacity Cells TX Switch On   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Finish Data Transfer Call   ${UE_ALIAS}
    Finish Data Transfer Call   ${UE_ALIAS_2}
    Analyze TX Switch Off Counters   ${reference_counters}   ${capacity_cells}   ${0}
    [Teardown]    Suspend LBPS Current Period After Test   ${nrpgrp}

5G23R2_8133_RRM_003
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Require UE   ${UE_ALIAS_2}   capabilities=${UE_ALIAS_2}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Enable Band Config    ${UE_ALIAS_2}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N41_302}
    ${reference_counters}=   Get TX Switch Off Counters
    Switch On Power Saving
    ${nrpgrp}=   Set Cell Switch Off Params And Get Relevant Capacity Cells   TX switch off
    ${capacity_cells}=   Determine Capacity Cells    ${nrpgrp}
    Deattenuate Attach Cell   ${tl.attenuators}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS_2}
    Finish Data Transfer Call   ${UE_ALIAS}
    Finish Data Transfer Call   ${UE_ALIAS_2}
    Wait Until Capacity Cells TX Switch Off   ${capacity_cells}  ${SWITCH_OFF_TIMEOUT}
    Analyze TX Switch Off Counters    ${reference_counters}   ${capacity_cells}   ${1}
    [Teardown]    Suspend LBPS Current Period After Test   ${nrpgrp}

23R1_8662_RRM_001
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N25}
    Set 8662 Adaptive ReTx Parameters
    ${reference_counters}=   Get Reserved MCS 256QAM DL Counters
    Deattenuate Attach Cell   ${tl.attenuators}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}
    Sweep Attenuation Several Times   ${1}    attenuators=${tl.attenuators}
    Stop TTI Trace   ${OUTPUT_DIR}
    Finish Data Transfer Call   ${UE_ALIAS}
    ${retx_mcs}=   Analyze Rescheduling MCS In TTI Trace   ${OUTPUT_DIR}/TTI/tcpdump_tti/tcpdump_tti.pcap   ${OUTPUT_DIR}/tti_decoded
    Analyze Reserved MCS DL Counters   ${reference_counters}   ${retx_mcs}

23R1_8662_RRM_002
    Require UE   ${UE_ALIAS}   capabilities=${UE_ALIAS}
    Enable Band Config    ${UE_ALIAS}    DEFAULT
    Set Attach Cell DN   ${ATTACH_CELL_N25}
    Set 8662 Adaptive ReTx Parameters   UL
    ${reference_counters}=   Get Reserved MCS 256QAM UL Counters
    Deattenuate Attach Cell   ${tl.attenuators}
    Attach UE With Data Transfer   ${SWITCH_OFF_TIMEOUT}   ${UE_ALIAS}   UL
    Start TTI Trace   ${tl.test_pc}   ${tl.gnbs[0]}
    Sweep Attenuation Several Times   ${2}    ${3}    ${1}    attenuators=${tl.attenuators}
    Stop TTI Trace   ${OUTPUT_DIR}
    Finish Data Transfer Call   ${UE_ALIAS}   UL
    ${retx_mcs}=   Analyze Rescheduling MCS In TTI Trace   ${OUTPUT_DIR}/TTI/tcpdump_tti/tcpdump_tti.pcap   ${OUTPUT_DIR}/tti_decoded   UL
    Analyze Reserved MCS UL Counters   ${reference_counters}   ${retx_mcs}
