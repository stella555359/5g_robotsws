*** Settings ***
Documentation
...   Author: tracy.zheng@nokia-sbell.com
...   Contact: tracy.zheng@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM

Test Timeout    72 hour

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource           CommonKeyword/CB012629_Common_KeyWord.robot
Resource           CommonKeyword/CB012629_ET_KeyWord.robot


*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
${ap_version}     4.0.32005

*** Test Cases ***

Update Local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...                   eth_config_path=${CURDIR}/APCFG/ap_tl.json
    ...                   ap_build=${ap_version}

CheckSCF
    ${BTS_scf_1}     Get Runtime SCF     gnb_index=0
    sleep   5s
    ${BTS_scf_2}     Get Runtime SCF     gnb_index=0
	${status}    basic.compare_xml_files_and_return_status     file1=${BTS_scf_1}     file2=${BTS_scf_2}
	should be true    ${status}==${True}


TC104
	#[Setup]    Case Precondition For 8731       tag=104
	Airphone Operation   edaemon_egate_setup   gnb    tag=104
	Set AMF for Optimized ICS
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR    ${ue_id}    IN RANGE    101    107
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=none     tce_ip=10.56.197.7     trace_plmn=262:03
		sleep      5s
        Run Keyword And Ignore Error      UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
		sleep      5s
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=1
		sleep      5s
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=1
		sleep      5s
        #bearer stats check    ue_id=${ue_id}    direction=dl
        #bearer stats check    ue_id=${ue_id}    direction=ul
		sleep      5s
    END
    UE Deregister From gNB
    [Teardown]    TC67 Teardown

TC67
#[TC67]CB012629-SR-A_67_Activation_of_SBA_with_PCMD_content_for_gNB-DU_TCE_NRSTRACEDU_Conflicts_non_TLS_FR2
    [Tags]    QC_25243       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that default TCE's configuration will be used when TCE and NRSTRACEDU has
    ...    configuration conflicts.
    ...       OM_GEN_SFS_TRACEMGMNT.4843
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport for activating PCMD functionality is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport for activating Subscriber trace functionality is settotrue
    ...       NRBTS.NRDU.NRCTRLTSDU.NRMTRACEDU is configured (MBA)
    ...       MNL.TCEADM.TCE is configured with   tlsEnabled set to true
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA in ICS for DU with default TCE.
    ...              Online add below MOCs:
    ...              NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...              actPCMDReporting is set to true
    ...              defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...              nrTcePortNumber is set
    ...              tlsEnabled set to true
    ...              applyDefNrTceForAllSessions set to false
    ...       step2. Attach UE1 and start data traffic.
    ...       step3: Detach UE. Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  L2 and L3 PCMD content in scope of gNB-DU trace recording session (both MBA and SBA are same) is
    ...       reported to TCE
    ...       b.  In tcpdump, there is  NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
##    [Setup]    Test case precondition    ap_version=${ap_version}       tag=fr2
#    [Setup]    Airphone Operation  edaemon_egate_setup  gnb  tag=fr2
    Case Precondition For 8731       tag=fr2
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_17}
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
        Trigger ICS With Trace Start   ue_id=${ue_id}    tce_ip=${sba_host_tls}  trace_depth=${trace_depth}
        ...   trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
        Start data traffic in egate   ue_id=${ue_id}  direction=dl
        Start data traffic in egate   ue_id=${ue_id}   direction=ul
    END
    ${log_collection_end_time_mba}    ${dcap_alias_mba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_mba}    host=${mba_host}
    ${log_collection_end_time_sba_tls}    ${dcap_alias_tls}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_tls}    host=${sba_host_tls}
    Set Test Variable  ${log_collection_end_time_mba}
    Set Test Variable  ${dcap_alias_mba}
    Set Test Variable  ${log_collection_end_time_sba_tls}
    Set Test Variable  ${dcap_alias_tls}
    [Teardown]    TC67 Teardown

TC68
    [Tags]    QC_25243       QCD_MN_RAN      QCP_RAN_VRF
	[Setup]     Case Precondition For 8731       tag=8731
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_17}
    Get Required Logs   start  syslog   gnb
#    Get Required Logs   start  wireshark   gnb
    FOR    ${ue_id}    IN RANGE    1    11
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=1
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=3
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=2
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=2
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    FOR    ${ue_id}    IN RANGE    21    31
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=3
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=2    mbps=1
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=2    mbps=1
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    sleep    3600s
    UE Deregister From gNB
    [Teardown]    TC67 Teardown

TC84*****
    [Tags]    QC_25243       QCD_MN_RAN      QCP_RAN_VRF
    #[Setup]     Case Precondition For 8731       tag=8731
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_17}
    Get Required Logs   start  syslog   gnb
#    Get Required Logs   start  wireshark   gnb
    FOR    ${ue_id}    IN RANGE    1    11
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=1
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=3
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=2
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=2
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    FOR    ${ue_id}    IN RANGE    21    31
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=3
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=2    mbps=1
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=2    mbps=1
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    FOR    ${ue_id}    IN RANGE    11    21
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=1    mbps=1
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=1    mbps=1
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    FOR    ${ue_id}    IN RANGE    31    101
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        UE Register And PDU Session Setup   ue_id=${ue_id}  gw=2
        UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
        Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=1    mbps=1
        Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=1    mbps=1
        bearer stats check    ue_id=${ue_id}    direction=dl
        bearer stats check    ue_id=${ue_id}    direction=ul
    END
    sleep    3600s
    @{para_list}      Create List    actPCMDReport
    @{mo_list}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    @{value_list}     Create List    false
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}
    ...         mo_list=@{mo_list}
    UE Deregister From gNB
    [Teardown]    TC84 Teardown


TC85-CB012629-SR-A_85_Activation_of_SBA_with_PCMD_content_for_gNB-DU_VONR_IRAT
    [Tags]    QC_25243       QCD_MN_RAN      QCP_RAN_VRF
    #[Setup]      Case Precondition For 8731       tag=8731
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_17}
    Get Required Logs   start  syslog   gnb
    FOR    ${trace_depth}    ${ue_id}    IN ZIP    ${traceDepth_list}    ${ue_id_list}
    Set Ue NG Handover Request Param   ue_id=${ue_id}    trace_depth=${trace_depth}
    Enable including capabilities in ICS    ue_id=${ue_id}    trace_depth=${trace_depth}
    UE Register And PDU Session Setup   ue_id=${ue_id}  gw=1
    UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
    UE Modify new PDU    ue=${ue_id}     qosflows_to_add=3
    Start data traffic in egate   ue_id=${ue_id}  direction=dl    qfi=2    mbps=1
    Start data traffic in egate   ue_id=${ue_id}   direction=ul    qfi=2     mbps=1
    bearer stats check    ue_id=${ue_id}    direction=dl
    bearer stats check    ue_id=${ue_id}    direction=ul
    Meas_Records    ue_id=${ue_id}
    END
    UE Deregister From gNB
    [Teardown]    TC67 Teardown

TC86-CB012629-SR-A_86_100_Times_ICS_Timeout
    [Tags]    QC_25243       QCD_MN_RAN      QCP_RAN_VRF
    #[Setup]     Case Precondition For 8731       tag=8731
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_17}
    Get Required Logs   start  syslog   gnb
    FOR    ${index}    IN RANGE    1    11
    run_10_times_for_TC86
    END
    [Teardown]    TC67 Teardown

*** Keywords ***
run_10_times_for_TC86
    FOR    ${ue_id}    IN RANGE    1    101
        ${index}    Set Variable    ${ue_id % 6}
        ${tracedepth_value}    Set Variable    ${traceDepth_list[${index}]}
        Trigger ICS With Trace Start   ue_id=${ue_id}    trace_ref_id=${ue_id}  trace_rec_session_ref_id=${ue_id}
        ...    trace_depth=${tracedepth_value}    ifaces_to_trace=Uu,NG-C,Xn-C     tce_ip=10.56.197.7
        ...    trace_plmn=262:03
        Set Ue NG Handover Request Param    ue_id=${ue_id}    trace_depth=${tracedepth_value}
        amf_ue_ics_param_for_TC86    ue_id=${ue_id}
        Run Keyword And Ignore Error      UE Register And PDU Session Setup   ue_id=${ue_id}  gw=1
        Run Keyword And Ignore Error      UE Modify new PDU    ue=${ue_id}     qosflows_to_add=2
    END
    sleep    30s
    UE Deregister From gNB

Meas_Records
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${command} =  catenate  SEPARATOR=
    ...           ue_measurement_send_nr id=${ue_id} meas_id=4 event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...           \ phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Airphone Execute Egate Command    cmd=${command}
    Airphone Execute Egate Command   gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489

Enable including capabilities in ICS
    [Arguments]    ${ue_id}=1    ${trace_depth}=medium
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1
    ...           \ trace_activation=on trace_plmn=262:03 trace_ref_id=${ue_id} trace_rec_session_ref_id=${ue_id}
    ...           \ trace_depth=${trace_depth} ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=10.56.197.7
    Airphone Execute Egate Command    cmd=${command}

amf_ue_ics_param_for_TC86
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=amf_ue_ics_param ue=${ue_id} id=1 action=delay time_to_wait=180000


Set Ue NG Handover Request Param
    [Arguments]    ${ue_id}=1     ${trace_depth}=medium
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ng_handover_request_param id=1 ue=${ue_id} trace_activation=on trace_plmn=262:03 trace_ref_id=${ue_id}
    ...           \ trace_rec_session_ref_id=${ue_id} tce_ip=10.56.197.7 trace_depth=${trace_depth} ifaces_to_trace=0
    Airphone Execute Egate Command    cmd=${command}

Set AMF for Optimized ICS
    [Arguments]    ${ue_id}=1     ${trace_depth}=medium
    Log To Console    ${ue_id}
    Log To Console    ${trace_depth}
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=1 include_ue_capabilities=yes ue_capabilities=0414b9080bfe1a01000014f5e0302c002074
    ...           001208367130f8509009b0083ff30c7942c0e09804062280c0298c00283e236b0c6d1d262a08fe5949328340105b260901831e
    ...           31ff9863ca160703878099d87619d876008006000000000e2300000000210602372687c0390400000290400000a90400001292
    ...           500001a6017036f236b7480282000012ca48080000cb29202000052ca48080001cb29282000092ca48480002a9652401340e2e
    ...           91c5d0a89a55115d8816007801a010080000000000200400840503a5bc70053a001040c2050c1c409142c60d20449132854b17
    ...           3064d1b3a796bf3a7400000003a00000001d00000000e800000007400000003a00000001d00000000e800000007400000003a0
    ...           0000001d00000000e800000007400000003a00000001d00000000e800000007400000003a00000001d00000000e80000000740
    ...           0000003a00000001d00000000e800000007400000003a00000001d00000000e800000007400000003a000000037f7ffd900100
    ...           386c800000002f740000001012a545c63a02000004100008400010c0002200004500008c00011c0002400004900009400012c0
    ...           002600004d0000a0000144000290000530000a80001540002b0000570000b00001640002d00005b0000ba0001780003680007f
    ...           001d3a00000001d00000000e800000007400000003a00000001d00000000e800000007400000003a00000001d00000000e8000
    ...           00007400000003a00000001d00000000e800000007400000003a00000001d00000000e800000007400000003a00000001d0000
    ...           0000e800000007400000003a00000001d00000000e800000007400000003a00000001d00000000a080000079d0000000000000
    ...           000000000000000000000000000000000000000000000010114421200055000200452a00
    Airphone Execute Egate Command    cmd=${command}

bearer stats check
    [Arguments]     ${ue_id}     ${direction}=dl
    ${command} =  catenate   SEPARATOR=
    ...    bearer_stats ue=${ue_id} dir=${direction} type=l3 scell=0 format=short size_unit=auto trf_id=1 pdu=1 qfi=2
    Airphone Execute Egate Command    cmd=${command}


Test case precondition
    [Arguments]  ${ap_version}     ${tag}
    Log To Console    ${tag}
    # OperatingSystem.Run    python sw_update_local.py -a ${ap_version}
     ${cmd}  Catenate  python /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/library/
     ...           airphone_worker/sw_update_local.py
     OperatingSystem.Run    ${cmd} -a ${ap_version}
     #Case Precondition For 8731    tag=${tag}


Case Precondition For 8731
    [Arguments]  ${tag}=8731
    log to console    Case Precondition
    #${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    #Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Download wireshark plugin
    Case Precondition   operation=env_setup_sa  tag=${tag}

TC67 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
	UE Deregister From gNB
    Multi UE ICS With Trace Stop   num=7
    Get Required Logs   stop_and_download   syslog   gnb
    #Delete NRSTRACEDU
    #Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=000001
    ...   capture_file_path=${local_file_path}
    #Check emil logs for sba tls
    #Check emil logs for mba
	Log Collection    start    snapshot    product_type=gnb    bts_index=${0}      timeout=${1200}

TC84 Teardown
    sleep   60s
#    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    @{para_list}      Create List    actPCMDReport
    @{mo_list}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    @{value_list}     Create List    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    UE Deregister From gNB
    Multi UE ICS With Trace Stop   num=7
    Get Required Logs   stop_and_download   syslog   gnb
    Delete NRSTRACEDU
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=000001
    ...   capture_file_path=${local_file_path}
    Check emil logs for sba tls
    Check emil logs for mba


UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${gw}=1  ${pass_regexp}=QoS Routing Table
    Log To Console    ${gnb_id}
    Log To Console    ${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id} nwslice=all    pass_regexp=UE now in NG RM Register
	sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal log_traffic_stats=off
	sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw}    pass_regexp=${pass_regexp}
	sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...       pass_regexp=${pass_regexp}


UE Deregister From gNB
    Airphone Execute Egate Command   cmd=ue_deregister id=1-106 ue_deregister_type=switch_off
    sleep   15s

Get Runtime SCF
   [Arguments]         ${gnb_index}=0
    ${connection}     _bts.login    product_type=gnb     gnb_index=${gnb_index}     alias=COAM
    ${BTS_scf_1}    Collect scf with timestamp   alias=${connection}   folder_path=${TEST_LOG_DIRECTORY}
    ...             export_type=configurationAndRuntimeObjects
    [Return]    ${BTS_scf_1}
	[Teardown]   Run Keyword And Ignore Error     coam.teardown    connection=${connection}

Collect scf with timestamp
    [Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs  ${export_type}=${None}
    ${time}=  Get Time
    ${scf_path}    Set Variable    ${folder_path}/scf_${time}.xml
    coam.get_current_scf_file  local_dir_path=${folder_path}  file_name=scf_${time}.xml
    ...    timeout=60  connection=${alias}  export_type=${export_type}
    [Return]  ${scf_path}


#      Add NRMTRACECU   json_file_name=NRMTRACECU-1.json
#      Add NRSTRACECU
#      Add NRMTRACECUUP   json_file_name=NRMTRACECUUP-1.json
#      Add NRSTRACECUUP
#      Add NRMTRACEDU   json_file_name=NRMTRACEDU-1.json
#      Delete NRMTRACECU
#      Delete NRSTRACECU
#      Delete NRMTRACECUUP
#      Delete NRSTRACECUUP
#      Delete NRMTRACEDU
