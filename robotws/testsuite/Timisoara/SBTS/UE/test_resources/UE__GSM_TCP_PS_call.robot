*** Settings ***
Documentation
    ...  This test case performs uplink and downlink data transfer on gsm ue
    ...  (CAPABILITIES=GSM_only) specified in __init__.py file.
    ...  If PS throughput is less than ${MIN_GSM_THROUGHPUT}, TC will set a restriction.

Resource  ../../common_resources/sbts_ue.robot


*** Variables ***
${GSM_DESIRED_THROUGHPUT_UPLINK}  50 Kbits/sec
${GSM_DESIRED_THROUGHPUT_DOWNLINK}  100 Kbits/sec
${GSM_MIN_THROUGHPUT_UPLINK}  25 Kbits/sec
${GSM_MIN_THROUGHPUT_DOWNLINK}  50 Kbits/secc
${GSM_UE_ALIAS}  UE_GSM
${GSM_PS_DURATION}  40s


*** Keywords ***
UE__GSM_TCP_PS_Call
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-28753
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28753 - Initial TAT creation

    Set Tags  UE  MAINTAINER-bogdan.boldurean@nokia.com  PHASE-CRT

    Step0: Initial Check For Running Devices And Server
    Step1: Try To Attach UE To SBTS In Case It Is Not
    Step2: Make PS Uplink Call
    Step3: Make PS Downlink Call


Step0: Initial Check For Running Devices And Server
    Log  \nStep0: Initial Check For Running Devices And Server  console=true
    ${specific_ue}  Get UE For Technology  GSM_only
    Check Running Devices And Server  ${specific_ue}


Step1: Try To Attach UE To SBTS In Case It Is Not
    Log  Step1: Try to attach UE to SBTS in case it is not  console=true
    ${cells_ids}  Get Ids For GSM Cells
    Set Test Variable  ${CELLS_IDS}
    Require Ue  ${GSM_UE_ALIAS}  capabilities=GSM_only
    Reattach UE  ${GSM_UE_ALIAS}
    Attach UE If Needed  ${GSM_UE_ALIAS}  ${CELLS_IDS}


Step2: Make PS Uplink Call
    Log  \nStep2: Make PS uplink call  console=true
    Check If UE Has IP Address  ${GSM_UE_ALIAS}
    Start TCP Uplink  ${GSM_UE_ALIAS}  ${GSM_PS_DURATION}  desired_throughput=${GSM_DESIRED_THROUGHPUT_UPLINK}
    ...  min_throughput=${GSM_MIN_THROUGHPUT_UPLINK}  desired_cell_list=${CELLS_IDS}


Step3: Make PS Downlink Call
    Log  \nStep3: Make PS downlink call  console=true
    Check If UE Has IP Address  ${GSM_UE_ALIAS}
    Start TCP Downlink  ${GSM_UE_ALIAS}  ${GSM_PS_DURATION}  desired_throughput=${GSM_DESIRED_THROUGHPUT_DOWNLINK}
    ...  min_throughput=${GSM_MIN_THROUGHPUT_DOWNLINK}  desired_cell_list=${CELLS_IDS}


TC Setup
    Modify Resource Search Order  UE__GSM_TCP_PS_call
    Common Test Setup


TC Teardown
    Common Test Teardown
