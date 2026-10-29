*** Settings ***
Documentation
...               Feature ID: CB008957_CB007814
Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
Test Setup    Run Keywords    Prepare environment
Test Teardown     Run Keywords    Restore environment
Force Tags        CIT    FL00    QCD_MN_RAN    QCP_RAN_VRF
Resource    testsuite/Bangalore/ORAN/T08/CIT/resources/Common_resource.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource    CB007814_PVAcase.robot
Library    taf.hw.pdu   WITH NAME    PDU


*** Variables ***

@{data_transfer_protocol}    TCP    # Default data transfer type
${ip_pdu}=    10.53.252.19
${VM_IP}=     10.41.209.152
${BTS_ADDRESS}=    192.168.255.129
${ssh_username}=    toor4nsn
${ssh_password}=    oZPS0POrRieRtu
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/CIT/resources/config/swconfig.txt

*** Test Cases ***
CB008957_Verification_of_UL_and_DL_data_transfer_together_with_Single_UE
    Log        TC1 Verification_of_TCP_UL_DL_single_ue_LTE
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1      miRxWindowStats     5min
    Log     Locking NR cell for LTE calls
	COAM.lock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
	Sleep   60s
    Run keyword and Continue on failure     LTE_DL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     LTE_UL_UDP_call_with_throughtput_verification
    Log     TC-2 Counter Verification
    Run keyword and Continue on failure     RU_Counter_Value_update
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1      miRxWindowStats     disabled
	Log     Unlock NR Cells after TC execution
	COAM.unlock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
    Sleep   60s

CB008957_Verification_of_TCP_call_after_ORU_disconnection_ORU_lock_unlock
    Log     TC-3 ORU LOCK/Unlock, Reset
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1		miTrRxWindowStats	5min
	Parameter value change    MRBTS-1223/EQM-1/APEQM-1/RMOD-1      administrativeState     Locked
    Sleep   60s
    Parameter value change    MRBTS-1223/EQM-1/APEQM-1/RMOD-1      administrativeState     Unlocked
    Log     Locking NR cell for LTE calls
    COAM.lock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
    Run keyword and Continue on failure     LTE_DL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     LTE_UL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     TR_Counter_Value_update
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1		miTrRxWindowStats	disabled
	Log     Unlock NR cells after TC execution
	COAM.unlock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
    Sleep    60s
    Reset_all_rmods
	Sleep   100s

CB008957_Verification_of_TCP_UL_DL_single_ue_NR
    Log        TC1 Verification_of_TCP_UL_DL_single_ue_NR
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1      miRxWindowStats     5min
    COAM.lock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}
	Sleep   100s
    Run keyword and Continue on failure     NR_DL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     NR_UL_UDP_call_with_throughtput_verification
    Log     TC-2 Counter Verification
    Run keyword and Continue on failure     RU_OT_Counter_Value_update
    Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1      miRxWindowStats     disabled
    COAM.unlock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}

CB008957_Verification_of_TCP_Calls_after_ORU_disconnect_Lock_Unlock
	Log     TC-3 ORU Disconnect/Reconnect
    Perform_ORU_Disconnect_Reconnect_operation
	Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1     miTrRxWindowStats   5min
    COAM.lock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}
    Run keyword and Continue on failure     NR_DL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     NR_UL_UDP_call_with_throughtput_verification
    Run keyword and Continue on failure     TR_Counter_Value_update
    Parameter value change    MRBTS-1223/MNL-1/MNLENT-1/PMMNL-1     miTrRxWindowStats   disabled
	COAM.unlock    dist_name=MRBTS-1223/LNBTS-1223/LNCEL-0    timeout=300    connection=${connection}
	Sleep   100s

CB007814_5GC002139_Verify_TCP_UDP_DL_UL_tput_with_Closed_loop
	Verify_TCP_UDP_DL_UL_tput_with_Closed_loop

*** Keywords ***

LTE_DL_UDP_call_with_throughtput_verification
    Log to console    \n--DL_UDP call initiation and throughtput verification--\n
    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_dl}
    ...    ${throughput_dl_LTE}    ${deviation_dl}    ${timeout}     check_tpt=True    check_gnb_attach=False

LTE_UL_UDP_call_with_throughtput_verification
    Log to console    \n--UL_UDP call initiation and throughtput verification--\n
    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_ul}
    ...    ${throughput_ul_LTE}    ${deviation_ul}    ${timeout}     check_tpt=True    check_gnb_attach=False

NR_DL_UDP_call_with_throughtput_verification
    Log to console    \n--DL_UDP call initiation and throughtput verification--\n
    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_dl}
    ...    ${throughput_dl}    ${deviation_dl}    ${timeout}     check_tpt=True    check_gnb_attach=False

NR_UL_UDP_call_with_throughtput_verification
    Log to console    \n--UL_UDP call initiation and throughtput verification--\n
    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_ul}
    ...    ${throughput_ul}    ${deviation_ul}    ${timeout}     check_tpt=True    check_gnb_attach=False

Reset_all_rmods
    ${RMODS}    COAM.get_ids_for_all    RMOD    timeout=30s    connection=${connection}
    Log to console    \n--Resetting RMOD--\n
    FOR    ${RMOD}    IN    @{RMODS}
        COAM.reset_unit    dist_name=${RMOD}    reset_type=Soft    timeout=300s    connection=${connection}
    END
    Log to console    \n--Wait for gNB to be on Air --\n
    Wait for BTS OnAir
    Log     Locking NR cell for LTE calls
    COAM.lock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
    Run Keyword And Continue On Failure     Attach ue and run throughput
    ...     ${UE_alias}    ${capabilities}    ${direction_dl}
    ...    ${throughput_dl_LTE}    ${deviation_dl}    ${timeout}    check_tpt=True    check_gnb_attach=False
    Log     Unlock NR cells after TC execution
    COAM.unlock    dist_name=MRBTS-1223/NRBTS-1223/NRCELL-1    timeout=300    connection=${connection}
    Sleep    60s

Copy swconfig to BTS
    [Documentation]		copy swconfig file to BTS
    [Arguments]         ${swconfig_path}
    ${swconfig_source}=		Set Variable     ${swconfig_path}
    set global variable		${swconfig_source}
    SSHLibrary.Open Connection    host=${BTS_ADDRESS}
    SSHLibrary.Login    ${ssh_username}    password=${ssh_password}    delay=10
    SSHLibrary.Put File
	...     source=${swconfig_source}
	...     destination=/ffs/run    scp=scp
    SSHLibrary.Close All Connections

Perform_ORU_Disconnect_Reconnect_operation
    COAM.setup_admin    bts_host=192.168.255.129
    PDU.Setup_pdu    model=RRB    host=${ip_pdu}    alias=RRB_connection
    PDU.power_off    port=1    pdu_device=RRB_connection
    Sleep   60
    PDU.Setup_pdu    model=RRB    host=${ip_pdu}   alias=RRB_connection
    PDU.power_on    port=1    pdu_device=RRB_connection
    sleep    540
    ${mrbts_state}=    COAM.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}.

RU_Counter_Value_update
    ${count_1}      Counter value RURWS       M55604C00001
    ${count_2}      Counter value RURWS       M55604C00002
    ${count_3}      Counter value RURWS       M55604C00003
    ${count_4}      Counter value RURWS       M55604C00004
    ${count_5}      Counter value RURWS       M55604C00006

TR_Counter_Value_update
    ${count_1}      Counter value TRRWS       M55605C00001
    ${count_2}      Counter value TRRWS       M55605C00002
    ${count_3}      Counter value TRRWS       M55605C00003
    ${count_4}      Counter value TRRWS       M55605C00004
    ${count_6}      Counter value TRRWS       M55605C00006

RU_OT_Counter_Value_update
    ${count_1}      Counter value RURWS       M55604C00001
    ${count_2}      Counter value RURWS       M55604C00002
    ${count_3}      Counter value RURWS       M55604C00003
	${count_4}      Counter value RURWS       M55604C00004
	${count_6}      Counter value RURWS       M55604C00006
	RU_OT_Counter_Value_update_M400

RU_OT_Counter_Value_update_M400
    ${count_1}      Counter value OTRST       M40027C1
    ${count_2}      Counter value OTRST       M40027C2
    ${count_3}      Counter value OTRST       M40027C3
    ${count_4}      Counter value OTRST       M40027C4
    ${count_5}      Counter value OTRST       M40027C5
