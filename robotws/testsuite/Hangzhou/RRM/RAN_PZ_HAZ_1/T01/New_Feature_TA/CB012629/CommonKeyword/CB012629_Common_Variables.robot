*** Settings ***

Documentation     Varibles related to CB012629
*** Variables ***
${nsetapx_plugin_addr}
...  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins
${mcshark_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${wts_folder}  /opt/wts
${remote_dir}            /data/ntracer5g_5
&{dcap_info_loacl_emil}    host=127.0.0.1    port=9443    username=${None}    password=${None}
&{dcap_server_mba}           host=10.56.197.7    username=dcapuser     password=dcapuser
...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_10.56.197.7
&{dcap_server_sba}           host=10.56.218.137    username=dcapuser     password=dcapuser
...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_10.56.218.137
#&{dcap_server_tls}           host=10.69.9.244    username=dcapuser     password=dcapuser123!
#...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012629/config/id_rsa_DCAP_244.pub
&{dcap_server_tls}           host=10.56.197.4    username=dcapuser     password=dcapuser
...    key_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008411/config/id_rsa_10.56.197.4
${case_path}   /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012629
${remote_dir_tls}   /data/ntracer5g
${emil_host}            10.97.83.40
${emil_user}            Pz1
${emil_password}        Nokia@2w3e4r5t6y7u
${sudo_password}       dcapuser
${sba_host_tls}        10.56.197.4
${mba_host}            10.56.197.7
${sba_host}            10.56.218.137
${real_amf_host}       10.110.194.134

${DU_IP}               10.70.25.162
@{ducp_duup_tracerecords}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == rrcSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == bearerRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord

@{emil_ducp_duup_tracerecords}    UeCtxSetupTraceRecord
...   TimingAdvanceTraceRecord
...   DuRrcSetupTraceRecord
...   DuBearerTraceRecord
...   DuUlSchedulingTraceRecord
...   DuUlSchedulingTraceRecord
...   DuDlRadioBearerRlcMeasTraceRecord
...   DuUlRadioBearerRlcMeasTraceRecord
...   BeamUsageTraceRecord
...   ChannelStateInfoReportTraceRecord
...   BeamReportTraceRecord
...   DuUlRadioBearerRlcThroughputTraceRecord

@{ducp_duup_tracerecords_after_resume}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == rrcSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbHighRlcMeasRecord

@{cucp_tracerecords_after_resume}   nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord


@{ducp_duup_tracerecords_after_reestablish}   nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord

@{cucp_tracerecords_after_reestablish}   nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord


@{duup_tracerecords}    nsetapx.DuVendorExtensionRecordDataType == ulRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbHighRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord


@{emil_duup_tracerecords}   DuDlRadioBearerRlcMeasTraceRecord
...   DuUlRadioBearerRlcMeasTraceRecord
...   DuUlRadioBearerRlcThroughputTraceRecord
...   DuUlSchedulingTraceRecord
...   DuDlSchedulingTraceRecord
...   PowerHeadroomTraceRecord
...   BeamUsageTraceRecord
...   ChannelStateInfoReportTraceRecord
...   BeamReportTraceRecord
...   DuUlRadioBearerRlcThroughputTraceRecord
...   DuDlRadioBearerRlcMeasTraceRecord
...   DuUlRadioBearerRlcMeasTraceRecord

@{cuup_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerCtxSetupRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord

@{emil_cuup_tracerecords}   CuUpBearerContextSetupTraceRecord
...   CuUpBearerTraceRecord
...   CuUpPduSessionResourceInfoTraceRecord
...   CuUpUlRadioBearerPdcpMeasTraceRecord
...   CuUpDlRadioBearerPdcpMeasTraceRecord
...   CuUpDlRadioBearerPdcpThroughputTraceRecord

@{cuup_throughput_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord

@{emil_cuup_throughput_tracerecords}   CuUpDlRadioBearerPdcpThroughputTraceRecord
...   CuUpUlRadioBearerPdcpMeasTraceRecord
...   CuUpDlRadioBearerPdcpMeasTraceRecord

@{cucp_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == bearerRecord

@{emil_cucp_tracerecords}   PduSessionResourceInfoTraceRecord
...       UeDuConnectivityTraceRecord
...       CuRrcSetupTraceRecord
...       UeInfoTraceRecord
...       CuUeSetupTraceRecord
...       CuBearerTraceRecord

@{cucp_tracerecords_after_inactivate}
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
${cucp_mea_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
@{emil_cucp_mea_tracerecords}    UeMeasTraceRecord
...   NsetapX_IsAlive
@{emil_session_alive_tracerecords}    NsetapX_IsAlive
...   NsetapX_IsAlive
...   NsetapX_IsAlive
${stop_sesstion}   nsetapx.TraceMessage == stopRecordingSession
${start_sesstion}   nsetapx.TraceMessage == startRecordingSession
${alive}   nsetapx.TraceMessage == alive
${traceMessage_configure}     nsetapx.TraceMessage == Configure
${traceMessage_startSession}     nsetapx.TraceMessage == StartSession
${f1ap_trace_activate_minimum}   f1ap.traceDepth == minimum
${f1ap_trace_activate_medium}   f1ap.traceDepth == medium
${f1ap_trace_activate_maximum}   f1ap.traceDepth == maximum
${f1ap_trace_activate_min_without_vse}   f1ap.traceDepth == minimumWithoutVendorSpecificExtension
${f1ap_trace_activate_med_without_vse}   f1ap.traceDepth == mediumWithoutVendorSpecificExtension
${f1ap_trace_activate_max_without_vse}   f1ap.traceDepth == maximumWithoutVendorSpecificExtension
${e1ap_trace_activate_minimum}   e1ap.traceDepth == minimum
${e1ap_trace_activate_medium}   e1ap.traceDepth == medium
${e1ap_trace_activate_maximum}   e1ap.traceDepth == maximum
${e1ap_trace_activate_min_without_vse}   e1ap.traceDepth == minimumWithoutVendorSpecificExtension
${e1ap_trace_activate_med_without_vse}   e1ap.traceDepth == mediumWithoutVendorSpecificExtension
${e1ap_trace_activate_max_without_vse}   e1ap.traceDepth == maximumWithoutVendorSpecificExtension
${ngap_trace_activate_minimum}   ngap.traceDepth == minimum
${ngap_trace_activate_medium}   ngap.traceDepth == medium
${ngap_trace_activate_maximum}   ngap.traceDepth == maximum
${ngap_trace_activate_min_without_vse}   ngap.traceDepth == minimumWithoutVendorSpecificExtension
${ngap_trace_activate_med_without_vse}   ngap.traceDepth == mediumWithoutVendorSpecificExtension
${ngap_trace_activate_max_without_vse}   ngap.traceDepth == maximumWithoutVendorSpecificExtension
&{NRSTRACECUUP_param_dict_1}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACECUUP_param_dict_2}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACECUUP_param_dict_3}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=true
&{NRSTRACECUUP_param_dict_4}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACECUUP_param_dict_5}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACECUUP_param_dict_6}
...   maxBufferingTime=150   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACECUUP_param_dict_7}
...   maxBufferingTime=1500   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=true
...   certTypeForTlsAuth=ECDSA
&{NRSTRACECUUP_param_dict_8}
...   maxBufferingTime=1000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACECUUP_param_dict_9}
...   maxBufferingTime=1000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACECUUP_param_dict_10}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=true
&{NRSTRACECUUP_param_dict_11}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACECUUP_param_dict_12}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACECUUP_param_dict_13}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=10  tlsEnabled=false
&{NRSTRACECUUP_param_dict_14}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACECUUP_param_dict_15}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
...   actPCMDReporting=false
&{NRSTRACECUUP_param_dict_16}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=255  tlsEnabled=true
&{NRSTRACECUUP_param_dict_17}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=false
&{NRSTRACEDU_param_dict_1}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACEDU_param_dict_2}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACEDU_param_dict_3}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=true
&{NRSTRACEDU_param_dict_4}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACEDU_param_dict_5}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACEDU_param_dict_6}
...   maxBufferingTime=150   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACEDU_param_dict_7}
...   maxBufferingTime=1500   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=true
...   certTypeForTlsAuth=ECDSA
&{NRSTRACEDU_param_dict_8}
...   maxBufferingTime=1000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACEDU_param_dict_9}
...   maxBufferingTime=1000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=false
&{NRSTRACEDU_param_dict_10}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=1  tlsEnabled=true
&{NRSTRACEDU_param_dict_11}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACEDU_param_dict_12}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=true
&{NRSTRACEDU_param_dict_13}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=10  tlsEnabled=false
&{NRSTRACEDU_param_dict_14}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACEDU_param_dict_15}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
...   actPCMDReporting=false
&{NRSTRACEDU_param_dict_16}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=255  tlsEnabled=false
&{NRSTRACEDU_param_dict_17}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=false
&{NRSTRACEDU_param_dict_18}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=true  defaultNrTceIdentifier=2  tlsEnabled=false
&{NRSTRACECU_param_dict_1}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=2  tlsEnabled=true
&{NRSTRACECU_param_dict_2}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
&{NRSTRACECU_param_dict_3}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=3  tlsEnabled=false
...   actPCMDReporting=false
&{NRSTRACECU_param_dict_4}
...   maxBufferingTime=2000   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=255  tlsEnabled=false
&{NRMTRACEDU_param_dict_1}
...   nrTcePortNumber=49148   nrTceIdentifier=1
&{NRMTRACECU_param_dict_1}
...   actPCMDReporting=true   nrTceIdentifier=1
&{NRMTRACECUUP_param_dict_1}
...   actPCMDReporting=true   nrTceIdentifier=1
&{TCE_param_dict_1}
...   nrTcePortNumber=49148   tceIdentifier=255   tceIpAddress=10.101.2.23   tlsEnabled=true
@{traceDepth_index_list}  ${0}  ${1}  ${2}  ${3}  ${4}  ${5}
@{ue_index_list}  ${0}  ${1}  ${2}  ${3}  ${4}  ${5}
@{ue_id_list}  ${1}  ${2}  ${3}  ${4}  ${5}  ${6}
@{traceDepth_list}   minimum  medium  maximum  min_without_vse  med_without_vse  max_without_vse
@{traceDepth_index_list_wo}  ${0}  ${1}  ${2}
@{ue_index_list_wo}  ${0}  ${1}  ${2}
@{ue_id_list_wo}  ${1}  ${2}  ${3}
@{traceDepth_list_w}   minimum  medium  maximum
@{traceDepth_list_wo}  min_without_vse  med_without_vse  max_without_vse
@{f1ap_trace_activate_list}   f1ap.traceDepth == minimum
...  f1ap.traceDepth == medium
...  f1ap.traceDepth == maximum
...  f1ap.traceDepth == minimumWithoutVendorSpecificExtension
...  f1ap.traceDepth == mediumWithoutVendorSpecificExtension
...  f1ap.traceDepth == maximumWithoutVendorSpecificExtension
@{e1ap_trace_activate_list}   e1ap.traceDepth == minimum
...  e1ap.traceDepth == medium
...  e1ap.traceDepth == maximum
...  e1ap.traceDepth == minimumWithoutVendorSpecificExtension
...  e1ap.traceDepth == mediumWithoutVendorSpecificExtension
...  e1ap.traceDepth == maximumWithoutVendorSpecificExtension
@{ngap_trace_activate_list}   ngap.traceDepth == minimum
...  ngap.traceDepth == medium
...  ngap.traceDepth == maximum
...  ngap.traceDepth == minimumWithoutVendorSpecificExtension
...  ngap.traceDepth == mediumWithoutVendorSpecificExtension
...  ngap.traceDepth == maximumWithoutVendorSpecificExtension
@{f1ap_trace_activate_list_wo}   f1ap.traceDepth == minimumWithoutVendorSpecificExtension
...  f1ap.traceDepth == mediumWithoutVendorSpecificExtension
...  f1ap.traceDepth == maximumWithoutVendorSpecificExtension
@{e1ap_trace_activate_list_wo}   e1ap.traceDepth == minimumWithoutVendorSpecificExtension
...  e1ap.traceDepth == mediumWithoutVendorSpecificExtension
...  e1ap.traceDepth == maximumWithoutVendorSpecificExtension
@{ngap_trace_activate_list_wo}  ngap.traceDepth == minimumWithoutVendorSpecificExtension
...  ngap.traceDepth == mediumWithoutVendorSpecificExtension
...  ngap.traceDepth == maximumWithoutVendorSpecificExtension
@{trace_id_list}     000001   000002   000003   000004   000005   000006
@{trace_id_list_1}   000001   000002   000003
@{trace_id_list_2}   000004   000005   000006

#ET
${TCE_PORT}  49151
${resume_check}    resumeCause mt-Access
${resume_check_send_data}     rrcReconfigurationComplete
${inactive_check}    NR_RRC_INACTIVE
${rrc_message_rsrp_11}   nr-rrc.measQuantityResults.rsrp == 11
${rrc_message_rsrp_16}   nr-rrc.measQuantityResults.rsrp == 16
${rrc_message_rsrp_85}   nr-rrc.measQuantityResults.rsrp == 85
${ueMeasRecord_rsrp_11}   nsetapx.rsrp == 11
${ueMeasRecord_rsrp_16}   nsetapx.rsrp == 16
${ueMeasRecord_rsrp_85}   nsetapx.rsrp == 85
${rrc_setup_cell2}  nr-rrc.scramblingID0 == 51
${rrc_setup_gnb2_cell13}  nr-rrc.scramblingID0 == 62
${ngap}    ngap
${releasePreference_check}    QoS Routing Table
${Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
${Add_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
${HO_CELL2_SIMCELL1}
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
${HO_SIMCELL1_CELL2}
...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
${xn_up}    xnAP Link with GNB-2