*** Settings ***
Documentation
...     [Procedure]     "SOE verification after configuration reset and with mplane ip , and without mplane ip configuration"
...     [Author]        "Nandini P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
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
[1]TRS_5GC000268_verify_SOE_via_mplane
        Perform Commissioning       scf_file=${SOE_enabled_commissioning}   verify_bts_status=${True}     timeout=600     alias=default
       Verify SOE is enabled
       Verify Alarm      faultid=4654      occurrences=0       should_exist=${False}      alarm_type=active
       Read mplane IP
       Check nmap status for '${mplane_ipv4}' '${NMAP_COMMAND}'
       Perform Recommissioning     type=param      rat=nr     param_path=MRBTS-2323/MNL-1/MNLENT-1/SECADM-1:ethernetPortSecurityEnabled
       ...    operation=update    value=false    timeout=300
       Verify SOE is disabled
       Verify Alarm      faultid=4654      occurrences=1       should_exist=${True}      alarm_type=active
       Perform Recommissioning     type=param      rat=nr     param_path=MRBTS-2323/MNL-1/MNLENT-1/SECADM-1:ethernetPortSecurityEnabled
       ...  operation=update    value=true     timeout=300
       Verify SOE is enabled
       Verify Alarm      faultid=4654      occurrences=0       should_exist=${False}      alarm_type=active
       'Disable' Ethernet port security via '${mplane_ipv4}'
       Verify SOE is disabled
       'Enable' Ethernet port security via '${mplane_ipv4}'
       Verify SOE is enabled
       Verify alarm        expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
       Verify alarm        expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=history