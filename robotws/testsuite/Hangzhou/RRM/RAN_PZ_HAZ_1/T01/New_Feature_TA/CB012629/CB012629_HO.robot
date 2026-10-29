*** Settings ***
Documentation
...   Author: Zheng Tracy
...   Contact: tracy.zheng@nokia-sbell.com
...   Description: The purpose of this test is to Check CB012629

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     CB008411 Teardown

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    780 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot


*** Variables ***
@{du_tracerecords_HO_S}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == rrcSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == bearerRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
@{du_tracerecords_Intra_HO}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == rrcSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == bearerRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == hosrcRecord
...   nsetapx.DuVendorExtensionRecordDataType == hoTgtRecord
@{du_tracerecords_Intra_HO_612}    nsetapx.DuVendorExtensionRecordDataType == hosrcRecord
@{du_tracerecords_Intra_HO_61}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == rrcSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == bearerRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == hoTgtRecord
@{du_tracerecords_Intra_HO_TS}    nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
...   nsetapx.DuVendorExtensionRecordDataType == hosrcRecord
...   nsetapx.DuVendorExtensionRecordDataType == hoTgtRecord
@{du_tracerecords_HO_T}    nsetapx.DuVendorExtensionRecordDataType == ueCtxSetupRecord
...   nsetapx.DuVendorExtensionRecordDataType == bearerRecord
...   nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == pwrHeadroomRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == csiReportRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcMeasRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulRbRlcThroughputRecord
@{du_tracerecords_HO_Common}    nsetapx.DuVendorExtensionRecordDataType == timingAdvanceRecord
...   nsetapx.DuVendorExtensionRecordDataType == ulSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlSchedulingRecord
...   nsetapx.DuVendorExtensionRecordDataType == beamUsageRecord
...   nsetapx.DuVendorExtensionRecordDataType == dlRbRlcMeasRecord
@{trace_depth_index_list}      minimum    medium    maximum
@{trace_depth_index_listPR}      minimum    medium
@{trace_depth_index_list1}      minimum
@{trace_depth_without_index_list1}      max_without_vse
@{trace_depth_without_index_list}      max_without_vse    med_without_vse    min_without_vse
${DST_FOR_FRM}          MRBTS-5505/NRBTS-10065
${DST_FOR_FRM_T}          MRBTS-5505/NRBTS-5505
${sba_host_tls}           10.56.197.4
${sba_host}               10.56.218.136
#${sba_host}               10.56.197.7
${FLAG}                  1
${DST_FOR_FRM_XNAP}      MRBTS-4812/NRBTS-10065/NRADJGNB-1
${DST_FOR_FRM_Cell_T}      MRBTS-5505/NRBTS-5505/NRCELL-0
${DST_FOR_FRM_Cell_T2}      MRBTS-5505/NRBTS-5505/NRCELL-1
@{cuup_tracerecords}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerCtxSetupRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == bearerRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
@{cuup_tracerecords_TS}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
@{cuup_tracerecords_detach}   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpThroughputRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == ulRbPdcpMeasRecord
...   nsetapx.CuUpVendorExtensionRecordDataType == dlRbPdcpMeasRecord
@{cucp_tracerecords}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == rrcSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == bearerrecord
@{cucp_tracerecords_detach}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
@{cucp_tracerecords_NGHO_S}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ngHoSrcRecord
@{cucp_tracerecords_NGHO_T}   nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ngHoTgtRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
@{cucp_tracerecords_XNHO_S}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == xnHoSrcRecord
@{cucp_tracerecords_XNHO_T}   nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == xnHoTgtRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
@{cucp_tracerecords_IntraHO}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueDuConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == intragNBHoSrcRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
...    nsetapx.CuVendorExtensionRecordDataType == bearerRecord
...    nsetapx.CuVendorExtensionRecordDataType == intragNBHoTgtRecord
@{cucp_tracerecords_IntraHO_TS}   nsetapx.CuVendorExtensionRecordDataType == pduSessionResourceInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == intragNBHoSrcRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueSetupRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueCuUpConnectivityRecord
...    nsetapx.CuVendorExtensionRecordDataType == ueMeasRecord
...    nsetapx.CuVendorExtensionRecordDataType == bearerRecord
...    nsetapx.CuVendorExtensionRecordDataType == intragNBHoTgtRecord
&{NRSTRACEDU_param_non_tls}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  tlsEnabled=false
...    tracePCMDCoordinateSystem=DoA
&{NRSTRACEDU_param_tls}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  tlsEnabled=true
...    tracePCMDCoordinateSystem=DoA
&{NRSTRACEDU_param_non_tls_actpcmd_false}
...   maxBufferingTime=50   nrTcePortNumber=49148  applyDefNrTceForAllSessions=false  defaultNrTceIdentifier=34  tlsEnabled=false
...   actPCMDReporting=false     tracePCMDCoordinateSystem=DoA



*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=gnb

IntraHO
#[TC58]CB012629-SR-A-B105_58_Successful_PCMD_SBA_trace_activation_Intra_DU_HO
    [Tags]    QC_32405       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     #Case Precondition for ST   product_type=gnb
	 #${scf_file}   Set Variable    5505_SCF_Intra_HO.xml
	 #Commissioning scf and wait on air Target gNB    scf_file_path=${CURDIR}/config/${scf_file}
     #Start Btslog Collect
     #${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time     dcap_server=${dcap_server_sba}
     #...      host=${sba_host}
     FOR   ${trace_depth_index}   IN   @{trace_depth_index_list}
         Start attenuator
         sleep        60s
         Start attenuator open source cell attach intra DU HO
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
#         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
#         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start Subscriber Trace   ue_id=10    tce_ip=${sba_host}  trace_depth=${trace_depth_index}
        ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
         Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target cell attach intra DU HO
         sleep    20s
         Start attenuator set source cell for intra DU HO
         sleep    55s
		 #Start attenuator open source cell attach intra DU HO
         #sleep    10s
		 #Start attenuator set target cell attach intra DU HO
		 #sleep    10s
         log to console    ********Detach UE***********
         Stop single UE  ue_index=0
         sleep    5s
         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${du_tracerecords_Intra_HO_TS}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
#		 ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
#         ...     tracerecords=${du_tracerecords_Intra_HO}
#		 ...     capture_file_path=${local_file_path_S}   host=sba    traceId=ffffff
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_IntraHO_TS}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords_TS}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5

     END
     FOR   ${trace_depth_index}   IN   @{trace_depth_without_index_list}
         Start attenuator
         Start attenuator open source cell attach intra DU HO
         #Start Tcpdump Log
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
#         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
#         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start Subscriber Trace   ue_id=10    tce_ip=${sba_host}  trace_depth=${trace_depth_index}
        ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
         Start single UE traffic   ue_index=0
         sleep    15s
         Start attenuator open target cell attach intra DU HO
         sleep    10s
         Start attenuator set source cell for intra DU HO
         sleep    30s
         log to console    *****Detach UE********
         Stop single UE  ue_index=0
         sleep    5s
         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
		 ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...     tracerecords=${du_tracerecords_IntraHO}  host=sba    traceId=ffffff
		 ...     capture_file_path=${local_file_path_T}
		 ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...     tracerecords=${du_tracerecords_Intra_HO_TS}  host=sba    traceId=ffffff
		 ...     capture_file_path=${local_file_path_T}
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cucp_tracerecords_IntraHO}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         log to console    scecario2 is completed
     END
    [Teardown]         Intra gNB HO CRT Teardown


#TraceStart
##[TC59]CB012629-SR-A-B105_59_Reactivation_of_the_gNB-DU_Subscriber_Trace_reporting_terminated_by_actPCMDReport
#    [Tags]    QC_       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#	 #${scf_file}   Set Variable    5505_SCF_Intra_HO.xml
#	 #Commissioning scf and wait on air Target gNB    scf_file_path=${CURDIR}/config/${scf_file}
#     #Start Btslog Collect
#    # Case Precondition for ST   product_type=gnb
#     FOR   ${trace_depth_index}   IN   @{trace_depth_index_list}
#         Start attenuator
#         Start attenuator open source cell attach intra DU HO
#		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
#         Prepare UE For commercial or Spark   ue_index=0
#         Attach single UE   ue_index=0
#         Start single UE traffic   ue_index=0
#         Start Subscriber Trace   ue_id=10    tce_ip=${sba_host}  trace_depth=${trace_depth_index}
#        ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
#        ...   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
#         sleep    20s
#         log to console    ********Detach UE***********
#         Stop single UE  ue_index=0
#         sleep    5s
#         #${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
#         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
#     END
#     FOR   ${trace_depth_index}   IN   @{trace_depth_without_index_list}
#         Start attenuator
#         Start attenuator open source cell attach intra DU HO
#		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
#         Prepare UE For commercial or Spark   ue_index=0
#         Attach single UE   ue_index=0
#         Start single UE traffic   ue_index=0
#         Start Subscriber Trace   ue_id=10    tce_ip=${sba_host}  trace_depth=${trace_depth_index}
#        ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
#        ...   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
#         sleep    20s
#         log to console    ********Detach UE***********
#         Stop single UE  ue_index=0
#         sleep    5s
#         #${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
#         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
#     END
#    [Teardown]         Intra gNB HO CRT Teardown



TC61
#[TC59]CB012629-SR-A-B105_59_Reactivation_of_the_gNB-DU_Subscriber_Trace_reporting_terminated_by_actPCMDReport
    [Tags]    QC_132239       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
	 #${scf_file}   Set Variable    5505_SCF_Intra_HO.xml
	 #Commissioning scf and wait on air Target gNB    scf_file_path=${CURDIR}/config/${scf_file}
     #Start Btslog Collect
	 Kill Node Process
     #Case Precondition for ST   product_type=gnb
     #Kill Node Process
     FOR   ${trace_depth_index}   IN   @{trace_depth_index_list}
         Start attenuator
         Start attenuator open source cell attach intra DU HO
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    10s
		 Delete target NRSTRACEDU        param_dict=${NRSTRACEDU_param_non_tls}
		 Kill Node Process
         Add target NRSTRACEDU         param_dict=${NRSTRACEDU_param_non_tls}
         Kill Node Process
         Start attenuator open target cell attach intra DU HO
         Start attenuator set source cell for intra DU HO
         sleep    60s
         log to console    ********Detach UE***********
         Stop single UE  ue_index=0
         sleep    5s
         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${du_tracerecords_Intra_HO_61}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_IntraHO}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...     tracerecords=${du_tracerecords_IntraHO_612}  host=sba    traceId=ffffff
		 ...     capture_file_path=${local_file_path_T}
		 Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 5

     END
     FOR   ${trace_depth_index}   IN   @{trace_depth_without_index_list}
         Start attenuator
         Start attenuator open source cell attach intra DU HO
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    10s
		 Delete target NRSTRACEDU        param_dict=${NRSTRACEDU_param_non_tls}
		 Kill Node Process
         Add target NRSTRACEDU          param_dict=${NRSTRACEDU_param_non_tls}
         Kill Node Process
         Start attenuator open target cell attach intra DU HO
         Start attenuator set source cell for intra DU HO
         sleep    20s
         log to console    ********Detach UE***********
         Stop single UE  ue_index=0
         sleep    5s
         ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
		 ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...     tracerecords=${du_tracerecords_IntraHO}  host=sba    traceId=ffffff
		 ...     capture_file_path=${local_file_path_T}
		 #${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 #...     tracerecords=${du_tracerecords_Common}  host=sba    traceId=ffffff
		 #...     capture_file_path=${local_file_path_T}
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cucp_tracerecords_IntraHO}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
		 ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...     capture_file_path=${local_file_path_T}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         #Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
     END
    [Teardown]         Intra gNB HO CRT Teardown


NGHO
#[TC73]CB012629-SR-B-B102_73_SBA_TRSs_activation_gNB-CU-CP_InterfacesToTraces_IE_0_NGAP_HO
    [Tags]    QC_32407       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    #Case Precondition for ST   product_type=gnb
    Get Required Logs   start  syslog   gnb
	Run Keyword And Ignore Error       Lock XNAP
    FOR   ${trace_depth_index}   IN   @{trace_depth_index_list}
         Start attenuator
         sleep        60s
         Start attenuator open source gNB
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    15s
         Start attenuator open target gNB
         sleep    15s
         Start attenuator HO from source gNB
         sleep    60s
         Stop single UE  ue_index=0
         sleep    5s
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${du_tracerecords_HO_Common}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${du_tracerecords_HO_Common}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${cucp_tracerecords_NGHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${cucp_tracerecords_NGHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...      tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         #${check_result}    ${check_result2}=    Run Keyword And Ignore Error      Check emil logs for sba
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
    END
	FOR   ${trace_depth_index}   IN   @{trace_depth_without_index_list}
         Start attenuator
         sleep        60s
         Start attenuator open source gNB
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...    ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target gNB
         sleep    25s
         Start attenuator HO from source gNB
         sleep    25s
         Stop single UE  ue_index=0
         sleep    5s
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_T}
		 ...     capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_S}
		 ...     capture_file_path=${local_file_path}   host=sba    traceId=ffffff
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...      tracerecords=${cucp_tracerecords_NGHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cucp_tracerecords_NGHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
         END
    [Teardown]     Inter gNB HO Teardown


TC55
    [Tags]    QC_32408       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    #Case Precondition for ST   product_type=gnb
    Get Required Logs   start  syslog    gnb
    FOR    ${ue_id}    IN RANGE    36    39
        ${index}    Set Variable    ${ue_id % 6}
        ${trace_depth_index}    Set Variable    ${traceDepth_list[${index}]}
         Start attenuator open source gNB
         Run Keyword And Ignore Error      Delete target NRSTRACEDU      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACEDU        param_dict=${NRSTRACEDU_param_tls}
         Run Keyword And Ignore Error      Delete target NRSTRACECU      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACECU        param_dict=${NRSTRACEDU_param_tls}
         Run Keyword And Ignore Error      Delete target NRSTRACECUUP      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACECUUP        param_dict=${NRSTRACEDU_param_tls}
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host_tls}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host_tls}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target gNB Cell 0
         sleep    25s
         Start attenuator HO from source gNB Cell 0
         sleep    25s
		 Delete target NRSTRACEDU      param_dict=${NRSTRACEDU_param_tls}
		 Delete target NRSTRACECU      param_dict=${NRSTRACEDU_param_tls}
		 Delete target NRSTRACECUUP      param_dict=${NRSTRACEDU_param_tls}
         sleep    5s
         Stop single UE  ue_index=0
         sleep    5s
		 Add target NRSTRACEDU        param_dict=${NRSTRACEDU_param_non_tls}
		 Add target NRSTRACECU        param_dict=${NRSTRACEDU_param_non_tls}
		 Add target NRSTRACECUUP        param_dict=${NRSTRACEDU_param_non_tls}
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
         Start attenuator open source gNB
		 Attach single UE   ue_index=0
		 Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target gNB Cell 0
         sleep    25s
         Start attenuator HO from source gNB Cell 0
         sleep    65s
         Stop single UE  ue_index=0
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
                  ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${du_tracerecords_HO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...       tracerecords=${du_tracerecords_HO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_XNHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_XNHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
    END
    FOR    ${ue_id}    IN RANGE    39    42
        ${index}    Set Variable    ${ue_id % 6}
        ${trace_depth_index}    Set Variable    ${traceDepth_list[${index}]}
         Start attenuator open source gNB
         Delete target NRSTRACEDU      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACEDU        param_dict=${NRSTRACEDU_param_tls}
         Delete target NRSTRACECU      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACECU        param_dict=${NRSTRACEDU_param_tls}
         Delete target NRSTRACECUUP      param_dict=${NRSTRACEDU_param_non_tls}
         Add target NRSTRACECUUP        param_dict=${NRSTRACEDU_param_tls}
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host_tls}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...    ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host_tls}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target gNB Cell 0
         sleep    25s
         Start attenuator HO from source gNB Cell 0
         sleep    25s
		 Delete target NRSTRACEDU      param_dict=${NRSTRACEDU_param_tls}
		 Delete target NRSTRACECU      param_dict=${NRSTRACEDU_param_tls}
		 Delete target NRSTRACECUUP      param_dict=${NRSTRACEDU_param_tls}
         sleep    5s
         Stop single UE  ue_index=0
         sleep    5s
		 Add target NRSTRACEDU        param_dict=${NRSTRACEDU_param_non_tls}
		 Add target NRSTRACECU        param_dict=${NRSTRACEDU_param_non_tls}
		 Add target NRSTRACECUUP        param_dict=${NRSTRACEDU_param_non_tls}
		 ${ue1_id}    Set Variable    ${ue_id + 1}
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...    ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=Xn-C,NG-C,Uu,E1,F1-C
         Start attenuator open source gNB
         Attach single UE   ue_index=0
		 Start single UE traffic   ue_index=0
         sleep    10s
         Start attenuator open target gNB Cell 0
         sleep    25s
         Start attenuator HO from source gNB Cell 0
         sleep    25s
         Stop single UE  ue_index=0
         sleep    5s
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_T}
		 ...     capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_S}
		 ...     capture_file_path=${local_file_path}   host=sba    traceId=ffffff
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...      tracerecords=${cucp_tracerecords_XNHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cucp_tracerecords_XNHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
    END
    [Teardown]     	Run Keyword And Ignore Error      Add target NRSTRACEDU
    ...         param_dict=${NRSTRACEDU_param_non_tls}


XNHO
#[TC74]CB012629-SR-B-B103_74_SBA_TRSs_activation_gNB-CU-CP_InterfacesToTraces_IE_0_XNAP_HO
    [Tags]    QC_32406       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    #Case Precondition for ST   product_type=gnb
    Get Required Logs   start  syslog   gnb
    FOR   ${trace_depth_index}   IN   @{trace_depth_index_list}
         Start attenuator
         sleep        60s
         Start attenuator open source gNB
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...   ifaces_to_trace=none
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215   ifaces_to_trace=none
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    15s
         Start attenuator open target gNB
         sleep    15s
         Start attenuator HO from source gNB
         sleep    55s
         Stop single UE  ue_index=0
         sleep    5s
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${du_tracerecords_HO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...       tracerecords=${du_tracerecords_HO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_XNHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cucp_tracerecords_XNHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check multi tracerecords
         ...     tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
    END
	FOR   ${trace_depth_index}   IN   @{trace_depth_without_index_list}
         Start attenuator
         sleep        60s
         Start attenuator open source gNB
         Trigger ICS With Trace Start   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215  trace_rec_session_ref_id=1   trace_plmn=262:03
		 ...   ifaces_to_trace=none
		 Set SBA Trace for NGHO   ue_id=10  tce_ip=${sba_host}  trace_depth=${trace_depth_index}
         ...   trace_ref_id=16777215     ifaces_to_trace=none
	     Get Required Logs   start  wireshark   gnb
		 Log Collection    start    wireshark    product_type=gnb    bts_index=${1}
         Prepare UE For commercial or Spark   ue_index=0
         Attach single UE   ue_index=0
         Start single UE traffic   ue_index=0
         sleep    15s
         Start attenuator open target gNB
         sleep    15s
         Start attenuator HO from source gNB
         sleep    15s
         Stop single UE  ue_index=0
         sleep    5s
		 ${local_file_path_T}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${1}
         Log To Console    \nwireshark log: ${local_file_path_T}
		 ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
         ${check_result1}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_T}
		 ...     capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result3}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${du_tracerecords_HO_S}
		 ...     capture_file_path=${local_file_path}   host=sba    traceId=ffffff
		 ${check_result4}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
		 ...      tracerecords=${cucp_tracerecords_XNHO_T}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result5}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cucp_tracerecords_XNHO_S}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         ${check_result6}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...     tracerecords=${cuup_tracerecords}
		 ...      capture_file_path=${local_file_path_T}   host=sba   traceId=ffffff
         ${check_result7}    ${check_result2}=    Run Keyword And Ignore Error      Check no tracerecords
         ...      tracerecords=${cuup_tracerecords_detach}
		 ...      capture_file_path=${local_file_path}   host=sba    traceId=ffffff
         Should Be Equal As Strings    ${check_result1}     PASS      msg=Check multi tracerecords failed 1
         Should Be Equal As Strings    ${check_result3}     PASS      msg=Check multi tracerecords failed 3
         Should Be Equal As Strings    ${check_result4}     PASS      msg=Check multi tracerecords failed 4
         Should Be Equal As Strings    ${check_result5}     PASS      msg=Check multi tracerecords failed 5
         Should Be Equal As Strings    ${check_result6}     PASS      msg=Check multi tracerecords failed 6
         Should Be Equal As Strings    ${check_result7}     PASS      msg=Check multi tracerecords failed 7
    END
    [Teardown]     Inter gNB HO Teardown

4G
    [Tags]    QC_32429       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    sleep        60s


NGAP3
    [Tags]    QC_32409       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    #Case Precondition for ST   product_type=gnb
    sleep        60s


CNI
    [Tags]    QC_50497       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    sleep        60s


*** Keywords ***
Set SBA Trace for NGHO
    [Arguments]    ${ue_id}=10   ${tce_ip}=&{dcap_server_sba}    ${trace_depth}=maximum    ${trace_ref_id}=2
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,E1,F1
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ng_handover_request_param id=1 ue=${ue_id} trace_activation=on trace_plmn=262:03
    ...           \ trace_ref_id=${trace_ref_id} trace_rec_session_ref_id=1 trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ tce_ip=${tce_ip}
    Execute Egate Command    cmd=${command}     fail_regexp=amf_ue_ng_handover_request_param

Inter gNB HO Teardown
    Run Keyword And Ignore Error      Get Required Logs   stop_and_download   syslog   gnb
#	Log Collection    start    snapshot    product_type=gnb    bts_index=${0}      timeout=${1200}
#	Log Collection    start    snapshot    product_type=gnb    bts_index=${1}      timeout=${1200}
    Run Keyword And Ignore Error      Unlock XNAP
    Start attenuator
    Run Keyword And Ignore Error      Log Collection    stop_and_download
	...      wireshark    product_type=gnb    bts_index=${1}
	NGAP Rollback Target gNB Recover
	XNAP Rollback Target gNB Recover

TC46 Teardown
    Run Keyword And Ignore Error      Get Required Logs   stop_and_download   syslog   gnb
    Run Keyword And Ignore Error      Unlock XNAP
    Start attenuator
    Run Keyword And Ignore Error      Log Collection    stop_and_download
	...      wireshark    product_type=gnb    bts_index=${1}
    BTS Operation  operation=cell_unblock  product_type=gnb  bts_index=1  distname_id=NRCELL-0  need_verify=yes


TC52 Teardown
    Activate PCMD Report Target gNB
	Activate SBA Report Target gNB
	Start attenuator
    Run Keyword And Ignore Error      Log Collection    stop_and_download
	...      wireshark    product_type=gnb    bts_index=${1}


Lock XNAP
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_XNAP}    parameter=administrativeState   new_value=Locked
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Unlock XNAP
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_XNAP}    parameter=administrativeState
    ...      new_value=Unlocked
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

NGAP Rollback Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actIntraNrNgHo   new_value=disabled
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

NGAP Rollback Target gNB Recover
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actIntraNrNgHo
    ...      new_value=sourceAndTarget
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

XNAP Rollback Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_Cell_T}    parameter=maxNumOfRrcSA   new_value=0
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

XNAP Rollback Target gNB Recover
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_Cell_T}    parameter=maxNumOfRrcSA   new_value=250
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Activate Trace Report
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM}    parameter=actPCMDReport   new_value=true
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM}    parameter=actSubscriberTraceReport   new_value=true
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Deactivate PCMD Report
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM}    parameter=actPCMDReport   new_value=false
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Activate PCMD Report Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actPCMDReport   new_value=true
    #COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM}    parameter=actSubscriberTraceReport   new_value=true
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Activate SBA Report Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actSubscriberTraceReport   new_value=true
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Deactivate PCMD Report Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actPCMDReport   new_value=false
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Deactivate SBA Report Target gNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=actSubscriberTraceReport   new_value=false
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Deactivate Subscriber Report
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM}    parameter=actSubscriberTraceReport   new_value=false
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Start attenuator HO from source gNB
    Log to console    Adjust PA Signal to HO to target gNB
    Set attenuator      value14= ${50}    value16= ${50}      value9= ${0}    value11= ${0}    value13= ${0}
    ...       value15= ${0}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator HO from source gNB Cell 0
    Log to console    Adjust PA Signal to HO to target gNB
    Set attenuator      value14= ${60}    value16= ${60}      value3= ${0}    value11= ${0}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator HO from target gNB
    Log to console    Adjust PA Signal to HO to source gNB
    Set attenuator      value14= ${0}    value16= ${0}      value9= ${40}    value11= ${40}    value13= ${40}
    ...         value15= ${40}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator HO from target gNB Cell 0
    Log to console    Adjust PA Signal to HO to source gNB
    Set attenuator      value14= ${0}    value16= ${0}      value3= ${50}    value11= ${50}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator open source gNB
    Log to console    Adjust PA Signal for attach to source gNB
#    Set attenuator      value14= ${0}    value16= ${0}
    Set attenuator      value2= ${0}    value4= ${0}    value6= ${0}    value8= ${0}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator open target gNB
    Log to console    Adjust PA Signal for attach to target gNB
#    Set attenuator      value14= ${0}    value16= ${0}      value9= ${0}    value11= ${0}    value13= ${0}
    ...      value15= ${0}
    Set attenuator      value2= ${0}    value4= ${0}    value6= ${0}    value8= ${0}      value9= ${0}
    ...      value11= ${0}    value13= ${0}     value15= ${0}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator open target gNB Cell 0
    Log to console    Adjust PA Signal for attach to target gNB
#    Set attenuator      value14= ${0}    value16= ${0}      value3= ${0}    value11= ${0}
     Set attenuator      value2= ${0}    value4= ${0}    value6= ${0}    value8= ${0}      value3= ${0}
     ...     value11= ${0}
     sleep    10s
    Log to console    attenuation change complete

Start attenuator open source cell attach intra DU HO
    Log to console    Adjust PA Signal for attach intra DU HO
    Set attenuator      value5= ${0}    value13= ${0}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator set source cell for intra DU HO
    Log to console    Adjust PA Signal trigger intra DU HO
    Set attenuator      value3= ${0}    value11= ${0}      value5= ${20}    value13= ${20}
    sleep    10s
    Log to console    attenuation change complete

Start attenuator open target cell attach intra DU HO
    Log to console    Adjust PA Signal for attach to target gNB
    Set attenuator      value3= ${0}    value11= ${0}      value5= ${0}    value13= ${0}
    sleep    10s
    Log to console    attenuation change complete


Start attenuator set target cell attach intra DU HO
    Log to console    Adjust PA Signal for attach to target gNB
    Set attenuator      value3= ${0}    value11= ${0}      value5= ${10}    value13= ${10}
    sleep    10s
    Log to console    attenuation change complete

Intra gNB HO CRT Teardown
    Stop single UE  ue_index=0
	Run Keyword And Ignore Error      Log Collection    stop_and_download
	...     wireshark    product_type=gnb    bts_index=${1}
#	Log Collection    start    snapshot    product_type=gnb     bts_index=${0}      timeout=${1200}
    Activate PCMD Report Target gNB
	Activate SBA Report Target gNB
	#${scf_file}   Set Variable    SCF_5505_Common.xml
	#Commissioning scf and wait on air Target gNB    scf_file_path=${CURDIR}/config/${scf_file}

TC01 Teardown
    sleep  60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Check common tracerecords  tracerecords=${traceMessage_configure}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${traceMessage_startSession}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${alive}   capture_file_path=${local_file_path}
    Add or Delete A New MOC   moc_jason=delete-NRMTRACEDU-applyDefNrTceForAllSessions-false.json

Commissioning scf and wait on air Target gNB
   [Arguments]         ${scf_file_path}
   COAM Commission with scf file Target gNB    scf_file_path=${scf_file_path}
   Check site on air Target GNB

Get Runtime SCF
   [Arguments]         ${gnb_index}=0
    ${connection}     _bts.login    product_type=gnb     gnb_index=${gnb_index}     alias=COAM
    ${BTS_scf_1}    Collect scf with timestamp   alias=${connection}   folder_path=${OUTPUT_DIR}
    ...             export_type=configurationAndRuntimeObjects
    [Return]    ${BTS_scf_1}
	[Teardown]   Run Keyword And Ignore Error     coam.teardown    connection=${connection}

COAM Commission with scf file Target gNB
    [Arguments]    ${scf_file_path}    ${connection}=COAM_local    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Description: Do commission and verify commission status
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file_path} | Yes | The scf file full path and file name. E.g. ~/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${connection} | No | The connection alias, default is COAM_local |
    ...    | ${timeout} | No | The timeout for this commission, default is 300s |
    ...    | ${is_pdl_checking_needed} | No | Whether need the pdl validation, default is True |
    ...
    ...    | Return Value | Description |
    ...    | ${result} | The commission result |
    ...
    ...    Example
    ...    | ${commission_result} | COAM Commission with scf file | scf_file=/home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=COAM
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    [Return]    ${result}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Check site on air Target GNB
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=10.56.218.135
    wait until keyword succeeds    10 min    30 sec    Verify 5G cells should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Execute Egate Command
    [Arguments]    ${cmd}    ${timeout}=60
    ...    ${pass_regexp}=${None}     ${fail_regexp}=${None}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...    This keyword is used to Execute Egate Command.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cmd} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | Airphone Execute Egate Command | local_dir=${LOCAL_WTS_DIR} |
    ...
    tak_ap.airphone_execute_egate_command   ${cmd}    timeout=${timeout}
    ...    pass_regexp=${pass_regexp}     fail_regexp=${fail_regexp}

Add target NRSTRACECU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}   ${json_file_name}=NRSTRACECU-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACECU.json   new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACECU.json   bts_index=${1}

Delete target NRSTRACECU
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACECU-1.json
    ...   new_file_name=NRSTRACECU.json   target_operation=delete  new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACECU.json   bts_index=${1}

Add target NRSTRACECUUP
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}   ${json_file_name}=NRSTRACECUUP-1.json
    Modify json file value    param_dict=${param_dict}   json_file_name=${json_file_name}
    ...   new_file_name=NRSTRACECUUP.json   new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json   bts_index=${1}

Delete target NRSTRACECUUP
    [Arguments]    ${param_dict}=${NRSTRACEDU_param_dict_4}
    Modify json file value    param_dict=${param_dict}   json_file_name=NRSTRACECUUP-1.json
    ...   new_file_name=NRSTRACECUUP.json   target_operation=delete  new_distname=MRBTS-5505/NRBTS-5505
    Add or Delete A New MOC   moc_jason=NRSTRACECUUP.json   bts_index=${1}

Kill Node Process
    ssh.Connect to    hostname=127.0.0.1    username=${PC_USER}    password=${PC_PASSWORD}    alias=VM
    ssh.execute    command=sudo pkill node    connection=VM
    ssh.disconnect    connection=VM

CB008411 Teardown
     Common Test Teardown For RRM
     ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False