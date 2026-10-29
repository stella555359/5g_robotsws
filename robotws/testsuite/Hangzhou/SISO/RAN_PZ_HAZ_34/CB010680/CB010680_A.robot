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
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_Params.py

Suite Setup    Common Suit Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${LOOP_TIMES}    ${1}
#trp selection low precision position
#@{degreesOfLatitude_lst}    2848990    2848940    2848999    2848935    2848945    2848980
#@{degreesOfLongitude_lst}    4850193    4850193    4850193    4850193    4850193    4850193
#trp selection high precision position
@{degreesOfLatitude_lst}    2850210    2850629    2851049    2851469    2851889    2852309    2852729    2853148
@{degreesOfLongitude_lst}    4850609    4850747    4850886    4851024    4851163    4851301   4851440    4851578

*** Test Cases ***
[1][1.0]CB010680_G_RRM_003_different_structure_Prach_index_Ru_Access
    [Tags]    CB010680_G    CIT    T714
    [Setup]    robot_common_operations.Common case Setup
    modify the parameter case CB010680    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}   connection=GNB_OAM    input_list=${tddFrameStructure_all_1}
    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=20min
    Run Keyword And Ignore Error    Kill vysor process    ue_index=${ue_index}
    UE Attach and check log    ue_inex=${0}    pci=none    subcell_num=${0}    srs_cell_num=${0}
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

[1]CB010680_A_013_site_block_for_Precise_Positioning_ABIP_SupperCell_with_RU_ACCESS_only
     [Documentation]    basic robustness testing with different siso operation,
     ...    compare with qc origin step, some step will be removed as follow:
     ...    Step1 check bts state before rat reset ---> covered by Common Case Setup
     ...    Step2 hot insert one new ABIP or ABIO with BBMOD commission -> not possible for automaiton
    [Tags]    CB010680_A    T714    CIT
    [Setup]    Common Case Setup
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    Step3 lock 5/6 rus from webem
    Step5 reset last one unlocked ru from webem
    Step6 Unlock 5/6 Locked Ru From Webem
    Step8 reset all ru from webem
    Step12 And Step13 trigger site block from webem and check alarm in webem
    Step14 And Step15 Triger Site Unblock On Webem And Check Bts State After Site Unblock
    Step10 lock bb from webem
    Step11 unlock bb from webem
    Step18 repeat step1~17 multi times for site block

[1]CB010680_A_012_RAT_reset_for_Precise_Positioning_ABIP_SupperCell_with_RU_ACCESS_only
    [Documentation]    basic robustness testing with different siso operation,
    ...    compare with qc origin step, some step will be removed or merged as follow:
    ...    Step1 check bts state before rat reset ---> covered by Common Case Setup
    ...    Step2 hot insert one new ABIP or ABIO without commission -> not possible for automation
    ...    Step3 and Step4 merged into -> Step3 and Step4 block and unblock all cell from webem
    ...    Step7 and Step8 merged into -> Step7 and Step8 nr rat soft reset on webem with grace cell shutdown
    ...    Step14 check NRPOSINFO configuration -> not needed in automation since no pr in new feature
    ...    Step18 check operation history -> not needed in automation since no pr in new feature
    ...    Step19 Collect snapshot to local from webem -> not needed in automation since no pr in new feature
    [Tags]    CB010680_A    T714    CIT
    [Setup]    Common Case Setup
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    Step3 and Step4 block and unblock all cell from webem
    Step6 block all cell from webem
    Step7 and Step8 nr rat soft reset on webem with grace cell shutdown
    Step10 lock cell from webem cm parameter
    Step11 nr rat hard reset on webem without grace cell shutdown
    Step12 unlock cell from webem cm parameter
    Step15 reset cell from webem
    Step17 repeat step1~16 multi times for rat reset

[1]CB010680_B_RRM_001_ABIP_Interworking_with_PRB_Blanking
    [Documentation]    This user scenario is to verify CB010680 can
    ...    work together with CB009915 UL and DL PRB Blanking at Carrier Edges in FR1 TDD feature.
    ...    remove prb blanking in CIT since no pr found in new feature and focus on SRS reconfig,
    ...    CRT CB010680_D_RRM_001_coexistence_with_VONR_call_and_PRB_Blanking cover prb blanking
    [Tags]    CB010680_B    T714    CIT
    [Setup]    Common Case Setup
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    FOR    ${iteration}    IN RANGE    ${LOOP_TIMES}
        Log To Console    Current Iteration: ${iteration}
        Step4 online change SRS only    cell_id=${1}
        Step1 online enable actPRBBlanking    cell_id=${1}
        ${NRCELl_List}    Get All NRCELL From BTS
        Set Test Variable    ${NRCELl_List}
        ${NRCELL_used_list}    Create List    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
        ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
        ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-6
        Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}
        Run Keyword And Ignore Error    Kill vysor process    ue_index=${ue_index}
        Stepx start ue call and bip log checking for toe    ue_inex=0    cell_id=${1}
        ...    pci=none    subcell_num=${0}    srs_cell_num=${0}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}
    END

[1]CB010680_A_011_AOSG_Online_change_supercell_from_3+3_to_2+2+2_for_Precise_Positioning_with_RU_ACCESS_only
   [Documentation]    Online change supper cell from 1 supper cell with 6 sub cells to 3 superCell with 2+2+2
   ...    compare with qc origin step, more supper cell reconfig added here
   [Tags]    CB010680_A    T714    CIT
   [Setup]    Common Case Setup
   [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
   Step0 Reconfigure 1 Normal Cell To 1 SupperCell with 6 Subcells
   Run Keyword And Ignore Error    Stepx start ue call and bip log checking for toe    ue_inex=0    cell_id=${1}
   ...    pci=none    subcell_num=${6}    srs_cell_num=${0}


[1]CB010680_F_007_mix_BF_nBF_Full_ABIQ_RU_Access_RU_SRS_in_same_cellset
    [Tags]    CB010680_A    T714    CRT    CDRT
    [Setup]    Common Case Setup
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    [Documentation]    default configuraiton ABIP_1 with 6 NRCELLs+12NRPOSCELL, ABIP-3 with BF and none-BF mixed
    ...    this case have been covered by CB010680_D_003_NormalCell_half_ABIP_6_RU-ACCESS_and_half_12_RU_SRS_Reconfiguation
    ...    optimization CIT to cover most important function and make sure execution time for branch+trunk
    ...    move some test step from CIT to CRT
    Setup Commission SCF    scf_name=_F    timeout=600
    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=20min    interval=120
    FOR    ${iteration}    IN RANGE    ${LOOP_TIMES}
        Log To Console    Current Iteration: ${iteration}
        ${NRCELl_List}    Get All NRCELL From BTS
        Set Test Variable    ${NRCELl_List}
        ${NRCELL_used_list}    Create List    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
        ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
        ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-6
        Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}
        Stepx start ue call and bip log checking for toe   ue_inex=0    cell_id=${1}
        ...    pci=none    subcell_num=${0}    srs_cell_num=${0}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}
    END

[1]CB010680_A_011_AOSG_Online_change_supercell_from_3+3_to_2+2+2_to_6
   [Documentation]    Online change supper cell from 1 supper cell with 6 sub cells to 3 superCell with 2+2+2
   ...    compare with qc origin step, more supper cell reconfig added here
   [Tags]    CB010680_A    T714    none-CIT/CRT
   [Setup]    Common Case Setup
   [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    Setup Commission SCF    scf_name=${EMPTY}    timeout=600
    Step0 Reconfigure 1 Normal Cell To 1 SupperCell with 6 Subcells
    Step1 disable feature actHPPosMethodOptList without UL-TDOA
    Step2 enable feature actHPPosMethodOptList with UL-TDOA
    Step3 online change supercell from 6 subcells to 3+3
    Stepx start ue call and bip log checking for toe    ue_inex=0    cell_id=${1}
    ...    pci=none    subcell_num=${3}    srs_cell_num=${0}
    Step5 online change supercell from 3+3 subcells to 2+2+2
    Step9 online change supercell from 2+2+2 subcells to 6 subcells

[1]CB010680_A_014_site_reset_for_with_RU_ACCESS_only
     [Documentation]    basic robustness testing with different siso operation,
     ...    compare with qc origin step, some step will be removed as follow:
     ...    Step1 check bts state before rat reset ---> covered by Common Case Setup
     ...    Step2 hot insert one new ABIP or ABIO with BBMOD commission -> not possible for automaiton
    [Tags]    CB010680_A    T714   none-CIT/CRT
    [Setup]    Common Case Setup
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore
    ${fault_id_list}    Create List    ${6825}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Append To List    ${allowed_alarm_list}    ${6825}
    Step1 repeat site reset for multiple times
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}

[1]CB010680_A_005_Precise_Positioning_SuperCell_with_full_and_half_ASOG_for_RU_ACCESS_only_for_P-SRS_100MHz
    [Documentation]  ASOG normal cell
    ...    Full ASOG support 8*100M NR normal cells
    ...    Half ASOG 4*100M NR normal cells when allowSlowPrbPoolingStatNdmSrs is ture
    ...    Half ASOG 3*100M NR normal cells when allowSlowPrbPoolingStatNdmSrs is false
    [Setup]    robot_common_operations.Common case Setup
    [Tags]    CB010680_A    T714    none-CIT/CRT
    ${fault_id_list}    Create List    ${1868}    ${6825}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Step1 Enable AllowSlowPrbPoolingStatNdmSrs And Check 4 Cells Are Up In Half ASOG
    Step2 Change SmodBoardConfigType To Full ASOG And Check 8 Cells Are Up
    Step3 Disable AllowSlowPrbPoolingStatNdmSrs And Check 3 Cells Are Up In Half ASOG
    Step2 Change SmodBoardConfigType To Full ASOG And Check 8 Cells Are Up
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}
    [Teardown]    CB010680_A Common Teardown With TMO SCF Restore

*** Keywords ***
Step1 Enable allowSlowPrbPoolingStatNdmSrs and check 4 cells are up in half ASOG
    Online Change allowSlowPrbPoolingStatNdmSrs For NRBTS    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    password=${gNB_password}    ndm_srs_flag=${true}
    Online Change smodBoardConfigType To Lock Resource    bts_host=${gNB_ip}    is_full=${False}    1868_num=${4}

Step2 Change smodBoardConfigType to full ASOG and check 8 cells are up
    Online Change smodBoardConfigType To Lock Resource    bts_host=${gNB_ip}    is_full=${True}    1868_num=${0}

Step3 Disable allowSlowPrbPoolingStatNdmSrs and check 3 cells are up in half ASOG
    Online Change allowSlowPrbPoolingStatNdmSrs For NRBTS    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    password=${gNB_password}    ndm_srs_flag=${false}
    Online Change smodBoardConfigType To Lock Resource    bts_host=${gNB_ip}    is_full=${True}    1868_num=${5}

Step3 and Step4 block and unblock all cell from webem
    log to console    Step3 And Step4 Block And Unblock All Cell From Webem
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Append To List    ${allowed_alarm_list}    ${49}
    ${nr_cell_list}    Get NRCELL ID List Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    ${nr_cell_list}
    BLock or UnBlock Cell And Check Status    allowed_list=@{allowed_alarm_list}  block_flag=${True}
    ...    bts_host=${gNB_ip}    block_cell_id_list=${nr_cell_list}
    BLock Or UnBlock Cell And Check Status    allowed_list=@{allowed_alarm_list}  block_flag=${False}
    ...    bts_host=${gNB_ip}    unblock_cell_id_list=${nr_cell_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=49

Step6 block all cell from webem
    Log To Console    Step6 block all cell from webem
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Append To List    ${allowed_alarm_list}    ${49}
    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_alarm_list}  block_flag=${True}
    ...    bts_host=${gNB_ip}    block_cell_id_list=${nr_cell_list}

Step7 and Step8 nr rat soft reset on webem with grace cell shutdown
    Log To Console    Step7 and Step8 nr rat soft reset on webem with grace cell shutdown
    Append To List    ${allowed_alarm_list}    ${49}
    RAT Reset Via Admin CLI And Check Cell Onair    bts_host=${gNB_ip}    rat_type=NR    graceful_cell_shutdown=${True}
    ...    reset_type=Soft   time_out=240    allowed_list=@{allowed_alarm_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=49

Step10 lock cell from webem cm parameter
    log to console    Step10 lock cell from webem cm parameter
    Lock Or Unlock Cell And Check Status    allowed_list=${allowed_alarm_list}  lock_flag=${True}
    ...    bts_host=${gNB_ip}    lock_cell_id_list=${nr_cell_list}

Step11 nr rat hard reset on webem without grace cell shutdown
    log to console    Step11 nr rat hard reset on webem without grace cell shutdown
    RAT Reset Via Admin CLI And Check Cell Disabed    bts_host=${gNB_ip}    rat_type=NR    graceful_cell_shutdown=${False}
    ...    reset_type=Hard   time_out=240    allowed_list=@{allowed_alarm_list}

Step12 unlock cell from webem cm parameter
    log to console    Step12 unlock cell from webem cm parameter
    Lock Or Unlock Cell And Check Status    allowed_list=${allowed_alarm_list}  lock_flag=${False}
    ...    bts_host=${gNB_ip}    unlock_cell_id_list=${nr_cell_list}

Step15 reset cell from webem
    log to console    Step15 reset cell from webem
    Cell Reset Via Admin CLI And Check Cell Onair    allowed_list=${allowed_alarm_list}  cell_id_list=${nr_cell_list}
    ...    BTS_ID=${TL_BTS_ID}    NRBTS_ID=${TL_NRBTS_ID}    bts_host=${gNB_ip}

Step17 repeat step1~16 multi times for rat reset
    log to console    Step17 repeat step1~17 multi times
    FOR    ${iteration}    IN RANGE    0
        Log To Console    Current Iteration: ${iteration}
        Step3 and Step4 block and unblock all cell from webem
        Step6 block all cell from webem
        Step7 and Step8 nr rat soft reset on webem with grace cell shutdown
    END

###CB010680_A_013_site_block_for_Precise_Positioning_ABIP_SupperCell_with_RU_ACCESS_only###
Step3 lock 5/6 rus from webem
    @{all_ru_list}    Get All RU Index Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    @{all_ru_list}
    Lock Or Unlock RU And Check Status    lock_RU_id_list=@{all_ru_list[0:-1]}    lock_flag=${True}
    ...    bts_host=${gNB_ip}    allowed_list=@{allowed_alarm_list}

Step5 reset last one unlocked ru from webem
    log to console    Step5 reset last one unlocked ru from webem
    ${last_ru_index}    Evaluate    len(${all_ru_list})-1
    Set Test Variable    ${last_ru_index}
    ${RMOD_index_list}    Create List    ${last_ru_index}
    SISO_common_operation.RF module reset    bts_host=${gNB_ip}    RMOD_index_list=@{RMOD_index_list}
    ${expect_item_status_dict}    create dictionary
    ${nr_cell_list}    Get NRCELL ID List Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    ${nr_cell_list}
    FOR  ${cell_id}  IN    @{nr_cell_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_disable_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}    bts_host=${gNB_ip}
    Check Alarm List on BTS    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}

Step6 unlock 5/6 locked ru from webem
    log to console    Step6 unlock 5/6 locked ru from webem
    ${Unlock_RU_list}    Get Slice From List    ${all_ru_list}    0   ${last_ru_index}
    Lock or Unlock RU And Check Status     lock_flag=${False}    unlock_RU_id_list=${Unlock_RU_list}
    ...    bts_host=${gNB_ip}    allowed_list=@{allowed_alarm_list}

Step8 reset all ru from webem
    log to console    Step8 reset all ru from webem and collect snapshot
    # the value of rmod_id -1 is rmod_inex
    @{RMOD_index_list}    Create List
    FOR  ${rmod_id}  IN  @{all_ru_list}
        ${rmod_index}    Evaluate    ${rmod_id}-1
        Append To List    ${RMOD_index_list}    ${rmod_index}
    END
    # consider execution time use evaluate random select 2 ru to reset
    ${ru_index_list}    Evaluate    random.sample(${RMOD_index_list},2)
    Reset RF Module And Check On Air    bts_host=${gNB_ip}    RMOD_index_list=${ru_index_list}    allowed_list=@{allowed_alarm_list}

Step10 lock bb from webem
    log to console    Step10 lock bb from webem
    ${bbmod_index_list}  Get All BBMOD Index Via Admin CLI    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Set Test Variable    ${bbmod_index_list}
    Run Keyword If    len(${bbmod_index_list})>0    Lock Or Unlock BB And Check Status    lock_BB_id_list=@{bbmod_index_list}
    ...    bts_host=${gNB_ip}    lock_flag=${True}    allowed_list=@{allowed_alarm_list}
    ...    ELSE    log to console    no bbmod to lock,check if ASOG/H/E used

Step11 unlock bb from webem
    Run Keyword If    len(${bbmod_index_list})>0    Lock Or Unlock BB And Check Status    unlock_BB_id_list=@{bbmod_index_list}
    ...    bts_host=${gNB_ip}    lock_flag=${False}    allowed_list=@{allowed_alarm_list}
    ...    ELSE    log to console    no bbmod to unlock,check if ASOG/H/E used

Step12 And Step13 trigger site block from webem and check alarm in webem
    log to console    Step12 trigger site block from webem
    AlarmWatchdog.add_allow_alarms    fault_id=50
    Block Site Via Admin CLI And Check Alarm    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}

Step14 And Step15 triger site unblock on webem and check bts state after site unblock
    log to console    Step14 triger site unblock on webem
    Append To List    ${allowed_alarm_list}    ${50}    ${6825}
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    Unblock Site Via Admin CLI And Check Alarm    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=6 min
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${gNB_ip}
    Should Be True    '${result}'=='${True}'
    AlarmWatchdog.remove_allow_alarms    fault_id=50
    AlarmWatchdog.remove_allow_alarms    fault_id=6825

Step18 repeat step1~17 multi times for site block
    log to console    Step18 repeat step1~17 ${LOOP_TIMES} times for site block
    FOR    ${iteration}    IN RANGE    0
        Log To Console    Current Iteration: ${iteration}
        Step3 lock 5/6 rus from webem
        Step6 Unlock 5/6 Locked Ru From Webem
        Step12 And Step13 trigger site block from webem and check alarm in webem
        Step14 And Step15 Triger Site Unblock On Webem And Check Bts State After Site Unblock
        Step10 lock bb from webem
        Step11 unlock bb from webem
    END

Step1 repeat site reset for multiple times
    FOR    ${iteration}    IN RANGE    ${LOOP_TIMES}
        Log To Console    Current site reset iteration: ${iteration}
        Reset Station And Check On Air    bts_host=${gNB_IP}    allowed_list=${allowed_alarm_list}
    END


#[1]CB010680_A_011_AOSG_Online_change_supercell_from_3+3_to_2+2+2_for_Precise_Positioning_with_RU_ACCESS_only
Step1 disable feature actHPPosMethodOptList without UL-TDOA
    Log To Console    Step1 disable feature actHPPosMethodOptList without UL-TDOA
    Online Disable ActHPPosMethodOptList For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${1}    connection=GNB_OAM

Step2 enable feature actHPPosMethodOptList with UL-TDOA
    Log To Console    Step3 enable feature actHPPosMethodOptList with UL-TDOA
    Online Enable ActHPPosMethodOptList For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${1}    connection=GNB_OAM

Step3 online change supercell from 6 subcells to 3+3
    Log To Console    Step3 online change supercell from 6 subcells to 3+3
    ${subcell_num_list}    Create List    ${6}
    SupperCell Number And Subcell Number Should Be Expected    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    supper_cell_num=${1}    subcell_num_list=${subcell_num_list}

    ${nrCellId_old}    ${lcrId_old}    ${physCellId_old}    Get lcrID And pci For Specfic Cell    bts_host=${gNB_ip}
    ...    username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    ${copy_from}    Set Variable    CURRENT_BTS_CONF-1
    ${cell_id}    Evaluate    ${nrCellId_old}+1
    ${lcrId}    Evaluate    ${lcrId_old}+1
    ${physCellId}    Evaluate    ${physCellId_old}+1
    ${copy_cell_id}    Set Variable    ${nrCellId_old}
    Selenium_Coam_LogIn_And_Retry    bts_host=${gNB_ip}
    # delete nGRanAccessPointPosition structure under NRCELL
    Log To Console    Delete nGRanAccessPointPosition structure under NRCELL for cell-${copy_cell_id}
    # delete NRPOSINFO structure under NRCELL
    Log To Console    Delete NRPOSINFO structure under NRCELL for cell-${copy_cell_id}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id}/NRPOSINFO-4
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id}/NRPOSINFO-5
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id}/NRPOSINFO-6
    # Copy and add NRCELL
    Log To Console    Copy and add NRCELL for cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELL
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    # Update lcrId for added NRCELL
    Log To Console    Update lcrId=${lcrId} for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID   new_value=${lcrId}    abbr=lcrId
    # Update phyCellId for added NRCELL
    Log To Console    Update phyCellId=${physCellId} for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier   new_value=${physCellId}   abbr=physCellId
    # Add NRCELLGP for added NRCELL
    Log To Console    Add NRCELLGP for added NRCELL cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${copy_cell_id}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    # Update refNrCellGroup for added NRCELL
    Log To Console    Update refNrCellGroup for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
    # Add added nrcell id into refNrCellGroup
    Log To Console    Add added nrcell id into refNrCellGroup for cell-${cell_id}
    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${cell_id}   node_index=${1}  abbr=refNrCellGroup
    # Add CELLMAPPING for added NRCELL
    Log To Console    Add CELLMAPPING for added NRCELL cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId_old}
    ...    include_subobject=${TRUE}    id_value=${lcrId}
    # Remove not used channel group for old cell
    Log To Console    Remove not used channel group for old cell-${copy_cell_id}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId_old}/CHANNELGROUP-4
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId_old}/CHANNELGROUP-5
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId_old}/CHANNELGROUP-6
    # Remove not used channel group for added cell
    Log To Console    Remove not used channel group for added cell-${cell_id}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}/CHANNELGROUP-1
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}/CHANNELGROUP-2
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}/CHANNELGROUP-3
    FOR    ${nrposinfor_id}    IN RANGE    1    4
        ${trp_id}    Evaluate    ${nrposinfor_id}+2
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of latitude  new_value=${degreesOfLatitude_lst[${trp_id}]}      abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of longitude  new_value=${degreesOfLongitude_lst[${trp_id}]}      abbr=degreesOfLongitude
    END
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate NR RTWP measurement    new_value=false   abbr=actRtwpMeasurement
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    # plan validation
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    # check pdl results list len is 0
    Sleep    120s
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    # Length Should Be    ${pdl_results}    0
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Sleep    60s
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    ${subcell_num_list}    Create List    ${3}    ${3}
    SupperCell Number And Subcell Number Should Be Expected    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    supper_cell_num=${2}    subcell_num_list=${subcell_num_list}
    [Teardown]   WEBUI Logout

Step5 online change supercell from 3+3 subcells to 2+2+2
    Log To Console    Step5 online change supercell from 3+3 subcells to 2+2+2
    ${nrCellId_old}    ${lcrId_old}    ${physCellId_old}    Get lcrID And pci For Specfic Cell    bts_host=${gNB_ip}
    ...    username=${gNB_username}    password=${gNB_password}    cell_id=${2}
    ${copy_from}    Set Variable    CURRENT_BTS_CONF-1
    ${cell_id}    Evaluate    ${nrCellId_old}+1
    ${lcrId}    Evaluate    ${lcrId_old}+1
    ${physCellId}    Evaluate    ${physCellId_old}+1
    ${copy_cell_id_1}    Evaluate    ${nrCellId_old}-1
    ${copy_cell_id_2}    Set Variable    ${nrCellId_old}
    Selenium_Coam_LogIn_And_Retry    bts_host=${gNB_ip}
    # delete one NRPOSINFO structure under NRCELL-1 and NRCELL-2
    Log To Console    Delete NRPOSINFO structure under NRCELL-1 and NRCELL-2
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_1}/NRPOSINFO-3
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_2}/NRPOSINFO-3
    # Copy and add NRCELL
    Log To Console    Copy and add NRCELL for cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELL
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_1}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    # Update lcrId for added NRCELL
    Log To Console    Update lcrId=${lcrId} for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID   new_value=${lcrId}    abbr=lcrId
    # Update phyCellId for added NRCELL
    Log To Console    Update phyCellId=${physCellId} for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier   new_value=${physCellId}   abbr=physCellId
    # Add NRCELLGP for added NRCELL
    Log To Console    Add NRCELLGP for added NRCELL cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}   object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${copy_cell_id_1}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    # Update refNrCellGroup for added NRCELL
    Log To Console    Update refNrCellGroup for added NRCELL cell-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${cell_id}
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
    # Add added nrcell id into refNrCellGroup under NRDU
    Log To Console    Add added nrcell id into refNrCellGroup under NRDU for cell-${cell_id}
    selenium_coam.add_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    # refnrCellGrop node_index start from 0, so node_index = lcrId -1
    ${refNrCellGroup_node_index}    Evaluate    ${lcrId}-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=${cell_id}   node_index=${refNrCellGroup_node_index}  abbr=refNrCellGroup
    # Add CELLMAPPING for added NRCELL
    Log To Console    Add CELLMAPPING for added NRCELL cell-${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${TRUE}    id_value=${lcrId}
    # Copy channel group 6 from NRCELL-2 to NRCELL-3
    Log To Console    Copy channel group 6 from NRCELL-2 to NRCELL-3
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId_old}/CHANNELGROUP-6
    ...    include_subobject=${TRUE}    id_value=${6}
    # remove not used channel group 1/2 for NRCELL-3
    Log To Console    Remove not used channel group 1/2 for NRCELL-3
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}/CHANNELGROUP-1
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}/CHANNELGROUP-2
    # Remove not used channel group for old cell 3/6
    Log To Console    Remove not used channel group for old cell-${copy_cell_id_1} and cell-${copy_cell_id_2}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_1}/CHANNELGROUP-3
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_2}/CHANNELGROUP-6
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate NR RTWP measurement    new_value=false   abbr=actRtwpMeasurement
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    # plan validation
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    # check pdl results list len is 0
    Sleep    120s
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
#    Length Should Be    ${pdl_results}    0
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Sleep    60s
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    ${subcell_num_list}    Create List    ${2}    ${2}    ${2}
    SupperCell Number And Subcell Number Should Be Expected    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    supper_cell_num=${3}    subcell_num_list=${subcell_num_list}
    [Teardown]   WEBUI Logout

Step9 online change supercell from 2+2+2 subcells to 6 subcells
    Log To Console    Step9 online change supercell from 2+2+2 subcells to 6 subcells
    Selenium_Coam_LogIn_And_Retry    bts_host=${gNB_ip}
    ${copy_from}    Set Variable    CURRENT_BTS_CONF-1
    ${lcrId}    Set Variable    ${1}
    ${copy_cell_id_1}    Set Variable    ${2}
    ${copy_cell_id_2}    Set Variable    ${3}
    # Copy channel group 3/6/4/5 from NRCELL-3 and NRCELL-2 to NRCELL-1
    Log To Console    Copy channel group 3/6/4/5 from NRCELL-3/2 to NRCELL-1
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_2}/CHANNELGROUP-3
    ...    include_subobject=${TRUE}    id_value=${3}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_1}/CHANNELGROUP-4
    ...    include_subobject=${TRUE}    id_value=${4}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_1}/CHANNELGROUP-5
    ...    include_subobject=${TRUE}    id_value=${5}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_2}/CHANNELGROUP-6
    ...    include_subobject=${TRUE}    id_value=${6}
    # Copy NRPOSINFO-/3/4/5/6 from NRCELL-2 and NRCELL-3 to NRCELL-1
    Log To Console    Add NRPOSINFO-3/4/5/6 for NRCELL-1
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${lcrId}
    ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_1}/NRPOSINFO-1
    ...    include_subobject=${TRUE}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${lcrId}
    ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_1}/NRPOSINFO-2
    ...    include_subobject=${TRUE}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${lcrId}
    ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_2}/NRPOSINFO-1
    ...    include_subobject=${TRUE}
    selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${lcrId}
    ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_2}/NRPOSINFO-2
    ...    include_subobject=${TRUE}
    # remove NRCELL-2 and MRCELL-3
    Log To Console    Remove NRCELL-2 and MRCELL-3
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_1}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${copy_cell_id_2}
    # remove NRCELLGP-2 and NRCELLGP-3
    Log To Console    Remove NRCELLGP-2 and NRCELLGP-3
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${copy_cell_id_1}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${copy_cell_id_2}
    # remove LCELNR-2 and LCELNR-3
    Log To Console    Remove LCELNR-1 and LCELNR-2
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_1}
    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id_2}
    # update refNrCellGroup node index 1/2 under NRDU-1
    Log To Console    Update refNrCellGroup and remove cell 2/3 under NRDU-1
    ${refNrCellGroup_node_index}    Evaluate    ${copy_cell_id_2}-1
    selenium_coam.remove_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${refNrCellGroup_node_index}    abbr=refNrCellGroup
    ${refNrCellGroup_node_index}    Evaluate    ${copy_cell_id_1}-1
    selenium_coam.remove_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${refNrCellGroup_node_index}    abbr=refNrCellGroup
    Log To Console    Update NRCELL-1/NRPOSINFO-2/3/4/5/6 degreesOfLatitude and degreesOfLongitude
    FOR    ${nrposinfor_id}    IN RANGE    1    7
        ${trp_id}    Evaluate    ${nrposinfor_id}-1
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of latitude   new_value=${degreesOfLatitude_lst[${trp_id}]}     abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of longitude  new_value=${degreesOfLongitude_lst[${trp_id}]}     abbr=degreesOfLongitude
    END
    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    # plan validation
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    # check pdl results list len is 0
    Sleep    120s
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    # Length Should Be    ${pdl_results}    0
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Sleep    60s
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    ${subcell_num_list}    Create List    ${6}
    SupperCell Number And Subcell Number Should Be Expected    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    supper_cell_num=${1}    subcell_num_list=${subcell_num_list}
    [Teardown]   WEBUI Logout


Stepx start ue call and bip log checking for toe
    [Arguments]    ${ue_inex}=0    ${cell_id}=${1}    ${pci}=none    ${subcell_num}=${0}    ${srs_cell_num}=${0}
    Log To Console    Stepx start ue call and bip log checking for toe
    ${ue_index_list}    Create List    ${ue_inex}
    ${nrCellIdentity}    Get NrCellIdentity For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${cell_id}
    ${nrCellId_list}    Create List    ${nrCellIdentity}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time_tcpdump}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time_tcpdump}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc_${log_time_tcpdump}.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    CB010680_UE.UE Start Traffic    ue_index=${ue_inex}    duration=600    dl_tput_sent=1600    ul_tput_sent=250
    ...    if_dl=${True}    if_ul=${True}
    Sleep    40s
    CB010680_UE.UE Check Tput    gnb_index=${0}    log_time=30s    dl_tput_expected=700    ul_tput_expected=100
    ...    if_dl=${True}    if_ul=${True}    dl_cells_list=${nrcellId_list}    ul_cells_list=${nrcellId_list}    ignore_time=15s
    ...    min_percent=0.6    target_avg_percent=0.7
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    Start Common Capture BIP log    target_file_name=bip_srs_${log_time}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    Sleep    2s
    ${pcap_log_path_lst}    End Common Capture BIP log and Download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc_${log_time_tcpdump}.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    ...    pci=${pci}    subcell_num=${subcell_num}    srs_cell_num=${srs_cell_num}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}

Step3 online disable actPRBBlanking
    Log To Console    Step1 online disable actPRBBlanking
    Online Disable actPRBBlanking For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${1}    connection=GNB_OAM
    Check GNB on air    bts_host=${gNB_ip}    time=6 min

Step4 online change SRS only
    [Arguments]    ${cell_id}=${1}
    Log To Console    Step4 Online Change SRS Only
    Online SRS Change For Disable actPRBBlanking For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${cell_id}    connection=GNB_OAM
    Check GNB on air    bts_host=${gNB_ip}    time=6 min

Step1 online enable actPRBBlanking
    [Arguments]    ${cell_id}=${1}
    Log To Console    Step3 online enable actPRBBlanking
    Online Enable actPRBBlanking For Specfic Cell    bts_host=${gNB_ip}    username=${gNB_username}
    ...    password=${gNB_password}    cell_id=${cell_id}    connection=GNB_OAM
    Check GNB on air    bts_host=${gNB_ip}    time=6 min

Step0 Reconfigure 1 Normal Cell To 1 SupperCell with 6 Subcells
    ${nrCellId_old}    ${lcrId_old}    ${physCellId_old}    Get lcrID And pci For Specfic Cell    bts_host=${gNB_ip}
    ...    username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    Selenium_Coam_LogIn_And_Retry    bts_host=${gNB_ip}
    FOR    ${i}  IN RANGE    2    7
        Log To Console    start to delete NRCELL-${i}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${i}
        Log To Console    start to delete NRCELLGRP-${i}
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELLGRP-${i}
        #copy channel group from MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${i}/CHANNELGROUP-1 to LCELNR-1/CHANNELGROUP-${i}
        Log To Console    start to copy channel group from LCELNR-${i} to LCELNR-1/CHANNELGROUP-${i}
        selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${i}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}
        Log To Console    start to delete LCELNR-${i} channel group
        selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${i}
        ${refNrCellGroup_i}    Evaluate    7-${i}
        Log To Console    start to delete refNrCellGroup-${refNrCellGroup_i}
        selenium_coam.remove_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${refNrCellGroup_i}    abbr=refNrCellGroup
        Log To Console    start to add NRPOSINFO structure for NRCELL-1
        selenium_coam.add_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
        ...    object_class_name=NRPOSINFO    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRPOSINFO-1
        ...    include_subobject=${TRUE}
    END
    Log To Console    Stepx Reconfigure 6 Normal Cell To 1 SupperCell 6 Sub-cells
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-256
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRREL-255
    # update MRBTS-37611/NRBTS-37611/NRCELL-1 actSuperCell from false to true
    Log To Console    enable actSuperCell for NRCELL-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell  new_value=true    abbr=actSuperCell
    # update MRBTS-37611/NRBTS-37611/NRCELL-1/NRPOSINFO-2 degreesOfLatitude and degreesOfLongitude
    Log To Console    Update NRCELL-1/NRPOSINFO-2/3/4/5/6 degreesOfLatitude and degreesOfLongitude
    FOR    ${nrposinfor_id}    IN RANGE    1    7
        ${trp_id}    Evaluate    ${nrposinfor_id}-1
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of latitude   new_value=${degreesOfLatitude_lst[${trp_id}]}     abbr=degreesOfLatitude
        selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-1/NRPOSINFO-${nrposinfor_id}
        ...    filter_param=Degrees of longitude  new_value=${degreesOfLongitude_lst[${trp_id}]}     abbr=degreesOfLongitude
    END
    Specfic Paramter Setting For TMO IWK From Normal To SupperCell

    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    # plan validation
    Log To Console    Validate Plan start ...
    selenium_coam.validate_plan
    # check pdl results list len is 0
    Sleep    120s
    ${pdl_results}    selenium_coam.get_relation_errors
    Log To Console    Validate Plan result: ${pdl_results}
    # Length Should Be    ${pdl_results}    0
    Log To Console    Activate Plan start ...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Sleep    60s
    Check GNB on air    bts_host=${gNB_ip}    time=6 min
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}
    [Teardown]   WEBUI Logout

Selenium_Coam_LogIn_And_Retry
    [Arguments]    ${bts_host}=${gNB_ip}    ${retry_times}=${3}
    Log to console    WEBUI Login...
    Wait Until Keyword Succeeds    ${retry_times}x    1min    WEBUI Login    bts_host=${bts_host}