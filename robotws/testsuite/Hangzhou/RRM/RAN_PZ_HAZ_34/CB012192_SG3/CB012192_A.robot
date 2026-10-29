*** Settings ***
Resource    ./Resources/CB012192_common_keywords.robot
Variables    ./Resources/CB012192_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB012192

Suite Setup     Common_suite_Setup_12192

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

*** Variables ***
#${golden_scf_name_10175}    MRBTS-10175_TL365_golden_scf_25R1.xml
#${golden_scf_name_11006}    MRBTS-11006_SBTS25R2_ENB_0000_CA.xml
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_type}    ${tl.ues[0].capabilities[0]}
@{value_beam0_2}    ${1}    ${1}    ${1}    ${0}    ${0}    ${0}
@{value_beam3_5}    ${0}    ${0}    ${0}    ${1}    ${1}    ${1}
@{beam_ID_set_vertical_list_10175}    ${96}    ${96}
@{beam_ID_set_vertical_list_11006}    ${96}    ${102}
@{beam_ID_set_horizontal_list_10175}    ${-40}    ${-22}    ${-5}    ${5}    ${22}    ${40}
@{beam_ID_set_horizontal_list_11006}    ${-35}    ${-14}    ${-6}    ${14}    ${35}    ${0}
@{beam_ID_set_horizontal_list_11006_06}    ${-35}    ${-14}    ${-7}    ${12}    ${34}    ${0}
${ul_throughput_A010_10175}    210000
${ul_throughput_A010_11006}    180000
${ul_throughput_A006_10175}    150000
${ul_throughput_A006_11006}    270000
${ul_throughput_A012_10175}    270000
${ul_throughput_A012_11006}    140000
${tput_target_ul_A010_10175}     130
${tput_target_ul_A010_11006}     180
${tput_target_ul_A006_10175}     140
${tput_target_ul_A006_11006}     180
${tput_target_ul_A012_10175}     87
${tput_target_ul_A012_11006}     130
${ue_alias_11006}                 0
${ue_alias_10175}                 5
${att_value_10175}                35
${att_value_11006}                25
${allow_fault_list}               4291    6327

*** Test Cases ***
[1]CB012192-A_010_4_SSBs_map_to_one_RACH_Occasion_with_RF7.1_nbrOfSsbPerRachOccasion_reconfiguration_with_2_and_4
    [Documentation]    This case describes Pcell and Scells sync status check when Pcell and Scells using different left&right_EdgeAngle setting.
    ...                for Pcell / Scell2 using DFT beams for PDSCH to transfer data to UE because they are using same DFT beam mute setting,
    ...                and Scell1 using PMI beam or SSB beam according to DL SU-MIMO configuration of Scell1.
    ...                2025/5/8 add online modify prachSequenceType=RestrictedTypeA and zeroCorrelationZoneConfig=11 for PR828434.
    [Tags]    A_010_4
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup for 11160
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=four ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_PR828434_${gnb_instance0}}
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_four_${gnb_instance0}}
    Log to console    \n*** Set MCS beamID0 and UE attach ***
    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}'
    ...    prepare MultilUE and MCS    att_value=${35}    vertical=${95}    horizontal=${-40}
    ...    ELSE    prepare MultilUE and MCS    att_value=${25}    vertical=${96}    horizontal=${-35}
    Prepare to caculate PM counter    period=start    counter_time=900
    sleep    10s
    Attach and start UL loop multi beamID    counter_id=${counter_id_CBRA}    tput_target_ul=${tput_target_ul_A010_${gnb_instance0}}
    ...                                      ul_throughput=${ul_throughput_A010_${gnb_instance0}}
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=two ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_two_${gnb_instance0}}
    Prepare to caculate PM counter    period=start    counter_time=900
    sleep    10s
    Attach and start UL loop multi beamID    counter_id=${counter_id_CBRA}    tput_target_ul=${tput_target_ul_A010_${gnb_instance0}}
    ...                                      ul_throughput=${ul_throughput_A010_${gnb_instance0}}
    [Teardown]    Run keyword    test_case_teardown_12192


[1]CB012192-A_006_2_SSBs_map_to_one_RACH_Occasion_with_SA _UEs_CBRA_with_5GC001208_C2_15kHz_prachIndex_202_ABIQ
    [Documentation]    This case describes Pcell and Scells sync status check when Pcell and Scells using different left&right_EdgeAngle setting.
    ...                for Pcell / Scell2 using DFT beams for PDSCH to transfer data to UE because they are using same DFT beam mute setting,
    ...                and Scell1 using PMI beam or SSB beam according to DL SU-MIMO configuration of Scell1.
    [Tags]    A_006_2
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup for 1208
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=four ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_four_${gnb_instance0}}
    Log to console    \n*** Set MCS beamID0 and UE attach ***
    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}'
    ...    prepare MultilUE and MCS    att_value=${35}    vertical=${95}    horizontal=${-40}
    ...    ELSE    prepare MultilUE and MCS    att_value=${25}    vertical=${96}    horizontal=${-35}
    Prepare to caculate PM counter    period=start    counter_time=900
    sleep    10s
    Attach and start UL loop multi beamID    counter_id=${counter_id_CBRA}
    ...    tput_target_ul=${tput_target_ul_A006_${gnb_instance0}}    ul_throughput=${ul_throughput_A006_${gnb_instance0}}
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=two ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_two_${gnb_instance0}}
    Prepare to caculate PM counter    period=start    counter_time=900
    sleep    10s
    Attach and start UL loop multi beamID    counter_id=${counter_id_CBRA}
    ...    tput_target_ul=${tput_target_ul_A006_${gnb_instance0}}    ul_throughput=${ul_throughput_A006_${gnb_instance0}}
    [Teardown]    Run keyword    test_case_teardown_12192

[1]CB012192-A_012_4_SSBs_map_to_one_RACH_Occasion_with_RF7.1_one_UE_CFRA_with_5GC001208_C2_15kHz_prachIndex_195_ABIQ
    [Documentation]    This case describes Pcell and Scells sync status check when Pcell and Scells using different left&right_EdgeAngle setting.
    ...                for Pcell / Scell2 using DFT beams for PDSCH to transfer data to UE because they are using same DFT beam mute setting,
    ...                and Scell1 using PMI beam or SSB beam according to DL SU-MIMO configuration of Scell1.
    [Tags]    A_012_4
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup for 1208
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=four ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_four_${gnb_instance0}}
    Log to console    \n*** Set MCS beamID0 and UE attach ***
    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}'
    ...    prepare MultilUE and MCS    att_value=${35}    vertical=${95}    horizontal=${-40}
    ...    ELSE    prepare MultilUE and MCS    att_value=${25}    vertical=${96}    horizontal=${-35}    UE_mode=5G_NSA
    Prepare to caculate PM counter    period=start    counter_time=900
    sleep    10s
    Attach and start UL loop multi beamID    counter_id=${counter_id_CFRA}    spark_UEmode=5G_NSA
    ...    tput_target_ul=${tput_target_ul_A012_${gnb_instance0}}    ul_throughput=${ul_throughput_A012_${gnb_instance0}}
    Log to console    \n*** set value nbrOfSsbPerRachOccasion=two ***
    Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_nbrOfSsbPerRachOccasion_two_${gnb_instance0}}
    Log to console    \n*** Set MCS beamID0 and UE attach ***
    Attach and start UL loop multi beamID    counter_id=${counter_id_CFRA}    spark_UEmode=5G_NSA
    ...    tput_target_ul=${tput_target_ul_A012_${gnb_instance0}}    ul_throughput=${ul_throughput_A012_${gnb_instance0}}
    [Teardown]    Run keyword    test_case_teardown_12192

*** Keywords ***
Common Case TestLine Setup for 11160
    [Arguments]
#    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}' and '${release_info}' == 'SBTS25R3_ENB_0000'
#    ...    Common Case TestLine Setup    golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml    ModifySCF_Beforecommission=True
#    ...    ParamterToModify=${ParamterToModify_12129_11160_F0_${gnb_instance0}}    ListParamterToModify=${LISTTOmodify_12192_F0_${gnb_instance0}}
#    ...    ListToAdd=${LIST_TO_ADD_11160_F0_${gnb_instance0}}    ParameterToDelete=${PARAMS_TO_delete_11160_F0_${gnb_instance0}}
    Run keyword If    '${gnb_instance0}'=='${gnb_id[1]}'    run keyword
    ...    Common Case TestLine Setup    golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml    ModifySCF_Beforecommission=True
    ...    ParamterToModify=${ParamterToModify_12129_11160_F0_${gnb_instance0}}    ListParamterToModify=${LISTTOmodify_12192_F0_${gnb_instance0}}
    ...    ListToAdd=${LIST_TO_ADD_11160_F0_${gnb_instance0}}    ParameterToDelete=${PARAMS_TO_delete_11160_F0_${gnb_instance0}}
    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}'
    ...    Common Case TestLine Setup    is_commission=True
    ...                                  golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0

Common Case TestLine Setup for 1208
    [Arguments]
#    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}' and '${release_info}' == 'SBTS25R3_ENB_0000'
#    ...    Common Case TestLine Setup    golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml    ModifySCF_Beforecommission=True
#    ...    ParamterToModify=${ParamterToModify_12129_1208_C2_${gnb_instance0}}
#    ...    ListToAdd=${LIST_TO_ADD_1208_C2_${gnb_instance0}}    ParameterToDelete=${PARAMS_TO_delete_1208_C2_${gnb_instance0}}
#    ...    ListParamterToModify=${LISTTOmodify_1208_F0_${gnb_instance0}}
    Run keyword If    '${gnb_instance0}'=='${gnb_id[1]}'
    ...    Common Case TestLine Setup    golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml    ModifySCF_Beforecommission=True
    ...    ParamterToModify=${ParamterToModify_12129_1208_C2_${gnb_instance0}}
    ...    ListToAdd=${LIST_TO_ADD_1208_C2_${gnb_instance0}_TRUNK}    ParameterToDelete=${PARAMS_TO_delete_1208_C2_${gnb_instance0}}
    ...    ListParamterToModify=${LISTTOmodify_1208_F0_${gnb_instance0}}
    Run keyword If    '${gnb_instance0}'=='${gnb_id[0]}' and '${release_info}' == 'SBTS26R1_ENB_0000'
    ...    Common Case TestLine Setup    golden_scf_name=MRBTS-${gnb_instance0}_${release_info}.xml    ModifySCF_Beforecommission=True
    ...    ParamterToModify=${ParamterToModify_12129_1208_C2_${gnb_instance0}_26R1}
    ...    ListToAdd=${LIST_TO_ADD_1208_C2_${gnb_instance0}_26R1}    ParameterToDelete=${PARAMS_TO_delete_1208_C2_${gnb_instance0}}
    ...    ListParamterToModify=${LISTTOmodify_1208_F0_${gnb_instance0}_26R1}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0

attach and start beamID UL traffic
    [Arguments]    ${tput_target_ul}=90    ${ul_throughput}=260000
    ...            ${ue_index}=${0}    ${spark_UEmode}=5G_SA
    run keyword if    '${gnb_instance0}' == '10175'
    ...    Spark_multiUE.attach UE    ue_index=${ue_index}    spark_ue_mode=${spark_UEmode}
    ...    ELSE    Dingli_single_multiUE_attach_new_version    ue_alias=${uegroup}[0]
    run keyword if    '${gnb_instance0}' == '10175'
    ...    Spark_multiUE.start UL traffic    ue_index=${ue_index}    bandwidth=${ul_throughput}
    ...   ELSE    Start UL Data Transfer with pioneer client    ues_index=${ue_index}    ul_throughput=${ul_throughput}
    run keyword if    '${gnb_instance0}' == '10175'    Wait until keyword succeeds    5X    5s
    ...    Check UL_tput for spark_multiUE    ue_index=${ue_index}    tput_target=${tput_target_ul}
    ...    ELSE    Wait until keyword succeeds    5X    5s
    ...    Check traffic with pioneer client with pioneer client    tput_target=${tput_target_ul}    ues_index=${ue_index}
    [Teardown]    Run keyword and ignore error     run keyword if    '${gnb_instance0}' == '10175'
    ...    stop and detach spark ue    ue_index=${ue_index}
    ...    ELSE    Detech and stop UL traffic

Attach and start UL loop multi beamID
    [Arguments]    ${ue_index}=${0}
    ...    ${counter_id}=${counter_id_CBRA}
    ...    ${att_value}=${att_value_${gnb_instance0}}
    ...    ${tput_target_ul}=90
    ...    ${value_beam0_2}=${value_beam0_2}    ${value_beam3_5}=${value_beam3_5}
    ...    ${ul_throughput}=260000
    ...    ${spark_UEmode}=5G_SA
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[0]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[0]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[0]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[1]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[0]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[2]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    Prepare to caculate PM counter    period=end    counter_time=900
    sleep    60s
    Check the PM counter update    counter_id=${counter_id}    dic_path=${dic_path_CBRA_beam_${gnb_instance0}}    value=${value_beam0_2}
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[0]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[3]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[0]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[4]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    MCS SET ATT AND PHASE    att_value=${att_value}    vertical=${beam_ID_set_vertical_list_${gnb_instance0}}[1]
    ...                      horizontal=${beam_ID_set_horizontal_list_${gnb_instance0}}[5]
    attach and start beamID UL traffic    tput_target_ul=${tput_target_ul}    ul_throughput=${ul_throughput}
    ...                                   ue_index=${ue_index}    spark_UEmode=${spark_UEmode}
    Prepare to caculate PM counter    period=end    counter_time=900
    sleep    60s
    Check the PM counter update    counter_id=${counter_id}    dic_path=${dic_path_CBRA_beam_${gnb_instance0}}    value=${value_beam3_5}

test_case_teardown_12192
    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    run keyword if    '${gnb_instance0}' == '10175'
    ...    stop and detach spark ue    spark_ue_id=${spark_ue_id}
    ...    ELSE    Detech and stop UL traffic
    Run Keyword And Ignore Error    run keyword if    '${gnb_instance0}' == '11006'
    ...                             client.stoplog      service=pioneer
    ...    ELSE    Spark_multiUE.stop ue log    spark_service=spark_ue
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    Common Case Teardown for COAM

