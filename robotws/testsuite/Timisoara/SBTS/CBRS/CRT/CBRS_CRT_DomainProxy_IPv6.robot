*** Settings ***
Documentation    DomainProxy IPv6 functionality
...              Suite designed for testline CBRS_15 IPv6

Resource        ../Resources/cbrs_common_keywords.robot

Suite Setup       Run Keywords    Suite Precondition    AND    Set Software Version
Suite Teardown    Run Keywords    Suite Postcondition

Force Tags    QCP_RAN_VRF    QCD_MN_RAN    CRT    4G_TDD

*** Test Cases ***

#!! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !!
CBRS_CB012364-C_01_LTE_Static_Mplane_connect_to_IPv6_Domain_Proxy
    [Tags]    CB012364-C    SBTS00
    Log To Console    Check if TC Passed and report to QC.

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${CB012364-C_01_PASSED}
    IF  ${test_executed}==${False}    CBRS_CRT_DomainProxy_IPv6_Suite

    IF  ${CB012364-C_01_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_IPv6_Suite TC.

CBRS_CB012364-C_02_LTE_Static_Mplane_connect_to_IPv6_Secondary_Domain_Proxy
    [Tags]    CB012364-C    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${CB012364-C_02_PASSED}
    IF  ${test_executed}==${False}    CBRS_CRT_DomainProxy_IPv6_Suite
    IF  ${CB012364-C_02_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_IPv6_Suite TC.

CBRS_CB012364-C_07_LTE_Static_IPv6_Mplane_Fault_Switchover_successfully
    [Tags]    CB012364-C    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${CB012364-C_07_PASSED}
    IF  ${test_executed}==${False}    CBRS_CRT_DomainProxy_IPv6_Suite

    IF  ${CB012364-C_07_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_IPv6_Suite TC.

CBRS_CB012364-C_08_LTE_Static_IPv6_Mplane_Fault_Switchover_secondary_DP_failed
    [Tags]    CB012364-C    SBTS00

    # Trigger suite for 0 touch regression
    ${test_executed}=    Run Keyword And Return Status    Variable Should Exist    ${CB012364-C_08_PASSED}
    IF  ${test_executed}==${False}    CBRS_CRT_DomainProxy_IPv6_Suite

    IF  ${CB012364-C_08_PASSED} != ${TRUE}  Fail  msg=TC Failed, check logs under CBRS_CRT_DomainProxy_IPv6_Suite TC.
#!! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !! TC ONLY FOR REPORTING TO QC !!

*** Keywords ***
CBRS_CRT_DomainProxy_IPv6_Suite
    [Timeout]    90min
    Test Precondition
    CBRS_CRT_DomainProxy_IPv6
    [Teardown]    Test Postcondition

CBRS_CRT_DomainProxy_IPv6

    ${access_interface_DP1}=    Set Variable    2a00:8a00:6000:6f00::1:1204
    ${access_interface_DP2}=    Set Variable    2a00:8a00:6000:6f00::1:1205

    &{mandatory_alarm_1}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                           reason=DP is not able to communicate with SAS
    &{mandatory_alarm_2}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    ...                                           reason=DP is not able to communicate with SAS
    &{mandatory_alarm_3}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                           reason=the Fault NCDP switchover is triggered
    &{mandatory_alarm_4}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    ...                                           reason=BTS encountered a connection failure or no response from the Domain Proxy
    &{mandatory_alarm_5}=    Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    ...                                           reason=BTS encountered a connection failure or no response from the Domain Proxy
    &{expected_alarm}=        Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ${mandatory_alarms_list_1}=    Create List    ${mandatory_alarm_1}    ${mandatory_alarm_2}    ${expected_alarm}
    ${mandatory_alarms_list_2}=    Create List    ${mandatory_alarm_3}    ${mandatory_alarm_4}   ${mandatory_alarm_5}

    ${mandatory_alarms_objects_1}=    Create Watchdog Alarm List    ${mandatory_alarms_list_1}
    ${mandatory_alarms_objects_2}=    Create Watchdog Alarm List    ${mandatory_alarms_list_2}

    Log To Console    ${\n}${\n}===================== STEP 1. Prepare test Environment =====================
    Prepare Test Environment DP IPv6

    Log To Console    ${\n}${\n}================== STEP 2. Check connection with primary DP ================
    Log To Console    CBRS_CB012364-C_01_LTE_Static_Mplane_connect_to_IPv6_Domain_Proxy
    Check Cells Are OnAir And Verify ENB Alarms
    Start Watchdog Alarm Detection    expected_alarms=${mandatory_alarms_objects_1}

    Log To Console    ${\n}${\n}========== STEP 3. Check alarm raised on ENB called by primary DP ==========
    Log To Console    Blocking SAS communication
    Block IPv6 SAS communication

    Log To Console    \nLooking for mandatory alarm raise on BTS\n${mandatory_alarm_1}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_1}[fault_id]    fault_name=${mandatory_alarm_1}[fault_name]
    ...                                   severity=${mandatory_alarm_1}[severity]    reason=${mandatory_alarm_1}[reason]    timeout=60

    Log To Console    \nLooking if alarm cleared on BTS\n${mandatory_alarm_1}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_1}[fault_id]    fault_name=${mandatory_alarm_1}[fault_name]
    ...                                   severity=${mandatory_alarm_1}[severity]    reason=${mandatory_alarm_1}[reason]    timeout=180

    Log To Console    \nLooking for mandatory alarm raise on BTS\n${mandatory_alarm_2}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_2}[fault_id]    fault_name=${mandatory_alarm_2}[fault_name]
    ...                                   severity=${mandatory_alarm_2}[severity]    reason=${mandatory_alarm_2}[reason]    timeout=60

    Log To Console    \nRe-enabling SAS communication and check cells status..
    Unblock IPv6 SAS communication

    Log To Console    \nLooking if alarm cleared on BTS\n${mandatory_alarm_2}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_2}[fault_id]    fault_name=${mandatory_alarm_2}[fault_name]
    ...                                   severity=${mandatory_alarm_2}[severity]    reason=${mandatory_alarm_2}[reason]    timeout=180

    Check Cells Are OnAir And Verify ENB Alarms
    Stop Watchdog Alarm Detection And Check For Failures
    Set Suite Variable    ${CB012364-C_01_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}================= STEP 4. Check connection with secondary DP ================
    Log To Console    CBRS_CB012364-C_02_LTE_Static_Mplane_connect_to_IPv6_Secondary_Domain_Proxy
    Block IPv6 SAS communication

    # configuring primaryDomainProxyServer with wrong address
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=primaryDomainProxyServer
           ...    operation=update
           ...    value=ncdp.wg01.wroclaw.nsn-rdnet.net:8443err
           ...    connection=RAT_1ST

    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=secondaryDomainProxyServer
           ...    operation=update
           ...    value=ncdp.wg02.wroclaw.nsn-rdnet.net:8443
           ...    connection=RAT_1ST

    Unblock IPv6 SAS communication
    Check Cells Are OnAir And Verify ENB Alarms
    Log To Console    Connection with secondary DP established
    Set Suite Variable    ${CB012364-C_02_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}================= STEP 5. Change configuration to dual stack =================
    # delta contains primaryDomainProxyServer configured and secondaryDomainProxyServer not configured
    Replace Variables In File
    ...    ${CURDIR}/../Tests/CB012364/Data/dual_stack_delta.json
    ...    ${TEST_LOGS_DIR_PATH}/dual_stack_delta.json    enb_id=${testlines.${testline_id}.enb_id}
    Wait Until BTS Is Not Busy    alias=RAT_1ST
    # delta recommissioning: dual stack and primaryDomainProxyServer configuring
    Wait Until Keyword Succeeds    2x    30s
    ...    Perform Delta Recommissioning    ${TEST_LOGS_DIR_PATH}/dual_stack_delta.json    alias=RAT_1ST

    Log To Console    Resetting site after reconfiguration to dual stack..
    Reset Site    connection=RAT_1ST    timeout=5min    wait_for_reconnection=True
    Check Cells Are OnAir And Verify ENB Alarms

    Log To Console    ${\n}${\n}========= STEP 6. Check if fault switchover is performed successfully ========
    Log To Console    CBRS_CB012364-C_07_LTE_Static_IPv6_Mplane_Fault_Switchover_successfully

    Start Watchdog Alarm Detection    expected_alarms=${mandatory_alarms_objects_2}
    Check Cells Are OnAir And Verify ENB Alarms
    # configuring secondaryDomainProxyServer
    Wait Until Keyword Succeeds    3x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
           ...    dist_name=MRBTS-${testlines.${testline_id}.enb_id}/LNBTS-${testlines.${testline_id}.enb_id}/CBRSPR-1
           ...    parameter=secondaryDomainProxyServer
           ...    operation=update
           ...    value=ncdp.wg02.wroclaw.nsn-rdnet.net:8443
           ...    connection=RAT_1ST
    Wait Until BTS Is Not Busy

    Log to Console    Block connection between DP1 and BTS
    Block Incoming Access From IPv6 Address    IPv6_address=${access_interface_DP1}

    Log To Console    \nLooking for mandatory alarm raise on BTS\n${mandatory_alarm_3}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                   severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=180

    Log To Console    \nLooking if alarm cleared on BTS\n${mandatory_alarm_3}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                   severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=180

    Check Cells Are OnAir And Verify ENB Alarms
    Log To Console    Fault switchover performed successfully
    Set Suite Variable    ${CB012364-C_07_PASSED}    ${TRUE}

    Log To Console    ${\n}${\n}================== STEP 7. Check if fault switchover fails ==================
    Log To Console    CBRS_CB012364-C_08_LTE_Static_IPv6_Mplane_Fault_Switchover_secondary_DP_failed
    # step is started with connection to secondary DP
    Check Cells Are OnAir And Verify ENB Alarms

    # block connection between DP2 and BTS, connection from DP1 is already blocked
    Block Incoming Access From IPv6 Address    IPv6_address=${access_interface_DP2}

    Log To Console    \nLooking for mandatory alarm raise on BTS\n${mandatory_alarm_3}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                   severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=180

    Log To Console    \nLooking if alarm cleared on BTS\n${mandatory_alarm_3}
    Wait For Watchdog Alarm Deactivation    fault_id=${mandatory_alarm_3}[fault_id]    fault_name=${mandatory_alarm_3}[fault_name]
    ...                                     severity=${mandatory_alarm_3}[severity]    reason=${mandatory_alarm_3}[reason]    timeout=180

    Log To Console    \nLooking for mandatory alarm raise on BTS\n${mandatory_alarm_4}
    Wait For Watchdog Alarm Activation    fault_id=${mandatory_alarm_4}[fault_id]    fault_name=${mandatory_alarm_4}[fault_name]
    ...                                   severity=${mandatory_alarm_4}[severity]    reason=${mandatory_alarm_4}[reason]    timeout=180

    Check If Cells Are Disabled    ${testlines.${testline_id}.enb_id}
    Log To Console    Fault switchover failed
    Set Suite Variable    ${CB012364-C_08_PASSED}    ${TRUE}

    [Teardown]    Run Keywords
    ...    Unblock Incoming Access From IPv6 Address    IPv6_address=${access_interface_DP1}    AND
    ...    Unblock Incoming Access From IPv6 Address    IPv6_address=${access_interface_DP2}    AND
	...    Unblock IPv6 SAS communication    AND
	...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Remove All CBRS Certificates From BTS    AND
    ...    Wait Until Keyword Succeeds    20x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Commissioning
           ...    bts_id=${testlines.${testline_id}.enb_id}
           ...    scf_file=${SUITE_LOGS_DIR_PATH}/RAT_1ST_SCFC_Before_Suite.xml
           ...    connection=RAT_1ST

*** Keywords ***

Prepare Test Environment DP IPv6
    # Upload SCF with IPv6 DP config
    ${scf}=    Set Variable    ${CURDIR}/../Tests/CB012364/Data/SCF_CBRS_15_IPv6_DP_FQDN_SBTS00.xml
    Wait Until Keyword Succeeds    20x    5s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    taf.sbts.oam.coam.admin.Perform Commissioning
           ...    bts_id=${testlines.${testline_id}.enb_id}
           ...    scf_file=${scf}
           ...    connection=RAT_1ST
    Log To Console    SCF for DP IPv6 config uploaded

#    Setup Google Chrome And Chrome Driver Version
#    Set Screenshot Directory    ${TEST_LOGS_DIR_PATH}/ScreenShots/

#    Run Keyword And Ignore Error    Remove All CBRS Certificates From BTS
#    OperatingSystem.Create Directory    ${TEST_LOGS_DIR_PATH}/Certificates

#    Generate and save new certificate with CSR    BTS    issuer=NCDP_CA
#    Download TA & CA Core Certificates    @{instaCommonCertificates2}

#    Install Certificate CBRS Vendor chain    BTS    NCDP_CA    NCDP_TA
#    Log To Console    CBRS certificates installed on BTS! Environment preparation COMPLETE!

Check Cells Are OnAir And Verify ENB Alarms
    [Arguments]    ${mandatory}=@{EMPTY}

    Log    \nCheck if cells are onAir    console=true
    All Cells Should Be Enabled And Onair

    Log    \nCheck active alarms    console=true
    FOR    ${i}    IN    ${mandatory}
        Log    Mandatory alarm = ${i}    console=true
    END

    Wait Until Keyword Succeeds    60x    2s    Admin Alarms Get And Check    alias=RAT_1ST
    ...    allowed=${enb_allowed_alarms}
    ...    mandatory=@{mandatory}

Block IPv6 SAS communication
    [Arguments]    ${SAS_IP}=10.44.157.23    # SAS Sim IP address
    ...            ${username}=ute           # SAS Sim username access
    ...            ${password}=Ut3pa5s#1be1  # SAS Sim password access
    Open Connection    ${SAS_IP}
    Login    ${username}    ${password}
    Execute Command    sudo iptables -A OUTPUT -p tcp --destination-port 4433 -j DROP
    Execute Command    sudo iptables -A INPUT -p tcp --destination-port 4433 -j DROP
    Execute Command    sudo iptables-save
    [Teardown]    Close All Connections

Unblock IPv6 SAS communication
    [Arguments]    ${SAS_IP}=10.44.157.23    # SAS Sim IP address
    ...            ${username}=ute           # SAS Sim username access
    ...            ${password}=Ut3pa5s#1be1  # SAS Sim password access
    Open Connection    ${SAS_IP}
    Login    ${username}    ${password}
    Execute Command    sudo iptables -F
    Execute Command    sudo iptables -X
    Execute Command    sudo iptables-save
    [Teardown]    Close All Connections

Block Incoming Access From IPv6 Address
    [Arguments]    ${node_IP}=192.168.255.1    # IP to enb ssh connection
    ...            ${IPv6_address}=2a00:8a00:6000:6f00::1:1204    # IPv6 address to block connection
    Open Connection    ${node_IP}
    Login              ${credentials.enb_username}    ${credentials.enb_password}
    Execute Command    ip6tables -A INPUT -s ${IPv6_address} -j DROP
    [Teardown]    Close All Connections

Unblock Incoming Access From IPv6 Address
    [Arguments]    ${node_IP}=192.168.255.1    # IP to enb ssh connection
    ...            ${IPv6_address}=2a00:8a00:6000:6f00::1:1204    # IPv6 address to block connection
    Open Connection    ${node_IP}
    Login              ${credentials.enb_username}    ${credentials.enb_password}
    Execute Command    ip6tables -D INPUT -s ${IPv6_address} -j DROP
    [Teardown]    Close All Connections
