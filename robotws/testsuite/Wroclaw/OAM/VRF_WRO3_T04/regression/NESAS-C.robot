*** Settings ***
Documentation    Suite for 9203 testcases from Pack C for NESAS.

Resource        ../features/NESAS/Pack_C/TestCases/NESAS-C.robot
Resource        ../features/TLS/TestCases/TLS_certificates.robot
Resource        ../features/CB007672-A/TestCases/CB007672-5G-A-Firewall_m-plane_rate_limiter_and_counters.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        ../common_resources/variables/variables.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/admin/admin.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot

Library         ../common_resources/robot_extensions/robot_extensions.py

Force Tags      CA_RAN_PZ_WRO_3
...             RESPONSIBLE_TESTER=kubacka

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
[1]NESAS-C_X2-U_IPv4_Nmap
    [Tags]
    X2-U_IPv4_Nmap

[1]NESAS-C_X2-C_IPv4_Nmap
    [Tags]
    X2-C_IPv4_Nmap

[1]NESAS-C_Xn-U_IPv6_Nmap
    [Tags]
    Xn-U_IPv6_Nmap

[1]NESAS-C_X2-U_IPv6_Nmap
    [Tags]
    X2-U_IPv6_Nmap

[1]NESAS-C_X2-C_IPv6_Nmap
    [Tags]
    X2-C_IPv6_Nmap

[1]NESAS-C_Xn-U_IPv4_Nmap
    [Tags]
    Xn-U_IPv4_Nmap

[1]NESAS-C_Xn-C_IPv6_Nmap
    [Tags]
    Xn-C_IPv6_Nmap

[1]NESAS-C_Xn-C_IPv4_Nmap
    [Tags]
    Xn-C_IPv4_Nmap

[1]NESAS-C_NG-C_IPv6_Nmap
    [Tags]
    NG-C_IPv6_Nmap

[1]NESAS-C_NG-C_IPv4_Nmap
    [Tags]
    NG-C_IPv4_Nmap

[1]NESAS-C_NG-U_IPv6_Nmap
    [Tags]
    NG-U_IPv6_Nmap

[1]NESAS-C_NG-U_IPv4_Nmap
    [Tags]
    NG-U_IPv4_Nmap

[1]NESAS-C_SPlane_IPv6_Nmap
    [Tags]
    SPlane_IPv6_Nmap

[1]NESAS-C_SPlane_IPv4_Nmap
    [Tags]
    SPlane_IPv4_Nmap

[1]NESAS-C_MPlane_IPv6_Nmap
    [Tags]
    MPlane_IPv6_Nmap

[1]NESAS-C_MPlane_IPv4_Nmap
    [Tags]
    MPlane_IPv4_Nmap

[1]NESAS-C_LMP_IPv4_Nmap
    [Tags]
    LMP_IPv4_Nmap

[1]NESAS-C_M-Plane_IPv4_Nmap_Fronthaul
    [Tags]
    M-Plane_IPv4_Nmap_Fronthaul

[1]NESAS-C_Verify_NE3S_Password_Storage_Uses_One-Way_Hash_Algorithm
    [Tags]
    Verify_Users_Password_Storage

[1]Nesas-5G-C_Protect_Data_Info_Transfer_Other_Protocols
    [Tags]
    Protect_Data_Info_Transfer_Other_Protocols

[1]NESAS-C_Perform_Mount_Options_Check_For_ABIO_Snowfish
    [Tags]
    Perform_Mount_Options_Check_master
    Perform_Mount_Options_Check_slave

[1]NESAS-C_Check_Authorization_Privileges
    [Tags]
    Check_Authorization_Privileges

[1]NESAS-C_Brute_Force_Test_Creation_Unlimited_Login_Sessions_For_NE3S_wsuser_Login_Sessions
    [Tags]
    Brute_Force_Test_Creation_Unlimited_Login_Sessions_For_NE3S_wsuser_Login_Sessions

[1]NESAS-C_Verify_serviseuser_Password_Storage_Uses_One-Way_Hash_Algorithm
    [Tags]
    Verify_Nemuadmin_Password_Storage

#[1]NESAS-C_Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp
#    [Tags]    do poprawy
#    Rate_Limit_for_UDP_echo_request_TWAMP_ipRmDropPcktsRtLimTwamp

#[1]NESAS-C_Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane
#    [Tags]    do poprawy
#    Rate_Limit_for_M-plane_LTE_ipRmDropPcktsRtLimSrLteMplane

[1]NESAS-C_Create_Update_Delete_3_VLANs_On_Classical
    [Tags]
    Create_Update_Delete_3_VLANs_On_Classical

[1]NESAS-C_Check_Limit_Of_SSH_Login_Sessions_With_toor4nsn_Or_serviceuser_User_From_LMP_or_M-Plane
    [Tags]
    Check_Limit_Of_SSH_Login_Sessions_With_toor4nsn_Or_serviceuser_User_From_LMP_or_M-Plane
    Check_Limit_Of_WebEM_Sessions_as_Local_User

#[1]NESAS-C_Check_Firewall_S-Plane_Limit_For_ptp_And_For_ptp_Over_UDP_For_IPv4_And_IPv6
#    [Tags]
#    [1]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane
#    [1]CB007672-5G-A-Rate_Limit_for_TOP_ipRmDropPcktsRtLimSplane_IPv6

[1]NESAS-C_Protect_Data_Info_Transfer_TLS
    [Tags]
    TLS_operations

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

