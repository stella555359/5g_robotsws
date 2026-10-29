*** Settings ***
Documentation    this suite is used for CB010680 5G Precise Positioning SiSo for Shikra pRRH and mRRH
                ...    1. 5G SA TDD Cells with Maximum 100MHz Bandwidth
                ...    2. RF 6.2 Made2 B0 based non-BF RRHs with eCPRI 7.2a fronthaul
                ...    3. periodical UL-SRS reporting with NDM SRS configuration
                ...    author: cheng xianbiao
                ...    contact: xianbiao.cheng@nokia-sbell.com
                ...    squad group: HAZ3_4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_A_Common_KW.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_B_Common_KW.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_UE.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_BIP.robot
Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_SRS_BIP.py

#Suite Setup    Common Suit Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${LOOP_TIMES}    ${2}

*** Test Cases ***
[1]CB010680_D_RRM_001_coexistence_with_VONR_call_and_PRB_Blanking
    [Documentation]    This user scenario is to verify CB010680 can
    ...    work together with CB009915 UL and DL PRB Blanking at Carrier Edges in FR1 TDD feature.
    ...    Tps 1830 will cause fault 16 in startup phase, so add it to allowed alarm list
    [Tags]    CB010680_D    T749
    [Timeout]    120 minutes
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,1900,16,6829,4298,4799
    [Teardown]    CB010680_D Common Teardown
    ${fault_id_list}    Create List    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    Commission With 6 NRCELLS and 12 NRPOSCELL
    Step1 online enable actPRBBlanking    cell_id=${0}
    ${ue_list}    Create List    ${0}    ${2}
    ${gnb_index}    set variable    ${0}
    ${srs_config_dict}    Create Dictionary    ${1}=${7}      ${5}=${59}
    ${pci_dict}           Create Dictionary    ${1}=${301}    ${5}=${305}
    ${srs_cell_num_dic}    Create Dictionary    ${1}=${2}      ${5}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${nrcellId_list}    Create List    616038401    616038405
    ${NRCELL_used_list}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-3
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-4
    ${NRCELl_List}    Get All NRCELL DN From BTS    gnb_index=${gnb_index}
    Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}    allowed_list=${allowed_alarm_list}
    All UE L3 Call And Check BIP SRS   gnb_index=${gnb_index}    ue_list=${ue_list}    nrcellId_list=${nrcellId_list}
    ...    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}    if_bip_check=${True}    vonr_call_flg=after_traffic
    ...    srs_cell_num_dic=${srs_cell_num_dic}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    Step3 online disable actPRBBlanking    cell_id=${0}
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}

[1]CB007880-E-003_Precise_Position_normalcell_RU_Access_RU_SRS_with_share_TRP_iwk_with_PRBBlanking
    [Documentation]    This user scenario is to verify CB010680 can
    ...    work together with CB009915 UL and DL PRB Blanking at Carrier Edges in FR1 TDD feature.
    ...    Tps 1830 will cause fault 16 in startup phase, so add it to allowed alarm list
    [Tags]    CB010680_D    T749
    [Timeout]    150 minutes
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,1900,16,6829,4298
    [Teardown]    CB010680_D Common Teardown
    ${fault_id_list}    Create List    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    Commission With 6 NRCELLS and 12 NRPOSCELL
    Step1 online enable actPRBBlanking    cell_id=${0}
    Step1 online enable actPRBBlanking    cell_id=${1}
    modify the parameter case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}   connection=GNB_OAM    input_list=${shareTrp_enable_PARAM}
    ${ue_list}    Create List    ${0}    ${2}
    ${gnb_index}    set variable    ${0}
    ${srs_config_dict}    Create Dictionary    ${1}=${7}      ${5}=${59}
    ${pci_dict}           Create Dictionary    ${1}=301_or_300    ${5}=${305}
    ${srs_cell_num_dic}    Create Dictionary    ${1}=${5}      ${5}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${nrcellId_list}    Create List    616038401    616038405
    ${NRCELL_used_list}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-0
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-3
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-4
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-2
    ${NRCELl_List}    Get All NRCELL DN From BTS    gnb_index=${gnb_index}
    Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}    allowed_list=${allowed_alarm_list}
    All UE L3 Call And Check BIP SRS   gnb_index=${gnb_index}    ue_list=${ue_list}    nrcellId_list=${nrcellId_list}
    ...    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}    if_bip_check=${True}    vonr_call_flg=after_traffic
    ...    srs_cell_num_dic=${srs_cell_num_dic}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}

[1]CB010680_D_003_NormalCell_half_ABIP_6_RU-ACCESS_and_half_12_RU_SRS_Reconfiguation
    [Tags]    CB010680_D    T749
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298
    [Teardown]    CB010680_D Common Teardown
    [Documentation]    Default configuraiton is one full ABIP with 6 RU-ACCESS and 12 RU-SRS, so
    ...    add some siso operation to cover more robustness test
    ...    tps 1830 will cause fault 16 in startup phase, so add it to allowed alarm list
    ${fault_id_list}    Create List    ${6825}    ${1920}    ${16}    ${50}    ${6832}    ${4681}    ${4003}    ${6829}
    ...    ${4298}    ${4799}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    Step2 Lock All RUs from Webem
    Step3 Unlock All Locked RUs From Webem
    Step4 Lock BB From Webem
    Step5 Unlock BB From Webem
    Step6 repeat multi times for site block
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}

[1]CB007880_H_RRM_1_SRS_Position_Measment_Different_drxLongCycle_ueOndurationTimer_with_default_srsReportPeriodically
    [Tags]    CB007880_H    T749
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298
    [Teardown]    CB010680_D Common Teardown
    [Documentation]    This test case is to verify UE can do position measurement with different drxLongCycle and ueOndurationTimer
    ...    tps 1830 will cause fault 16 in startup phase, so add it to allowed alarm list
    ${fault_id_list}    Create List    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    Commission With 6 NRCELLS and 12 NRPOSCELL
    ${ue_list}    Create List    ${0}    ${2}
    ${gnb_index}    set variable    ${0}
    ${srs_config_dict}    Create Dictionary    ${1}=${7}      ${5}=${59}
    ${pci_dict}           Create Dictionary    ${1}=${301}    ${5}=${305}
    ${srs_cell_num_dic}    Create Dictionary    ${1}=${2}      ${5}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${nrcellId_list}    Create List    616038401    616038405
    ${NRCELL_used_list}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-3
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-4
    ${NRCELl_List}    Get All NRCELL DN From BTS    gnb_index=${gnb_index}
    FOR    ${DRX_SRS_CONFIG}    IN    @{DRX_SRS_CONFIG_LIST}
        Log To Console    Current DRX and SRS Configuration: ${DRX_SRS_CONFIG}
        @{tmp_str_lst}    Split String    string=${DRX_SRS_CONFIG}    separator=_
        ${drxLongCycle}    Set Variable    ${tmp_str_lst[0]}
        ${drxInactivityTimer}    Set Variable    ${tmp_str_lst[1]}
        ${drxOnDurationTimer}    Set Variable    ${tmp_str_lst[2]}
        ${drxPriority}    Set Variable    ${tmp_str_lst[3]}
        ${srsUePeriodicity}    Set Variable    ${tmp_str_lst[4]}
        ${nrdrx_id}    Set Variable    ${32}
        ${Create_DRX_MO_Flag}    Check IF NRDRX For Specfic ID Existed    bts_host=${gNB_ip}    username=${gNB_Username}
        ...    password=${gNB_Password}    id=${nrdrx_id}    connection=NRDRX
        ${param_list}    updateSrsDrxParamList    btsDist=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
        ...    drxLongCycle=${drxLongCycle}    drxInactivityTimer=${drxInactivityTimer}
        ...    drxOnDurationTimer=${drxOnDurationTimer}    drxPriority=${drxPriority}    srsUePeriodicity=${srsUePeriodicity}
        ...    create_drx_mo=${Create_DRX_MO_Flag}    posNrDrxDN=NRDRX-${nrdrx_id}
        Modify The Parameter Case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
        ...    password=${gNB_password}   connection=GNB_OAM    input_list=${param_list}
        Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}    allowed_list=${allowed_alarm_list}
        Run Keyword And Continue On Failure    All UE L3 Call And Check BIP SRS   gnb_index=${gnb_index}
        ...    ue_list=${ue_list}    nrcellId_list=${nrcellId_list}
        ...    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}    if_bip_check=${True}    vonr_call_flg=none
        ...    srs_cell_num_dic=${srs_cell_num_dic}  if_traffic=${False}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}


[1]CB007880_H_RRM_3_SRS_Position_Measment_Interworking_VONR
   [Documentation]    This user scenario is to verify vonr drx profile interworing with position drx profile
    [Timeout]    120 minutes
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,1900,16,6829,4298,4799
    [Teardown]    CB010680_D Common Teardown
    ${fault_id_list}    Create List    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}    ${4799}
    Commission With 6 NRCELLS and 12 NRPOSCELL
    ${ue_list}    Create List    ${0}    ${2}
    ${gnb_index}    set variable    ${0}
    ${srs_config_dict}    Create Dictionary    ${1}=${7}      ${5}=${59}
    ${pci_dict}           Create Dictionary    ${1}=${301}    ${5}=${305}
    ${srs_cell_num_dic}    Create Dictionary    ${1}=${2}      ${5}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${nrcellId_list}    Create List    616038401    616038405
    ${NRCELL_used_list}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-3
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRPOSCELL-4
    ${NRCELl_List}    Get All NRCELL DN From BTS    gnb_index=${gnb_index}
    FOR    ${DRX_SRS_CONFIG}    IN    @{DRX_SRS_CONFIG_LIST_VONR}
        Log To Console    Current DRX and SRS Configuration: ${DRX_SRS_CONFIG}
        @{tmp_str_lst}    Split String    string=${DRX_SRS_CONFIG}    separator=_
        ${drxLongCycle}    Set Variable    ${tmp_str_lst[0]}
        ${drxInactivityTimer}    Set Variable    ${tmp_str_lst[1]}
        ${drxOnDurationTimer}    Set Variable    ${tmp_str_lst[2]}
        ${drxPriority}    Set Variable    ${tmp_str_lst[3]}
        ${srsUePeriodicity}    Set Variable    ${tmp_str_lst[4]}
        ${nrdrx_id}    Set Variable    ${32}
        ${Create_DRX_MO_Flag}    Check IF NRDRX For Specfic ID Existed    bts_host=${gNB_ip}    username=${gNB_Username}
        ...    password=${gNB_Password}    id=${nrdrx_id}    connection=NRDRX
        ${param_list}    updateSrsDrxParamList    btsDist=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
        ...    drxLongCycle=${drxLongCycle}    drxInactivityTimer=${drxInactivityTimer}
        ...    drxOnDurationTimer=${drxOnDurationTimer}    drxPriority=${drxPriority}    srsUePeriodicity=${srsUePeriodicity}
        ...    create_drx_mo=${Create_DRX_MO_Flag}    posNrDrxDN=NRDRX-${nrdrx_id}
        Modify The Parameter Case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
        ...    password=${gNB_password}   connection=GNB_OAM    input_list=${param_list}
        Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}    allowed_list=${allowed_alarm_list}
        Run Keyword And Continue On Failure    All UE L3 Call And Check BIP SRS   gnb_index=${gnb_index}
        ...    ue_list=${ue_list}    nrcellId_list=${nrcellId_list}
        ...    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}    if_bip_check=${True}    vonr_call_flg=before_traffic
        ...    srs_cell_num_dic=${srs_cell_num_dic}  if_traffic=${False}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    allowed_list=${allowed_alarm_list}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}

*** Keywords ***
Step3 online disable actPRBBlanking
    [Arguments]    ${cell_id}=${0}
    Log To Console    Step1 online disable actPRBBlanking
    Online Disable actPRBBlanking For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${cell_id}    connection=GNB_OAM
    Check GNB on air    bts_host=${gNB_ip}    time=6 min

Step1 online enable actPRBBlanking
    [Arguments]    ${cell_id}=${0}
    Log To Console    Step3 online enable actPRBBlanking
    Online Enable actPRBBlanking For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${cell_id}    connection=GNB_OAM
    Check GNB on air    bts_host=${gNB_ip}    time=6 min

Step2 VNOR call
    Make a VoNR call(+6688)

Step2 Lock All RUs from Webem
    log to console    Step2 Lock All RUs From Webem
    @{all_ru_list}    Get All RU Index Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    @{all_ru_list}
    Lock Or Unlock RU And Check Status    lock_RU_id_list=@{all_ru_list}    lock_flag=${True}
    ...    bts_host=${gNB_ip}    allowed_list=@{allowed_alarm_list}

Step3 Unlock All Locked RUs From Webem
    log to console    Step3 Unlock All Locked RUs From Webem
    Lock or Unlock RU And Check Status     lock_flag=${False}    unlock_RU_id_list=@{all_ru_list}
    ...    bts_host=${gNB_ip}    allowed_list=@{allowed_alarm_list}

Step4 Lock BB From Webem
    log to console    Step4 Lock BB From Webem
    ${bbmod_index_list}  Get All BBMOD Index Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    ${bbmod_index_list}
    Run Keyword If    len(${bbmod_index_list})>0    Lock Or Unlock BB And Check Status    lock_BB_id_list=@{bbmod_index_list}
    ...    bts_host=${gNB_ip}    lock_flag=${True}    allowed_list=@{allowed_alarm_list}
    ...    ELSE    log to console    no bbmod to lock,check if ASOG/H/E used

Step5 Unlock BB From Webem
    Log To Console    Step5 Unlock BB From Webem
    Run Keyword If    len(${bbmod_index_list})>0    Lock Or Unlock BB And Check Status    unlock_BB_id_list=@{bbmod_index_list}
    ...    bts_host=${gNB_ip}    lock_flag=${False}    allowed_list=@{allowed_alarm_list}
    ...    ELSE    log to console    no bbmod to unlock,check if ASOG/H/E used

Step6 repeat multi times for site block
    log to console    Step6 repeat ${LOOP_TIMES} times for site block
    FOR    ${iteration}    IN RANGE    ${LOOP_TIMES}
        Log To Console    Current Iteration: ${iteration}
        Step12 And Step13 trigger site block from webem and check alarm in webem
        Step14 And Step15 Triger Site Unblock On Webem And Check Bts State After Site Unblock
    END

Step12 And Step13 trigger site block from webem and check alarm in webem
    log to console    Step12 trigger site block from webem
    Block Site Via Admin CLI And Check Alarm    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}

Step14 And Step15 triger site unblock on webem and check bts state after site unblock
    log to console    Step14 triger site unblock on webem
    Unblock Site Via Admin CLI And Check Alarm    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=15 min
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${gNB_ip}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${gNB_ip}
    Should Be True    '${result}'=='${True}'

Commission With 6 NRCELLS and 12 NRPOSCELL
    Log To Console    Commission With 6 NRCELLS and 12 NRPOSCELL
    Setup Commission SCF    scf_name=_D    timeout=600
    Check GNB on air    bts_host=${gNB_ip}    interval=60