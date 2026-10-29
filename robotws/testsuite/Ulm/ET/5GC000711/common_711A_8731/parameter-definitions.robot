*** Settings ***
Documentation   This is a file for 5GC000711-A, parameter definitions
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

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
${text_M55124C00502}    Number of fallbacks to RRC Setup procedure during RRC Re-establishment procedure
${text_M55124C00505}    Number of RRC Re-establishment Request caused by other failure
${text_M55124C00515}    Number of fallback RRCSetup successful as response to RRCReestablishmentReq
${text_M55124C01031}    Number of RRC CONNECTION Attempts that were completed successfully
${text_M55124C02501}    Number of RRC Releases with LTE frequency redirection for voice fallback
${text_M55125C06502}    Number of LOCATION REPORT messages sent
${text_M55125C08001}    Number of HANDOVER REQUEST messages with Location reporting request received
${text_M55157C00034}    Number of times the SA mobility profile 2 is selected
${text_M55138C01501}    The number of radio admission requests for 1 Scell in SA mode
${text_M55138C01502}    The number of successful radio admissions for 1 Scell additions in SA mode
${text_M55306C05001}    RA setup completions for dedicated preambles
${text_M55306C03001}    RA setup completions for contention based group A preambles
