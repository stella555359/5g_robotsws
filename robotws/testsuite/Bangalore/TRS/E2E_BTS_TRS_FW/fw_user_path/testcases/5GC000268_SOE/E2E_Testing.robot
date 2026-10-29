*** Settings ***
Documentation
...     [Procedure]             "SOE verification with parameter disable, enable and persistency check after upgrade"
...     [Author]                "Nandini P"
...     [Maintenance]           "TRS I & V Bangalore Team"
...     [Function_Hash_Tags]    "SOE"
#Force Tags    SM TRSIV Test 3       CRT
#Comment : Verify SOE with TWAMP configuration , TWAMP should not have nay impact on SOE

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

***Test Cases***
[1][1.0] To verify Ethernet Port Security Feature in E2E testing.
       Perform Recommissioning     type=param           param_path=${SOE_Moc}  operation=update    value=true     timeout=300
       Verify SOE is enabled
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Verify alarm        expected_alarms=${expected_alarms}
       Perform Recommissioning     type=param           param_path=${SOE_Moc}  operation=update    value=false     timeout=300
       Verify SOE is disabled
       Check snapshot collection and IM snapshot is successful
       SSH and R&D should not have any impact
       Perform Recommissioning     type=param           param_path=${SOE_Moc}  operation=update    value=true     timeout=300
       Verify SOE is enabled

       Perform software upgrade and Check SOE is enabled
     Change Ethernet port security       enable=${False}   timeout=120     alias=default
     Verify SOE is disabled
     SSH and R&D should not have any impact

     Change Ethernet port security       enable=${True}  timeout=120     alias=default
     Verify SOE is enabled
     SSH and R&D should not have any impact
***Keywords***
Perform software upgrade and Check SOE is enabled
       Perform software download and update     wft_profile=sbtstrunk_00    package=auto        activate_sw=true        update_timeout=1600
       sleep    300
       Verify SOE is enabled
       ${soe_status}=      Get Parameter      param_path=${SOE_Moc}
       Should Be True     '${soe_status}'=='True'
       Verify alarm        expected_alarms=${expected_alarms}
Verify SOE is enabled
    ${output}=       Run  ping -c 5 ${enb_internal_ip}
    Should contain      ${output}       5 packets transmitted, 0 received, 100% packet loss
Check snapshot collection and IM snapshot is successful
    ${snapshot_file}=       Collect snapshot
    FIle should not be empty        ${snapshot_file}
    ${im_snapshot_file}=    Collect IM snapshot
    FIle should not be empty        ${im_snapshot_file}
Verify SOE is disabled
      ${output}=       Run  ping -c 5 ${enb_internal_ip}
      Should contain    ${output}  5 packets transmitted, 5 received, 0% packet loss
SSH and R&D should not have any impact
    ${ssh_status}=      Get Parameter      param_path=${SSH_parameter}
    Should Be True     '${ssh_status}'=='True'

    ${rd_status}=      Get Parameter      param_path=${R&D_parameter}
    Should Be True     '${rd_status}'=='True'

    Setup Remote Access    remote_device=bts
    ${stdout}       Remote Command Execute      command=ls /ffs/run
    Should not Be Empty     ${stdout}
    Teardown remote Access
