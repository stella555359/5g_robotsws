*** Settings ***
Documentation
    ...  This test case performs voice call on wcdma ue (CAPABILITIES=WCDMA_only) specified in
    ...  __init__.py file.

Resource  ../../common_resources/sbts_ue.robot


*** Variables ***
${WCDMA_UE_ALIAS}  UE_WCDMA
${WCDMA_VOICE_CALL_TIMEOUT}  20s
${NUMBER}  00104


*** Keywords ***
UE__WCDMA_Voice_Call
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
    Step2: Start Voice Call


Step0: Initial Check For Running Devices And Server
    Log  \nStep0: Initial Check For Running Devices And Server  console=true
    ${specific_ue}  Get UE For Technology  WCDMA_only
    Check Running Devices And Server  ${specific_ue}


Step1: Try To Attach UE To SBTS In Case It Is Not
    Log  Step1: Try to attach UE to SBTS in case it is not  console=true
    ${cells_ids}  Get Ids For WCDMA Cells
    Require Ue  ${WCDMA_UE_ALIAS}  capabilities=WCDMA_only
    Reattach UE  ${WCDMA_UE_ALIAS}
    Attach UE If Needed  ${WCDMA_UE_ALIAS}  ${cells_ids}


Step2: Start Voice Call
    Log  /Step2: Starting voice call...  console=true
    Start Voice Call  voicecall1  ${WCDMA_UE_ALIAS}  ${NUMBER}  ${VOICE_CALL_TIMEOUT}
    Await Voice Call Finish  voicecall1
    Log  Voice call ended.  console=true


TC Setup
    Modify Resource Search Order  UE__WCDMA_Voice_call
    Common Test Setup


TC Teardown
    Common Test Teardown
