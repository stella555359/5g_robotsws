*** Settings ***
Documentation
...     [Procedure]    "Link Aggregation Support for Backhaul"
...     [Author]    "Sahana TC Santhosh KG"
...     [Maintenance]    "TRS I & V Tools Bangalore Team"
...     [QC_Path]    "QC_Path in Test Plan"
...     [QC_ID]    "QC_ID in Test Lab For Reporting"
...     [Feature_ID]    "CB006666"
...     [Requirement ID]    "TT_NCONF.1979;TT_NCONF.1999;TT_NCONF.2342;TT_NCONF.2360; TT_L2.2735; TT_L2.2710"
...     [Funtion_Hash_Tags]    "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]    "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]    "LAGRP under TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]   "bts_id is provided at run time."

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Configure LAG on Switch and BTS
    [ARGUMENTS]      ${switch_config}      ${bts_config}
    Configure Switch    device=l3switch    command_profile=${switch_config}
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=200
    Sleep   50
    Verify BTS Status     should_be_onair=${True}     rat=5g

Configure Master BTS AS
    Configure Switch    device=l3switch    command_profile=asib_master_chained
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${False}     timeout=300     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandby}        timeout=200    alias=default
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk5_path}    value=${ethlk_state_lock}    operation=update
    Sleep    100

Configure Master BTS AA
    Configure Switch    device=l3switch    command_profile=asib_master_chained
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${False}     timeout=300     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveActive}        timeout=200    alias=default
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk5_path}    value=${ethlk_state_lock}    operation=update
    Sleep    100

Configure Slave BTS AS
    Log     Configure Slave BTS with LAG ON_AIR_2212_AS.xml before start of the TC execution and ethlk-3 shall be locked

Configure Slave BTS AA
    Setup Mplane Connection with Chained BTS
    Run Keyword And Ignore Error    Perform Recommissioning    type=delta    delta_file=${Ethlk12unlock_3lock_createAA_lag}
    ...        timeout=200      alias=mplane

Configure Master BTS Static
    Log     Configure Slave BTS with M plane reachable xml with ethlk3 alone enabled
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=300     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateStaticLag}        timeout=200
    Sleep   100

Configure Slave BTS Static
    Setup Mplane Connection with Chained BTS
    Run Keyword And Ignore Error    Perform Recommissioning    type=delta    delta_file=${CreateStaticLag_unlockP1and2_lockP3}
    ...        timeout=200      alias=mplane

Setup Mplane Connection with Chained BTS
    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane

Remove Static LAG From Master and Slave BTS
    Run Keyword And Ignore Error    Perform Recommissioning     type=delta    delta_file=${Ethlk12lock_3unlock_deleteLag}
    ...        timeout=200    alias=mplane
    Perform Recommissioning     type=delta    delta_file=${DeleteLAGActiveActive}        timeout=200
    Configure Switch    device=l3switch    command_profile=remove_chained_asil_slave
    Sleep   200
    Setup Mplane Connection with Chained BTS
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane

Remove LAG From Master and Slave BTS
    Run Keyword And Ignore Error        Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveStandbyC}
    ...       timeout=300      alias=mplane
    Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveStandby}        timeout=300
    Sleep   100
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane

Remove LAG From Master and disable lag Slave BTS
    Run Keyword And Ignore Error        Perform Recommissioning     type=delta    delta_file=${Ethlk12lock_3unlock_deleteLag}
    ...      timeout=300     alias=mplane
    Perform Recommissioning     type=delta    delta_file=${DeleteLAGActiveStandby}        timeout=300
    Configure Switch    device=l3switch    command_profile=remove_chained_asil_slave
    Sleep   300
    Setup Mplane Connection with Chained BTS
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane

Verify BTS Status Master and Slave
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane

Check LAG on Master and Slave
    Check LAG and Port Status       enabled       ACTIVE_ENABLED        STANDBY_ENABLED
    Check LAG and Port Status Mplane      enabled       ACTIVE_ENABLED        STANDBY_ENABLED

Check LAG on Master and Slave AA
    Check LAG and Port Status       enabled      ACTIVE_ENABLED       ACTIVE_ENABLED
    Check LAG and Port Status Mplane      enabled      ACTIVE_ENABLED       ACTIVE_ENABLED

Configure Two LAGRP on Switch and BTS AS
    Configure LAG on Switch and BTS Optical Ports AS
    Configure LAG on Switch and BTS Electrical Ports AS1

Configure Two LAGRP on Switch and BTS AA
    Configure LAG on Switch and BTS Optical Ports AA
    Configure LAG on Switch and BTS Electrical Ports AA

Verify LAG Switchover by LOS Restoration and Alarm degradation For Two LAGRP
    Verify LAG Switchover by LOS Restoration and Alarm degradation LAGRP1
    Verify LAG Switchover by LOS Restoration and Alarm degradation Elec LAGRP2

Verify LAG Switchover by LOS Restoration and Alarm degradation For Two LAGRP AA
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA LAGRP1
    Verify LAG Switchover by LOS Restoration and Alarm degradation AA Elec LAGRP2

Verify Two LAGRP Switchover by LOS
    Verify LAG Switchover by LOS1
    Verify LAG Switchover by LOS Elec For Two LAGRP

Verify Two LAGRP Switchover by LOS AA
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Elec For Two LAGRP

Verify Two LAG Parameters in LAPCDUs
    Verify LAG Parameters in LAPCDUs
    Verify LAG Parameters in LAPCDUs Elec

Verify Two LAG Parameters in LAPCDUs AA
    Verify LAG Parameters in LAPCDUs AA
    Verify LAG Parameters in LAPCDUs AA Elec

Check Two LAGRPs and Port Status AA
    Check LAG and Port Status AA
    Check LAG and Port Status AA Elec

Check Two LAGRPs and Port Status
    Check LAG and Port Status1
    Check LAG and Elec Port Status1

Remove LAG Configuration From BTS and Switch AS Two LAGRP
    Remove LAG Configuration From BTS and Switch AS
    Remove LAG Configuration From BTS and Switch AS Elec

Remove LAG Configuration From BTS and Switch AA Two LAGRP
    Remove LAG Configuration From BTS and Switch AA
    Remove LAG Configuration From BTS and Switch AA Elec

Configure LAG on BTS With Different Physical type
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${LAGDifSpeed}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_dif_phy_type}

Configure BFD
    Perform Recommissioning    type=delta    delta_file=${CreateBFDSession}        timeout=300

Verify No LACP When BTS And Switch In Passive
    Configure Switch    device=l3switch    command_profile=dynamic_lag_passive
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPassive}        timeout=200
    Sleep   5
    Verify No LACPDUs     bts1      bts2       nolag_a     nolag_s    lag_active_0     lag_standby_0
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveStandby}

Reload BTS And Switch
    Configure Switch    device=l3switch    command_profile=teardown_lag
    Sleep    10
    Run Keyword And Ignore Error       Perform Recommissioning    type=delta    delta_file=${DeleteLAG}        timeout=200

Perform Switchover
    Configure Switch    device=l3switch    command_profile=port_shut1
    Sleep   10
    Check LAG and Port Status       enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify BTS Status     should_be_onair=${True}      rat=5g

Reload Switchover
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Sleep     15
    Check LAG and Port Status       enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}      rat=5g

Configure LAG on Switch and BTS Optical Ports As Passive
    Configure Switch    device=l3switch    command_profile=dynamic_lag_passive
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPassive}        timeout=600
    Sleep   50
    Verify BTS Status     should_be_onair=${True}     rat=5g

Verify LAG Switchover by LOS
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${False}
    Run Keywords in Parallel   Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    ...      AND       Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    ...      AND     Configure Switch    device=l3switch    command_profile=port_shut1
    Stop Calls
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify BFD     bfd     bfd
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Reset Bts       should_be_onair=${True}      rat=5g
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Configure Switch    device=l3switch    command_profile=port_shut2
    Sleep   10
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=2    severity=critical    should_exist=True

Verify LAG Switchover by LOS1
    Configure Switch    device=l3switch    command_profile=port_shut1
    Sleep   10
    Check Dynamic LAG and Port Status After Switchover1
    Verify BFD
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Reset Bts       should_be_onair=${True}      rat=5g
    Check Dynamic LAG and Port Status After Switchover1
    Configure Switch    device=l3switch    command_profile=port_shut2
    Sleep   10
    Check LAG and Port Status as Disabled1
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=2    severity=critical    should_exist=True

Verify Topp After LAG Switchover
    Configure Switch    device=l3switch    command_profile=port_shut1
    Sleep   30
    Check LAG and Port Status     enabled       DISABLED      ACTIVE_ENABLED
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Configure Switch    device=l3switch    command_profile=port_noshut1

Verify LAG Switchover by LOS Restoration and Alarm degradation
    Configure Switch    device=l3switch    command_profile=port_noshut2
    Sleep  10
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA
    Configure Switch    device=l3switch    command_profile=port_noshut2
    Sleep  10
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Check LAG and Port Status AA Mplane
    Setup Oamops        bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState      alias=mplane
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus     alias=mplane
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

Check LAG and Port Status
    [ARGUMENTS]     ${OperationState}        ${Port1Status}       ${Port2Status}
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${OperationState}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${Port1Status}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${Port2Status}

Check LAG and Port Status Mplane
    [ARGUMENTS]        ${OperationState}        ${Port1Status}       ${Port2Status}
    Setup Oamops        bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState     alias=mplane
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${OperationState}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus       alias=mplane
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${Port1Status}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${Port2Status}

Check LAG and Port Status Slave When ETHLK Locked
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState        alias=mplane
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus      alias=mplane
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

Verify LAG Parameters in LAPCDUs
     [Arguments]           ${bts1}        ${bts2}         ${pcap_name1}       ${pcap_name2}       ${analysis1}       ${analysis2}
     Traffic Capture Start        capture_device=${bts1}          alias=${pcap_name1}
     Traffic Capture Start        capture_device=${bts2}          alias=${pcap_name2}
     Sleep    30
     ${pcap_name1}=                Traffic Capture Stop    alias=${pcap_name1}
     ${pcap_name2}=                Traffic Capture Stop    alias=${pcap_name2}
     Set Suite Variable            ${pcap_name1}
     Set Suite Variable            ${pcap_name2}
     Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis1}
     Analyse Pcap    pcap_filename=${pcap_name2}   analysis=${analysis2}

Verify BFD
    [Arguments]           ${pcap_name1}            ${analysis1}
    Traffic Capture Start        capture_device=bts          alias=${pcap_name1}
    Sleep    30
    ${pcap_name1}=                Traffic Capture Stop    alias=${pcap_name1}
    Set Suite Variable            ${pcap_name1}
    Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis1}

Verify LAG Parameters in Master BTS
    [ARGUMENTS]        ${bts1}      ${bts2}       ${pcap_name1}       ${pcap_name2}       ${analysis1}      ${analysis2}
    ...      ${analysis3}      ${analysis4}
    Traffic Capture Start        capture_device=${bts1}          alias=${pcap_name1}
    Traffic Capture Start        capture_device=${bts2}          alias=${pcap_name2}
    Sleep    30
    ${pcap_name1}=                Traffic Capture Stop    alias=${pcap_name1}
    ${pcap_name2}=                Traffic Capture Stop    alias=${pcap_name2}
    Set Suite Variable            ${pcap_name1}
    Set Suite Variable            ${pcap_name2}
    Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis1}
    Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis2}
    Analyse Pcap    pcap_filename=${pcap_name2}   analysis=${analysis3}
    Analyse Pcap    pcap_filename=${pcap_name2}   analysis=${analysis4}

Remove LAG Configuration From BTS and Switch
    [ARGUMENTS]       ${switch_config}       ${bts_config}
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=300
    Sleep   5
    Configure Switch    device=l3switch    command_profile=${switch_config}
    Sleep    100
    Verify BTS Status     should_be_onair=${True}      rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active

Verify No LACPDUs
    [Arguments]           ${bts1}       ${bts2}      ${pcap_name1}       ${pcap_name2}       ${analysis1}       ${analysis2}
    Traffic Capture Start        capture_device=${bts1}          alias=${pcap_name1}
    Traffic Capture Start        capture_device=${bts2}          alias=${pcap_name2}
    Sleep    30
    ${pcap_name1}=                Traffic Capture Stop    alias=${pcap_name1}
    ${pcap_name2}=                Traffic Capture Stop    alias=${pcap_name2}
    Set Suite Variable            ${pcap_name1}
    Set Suite Variable            ${pcap_name2}
    Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis1}
    Analyse Pcap    pcap_filename=${pcap_name2}   analysis=${analysis2}

Change Port Priority And Verify LAG
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPortSystemPriority}        timeout=300
    Verify LAG Parameters in LAPCDUs      bts1      bts2     lag_po_change_s    lag_po_change_a    lag_po_change_s    lag_po_change_a
    Sleep    30
    Check LAG and Port Status      enabled       STANDBY_ENABLED      ACTIVE_ENABLED
    Perform Recommissioning    type=delta    delta_file=${DeleteLAGPortSystemPriority}        timeout=600
    Configure Switch    device=l3switch    command_profile=remove_lag

Check LAG and Opt Port Status P2 Active P1 Standby
    ${lag_status_dict}=     Query Admin Infomodel    query=get object ${LAGRP1}
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Match     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${STANDBY}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

LAG Status When ETHLK Locked
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    Sleep   5
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    Sleep   100
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandby}        timeout=300
    Sleep   100
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    Remove LAG Configuration From BTS and Switch       remove_lag      ${DeleteLAGActiveStandby}

Static LAG Status When ETHLK Locked
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    Sleep   10
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    Check LAG and Port Status      enabled    ACTIVE_ENABLED     ACTIVE_ENABLED

Static LAG Swithover Using LOS
    Configure Switch    device=l3switch    command_profile=port_shut1
    Sleep    20
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify BFD      bfd      bfd
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Ping Success
    Reset Bts      should_be_onair=${True}     rat=5g
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=port_shut2
    Sleep    15
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Check Ping Failure
    Configure Switch    device=l3switch    command_profile=port_noshut2
    Sleep    15
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Check Ping Success
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Sleep    15
    Check LAG and Port Status     enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active
    Check Ping Success

Check Dynamic LAG and Port Status After Switchover
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

Check Dynamic LAG and Port Status After Switchover1
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1_1}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1_1}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

Check Dynamic LAG and Port Status After Switchover Slave
    [ARGUMENTS]     ${operationalState}      ${Port1Status}       ${Port2Status}
    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState        alias=mplane
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${operationalState}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus    alias=mplane
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${Port1Status}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}    ${Port2Status}

Check Ping Success
    Setup Remote Access     remote_device=bts     alias=co
    ${ping_mme}=      Execute Interactive Remote Command      command=ping -c 10 ${mme}     alias=co
    ${ping_amf}=      Execute Interactive Remote Command      command=ping -c 10 ${amf}     alias=co
    Sleep    10
    Should Contain    ${ping_mme}    ${packet_loss}
    Should Contain    ${ping_amf}    ${packet_loss}
    Teardown Remote Access     alias=co

Check Ping Success Slave
    Setup Remote Access     remote_device=btschained     alias=chain
    ${ping_amf}=      Execute Interactive Remote Command      command=ping -c 10 ${amf}     alias=mplane
    Sleep    10
    Should Contain    ${ping_amf}    ${packet_loss}
    Teardown Remote Access     alias=chain

Check Ping Failure
    Setup Remote Access     remote_device=bts     alias=co
    ${ping_mme}=      Execute Interactive Remote Command      command=ping -c 10 ${mme}     alias=co
    ${ping_amf}=      Execute Interactive Remote Command      command=ping -c 10 ${amf}     alias=co
    Sleep    10
    Should Not Contain    ${ping_mme}    ${packet_loss}
    Should Contain    ${ping_amf}    ${packet_loss}
    Teardown Remote Access     alias=co

Configure LAG on Switch and BTS Electrical Ports AS1
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e2
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyE1}        timeout=300
    Sleep   50
    Verify BTS Status     should_be_onair=${True}     rat=5g

Change LACP Periodic Time
    Configure Switch    device=l3switch    command_profile=slow_lacp_periodic
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyESlowPeriodic}        timeout=300
    Sleep   100
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify lacp periodic time      bts3      bts4      lag_a30     lag_s30      lag_active_e30      lag_standby_e30
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveStandbyE}

Port Removal From LAGRP AS
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${Remove_Port}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_rule_as}
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED

Port Removal From LAGRP AA
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${Remove_Port}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_rule_aa}
    Check LAG and Port Status         enabled       ACTIVE_ENABLED       ACTIVE_ENABLED

Verify LAG Switchover by LOS Elec
    Configure Switch    device=l3switch    command_profile=port_shut3
    Sleep   20
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify BFD       bfd       bfd
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status      should_be_onair=${True}      rat=5g
    Reset BTS       should_be_onair=${True}       rat=5g
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Configure Switch    device=l3switch    command_profile=port_shut4
    Sleep   10
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=2    severity=critical    should_exist=True

Verify LAG Switchover by LOS Elec For Two LAGRP
    Configure Switch    device=l3switch    command_profile=port_shut3
    Sleep   20
    Check Dynamic LAG and Port Status After Switchover Elec1
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    occurrences=1    severity=major    should_exist=True
    Verify Alarm    faultid=61029    occurrences=3    severity=critical    should_exist=True
    Verify BTS Status      should_be_onair=${True}      rat=5g
    Configure Switch    device=l3switch    command_profile=port_shut4
    Sleep   10
    Check LAG and Port Status as Disabled Elec1
    Verify Alarm    faultid=61662    occurrences=2      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=4    severity=critical    should_exist=True

Check TOPP Unicast Availability After Switchover
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}

Static LAG Swithover Using LOS Elec
    Configure Switch    device=l3switch    command_profile=port_shut3
    Sleep    15
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify BFD     bfd     bfd
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Ping Success
    Reset Bts      should_be_onair=${True}     rat=5g
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Configure Switch    device=l3switch    command_profile=port_shut4
    Sleep    15
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Check Ping Failure
    Configure Switch    device=l3switch    command_profile=port_noshut4
    Sleep    15
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Check Ping Success
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=port_noshut3
    Sleep    15
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active
    Check Ping Success

Check Dynamic LAG and Port Status After Switchover Elec1
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1_2}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1_2}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}

Check LAG and Port Status as Disabled Elec1
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1_2}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${DISABLE1}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1_2}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${DISABLE2}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA Elec
    Configure Switch    device=l3switch    command_profile=port_noshut4
    Sleep  10
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut3
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED        ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA Elec LAGRP2
    Configure Switch    device=l3switch    command_profile=port_noshut4
    Sleep  10
    Check Dynamic LAG and Port Status After Switchover Elec
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut3
    Sleep  10
    Check LAG and Port Status AA Elec
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation Elec
    Configure Switch    device=l3switch    command_profile=port_noshut4
    Sleep  15
    Check LAG and Port Status      enabled       DISABLED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut3
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation Elec LAGRP2
    Configure Switch    device=l3switch    command_profile=port_noshut4
    Sleep  15
    Check Dynamic LAG and Port Status After Switchover Elec1
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=port_noshut3
    Sleep  10
    Check LAG and Elec Port Status1
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Check LAG and Elec Port Status1
    ${lag_status_dict}=     Query Admin Infomodel    query=get object ${LAGRP1_2}
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Match     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${STANDBY}

Remove LAG Configuration From BTS and Switch AS Elec1
    Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveStandbyE1}        timeout=300
    Sleep   5
    Configure Switch    device=l3switch    command_profile=remove_lag_e
    Sleep    100
    Verify BTS Status     should_be_onair=${True}      rat=5g

Verify lacp periodic time
    [Arguments]           ${bts1}        ${bts2}         ${pcap_name1}       ${pcap_name2}       ${analysis1}       ${analysis2}
    Traffic Capture Start        capture_device=${bts1}          alias=${pcap_name1}
    Traffic Capture Start        capture_device=${bts2}          alias=${pcap_name2}
    Sleep    100
    ${pcap_name1}=                Traffic Capture Stop    alias=${pcap_name1}
    ${pcap_name2}=                Traffic Capture Stop    alias=${pcap_name2}
    Set Suite Variable            ${pcap_name1}
    Set Suite Variable            ${pcap_name2}
    Analyse Pcap    pcap_filename=${pcap_name1}   analysis=${analysis1}
    Analyse Pcap    pcap_filename=${pcap_name2}   analysis=${analysis2}

Change Port Priority And Verify LAG Elec
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPortSystemPriorityE}        timeout=300
    Verify LAG Parameters in LAPCDUs       bts3       bts4      lag_po_change_s1       lag_po_change_a1      lag_po_change_s_e
    ...       lag_po_change_a_e
    Check LAG and Port Status      enabled      STANDBY_ENABLED      ACTIVE_ENABLED
    Perform Recommissioning    type=delta    delta_file=${DeleteLAGPortSystemPriorityE}        timeout=300
    Configure Switch    device=l3switch    command_profile=remove_lag_e

LAG Status When ETHLK Locked Elec
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e
    Sleep   5
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    Sleep   100
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyE}        timeout=300
    Sleep   100
    Check LAG and Port Status      disabled       DISABLED      DISABLED
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_unlock}    operation=update
    Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveStandbyE}

Verify Switchover in Master BTS and Restoration
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    Sleep   15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True       alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}        alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True        alias=mplane
    Check LAG and Port Status      enabled       DISABLED       ACTIVE_ENABLED
    Verify BTS Status Master and Slave
    Perform Recommissioning    type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    occurrences=1     severity=major    should_exist=True
    Check LAG and Port Status       disabled      DISABLED      DISABLED
    Perform Recommissioning    type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check LAG and Port Status      enabled       DISABLED       ACTIVE_ENABLED
    Reset BTS       should_be_onair=${True}     rat=5g
    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True   alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True    alias=mplane
    Check LAG and Port Status      enabled       DISABLED       ACTIVE_ENABLED
    Verify BTS Status Master and Slave
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Dynamic LAG and Port Status After Switchover Slave      enabled       DISABLED       ACTIVE_ENABLED
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    Sleep    15
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update  alias=mplane
    Sleep    15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True   alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Check Dynamic LAG and Port Status After Switchover Slave      enabled       DISABLED       ACTIVE_ENABLED
    Check LAG and Port Status       enabled       DISABLED       ACTIVE_ENABLED
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update    alias=mplane
    Sleep    15
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Configure LAG Via Netact
    Configure Switch    device=l3switch    command_profile=enable_eif3_netact
    Sleep     50
    Setup Ems    config_device=netact1042    alias=lab1042
    Cm Upload   config_device=netact1042   alias=lab1042
    Configuration Manage    config_device=netact1042   config=lag_netact.json    plan_name=lag_create   delete_plan="True"   alias=lab1042
    Sleep     20
    Configure Switch    device=l3switch    command_profile=enable_lag_netact
    Sleep     60
    Check LAG and Port Status       enabled       ACTIVE_ENABLED        STANDBY_ENABLED

Verify Switchover in Master BTS and Restoration Using LACP Timeout
    Run Keyword And Ignore Error    Perform Recommissioning     type=delta      delta_file=${DeletePortFromLAG}
    ...    skip_parameter_relation_errors=${True}      timeout=200     alias=mplane
    Check LAG and Port Status      enabled       DEFAULTED       ACTIVE_ENABLED
    Sleep   15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Perform Recommissioning    type=delta    delta_file=${AddPortToLAG}        timeout=200        alias=mplane
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}

Static LAG Status When ETHLK Locked Elec
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    Sleep   10
    Check LAG and Port Status      disabled      DISABLED      DISABLED
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_unlock}    operation=update
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED

Verify LAG Switchover by LACP Timeout Elec
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${False}
    Run Keywords in Parallel   Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    ...      AND       Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    ...      AND     Configure Switch    device=l3switch    command_profile=stop_lacp3
    Stop Calls
    Sleep     20
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify BFD      bfd      bfd
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status      should_be_onair=${True}      rat=5g
    Reset BTS       should_be_onair=${True}     rat=5g
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=stop_lacp4
    Sleep   10
    Check LAG and Port Status      disabled       DEFAULTED      DEFAULTED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LACP Restoration and Alarm degradation AA
    Configure Switch    device=l3switch    command_profile=start_lacp4
    Sleep  10
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=start_lacp3
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LACP Restoration and Alarm degradation Elec
    Configure Switch    device=l3switch    command_profile=start_lacp4
    Sleep  15
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=start_lacp3
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LACP Timeout
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${False}
    Run Keywords in Parallel   Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    ...      AND       Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    ...      AND     Configure Switch    device=l3switch    command_profile=stop_lacp1
    Stop Calls
    Sleep     20
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify BFD     bfd      bfd
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Reset Bts       should_be_onair=${True}     rat=5g
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=stop_lacp2
    Sleep   10
    Check LAG and Port Status      disabled       DEFAULTED      DEFAULTED
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation by LACP Timeout
    Configure Switch    device=l3switch    command_profile=start_lacp2
    Sleep  10
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=start_lacp1
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      STANDBY_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA by LACP Timeout
    Configure Switch    device=l3switch    command_profile=start_lacp2
    Sleep  10
    Check LAG and Port Status      enabled       DEFAULTED      ACTIVE_ENABLED
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Configure Switch    device=l3switch    command_profile=start_lacp1
    Sleep  10
    Check LAG and Port Status      enabled       ACTIVE_ENABLED      ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Modify Port priority and Verify LAG Status
    Perform Recommissioning     type=delta      delta_file=${PortUpdate1}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status      enabled        STANDBY_ENABLED        ACTIVE_ENABLED
    Perform Recommissioning     type=delta      delta_file=${PortUpdate2}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status      enabled        ACTIVE_ENABLED        STANDBY_ENABLED
    Perform Recommissioning     type=delta      delta_file=${PortUpdate3}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status      enabled        STANDBY_ENABLED        ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g

Modify System priority and Verify LAG Status
    Log     BTS Low System Priority Switch High System Priority - Switch considered as Actor followed with Port numbers of Switch
    Perform Recommissioning     type=param  param_path=${lag_systempriority}    value=${system_priority1}    operation=update
    Check LAG and Port Status      enabled        ACTIVE_ENABLED        STANDBY_ENABLED
    Log     BTS And Switch Same System Priority and Same Port Priority - BTS having lower MAC considered as Actor followed
    ...     with Port numbers of BTS
    Perform Recommissioning     type=param  param_path=${lag_systempriority}    value=${system_priority2}    operation=update
    Check LAG and Port Status      enabled        STANDBY_ENABLED        ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}     rat=5g

Check LAG and Port Status AAA Port3 Addition
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState
    Log   ${lag_status_dict}
    Should Match     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Match    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Match    ${port2}   ${ACTIVE}
    ${port_status3}=   Get From List    ${port_operational_status}   2
    Log   ${port_status3}
    ${port3}=  Get From Dictionary    ${port_status3}   portState
    Log   ${port3}
    Should Match    ${port3}   ${ACTIVE}

Add Port and Delete Port
    Configure Switch    device=l3switch    command_profile=add_port3
    Sleep   5
    Perform Recommissioning     type=delta      delta_file=${AddPort}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status AAA Port3 Addition
    Verify BTS Status     should_be_onair=${True}      rat=5g
    Configure Switch    device=l3switch    command_profile=delete_port3
    Perform Recommissioning     type=delta      delta_file=${DeletePort}     skip_parameter_relation_errors=${True}      timeout=300
    Sleep   5
    Check LAG and Port Status      enabled        ACTIVE_ENABLED        ACTIVE_ENABLED
    Verify BTS Status     should_be_onair=${True}      rat=5g

Make 5G Calls
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${False}
    Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    Sleep    20
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_100M_ul
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_100M_dl
    Call Teardown    5g=device_3:data

Stop Calls
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_10M_ul
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_10M_dl
    Call Teardown    5g=device_3:data

Configure IPSEC
    Install BTS Certificates
    Configure Switch    device=l3switch1    command_profile=add_route
    Perform Recommissioning    type=delta    delta_file=${ConfigIpsec}        timeout=200

Remove IPSEC
    Configure Switch    device=l3switch1    command_profile=remove_route
    Perform Recommissioning    type=delta    delta_file=${DeleteIpsec}        timeout=200

Install BTS Certificates
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${IP_BTSCertpass}       key_pool_type=RSA
    Sleep    20
