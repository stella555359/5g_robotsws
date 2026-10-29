*** Settings ***
Documentation
...   author: Andy
...   contact: fan-andy.yu@nokia-sbell.com
...   this is a robot case about CB008541
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_120db}              ${120}
${PA_NormalValue}        ${1}
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
&{fault_62003}              faultId=${62003}
&{fault_1933}             faultId=${1933}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_62003}    &{fault_1933}
...    &{fault_6331}
${scf_for_reload}          10_5_UTESRAN001T10787_CB005825_case06_reload_scf
# ${DEBUG_MODE}    ${TRUE}
${scell_small_bwp}         \[187367435: 173\] \[187367436: 173\]
${startUacBarringTimer}    startUacBarringTimer
${UacFsmAutoUacMax}    UacFsmAutoUacMax
${stopUacBarringTimer}    stopUacBarringTimer

# ${Feature_CB005825_actUeBasedAnrNrHo}     actUeBasedAnrNrHo
# ${dist_name}                              MRBTS-10787/LNBTS-10787

# ${Feature_CB005825_parameter1}     actAutoNrHoNeighRemoval
# ${dist_name1}                       MRBTS-10787/LNBTS-10787/ANR-0

# ${Feature_CB005825_parameter2}     anrNrHoNbrRelRemGuardTime
# ${dist_name2}                       MRBTS-10787/LNBTS-10787/ANR-0

# ${Feature_CB005825_parameter3}     nrPciHoNbrRelAddThresh
# ${dist_name3}                       MRBTS-10787/LNBTS-10787/LNCEL-22/LNHON-0

*** Test Cases ***
# Upgrade
#     [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#     Run Feature Case
#     [Teardown]    TL Suite Teardown

CB008242-SR_B_01_01 Upgrade auto UAC triggered by number of RRC connections with static UAC
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008242_case1
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    # Unblock BTS10787 LTE Cell_22
    Unblock BTS10787 NR Cell_11
    AT.UE Attach
    sleep    60s
    # HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    # sleep    10s
    # Check HO type for BTS0
    # Check InterRatToNr for BTS0
    Check auto UAC for BTS0
    # #Check SA State For BTS0

CB008242-SR_E_09_01 gNB stops reserving the cell for operator use for PLMNs when gNB stops max autoUAC
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008242_case9
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    # Unblock BTS10787 LTE Cell_22
    Unblock BTS10787 NR Cell_11
    AT.UE Attach
    sleep    60s
    # HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    # sleep    10s
    # Check HO type for BTS0
    # Check InterRatToNr for BTS0
    Check auto UAC for BTS0
    # #Check SA State For BTS0
    sleep    200s
    Check cell reserved in max autoUAC for BTS0
    AT.UE Detach
    sleep    60s
    Check cell stop reserved when out of max autoUAC for BTS0




*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Check HO type for BTS${i}
    Log To Console    Check HO type
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a EHandoverType_InterRatToNr | grep -av grep
    Should Contain    ${ret}    EHandoverType_InterRatToNr

Check small BWP for BTS${i}
    Log To Console    Check HO type
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a BwpProfileId | grep -av grep
    Should Contain    ${ret}    ${scell_small_bwp}

Check auto UAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a startUacBarringTimer | grep -av grep
    Should Contain    ${ret}    ${startUacBarringTimer}

Check cell reserved in max autoUAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a UacFsmAutoUacMax | grep -av grep
    Should Contain    ${ret}    ${UacFsmAutoUacMax}

Check cell stop reserved when out of max autoUAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a stopUacBarringTimer | grep -av grep
    Should Contain    ${ret}    ${stopUacBarringTimer}

Block BTS10787 NR Cell_11
    Log To Console    Block BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MaxValue}

Unblock BTS10787 NR Cell_11
    Log To Console    Unblock BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}
