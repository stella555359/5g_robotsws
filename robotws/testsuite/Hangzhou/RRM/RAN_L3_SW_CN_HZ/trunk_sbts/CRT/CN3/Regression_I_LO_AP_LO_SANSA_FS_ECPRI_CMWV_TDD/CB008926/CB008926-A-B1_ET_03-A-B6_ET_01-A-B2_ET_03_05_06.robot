*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG1    owner-xiujuan.sun    release-SBTS23R3
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri
${rdEnableTrafficManager}    0x89001C=0
${rdEnableUeIdRangeAllocationViaSdl}    0x89001D=0
${rdEnableUeMappingRemovalFromCpIf}    0x89001E=1
@{FAULTS_EXCLUDED_CHECKING}    6450
${nsaInactivityTimer7200s}    NRBTS:nsaInactivityTimer=7200
${cuUeIdToLinkMappingUpdateDelay500ms}    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms
@{PARAMS_IN_SWCONFIG}
#...    ${rdEnableTrafficManager}
#...    ${rdEnableUeIdRangeAllocationViaSdl}
#...    ${rdEnableUeMappingRemovalFromCpIf}
@{PARAMS_IN_SCF}    ${cuUeIdToLinkMappingUpdateDelay500ms}    ${nsaInactivityTimer7200s}

@{caseAB2_005DeltaParam}
...    NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:ipAddressAllocationMethod=MANUAL
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpAddr=10.0.1.20
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2:localIpPrefixLength=24
@{caseAB2_005_rollback}
...    NRBTS:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{Online_Param_Lock_X2}
...    NRBTS/LTEENB-0:x2LinkLock=locked
@{Online_Param_Unlock_X2}
...    NRBTS/LTEENB-0:x2LinkLock=unlocked

*** Test Cases ***
CB008926-SR-A-B2_ET_01_03_CPCL triggered partial reset via locking cell for SA and NSA UE in classical gNB
    [Tags]    AB2-003
    [Documentation]    Check F1 partial reset request shall be sent by vCU with Ueid of UE1 and UE2
    ${nsa_enb_x2apId}    ${nsa_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    ${sa_ueID}    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Set Test Variable    \${nsa_enb_x2apId}    ${nsa_enb_x2apId}
    Set Test Variable    \${nsa_gnb_x2apid}    ${nsa_gnb_x2apid}
    Set Test Variable    \${sa_ueID}    ${sa_ueID}
    Lock gNB Cell    1
    sleep    2s    wait for partial reset finished
    Unlock gNB Cell    1
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B2-03${/}a2a.ini    wait_string=procedureCode: id-Reset::4

CB008926-SR-A-B2_ET_01_05_CPIF triggered partial reset due to invalid NG-C ip address for SA UE in classical gNB
    [Tags]    AB2-005
    [Documentation]    Check F1 partial reset is initiated by CPUE and including UEIDs of UE1/UE2
    ${sa1_ueID}    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Set Test Variable    \${sa1_ueID}    ${sa1_ueID}
    Delta Commission Parameters    ${caseAB2_005DeltaParam}
    sleep    2s    wait for partial reset finished
    Delta Commission Parameters    ${caseAB2_005_rollback}
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B2-05${/}a2a.ini    wait_string=procedureCode: id-Reset::4

CB008926-SR-A-B2_ET_01_06_CPIF triggered partial reset via locking x2-c link for NSA UE in classical gNB
    [Tags]    AB2-006
    [Documentation]     CPUE shall initiated x2/F1/E1 partial reset for UE2.
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2    isPduSessionSetup=True
    ${nsa1_enb_x2apId}    ${nsa1_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    ${nsa2_enb_x2apId}    ${nsa2_gnb_x2apid}    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    Set Test Variable    \${nsa1_enb_x2apId}    ${nsa1_enb_x2apId}
    Set Test Variable    \${nsa1_gnb_x2apid}    ${nsa1_gnb_x2apid}
    Set Test Variable    \${nsa2_enb_x2apId}    ${nsa2_enb_x2apId}
    Set Test Variable    \${nsa2_gnb_x2apid}    ${nsa2_gnb_x2apid}
    Lock x2-c link
    unLock X2-c link
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B2-06${/}a2a.ini    wait_string=procedureCode: id-Reset::10

CB008926-SR-A-B6_ET_01_01_partial reset due to CPUE faliure in classical gNB
    [Tags]    AB6-001
    [Documentation]    This user scenario describes the gNB behavior of CP-UE Recovery.
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=5    isPduSessionSetup=True
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=33    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=34    target_gnbCell=1
    Kill LXC container for CPUE1
    sleep    2s    wait for CPUE recovery successfully
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B6-01${/}a2a.ini    wait_string=procedureCode: id-endcPartialReset::4

CB008926-SR-A-B1_ET_01_03_F1 partial reset is triggered for SA and NSA Ues due to L2NRT pool failure in classical gNB
    [Tags]    AB1-003
    [Documentation]    when kill UPUE-1 where SA and NSA in, the F1 partial reset will be triggered and bulk common release will be started.
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3    isPduSessionSetup=True
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=3    ue_id_end_before=4    isPduSessionSetup=True
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA UE ICS and setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=2
    Kill LXC container for UPUE1
    sleep    3s    Check F1/E1 partial reset shall be initiated for UEs
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_A-B1-03${/}a2a.ini    wait_string=procedureCode: id-NGReset::2

*** Keywords ***
Kill LXC container for UPUE1
    Execute Cmd On Gnb    ps -ef|grep /UPUENODE_ABINO|grep -i lxc-start    fsp1
    ${processIdList}    Execute Cmd On Gnb    ps -ef|grep /UPUENODE_ABINO|grep -i lxc-start |awk '{print \$2}'    fsp1
    Execute Cmd On Gnb    kill -9 ${processIdList.split('\n')}[0]    fsp1
    Execute Cmd On Gnb    kill -9 ${processIdList.split('\n')}[1]    fsp1

Lock gNB Cell
    [Arguments]    ${cell_id}=1
    Delta Commission Parameters    NRCELL-${cell_id}:administrativeState=Locked

Unlock gNB Cell
    [Arguments]    ${cell_id}=1
    Delta Commission Parameters    NRCELL-${cell_id}:administrativeState=Unlocked
    wait cell has sib Message    cell_id=${cell_id}

wait cell has sib Message
    [Arguments]    ${cell_id}=3
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=${cell_id}

check cell has sib Message
    [Arguments]    ${cell_id}=3
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    Should Match Regexp    ${ret}    SIB1.*?yes

Lock x2-c link
    delta commission parameters    ${Online_Param_Lock_X2}

UnLock X2-c link
    delta commission parameters    ${Online_Param_Unlock_X2}
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up    timeout=120

Kill LXC container for CPUE1
    Execute Cmd On Gnb    ps -ef|grep /CPUENODE|grep -i lxc-start    fsp1
    ${processIdList}    Execute Cmd On Gnb    ps -ef|grep /CPUENODE|grep -i lxc-start |awk '{print \$2}'    fsp1
    Execute Cmd On Gnb    kill -9 ${processIdList.split('\n')}[0]    fsp1

Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    [Return]    ${sa_ueID}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}    location
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    ${sa_ueID}    UE Register To GNB    ${ue_id}

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}    ${isPduSessionSetup}=True
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
        UE PDU Session Setup    ${ue_id}    ${ue_id}
    END

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [Return]    ${sa_ueID}
    ${sa_ueID}    Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}

UE Register To GNB
    [Arguments]    ${ue_id}
    [Return]    ${ngapID}[0]
    ${output}    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    ${ngapID}    Get Regexp Matches    ${output}    Starting Authentication Procedure for UE with RAN UE NGAP ID (\\d+)    1

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

NSA UE ICS and setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    [Return]    ${MeNB_x2apIDList[0]}    ${sgNB_x2apIDList[0]}
    UE Attach To ENB    ${ue_id}
    ${output}    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=SgNBAdditionRequestAcknowledge
    ${MeNB_x2apIDList}    Get Regexp Matches    ${output}    value UE-X2AP-ID : (\\d+)    1
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

UE Attach To ENB
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
