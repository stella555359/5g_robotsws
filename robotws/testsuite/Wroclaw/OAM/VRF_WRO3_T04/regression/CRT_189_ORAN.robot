*** Settings ***
Documentation    Suite for parity feature CB009029_CB009131 on ABIP

Resource        ../features/CB013411/TestCases/CB013411_C.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/commissioning/commissioning.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${SCF}=             ${CURDIR}/../features/CB013411/Resources/CLOUD_SRAN_TL189_DHCP_CLIENT.xml
${BASIC_SCF}=       ${CURDIR}/base_scf.xml

*** Test Cases ***
[1]CB013411_CB006114-A_IPSec_defect_handling_between_the_DU_and_RU_internal_DHCP
    [Tags]
    CB013411-A_IPSec_defect_handling_between_the_DU_and_RU

[1]CB013411_CB006436_Counters_verification_NetAct_WebEM
    [Tags]
    CB013411-SyVe_Counters_Verification

[1]CB013411_CB006436_Spoof_prevention_IPv4
    [Tags]
    CB013411-SyVe_Spoof_Prevention_IPv4

[1]CB013411_CB006436_Stateful_packet_filtering_IPv4
    [Tags]
    CB013411-SyVe_Stateful_Packet_Filtering_IPv4

[1]CB013411_CB006436_Stateless_packet_filtering_IPv4
    [Tags]
    CB013411-SyVe_Stateless_Packet_Filtering_IPv4

[1]CB013411_CB006436_Stateless_packet_filtering_IPv4_ORAN
    [Tags]
    CB013411-SyVe_Stateless_Packet_Filtering_IPv4_ORAN



*** Keywords ***
Suite Setup
    Download SCF    ${BASIC_SCF}
    Commission SCF    ${SCF}
    ${conn}=    Connect to ADMIN
    ${netconf_account}=    Create Accounts Array
    admin.configure_netconf_accounts
    ...     unsecure_ciphering=False
    ...     authentication_method=NoAuthentication
    ...     accounts=${netconf_account}
    ...     connection=${conn}
    Wait Until Keyword Succeeds    15min    30sec    Check If All Cells Are OnAir

    Common Gathering Logs for Common Suite Setup
    Add Alarm To Allowed Alarms     10     No connection to unit

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}
    Commission SCF    ${BASIC_SCF}
    Remove Multiple Alarms from Watchdog List  10

Test Setup
    Add Multiple Alarms to Watchdog List    10
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown



