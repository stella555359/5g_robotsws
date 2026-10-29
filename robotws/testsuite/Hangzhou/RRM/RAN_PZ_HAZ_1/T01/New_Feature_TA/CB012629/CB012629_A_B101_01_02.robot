*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB012629

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot




*** Test Cases ***
[1][1.0] WTS Precondition
         Case Precondition for ST   product_type=gnb

[TC01]CB012629_SR_A_B101_1_Successful_PCMD_SBA_trace_activation_applyDefNrTceForAllSessions_True_without_TLS_IsAlive
    [Tags]    QC_16472       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new connection to TCE for gNB-DU
    ...       SBA trace session.
    ...       5G_RAN_USR_COM_22975
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to true
    ...       No MBA based PCMD is configured.
    ...       No active UEs are present.
    ...    3. Test Case Steps:
    ...       Reset gNB and monitor the tcpdump log in BTS startup.
    ...    4. Expert Result:
    ...       gNB-DU SBA Trace Session is active
    ...       TCC opens a connection for activated SBA trace session and NSETAP-X: TraceMessage.Configure message was present
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    ...       No PCMD content is present
    Delete NRMTRACEDU
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_14}
    Reset Site
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    wait until keyword succeeds    5 min    30 sec    BTS Operation  verify   verify_status=CELL_ONAIR   timeout=360s
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    [Teardown]  TC01 Teardown

[TC02]CB012629-SR-A-B101_2_Successful_PCMD_SBA_trace_activation_applyDefNrTceForAllSessions_False_without_TLS_IsAlive
    [Tags]    QC_16473       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller configures and starts new connection to TCE for gNB-DU
    ...       SBA trace session.
    ...       5G_RAN_USR_COM_22975
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...       The feature flag NRBTS-actPCMDReport is set to true.
    ...       The feature flag NRBTS-actSubscriberTraceReport is set to true.
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       No MBA based PCMD is configured.
    ...       No active UEs are present.
    ...    3. Test Case Steps:
    ...       Reset gNB and monitor the tcpdump log in BTS startup.
    ...    4. Expert Result:
    ...       gNB-DU SBA Trace Session is active
    ...       TCC opens a connection for activated SBA trace session and NSETAP-X: TraceMessage.Configure message was present
    ...       TCC sends NSETAP-X: TraceMessage.isAlive notifications to TCE periodically
    ...       No PCMD content is present
    Delete NRMTRACEDU
    Add NRSTRACEDU  param_dict=${NRSTRACEDU_param_dict_4}
    Reset Site
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    wait until keyword succeeds    5 min    30 sec    BTS Operation  verify   verify_status=CELL_ONAIR   timeout=360s
    ${log_collection_end_time_sba}    ${dcap_alias_sba}    Get dcap collection time for current time
      ...   dcap_server=${dcap_server_sba}    host=${sba_host}
    Set Test Variable  ${log_collection_end_time_sba}
    Set Test Variable  ${dcap_alias_sba}
    [Teardown]  TC02 Teardown

Case Postcondtion
    Case Postcondition for ST

*** Keywords ***
TC01 Teardown
    sleep  60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Check common tracerecords  tracerecords=${traceMessage_configure}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${alive}   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_session_alive_tracerecords}
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Add NRMTRACEDU
    Delete NRSTRACEDU


TC02 Teardown
    sleep   60s
    ${local_file_path}    Get Required Logs   stop_and_download   wireshark   gnb
    Get Required Logs   stop_and_download   syslog   gnb
    Check common tracerecords  tracerecords=${traceMessage_configure}   capture_file_path=${local_file_path}
    Check common tracerecords  tracerecords=${alive}   capture_file_path=${local_file_path}
    Check emil logs for sba   tracerecords=${emil_session_alive_tracerecords}
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Add NRMTRACEDU
    Delete NRSTRACEDU