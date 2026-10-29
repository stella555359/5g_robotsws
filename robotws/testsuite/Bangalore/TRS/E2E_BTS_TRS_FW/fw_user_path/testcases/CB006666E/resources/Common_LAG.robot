** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***

Alarms before LAG
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=  Create List
    ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
    Sort List   ${pre_alarm_faultids}
    Set Suite Variable      ${pre_alarm_faultids}

Alarms after LAG
    ${post_reset_alarms}=    Verify Alarm    alarm_type=active
    ${post_reset_length}=    Get Length  ${post_reset_alarms}
    ${post_alarm_faultids}=  Create List
    ${post_alarm_faultids}=  Create fault id List    ${post_reset_alarms}
    Sort List   ${post_alarm_faultids}
    Set Suite Variable      ${post_alarm_faultids}
    should be equal    ${pre_alarm_faultids}    ${post_alarm_faultids}

Create fault id List
    [Arguments]     ${list}
    ${length}=  Get Length  ${list}
    ${list1}=   Create List
    FOR   ${i}    IN RANGE    ${length}
        Append To List  ${list1}    ${list[${i}]['faultId']}
    END
    [return]    ${list1}

Configure Normal ports without LAG
    Configure Switch    device=l3switch    command_profile=remove_lag
    Configure Switch    device=l3switch    command_profile=port_shut3

Configure LAG on Switch and BTS Optical Ports AS
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandby}        timeout=600
    BuiltIn.Sleep   200
    Verify BTS Status     should_be_onair=${True}     rat=5g


Lock Ethlk3 port
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_lock}    operation=update

Configure Two LAGRP on Switch and BTS AS
    Configure LAG on Switch and BTS Optical Ports AS
    Configure LAG on Switch and BTS Electrical Ports AS

Verify Two LAGRP Switchover by LOS
    Verify LAG Switchover by LOS
    Verify LAG Switchover by LOS Elec

Verify Two LAG Parameters in LAPCDUs
    Verify LAG Parameters in LAPCDUs
    Verify LAG Parameters in LAPCDUs Elec

Check Two LAGRPs and Port Status
    Check LAG and Port Status
    Check LAG and Elec Port Status

Configure Slave BTS Static
#    Log     Configure Slave BTS with M plane reachable xml with LAG ON_AIR_2213_Static.xml before start of the TC execution
    Setup Mplane Connection with Chained BTS
    Run Keyword And Ignore Error    Perform Recommissioning    type=delta    delta_file=${CreateStaticLag_unlockP1and2_lockP3}
    ...        timeout=300      alias=mplane

Configure Master BTS Static
#    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateStaticLag}        timeout=200

Configure Slave BTS port
    Configure Switch    device=l3switch    command_profile=shut_slave_eif3


Configure Master BTS AS
    Configure Switch    device=l3switch    command_profile=enable_eif3__master
    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandby}        timeout=200    alias=default
    BuiltIn.Sleep    100

Configure Master BTS AA
    Configure Switch    device=l3switch    command_profile=enable_eif3__master
#    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=600     alias=default
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveActive}        timeout=300    alias=default
    BuiltIn.Sleep    180


Setup Mplane Connection with Chained BTS
    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane

Check LAG on Master and Slave
    Check LAG and Port Status
    Check LAG and Port Status Mplane

Check LAG on Master and Slave AA
    Check LAG and Port Status AA
    Check LAG and Port Status AA Mplane




Verify BTS Status Master and Slave
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane

Remove LAG From Master and disable lag Slave BTS


    Run Keyword And Ignore Error    Perform Recommissioning     type=delta    delta_file=${Ethlk12lock_3unlock}        timeout=300    alias=mplane
    Perform Recommissioning     type=delta    delta_file=${DeleteLAGActiveStandby}        timeout=300
    Configure Switch    device=l3switch    command_profile=enable_eif3_slave
    BuiltIn.Sleep   50
#    Setup Mplane Connection with Chained BTS
    BuiltIn.Sleep   20
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane
    Teardown Oamops     alias=mplane

Remove LAG From Master and disable lag Slave BTS AA

    Run Keyword And Ignore Error    Perform Recommissioning     type=delta    delta_file=${Ethlk12lock_3unlock}        timeout=300    alias=mplane

    Perform Recommissioning     type=delta    delta_file=${DeleteLAGActiveActive}        timeout=300
    Configure Switch    device=l3switch    command_profile=enable_eif3_slave
    BuiltIn.Sleep   30
    Setup Mplane Connection with Chained BTS
    BuiltIn.Sleep   10
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane
    BuiltIn.Sleep   10
    Teardown Oamops     alias=mplane

Remove Static LAG From Master and Slave BTS

    Run Keyword And Ignore Error    Perform Recommissioning     type=delta    delta_file=${Ethlk12lock_3unlock_deleteLag}
    ...        timeout=300    alias=mplane

    Perform Recommissioning     type=delta    delta_file=${DeleteLAGActiveActive}        timeout=300
    Configure Switch    device=l3switch    command_profile=enable_eif3_slave
    BuiltIn.Sleep   90
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify BTS Status     should_be_onair=${True}     rat=5g     alias=mplane
    BuiltIn.Sleep   10
    Teardown Oamops     alias=mplane


Configure Slave BTS AS
    Log     Configure Slave BTS with M plane reachable xml with LAG Configuration_scf_MRBTS-2213_Chained_case_asil_as_master_AS_case.xml
    Log      from 2213_scfc_files before start of the TC execution
   Configure Switch    device=l3switch    command_profile=slave_asib_make_all_default


Configure Slave BTS AA
    Setup Mplane Connection with Chained BTS
#    BuiltIn.Sleep   60
    Run Keyword And Ignore Error    Perform Recommissioning    type=delta    delta_file=${Ethlk12unlock_3lock_createAA_lag}
    ...        timeout=300      alias=mplane
#    Teardown Oamops	alias=mplane


Configure LAG on BTS With Different Physical type
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${LAGDifSpeed}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_dif_phy_type}

Configure BFD
    Perform Recommissioning    type=delta    delta_file=${CreateBFDSession}        timeout=600


Change LACP Periodic Time
    Configure Switch    device=l3switch    command_profile=slow_lacp_periodic
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyslowPeriodicTime}        timeout=600
    BuiltIn.Sleep   200
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify lacp periodic time
    Remove LAG Configuration From BTS and Switch AS


Verify No LACP When BTS And Switch In Passive
    Configure Switch    device=l3switch    command_profile=dynamic_lag_passive
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPassive}        timeout=600
    BuiltIn.Sleep   5
    Verify No LACPDUs
    Remove LAG Configuration From BTS and Switch AS

Perform Switchover
    Configure Switch    device=l3switch    command_profile=port_shut1
    BuiltIn.Sleep   10
    Check Dynamic LAG and Port Status After Switchover
    Verify BTS Status     should_be_onair=${True}

Configure LAG on Switch and BTS Optical Ports As Passive
    Configure Switch    device=l3switch    command_profile=dynamic_lag_passive
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGPassive}        timeout=600
    BuiltIn.Sleep   200
    Verify BTS Status     should_be_onair=${True}     rat=5g

Configure Static Lag
    Configure Switch    device=l3switch    command_profile=static_lag
    BuiltIn.Sleep    5
    Perform Recommissioning    type=delta    delta_file=${CreateStaticLag}        timeout=600
    BuiltIn.Sleep    200
    Verify BTS Status     should_be_onair=${True}    rat=5g

Verify LAG Switchover by LOS
    Configure Switch    device=l3switch    command_profile=port_shut1
    BuiltIn.Sleep   10
    Check Dynamic LAG and Port Status After Switchover
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Reset Bts      should_be_onair=${True}     rat=5g    wait_for=600
    Check Dynamic LAG and Port Status After Switchover
    Configure Switch    device=l3switch    command_profile=port_shut2
    BuiltIn.Sleep   10
    Check LAG and Port Status as Disabled
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=2    severity=critical    should_exist=True

Verify LAG Switchover by LOS Restoration and Alarm degradation
    Configure Switch    device=l3switch    command_profile=port_noshut2
    BuiltIn.Sleep  20
    Check Dynamic LAG and Port Status After Switchover
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=port_noshut1
    BuiltIn.Sleep  10
    Check LAG and Port Status
    BuiltIn.Sleep  10
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA
    Configure Switch    device=l3switch    command_profile=port_noshut2
    BuiltIn.Sleep  20
    Check Dynamic LAG and Port Status After Switchover
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=port_noshut1
    BuiltIn.Sleep  20
    Check LAG and Port Status AA
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify Switchover in Master BTS and Restoration
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}

    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True       alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}        alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True        alias=mplane
    Check Dynamic LAG and Port Status After Switchover
    Verify BTS Status Master and Slave
    Perform Recommissioning    type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    occurrences=1     severity=major    should_exist=True
    Check LAG and Port Status as Disabled
    Perform Recommissioning    type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}

    Check Dynamic LAG and Port Status After Switchover
    Reset BTS       should_be_onair=${True}     wait_for=600
    BuiltIn.Sleep    10
#    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True   alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True    alias=mplane
    Check Dynamic LAG and Port Status After Switchover
    Verify BTS Status Master and Slave
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Dynamic LAG and Port Status After Switchover Slave
    Verify BTS Status    should_be_onair=${True}     rat=5g      alias=mplane
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update  alias=mplane
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True   alias=mplane
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alias=mplane
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Check Dynamic LAG and Port Status After Switchover Slave
    Check Dynamic LAG and Port Status After Switchover
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update    alias=mplane
    BuiltIn.Sleep    15
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}



Verify LAG Parameters in Master BTS AA
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture12}     alias=co
     Execute Interactive Remote Command     command=${start_capture22}     alias=co
     Execute Interactive Remote Command     command=${start_capture24}     alias=co
     BuiltIn.Sleep   10
     Get File From Remote Host    source=/user/toor4nsn/lag_am.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_a1m.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location22}   analysis=lag_active
     Analyse Pcap    pcap_filename=${pcap_file_location22}   analysis=lag_active_slave
     Analyse Pcap    pcap_filename=${pcap_file_location24}   analysis=lag_active1
     Analyse Pcap    pcap_filename=${pcap_file_location24}   analysis=lag_active1_slave
     Teardown Remote Access     alias=co



Check Dynamic LAG and Port Status After Switchover Slave
    Setup Oamops     bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Check LAG and Port Status AA Mplane
#    Setup Oamops        bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get param ${LAGRP1}:operationalState      alias=mplane
    Log   ${lag_status_dict}
    Should Contain     ${lag_status_dict}    ${ENABLE}
    ${port_operational_status}=     Query Admin Infomodel    query=get param ${LAGRP1}:portStatus     alias=mplane
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}





Check LAG and Port Status Mplane
#    Setup Oamops        bts_host=${MplaneChainBts}      timeout=120    alias=mplane
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${STANDBY}

Verify LAG Parameters in Master BTS
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture11}     alias=co
     Execute Interactive Remote Command     command=${start_capture22}     alias=co
     Execute Interactive Remote Command     command=${start_capture23}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_am.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_sm.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location22}   analysis=lag_active
     Analyse Pcap    pcap_filename=${pcap_file_location22}   analysis=lag_active_slave
     Analyse Pcap    pcap_filename=${pcap_file_location23}   analysis=lag_standby
     Analyse Pcap    pcap_filename=${pcap_file_location23}   analysis=lag_standby_slave
     Teardown Remote Access     alias=co


Check LAG and Port Status AA
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Configure LAG on Switch and BTS Optical Ports AA
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    BuiltIn.Sleep   10
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveActive}        timeout=600
    BuiltIn.Sleep   250
    Verify BTS Status     should_be_onair=${True}    rat=5g

Check LAG and Port Status
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${STANDBY}

Verify Topp After LAG Switchover
    Configure Switch    device=l3switch    command_profile=port_shut1
    BuiltIn.Sleep   300
    Check Dynamic LAG and Port Status After Switchover
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}
    Configure Switch    device=l3switch    command_profile=port_noshut1


Check LAG and Port Status as Disabled
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${DISABLE1}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${DISABLE2}

Verify LAG Parameters in LAPCDUs
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture}     alias=co
     Execute Interactive Remote Command     command=${start_capture}     alias=co
     Execute Interactive Remote Command     command=${start_capture1}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_a.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_s.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location}   analysis=lag_active
     Analyse Pcap    pcap_filename=${pcap_file_location}   analysis=loam
     Analyse Pcap    pcap_filename=${pcap_file_location1}   analysis=lag_standby
     Teardown Remote Access     alias=co

Verify LAG Parameters in LAPCDUs AA
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture2}     alias=co
     Execute Interactive Remote Command     command=${start_capture}     alias=co
     Execute Interactive Remote Command     command=${start_capture4}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_a.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_a1.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location}   analysis=lag_active
     Analyse Pcap    pcap_filename=${pcap_file_location}   analysis=loam
     Analyse Pcap    pcap_filename=${pcap_file_location4}   analysis=lag_active1
     Teardown Remote Access     alias=co

Remove LAG Configuration From BTS and Switch AS
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveStandby}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_lag
     BuiltIn.Sleep   250
     Verify BTS Status     should_be_onair=${True}     rat=5g
     Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
     Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active

Remove LAG Configuration From BTS and Switch AA
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveActive}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_lag
     BuiltIn.Sleep    200
     Verify BTS Status     should_be_onair=${True}      rat=5g
     Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
     Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active

Remove LAG Configuration From BTS and Switch Static Lag
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveActive}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_static_lag
     BuiltIn.Sleep    200
     Verify BTS Status     should_be_onair=${True}     rat=5g

Verify No LACPDUs
     Setup Remote Access     remote_device=bts     alias=co1
     Execute Interactive Remote Command     command=${remove_existing_capture1}     alias=co1
     Execute Interactive Remote Command     command=${start_capture2}     alias=co1
     BuiltIn.Sleep   55
     Execute Interactive Remote Command     command=${start_capture3}     alias=co1
     BuiltIn.Sleep   55
     Get File From Remote Host    source=/user/toor4nsn/nolag_a.pcap      destination=/home/ute    alias=co1
     Get File From Remote Host    source=/user/toor4nsn/nolag_s.pcap      destination=/home/ute    alias=co1
     Analyse Pcap    pcap_filename=${pcap_file_location2}   analysis=lag_active_0
     Analyse Pcap    pcap_filename=${pcap_file_location3}   analysis=lag_standby_0
     Teardown Remote Access     alias=co1

Change Port Priority And Verify LAG
     Configure Switch    device=l3switch    command_profile=dynamic_lag
     BuiltIn.Sleep   5
     Perform Recommissioning    type=delta    delta_file=${CreateLAGPortSystemPriority}        timeout=600
     Setup Remote Access     remote_device=bts     alias=co2
     Execute Interactive Remote Command     command=${remove_existing_capture3}     alias=co2
     Execute Interactive Remote Command     command=${start_capture5}     alias=co2
     Execute Interactive Remote Command     command=${start_capture6}     alias=co2
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_po_change_s.pcap      destination=/home/ute    alias=co2
     Get File From Remote Host    source=/user/toor4nsn/lag_po_change_a.pcap      destination=/home/ute    alias=co2
     Check LAG and Port Status P2 Active P1 Standby
     Analyse Pcap    pcap_filename=${pcap_file_location5}   analysis=lag_po_change_s
     Analyse Pcap    pcap_filename=${pcap_file_location6}   analysis=lag_po_change_a
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGPortSystemPriority}        timeout=600
     Configure Switch    device=l3switch    command_profile=remove_lag
     Teardown Remote Access     alias=co2

Check LAG and Port Status P2 Active P1 Standby
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${STANDBY}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

LAG Status When ETHLK Locked
    Configure Switch    device=l3switch    command_profile=dynamic_lag
    BuiltIn.Sleep   5
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep   100
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandby}        timeout=600
    BuiltIn.Sleep   100
    Check LAG and Port Status as Disabled
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    Remove LAG Configuration From BTS and Switch AS

Static LAG Status When ETHLK Locked
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep   10
    Check LAG and Port Status as Disabled
    Perform Recommissioning     type=param  param_path=${ethlk1_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk2_path}    value=${ethlk_state_unlock}    operation=update
    Check LAG and Port Status AA

Static LAG Swithover Using LOS
    Configure Switch    device=l3switch    command_profile=port_shut1
    BuiltIn.Sleep    15
    Check Static LAG and Port Status After Switchover
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Ping Success
#    Check call
    Reset Bts      should_be_onair=${True}     rat=5g       wait_for=600
    Check Static LAG and Port Status After Switchover
    Configure Switch    device=l3switch    command_profile=port_shut2
    BuiltIn.Sleep    15
    Check LAG and Port Status as Disabled
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
#    Check Ping Failure
#    Check call
    Configure Switch    device=l3switch    command_profile=port_noshut2
    BuiltIn.Sleep    15
    Check Static LAG and Port Status After Switchover
    Check Ping Success
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=port_noshut1
    BuiltIn.Sleep    15
    Check LAG and Port Status AA
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active
    Check Ping Success

Check Static LAG and Port Status After Switchover
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Check Dynamic LAG and Port Status After Switchover
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

#Ping to MME/AMF
Check Ping Success
       Setup Remote Access     remote_device=bts     alias=co
       ${ping_mme}=      Execute Interactive Remote Command      command=ping -c 10 100.70.20.75     alias=co
       BuiltIn.Sleep    10
       Should Contain    ${ping_mme}    ${packet_loss}
       Teardown Remote Access     alias=co

Check Ping Failure
       Setup Remote Access     remote_device=bts     alias=co
       ${ping_mme}=      Execute Interactive Remote Command      command=ping -c 10 100.70.20.75     alias=co
       BuiltIn.Sleep    10
       Should Not Contain    ${ping_mme}    ${packet_loss}
       Teardown Remote Access     alias=co

Configure LAG on Switch and BTS Electrical Ports AS
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyE}        timeout=600
    BuiltIn.Sleep   200
    Verify BTS Status     should_be_onair=${True}     rat=5g

Configure Static Lag Elec
    Configure Switch    device=l3switch    command_profile=static_lag_e
    BuiltIn.Sleep    5
    Perform Recommissioning    type=delta    delta_file=${CreateStaticLagE}        timeout=600
    BuiltIn.Sleep    200
    Verify BTS Status     should_be_onair=${True}     rat=5g

#Change LACP Periodic Time
#    Configure Switch    device=l3switch    command_profile=slow_lacp_periodic
#    BuiltIn.Sleep   5
#    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyESlowPeriodic}        timeout=600
#    BuiltIn.Sleep   200
#    Verify BTS Status     should_be_onair=${True}     rat=5g
#    Verify lacp periodic time
#    Check LAG and Elec Port Status
#    Remove LAG Configuration From BTS and Switch AS Elec

Port Removal From LAGRP AS
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${Remove_Port}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_rule_as}
    Check LAG and Elec Port Status Elec

Port Removal From LAGRP AA
    ${msg}=     Run Keyword And Expect Error    *   Perform Recommissioning     type=delta      delta_file=${Remove_Port}
    ...     skip_parameter_relation_errors=${False}      timeout=300
    Log    ${msg}
    Should Contain  ${msg}  AdminApiProcedureFailureException
    Should Contain  ${msg}  ${pdl_rule_aa}
    Check LAG and Port Status AA Elec

Verify LAG Switchover by LOS Elec
    Configure Switch    device=l3switch    command_profile=port_shut3
    BuiltIn.Sleep   20
    Check Dynamic LAG and Port Status After Switchover Elec
    Check TOPP Unicast Availability After Switchover
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status      should_be_onair=${True}      rat=5g
#   Ping/Call to Core should work here
    Reset Bts      should_be_onair=${True}     rat=5g       wait_for=600
    Check Dynamic LAG and Port Status After Switchover Elec
    Configure Switch    device=l3switch    command_profile=port_shut4
    BuiltIn.Sleep   10
    Check LAG and Port Status as Disabled Elec
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    occurrences=2    severity=critical    should_exist=True

Check TOPP Unicast Availability After Switchover
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_usable_key}    ${top_usability_status}

Static LAG Swithover Using LOS Elec
    Configure Switch    device=l3switch    command_profile=port_shut3
    BuiltIn.Sleep    15
    Check Static LAG and Port Status After Switchover
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Check Ping Success
    Reset Bts      should_be_onair=${True}     rat=5g       wait_for=600
    Check Static LAG and Port Status After Switchover
    Configure Switch    device=l3switch    command_profile=port_shut4
    BuiltIn.Sleep    15
    Check LAG and Port Status as Disabled
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Check Ping Failure
    Configure Switch    device=l3switch    command_profile=port_noshut4
    BuiltIn.Sleep    15
    Check Static LAG and Port Status After Switchover
    Check Ping Success
    Verify Alarm    faultid=61662    occurrences=1      severity=minor    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Configure Switch    device=l3switch    command_profile=port_noshut3
    BuiltIn.Sleep    15
    Check LAG and Port Status AA Elec
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active
    Check Ping Success

Check Static LAG and Port Status After Switchover Elec
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Check Dynamic LAG and Port Status After Switchover Elec
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Check LAG and Port Status as Disabled Elec
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${DISABLE1}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${DISABLE2}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA Elec
    Configure Switch    device=l3switch    command_profile=port_noshut4
    BuiltIn.Sleep  10
    Check Dynamic LAG and Port Status After Switchover Elec
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=port_noshut3
    BuiltIn.Sleep  10
    Check LAG and Port Status AA Elec
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Check LAG and Port Status AA Elec
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Verify LAG Switchover by LOS Restoration and Alarm degradation Elec
    Configure Switch    device=l3switch    command_profile=port_noshut4
    BuiltIn.Sleep  15
    Check Dynamic LAG and Port Status After Switchover Elec
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    occurrences=1    severity=critical    should_exist=True
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=port_noshut3
    BuiltIn.Sleep  10
    Check LAG and Elec Port Status
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    severity=critical    should_exist=${False}

Verify Static LAG Parameters
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Configure LAG on Switch and BTS Electrical Ports AA
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveActiveE}        timeout=600
    BuiltIn.Sleep   200
    Verify BTS Status     should_be_onair=${True}      rat=5g

Check LAG and Elec Port Status
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${STANDBY}

Check LAG and Port Status When ETHLK Locked
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-2
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${DISABLE1}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DISABLE2}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${DISABLE2}

Verify LAG Parameters in LAPCDUs Elec
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture4}     alias=co
     Execute Interactive Remote Command     command=${start_capture7}     alias=co
     Execute Interactive Remote Command     command=${start_capture8}     alias=co
     Execute Interactive Remote Command     command=${start_capture21}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_a1.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_s1.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/nolag.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location7}   analysis=lag_active_e
     Analyse Pcap    pcap_filename=${pcap_file_location8}   analysis=lag_standby_e
     Analyse Pcap    pcap_filename=${pcap_file_location21}   analysis=nolacp
     Teardown Remote Access     alias=co

Verify LAG Parameters in LAPCDUs AA Elec
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture7}     alias=co
     Execute Interactive Remote Command     command=${start_capture13}     alias=co
     Execute Interactive Remote Command     command=${start_capture14}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_a1.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_a1_1.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location13}   analysis=lag_active_e
     Analyse Pcap    pcap_filename=${pcap_file_location14}   analysis=lag_active1_e
     Teardown Remote Access     alias=co

Remove LAG Configuration From BTS and Switch AS Elec
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveStandbyE}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_lag_e
     BuiltIn.Sleep    200
     Verify BTS Status     should_be_onair=${True}      rat=5g

Remove LAG Configuration From BTS and Switch AA Elec
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveActiveE}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_lag_e
     BuiltIn.Sleep    250
     Verify BTS Status     should_be_onair=${True}      rat=5g

Remove LAG Configuration From BTS and Switch Static Lag Elec
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGActiveActiveE}        timeout=600
     BuiltIn.Sleep   5
     Configure Switch    device=l3switch    command_profile=remove_static_lag_e
     BuiltIn.Sleep    200
     Verify BTS Status     should_be_onair=${True}      rat=5g

Verify No LACPDUs Elec
     Setup Remote Access     remote_device=bts     alias=co1
     Execute Interactive Remote Command     command=${remove_existing_capture5}     alias=co1
     Execute Interactive Remote Command     command=${start_capture9}     alias=co1
     BuiltIn.Sleep   55
     Execute Interactive Remote Command     command=${start_capture10}     alias=co1
     BuiltIn.Sleep   55
     Get File From Remote Host    source=/user/toor4nsn/nolag_a1.pcap      destination=/home/ute    alias=co1
     Get File From Remote Host    source=/user/toor4nsn/nolag_s1.pcap      destination=/home/ute    alias=co1
     Analyse Pcap    pcap_filename=${pcap_file_location9}   analysis=lag_active_0_e
     Analyse Pcap    pcap_filename=${pcap_file_location10}   analysis=lag_standby_0_e
     Teardown Remote Access     alias=co1

Verify No LACPDUs after LAG deletion Elec AA
     Setup Remote Access     remote_device=bts     alias=co1
     Execute Interactive Remote Command     command=${remove_existing_capture8}     alias=co1
     Execute Interactive Remote Command     command=${start_capture15}     alias=co1
     BuiltIn.Sleep   55
     Execute Interactive Remote Command     command=${start_capture16}     alias=co1
     BuiltIn.Sleep   55
     Get File From Remote Host    source=/user/toor4nsn/nolag_a1.pcap      destination=/home/ute    alias=co1
     Get File From Remote Host    source=/user/toor4nsn/nolag_a1_1.pcap      destination=/home/ute    alias=co1
     Analyse Pcap    pcap_filename=${pcap_file_location15}   analysis=lag_active_0_e
     Analyse Pcap    pcap_filename=${pcap_file_location16}   analysis=lag_standby_0_e
     Teardown Remote Access     alias=co1

Verify lacp periodic time
     Setup Remote Access     remote_device=bts     alias=co1
     Execute Interactive Remote Command     command=${remove_existing_capture10}     alias=co1
     Execute Interactive Remote Command     command=${start_capture19}     alias=co1
     BuiltIn.Sleep   95
     Execute Interactive Remote Command     command=${start_capture20}     alias=co1
     BuiltIn.Sleep   95
     Get File From Remote Host    source=/user/toor4nsn/lag_a30.pcap      destination=/home/ute    alias=co1
     Get File From Remote Host    source=/user/toor4nsn/lag_s30.pcap      destination=/home/ute    alias=co1
     Analyse Pcap    pcap_filename=${pcap_file_location19}   analysis=lag_active_30
     Analyse Pcap    pcap_filename=${pcap_file_location20}   analysis=lag_standby_30
     Teardown Remote Access     alias=co1

Change Port Priority And Verify LAG Elec
     Configure Switch    device=l3switch    command_profile=dynamic_lag_e
     BuiltIn.Sleep   5
     Perform Recommissioning    type=delta    delta_file=${CreateLAGPortSystemPriorityE}        timeout=600
     Setup Remote Access     remote_device=bts     alias=co2
     Execute Interactive Remote Command     command=${remove_existing_capture6}     alias=co2
     Execute Interactive Remote Command     command=${start_capture11}     alias=co2
     Execute Interactive Remote Command     command=${start_capture12}     alias=co2
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_po_change_s1.pcap      destination=/home/ute    alias=co2
     Get File From Remote Host    source=/user/toor4nsn/lag_po_change_a1.pcap      destination=/home/ute    alias=co2
     Analyse Pcap    pcap_filename=${pcap_file_location11}   analysis=lag_po_change_s_e
     Analyse Pcap    pcap_filename=${pcap_file_location12}   analysis=lag_po_change_a_e
     Perform Recommissioning    type=delta    delta_file=${DeleteLAGPortSystemPriorityE}        timeout=600
     Configure Switch    device=l3switch    command_profile=remove_lag_e
     Teardown Remote Access     alias=co2

LAG Status When ETHLK Locked Elec
    Configure Switch    device=l3switch    command_profile=dynamic_lag_e
    BuiltIn.Sleep   5
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep   100
    Perform Recommissioning    type=delta    delta_file=${CreateLAGActiveStandbyE}        timeout=600
    BuiltIn.Sleep   100
    Check LAG and Port Status as Disabled Elec
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_unlock}    operation=update
    Remove LAG Configuration From BTS and Switch AS Elec

Static LAG Status When ETHLK Locked Elec
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_lock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_lock}    operation=update
    BuiltIn.Sleep   10
    Check LAG and Port Status as Disabled
    Perform Recommissioning     type=param  param_path=${ethlk3_path}    value=${ethlk_state_unlock}    operation=update
    Perform Recommissioning     type=param  param_path=${ethlk4_path}    value=${ethlk_state_unlock}    operation=update
    Check LAG and Port Status AA Elec

Verify LAG Switchover by LACP Timeout Elec
    Configure Switch    device=l3switch    command_profile=stop_lacp3
    BuiltIn.Sleep   15
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status      should_be_onair=${True}      rat=5g
#   Ping/Call to Core should work here
    Reset Bts      should_be_onair=${True}     rat=5g       wait_for=600
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Configure Switch    device=l3switch    command_profile=stop_lacp4
    BuiltIn.Sleep   10
    Check LAG Status as Disabled and Port Status as Defaulted
    BuiltIn.Sleep   10
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    should_exist=${False}

Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DEFAULT}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}

Check LAG Status as Disabled and Port Status as Defaulted
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${DISABLE1}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${DEFAULT}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${DEFAULT}

Verify LAG Switchover by LACP Restoration and Alarm degradation AA
    Configure Switch    device=l3switch    command_profile=start_lacp4
    BuiltIn.Sleep  10
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=start_lacp3
    BuiltIn.Sleep  10
    Check LAG and Port Status AA
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LACP Restoration and Alarm degradation Elec
    Configure Switch    device=l3switch    command_profile=start_lacp4
    BuiltIn.Sleep  15
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=start_lacp3
    BuiltIn.Sleep  10
    Check LAG and Elec Port Status
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LACP Timeout
    Configure Switch    device=l3switch    command_profile=stop_lacp1
    BuiltIn.Sleep   10
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Reset Bts      should_be_onair=${True}     rat=5g       wait_for=600
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Configure Switch    device=l3switch    command_profile=stop_lacp2
    BuiltIn.Sleep   10
    Check LAG Status as Disabled and Port Status as Defaulted
    Verify Alarm    faultid=61662    occurrences=1      severity=major    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation by LACP Timeout
    Configure Switch    device=l3switch    command_profile=start_lacp2
    BuiltIn.Sleep  10
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=start_lacp1
    BuiltIn.Sleep  10
    Check LAG and Port Status
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Verify LAG Switchover by LOS Restoration and Alarm degradation AA by LACP Timeout
    Configure Switch    device=l3switch    command_profile=start_lacp2
    BuiltIn.Sleep  10
    Check Dynamic LAG and Port Status After Switchover by LACP Timeout
    Verify Alarm    faultid=61662    occurrences=1    severity=minor    should_exist=True
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}
    Verify BTS Status     should_be_onair=${True}     rat=5g
#   Ping/Call to Core should work here
    Configure Switch    device=l3switch    command_profile=start_lacp1
    BuiltIn.Sleep  10
    Check LAG and Port Status AA
    Verify BTS Status     should_be_onair=${True}     rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}
    Verify Alarm    faultid=61029    should_exist=${False}

Modify Port priority and Verify LAG Status
    Perform Recommissioning     type=delta      delta_file=${PortUpdate1}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status P2 Active P1 Standby
    Perform Recommissioning     type=delta      delta_file=${PortUpdate2}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status
    Perform Recommissioning     type=delta      delta_file=${PortUpdate3}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status P2 Active P1 Standby
    Verify BTS Status     should_be_onair=${True}     rat=5g

Modify System priority and Verify LAG Status
    Log     BTS Low System Priority Switch High System Priority - Switch considered as Actor followed with Port numbers of Switch
    Perform Recommissioning     type=param  param_path=${lag_systempriority}    value=${system_priority1}    operation=update
    Check LAG and Port Status
    Log     BTS And Switch Same System Priority and Same Port Priority - BTS having lower MAC considered as Actor followed with Port numbers of BTS
    Perform Recommissioning     type=param  param_path=${lag_systempriority}    value=${system_priority2}    operation=update
    Check LAG and Port Status P2 Active P1 Standby
    Verify BTS Status     should_be_onair=${True}     rat=5g

Configure LAG on Switch and BTS Optical Ports AS Same System and Port Priotity
    Configure Switch    device=l3switch    command_profile=sp_pp_same
    BuiltIn.Sleep   5
    Perform Recommissioning    type=delta    delta_file=${CreateLAG_same_sp_pp}        timeout=600
#   Switch system priority shoould be 10, Since lag is with SP 10 and viseversa
    BuiltIn.Sleep   250
    Verify BTS Status     should_be_onair=${True}     rat=5g

Check LAG and Port Status AAA Port3 Addition
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}
    ${port_status3}=   Get From List    ${port_operational_status}   2
    Log   ${port_status3}
    ${port3}=  Get From Dictionary    ${port_status3}   portState
    Log   ${port3}
    Should Contain    ${port3}   ${ACTIVE}

Check LAG and Port Status AAA Port3 Deletion
    ${lag_status_dict}=     Query Admin Infomodel    query=get object //LAGRP_R-1
    Log   ${lag_status_dict}
    ${lag_operational_status}=     Get From Dictionary   ${lag_status_dict}   operationalState
    Should Contain     ${lag_operational_status}    ${ENABLE}
    Log   ${lag_operational_status}
    ${port_operational_status}=     Get From Dictionary   ${lag_status_dict}   portStatus
    Log   ${port_operational_status}
    ${port_status1}=   Get From List    ${port_operational_status}   0
    Log   ${port_status1}
    ${port1}=  Get From Dictionary    ${port_status1}   portState
    Log   ${port1}
    Should Contain    ${port1}    ${ACTIVE}
    ${port_status2}=   Get From List    ${port_operational_status}   1
    Log   ${port_status2}
    ${port2}=  Get From Dictionary    ${port_status2}   portState
    Log   ${port2}
    Should Contain    ${port2}   ${ACTIVE}
#    ${port_status3}=   Get From List    ${port_operational_status}   2
#    Log   ${port_status3}
#    ${port3}=  Get From Dictionary    ${port_status3}   portState
#    Log   ${port3}
#    Should Not Contain    ${port3}   ${ACTIVE}

Add Port and Delete Port
    Configure Switch    device=l3switch    command_profile=add_port3
    BuiltIn.Sleep   5
    Perform Recommissioning     type=delta      delta_file=${AddPort}     skip_parameter_relation_errors=${True}      timeout=300
    Check LAG and Port Status AAA Port3 Addition
    Verify BTS Status     should_be_onair=${True}      rat=5g
    Configure Switch    device=l3switch    command_profile=delete_port3
    Perform Recommissioning     type=delta      delta_file=${DeletePort}     skip_parameter_relation_errors=${True}      timeout=300
    BuiltIn.Sleep   5
    Check LAG and Port Status AAA Port3 Deletion
    Verify BTS Status     should_be_onair=${True}      rat=5g

Verify LAG Parameters in LAPCDUs Optical with Same System Priority And Port Priority
     Setup Remote Access     remote_device=bts     alias=co
     Execute Interactive Remote Command     command=${remove_existing_capture9}     alias=co
     Execute Interactive Remote Command     command=${start_capture17}     alias=co
     Execute Interactive Remote Command     command=${start_capture18}     alias=co
     BuiltIn.Sleep   30
     Get File From Remote Host    source=/user/toor4nsn/lag_sspa.pcap      destination=/home/ute    alias=co
     Get File From Remote Host    source=/user/toor4nsn/lag_ssps.pcap      destination=/home/ute    alias=co
     Analyse Pcap    pcap_filename=${pcap_file_location18}   analysis=lag_ssps
     Analyse Pcap    pcap_filename=${pcap_file_location17}   analysis=lag_sspa
     Teardown Remote Access     alias=co

Configure IPSEC
    Install BTS Certificates
    Configure Switch    device=l3switch1    command_profile=add_route
    Perform Recommissioning    type=delta    delta_file=${ConfigIpsec}        timeout=600

Remove IPSEC
    Configure Switch    device=l3switch1    command_profile=remove_route
    Perform Recommissioning    type=delta    delta_file=${DeleteIpsec}        timeout=600

Install BTS Certificates
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${IP_BTSCertpass}       key_pool_type=RSA
    BuiltIn.Sleep    20




