*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        RAN_5G        RAN_5G_TDD    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               5GC002498    Owner_jing.wang    CN2    SBTS00    team-SG2    release-5G21A    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107    7101    7305    1900

@{PARAMS_IN_SCF}
...    NRCELL:fPdcchMonOccsnPo=6

@{SA_set}
...    NRBTS-1/NRCELL-1:cellDepType=SA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    delete:NRBTS-1/NRCELL-1:configuredEpsTac
	
@{fault_7310}    fault_id=7310
@{fault_7704}    fault_id=7704
@{Fault_7506}    fault_id=7506 

${Fault_detail}    gNB CpRtCell configuration update failure  

@{SCTP_ORIGIN}
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoInit=3000
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMax=30000
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMin=250	

@{SCTP_MIN}
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoInit=200
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMax=240
...    NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMin=100	

*** Test Cases ***
5GC002498-ET-B001_Verify SCTP association re-establishment on E1 interface
    [Documentation]
    ...    [purpose]:
    ...        The purpose is to Verify SCTP association re-establishment on E1 interface,E1 Reset initiated by gNB-CU-CP in classical
    ...        and EDA for 03146805
    ...    [TL seting]: LO_AP_LO
    ...    [Test Case Steps]
    ...         a.Settings Cells type to sa
    ...         b. Check E1 link status is ok,then drop E1,and Check alarm
    ...         c.Recover E1 sctp and check alarm disappear
    ...         d.UE register and trigger NG reset 
    ...         e.Detach UE
    ...         f.Change sctp configuraiotn ,make sure this is default value.
    ...         g.attach UE and start traffic 
	...         h.update SCTP value
	...         i.attach UE2 and start traffic
	...         j.check UE1,UE traffic is noraml
	...         k.Check no 7506 alarm when sctp value change.
    ...    [Expected Results]:
    ...         b.UE attach successful
    ...         c.traffic >90%
    ...         d.sctp value change not impact attached UE work
    ...         e. No alarm 7506 raised
    [Tags]    B001    QC_46897
    Delta Commission Parameters    ${SA_set}
    Check E1 link status then drop E1 Sctp and check alarm
    Recover E1 Sctp and check alarm
    register UE then trigger NG reset
    Ue Deregister
    Delta Commission Parameters    ${SCTP_ORIGIN}
    sa ue attach successful and start traffic 
    Delta Commission Parameters    ${SCTP_MIN}
    sa ue attach successful and start traffic    2
    Verify SA DL and UL Traffic
    Verify SA DL and UL Traffic    2
    Check No Alarms For SCTP Link
	
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Check E1 link status then drop E1 Sctp and check alarm
    ${out}    Execute Command On Enb    cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep e1CLinkStatusCuCp
    Should Contain    ${out}    <p name="e1CLinkStatusCuCp">1</p>
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2 msg_type=abort    dropped
    Execute Command On Enb    iptables -A OUTPUT -p sctp --dport 38462 -j DROP
    Execute Command On Enb    ip6tables -A OUTPUT -p sctp --dport 38462 -j DROP
    Wait Until Keyword Succeeds    15 min    2 min    E1_Down
    Wait Until Keyword Succeeds    15 min    30 sec    check alarm 7310 and alarm 7704

E1_Down
    ${output}    Execute Command On Enb     cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep e1CLinkStatusCuCp
    Should Contain    ${output}    <p name="e1CLinkStatusCuCp">0</p>

E1_up
    ${output}    Execute Command On Enb    cat /ffs/run/config/NetworkPlanFileUpdate_*.xml | grep e1CLinkStatusCuCp
    Should Contain    ${output}    <p name="e1CLinkStatusCuCp">1</p>

check alarm 7310 and alarm 7704
    fm fault should be raised    ${fault_7310}
    fm fault should be raised    ${fault_7704}

Recover E1 Sctp and check alarm
    Execute Command On Enb     iptables -t filter -F OUTPUT
    Execute Command On Enb     ip6tables -t filter -F OUTPUT
    wait until keyword succeeds    15 min    1 min    E1_up
    sleep    3s
    wait until keyword succeeds    20 min    1 min    Cells Should Be Onair    check_sib=${True}
    wait until keyword succeeds    10 min    30 sec    check alarm 7310 and alarm 7704 disappear

check alarm 7310 and alarm 7704 disappear
    fm fault should be cleared    ${fault_7310}
    fm fault should be cleared    ${fault_7704}

register UE then trigger NG reset
    Execute Egate Command    ue_register id=1    NG RM Registered
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1    Established PDU session
    Execute Egate Command    link_ng_reset by=amf:1    NgLink::OnReceiveNgResetAcknowledge
    Check WireShark Log    ${CURDIR}${/}a2a_B_02${/}TA_B_02.ini    wait_string=ResetAcknowledge::5

Ue Deregister
    [Arguments]    ${id}=1
    Execute Egate Command    ue_deregister id=${id} ue_deregister_type=switch_off    detach

sa ue attach successful and start traffic
    [Arguments]    ${id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${id} pdu=${pdu} nwslice=${nwslice} gw=${id}    ${cmd_pdu_regexp}
    Execute Egate Command    trf_data_start ue=${id} pdu=${pdu} qfi=1 dir=dl mbps=10 trf_id=1
    ...    pass_regexp=UE ${id}: UDP DL
    Execute Egate Command    trf_data_start ue=${id} pdu=${pdu} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${id}: UDP UL

Verify SA DL and UL Traffic
    [Arguments]    ${id}=1    ${pdu}=1
    Builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${id}    pdu=${pdu}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${id}    pdu=${pdu}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9	

Check No Alarms For SCTP Link
    ${fault}    Create List    fault_id=${fault_7506}    fault_name=${Fault_detail}
    Fm Fault Should Be Cleared    ${fault}    60s
