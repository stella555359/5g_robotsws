*** Settings ***

Documentation
...    Test Description: This feature is to verify the Antenna Port Re-mapping for 4T4R ORAN FDD NR_LTE concurrent mode SA cell configuration
...    Sample execution: robot -d /home/ute/logs/ -T /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG01/CB010916/general.robot

Library     ./testsuite/Bangalore/ORAN/SG02/CRT2Suite/CB008796.py
Library     ./testsuite/Bangalore/ORAN/SG02/CRT2Suite/UpdateCellSOParameters.py
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
Resource    ./testsuite/Bangalore/ORAN/SG02/CRT2Suite/CRT2Variables.robot
Resource    ./testsuite/Bangalore/ORAN/SG02/CRT2Suite/KeywordsCRT2.robot
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.file.pack
Library     taf.collectors.pmcounters    WITH NAME    PM
Library     taf.analyzer.pmcounter    WITH NAME    analyser
Resource    ./testsuite/Bangalore/ORAN/resources/robot/common_admin.robot
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Library     testsuite/Bangalore/ORAN/SG02/resources/python/snapshotFileIdentifier.py
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

Suite Setup        Suite Setup
Suite Teardown     Suite Teardown
Test Setup         KeywordsCRT2.Test Setup
Test Teardown      KeywordsCRT2.Test Teardown
#Force Tags         CA_VRF_BLR1    SBTS00    SBTS25R2    QCD_MN_RAN   QCP_RAN_VRF

*** Test Cases ***

CB009462CATM
    [Documentation]    CB009462_Verification of Successful commissioning of O-RAN with O-RAN M-Plane static LTE PRACH configuration with CatM_enabled
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    TC_CATM    trunk

    Perform Parameter Recommissioning    ${distname_lncelfdd}    ${paramter_catm}    ${value_true}
    Create dcap session
    DCAP_Start_Trace_enb_profile_customised
    Run Keyword And Continue On failure    cat-M UE call
    #LTE wideband and catM call
    Netconf File Collection
    Run Keyword And Continue On failure    Verify static PRACH config from Netconf logs
	...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${NetconfFileName}
    DCAP_Stop_Trace
    Perform Parameter Recommissioning    ${distname_lncelfdd}    ${paramter_catm}    ${value_false}
    Wait Until Keyword Succeeds    10m    10s    Check_BTS_State

CB010916AntPortRemapping
    [Documentation]    CB010916_Verfication of enabling_modification and disabling of Antenna Port Re_mapping for
	...    4T4R ORAN FDD NR_LTE concurrent mode SA cell
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    10916    NR

    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    Perform commissioning with ANT port re-map    ${commonSCFpath}/ANT_remap.json
    Wait Until Keyword Succeeds   10min    10s      Ensure cells are enabled
    RadioLock    ${RMOD5_distname}
    RadioLock    ${RMOD4_distname}
    RadioLock    ${RMOD6_distname}
    Peform_block_Cell    ${OFEGSACELLNR2}
    Peform_block_Cell    ${OFEGSACELLNR5}
    BuiltIn.sleep    10
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}    ${capabilities3}
    Perform commissioning with ANT port re-map    ${commonSCFpath}/ANT_remap_modifying.json
    Wait Until Keyword Succeeds   10min    10s      Ensure cells are enabled
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}     ${capabilities3}
    Perform commissioning with ANT port re-map    ${commonSCFpath}/ANT_remap_deletion.json
    Wait Until Keyword Succeeds   10min    10s      Check_BTS_State
    Peform_block_Cell    ${OFEGSACELLNR2}
    Peform_block_Cell    ${OFEGSACELLNR5}
    FOR    ${index}    IN RANGE   5
         SingleBBmodReset    ${BBmod}
    END
    BuiltIn.sleep    10
    FOR    ${index}    IN RANGE   5
        Run Keyword And Continue On Failure      coam.reset_unit    dist_name=${Rmod3}    reset_type=Soft    timeout=400
        Wait Until Keyword Succeeds     6m    10s    Ensure cells are enabled
    END
    BuiltIn.sleep    180
    COAM.collect_snapshot     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/Snapshot_10916.zip
    FOR    ${index}    IN RANGE   5
        SiteReset
    END
    Run Keyword and Continue On Failure    PerformPowerResetfromIpPdu     ${ip_pdu}     ${asim}
    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    Run Keyword and Continue On Failure    PerformPowerResetfromIpPdu     ${ip_pdu1}    ${ru}
    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}     ${capabilities3}
    Peform_unblock_Cell    ${OFEGSACELLNR2}
    Peform_Unblock_Cell    ${OFEGSACELLNR5}

CB0078145GC000501
    [Documentation]    CB007814_5GC000501_Enabling and configuring Graceful Cell Shutdown and OAM shall reject any parallel procedure for given cell
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    501    trunk    CRT    NR
    [Setup]    Run Keywords     NetActSetup    KeywordsCRT2.Test Setup

    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}    ${capabilities3}
    Perform Parameter Recommissioning    ${NRBTS_distname}    ${value_actGrflShdn}    ${value_true}
    Perform Parameter Recommissioning    ${NRBTS_distname}    ${value_shutdownWindow}    ${shut_window}
    Perform Parameter Recommissioning    ${NRBTS_distname}    ${value_shutdownStepAmount}    ${shutstep}
    Create_Activate_Plan_Netact    ${shutcell_plan}     ${shutcellBackup}     ${celladministrativeState1}
    BuiltIn.Sleep    200s
    Run Keyword and Continue On Failure    checkCellState     Locked    disabled     Idle    initialization required
    ResetAllRadio
    Run Keyword and Continue On Failure    checkCellState     Locked    disabled     Idle     initialization required
    Create_Activate_Plan_Netact    ${unlockcell_plan}    ${unlockBackup}     ${celladministrativeState2}
    BuiltIn.Sleep    100s
    Run Keyword and Continue On Failure    checkCellState      Unlocked      enabled      Active      configured
    Wait Until Keyword Succeeds   6min    10s    Check_BTS_State
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}    ${capabilities3}
    [Teardown]    Run Keywords     NetActTeardown    KeywordsCRT2.Test Teardown

LTE914LTE830
      [Documentation]    CB008796_LTE914_LTE830 LTE Automatic lock and Graceful Cell Shutdown Validation
      [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    LTE830    trunk    LTE
      [Setup]    Run Keywords    KeywordsCRT2.Test Setup     Setup_Attenuator_AHHB

      Wait Until Keyword Succeeds   15min    10s    Check_BTS_State
      RadioLock    ${RMOD5_distname}
      RadioLock    ${RMOD2_distname}
      RadioLock    ${RMOD1_distname}
      Perform Parameter Recommissioning     ${New_Element_MO_dis}     ${param_autolock}     ${value_enabled}
      Perform Parameter Recommissioning     ${New_Element_MO_dis}     ${param_grflshdn}     ${value_enabled}
      Peform_block_Cell    ${OFEGSACELLLTE2}
      Prepare UE and Attach UE with default bearers
      BuiltIn.Sleep    15s
      Start Voice call to establish QCI1 dedicated bearer
      BuiltIn.Sleep    15s
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
      BuiltIn.Sleep    5s
      Perform Parameter Recommissioning     ${distname_lncelfdd}    ${param_rootseqindex}     ${rootseqindex_value}
      Stop BTS logs_LTE830
      Run keyword And Continue On Failure     Verify gracelfullshutdown in Syslogs    ${grflcellshtn}
      Start BTS logs
      Run keyword And Continue On Failure    Stop Voice call to release QCI1 bearer
      BuiltIn.sleep    10s
      Run keyword And Continue On Failure     RadioUnlock    ${RMOD5_distname}
      Run keyword And Continue On Failure     RadioUnlock    ${RMOD2_distname}
      Run keyword And Continue On Failure     RadioUnlock    ${RMOD1_distname}
      Peform_unblock_Cell    ${OFEGSACELLLTE2}

CB008796LTE907
      [Documentation]    CB008796_LTE907_Validation of TTIB during call setup & release, inter & intra-frequency measurements & re-establishments
      ...                TC Purpose:verify link adaptation by Adaptive Modulation and Coding (AMC) for Downlink Data Channel (PDSCH)
      [Tags]    QCD_MN_RAN    QCP_RAN_ST    trunk    LTE907    CRT    LTE
      [Setup]    Run Keywords     Setup Attenuator    KeywordsCRT2.Test Setup

      Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
      Create dcap session
      DCAP_Start_Trace_enb_profile_customised
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
      BuiltIn.sleep    5s
      Peform_block_Cell    ${OFEGSACELLLTE2}
      Perform Parameter Recommissioning         ${Cell1_dist}    ${param_ttibundling}	   ${value_false}
      ta_ultracaller.Require UE    ue_alias=${UE_alias}   capabilities=${capabilities}
      ta_ultracaller.Detach UE     ue_alias=${UE_alias}
      ta_ultracaller.Attach UE     ue_alias=${UE_alias}
      BuiltIn.sleep    10s
      Start Voice call to establish QCI1 dedicated bearer
      BuiltIn.sleep    20s
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${ports}
      ...  vendor=${at_vendor}  model=${at_model}
      FOR   ${i}   IN   @{valueslistofports_907}
          at.set_ports_attenuation     ports=${ports}     values=${i}    confirm=${value_true}    confirmation_delay=5s
 	  BuiltIn.sleep    5s
      END
      BuiltIn.sleep    6m
      TTI Counter Verification
      Stop Voice call to release QCI1 bearer
      at.set_ports_attenuation    ${ports}    ${values}    confirm=${value_true}    confirmation_delay=5
      BuiltIn.sleep    15s
      ${counter_TTIB_OFF}    create list    ${ratio1}    ${ratio2}
      Perform Parameter Recommissioning    ${Cell1_dist}     ${param_ttibundling}	  ${value_true}
      BuiltIn.sleep    10s
      ta_ultracaller.Attach UE     ue_alias=${UE_alias}
      BuiltIn.sleep    10s
      Start Voice call to establish QCI1 dedicated bearer
      BuiltIn.sleep    20s
      FOR   ${i}   IN   @{valueslistofports_907}
          at.set_ports_attenuation     ports=${ports}     values=${i}    confirm=${value_true}    confirmation_delay=5s
 	  BuiltIn.sleep    5s
      END
      BuiltIn.sleep    6m
      TTI Counter Verification
      ${counter_TTIB_ON}    create list    ${ratio1}    ${ratio2}
      Stop Voice call to release QCI1 bearer
      DCAP_Stop_Trace
      Run keyword And Continue on Failure     Should be True     ${counter_TTIB_ON} < ${counter_TTIB_OFF}
      @{check}	    Create list		 rrcConnectionReconfiguration::ttiBundling TRUE
      Run keyword And Continue on Failure    Verify Emil logs    @{check}
      at.set_ports_attenuation    ${ports}    ${values0}    confirm=True    confirmation_delay=5
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
      Peform_unblock_Cell    ${OFEGSACELLLTE2}

LTE30LTE31
      [Documentation]    CB008796_LTE30_LTE31_Link Adaptation_DL AMC for Data Channel_TC
      [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk     LTE30_31    LTE8796    CRT    LTE
      [Setup]    Run Keywords     Setup Attenuator    KeywordsCRT2.Test Setup

      Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
      BuiltIn.sleep    5s
      Perform Parameter Recommissioning     ${Cell1_dist}     ${param_modscheme}    ${value_qam}
      Create dcap session
      DCAP_Start_Trace_enb_profile_customised
      BuiltIn.sleep    100s
      Peform_block_Cell    ${OFEGSACELLLTE2}
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
      BuiltIn.Sleep    100s
      ${Result_1}=    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
      ...    direction=${direction_dl}    thrughtput=${throughput_dl}    deviation=${deviation_dl}
      ${Value_1}=    get from dictionary    ${Result_1['${UE_alias[0]}']}    maxtput
      ${Int_value}=   Convert To Integer    ${Value_1}
      ${status_1}=    BuiltIn.Evaluate      ${Int_value}>=${Acceptable_Peak_tp_DL}[0]
      Run keyword And Continue On Failure        Should Be True    ${status_1}
      DCAP_Stop_Trace
      Run keyword And Continue On Failure    ExtractLogsForValidation    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/
      Run keyword And Continue On Failure    TTI parse DL    ${sw_build}
      at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
      ...  vendor=${at_vendor}  model=${at_model}
      at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
      Peform_unblock_Cell    ${OFEGSACELLLTE2}

CB008796CB006620
    [Documentation]    CB008796_CB006620_Fast Uplink Link Adaptation improvement_TC
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    LTE8796    6620    LTE
    [Setup]    Run Keywords     Setup Attenuator    KeywordsCRT2.Test Setup

    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    Perform Parameter Recommissioning     ${Cell1_dist}     ${param_modschemeUL}    ${value_qam}
    Perform Parameter Recommissioning     ${Cell1_dist}     ${param_actUlLnkAdp}    ${param_actUlLnkAdp_value}
    Perform Parameter Recommissioning     ${Cell1_dist}     ${param_mcs}    ${value_true}
    Create dcap session
    DCAP_Start_Trace_enb_profile_customised
    Peform_block_Cell    ${OFEGSACELLLTE2}
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
    BuiltIn.Sleep    100s
    ${Result_2}=    calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction_ul}    thrughtput=${throughput_ul}    deviation=${deviation_ul}
    ${Value_2}=    get from dictionary    ${Result_2['${UE_alias[0]}']}    maxtput
    ${Int_value_2}=   Convert To Integer    ${Value_2}
    ${status_2}=    BuiltIn.Evaluate      ${Value_2}>=${Acceptable_Peak_tp_UL}[0]
    Run keyword And Continue On Failure		Should Be True    ${status_2}
    DCAP_Stop_Trace
    Run keyword And Continue On Failure    ExtractLogsForValidation    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAPlogs/
    Run keyword And Continue On Failure    TTI parse UL    ${sw_build}
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
    Peform_unblock_Cell    ${OFEGSACELLLTE2}

####CA cases#####

LTE5270
    [Documentation]     CB008796_LTE5270
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    LTE7CC    trunk    25R2

    Wait Until Keyword Succeeds   10min    10s    Check_BTS_State
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
    #${trace_id} =   Convert To Integer    ${trace_id}
    #RETURN    ${trace_id}
    ${start_date}=    Get Current Date
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values8}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    Peform_block_Cell    ${OFEGSACELLLTE2}
    ue.Require ue    ue_alias=UE_1    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_1
    ue.Attach Ue     ue_alias=UE_1
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_AHHB}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation     ports=${ports_AHHB}     values=${values0}    confirm=${value_true}    confirmation_delay=5s
    BuiltIn.sleep    5s
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=120s
        ...     throughput=500000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=1500M
        ...     port=5053
    BuiltIn.sleep     120
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1500 Mbits/sec
    ...     deviation=50%
    ${end_date}=    Get Current Date
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    700
    ${dcap_file_name}=   dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/DCAP
    ...    timeout=${timeout}
    Run Keyword And Continue On Failure    KeywordsCRT2.Counter_Value_Check    ${LTE_pcell_counters_path}    @{LTE5270_7CC_counters}
    Verify Emil logs     ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}\DCAP.zip    @{emil_values}
    Peform_unblock_Cell    ${OFEGSACELLLTE2}

DLTput3CC_TDDPCell
    [Documentation]    Verification of UDP Downlink Carrier Aggregation data Tput and SCell selection for
	...    up to 3CC UE with TDD as PCell using measurement method
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    5GCA    3cc    trunk    25R2

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
    #RETURN    ${trace_id}
    at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}       model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_fjt}    ${cavalues0}    confirm=True    confirmation_delay=5
    at.setup_attenuator    ip_addr=${attenuator_host}     port=${attenuator_port}     attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}      model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_ahpmda}    ${cavalues0}    confirm=True    confirmation_delay=5
    at.setup_attenuator       ip_addr=${attenuator_host}       port=${attenuator_port}       attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}      model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues2}    confirm=True    confirmation_delay=5
    ${start_date}=    Get Current Date
    ue.Require ue    ue_alias=UE_1    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_1
    ue.Attach Ue     ue_alias=UE_1
    ue.Start Data Transfer
            ...     dt_name=DT_1
        ...     ue_alias=UE_1
       ...     direction=dl
        ...     duration=60s
        ...     throughput=1500000000 bits/sec
        ...     protocol=udp
       ...     bandwidth=1500M
        ...     port=5033
    BuiltIn.sleep     60
    ue.Stop Data Transfer    dt_name=DT_1
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_fjt}    ${cavalues1}    confirm=True    confirmation_delay=5
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_ahpmda}    ${cavalues1}    confirm=True    confirmation_delay=5
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues3}    confirm=True    confirmation_delay=5
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=30s
        ...     throughput=1500000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=1500M
        ...     port=5034
    sleep     30
    ue.Stop Data Transfer    dt_name=DT_1
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_azqp}
    ...  vendor=${at_vendor}  model=${at_model}
    Run Keyword And Continue On Failure    at.set_ports_attenuation    ${ports_azqp}    ${cavalues4}    confirm=True    confirmation_delay=5
    ue.Start Data Transfer
        ...     dt_name=DT_1
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=120s
        ...     throughput=1500000000 bits/sec
        ...     protocol=udp
        ...     bandwidth=1500M
        ...     port=5035
    BuiltIn.sleep     120
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1500 Mbits/sec
    ...     deviation=10%
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    500   ###sleep time for packaging log files in dcap tool
    ${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ...    timeout=${timeout}
    KeywordsCRT2.Counter_Value_Check    ${NRcell1_counters_path1}    @{3CC_Countervalues}
    #Verify Emil logs

Dput_SCell_2CC
    [Documentation]     Verification of TCP Downlink Carrier Aggregation data Tput and Buffer Based SCell activation for up to 2CC UEs
    [Tags]    QCD_MN_RAN    QCP_RAN_ST    5GCA    2cc    trunk    25R2
    ${start_date}=    Get Current Date
    at.setup_attenuator     ip_addr=${attenuator_host}     port=${attenuator_port}      attenuation_port_numbers=${at_channel}
    ...  vendor=${at_vendor}       model=${at_model}
    at.set_ports_attenuation    ${ports_fjt}    ${cavalues0}    confirm=True    confirmation_delay=5s
    at.setup_attenuator  ip_addr=${attenuator_host}  port=${attenuator_port}  attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}  model=${at_model}
    at.set_ports_attenuation    ${ports_ahpmda}    ${cavalues0}    confirm=True    confirmation_delay=5
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
    #RETURN    ${trace_id}
    ue.Require ue    ue_alias=UE_2    capabilities=REAL_QUALCOMM_UE
    ue.Detach Ue     ue_alias=UE_2
    ue.Attach Ue     ue_alias=UE_2
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
    BuiltIn.sleep     120
    ue.Stop Data Transfer    dt_name=DT_1
    Run keyword and Continue on Failure     ue.Verify Average Throughput With Deviation
    ...     dt_name=DT_1
    ...     tput=1100 Mbits/sec
    ...     deviation=10%
    ${end_date}=    Get Current Date
    dcap.stop_trace    ${trace_id}    timeout=${dcap_log_timeout}
    BuiltIn.sleep    300   ###sleep time for packaging log files in dcap tool
    ${dcap_file_name}=   dcap.get_results    result_id=${trace_id}    target_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ...    timeout=${timeout}
    KeywordsCRT2.Counter_Value_Check    ${NRcell1_counters_path1}    @{2CC_Countervalues}
    at.setup_attenuator    ip_addr=${attenuator_host}     port=${attenuator_port}     attenuation_port_numbers=${at_channel_ahpmda}
    ...  vendor=${at_vendor}      model=${at_model}
    at.set_ports_attenuation    ${ports_ahpmda}    ${cavalues0}    confirm=True    confirmation_delay=5
    Verify Emil logs    /${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/UTFLab_start_*.zip    @{emil_values}
    #Emil decoding in csv to specific folder with callable filter    126
    #DCAP_EMIL_DECODER    /home/ute/UTFLab_start_trace_2025-02-12T06_25_00.544Z.zip

##########CB010992Sceanrio##########

CB010992_Scenarios
	[Documentation]     CB010992 Trigger Cell Switch Off for NR and LTE and ORU Energy Saving
    	[Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    CB010992    CELLSO    NR    trunk    25R2
	LOG TO CONSOLE    \n Updating day and time and configuring new SCF
	Get Time and update SCF for Power Saving Parameters
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[0]
	LOG TO CONSOLE    \n Commissioning new SCF with latest date and time for Cell and ORU Switch OFF
	SCF commissioning    ${output_File}
	Wait Until Keyword Succeeds    15min    10s    Validate_BTS_STATUS    ${Required_bts_status}[1]
	LOG TO CONSOLE    \n SETUP IS UP and ONAIR
	BuiltIn.Sleep    400
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE1}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE2}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR1}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR2}    ${CellState}[0]
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[1]
	BuiltIn.Sleep    30
	BuiltIn.Sleep    1000
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE1}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLLTE2}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR1}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check Energy saving State    ${OFEGSACELLNR2}    ${CellState}[1]
	Wait Until Keyword Succeeds    15min    60s    Check RU Powerstate    ${RMODOFEGSA}    ${ORUState}[0]
	Block all cells Except OFEGSA
	Run Keyword And Continue On Failure    Place Calls On Cells
    Unblock all cells Except OFEGSA

CB010358_LTE5669_CB005735_Verification of CB005735_configuration_activation_and_deactivation with LTE-NR Slim DSS Carrier 20 MHz
    [Documentation]     CB010358 ABIP DSS Case where we try to check for CRM Commits
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    CB010358    DSS    25R2    trunk
    #coam.setup_admin
    #DssPreconditions      ${DSS_SCF_FILE}
    Block all cells Except OFEGSA DSS cells
    Run Keyword and Continue On Failure    Initiate the TCP Downlink and uplink data transfer    ${UE_alias3}    ${capabilities3}
    Unblock all cells Except OFEGSA DSS cells
    Stop BTS logs_DSS
    Wait For CRM Message In Syslog

CNI121537EPEcounters
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    25R2    trunk    121537    NR

    Wait Until Keyword Succeeds     10m    10s    Check_BTS_State
    Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
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
    Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue_disable}
    Wait Until Keyword Succeeds     5m    10s    Check_BTS_State

RFDiagnosticsCB009556
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    25R2    trunk    9556    NR
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

CB007814Ftds
    [Documentation]     CB007814-F_Verification of site moving to TDS and then back to normal state
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    NR    tds    trunk

    PerformRecommissioning    ${commonSCFpath}/${scf_OFEGSA}
    Wait Until Keyword Succeeds    15min    10s    Validate_BTS_STATUS    ${Required_bts_status}[1]
    move_to_test_dedicated_state_Enable
    Run Keyword And Continue On Failure    KeywordsCRT2.start_downlinkNr_test
    Run Keyword And Continue On Failure   KeywordsCRT2.stop_downlinkNr_test
    move_to_test_dedicated_state_Disable
	PerformRecommissioning    ${master_scf_file}
    Wait Until Keyword Succeeds     15m    10s    Ensure cells are enabled

AntenalinemonitorCB009556
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST    trunk    25R2    NR    ant9556

    PerformRecommissioning    ${scf_config2}
    Wait Until Keyword Succeeds     15m    10s    Ensure cells are enabled
    Antenalinemonitor    ${time}
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
    PerformRecommissioning    ${master_scf_file}
    Wait Until Keyword Succeeds     15m    10s    Ensure cells are enabled
