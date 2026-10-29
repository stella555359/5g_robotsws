*** Settings ***
Documentation
...            [Author]         "Santhosh K G"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Base Configurations
    Perform Switchover IXR14
    Configure Switch    device=l3switch    command_profile=allow_vlan
    Perform Commissioning      scf_file=${base_scf}     timeout=300     alias=default
    Sleep   300
    Verify Bts Status   should_be_onair=${True}
    Read IP parameters
    Alarms before VRRP Switchover

Base Configurations for Dual link
    Perform Switchover IXR14
    Configure Switch    device=l3switch    command_profile=allow_vlan
    Configure Switch    device=l3switch2    command_profile=allow_vlan
    Perform Commissioning      scf_file=${base_scf}     timeout=300     alias=default
    Sleep   300
    Verify Bts Status   should_be_onair=${True}
    Read IP parameters
    Alarms before VRRP Switchover

Base Configurations for LAG
    Perform Switchover IXR14
    Perform Commissioning      scf_file=${base_scf}     timeout=300     alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk2_unlock}   timeout=300   alias=default
    Configure LAG on Switch and BTS       dynamic_lag        ${CreateLAGActiveStandby}
    Check LAG and Port Status      enabled        ACTIVE_ENABLED      STANDBY_ENABLED
    Sleep   300
    Verify Bts Status   should_be_onair=${True}
    Read IP parameters
    Alarms before VRRP Switchover

Base Configurations for LINK LAG
    Perform Switchover IXR14
    Perform Commissioning      scf_file=${base_scf}     timeout=300     alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk1_lock}   timeout=300   alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk34_unlock}   timeout=300   alias=default
    Configure LAG on Switch and BTS_Electrical       dynamic_lag_eif34        ${CreateLAGActiveStandby_LINK_LAG}
    Check LAG and Port Status      enabled        ACTIVE_ENABLED      STANDBY_ENABLED
    Sleep   600
    Verify Bts Status   should_be_onair=${True}
    Read IP parameters
    Alarms before VRRP Switchover

Remove configurations
    Remove LAG Configuration From BTS and Switch_Electrical     remove_lag      ${DeleteLAGActiveStandby}
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Perform Recommissioning    type=delta      delta_file=${ethlk1_unlock}   timeout=300   alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk34_lock}   timeout=300   alias=default
    Sleep   60
    Verify Bts Status   should_be_onair=${True}

Delete Electrical LAG in BTS
    Remove Electrical LAG Configuration From BTS        ${DeleteLAGActiveStandby}

Get top info details
    [Documentation]   Verfies Top master availability and usability staus
    [Arguments]    ${top_first_level_key}    ${top_second_level_key}    ${top_third_level_key}   ${top_status}    ${top_type}=TOPP
    ${top_info}=    Get Sync Info
    ${top_info}=    Get From Dictionary    ${top_info}   ${top_first_level_key}
    FOR    ${top_dict}    IN   @{top_Info}
        ${top_sync_type}=    Get From Dictionary    ${top_dict}   syncInputType
        Continue For Loop If    not '${top_sync_type}' == '${top_type}'
        ${top_info}=    Get From Dictionary    ${top_dict}   ${top_second_level_key}
        ${top_info}=    Get From Dictionary    ${top_info}   ${top_third_level_key}
        Exit For Loop IF    '${top_sync_type}' == '${top_type}'
    END
    Should Be Equal    ${top_info}   ${top_status}

Verify VRRP status in IXR13
    [Documentation]    Storing the VRRP output from IXR to current directory
    [Arguments]        ${check1}
    Setup Remote Access    remote_device=switch13    alias=conn1
    FOR    ${i}    IN   @{VLANLIST}
        Execute Interactive Remote Command    command=${show_cmd}_${i} > IES_FOR_VLAN_${i}    alias=conn1
        Get File From Remote Host    source=IES_FOR_VLAN_${i}     destination=${CURDIR}   alias=conn1
    END
    Teardown Remote Access    alias=conn1
    Verify VRRP status for IPV4 and IPV6  ${check1}

Verify VRRP status in IXR14
    [Documentation]    Storing the VRRP output from IXR to current directory
    [Arguments]        ${check1}
    Setup Remote Access    remote_device=switch14    alias=conn1
    FOR    ${i}    IN   @{VLANLIST}
        Execute Interactive Remote Command    command=${show_cmd}_${i} > IES_FOR_VLAN_${i}    alias=conn1
        Get File From Remote Host    source=IES_FOR_VLAN_${i}     destination=${CURDIR}   alias=conn1
    END
    Teardown Remote Access    alias=conn1
    Verify VRRP status for IPV4 and IPV6  ${check1}

Verify VRRP status for IPV4 and IPV6
    [Arguments]      ${check1}
    Setup Remote Access     remote_device=VM    alias=conn2
    FOR    ${i}    IN   @{VLANLIST}
        ${output}=    Execute Interactive Remote Command    command=cat ${CURDIR}/IES_FOR_VLAN_${i} | grep VRRP | head -3   alias=conn2
        Should Contain    ${output}    ${check1}
        ${output}=    Execute Interactive Remote Command    command=cat ${CURDIR}/IES_FOR_VLAN_${i} | grep VRRP | tail -2   alias=conn2
        Should Contain    ${output}    ${check1}
    END
    Teardown Remote Access    alias=conn2

Verify traceroute in BTS for different Application Ipaddress
    Verify Primary MME traceroute
    Verify Secondary MME traceroute
    Verify TOP traceroute

Verify Primary MME traceroute
    Setup Remote Access    remote_device=bts    alias=conn4
    Execute Interactive Remote Command    command=traceroute ${Primary_MME_IP} > MME_traceroute1      timeout=100       alias=conn4
    Get File From Remote Host    source=MME_traceroute1     destination=${CURDIR}   alias=conn4
    Teardown Remote Access    alias=conn4

Verify Secondary MME traceroute
    Setup Remote Access    remote_device=bts    alias=conn5
    Execute Interactive Remote Command    command=traceroute ${Secondary_MME_IP} > MME_traceroute2    timeout=30     alias=conn5
    Get File From Remote Host    source=MME_traceroute2     destination=${CURDIR}   alias=conn5
    Teardown Remote Access    alias=conn5

Verify TOP traceroute
    Setup Remote Access    remote_device=bts    alias=conn6
    Execute Interactive Remote Command    command=traceroute ${TOP_IP} > TOP_traceroute     timeout=30      alias=conn6
    Get File From Remote Host    source=TOP_traceroute     destination=${CURDIR}   alias=conn6
    Teardown Remote Access    alias=conn6

Route verfication
    [Arguments]      ${IXR_gateway_VLAN525}    ${IXR_gateway_VLAN527}    ${IXR_gateway_VLAN528}
    Setup Remote Access     remote_device=VM    alias=conn2
    ${output}=    Execute Interactive Remote Command    command=cat ${CURDIR}/MME_traceroute1 | head -2    alias=conn2
    Should Contain     ${output}    ${IXR_gateway_VLAN525}
    ${output}=    Execute Interactive Remote Command    command=cat ${CURDIR}/MME_traceroute2 | head -2    alias=conn2
    Should Contain     ${output}    ${IXR_gateway_VLAN527}
    ${output}=    Execute Interactive Remote Command    command=cat ${CURDIR}/TOP_traceroute | head -2    alias=conn2
    Should Contain     ${output}    ${IXR_gateway_VLAN528}
    Teardown Remote Access    alias=conn2

Read IP parameters
    ${Primary_MME_IP}=       Get Parameter     rat=common    param_path=${MME_primary_moc}
    Set Suite Variable     ${Primary_MME_IP}
    ${Secondary_MME_IP}=        Get Parameter     rat=common      param_path=${MME_secondary_moc}
    Set Suite Variable       ${Secondary_MME_IP}
    ${TOP_IP}=          Get Parameter     rat=common     param_path=${TOP_MOC}
    Set Suite Variable      ${TOP_IP}

Compare MME IP after VRRP switchover
    ${output}=      Get Parameter     rat=common    param_path=${MME_primary_moc}
    Should Be Equal    ${output}    ${Primary_MME_IP}
    ${output}=      Get Parameter     rat=common    param_path=${MME_secondary_moc}
    Should Be Equal    ${output}    ${Secondary_MME_IP}

Perform Switchover IXR13
    Setup Remote Access     remote_device=switch13    alias=conn10
    FOR    ${i}    IN   @{VLANLIST}
        Execute Interactive Remote Command    command=${switchover_cmd}_${i}    alias=conn10
    END
    Teardown Remote Access    alias=conn10

Perform Switchover IXR14
    Setup Remote Access     remote_device=switch14    alias=conn10
    FOR    ${i}    IN   @{VLANLIST}
        Execute Interactive Remote Command    command=${switchover_cmd}_${i}    alias=conn10
    END
    Teardown Remote Access    alias=conn10

Verify CALL with VRRP switchover
    Call Setup    5g=device_3:data    verify_attach=${False}    attach=${True}
    Run Keywords in Parallel   Call Start    5g=device_3:data    profile=udp_100M_ul    iperf_section=device1
    ...      AND       Call Start    5g=device_3:data    profile=udp_100M_dl    iperf_section=device1
    Traffic Capture Start   capture_device=oam_device    measurement_point=Transport_Interface    mode=file
    Setup Remote Access     remote_device=switch13    alias=conn10
    Execute Interactive Remote Command    command=${switchover_cmd}_${CALL_VLAN}    alias=conn10
    Teardown Remote Access    alias=conn10
    ${file}=    Traffic Capture Stop    mode=file    timeout=120
    Set Suite Variable      ${file}
    Analyse Pcap        pcap_filename=${file}        analysis=call_drop_message       filter_file_name=${traffic_filter_file_name}
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_10M_ul
    Run keyword And Ignore Error    Call Stop     5g=device_3:data    profile=udp_10M_dl
    Call Teardown    5g=device_3:data
    Setup Remote Access     remote_device=switch14    alias=conn10
    Execute Interactive Remote Command    command=${switchover_cmd}_${CALL_VLAN}    alias=conn10
    Teardown Remote Access    alias=conn10

Verify VRRP Single Link Redundancy with IPV4 multihomming and TOP
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525}    ${IXR14_gateway_VLAN527}   ${IXR14_gateway_VLAN528}
    Sleep    60
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Sleep    60
    Alarms after VRRP Switchover
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Sleep    60
    Alarms after VRRP Switchover

Verify VRRP Single Link Redundancy with IPV6 multihomming and TOP
    Perform Recommissioning    type=delta      delta_file=${TOP_MME_IPV6}   timeout=300   alias=default
    Sleep   300
    Read IP parameters
    Sleep    60
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525_ipv6}    ${IXR14_gateway_VLAN527_ipv6}   ${IXR14_gateway_VLAN528_ipv6}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Sleep    60
    Alarms after VRRP Switchover
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Sleep    60
    Alarms after VRRP Switchover

Verify VRRP Dual Link Redundancy with IPV4 multihomming and TOP
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Perform Recommissioning    type=delta      delta_file=${ethlk2_unlock}   timeout=300   alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk1_lock}   timeout=300   alias=default
    Configure Switch    device=l3switch2    command_profile=port_noshut
    Configure Switch    device=l3switch    command_profile=port_shut1
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   300
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525}    ${IXR14_gateway_VLAN527}   ${IXR14_gateway_VLAN528}
    Alarms after VRRP Switchover
    Perform Recommissioning    type=delta      delta_file=${ethlk1_unlock}   timeout=300   alias=default
    Perform Recommissioning    type=delta      delta_file=${ethlk2_lock}   timeout=300   alias=default
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Configure Switch    device=l3switch2    command_profile=port_shut
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   300
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Alarms after VRRP Switchover

Verify VRRP Dual Link Redundancy with IPV6 multihomming and TOP
    Perform Recommissioning    type=delta      delta_file=${TOP_MME_IPV6}   timeout=300   alias=default
    Sleep   300
    Read IP parameters
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Perform Recommissioning    type=delta      delta_file=${ethlk2_unlock}   timeout=300   alias=default
    Configure Switch    device=l3switch    command_profile=port_shut1
    Configure Switch    device=l3switch2    command_profile=port_noshut
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   300
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525_ipv6}    ${IXR14_gateway_VLAN527_ipv6}   ${IXR14_gateway_VLAN528_ipv6}
    Alarms after VRRP Switchover
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Configure Switch    device=l3switch2    command_profile=port_shut
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   300
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Alarms after VRRP Switchover
    Perform Recommissioning    type=delta      delta_file=${ethlk2_lock}   timeout=300   alias=default

Configure LAG on Switch and BTS_Electrical
    [ARGUMENTS]      ${switch_config}      ${bts_config}
    Configure Switch    device=l3switch2    command_profile=${switch_config}
    Sleep   5
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=200
    Sleep   50
    Verify BTS Status     should_be_onair=${True}

Verify VRRP Dual Link LAG Redundancy with IPV4 multihomming and TOP
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Perform Recommissioning    type=delta      delta_file=${ethlk1_unlock}   timeout=300   alias=default
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Configure Switch    device=l3switch2    command_profile=dynamic_lag_shut
    Perform Recommissioning    type=delta      delta_file=${ethlk34_lock}   timeout=300   alias=default
    Delete Electrical LAG in BTS
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   600
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525}    ${IXR14_gateway_VLAN527}   ${IXR14_gateway_VLAN528}
    Alarms after VRRP Switchover
    Configure LAG on Switch and BTS_Electrical       dynamic_lag_eif34        ${CreateLAGActiveStandby_LINK_LAG}
    Perform Recommissioning    type=delta      delta_file=${ethlk34_unlock}   timeout=300   alias=default
    Configure Switch    device=l3switch    command_profile=port_shut1
    Configure Switch    device=l3switch2    command_profile=dynamic_lag_noshut
    Sleep   30
    Check LAG and Port Status      enabled        ACTIVE_ENABLED      STANDBY_ENABLED
    Verify Bts Status      should_be_onair=${True}
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   600
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525}    ${IXR13_gateway_VLAN527}   ${IXR13_gateway_VLAN528}
    Perform Recommissioning    type=delta      delta_file=${ethlk1_lock}   timeout=300   alias=default
    Sleep   30
    Alarms after VRRP Switchover

Verify VRRP Dual Link LAG Redundancy with IPV6 multihomming and TOP
    Perform Recommissioning    type=delta      delta_file=${TOP_MME_IPV6}   timeout=300   alias=default
    Sleep   600
    Read IP parameters
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Perform Recommissioning    type=delta      delta_file=${ethlk1_unlock}   timeout=300   alias=default
    Configure Switch    device=l3switch    command_profile=port_noshut1
    Configure Switch    device=l3switch2    command_profile=dynamic_lag_shut
    Perform Switchover IXR13
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   600
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR14     ${Master}
    Verify VRRP status in IXR13     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR14_gateway_VLAN525_ipv6}    ${IXR14_gateway_VLAN527_ipv6}   ${IXR14_gateway_VLAN528_ipv6}
    Alarms after VRRP Switchover
    Configure Switch    device=l3switch    command_profile=port_shut1
    Configure Switch    device=l3switch2    command_profile=dynamic_lag_noshut
    Sleep   30
    Check LAG and Port Status      enabled        ACTIVE_ENABLED      STANDBY_ENABLED
    Verify Bts Status      should_be_onair=${True}
    Perform Switchover IXR14
    Verify Bts Status      should_be_onair=${True}
    Compare MME IP after VRRP switchover
    Sleep   600
    Get top info details    ${top_first_levele_key}   ${top_second_levele_key}    ${top_third_levele_key}    ${top_availability_status}
    Verify VRRP status in IXR13     ${Master}
    Verify VRRP status in IXR14     ${Backup}
    Verify traceroute in BTS for different Application Ipaddress
    Route verfication    ${IXR13_gateway_VLAN525_ipv6}    ${IXR13_gateway_VLAN527_ipv6}   ${IXR13_gateway_VLAN528_ipv6}
    Alarms after VRRP Switchover

Remove LAG Configuration From BTS and Switch_Electrical
    [ARGUMENTS]       ${switch_config}       ${bts_config}
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=300
    Sleep   5
    Configure Switch    device=l3switch2    command_profile=${switch_config}
    Sleep    100
    Verify BTS Status     should_be_onair=${True}      rat=5g
    Verify Alarm    faultid=61662    severity=minor    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=61662    severity=major    should_exist=${False}    alarm_type=active

Remove Electrical LAG Configuration From BTS
    [ARGUMENTS]       ${bts_config}
    Perform Recommissioning    type=delta    delta_file=${bts_config}        timeout=300
    Sleep   5

Alarms before VRRP Switchover
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=  Create List
    ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
    Sort List   ${pre_alarm_faultids}
    Set Suite Variable      ${pre_alarm_faultids}

Alarms after VRRP Switchover
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

