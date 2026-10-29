*** Settings ***
Documentation
...    author: Tang Lixia
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Library             Collections
Library             taf.hw.fhgw.cli                       WITH NAME    issh
Library             taf.config.scf                        WITH NAME    scf
Library             OperatingSystem
Library             String
Library             taf.transport.ssh                     WITH NAME    tafssh
Library             Process
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables   TLConfigration_7199.py


*** Variables ***
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/SCF_0.300_vDU.xml
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${dist}                     MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
${dist_BWP}                     MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/BWP_PROFILE-47/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
${apn_address}              wap2.nokia.com
${counter_value}            4
${MAX_SCHED_UE_PDSCH}       M55308C17002
${MAX_SCHED_UE_PUSCH}       M55308C18002
${DL_SLT_2_SYMB_ALLOC_CBWP1}    M55335C05007
${counter_value_with7090}       0
${enable_7090_flag}         true
${disable_7090_flag}         false
${coresetDedicated_size_48}     48
${coresetDedicated_size_192}    192

*** Keywords ***
NonDBF_eCPRI_NSA_TDD_FR1_DL_UL_IncreasedFdm_100Mhz
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfigDL
    MultiUE Start Traffic    DL_Enable=True
    Sleep   2s
    Run Keyword And Ignore Error     MultiUE Check Bi Tput
    MultiUE Stop Traffic    DL_Enable=True
    MultiUE Detach
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfigUL
    MultiUE Start Traffic    UL_Enable=True
    Sleep   2s
    Run Keyword And Ignore Error    MultiUE Check Bi Tput
    Sleep   300s
    Check FDM Counter Value Result    counter_id=${MAX_SCHED_UE_PDSCH}    expect_counter_value=${counter_value}
    Check FDM Counter Value Result    counter_id=${MAX_SCHED_UE_PUSCH}    expect_counter_value=${counter_value}
    MultiUE Stop Traffic    UL_Enable=True
    MultiUE Detach

NonDBF_eCPRI_NSA_TDD_FR1_UL_IncreasedFdm_100Mhz
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfigUL
    MultiUE Start Traffic    UL_Enable=True
    Run Keyword And Ignore Error    MultiUE Check Bi Tput
    Sleep   300s
    Check FDM Counter Value Result    counter_id=${MAX_SCHED_UE_PUSCH}    expect_counter_value=${counter_value}
    MultiUE Stop Traffic    UL_Enable=True
    MultiUE Detach

NonDBF_eCPRI_NSA_TDD_FR1_DL_IncreasedFdm_100Mhz
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfigDL
    MultiUE Start Traffic    DL_Enable=True
    Run Keyword And Ignore Error    MultiUE Check Bi Tput
    Sleep   300s
    Check FDM Counter Value Result    counter_id=${MAX_SCHED_UE_PDSCH}    expect_counter_value=${counter_value}
    MultiUE Stop Traffic    DL_Enable=True
    MultiUE Detach

CB007090_NonDBF_eCPRI_TDD_PDCCH_FlagActivation_NIDD_ON_100Mhz
    Online Modify 7090 Parameters    7090_flag=${enable_7090_flag}
    Online Modify coresetDedicated Parameters    coresetDedicated_size=${coresetDedicated_size_48}
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfig
    MultiUE Start Traffic    DL_Enable=True
    Sleep   2s
    Run Keyword And Ignore Error     MultiUE Check Bi Tput
    Sleep   300s
    Check 7090 Counter When 7090 on    counter_id=${DL_SLT_2_SYMB_ALLOC_CBWP1}    expect_counter_value=${counter_value_with7090}
    MultiUE Stop Traffic    DL_Enable=True
    MultiUE Detach
    Online Modify 7090 Parameters    7090_flag=${disable_7090_flag}
    MultiUE Attach Parallelly    multiue_config_direction=TLCommonConfig
    MultiUE Start Traffic    DL_Enable=True
    Sleep   2s
    Run Keyword And Ignore Error     MultiUE Check Bi Tput
    Sleep   300s
    Check 7090 Counter When 7090 off    counter_id=${DL_SLT_2_SYMB_ALLOC_CBWP1}    expect_counter_value=${counter_value_with7090}
    MultiUE Stop Traffic    DL_Enable=True
    MultiUE Detach
    [Teardown]    Run keywords    Online Modify coresetDedicated Parameters    coresetDedicated_size=${coresetDedicated_size_192}
    ...           AND    Online Modify 7090 Parameters    7090_flag=${enable_7090_flag}

Online Modify 7090 Parameters
    [Arguments]    ${7090_flag}
    log to console   \n*** Online Modify 7090 Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{7090_modify_parameter_dict}    Create Dictionary    dynPdcchTdMgt/0/actDynPdcchTd=${7090_flag}
    ...    dynPdcchTdMgt/0/pdcchBlockingThreshold=0    dynPdcchTdMgt/0/pdcchFreeThreshold=100
    ...    actCceSplit=true    nUeCtxForCceSplitDeactivation=2
    FOR    ${para_name}    IN    @{7090_modify_parameter_dict}
        ${value}=    Online Get VDU Parameter Value    ${dist}    ${para_name}
        run keyword if    "${value}" != "${7090_modify_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${7090_modify_parameter_dict}[${para_name}]
    END
    log to console   \n*** Modify Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 7090 Parameters
    ...    dist=${dist}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Online Modify coresetDedicated Parameters
    [Arguments]    ${coresetDedicated_size}
    log to console   \n*** Online Modify coresetDedicated Parameters ***
    vDU Login
    &{modify_parameter_dict}    Create Dictionary
    &{7090_modify_parameter_dict_BWP}    Create Dictionary    coresetDedicated/0/size=${coresetDedicated_size}
    FOR    ${para_name}    IN    @{7090_modify_parameter_dict_BWP}
        ${value}=    Online Get VDU Parameter Value    ${dist_BWP}    ${para_name}
        run keyword if    "${value}" != "${7090_modify_parameter_dict_BWP}[${para_name}]"
        ...    Set to Dictionary    ${modify_parameter_dict}    ${para_name}    ${7090_modify_parameter_dict_BWP}[${para_name}]
    END
    log to console   \n*** Modify coresetDedicated Parameters ***
    Run Keyword If  &{modify_parameter_dict} != &{Empty}    Modify 7090 Parameters
    ...    dist=${dist_BWP}   updated_paras_dict=${modify_parameter_dict}    wait_vdu_up=True
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Modify 7090 Parameters
    [Arguments]    ${dist}   ${updated_paras_dict}    ${wait_vdu_up}=False
    ${uni_id}   Get Unique Id
	${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
	log to console   \n*** Generate Delta Plan ***
	${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
	log to console   \n*** Update Delta Plan Parameter ***
	Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${updated_paras_dict}   operation=replace
    log to console   \n*** Validate Delta Plan By REST ***
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    log to console   \n*** Save Delta Plan File ***
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_plan_name}
    log to console   \n*** Activate Delta Plan By REST ***
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}

OAM Precondition Cell Should Be Onair
    wait until keyword succeeds    600   20   vDU Verify All Cells Status Should Be Onair

#Online Get VDU Parameter Value
#    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
#    [Return]  ${out}

Test Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    wait until keyword succeeds    600   20   vDU Verify All Cells Status Should Be Onair


MultiUE Attach Parallelly
    [Arguments]    ${multiue_config_direction}
    log to console      "Prepare UE"
    run keyword if    '${multiue_config_direction}'=='TLCommonConfigDLUL'    Run Keyword And Ignore Error
    ...    power_ue.Prepare UE    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfigDLUL["MultiUECFG"]}
    run keyword if    '${multiue_config_direction}'=='TLCommonConfigUL'    Run Keyword And Ignore Error
    ...    power_ue.Prepare UE    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfigUL["MultiUECFG"]}
    run keyword if    '${multiue_config_direction}'=='TLCommonConfigDL'    Run Keyword And Ignore Error
    ...    power_ue.Prepare UE    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfigDL["MultiUECFG"]}
    run keyword if    '${multiue_config_direction}'=='TLCommonConfig'    Run Keyword And Ignore Error
    ...    power_ue.Prepare UE    ue_type=sigspark_multiUE    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
    log to console      "UE Attach"
    power_ue.UE Attach     ue_type=sigspark_multiUE

MultiUE Start Traffic
    [Arguments]    ${DL_Enable}=False    ${UL_Enable}=False
    log to console      "UE Start Traffic"
    run keyword if    '${DL_Enable}'=='True'    power_ue.Start traffic    ue_type=sigspark_multiUE
    ...                direction=dl
    run keyword if    '${UL_Enable}'=='True'    power_ue.Start traffic    ue_type=sigspark_multiUE
    ...                direction=ul

MultiUE Check Bi Tput
    log to console      "UE Check Tput"
    power_ue.Check Bi Tput    ue_type=sigspark_multiUE

MultiUE Stop Traffic
    [Arguments]    ${DL_Enable}=False    ${UL_Enable}=False
    log to console      "UE Stop Traffic"
    run keyword if    '${DL_Enable}'=='True'
    ...    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=dl
    run keyword if    '${UL_Enable}'=='True'
    ...    power_ue.Stop traffic     ue_type=sigspark_multiUE    direction=ul

MultiUE Detach
    log to console      "UE Detach"
    power_ue.UE Detach        ue_type=sigspark_multiUE

Test Case Teardown
     Run Keyword And Ignore Error    MultiUE Stop Traffic    DL_Enable=True    UL_Enable=True
     Run Keyword And Ignore Error    MultiUE Detach

Get vDU PM Counter Result
    [Arguments]    ${counter_id}    ${dimension_dist_name}    ${vdu_index}=0
    ${counter_result}    vDU Get PM Counter Values    ${counter_id}    ${dimension_dist_name}    ${vdu_index}
    ${len}    Get Length    ${counter_result}
    @{counter_value_list}=    create list
    FOR  ${i}  IN RANGE  ${len}
       ${temp_dic}    Set Variable   ${counter_result[${i}]}
       ${temp_value}   Get From Dictionary    dictionary=${temp_dic}    key=value
       ${counter_value}    Convert To Integer    ${temp_value}
       append to list   ${counter_value_list}   ${counter_value}
    END
    ${counter_return}    Convert To Integer    ${counter_value_list[-1]}
    [return]    ${counter_return}
    
Check FDM Counter Value Result
    [Arguments]    ${counter_id}    ${expect_counter_value}
    ${counter_max}=    Get vDU PM Counter Result    counter_id=${counter_id}    dimension_dist_name=${dist}
    ${Scheduled_UE_num}    Set Variable    ${expect_counter_value}
    ${real_numUEs}    Convert To Integer    ${Scheduled_UE_num}
    Should Be True   ${counter_max} >= ${real_numUEs}

Check 7090 Counter When 7090 on
    [Arguments]    ${counter_id}    ${expect_counter_value}
    ${counter_value}=    Get vDU PM Counter Result    counter_id=${counter_id}    dimension_dist_name=${dist}
    ${expect_counter_value}    Convert To Integer    ${expect_counter_value}
    Should Be True   ${counter_value} == ${expect_counter_value}

Check 7090 Counter When 7090 off
    [Arguments]    ${counter_id}    ${expect_counter_value}
    ${counter_value}=    Get vDU PM Counter Result    counter_id=${counter_id}    dimension_dist_name=${dist}
    ${expect_counter_value}    Convert To Integer    ${expect_counter_value}
    Should Be True   ${counter_value} > ${expect_counter_value}

vDU Get PM Counter Values
    [Arguments]   ${counter_id}   ${dimension_dist_name}  ${vdu_index}=0
    [Documentation]    Get latest counter value from webUI via rest API.
    ...    firstly, using restapi to get the counter whole info, then get the latest value
    ...    | Input Parameters | Man. | Description |
    ...    | counter_id | Yes | PM counter ID |
    ...    | dimension_dist_name | Yes | the dimension dist name that the counter belongs to, like MRBTS-2072/NRBTS-2072/NRCELL-1/NCELA |
    ...    | vdu_index | No |  vdu index to indicate which vdu will be used, 0 in default  |
    ...
    ...    *RETURN VALUE*
    ...    List of counter value
    vDU Rest Login    vdu_index=${vdu_index}
    ${counter_list}=  vdu.get_counter_values    ${counter_id}   ${dimension_dist_name}
    [return]    ${counter_list}
    [Teardown]   vDU Rest Logout   vdu_index=${vdu_index}

