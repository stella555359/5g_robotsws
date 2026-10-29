*** Settings ***
Documentation   This is a keyword file for CB008699, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${cell}                 NRCELL-1

${text_M55306C03001}    RA setup completions for contention based group A preambles
${text_M55306C05001}    RA setup completions for dedicated preambles
${text_M55147C00036}    Number of successful handover preparations at target cell using full configuration
${text_M55147C00037}    No of RRC Reconfiguration Complete at target when UE is configured with full configuration for HO
${text_M55352C00002}    DL PDCP PDUs discarded due to PDCP Reset per NRPMQAP Profile
${text_M55352C00003}    DL PDCP PDU volume discarded due to PDCP Reset per NRPMQAP profile
${text_M55319C11006}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 06
${text_M55319C11007}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 07
${text_M55319C15006}    UL PDCP SDUs received for SA Bearer - QoS Group 06
${text_M55319C15007}    UL PDCP SDUs received for SA Bearer - QoS Group 07

${text_M55138C02001}    Total number of partial admissions
${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55190C00001}    Number of selected measurement profiles for SA

*** Keywords ***

prepare counters and expected values t1_t5
    [Documentation]    [PRIVATE]    set expected values for CB008699_A_Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handover
    ...                             set expected values for CB008699_CNI_96896_Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C03001}             ${text_M55306C03001}     0    ${cell}   NRACH
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55147C00036}             ${text_M55147C00036}     1    ${cell}   NMOCU
    set test variable    @{M55147C00037}             ${text_M55147C00037}     1    ${cell}   NMOCU
    set test variable    @{M55352C00002}             ${text_M55352C00002}     0    ${cell}   PDCPQ
    set test variable    @{M55352C00003}             ${text_M55352C00003}     0    ${cell}   PDCPQ

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55147C00036=${M55147C00036}
    ...                                              M55147C00037=${M55147C00037}
    ...                                              M55352C00002=${M55352C00002}
    ...                                              M55352C00003=${M55352C00003}

    set test variable    @{M55319C11006}             ${text_M55319C11006}     PDCP1
    set test variable    @{M55319C15006}             ${text_M55319C15006}     PDCP1

    set test variable    @{UE}         1



prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected values for CB008699_B_Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C03001}             ${text_M55306C03001}     1    ${cell}   NRACH
    set test variable    @{M55306C05001}             ${text_M55306C05001}     0    ${cell}   NRACH
    set test variable    @{M55147C00036}             ${text_M55147C00036}     1    ${cell}   NMOCU
    set test variable    @{M55147C00037}             ${text_M55147C00037}     1    ${cell}   NMOCU
    set test variable    @{M55352C00002}             ${text_M55352C00002}     0    ${cell}   PDCPQ
    set test variable    @{M55352C00003}             ${text_M55352C00003}     0    ${cell}   PDCPQ

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55147C00036=${M55147C00036}
    ...                                              M55147C00037=${M55147C00037}
    ...                                              M55352C00002=${M55352C00002}
    ...                                              M55352C00003=${M55352C00003}

    set test variable    @{M55319C11006}             ${text_M55319C11006}     PDCP1
    set test variable    @{M55319C15006}             ${text_M55319C15006}     PDCP1

    set test variable    @{UE}         1


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected values for CB008699_B_Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    set test variable    @{UE}         1


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected values for CB008699_A_Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C03001}             ${text_M55306C03001}     0    ${cell}   NRACH
    set test variable    @{M55306C05001}             ${text_M55306C05001}     1    ${cell}   NRACH
    set test variable    @{M55147C00036}             ${text_M55147C00036}     1    ${cell}   NMOCU
    set test variable    @{M55147C00037}             ${text_M55147C00037}     1    ${cell}   NMOCU
    set test variable    @{M55352C00002}             ${text_M55352C00002}     0    ${cell}   PDCPQ
    set test variable    @{M55352C00003}             ${text_M55352C00003}     0    ${cell}   PDCPQ

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55147C00036=${M55147C00036}
    ...                                              M55147C00037=${M55147C00037}
    ...                                              M55352C00002=${M55352C00002}
    ...                                              M55352C00003=${M55352C00003}

    set test variable    @{M55319C11006}             ${text_M55319C11006}     PDCP1
    set test variable    @{M55319C11007}             ${text_M55319C11007}     PDCP1
    set test variable    @{M55319C15006}             ${text_M55319C15006}     PDCP1
    set test variable    @{M55319C15007}             ${text_M55319C15007}     PDCP1

    set test variable    @{UE}         1


prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected values for Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55306C03001}             ${text_M55306C03001}     0    ${cell}   NRACH
    set test variable    @{M55306C05001}             ${text_M55306C05001}     4    ${cell}   NRACH
    set test variable    @{M55147C00036}             ${text_M55147C00036}     2    ${cell}   NMOCU
    set test variable    @{M55147C00037}             ${text_M55147C00037}     2    ${cell}   NMOCU

    set test variable    &{dict_pm_counter}
    ...                                              M55306C05001=${M55306C05001}
    ...                                              M55306C03001=${M55306C03001}
    ...                                              M55147C00036=${M55147C00036}
    ...                                              M55147C00037=${M55147C00037}

    set test variable    @{UE}         1  2  3  4


prepare counters and expected values FR2
    [Documentation]    [PRIVATE]    set expected values for Partial_admission_control_for_Xn_handover_with_full_RRC_configuration
    ...       :Autor: Sylvia Schneider

    set test variable    @{M55138C02001}             ${text_M55138C02001}     1    ${cell}   RSACU
    set test variable    @{M55147C00036}             ${text_M55147C00036}     1    ${cell}   NMOCU
    set test variable    @{M55147C00037}             ${text_M55147C00037}     1    ${cell}   NMOCU
    set test variable    &{dict_pm_counter}
    ...                                              M55138C02001=${M55138C02001}
    ...                                              M55147C00036=${M55147C00036}
    ...                                              M55147C00037=${M55147C00037}

    set test variable    @{masa_counter}                   NRCELL-1   NRMASA-1    MASA
    set test variable    @{text_M55190C00001-1}            ${text_M55190C00001}     2
    set test variable    &{dict_masa_counter}              M55190C00001-1=${text_M55190C00001-1}

    set test variable    @{miaf_counter}                   NRCELL-1   NRMIAF-1    MIAF
    set test variable    @{text_M55187C00001-1}            ${text_M55187C00001}     2
    set test variable    &{dict_miaf_counter}              M55187C00001-1=${text_M55187C00001-1}
