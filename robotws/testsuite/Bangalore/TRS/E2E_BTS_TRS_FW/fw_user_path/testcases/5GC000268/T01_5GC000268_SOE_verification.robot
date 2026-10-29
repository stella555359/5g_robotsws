*** Settings ***
Documentation
...     [Procedure]             "SOE verification with parameter disable, enable and persistency check after upgrade"
...     [Author]                "Nandini P"
...     [Maintenance]           "TRS I & V Bangalore Team"
...     [Function_Hash_Tags]    "SOE"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/5G_Common_SOE.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library         Selenium2Library

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

***Test Cases***
[1]TRS_5GC000268_enable_disable_ethernet_port_security
       Perform Commissioning       scf_file=${SOE_enabled_commissioning}   verify_bts_status=${True}     timeout=500     alias=default
       Verify SOE is enabled
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Check nmap when SOE is enabled
       Verify Alarm      faultid=4654      occurrences=0       should_exist=${False}      alarm_type=active
       Sleep    45
       Perform Recommissioning     type=param      rat=nr     param_path=MRBTS-2323/MNL-1/MNLENT-1/SECADM-1:ethernetPortSecurityEnabled
       ...    operation=update    value=false     timeout=300
       Verify SOE is disabled
       Check nmap when SOE is disabled
       Verify Alarm      faultid=4654      occurrences=1       should_exist=${True}      alarm_type=active
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Perform Recommissioning     type=param      rat=nr     param_path=MRBTS-2323/MNL-1/MNLENT-1/SECADM-1:ethernetPortSecurityEnabled
       ...    operation=update    value=true     timeout=300
       Sleep    45
       Verify SOE is enabled
       Verify Alarm      faultid=4654      occurrences=0       should_exist=${False}      alarm_type=active
       Change Ethernet port security       enable=${False}   timeout=120     alias=default
       Verify SOE is disabled
       SSH and R&D should not have any impact
       Change Ethernet port security       enable=${True}  timeout=120     alias=default
       Verify SOE is enabled
       SSH and R&D should not have any impact
       Verify alarm        expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
       Verify alarm        expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=history