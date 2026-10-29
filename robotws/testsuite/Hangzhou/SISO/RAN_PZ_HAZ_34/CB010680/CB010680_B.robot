*** Settings ***
Suite Setup    CB010680_B Suite setup
Suite Teardown    Run keywords    Kill Firefox process    AND    robot_common_operations.Common Suite Teardown

Documentation
...   author: pengliang.wu@nokia-sbell.com
...   contact: pengliang.wu@nokia-sbell.com


Resource     ./Resource/CB010680_B_Common_KW.robot
Resource     ./Resource/CB010680_A_Common_KW.robot
Resource     ./Resource/CB010680_BIP.robot
Resource     ./Resource/CB010680_UE.robot
Library      ./Resource/CB010680_SRS_BIP.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot


*** Test Cases ***
[1]CB010680_B_001_Precise_Positioning_NormalCell_with_full_ABIP_12_cell_and_RU_ACCESS_only_for_P-SRS_100MHz
    [Documentation]  ABIP normal cell
    ...    feature deactive and active, UE L3 call on NRCELL-0,2,5 and bip srs resource check
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298
    [Tags]    CB010680_B    T749    CRT
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${ue_list}    Create List    ${0}    ${2}
    ${gnb_index}    set variable    ${0}
    ${srs_config_dict}    Create Dictionary    ${0}=${7}      ${5}=${51}
    ${pci_dict}           Create Dictionary    ${0}=${300}    ${5}=${305}
    ${srs_cell_num_dic}    Create Dictionary    ${0}=${0}      ${5}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${nrcellId_list}    Create List    616038400    616038405
    ${NRCELL_used_list}    Create List
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-0
    ...    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-5
    Online active and deactive CB010680    gnb_index=${gnb_index}    cell_id_list=${cell_id_list}    if_active=${False}
    Online active and deactive CB010680    gnb_index=${gnb_index}    cell_id_list=${cell_id_list}    if_active=${True}
    Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELL_used_list}
    All UE L3 Call And Check BIP SRS   gnb_index=${gnb_index}    ue_list=${ue_list}    nrcellId_list=${nrcellId_list}
    ...    srs_config_dict=${srs_config_dict}    pci_dict=${pci_dict}    if_bip_check=${True}    vonr_call_flg=before_traffic
    ...    srs_cell_num_dic=${srs_cell_num_dic}
    Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}    gnb_index=${gnb_index}
    [Teardown]    CB010680_B Case TearDown

[1]CB010680_A_005_Precise_Positioning_SuperCell_with_full_and_half_ABIP_for_RU_ACCESS_only_for_P-SRS_100MHz
    [Documentation]  ABIP normal cell
    ...    half/full ABIP resource change via bbmodBoardConfigType, UE L3 call on NRCELL-2,5,6 and bip srs resource check
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298
    [Tags]    CB010680_A    T749    CRT
    ${fault_id_list}    Create List    ${1868}    ${6825}    ${16}    ${6832}    ${4681}    ${6829}    ${4298}
    AlarmWatchdog.add_allow_alarms    fault_id=${fault_id_list}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${gnb_index}     set variable    ${0}
    Online change bbmodBoardConfigType to lock BB half resource    gnb_index=${gnb_index}    if_full=${False}
    Online change bbmodBoardConfigType to lock BB half resource    gnb_index=${gnb_index}    if_full=${True}
    AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id_list}
    [Teardown]    CB010680_B Case TearDown

[1]CB010680_B_008_Online_add_and_delete_RU_ACCESS_for_ABIP_Precise_Positioning
    [Documentation]  ABIP normal cell
    ...    online delete / add RMOD/NRCELL, UE L3 call on NRCELL-2,5,6 and bip srs resource check
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298,10
    [Tags]    CB010680_B    T749    CRT
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${gnb_index}     set variable    ${0}
    ${cell_id_list}       Create List    0    2    5
    ${cellgrp_id_list}    Create List    0    2    5
    ${rmod_list}          Create List    1    3    6
    ${cablink_list}       Create List    2    4    7
    Download Current BTS SCF To UTE    gnb_index=${gnb_index}    scf_name=origion_scf
    Delete and Add RMOD And NRCELL    gnb_index=${gnb_index}    scf_path=${OUTPUT_DIR}/${TEST NAME}/origion_scf.xml
    ...    cell_id_list=${cell_id_list}    cellgrp_id_list=${cellgrp_id_list}    rmod_list=${rmod_list}
    ...    cablink_list=${cablink_list}
    [Teardown]    CB010680_B Case TearDown

[1]CB010680_Non_CRT_Cell_lock_unlock_testing_with_ABIP_and_RU_ACCESS_only_for_P-SRS_mix_bw
    [Documentation]  ABIP normal cell
    ...    cell lock / unlock multi-times testing
    [Setup]    Common Case Setup    allowed_faults_ids=4655,61524,61652,61649,4654,4592,6832,6825,16,6829,4298
    [Tags]    T749    Non_CIT/CRT
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    FOR    ${index}    IN RANGE    ${1}
        Log to console    loop ${index} start...
        Lock and Unlock NRCELL    lock_cell_list=${NRCELl_List}
        Lock and Unlock NRCELL    unlock_cell_list=${NRCELl_List}
    END
    [Teardown]    CB010680_B Case TearDown