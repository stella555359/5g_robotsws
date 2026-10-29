*** Settings ***

*** Variables ***
${DELTA_DEFAULT}=            delta_default.json
${DELTA_DRBMACDEFPROF}=      delta_drbMacDefProf.json
${DELTA_DRBRLCAMDEFPROF}=    delta_drbRlcAmDefProf.json
${DRBMACDEFPROF_BEFORE}=     ${F1AP_UE_CONTEXT_SETUP_RESPONSE} && nr-rrc.priority == 12 && nr-rrc.logicalChannelGroup == 1
${DRBMACDEFPROF_AFTER}=      ${F1AP_UE_CONTEXT_SETUP_RESPONSE} && nr-rrc.priority == 10 && nr-rrc.logicalChannelGroup == 2

${DRBRLCAMDEFPROF_BEFORE}=    ${F1AP_UE_CONTEXT_SETUP_RESPONSE} && nr-rrc.maxRetxThreshold == 6 && nr-rrc.t_PollRetransmit == 8
...                           && nr-rrc.pollPDU == 4 && nr-rrc.pollByte == 13 && nr-rrc.t_StatusProhibit == 3 && nr-rrc.t_Reassembly == 3

${DRBRLCAMDEFPROF_AFTER}=     ${F1AP_UE_CONTEXT_SETUP_RESPONSE} && nr-rrc.maxRetxThreshold == 7 && nr-rrc.t_PollRetransmit == 44
...                           && nr-rrc.pollPDU == 16 && nr-rrc.pollByte == 27 && nr-rrc.t_StatusProhibit == 20 && nr-rrc.t_Reassembly == 23
