*** Settings ***
Documentation
    ...  This test case performs downlink data transfer on lte ue
    ...  (CAPABILITIES=LTE_only) specified in __init__.py file.
    ...  If PS throughput is less than ${MIN_LTE_THROUGHPUT}, TC will set a restriction.

Resource  ../../common_resources/sbts_ue.robot


*** Variables ***
${LTE_DESIRED_THROUGHPUT_UPLINK}  20 Mbits/sec
${LTE_DESIRED_THROUGHPUT_DOWNLINK}  30 Mbits/sec
${LTE_MIN_THROUGHPUT_UPLINK}  10 Mbits/sec
${LTE_MIN_THROUGHPUT_DOWNLINK}  20 Mbits/sec
${LTE_UE_ALIAS}  UE_LTE
${LTE_PS_DURATION}  40s


*** Keywords ***
UE__LTE_TCP_PS_Call
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
    ${specific_ue}  Get UE For Technology  LTE_only
    Check Running Devices And Server  ${specific_ue}


Step1: Try To Attach UE To SBTS In Case It Is Not
    Log  Step1: Try to attach UE to SBTS in case it is not  console=true
    ${cells_ids}  Get Ids For LTE Cells
    Set Test Variable  ${CELLS_IDS}
    Require Ue  ${LTE_UE_ALIAS}  capabilities=LTE_only
    Reattach UE  ${LTE_UE_ALIAS}
    Attach UE If Needed  ${LTE_UE_ALIAS}  ${CELLS_IDS}


Step2: Make PS Uplink Call
    Log  \nStep2: Make PS uplink call  console=true
    Check If UE Has IP Address  ${LTE_UE_ALIAS}
    Start TCP Uplink  ${LTE_UE_ALIAS}  ${LTE_PS_DURATION}  desired_throughput=${LTE_DESIRED_THROUGHPUT_UPLINK}
    ...  min_throughput=${LTE_MIN_THROUGHPUT_UPLINK}  desired_cell_list=${CELLS_IDS}


Step3: Make PS Downlink Call
    Log  \nStep3: Make PS downlink call  console=true
    Check If UE Has IP Address  ${LTE_UE_ALIAS}
    Start TCP Downlink  ${LTE_UE_ALIAS}  ${LTE_PS_DURATION}  desired_throughput=${LTE_DESIRED_THROUGHPUT_DOWNLINK}
    ...  min_throughput=${LTE_MIN_THROUGHPUT_DOWNLINK}  desired_cell_list=${CELLS_IDS}


TC Setup
    Modify Resource Search Order  UE__LTE_TCP_PS_call
    Common Test Setup


TC Teardown
    Common Test Teardown
