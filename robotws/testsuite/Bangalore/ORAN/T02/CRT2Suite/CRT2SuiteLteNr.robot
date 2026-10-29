*** Settings ***

Documentation
...    Test Description: CRT test cases to test ORAN testline
...    Sample execution: robot -d /home/ute/logs/ -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG01/CB010916/general.robot

Library     ./testsuite/Bangalore/ORAN/T02/CRT2Suite/CB008796.py
Library     ./testsuite/Bangalore/ORAN/T02/CRT2Suite/UpdateCellSOParameters.py
Library     taf.hw.pdu     WITH NAME   pdu
Library     ute_fsmaccess
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.hw.rf_attenuator.rf_attenuator  WITH NAME  at
Library     String
Library     SSHLibrary
Library     taf.config.scf   WITH NAME    scf
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     ta5g_pm_counters
Library     taf.sw.scout    WITH NAME    scout
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Resource    ./testsuite/Bangalore/ORAN/T02/CRT2Suite/CRT2Variables.robot
Resource    ./testsuite/Bangalore/ORAN/T02/CRT2Suite/KeywordsCRT2.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/SetupReadinessWithIntelligentSoftwareUpdate.robot
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource     ./testsuite/Bangalore/ORAN/resources/robot/OperationKeywords.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
Library     ./testsuite/Bangalore/ORAN/resources/python/SysValidation.py
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.file.pack
Library     taf.collectors.pmcounters    WITH NAME    PM
Library     taf.analyzer.pmcounter    WITH NAME    analyser
Resource    ./testsuite/Bangalore/ORAN/resources/robot/common_admin.robot
Resource    ./testsuite/Bangalore/ORAN/T02/resources/robot/CommonKeywordResourceFile.robot
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Library     testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Library     ./testsuite/Bangalore/ORAN/resources/python/downloadwftpackage.py
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library     Process
Library     taf.transport.ssh
Library     ute_ue
Library     Collections
Library     taf.nms.netact        WITH NAME    netact
Library     DateTime
Library     taf.collectors.core    WITH NAME    core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     OperatingSystem     WITH NAME    os
Library     taf.sw.dcap.rd		WITH NAME	  dcap
Library     taf.collectors.simple    WITH NAME    simple
Library     taf.ue  WITH NAME  ue
Library    taf.converters.emil    WITH NAME    emil
Library    taf.converters.ttitracer    WITH NAME    ttitracer
Library        ./testsuite/Bangalore/ORAN/resources/python/tti_trace_validation/
Library     ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Suite Setup    Run Keywords
...    UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    KeywordsCRT2.Suite Setup
Suite Teardown     KeywordsCRT2.Suite Teardown
Test Setup         KeywordsCRT2.Test Setup
Test Teardown      KeywordsCRT2.Test Teardown
Force Tags         CA_VRF_BLR1    SBTS00    SBTS25R3    QCD_MN_RAN   QCP_RAN_VRF

*** Test Cases ***

[1]CB007795-B_Verification of Cell setup procedure with O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    7795    singlerun    26R2
    #Wait Until Keyword Succeeds     15m    10s    PerformRecommissioning    ${master_scf_with_AWHQN}
    #Wait Until Keyword Succeeds   15min    10s    Check_BTS_State
    setup_pdu     model=RRB    host=${FJT_ippdu_ip}    alias=RRB_ippdu
    pdu.power_off    port=${FJT_ippdu_port}    pdu_device=RRB_ippdu
    sleep    30s
    SiteReset
    Run Keyword And Continue On Failure    KeywordsCRT2.Software update via Netact
    Wait Until Keyword Succeeds     8m    10s    Check_BTS_State
    OperationKeywords.Perform Parameter Recommissioning    ${distname_pmax}    ${parameter_pmax}    ${pmax_43dbm}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Verify TCP UL/DL data with egen logs collection
    Validation of egen logs and netconf logs
    OperationKeywords.Perform Parameter Recommissioning    ${distname_pmax}    ${parameter_pmax}    ${pmax_40dbm}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Run Keyword And Continue On Failure    Perform O&M operations on AWHQN and verify calls
    Run Keyword And Continue On Failure    Perform RET reset using WebEM and Verifying ALD RET parameters are being sent from ORU
    #pdu.power_on    port=${FJT_ippdu_port}    pdu_device=RRB_ippdu
    #pdu.teardown_pdu    pdu_device=RRB_ippdu
    [Teardown]    run keywords
    ...        KeywordsCRT2.Power_On_FJT
	...        KeywordsCRT2.Test Teardown

[1]CNI-121537_ Verification of EPE counters for power and temperature after Radio Reset and Lock_Unlock
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    121537      nocalls    singlerun    26R2
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    ${sw_release}=    coam.get_sw_release_name
    ${current_sw_version_raw}=      coam.get sw version
    IF  '${trunk}' in '${current_sw_version_raw}'
        Run Keyword And Continue On Failure    Validate counters for AWHQN
    END
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    OperationKeywords.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    RadioLock    ${Rmod}
    RadioUnlock    ${Rmod}
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    ResetSingleRadio    ${Rmod}
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    BuiltIn.Sleep    9m
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    OperationKeywords.Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue_disable}
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    MayureshCNI121537EPEcounters_With_FJT_SUPPORT

CNI121537EPEcounters_With_FJT_SUPPORT
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    25R3    trunk    121537_netact     nocalls    singlerun    26R1
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
    NetActSetup
    ${plan_conf}=    netact.Create Plan Configuration    ${plan_name_enableFeature}    ${description}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    OperationKeywords.Get Actual Configuration MO Data   ${mo_id_pmmnl}
    ${managed_object}=     netact.create_managed_object    ${plan_conf}    ${meta_class}     ${meta_version}    ${mo_id_pmmnl}    UPDATE
    ...    miTrRxWindowStats=${Time_5m}    miOranTrxStats=${Time_5m}    miOranRuTxStats=${Time_5m}    miOranEpeStats=${Time_5m}
    ...    alias=${NETACT_NAME}
    KeywordsCRT2.Provision Plan    ${plan_name_enableFeature}
    Sleep    9m
    FOR    ${i}    IN RANGE    0    11
        Run Keyword and Continue on Failure    GetCounter_miTrRxWindowStats    ${counterlist_miTrRxWindowStats}[${i}]    ${transport_stats_group}
        Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     ${counterlist_miOranTrxStats}[${i}]    ${miOranTrx_stats_group}
    END
    FOR    ${i}    IN RANGE    0    12
        Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     ${counterlist_miOranEpeStats}[${i}]    ${miOranEpe_stats_group}
    END
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranEpeStats_Counter}    @{miOranEpeStats_CounterList}
    Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     @{counterlist_miOranRuTxStats}    ${miOranRuTx_stats_group}
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miTrRxWindowStats_Counter}    @{miTrRxWindowStats_CounterList}
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranTrxStats_Counter}    @{mioranTrxStats_CounterList}
    coam.Teardown All Aliases For Admin
    coam.Setup_Admin
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranRuTxStats_Counter}    @{miOranRuTxStats_CounterList}
    ${plan_conf}=    netact.Create Plan Configuration    ${plan_name_disableFeature}    ${description}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    OperationKeywords.Get Actual Configuration MO Data   ${mo_id_pmmnl}
    ${managed_object}=    netact.create_managed_object    ${plan_conf}    ${meta_class}    ${meta_version}    ${mo_id_pmmnl}    UPDATE
    ...    miTrRxWindowStats=${disabled}    miOranTrxStats=${disabled}    miOranRuTxStats=${disabled}   miOranEpeStats=${disabled}
    ...    alias=${NETACT_NAME}
    KeywordsCRT2.Provision Plan    ${plan_name_disableFeature}
    Sleep    9m
    FOR    ${i}    IN RANGE    0    11
        Run Keyword and Continue on Failure    GetCounter_miTrRxWindowStats    ${counterlist_miTrRxWindowStats}[${i}]    ${transport_stats_group}
        Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     ${counterlist_miOranTrxStats}[${i}]    ${miOranTrx_stats_group}
    END
    FOR    ${i}    IN RANGE    0    12
        Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     ${counterlist_miOranEpeStats}[${i}]    ${miOranEpe_stats_group}
    END
    Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats    @{counterlist_miOranRuTxStats}    ${miOranRuTx_stats_group}
    KeywordsCRT2.Validate ActiveAlarms
    coam.Teardown All Aliases For Admin
    coam.Setup_Admin
    Sleep    2m
    KeywordsCRT2.Collect Snapshot
    KeywordsCRT2.Extract netconf from snapshot
    os.Move file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/*_NetconfRpcMessageTrace.log
    ...		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace1.log
    Netconf_MessageVerification_9196related_messages
    ...     ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace1.log
    ...    @{miTrRxWindowStats_capabilities}
    Netconf_MessageVerification_9196related_messages
    ...     ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace1.log
    ...    @{miOranepeStats_capabilities}
    Netconf_MessageVerification_9196related_messages
    ...     ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace1.log
    ...    @{miOranRuTxStats_capabilities}
    Netconf_MessageVerification_9196related_messages
    ...              ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace1.log
    ...                                                 @{miOranTrxStats_capabilities}
    ${plan_conf}=    netact.Create Plan Configuration    ${plan_name_enableFeature_1}    ${description}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    OperationKeywords.Get Actual Configuration MO Data   ${mo_id_pmmnl}
    ${managed_object}=     netact.create_managed_object   ${plan_conf}    ${meta_class}     ${meta_version}    ${mo_id_pmmnl}    UPDATE
    ...    miRxWindowStats=${Time_5m}    miOranTrTxStats=${Time_5m}    alias=${NETACT_NAME}
    KeywordsCRT2.Provision Plan    ${plan_name_enableFeature_1}
    Sleep    12m
    FOR    ${i}    IN RANGE    0    8
        Run Keyword and Continue on Failure    GetCounter_miTrRxWindowStats    ${counterlist_miRxWindowStats}[${i}]    ${miRxWindow_stats_group}
    END
    Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     @{counterlist_miOranTrTxStats}    ${miOranTrTx_stats_group}
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miRxWindowStats_Counter}    @{miRxWindowStats_CounterList}
    Run Keyword and Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${miOranTrTxStats_Counter}    @{miOranTrTxStats_CounterList}
    ${plan_conf}=    netact.Create Plan Configuration    ${plan_name_disableFeature_1}    ${description}    alias=${NETACT_NAME}
    ${meta_class}     ${meta_version}=    OperationKeywords.Get Actual Configuration MO Data   ${mo_id_pmmnl}
    ${managed_object}=     netact.create_managed_object   ${plan_conf}    ${meta_class}     ${meta_version}    ${mo_id_pmmnl}    UPDATE
    ...    miRxWindowStats=${disabled}    miOranTrTxStats=${disabled}    alias=${NETACT_NAME}
    KeywordsCRT2.Provision Plan    ${plan_name_disableFeature_1}
    Sleep    9m
    FOR    ${i}    IN RANGE    0    8
        Run Keyword and Continue on Failure    GetCounter_miTrRxWindowStats    ${counterlist_miRxWindowStats}[${i}]    ${miRxWindow_stats_group}
    END
    Run Keyword and Continue on Failure    GetCounter_miOranRuTxStats     @{counterlist_miOranTrTxStats}    ${miOranTrTx_stats_group}
    KeywordsCRT2.Validate ActiveAlarms
    KeywordsCRT2.Collect Snapshot
    KeywordsCRT2.Extract netconf from snapshot
    os.Move file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/*_NetconfRpcMessageTrace.log
    ...		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace2.log
    BuiltIn.Run Keyword And Ignore Error     Netconf_MessageVerification_9196related_messages
    ...     ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace2.log
    ...    @{miRxWindowStats_capabilities}
    BuiltIn.Run Keyword And Ignore Error     Netconf_MessageVerification_9196related_messages
    ...     ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}/RMOD_L-4_NetconfRpcMessageTrace2.log
    ...    @{miOranTrTxStats_capabilities}

[1]CB009556_Cell level and Radio level measurements in RF Diagnostic Test via CLI commands after performing basic O&M operations multiple times
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    25R22    trunk    9556      nocalls    singlerun       25R2
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    PerformRFDiagTest
    FOR    ${i}    IN RANGE    1    4
        PerformNRResetRAT
        Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
        BuiltIn.Sleep    60s
        PerformRFDiagTest
        ResetAllCells    NR
        Wait Until Keyword Succeeds     5m    10s    Check_BTS_State
        PerformRFDiagTest
    END

[1]CB008796_LTE30_LTE31_Link Adaptation_DL AMC for Data Channel
      [Documentation]    CB008796_LTE30_LTE31_Link Adaptation_DL AMC for Data Channel_TC
      [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk     LTE30_31    LTE8796    CRT    LTE    singlerun
      [Setup]    Run Keywords     Setup Attenuator    KeywordsCRT2.Test Setup
      Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
      BuiltIn.sleep    5s
      OperationKeywords.Perform Parameter Recommissioning     ${Cell1_dist}     ${param_modscheme}    ${value_qam}
      Create dcap session
      DCAP_Start_Trace_enb_profile_customised
      BuiltIn.sleep    100s
      Block all cells Except OFEGSA
      #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9110}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9115}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9118}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLNR1}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGNRCELL}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL2}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AHHBCELL1}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AHHBCELL2}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_2}
      #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_10}
      Prepare UE and Attach UE with default bearers
      ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
      BuiltIn.sleep    30s
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
      ...  vendor=${at_vendor}  model=${at_model}
      FOR   ${i}   IN   @{valueslistofports}
          at.set_ports_attenuation     ports=${ports}     values=${i}    confirm=${value_true}    confirmation_delay=5s
          BuiltIn.sleep    5s
      END
      ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_dl}
      BuiltIn.Sleep    250s
      ${Result_1}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
      ...    direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}
      ${Value_1}=    get from dictionary    ${Result_1['${UE_alias[0]}']}    maxtput
      ${Int_value}=   Convert To Integer    ${Value_1}
      ${status_1}=    BuiltIn.Evaluate      ${Int_value}>=${Acceptable_Peak_tp_DL}[0]
      Run keyword And Continue On Failure        Should Be True    ${status_1}
      DCAP_Stop_Trace
      Run keyword And Continue On Failure    ExtractLogsForValidation    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/
      Run keyword And Ignore Error    TTI parse DL    ${sw_build}
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9110}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9115}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9118}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLNR1}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGNRCELL}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHHBCELL1}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHHBCELL2}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_2}
     #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_10}
         [Teardown]    run keywords
    ...    Unblock all cells Except OFEGSA
    ...    KeywordsCRT2.Test Teardown

[1]CB008796_CB006620_Fast Uplink Link Adaptation improvement
    [Documentation]    CB008796_CB006620_Fast Uplink Link Adaptation improvement_TC
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk   LTE8796    6620    LTE    singlerun
    [Setup]    Run Keywords     Setup Attenuator    KeywordsCRT2.Test Setup

    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    OperationKeywords.Perform Parameter Recommissioning     ${Cell1_dist}     ${param_modschemeUL}    ${value_qam}
    OperationKeywords.Perform Parameter Recommissioning     ${Cell1_dist}     ${param_actUlLnkAdp}    ${param_actUlLnkAdp_value}
    OperationKeywords.Perform Parameter Recommissioning     ${Cell1_dist}     ${param_mcs}    ${value_true}
    Create dcap session
    DCAP_Start_Trace_enb_profile_customised
    Block all cells Except OFEGSA
    #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9110}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9115}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLLTE9118}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLNR1}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGNRCELL}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL2}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AHHBCELL1}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AHHBCELL2}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_2}
    #Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_10}
    Prepare UE and Attach UE with default bearers
    BuiltIn.sleep     15s
    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_ul}
    BuiltIn.sleep    30s
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    FOR   ${i}   IN   @{valueslistofports_6620}
          at.set_ports_attenuation     ports=${ports}     values=${i}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    END
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    direction=${direction_ul}
    BuiltIn.Sleep    250s
    ${Result_2}=    calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}
    ${Value_2}=    get from dictionary    ${Result_2['${UE_alias[0]}']}    maxtput
    ${Int_value_2}=   Convert To Integer    ${Value_2}
    ${status_2}=    BuiltIn.Evaluate      ${Value_2}>=${Acceptable_Peak_tp_UL}[0]
    Run keyword And Continue On Failure		Should Be True    ${status_2}
    DCAP_Stop_Trace
    Run keyword And Continue On Failure    ExtractLogsForValidation    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/
    Run keyword And Ignore Error    TTI parse UL    ${sw_build}
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9110}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9115}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLLTE9118}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLNR1}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGNRCELL}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHHBCELL1}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHHBCELL2}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_2}
    #Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_10}
    [Teardown]    run keywords
    ...    Unblock all cells Except OFEGSA
    ...    KeywordsCRT2.Test Teardown

[1]CB007814-F_Verification of site moving to TDS and then back to normal state.
    [Documentation]     CB007814-F_Verification of site moving to TDS and then back to normal state
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    NR1    tds    trunk    nocalls    singlerun    25R2    RP
    PerformRecommissioning    ${master_scf_without_AWHQN}
    Wait Until Keyword Succeeds    15min    10s    Validate_BTS_STATUS    ${Required_bts_status}[1]
    move_to_test_dedicated_state_Enable
    Run Keyword And Continue On Failure    KeywordsCRT2.start_downlinkNr_test
    Run Keyword And Continue On Failure   KeywordsCRT2.stop_downlinkNr_test
    move_to_test_dedicated_state_Disable
    RP Settings
    [Teardown]    run keywords
    ...    master scf commissioning
    ...    KeywordsCRT2.Test Teardown

[1]CB010992-D_CB010443_Verify EN-DC Cell Activation procedure that is triggered by eNB for NR cell.
	[Documentation]     CB010992 Trigger Cell Switch Off for NR and LTE and ORU Energy Saving
    	[Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    CB010992    CELLSO    NR1    26R1    singlerun    trunk    26R2    RP
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    Wait Until Keyword Succeeds     10m    10s    OperationKeywords.Perform Parameter Recommissioning    ${dist_timezone}
    ...    ${timezone}    ${timezone_value_utc}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
	LOG TO CONSOLE    \n Updating day and time and configuring new SCF
    Get Time and update SCF for Power Saving Parameters
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[0]
	LOG TO CONSOLE    \n Commissioning new SCF with latest date and time for Cell and ORU Switch OFF
	KeywordsCRT2.SCF commissioning    ${output_File}
	Wait Until Keyword Succeeds    15min    10s    Validate_BTS_STATUS    ${Required_bts_status}[1]
	LOG TO CONSOLE    \n SETUP IS UP and ONAIR
	BuiltIn.Sleep    400
    Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9117}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9118}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9110}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9115}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR1}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[1]
	BuiltIn.Sleep    30
	BuiltIn.Sleep    1000
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9110}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9115}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9117}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE9118}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR1}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[0]
	Block all cells Except OFEGSA
	Run Keyword And Continue On Failure    Place Calls On Cells
    Unblock all cells Except OFEGSA
    Wait Until Keyword Succeeds     10m    10s    OperationKeywords.Perform Parameter Recommissioning    ${dist_timezone}
    ...    ${timezone}    ${timezone_value_asia}
    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State

[1]Test case-2_CB010358_CB005738_CB007738_DSS_LTE-NR_SuperFast_allocation_verification_20MHz_SA
    [Documentation]     CB010358 ABIP DSS Case where we try to check for CRM Commits
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    CB010358    DSS    25R3    trunk    NR    singlerun    26R1
    Block all cells Except OFEGSA DSS cells
    block AWHQN cell
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias2}    ${capabilities2}
    Unblock all cells Except OFEGSA DSS cells
    unblock AWHQN cell
    Stop BTS logs_DSS
    validate_syslog_file_contents
    ...    dir_path=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/syslogs_DSS/btslog/syslog_files.tar/
    ...    search_string=@{search_string}
    #Object Recommissioning    ${maxNrDssRatio_70}    ${lteNrDssDlRatio_70}     ${maxLteDssSibRb_0}
    #sleep    60
    #Object Recommissioning    ${maxNrDssRatio_50}    ${lteNrDssDlRatio_50}     ${maxLteDssSibRb_0}
    #sleep    60

[1]CB009556_ETP and RTWP in ALM via CLI commands after performing basic O&M operations multiple times.
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    ant9556    nocalls    singlerun

    DHCP messages validation during RMOD startup
    os.Copy file    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/tcpdump/tcpdump.pcap
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/tcpdump/tcpdump_ipv4.pcap
    PerformRecommissioning    ${scf_config2}
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    DHCPv6 messages validation during RMOD startup
    CheckOperationalStateOfRadios
    ResetSingleRadio    ${Rmod}
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    PerformRecommissioning    ${master_scf_without_AWHQN}
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    Run Keyword And Continue On Failure    Antenalinemonitor    ${time}
    RenameFile    ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}    initialfile
    FOR    ${i}    IN RANGE    1    4
        ResetSingleRadio    ${Rmod}
        Wait Until Keyword Succeeds     7m    10s    Check_BTS_State
        BuiltIn.Sleep    300
        Antenalinemonitor    ${time}
        RenameFile    ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}    radioreset${i}
        SingleBBmodReset    ${BBmod}
        Wait Until Keyword Succeeds     7m    10s    Check_BTS_State
        BuiltIn.Sleep   300
        Antenalinemonitor    ${time}
        RenameFile    ${BTS_path}/${SUITE_NAME}/${Date}/${TEST_NAME}    BBreset${i}
    END
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias2}     ${capabilities2}
   [Teardown]    run keywords
    ...    master scf commissioning
    ...    KeywordsCRT2.Test Teardown

[1]CB012780_To Monitor ORU reset along with SSH key exchange
    [Tags]    CB012780    trunk
    setup_pdu     model=RRB    host=${FJT_ippdu_ip}    alias=RRB_ippdu
    pdu.power_off    port=${FJT_ippdu_port}    pdu_device=RRB_ippdu
    sleep    30s
    coam.reset_site
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    Get TcpdumpLogs from container using lxc-attach
    ResetSingleRadio    ${RMOD_AWHQN}
    RAE State should be enabled
    Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    Stop TcpdumpLogs
    Netconf File Collection
    ${netconf_file}=     Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log
    ${a}=    validate_netconf_reply_message      ${netconf_file}     ${rpc_get}    ${info}    ${version}
    run keyword and continue on failure   Should not be empty    ${a}
    ${version}=    Evaluate    any('12.0.0' in item[2]['operational-info'] for item in ${a})
    Should Be True    ${version}
    Run Keyword And Continue On Failure    Extraction and validation of runtime log from snapshot
    pdu.power_on    port=${FJT_ippdu_port}    pdu_device=RRB_ippdu
    pdu.teardown_pdu    pdu_device=RRB_ippdu
    Wait Until Keyword Succeeds     15m    10s    Ensure cells are enabled
    ${file_content}    Convert pcap file    ${filter_msg}
    Wireshark log validation for CB012780    ${file_content}
    Verify TCP UL/DL data with egen logs collection
    [Teardown]    run keywords
    ...    KeywordsCRT2.Power_On_FJT
    ...    KeywordsCRT2.Test Teardown

[1]CB009196-B_Verification_of_O-RU_M-Plane_version_check_when_supported_M-Plane_version_value_is_higher
    [Tags]    8205-G        9196B
    #Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    #setup_pdu     model=RRB    host=${AWHQN_ippdu_ip}    alias=RRB_ippdu
    #pdu.power_off    port=${AWHQN_IPPDU_port}    pdu_device=RRB_ippdu
    #sleep    30s
    #coam.reset_site
    BuiltIn.Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    Netconf File Collection
    KeywordsCRT2.Validating M-plane negotiation    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/RMOD_L-1_NetconfRpcMessageTrace.log

#TC_04_Vendor_specific_fault_simulation_on_O-RU
    #[Tags]    8205-C    trunk1    TC04
    #Wait Until Keyword Succeeds     15m    10s    Check_BTS_State
    ###Logs into Windows, then SSHs from Windows to a second Linux machine.
    #Connect To Windows And Login

####CA cases#####

[1]CB007814 _5GC006138- Verification of UDP Downlink Carrier Aggregation data Tput and SCell selection for up to 3CC UE with TDD as PCell
    [Documentation]    Verification of UDP Downlink Carrier Aggregation data Tput and SCell selection for
	...    up to 3CC UE with TDD as PCell using measurement method
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    5GCA    3cc    trunkCA    25R3CA    CA    26R1CA

    COAM.get_bts_info
    dcap.connect_to    host=${DCAP_host}    port=${port}    username=${dcapuser}    password=${dcap_password}
    ...              rd_version=dcapv3    secure=True
    &{bts1_info}    create dictionary    host=${BTS_M_plane_ip}    port=${port}   username=${bts_username}    password=${bts_password}
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    @{bts}      Create List     ${bts1_info}
    ${output}    dcap.start_trace     duration=-1    bts=${bts1_info}     bts_trace_profile=Default tracing profile
    ...    gnb_trace_profile=Default tracing profile    wait_for_activation=True
    LogToConsole    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    BuiltIn.sleep     20
    ${trace_id} =   Convert To Integer    ${trace_id}
    Run Keyword And Continue On Failure    Block all cells Except AZQP_PCell
    Run Keyword And Continue On Failure    block AWHQN cell
    at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}       model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_fjt}    ${cavalues0}    confirm=True    confirmation_delay=5
    at.setup_attenuator    ip_addr=${attenuator_host}     port=${attenuator_port}     attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}      model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_ahpmdg}    ${avalues0}    confirm=True    confirmation_delay=5
    at.setup_attenuator       ip_addr=${attenuator_host}       port=${attenuator_port}       attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}      model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues1}    confirm=True    confirmation_delay=5
    ${start_date}=    Get Current Date
    ue.Require ue    ue_alias=UE_1    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_1
    ue.Attach Ue     ue_alias=UE_1    timeout=120
    Log To Console    Data transfer starting
    ue.Start Data Transfer
            ...     dt_name=DT_1
        ...     ue_alias=UE_1
       ...     direction=dl
        ...     duration=60s
        ...     throughput=2000000000 bits/sec
        ...     protocol=udp
       ...     bandwidth=2000M
        ...     port=5033
        ...     apn=srancptupf3
    BuiltIn.sleep     60
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGNRCELL}
    ue.Stop Data Transfer    dt_name=DT_1
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_fjt}    ${cavalues1}    confirm=True    confirmation_delay=5
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_ahpmdg}    ${avalues1}    confirm=True    confirmation_delay=5
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues3}    confirm=True    confirmation_delay=5
    Log To Console    Data transfer starting after attenuation
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=30s
        ...     throughput=2000000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=2000M
        ...     port=5034
        ...     apn=srancptupf3
    BuiltIn.sleep     30
    ue.Stop Data Transfer    dt_name=DT_1
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues4}    confirm=True    confirmation_delay=5
    Log To Console    Data transfer starting after attenuation
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=120s
        ...     throughput=2000000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=2000M
        ...     port=5035
        ...     apn=srancptupf3
    BuiltIn.sleep     120
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1100 Mbits/sec
    ...     deviation=30%
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    500   ###sleep time for packaging log files in dcap tool
    ${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ...    timeout=${timeout}
    KeywordsCRT2.Counter_Value_Check    ${NRcell6_counters_path1}    @{3CC_Countervalues}
    #Verify Emil logs
    [Teardown]    run keywords
    ...    KeywordsCRT2.Unblock all cells Except AZQP_PCell
    ...    KeywordsCRT2.unblock AWHQN cell
    #...    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    ...    KeywordsCRT2.Test Teardown

[1]CB007814_5GC002250_5GC001390 Verification of TCP Downlink Carrier Aggregation data Tput and Buffer Based SCell activation
    [Documentation]     Verification of TCP Downlink Carrier Aggregation data Tput and Buffer Based SCell activation for up to 2CC UEs
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    5GCA    2cc    trunkCA    CA
    ${start_date}=    Get Current Date
    at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}       model=${at_model}
    at.set_ports_attenuation    ${ports_fjt}    ${cavalues0}    confirm=True    confirmation_delay=5s
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation    ${ports_ahpmdg}    ${avalues0}    confirm=True    confirmation_delay=5
    dcap.connect_to    host=${DCAP_host}    port=${port}    username=${dcapuser}    password=${dcap_password}
    ...              rd_version=dcapv3    secure=True
    &{bts1_info}    create dictionary    host=${BTS_M_plane_ip}    port=${port}   username=${bts_username}    password=${bts_password}
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    @{bts}      Create List     ${bts1_info}
    ${output}    dcap.start_trace     duration=-1    bts=${bts1_info}     bts_trace_profile=Default tracing profile
    ...    gnb_trace_profile=Default tracing profile    wait_for_activation=True
    LogToConsole    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    BuiltIn.Sleep    20
    ${trace_id} =   Convert To Integer    ${trace_id}
    Run keyword and Continue on Failure    Block all cells Except AZQP_PCell
    Run keyword and Continue on Failure    KeywordsCRT2.unblock AWHQN cell
    ue.Require ue    ue_alias=UE_2    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_2
    ue.Attach Ue     ue_alias=UE_2    timeout=300
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation    ${ports_fjt}    ${cavalues1}    confirm=True    confirmation_delay=5
    ue.Start Data Transfer
            ...     dt_name=DT_1
        ...     ue_alias=UE_2
        ...     direction=dl
        ...     duration=120s
        ...     throughput=1500000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=1500M
        ...     port=5023
        ...     apn=srancptupf3
    BuiltIn.sleep     120
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1000 Mbits/sec
    ...     deviation=40%
    ${end_date}=    Get Current Date
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    300   ###sleep time for packaging log files in dcap tool
    ${dcap_file_name}=   dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ...    timeout=${timeout}
    KeywordsCRT2.Counter_Value_Check    ${NRcell1_counters_path1}    @{2CC_Countervalues}
    at.setup_attenuator    ip_addr=${attenuator_host}     port=${attenuator_port}     attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}      model=${at_model}
    at.set_ports_attenuation    ${ports_ahpmdg}    ${avalues0}    confirm=True    confirmation_delay=5
    Verify Emil logs    /${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/UTFLab_start_*.zip    @{emil_values}
    #Emil decoding in csv to specific folder with callable filter    126
    #DCAP_EMIL_DECODER    /home/ute/UTFLab_start_trace_2025-02-12T06_25_00.544Z.zip
    #Verify Emil logs    @{emil_values}
    [Teardown]    run keywords
    ...    Unblock all cells Except AZQP_PCell
    ...    KeywordsCRT2.unblock AWHQN cell
    #...    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    ...    KeywordsCRT2.Test Teardown

[1]CB008796_LTE5270_Verification of 4CC 16 MIMOlayers FDD DL CA with blind SCel additionLTE5270
    [Documentation]     CB008796_LTE5270
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    LTE4CC    trunkCA    25R3CA    CA    26R1CA
    Wait Until Keyword Succeeds   15min    10s    Check_BTS_State
    dcap.connect_to    host=${DCAP_host}    port=${port}    username=${dcapuser}    password=${dcap_password}
    ...              rd_version=dcapv3    secure=True
    &{bts1_info}    create dictionary    host=${BTS_M_plane_ip}    port=${port}   username=${bts_username}    password=${bts_password}
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g    cp_4g
    @{bts}      Create List     ${bts1_info}
    ${output}    dcap.start_trace     duration=-1    bts=${bts1_info}     bts_trace_profile=Default tracing profile
    ...    enb_trace_profile=Default tracing profile    wait_for_activation=True
    LogToConsole    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    BuiltIn.Sleep    20
    ${trace_id} =   Convert To Integer    ${trace_id}
    ${start_date}=    Get Current Date
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    Run keyword And Continue On Failure    Peform_block_Cell    ${OFEGSACELLNR1}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGNRCELL}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AZQPNRCELL2}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_2}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AHPMDGLCELL_10}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AWHQNNRCELL}
    Run keyword And Continue On Failure    Peform_block_Cell    ${AHHBCELL2}
    ue.Require ue    ue_alias=UE_1    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_1
    ue.Attach Ue     ue_alias=UE_1    timeout=120
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    60s
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=120s
        ...     throughput=500000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=1500M
        ...     port=5053
        ...     apn=srancptupf3
    Log To Console    Data transfer started
    BuiltIn.sleep     240
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1500 Mbits/sec
    ...     deviation=50%
    ${end_date}=    Get Current Date
    sleep   120
    Run Keyword And Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${LTE_pcell_counters_path}    @{LTE5270_4CC_counters}
    Run Keyword And Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${LTE_pcell_tput_counters_path}    @{LTE5270_4CC_counters_tput}
    Run Keyword And Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${LTE_pcell_LTE_Pwr_and_Qual_DL}    @{LTE5270_4CC_counters_UE}
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    700
    ${dcap_file_name}=   dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP
    ...    timeout=${timeout}
    #Verify Emil logs     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP.zip    @{emil_values}
    #Run keyword And Continue On Failure    Verify Emil logs     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP    @{emil_values}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${OFEGSACELLNR1}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGNRCELL}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AZQPNRCELL2}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_2}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHPMDGLCELL_10}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AWHQNNRCELL}
    Run keyword And Continue On Failure    Peform_unblock_Cell    ${AHHBCELL2}
    [Teardown]    run keywords
    #...    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    ...    KeywordsCRT2.Test Teardown
