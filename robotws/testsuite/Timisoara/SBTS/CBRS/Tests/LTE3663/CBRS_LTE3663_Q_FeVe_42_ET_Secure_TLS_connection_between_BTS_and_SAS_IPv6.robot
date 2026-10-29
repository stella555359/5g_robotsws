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
...    Review link:

*** Keywords ***
CBRS_LTE3663_Q_FeVe_42_ET_Secure_TLS_connection_between_BTS_and_SAS_IPv6
    [Documentation]    Requirement: WBTS_SEC_56454
    ...                Purpose: This scenario is used to verify that BTS with IPv4 M-Plane refuses to setup the
    ...                connection with SAS server, in case SAS server is configured with IPv6.
    ...                Test Steps:
    ...                Step 1: Check if IPv6 SAS Sim is running
    ...                Step 2: Check if IPv4/IPv6 M-Plane dual stack configuration exist on BTS
    ...                Step 3: Set IPv6 address as primary SAS Server on BTS
    ...                Step 4: Enable CBRS and confirm that CBSD can be registerred in SAS
    ...                Step 5: Check if all cells reached onAir state

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Disable CBRS Feature On eNB

    Log To Console    ${\n}Step 1: Check if IPv6 SAS Simulator instance is running...${SPACE}    no_newline=true
    Open Connection    ${ipv6_sas.vm_ip}
    Login    ${ipv6_sas.vm_user}    ${ipv6_sas.vm_pass}
    ${sas_status}   Execute Command    ps -aux | grep SAS_Sim.py
    ${is_ipv6_sas_running}   Run Keyword And Return Status    Should Contain    ${sas_status}    python3 SAS_Sim.py
    IF  '${is_ipv6_sas_running}'=='False'
        Execute Command  python3 /home/ute/Desktop/SASSim/SAS_Sim.py
        Sleep  5s    #wait for SAS Sim start
    END
    ${ipv6_flag_search}   Execute Command    cat /home/ute/Desktop/SASSim/SAS_Sim.log | grep enable_ipv6
    Should Contain    ${ipv6_flag_search}    enable_ipv6 is configed to True    msg=SAS Sim is not running in IPv6 mode
    Log To Console    Done, SAS Simulator is running on ${ipv6_sas.vm_ip}

    Log To Console    Step 2: Check if IPv6 is set on BTS...${SPACE}    no_newline=true
    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${query}   Catenate    SEPARATOR=${SPACE}
    ...    check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/MNL_A-*/MNLENT_A-*/FEATCADM_A-*
    ...    is [actDualStackIpV4V6ForMplane=true]
    ${is_mplane_dual_stack_enabled}   Run Keyword And Return Status    Query Infomodel    query=${query}    timeout=30    alias=${alias}
    Should Be Equal    ${is_mplane_dual_stack_enabled}    ${True}    msg=IPv6 configuration not found on BTS
    Log To Console    Done, dual stack config found

    #inside below query BTS_L object can have ID 1 or 4 (it depends on SMOD side in AMIA)
    ${cbrspr_object}   Query Infomodel
    ...    query=get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBRSPR_A-1
    ...    timeout=60
    ...    alias=${alias}
    ${primary_sas_backup}   Set Variable    ${cbrspr_object['primarySasServer']}

    Log To Console    Step 3: Set IPv6 SAS server...${SPACE}    no_newline=true
    Set Primary Sas Server    bts_id=${enb_id}    sas_ip=[${ipv6_sas.default_sas_ip}]:${ipv6_sas.default_sas_port}

    Log To Console    Step 4: Enable CBRS and check if CBSD can be registered...${SPACE}    no_newline=true
    Start Watchdog Alarm Detection
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}

    Log To Console    Step 5: Check if cells reached onAir state...${SPACE}    no_newline=true
    Wait For All Cells To Be OnAir    wait_time=4min
    Log To Console    Done, starting teardown with primary SAS Server restore

    [Teardown]    Run Keywords
    ...    Close All Connections    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Set Primary Sas Server    bts_id=${enb_id}    sas_ip=${primary_sas_backup}    print_ip=False
