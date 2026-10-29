*** Settings ***
Documentation
...  authors: Aleksandra Bialas, Michal Rzeszowski
...  contact: aleksandra.bialas@nokia.com, michal.rzeszowski@nokia.com
...  Description: [1]5GC001578-RA-5GC000309_C_08 SCTP association termination for F1-C interface(Detected by DU)
...  Purpose of this test is to verify that fault SCTP connection is terminated when failure is detected and alarm is
...  raised on DU and CU

Library    SctpConnectivityCheck.py
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Setup       Common Preconditions
Test Teardown    Common Postconditions

*** Variables ***
${fault_name} =   F1 SCTP endpoint in DU
${fault_id} =  7303
${fault_name_cu} =  F1 SCTP endpoint in CU
${alarm_id} =  	7107
${password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${gnb_id} =  0
${procedural_states}=  Configured
${bts_id} =  0
${du_id} =  0

*** Test Cases ***
[1]5GC001578-RA-5GC000309_C_08 SCTP association termination for F1-C interface(Detected by DU)
    Ssh To Cpif Then Execute Ip Tables And Tcpdump  ${password}
    Verify Alarm is Active on gNB    ${fault_name}
    Verify Procedural and Blocking State    ${gnb_id}   ${procedural_states}
    Sleep    3 minutes
    Verify Alarm is Active on CU    ${fault_id}    ${fault_name_cu}    ${alarm_id}
    Unblock Sctp Connection         ${password}


*** Keywords ***
Setup
    Verify gNB is onAir    ${gnb_id}   ${du_id}
    Verify CU state is operational    ${bts_id}

Teardown
    clear iptables      ${password}

