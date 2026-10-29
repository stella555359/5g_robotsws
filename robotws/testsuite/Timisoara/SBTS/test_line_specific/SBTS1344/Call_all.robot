*** Settings ***
Resource    ../../UE/test_resources/UE__NR_NSA_PS_call.robot
Resource    ../../UE/test_resources/UE__NR_SA_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_Voice_call.robot

Resource    ../../UE/test_resources/UE__NR_NSA_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__NR_SA_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_TCP_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_TCP_PS_call.robot

Documentation  Suite for calls.

Suite Setup    Map BuildShareTimi01


*** Variables ***
${NR_SA_DESIRED_THROUGHPUT_UPLINK}  301 Mbits/sec
${NR_SA_DESIRED_THROUGHPUT_DOWNLINK}  501 Mbits/sec
${NR_SA_MIN_THROUGHPUT_UPLINK}  100 Mbits/sec
${NR_SA_MIN_THROUGHPUT_DOWNLINK}  100 Mbits/sec
${NR_SA_UE_ALIAS}  UE_NR_SA
${NR_SA_PS_DURATION}  40s
${NR_NSA_DESIRED_THROUGHPUT_UPLINK}  301 Mbits/sec
${NR_NSA_DESIRED_THROUGHPUT_DOWNLINK}  501 Mbits/sec
${NR_NSA_MIN_THROUGHPUT_UPLINK}  71 Mbits/sec
${NR_NSA_MIN_THROUGHPUT_DOWNLINK}  121 Mbits/sec
${NR_NSA_UE_ALIAS}  UE_NR_NSA
${NR_NSA_PS_DURATION}  40s
${LTE_DESIRED_THROUGHPUT_UPLINK}  101 Mbits/sec
${LTE_DESIRED_THROUGHPUT_DOWNLINK}  161 Mbits/sec
${LTE_MIN_THROUGHPUT_UPLINK}  21 Mbits/sec
${LTE_MIN_THROUGHPUT_DOWNLINK}  41 Mbits/sec
${LTE_UE_ALIAS}  UE_LTE
${LTE_PS_DURATION}  40s
${GSM_DESIRED_THROUGHPUT_UPLINK}  201 Kbits/sec
${GSM_DESIRED_THROUGHPUT_DOWNLINK}  151 Kbits/sec
${GSM_MIN_THROUGHPUT_UPLINK}  31 Kbits/sec
${GSM_MIN_THROUGHPUT_DOWNLINK}  31 Kbits/secc
${GSM_UE_ALIAS}  UE_GSM
${GSM_PS_DURATION}  40s
${GSM_VOICE_CALL_TIMEOUT}  20s
${NUMBER}  00104


*** Test Cases ***
[1]UE__NR_NSA_PS_Call
    [Setup]  UE__NR_NSA_PS_Call.TC Setup
    [Timeout]    20 minutes
    UE__NR_NSA_PS_Call
    [Teardown]    UE__NR_NSA_PS_Call.TC Teardown

[1]UE__LTE_PS_Call
    [Setup]  UE__LTE_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__LTE_PS_call
    [Teardown]    UE__LTE_PS_call.TC Teardown

[1]UE__GSM_PS_Call
    [Setup]  UE__GSM_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_PS_call
    [Teardown]    UE__GSM_PS_call.TC Teardown

[1]UE__GSM_Voice_Call
    [Setup]  UE__GSM_Voice_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_Voice_call
    [Teardown]  UE__GSM_Voice_call.TC Teardown


[1]UE__NR_NSA_TCP_PS_Call
    [Setup]  UE__NR_NSA_TCP_PS_Call.TC Setup
    [Timeout]    20 minutes
    UE__NR_NSA_TCP_PS_Call
    [Teardown]    UE__NR_NSA_TCP_PS_Call.TC Teardown

[1]UE__LTE_TCP_PS_Call
    [Setup]  UE__LTE_TCP_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__LTE_TCP_PS_call
    [Teardown]    UE__LTE_TCP_PS_call.TC Teardown

[1]UE__GSM_TCP_PS_Call
    [Setup]  UE__GSM_TCP_PS_call.TC Setup
    [Timeout]    20 minutes
    UE__GSM_TCP_PS_call
    [Teardown]    UE__GSM_TCP_PS_call.TC Teardown


*** Keywords ***
Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sudo_command}  Catenate  SEPARATOR=  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/ cifs _netdev,
    ...  noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sudo_command}
    Run  sudo mount -a
    Run  sudo cp -r /home/ute/testline_configuration/10_18_UTESRANCLOUD1344 /home/ute/
