*** Settings ***
Documentation
...    = Author =
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    aleksandra.chudzik@nokia.com
...    karol.sadowski@nokia.com
...    elzbieta.wlodarczyk@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1279/

*** Keywords ***
CBRS_LTE3663_Q_FeVe_40_ET_BTS_IPv4_refuse_to_setup_connection_with_SAS_IPv6
    [Documentation]    Requirement: WBTS_SEC_56454
    ...                Purpose: This scenario is used to verify that BTS with IPv4 M-Plane refuses to setup the
    ...                connection with SAS server, in case SAS server is configured with IPv6.
    ...                Test Steps:
    ...                Step 1: Check if IPv6 SAS Sim is running
    ...                Step 2: Remove IPv4/IPv6 M-Plane dual stack configuration from BTS (if exist)
    ...                Step 3: Set IPv6 address as primary SAS Server
    ...                Step 4: Enable CBRS and confirm that cells remain disabled

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${ipv6_sas_vm_ip_addr}   Set Variable    ${ipv6_sas.vm_ip}
    ${ipv6_sas_vm_user}   Set Variable    ${ipv6_sas.vm_user}
    ${ipv6_sas_vm_password}   Set Variable    ${ipv6_sas.vm_pass}
    ${ipv6_sas_addr}   Set Variable    ${ipv6_sas.default_sas_ip}
    ${ipv6_sas_port}   Set Variable    ${ipv6_sas.default_sas_port}
    ${is_mplane_dual_stack_enabled}   Set Variable    False
    &{expected_alarm}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    ${alias}   Set Variable    RAT_1ST

    Disable CBRS Feature On eNB

    Log To Console    ${\n}Step 1: Check if IPv6 SAS Simulator instance is running...${SPACE}    no_newline=true
    Open Connection    ${ipv6_sas_vm_ip_addr}
    Login    ${ipv6_sas_vm_user}    ${ipv6_sas_vm_password}
    ${sas_status}   Execute Command    ps -aux | grep SAS_Sim.py
    ${is_ipv6_sas_running}   Run Keyword And Return Status    Should Contain    ${sas_status}    python3 SAS_Sim.py
    IF  '${is_ipv6_sas_running}'=='False'
        Execute Command  python3 /home/ute/SASSimRepo/uri/test/py/tools/SASSim/SAS_Sim.py
        Sleep  5s    #wait for SAS Sim start
    END
#    ${ipv6_flag_search}   Execute Command    cat /home/ute/SASSimRepo/uri/test/py/tools/SASSim/SAS_Sim.log | grep enable_ipv6
	${ipv6_flag_search}   Execute Command    cat /home/ute/SAS_Sim.log | grep enable_ipv6
    Should Contain    ${ipv6_flag_search}    enable_ipv6 is configed to True    msg=SAS Sim is not running in IPv6 mode
    Log To Console    Done, SAS is running on ${ipv6_sas_vm_ip_addr}

    Log To Console    Step 2: Check if IPv6 is set on BTS...${SPACE}    no_newline=true
    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${query}   Catenate    SEPARATOR=${SPACE}
    ...    check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/MNL_A-*/MNLENT_A-*/FEATCADM_A-*
    ...    is [actDualStackIpV4V6ForMplane=true]
    ${is_mplane_dual_stack_enabled}   Run Keyword And Return Status    Query Infomodel    query=${query}    timeout=30     alias=${alias}
    IF  ${is_mplane_dual_stack_enabled}
        Prepare Backup Plan For Ipv6 Parameters  bts_id=${enb_id}
        Remove Ipv6 Parameters  bts_id=${enb_id}
        Log To Console  Done, IPv6 configuration removed (backup prepared)
    ELSE
        Log To Console  Done, no IPv6 configuration found
    END
    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${cbrspr_object}   Query Infomodel
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBRSPR_A-1
    ...    timeout=60
    ...    alias=${alias}
    ${primary_sas_backup}   Set Variable    ${cbrspr_object['primarySasServer']}

    Log To Console    Step 3: Set IPv6 SAS server...${SPACE}    no_newline=true
    Set Primary Sas Server    bts_id=${enb_id}    sas_ip=[${ipv6_sas_addr}]:${ipv6_sas_port}

    Log To Console    Step 4: Enable CBRS and check if cells remain disabled...${SPACE}    no_newline=true
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=60
    ${is_bts_onair}   Run Keyword And Return Status    Query InfoModel
    ...    query=every //LNBTS_M-1/CELL_M-* is [stateInfo.proceduralState=regex"(?i)OnAirDone"]
    ...    timeout=120
    ...    alias=${alias}
    IF  ${is_bts_onair}  Fail  BTS shouldn't reach on air state
    Log To Console    Done, starting teardown

    [Teardown]    Run Keywords
    ...    Close All Connections    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Restore Parameters if stack enabled  ${is_mplane_dual_stack_enabled}   AND
    ...    Set Sas Server if stack enabled  ${is_mplane_dual_stack_enabled}  ${enb_id}  ${primary_sas_backup}


Restore Parameters if stack enabled
    [Arguments]  ${is_mplane_dual_stack_enabled}

    IF  ${is_mplane_dual_stack_enabled}  Restore Ipv6 Parameters


Set Sas Server if stack enabled
    [Arguments]  ${is_mplane_dual_stack_enabled}  ${enb_id}  ${primary_sas_backup}

    IF  ${is_mplane_dual_stack_enabled}  Set Primary Sas Server  bts_id=${enb_id}  sas_ip=${primary_sas_backup}  print_ip=False


Prepare Backup Plan For Ipv6 Parameters
    [Documentation]  Description:           Save mandatory IPv6 parameters for M-Plane dual stack to a delta plan
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]      ${bts_id}              # BTS ID
    ...              ${alias}=RAT_1ST       # connection alias

    #inside below query URI object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${dns_object}   Query Infomodel
    ...    query=get object /MRBTS-1/RAT-1/URI-*/NETWORK_CONFIG-1/NCF-*/DNS_N-1
    ...    timeout=60
    ...    alias=${alias}
    ${primary_dns}   Set Variable    ${dns_object['dnsIpAddressPrimary']}
    ${secondary_dns}   Set Variable    ${dns_object['dnsIpAddressSecondary']}
    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${mplanenw_object}   Query Infomodel
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${bts_id}/MNL_A-1/MNLENT_A-1/MPLANENW_A-1
    ...    timeout=60
    ...    alias=${alias}
    ${mplane_ipv6_dn}   Set Variable    ${mplanenw_object['mPlaneIpv6AddressDN']}
    ${ipif_id}   Get Regexp Matches    ${mplane_ipv6_dn}    (?<=IPIF\\_A-)(\\d*)

    Replace Variables In File    file_path=${CURDIR}/Data/IPv6_parameters_set.json
    ...                          file_destination=${OUTPUT_DIR}/IPv6_parameters_set.json
    ...                          enb_id=${bts_id}
    ...                          primary_dns=${primary_dns}
    ...                          secondary_dns=${secondary_dns}
    ...                          mplane_ipv6_dn=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id[0]}/IPADDRESSV6-1

Remove Ipv6 Parameters
    [Documentation]  Description:           Prepare and send a delta plan to remove mandatory IPv6 parameters, to disable
    ...                                     IPv4/IPv6 M-Plane dual stack on BTS.                 ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]      ${bts_id}                         # BTS ID
    ...              ${primary_dns}=10.44.45.199       # primary DNS (must be IPv4)
    ...              ${secondary_dns}=10.45.168.139    # secondary DNS (must be IPv4)
    ...              ${alias}=RAT_1ST                  # connection alias

    Log To Console    ${\n}BTS ID is... ${bts_id}
    Replace Variables In File    file_path=${CURDIR}/Data/IPv6_parameters_remove.json
    ...                          file_destination=${OUTPUT_DIR}/IPv6_parameters_remove.json
    ...                          enb_id=${bts_id}
    ...                          primary_dns=${primary_dns}
    ...                          secondary_dns=${secondary_dns}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/IPv6_parameters_remove.json
    ...                                     connection=${alias}

Restore Ipv6 Parameters
    [Documentation]  Description:           Send a delta plan (must be prepared earlier) to restore mandatory IPv6
    ...                                     parameters and enable IPv4/IPv6 M-Plane dual stack.  ${\n}
    ...              Return:                none                                                 ${\n}
    ...              Output:                {}                                                   ${\n}
    ...              Author:                piotr.lukaszewicz@nokia.com                          ${\n}
    ...              Maintainer:            CBRS Team                                            ${\n}
    [Arguments]      ${alias}=RAT_1ST       # connection alias

    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/IPv6_parameters_set.json
    ...                                     connection=${alias}
