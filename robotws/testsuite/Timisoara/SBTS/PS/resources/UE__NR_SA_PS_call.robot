*** Settings ***
Documentation
    ...  This test case performs downlink data transfer on nr ue
    ...  (CAPABILITIES=NR_SA) specified in __init__.py file.
    ...  If PS throughput is less than ${MIN_NR_THROUGHPUT}, TC will set a restriction.

Resource  ../../common_resources/sbts_ue.robot


*** Variables ***
${NR_SA_DESIRED_THROUGHPUT_UPLINK}  30 Mbits/sec
${NR_SA_DESIRED_THROUGHPUT_DOWNLINK}  50 Mbits/sec
${NR_SA_MIN_THROUGHPUT_UPLINK}  20 Mbits/sec
${NR_SA_MIN_THROUGHPUT_DOWNLINK}  40 Mbits/sec
${NR_SA_UE_ALIAS}  UE_NR_SA
${NR_SA_PS_DURATION}  40s


*** Keywords ***
UE__NR_SA_PS_Call
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.int.net.nokia.com/browse/TAT-23401
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  11.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23401 - Initial TAT creation
    ...  28.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26885 - Enhancement for call tests
    ...  29.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27597 - Multiple enhancements for call tests
    ...  21.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28784 - Call test improvements add reattach keyword

    Set Tags  UE  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com  PHASE-CRT

    Step0: Initial Check For Running Devices And Server
    Step1: Try To Attach UE To SBTS In Case It Is Not
    Step2: Make PS Uplink Call
    Step3: Make PS Downlink Call


Step0: Initial Check For Running Devices And Server
    Log  \nStep0: Initial Check For Running Devices And Server  console=true
    ${specific_ue}  Get UE For Technology  NR_SA
    Check Running Devices And Server  ${specific_ue}


Step1: Try To Attach UE To SBTS In Case It Is Not
    Log  Step1: Try to attach UE to SBTS in case it is not  console=true
    ${cells_ids}  Get Ids For NR Cells
    Set Test Variable  ${CELLS_IDS}
    Require Ue  ${NR_SA_UE_ALIAS}  capabilities=NR_SA
    Reattach UE  ${NR_SA_UE_ALIAS}
    Attach UE If Needed  ${NR_SA_UE_ALIAS}  ${CELLS_IDS}


Step2: Make PS Uplink Call
    Log  \nStep2: Make PS uplink call  console=true
    Check If UE Has IP Address  ${NR_SA_UE_ALIAS}
    Start UDP Uplink  ${NR_SA_UE_ALIAS}  ${NR_SA_PS_DURATION}  desired_throughput=${NR_SA_DESIRED_THROUGHPUT_UPLINK}
    ...  min_throughput=${NR_SA_MIN_THROUGHPUT_UPLINK}  desired_cell_list=${CELLS_IDS}


Step3: Make PS Downlink Call
    Log  \nStep3: Make PS downlink call  console=true
    Check If UE Has IP Address  ${NR_SA_UE_ALIAS}
    Start UDP Downlink  ${NR_SA_UE_ALIAS}  ${NR_SA_PS_DURATION}  desired_throughput=${NR_SA_DESIRED_THROUGHPUT_DOWNLINK}
    ...  min_throughput=${NR_SA_MIN_THROUGHPUT_DOWNLINK}  desired_cell_list=${CELLS_IDS}


TC Setup
#    Modify Resource Search Order  UE__NR_NSA_PS_call
    ${ERRORS}    Create list
    Set Test Variable    ${ERRORS}
    Setup Admin    192.168.255.129
#    Common Test Setup


TC Teardown
    Teardown Admin
    Should Be Empty    ${ERRORS}
#    Common Test Teardown  collect_snapshot=never
