*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        RAN_5G    RAN_5G_TDD    CRT    QCD_MN_RAN    QCP_RAN_ET
...               5GC002498    Owner_Junhui.He    CN2    SBTS00   team-DevHZ5_SG2    release-5G21A
...               CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{SA_set}    NRBTS-1/NRCELL-1:cellDepType=SA    delete:NRBTS-1/NRCELL-1:configuredEpsTac
@{fault_7504}    fault_id=7504
@{fault_7303}    fault_id=7303
${ue_id}    1
@{FAULTS_EXCLUDED_CHECKING}
...    7300
...    7100
...    7523
...    7107

*** Test Cases ***
5GC002498-ET-A002_5GC000481_C_4301_New F1 setup after SCTP recovery
    [Tags]    QC_61173    A002
    Delta Commission Parameters    ${SA_set}
    Check F1 link status then drop F1 Sctp and check alarm
    Recover F1 Sctp and check alarm
	Analysis capture wiresharklog_A001_F1Setup

5GC002498-ET-A001_5GC000481_AB_01_F1AP Setup Succeed
    [Tags]    QC_61172    A001
	BuiltIn.log    A001 is covered by A002......    console=${True}	
    #run    unzip -n ${TEST_LOG_DIR}/../5GC002498_ET_A002_5GC000481_C_4301_New_F1_setup_af.zip -d ${TEST_LOG_DIR}
    #run    cp ${TEST_LOG_DIR}/5GC002498_ET_A002_5GC000481_C_4301_New_F1_setup_af/wireshark_F1Setup.txt ${TEST_LOG_DIR}/
    #Analysis capture wiresharklog_A001_F1Setup

5GC002498-ET-A003_Verified F1 reset trigger Ng reset
    [Tags]    QC_61174    A003
    start tcpdump and register UE then lock cell
    stop tcpdump and verify F1 Creset trigger Ng reset
    Unlock Cell1

5GC002498-ET-A005_Verified Ng reset trigger f1 reset
    [Tags]    QC_61176    A005
    Start tcpdump and register UE then trigger NG reset
    Stop tcpdump and verify NG reset trigger F1 reset

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check F1 link status then drop F1 Sctp and check alarm
    ${out}    Execute Command On Enb    cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep f1CLinkStatusCU
    Should Contain    ${out}    <p name="f1CLinkStatusCU">1</p>
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort    dropped
    Execute Command On Enb    iptables -A OUTPUT -p sctp --dport 38472 -j DROP
    Execute Command On Enb    ip6tables -A OUTPUT -p sctp --dport 38472 -j DROP
    Wait Until Keyword Succeeds    15 min    2 min    F1_down
    Wait Until Keyword Succeeds    15 min    30 sec    check alarm 7303 and alarm 7504
    Start To Capture Wireshark Log    F1Setup

Recover F1 Sctp and check alarm
    Execute Command On Enb     iptables -t filter -F OUTPUT
    Execute Command On Enb     ip6tables -t filter -F OUTPUT
    wait until keyword succeeds    15 min    1 min    F1_up
    sleep    300s    #wait for cells to be onair
    wait until keyword succeeds    20 min    1 min    Cells Should Be Onair    check_sib=${False}
    wait until keyword succeeds    10 min    30 sec    check alarm 7303 and alarm 7504 disappear
    #Stop Capture Wireshark Log    F1Setup

F1_down
    ${output}    Execute Command On Enb     cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep f1CLinkStatusCU
    Should Contain    ${output}    <p name="f1CLinkStatusCU">0</p>

F1_up
    ${output}    Execute Command On Enb    cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep f1CLinkStatusCU
    Should Contain    ${output}    <p name="f1CLinkStatusCU">1</p>

Analysis capture wiresharklog_A001_F1Setup
    sleep    5s    #sleep for capture wireshark
    Check WireShark Log    ${CURDIR}${/}a2a_TA01${/}TA01.ini    name=F1Setup    wait_string=UEContextReleaseComplete::1

check alarm 7303 and alarm 7504
    fm fault should be raised    ${fault_7303}
    fm fault should be raised    ${fault_7504}

check alarm 7303 and alarm 7504 disappear
    fm fault should be cleared    ${fault_7303}
    fm fault should be cleared    ${fault_7504}

Start tcpdump and register UE then lock cell
    Start To Capture Wireshark Log     F1Reset
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Established PDU session
    ...    timeout=20s
    Lock Cell1

Stop tcpdump and verify F1 Creset trigger Ng reset
    #Stop Capture Wireshark Log    F1Reset
    Check WireShark Log    ${CURDIR}${/}a2a_TA03${/}TA03.ini    name=F1Reset    wait_string=UEContextReleaseComplete::1

Start tcpdump and register UE then trigger NG reset
    Start To Capture Wireshark Log     NgReset
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state    timeout=20s
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Established PDU session    timeout=20s
    Execute Egate Command    link_ng_reset by=amf:1    Received NG Reset Acknowledge    timeout=20s

Stop tcpdump and verify NG reset trigger F1 reset
    sleep    10s    #sleep for capture wireshark
    #Stop Capture Wireshark Log    NgReset
    Check WireShark Log    ${CURDIR}${/}a2a_TA05${/}TA05.ini    name=NgReset    wait_string=UEContextReleaseComplete::1
