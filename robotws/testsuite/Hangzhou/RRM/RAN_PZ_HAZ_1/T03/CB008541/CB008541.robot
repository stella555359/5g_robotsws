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
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
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
&{fault_1933}              faultId=${1933}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_62003}    &{fault_1933}
...    &{fault_6331}
${scf_for_reload}          10_5_UTESRAN001T10787_CB005825_case06_reload_scf
# ${DEBUG_MODE}    ${TRUE}
${scell_small_bwp}         selectedBwpprofile ID:173

# ${Feature_CB005825_actUeBasedAnrNrHo}     actUeBasedAnrNrHo
# ${dist_name}                              MRBTS-10787/LNBTS-10787

# ${Feature_CB005825_parameter1}     actAutoNrHoNeighRemoval
# ${dist_name1}                       MRBTS-10787/LNBTS-10787/ANR-0

# ${Feature_CB005825_parameter2}     anrNrHoNbrRelRemGuardTime
# ${dist_name2}                       MRBTS-10787/LNBTS-10787/ANR-0

# ${Feature_CB005825_parameter3}     nrPciHoNbrRelAddThresh
# ${dist_name3}                       MRBTS-10787/LNBTS-10787/LNCEL-22/LNHON-0


# ${DEBUG_MODE}              ${True}

*** Test Cases ***
# Upgrade
#     [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#     Run Feature Case
#     [Teardown]    TL Suite Teardown

CB008541-A_01_SA_2CC_Feature activation and deactivation of the CB008541 feature and Counters update
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008541_case1
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    # Unblock BTS10787 LTE Cell_22
    Unblock BTS10787 NR Cell_11
    AT.UE Attach
    sleep    10s
    # HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    # sleep    10s
    # Check HO type for BTS0
    # Check InterRatToNr for BTS0
    Check small BWP for BTS0
    # #Check SA State For BTS0

CB008541-A_05_SA Feature activation and deactivation of the CB008541 feature
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008541_case1
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${2}
    Start Multi Bts Log
    # Unblock BTS10787 LTE Cell_22
    Unblock BTS10787 NR Cell_11
    AT.UE Attach
    sleep    10s
    # HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    # sleep    10s
    # Check HO type for BTS0
    # Check InterRatToNr for BTS0
    Check small BWP for BTS0
    # #Check SA State For BTS0

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
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'selectedBwpprofile ID:173' | grep -av grep
    Should Contain    ${ret}    selectedBwpprofile ID:173

Check InterRatToNr for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Handover finished with success' | grep -av grep
    Should Contain    ${ret}    Handover finished with success

Check SA State For BTS${i}
    Log To Console    Check SA State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'PDU sessions successfully set up' | grep -av grep
    Should Contain    ${ret}    PDU sessions successfully set up

Unblock BTS10787 LTE Cell_22
    Log To Console    Unblock BTS10787 LTE Cell_22
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    Log    HO from BTS10787 LTE Cell_22 to BTS10787 NR Cell_11
    ${increase_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15s

Block BTS10787 NR Cell_11
    Log To Console    Block BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MaxValue}

Unblock BTS10787 NR Cell_11
    Log To Console    Unblock BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 NR Cell_12
    Log To Console    Unblock BTS10787 NR Cell_12
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_NormalValue}

Check nrAnrHoPciCounter For BTS${i}
    Log To Console    Check nrAnrHoPciCounter
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a nrAnrHoPciCounter | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter

Check NO LNRELN ADD For BTS${i}
    Log To Console    Check NO LNRELN ADD
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-10787/LNCEL-22/LNRELN-255' | grep -av grep
    Should Not Contain    ${ret}    operation: Create : LNBTS-10787/LNCEL-22/LNRELN-255

Check LNRELN ADD For BTS${i}
    Log To Console    Check NRRELN ADD
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-10787/LNCEL-22/LNRELN-255' | grep -av grep
    Should Contain    ${ret}    operation: Create : LNBTS-10787/LNCEL-22/LNRELN-255

Unblock BTS10787 LTE AHEGB_ANT13
    Log To Console    Unblock BTS10787 LTE AHEGB_ANT13
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 NR AZHM_ANT5678
    Log To Console    Unblock BTS10787 NR AZHM_ANT5678
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_NormalValue}

Increase BTS10787 LTE AHEGB_ANT13
    Log    Increase BTS10787 LTE AHEGB_ANT13
    ${increase_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${3}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    5s

Increase BTS10787 LTE AHEGB_ANT13 decrease AZHM_1234
    Log    Increase BTS10787 LTE AHEGB_ANT13
    ${increase_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${2}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    5s

Block BTS10787 NR AZHM_ANT5678
    Log To Console    Block BTS10787 NR AZHM_ANT5678
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_120db}

Check nbrPciHoCounters = 1 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 1
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 1' | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter: 1

Check nbrPciHoCounters = 2 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 2' | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter: 2

Check nbrPciHoCounters = 3 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 3
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 3' | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter: 3

Check nbrPciHoCounters = 4 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 4
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 4' | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter: 4

Check nbrPciHoCounters = 5 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 5
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 5' | grep -av grep
    Should Contain    ${ret}    nrAnrHoPciCounter: 5

Check LNRELN_0 of Cell22 DEL For BTS${i}
    Log To Console    Check LNRELN_0 of Cell22 DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-0' | grep -av grep
    Should Contain    ${ret}    Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-0

Check LNRELN_0 of Cell23 no DEL For BTS${i}
    Log To Console    Check LNRELN_0 of Cell23 no DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Export operation: Delete : LNBTS-10787/LNCEL-23/LNRELN-0' | grep -av grep
    Should Not Contain    ${ret}    Export operation: Delete : LNBTS-10787/LNCEL-23/LNRELN-0

Check LNADJN_LNADJNL DEL For BTS${i}
    Log To Console    Check LNADJN_LNADJNL DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'LNBTS-10787/LNADJN-0 : EModifier_Online:Delete' | grep -av grep
    Should Contain    ${ret}    LNBTS-10787/LNADJN-0 : EModifier_Online:Delete

Check LNRELN_1 of Cell22 DEL For BTS${i}
    Log To Console    Check LNRELN_1 of Cell22 DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-1' | grep -av grep
    Should Contain    ${ret}    Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-1

Check LNADJN_1 LNADJNL_1 DEL For BTS${i}
    Log To Console    Check LNADJN_1 LNADJNL_1 DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'LNBTS-10787/LNADJN-1 : EModifier_Online:Delete' | grep -av grep
    Should Contain    ${ret}    LNBTS-10787/LNADJN-1 : EModifier_Online:Delete

Check LNRELN relation verified For BTS${i}
    Log To Console    Check LNRELN relation verified
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a '12 4 InRelation Verified' | grep -av grep
    Should Contain    ${ret}    12 4 InRelation Verified

Check LNRELN relation to_be_verified For BTS${i}
    Log To Console    Check LNRELN relation to_be_verified
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a '12 5 InRelation ToBeVerified' | grep -av grep
    Should Contain    ${ret}    12 5 InRelation ToBeVerified

Check LNRELN relation verified_2 For BTS${i}
    Log To Console    Check LNRELN relation verified_2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'current profile status: Verified' | grep -av grep
    Should Contain    ${ret}    current profile status: Verified

Reload SCF For Current BTS
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}
    Log      ${TestLine_Name_without_localtion}
    ${scf_file_path}    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}    ${scf_for_reload}.xml
    Log      ${scf_file_path}
    ${is_exist}    Run Keyword And Return Status    File Should Exist    path=${scf_file_path}
    Should Be True      ${is_exist}
    Commission Golden SCF For One GNB      timeout=${600}    bts_index=${0}    scf_file_path=${scf_file_path}
    Wait All GNB Status    expect_status=OnAir

Check LNRELGNBCELL ADD For BTS${i}
    Log To Console    Check LNRELGNBCELL ADD
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-10787/LNCEL-22/LNRELGNBCELL-255' | grep -av grep
    Should Contain    ${ret}    operation: Create : LNBTS-10787/LNCEL-22/LNRELGNBCELL-255

Check alarm 5513 raised For BTS${i}
    Log To Console    Check alarm 5513 raised
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'active 5513' | grep -av grep
    Should Contain    ${ret}    active 5513

Trigger report B2 for AZHM_ANT5678
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 NR AZHM_ANT5678
    Increase BTS10787 LTE AHEGB_ANT13
    AT.UE Detach
    Block BTS10787 NR AZHM_ANT5678
    Sleep    5s

Unblock BTS10787 NR AZHM_ANT1234
    Log To Console    Unblock BTS10787 NR AZHM_ANT1234
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}

Block BTS10787 NR AZHM_ANT1234
    Log To Console    Block BTS10787 NR AZHM_ANT1234
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_120db}

Trigger report B2 for AZHM_ANT1234
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 NR AZHM_ANT1234
    Increase BTS10787 LTE AHEGB_ANT13 decrease AZHM_1234
    AT.UE Detach
    Block BTS10787 NR AZHM_ANT1234
    Sleep    5s

Online change parameters actUeBasedAnrNrHo to true
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${Feature_CB005825_actUeBasedAnrNrHo}
    ...                              operation=update
    ...                              value=true
    @{parameter_list}    Create List    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${parameter_list}
    ...                                    operation=update
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Online change parameters actAutoNrHoNeighRemoval to true
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${Feature_CB005825_parameter1}
    ...                              operation=update
    ...                              value=true
    @{parameter_list}    Create List    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_name1}    parameter=${parameter_list}
    ...                                    operation=update
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Online change parameters anrNrHoNbrRelRemGuardTime to 2
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${Feature_CB005825_parameter2}
    ...                              operation=update
    ...                              value=2
    @{parameter_list}    Create List    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_name2}    parameter=${parameter_list}
    ...                                    operation=update
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Online change parameters nrPciHoNbrRelAddThresh to 20
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${Feature_CB005825_parameter3}
    ...                              operation=update
    ...                              value=20
    @{parameter_list}    Create List    ${dict}
    coam.perform_object_recommissioning    dist_name=${dist_name3}    parameter=${parameter_list}
    ...                                    operation=update
    ...                                    skip_parameter_relation_errors=${true}
    ...                                    should_activate=${true}
    ...                                    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Check LNRELN_255 of Cell22 DEL For BTS${i}
    Log To Console    Check LNRELN_0 of Cell22 DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-255' | grep -av grep
    Should Contain    ${ret}    Export operation: Delete : LNBTS-10787/LNCEL-22/LNRELN-255

Check LNADJN_511 DEL For BTS${i}
    Log To Console    Check LNADJN_LNADJNL DEL
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'LNBTS-10787/LNADJN-511 : EModifier_Online:Delete' | grep -av grep
    Should Contain    ${ret}    LNBTS-10787/LNADJN-511 : EModifier_Online:Delete