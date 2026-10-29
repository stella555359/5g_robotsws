*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB007332
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_NormalValue}        ${1}
${PA_CA}                 ${25}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

# CB007334_01 LNRELGNBCELL removal due to insufficient frequency of B1-NR MR
#     [Documentation]    Author:Chen jiahao
#     [Tags]    10_5_UTESRAN001T6483    SCF_10_5_UTESRAN001T6483_CB007334_case01
#     Start Multi Bts Log
#     Attach UE to ENB and 5G2
#     sleep    5s
#     AT.Prepare UE
#     FOR    ${x}    IN RANGE    ${3}
#       AT.UE Attach
#       AT.UE Detach
#       sleep    5s
#     END
#     sleep    20s
#     Check LNRELGNBCELL State

# CB007334_03 LNRELGNBCELL creation when X2 data has no ambiguity without fast addition enabled
#     [Documentation]    author:jiahao.chen
#     [Tags]    10_5_UTESRAN001T6483    SCF_10_5_UTESRAN001T6483_CB007334_case03
#     Start Multi Bts Log

# CB007334_05 LNRELGNBCELL creation for unknown NR-PCINR-carrier pair
#     [Documentation]    author:jiahao.chen
#     [Tags]    10_5_UTESRAN001T6483    SCF_10_5_UTESRAN001T6483_CB007334_case05
#     Start Multi Bts Log

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
#     Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
#     Run Keyword And Ignore Error    Stop All Bts Log
#     Run Keyword And Ignore Error    AT.UE Detach
#     Run Keyword And Ignore Error    Stop tcpdump And download by command For Remote
#     ...    ${0}
#     Run Keyword And Ignore Error    Stop tcpdump And download by command For Remote
#     ...    ${3}
#     # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
#     Run Keyword And Ignore Error    Disconnect All VM

# Stop All Bts Log
#     Stop All BTSLog And Download to Local

# Attach UE to ENB and 5G2
#     Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_MinValue}
#     Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_MinValue}
#     Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_MinValue}

# Check LNRELGNBCELL State
#     Sleep    5s
#     ${check_LNRELGNBCELL}    Create List    Create : LNBTS-6483/LNCEL-32/LNRELGNBCELL-255    sourceOfData = UE    nrStatus = available
#     ${ret}    OperatingSystem.Run
#     ...    command=cat ${BTS0_LOG_PATH} |grep -a "Create : LNBTS-6483/LNCEL-32/LNRELGNBCELL-255" | grep -av grep
#     Should Contain    ${ret}    Create : LNBTS-6483/LNCEL-32/LNRELGNBCELL-255
#     ${ret}    OperatingSystem.Run
#     ...    command=cat ${BTS0_LOG_PATH} |grep -a "sourceOfData = UE" | grep -av grep
#     Should Contain    ${ret}    sourceOfData = UE
#     ${ret}    OperatingSystem.Run
#     ...    command=cat ${BTS0_LOG_PATH} |grep -a "nrStatus = available" | grep -av grep
#     Should Contain    ${ret}    nrStatus = available