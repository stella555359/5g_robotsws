*** Settings ***
Documentation   This is a file for 5GC008731, parameter definitions
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55138C02001}    Total number of partial admissions

${text_M55320C19001}    Total number of RoHC compressed headers
${text_M55320C19002}    Total volume of RoHC compressed headers
${text_M55320C19003}    Total number of RoHC decompressed headers
${text_M55320C19004}    Total volume of RoHC decompressed headers

${text_M55125C09013}    The number of QoS Flows during Setup Att for incoming HO in the target cell
${text_M55125C09014}    The number of QoS Flows during Setup Succ for incoming HO in the target cell
${text_M55125C09516}    In-session connected time for QoS Flows
${text_M55125C09524}    The number of 5QI-1 QoS Flows during Setup Att for incoming HO in the target cell
${text_M55125C09525}    The number of 5QI-1 QoS Flows during Setup Succ for incoming HO in the target cell
${text_M55125C09526}    In-session connected time for 5QI1 QoS Flows released due to normal cause
${text_M55125C09527}    In-session connected time for 5QI1 QoS Flows released due to abnormal cause
${text_M55125C11501}    SA UE Context Releases due to preemption
${text_M55125C12503}    Number of successful QoS Flow Setups for High Priority Access

${text_M55139C04505}    Number of admission control attempts in BWP1 for GBR
${text_M55139C04506}    Number of admission control successes in BWP1 for GBR

${text_M55163C00513}    The number of PMQAP QoS Flows during Setup Att for incoming HO in the target cell
${text_M55163C00514}    The number of PMQAP QoS Flows during Setup Succ for incoming HO in the target cell
${text_M55163C00521}    In-session connected time for PMQAP Profile based QoS Flows

${text_M55124C09001}    Number of RRC CONNECTION Attempts that were completed successfully for High Priority Access

${text_M55319C11001}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 01
${text_M55319C11002}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 02
${text_M55319C11005}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 05
${text_M55319C11006}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 06
${text_M55319C11010}    DL PDCP SDUs transmitted for SA Bearer- QoS Group 10
${text_M55319C15001}    UL PDCP SDUs received for SA Bearer - QoS Group 01
${text_M55319C15002}    UL PDCP SDUs received for SA Bearer - QoS Group 02
${text_M55319C15005}    UL PDCP SDUs received for SA Bearer - QoS Group 05
${text_M55319C15006}    UL PDCP SDUs received for SA Bearer - QoS Group 06
${text_M55319C15010}    UL PDCP SDUs received for SA Bearer - QoS Group 10

${text_M55184C00003}    A4 trigg Execution attempts for inter-freq Intra-gNB Intra-DU HO for SA
${text_M55184C00004}    A4 trigg Successful execution attempts for inter-freq Intra-gNB Intra-DU HO for SA

${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55188C00001}    Number of UE configuration attempts for inter-frequency measurement profiles
${text_M55189C00001}    Number of UE configuration attempts for inter-RAT measurement profiles
${text_M55190C00001}    Number of selected measurement profiles for SA

${text_M55142C00501}    Resource allocations attempts for incoming IS Handover from LTE
${text_M55142C00502}    Resource allocations successes for incoming IS Handover from LTE
${text_M55142C00503}    Resource allocations failures for incoming IS Handover from LTE due to AC
${text_M55142C00505}    Resource allocations failures for incoming IS Handover from LTE due to CP Overload
${text_M55142C00506}    Failed execution attempts for incoming IS Handover from LTE due to Timer Expiry
${text_M55142C00507}    Resource allocations failures for incoming IS Handover from LTE due to Other reasons
${text_M55142C00508}    IS Handover from LTE executions successes
${text_M55142C00509}    Resource allocations attempts for incoming IS Handover from LTE for VoNR call
${text_M55142C00510}    Resource allocations successes for incoming IS Handover from LTE for VoNR call
${text_M55142C00511}    Resource allocations failures for IS Handover from LTE due to AC for VoNR call
${text_M55142C00513}    Resource allocations failures for incoming IS Handover from LTE due to CP Overload for VoNR call
${text_M55142C00514}    Failed execution attempts for incoming IS Handover from LTE due to Timer Expiry for VoNR
${text_M55142C00515}    Resource allocations failures for incoming IS Handover from LTE due to Other reasons for VoNR
${text_M55142C00516}    IS Handover from LTE executions successes for VoNR

