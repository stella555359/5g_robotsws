*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB007163
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
...                     RAN_5G
# ...                     CDRT
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
...                     SBTS22R4
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_NormalValue}        ${1}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_A2Value}            ${20}
${PA_Intra_A3Value}      ${15}
${PA_30db}               ${30}
&{fault_7300}              faultId=${7300}
@{Ohter_Allow_Alarms}      &{fault_7300}

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB007163_03_MR-DC capabilities shall be considered when steering UE to preferred layer when CB006607 is enabled
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007163
    Start Multi Bts Log
    Unblock ENB AHEBG CELL
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    Attach UE By AT
    sleep    10s
    Check no 7163 HO For BTS0
    Unblock ENB Cell4
    sleep    15s
    Check 7163 A5 For BTS0
    Check 7163 new HO For BTS0
    Sleep    17 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Legacy PM Counter of Case03 in BTS0     starttime=${start_time}    endtime=${end_time}

CB007163_07_eA5 measurement activation and deactivation interaction with SgNB addition and release
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007163_case07
    Start Multi Bts Log
    Unblock ENB Cell3
    Unblock gNB Cell1
    Attach UE By AT
    sleep    30s
    Check EN-DC State
    sleep    30s
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0
    Modify gNB cell1
    sleep    10s
    Check gNB release For BTS0
    Restart Bts log
    sleep    60s
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0

CB007163_09_EN-DC Handover to preferred layer after incoming handover from intra-eNB cell with EN-DC without CB006607 enabled
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007163_case09
    Start Multi Bts Log
    Unblock ENB Cell2
    Unblock gNB Cell1
    Attach UE By AT
    Sleep    10s
    Check EN-DC State
    Unblock ENB Cell0
    Unblock ENB Cell3
    Modify ENB Cell2
    Sleep    10s
    Check Intra ENB HO
    Check gNB not release For BTS0
    Check 7163 HO For BTS0

CB007163_12_EN-DC Handover to preferred layer after incoming handover from inter-eNB cell with EN-DC without MR-DC capability retrieval needed
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007163_case12
    Start Multi Bts Log
    Unblock ENB Cell3
    Unblock gNB Cell1
    Attach UE By AT
    sleep    30s
    Check MR-DC capability retrieval For BTS0
    Check EN-DC State
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0
    Unblock ENB Cell31
    Modify ENB Cell3
    Sleep    30s
    Check inter eNB HO
    sleep    30s
    Unblock ENB Cell4
    Unblock ENB Cell0
    sleep   20s
    Check 7163 new HO For BTS0
    Stop All Bts Log
    Check MR-DC capability not retrieval For BTS2
    Check eA5 active For BTS2
    Check eA5 deactive For BTS2
    # Check SgNBAddition for inter eNB HO For BTS2

CB007163_13_EN-DC Handover to preferred layer interaction with inter-SgNB handover for EN-DC
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007163_case13
    Start Multi Bts Log
    Unblock ENB Cell3
    Unblock gNB2 Cell28
    Attach UE By AT
    sleep    30s
    Check MR-DC capability retrieval For BTS0
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0

    Unblock gNB Cell1
    Modify gNB2 Cell28
    sleep    20s
    Check inter Fre inter gNB handover

    Restart Bts log
    Sleep    30s
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0

    Unblock gNB2 Cell29
    Modify gNB cell1
    sleep    20s
    Check inter Fre inter gNB handover

    Restart Bts log
    Sleep    30s
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0

    Unblock gNB2 Cell28
    Modify gNB2 Cell29
    sleep    20s
    Check intra Fre intra gNB Handover

    Restart Bts log
    Sleep    30s
    Check eA5 active For BTS0
    Check eA5 deactive For BTS0

    Unblock ENB Cell4
    Sleep    20s
    Check 7163 HO For BTS0

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
    Run Keyword And Ignore Error    Disconnect All VM

Unblock ENB Cell0
    Log To Console    Unblock ENB Cell0
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_NormalValue}

Unblock ENB AHEBG CELL
    Log To Console    Unblock ENB AHEBG CELL
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}

Unblock ENB Cell2
    Log To Console    Unblock ENB Cell2
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}

Modify ENB Cell2
    Log To Console    Modify ENB Cell2
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_Intra_A3Value}

Unblock ENB Cell3
    Log To Console    Unblock ENB Cell3
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_NormalValue}

Modify ENB Cell3
    Log To Console    Modify ENB Cell3
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_30db}

Unblock ENB Cell4
    Log To Console    Unblock ENB Cell4
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_NormalValue}

Unblock ENB Cell31
    Log To Console    Unblock ENB Cell31
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}

Modify ENB Cell31
    Log To Console    Modify ENB Cell31
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_Intra_A3Value}

Unblock gNB Cell1
    Log To Console    Unblock gNB Cell1
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

Modify gNB cell1
    Log To Console    Modify gNB cell1
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_A2Value}

Unblock gNB2 Cell28
    Log To Console    Unblock gNB2 Cell28
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_NormalValue}

Modify gNB2 Cell28
    Log To Console    Modify gNB2 Cell28
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_A2Value}

Unblock gNB2 Cell29
    Log To Console    Unblock gNB2 Cell29
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${3}    value=${PA_NormalValue}

Modify gNB2 Cell29
    Log To Console    Modify gNB2 Cell29
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${3}    value=${PA_A2Value}

Check gNB release For BTS${i}
    Log To Console    ${i}
    Log To Console    Check gNB release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Received sgnb release" | grep -av grep
    Should Contain    ${ret}    Received sgnb release

Check gNB not release For BTS${i}
    Log To Console    Check gNB not release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Received sgnb release" | grep -av grep
    Should Not Contain    ${ret}    Received sgnb release

Check no 7163 HO For BTS${i}
    Log To Console    Check no 7163 HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a ResourceOptimisationHandover | grep -av grep
    Should Not Contain    ${ret}    ResourceOptimisationHandover

Check 7163 HO For BTS${i}
    Log To Console    Check 7163 HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a ResourceOptimisationHandover | grep -av grep
    Should Contain    ${ret}    ResourceOptimisationHandover

Stop All Bts Log
    Stop All BTSLog And Download to Local

Restart Bts log
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart.log

# Start BTSLite For Btslog On VM
#     [Arguments]    ${vm_index}=0    ${btslog_path}=${TEST_LOG_DIRECTORY}    ${btslog_name}=syslog.log
#     Run Keyword And Ignore Error    Stop BTSLite For Btslog On VM${vm_index}
#     ${btslog_process}   Create List    btslog    BTSLite
#     Kill Process    ${btslog_process}    connection=BTS${vm_index}_VM
#     Log to Console    clear btslog enviroment done.
#     csn.send_command    command=nohup ${BTSLITE_INFO.local_path} -dir ${btslog_path} -name ${btslog_name} &>/dev/null &
#     ...    connection=BTS${vm_index}_VM
#     Set Suite Variable    ${BTS${vm_index}_LOG_PATH}    ${btslog_path}${/}${btslog_name}

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check eA5 active For BTS${i}
    Log To Console    Check eA5 active
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Activating A5 measurements" | grep -av grep
    Should Contain    ${ret}    Activating A5 measurements

Check eA5 deactive For BTS${i}
    Log To Console    Check eA5 deactive
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "A5 measurement deactivated" | grep -av grep
    Should Contain    ${ret}    A5 measurement deactivated

Check MR-DC capability retrieval For BTS${i}
    Log To Console    Check MR-DC capability retrieval
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a UecTriggerRadioCapabilityTransferProcedure | grep -av grep
    Should Contain    ${ret}    UecTriggerRadioCapabilityTransferProcedure

Check MR-DC capability not retrieval For BTS${i}
    Log To Console    Check MR-DC capability not retrieval
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a UecTriggerRadioCapabilityTransferProcedure | grep -av grep
    Should Not Contain    ${ret}    UecTriggerRadioCapabilityTransferProcedure

Check Intra ENB HO
    Log To Console    Check Intra ENB HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "RRC connection reconfiguration for Handover procedure confirmed" | grep -av grep
    Should Contain    ${ret}    RRC connection reconfiguration for Handover procedure confirmed

Check inter eNB HO
    Log To Console    Check inter eNB HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_HANDOVER_REQUEST_ACKNOWLEDGE | grep -av grep
    Should Contain    ${ret}    X2AP_HANDOVER_REQUEST_ACKNOWLEDGE

Check SgNBAddition for inter eNB HO For BTS${i}
    Log To Console    Check SgNBAddition for inter eNB HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Finish UEC_CONNECTIVITY_SGNB@WaitForSgnbAdditionAckInSplitSustain" | grep -av grep
    Should Contain    ${ret}    Finish UEC_CONNECTIVITY_SGNB@WaitForSgnbAdditionAckInSplitSustain

Check inter Fre inter gNB handover
    Log To Console    Check inter Fre inter gNB handover
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "sgnb change completion phase finished successfully" | grep -av grep
    Should Contain    ${ret}    sgnb change completion phase finished successfully

Check intra Fre intra gNB Handover
    Log To Console    Check intra Fre intra gNB Handover
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "selectedMrdcBandCombinationInSgnbModRequired: 1" | grep -av grep
    Should Contain    ${ret}    selectedMrdcBandCombinationInSgnbModRequired: 1

Check 7163 A5 For BTS${i}
    Log To Console    Check 7163 HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Endc steered handover trigger start by A5 event" | grep -av grep
    Should Contain    ${ret}    Endc steered handover trigger start by A5 event

Check 7163 new HO For BTS${i}
    Log To Console    Check 7163 HO
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Handover finished with success" | grep -av grep
    Should Contain    ${ret}    Handover finished with success

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}

Check Legacy PM Counter of Case03 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M8021C29    M8021C34
    COAM_Admin.Login    bts_host=10.108.231.19
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=LNCEL-4
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M8021C29]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M8021C34]
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
