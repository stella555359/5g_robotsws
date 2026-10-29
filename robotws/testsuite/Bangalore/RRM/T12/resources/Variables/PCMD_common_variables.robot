*** Settings ***
Documentation        This Keywords consist of possible PCMD filters used in pcap.


*** Variables ***
${NSETAPX_PROTOCOL}                                 nsetapx
${NSETAPX_SBA}                                      nsetapx.traceActivationType == 1
${NSETAPX_MBA}                                      nsetapx.traceActivationType == 0
${NSETAPX_START_RECORDING_SESSION}                  nsetapx.TraceMessage == 4
${NSETAPX_STOP_RECORDING_SESSION}                   nsetapx.TraceMessage == 5
${NSETAPX_CU}                                       nsetapx.nodeType == 0
${NSETAPX_DU}                                       nsetapx.nodeType == 2
${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}               ngap.InitialContextSetupRequest_element
${ICS_WITH_TRACE_ACTIVATION}                        ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.TraceActivation_element
${NSETAPX_START_RECORDING_SESSION_SBA_CU}           ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_CU}
${NSETAPX_STOP_RECORDING_SESSION_SBA_CU}            ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_CU}
${NSETAPX_START_RECORDING_SESSION_MBA_CU}           ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_CU}
${NSETAPX_STOP_RECORDING_SESSION_MBA_CU}            ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_CU}
${NSETAPX_START_RECORDING_SESSION_MBA_DU}           ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_DU}
${NSETAPX_STOP_RECORDING_SESSION_MBA_DU}            ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_DU}
${NSETAPX_REPORT}                           ${NSETAPX_PROTOCOL} && nsetapx.report_element
${CELLID_SOURCE}                            nsetapx.cellIdentity == 00:00:04:00:10
${CELLID_TARGET}                            nsetapx.cellIdentity == 00:00:04:00:20
${NSETAPX_CU_REPORT}                        nsetapx.recordingSessionReportList == 0
${NSETAPX_DU_REPORT}                        nsetapx.recordingSessionReportList == 2
${NSETAPX_CELLTRACE_REPORT}                 nsetapx.data == 0
${NSETAPX_PCMD_REPORT}                      nsetapx.data == 1
${NSETAPX_CU_CELLTRACE_REPORT}              ${NSETAPX_REPORT} && ${NSETAPX_MBA} && ${NSETAPX_CU_REPORT} && ${NSETAPX_CELLTRACE_REPORT}
${NSETAPX_CU_PCMD_REPORT}                   ${NSETAPX_REPORT} && ${NSETAPX_MBA} && ${NSETAPX_CU_REPORT} && ${NSETAPX_PCMD_REPORT}
${NSETAPX_DU_PCMD_REPORT}                   ${NSETAPX_REPORT} && ${NSETAPX_MBA} && ${NSETAPX_DU_REPORT} && ${NSETAPX_PCMD_REPORT}
${NSETAPX_SBA_CELLTRACE_REPORT}             ${NSETAPX_REPORT} && ${NSETAPX_SBA} && ${NSETAPX_CU_REPORT} && ${NSETAPX_CELLTRACE_REPORT}
${NSETAPX_START_RECORDING_SESSION_MBA_CUUP}           ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_CUUP}
${NSETAPX_STOP_RECORDING_SESSION_MBA_CUUP}            ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA} && ${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_CUUP}
${NSETAPX_CUUP}                                       nsetapx.nodeType == 1
${NSETAPX_CUUP_REPORT}                                nsetapx.recordingSessionReportList == 1
${NSETAPX_CUUP_PCMD_REPORT}                           ${NSETAPX_REPORT} && ${NSETAPX_MBA} && ${NSETAPX_CUUP_REPORT} && ${NSETAPX_PCMD_REPORT}