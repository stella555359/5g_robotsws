*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    120 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot

*** Variables ***
${UE_Capa_Support_CAaware}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C07010A8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027
...    800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D5400001400000A8D805AC10143400000060
...    07800F5B00000000000000000000000000000D55554D5555404F0F1340038500000002C040BC3C02000E0D8000010B0102006026C00219000078081448014080
...    0FFFFFFF86C0038003C1C1401C0C026007000683E008000000000000000200F2A6B0300020800004B2CA82000020000000E95555030068007000B00008404008
...    010100200420200801008020043562600020406080A0C0E10162022242632424A4C4E50940A510000210
${MRBTS_ID}   1
${NRBTS_ID}   1

*** Test Cases ***
Case Precondition
    Case Precondition For CB008225

[TC45]CB012629-SR-A-B201_45_Successful_TRS_Stop_UE_Inactivity
    [Tags]    QC_25214       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario validates that BTS Trace Controller successfully cleares intenal resources during
    ...       resource deregistration
    ...       User scenario B201 #4
    ...       5G_RAN_USR_COM_22979
    ...    2. Preconditions :
    ...       gNB is up and running in FDD/TDD mode
    ...       Trace Session shall be able to trace SA UEs
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       TCE is DCAP, Trace Expert, 3rd party tool
    ...       TCE is configured under MNL.TCEADM.TCE MOC
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       The feature flag:
    ...       NRBTS.actPCMDReport is set to true
    ...       NRBTS.actSubscriberTraceReport is set to true
    ...       NRBTS.NRCTRLTS.NRMTRACECU configured with following parameters:
    ...       TceId is set
    ...       actPCMDReporting is set to true
    ...       NRBTS.NRDU.NRCTRLTSDU.NRSTRACEDU configured with following parameters:
    ...       actPCMDReporting is set to true
    ...       defaultNrTceIdentifier points to configured MNL.TCEADM.TCE
    ...       nrTcePortNumber is set
    ...       tlsEnabled set to false
    ...       applyDefNrTceForAllSessions set to false
    ...       maxBufferingTime configured within its allowed range
    ...    3. Test Case Steps:
    ...       step1. UE is configured in Core Simulator to support SBA.
    ...       step2. Attach UE and wait till UE enter inactivate state.
    ...       step3: Check tcpdump log and Emil log.
    ...    4. Expert Result:
    ...       a.  gNB-DU trace sessions are unaffected
    ...       b.  Stop Recording Session(s) were indicated to TCE
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Add or Delete A New MOC   moc_jason=NRSTRACEDU-1.json
    Activate or Deactivate Trace Report   actPCMDReport=true   actSubscriberTraceReport=true
    Get Required Logs   start  syslog   gnb
    Get Required Logs   start  wireshark   gnb
    Trigger ICS With Trace Start    ue_id=6  trace_ref_id=6  trace_rec_session_ref_id=6  trace_depth=maximum
    Update UE capa    ue_id=6     SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
    UE Register And PDU Session Setup    ue_id=6    pass_regexp=${releasePreference_check}
    Start data traffic in egate   ue_id=6
    Stop data traffic in egate   ue_id=6    pass_regexp=${inactive_check}
    [Teardown]    TC45 Teardown



*** Keywords ***
TC45 Teardown
    sleep  60s
    ${local_file_path}   Get Required Logs   stop_and_download   wireshark   gnb
    UE Deregister From gNB      ue_id=6
    Trigger ICS With Trace Stop   ue_id=6
    Check multi tracerecords   tracerecords=${ducp_duup_tracerecords}  host=mba  traceId=000001
    ...   capture_file_path=${local_file_path}
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=mba
    Check common tracerecords by host   tracerecords=${stop_sesstion}   capture_file_path=${local_file_path}  host=sba
    Check common tracerecords  tracerecords=${alive}   capture_file_path=${local_file_path}
    Get Required Logs   stop_and_download   syslog   gnb
    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}   timeout=${1200}
    Delete NRSTRACEDU

