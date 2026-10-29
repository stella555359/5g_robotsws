*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...    owner-ha.zheng    team-CN1ET    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_IPHY_XML}
...    GeneralSettings:l3Timeout=30

@{PARAMS_IN_SCF}
...    @{osimismatch}
...    @{prach}

@{osimismatch}
...    NRCELL:actOsiMismatchCheck=true

@{prach}
...    NRCELL:prachConfigurationIndex=175
...    delete:NRCELL:ranAC
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{pass_regexp}
...    Setup QosFlow with QFI:2 5QI:9
...    UE-1 PDU SESSION ID-1 setup
...    UE-1 PDU SESSION ID-2 setup

@{OnlineParam_A015_1}
...    delete:NRSYSINFO_PROFILE-1/NRIAFIM-1
...    delete:NRSYSINFO_PROFILE-1/NRLIM-1

@{cell_lock}
...    NRCELL-1:administrativeState=Locked
...    NRCELL-5:administrativeState=Locked

@{cell_unlock}
...    NRCELL-1:administrativeState=Unlocked
...    NRCELL-5:administrativeState=Unlocked

@{OnlineParam_A015_2}
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:deriveSsbIndexFromCell=true
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=1 beam
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:qRxLevMin=-56
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:sIntraSearchP=22
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:tReselectionNr=1
...    NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw100
...    NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=40890
...    NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeight=100
...    NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeightEnDc=100
...    NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=23
...    NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=false
...    NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-34
...    NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-22
...    NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=30
...    NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=30

${additional_info_7516}
...    Mismatch of System Information SIB Type (SIB3/SIB4/SIB5) between the received one from
...    gNB-CU (NRIAFIM/NRIRFIM/NRLIM) and the configured one at gNB-DU (sibSchedulingList.sibType)

*** Test Cases ***
CB008285-ET-A006_FR2_SA_Call_with_1SSB_rrc_idle_to_connected_with_multi_PDU_sessions_and_multi_qos_flows
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs which contain FR2 SA Cells.
    ...       These two CELLGROUPs are configured on two Radio Units.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...        b. add 2nd qos flow
    ...        c. add 2nd pdu session
    ...        d. make ue idle
    ...        e. ue exit idle mode
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step b: 2nd qos flow add successfully, tput noraml.
    ...        Step c: 2nd pdu session add successfully, tput noraml.
    ...        Step d: ue idle.
    ...        Step e: ue active and all qos flows and all pdu sessions add successfully.
    [Tags]    QC_300524    A006    LABEL-8T(8*100MHz_TDD_n257)
    UE Attach To Target Cell Then Send And Verify Throughput
    Add 2nd Qos Flow
    Add 2nd Pdu Session
    UE Enter To IDLE
    UE Exit IDLE
    Release Ues    ue_type=all

CB008285-ET-A009_FR2_SA_Cells_with_1SSB_and_2cellgroup_with_4cells_each_other
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with two CELLGROUPs which contain FR2 SA Cells.
    ...       These two CELLGROUPs are configured on two Radio Units.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    2.Test Case Steps:
    ...        a. UE1 Register And PDU Session Setup On pcell cell1
    ...        b. UE2 Register On scell cell2
    ...        c. UE3 Register And PDU Session Setup On pcell cell5
    ...        d. UE4 Register On scell cell6
    ...    3. Expected Results:
    ...        Step a: UE1 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step b: UE2 Register failed.
    ...        Step c: UE3 Register And PDU Session Setup Successfully, tput noraml.
    ...        Step d: UE4 Register failed.
    [Tags]    QC_300520    A009    LABEL-8T(8*100MHz_TDD_n257)
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    UE Attach To Target Cell failed    ue_id=2    cell_id=2
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=3    cell_id=5    pdu_id=2
    UE Attach To Target Cell failed    ue_id=4    cell_id=6
    Release Ues    ue_type=all

CB008285-ET-A015_FR2_SA_Cells_with_1SSB_and_mismatch_SIB4_SIB5_via_sibSchedulingList_at_gNB-DU
    [Documentation]
    ...    1. This user scenario describes the case when the OSI configuration is mismatched between gNB-DU and gNB-CU.
    ...       gNB-DU shall raise a Fault for such case.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    2.Test Case Steps:
    ...        a. online delete NRIAFIM-1 and NRLIM-1
    ...        b. UE1 Register On pcell cell1
    ...        c. online add NRIAFIM-1 and NRLIM-1, then lock unlock cells
    ...        d. UE2 Register On pcell cell5
    ...    3. Expected Results:
    ...        Step a: fault 7516 report on Pcells cell1 and cell5
    ...        Step b: UE1 Register successfully.
    ...        Step c: fault 7516 cleared on Pcells cell1 and cell5
    ...        Step d: UE2 Register successfully.
    [Tags]    QC_300514    A015    LABEL-8T(8*100MHz_TDD_n257)
    OnlineParamChange    ${OnlineParam_A015_1}
    Check fault 7516 and alarm 7114    alarming_object=NRCELL-1
    Check fault 7516 and alarm 7114    alarming_object=NRCELL-5
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=1    cell_id=1    pdu_id=1
    OnlineParamChange    ${OnlineParam_A015_2}
    Check fault 7516 and alarm 7114 cleared    alarming_object=NRCELL-1
    Check fault 7516 and alarm 7114 cleared    alarming_object=NRCELL-5
    UE Attach To Target Cell Then Send And Verify Throughput    ue_id=2    cell_id=5    pdu_id=2
    Release Ues    ue_type=all
    [Teardown]    A015_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param1}
    Delta Commission Parameters    ${Online_Param1}
    Delta Commission Parameters    ${cell_lock}
    Delta Commission Parameters    ${cell_unlock}
    Cells Should Be Onair    cell_id=1
    Cells Should Be Onair    cell_id=5

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all qos_flows=1,2 qos_rules=1,2 amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all qos_flows=1,2 qos_rules=1,2 amf=1

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1
    ...    pass_regexp=QoS Routing Table    timeout=10s
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}

UE Attach To Target Cell failed
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ${ret}=    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=MIB or SIB1 not recieved
    Should Not Contain    ${ret}    UE now in NG RM Register

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=150 trf_id=1    UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=550    ${pcell_tput_except_ul}=130    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}

Add 2nd Qos Flow
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    Added QosFlow with QFI:2 fiveQI:9
    Verify Throuput on Pcell    ue_id=${ue_id}

Add 2nd Pdu Session
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_setup pdu=2 gw=2 ue=${ue_id}
    ...    PDU SESSION ID-2 setup
    Verify Throuput on Pcell    ue_id=${ue_id}

UE Enter To IDLE
    [Arguments]    ${ue_id}=1
    execute egate command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release    pass_regexp=UE1: IS IDLE

UE Exit IDLE
    [Arguments]    ${ue_id}=1
    execute egate command    ue_im_exit id=${ue_id}    pass_regexp=${pass_regexp}

Check fault 7516 and alarm 7114
    [Arguments]    ${fault_id}=7516    ${alarm_id}=7114    ${severity}=Major
    ...    ${fault_name}=Incorrect cell parameter configuration
    ...    ${alarming_object}=NRCELL-1    ${supplAlarmInfo}=${additional_info_7516}
    ${fault7516_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    fault_name=${fault_name}    alarming_object=${alarming_object}    supplAlarmInfo=${supplAlarmInfo}
    Fm Fault Should Be Raised    ${fault7516_alarm7114}    timeout=40

Check fault 7516 and alarm 7114 cleared
    [Arguments]    ${fault_id}=7516    ${alarm_id}=7114    ${severity}=Major
    ...    ${fault_name}=Incorrect cell parameter configuration
    ...    ${alarming_object}=NRCELL-1
    ${fault7516_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    fault_name=${fault_name}    alarming_object=${alarming_object}
    Fm Fault Should Be Cleared    ${fault7516_alarm7114}    timeout=40

A015_Teardown
    OnlineParamChange    ${OnlineParam_A015_2}
    Common Test Teardown And Stop Capture Logs
