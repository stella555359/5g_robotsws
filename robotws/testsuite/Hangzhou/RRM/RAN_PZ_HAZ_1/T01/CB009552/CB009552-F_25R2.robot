*** Settings ***
Documentation
...   Author: Rong Nie
...   Contact: rong.nie@nokia-sbell.com
...   Description: CB009552-F improves the situation by allowing user to run selected scripts embedded in Cloud BTS SW using WebEM and M2M.
...                The scripts will collect additional Troubleshooting RF and vDU data.

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK

#Test Timeout    60 minutes

Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../Resources/RRM2_Resource.robot
Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot

*** Variables ***
${log_type}    tssVdu
@{profile}    tssVdu
&{dcap_info}   host=10.69.9.51    port=443
    ...    username=utfuser    password=utfadmin!

&{trace_info_1}    vdu_custom_profile=${profile}
...    script_names=RU_Common_capture_IQ_data
...    cells=MRBTS-4294967294/NRBTS-4294967294/NRCELL-1
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-1
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-1

&{trace_info_2}    vdu_custom_profile=${profile}
...    script_names=RU_Common_capture_L1low_data
...    cells=MRBTS-4294967294/NRBTS-4294967294/NRCELL-1
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-1
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-1

&{trace_info_3}    vdu_custom_profile=${profile}
...    script_names=RU_Common_capture_register_dump
...    cells=MRBTS-4294967294/NRBTS-4294967294/NRCELL-2
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-2
...    rmods=MRBTS-4294967294/EQM_R-1/APEQM_R-1/RMOD_R-2

*** Test Cases ***
[1]CB010412_CB009409-A#B1_Enable_Disable_TCP_Boost_proactivate_grants_for_all_UEs
    [Tags]    QC_145595       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: yali.an@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.11.2023,yali.an@nokia-sbell.com, draft

#    Create NRDRB_TCP_BOOST-1 in vDU
#    Check both vDU and vCU cells should be onair
#    Enable/Disable CB009409     allUes
    @{para_list}          Create List    actTcpBoostPug
    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-3
    @{value_list_true}    Create List    allUes
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VDU paramter update result: ${out}
    Check both vDU and vCU cells should be onair

#    Enable/Disable CB009409     disabled
    @{para_list}          Create List    actTcpBoostPug
    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-3
    @{value_list_true}    Create List    disabled
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VDU paramter update result: ${out}
    Check both vDU and vCU cells should be onair
    Collect and Check counter M55308C00038_39_40_41_41_42

#[0]CB010412_CB010584_ENDC_X2_SETUP_REQUEST_received_by_gNB_with_NokiaENDCChallenge_IE_which_is_determined_as_passing_ASN_1_transfer_syntax_rules
#    [Tags]    QC_145596       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie
#    ...    Contact: rong.nie@nokia-sbell.com
#    ...    11.14.2023,rong.nie@nokia-sbell.com
#
#    @{para_list}          Create List    x2LinkLock
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/LTEENB-0
#    @{value_list_true}    Create List    locked
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VCU paramter update result: ${out}
#    sleep    60s
#
#    @{para_list}          Create List    x2LinkLock
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/LTEENB-0
#    @{value_list_true}    Create List    unlocked
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VCU paramter update result: ${out}
#
#    Check both vDU and vCU cells should be onair
#    sleep    60s
#    Check CU Counter for M55110C00004
#
##[1]CB009552_A_012_Launch_and_execute_troubleshooting_RMOD_script_from_M2M
##    [Tags]    QC_32397      QCD_MN_RAN      QCP_RAN_VRF
##    [Documentation]
##    ...    Author: rong.nie@nokia-sbell.com
##    ...    history change: <date>,<who>,<what and how>
##    ...    24.11.2023,rong.nie@nokia-sbell.com, draft
##
##    ${alias}  set variable   vdu_connection
##    ${vdu_index}  set variable   0
##    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
##    ${res_scripts}  Get Troubleshooting Scripts Information   vdu_connection=${alias}
##    Log To Console  ${res_scripts}
##    @{NR_cell_list}   create list
##    @{ru_dist_name_list}   create list
##    ${alias}  set variable   vdu_connection
##    ${vdu_index}  set variable   0
##    append to list   ${NR_cell_list}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
##    append to list   ${ru_dist_name_list}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
##    @{fixed_param_and_values_list}   create list
##    &{param_cell_dict}    Create Dictionary
##    &{param_ru_dict}    Create Dictionary
##    Set To Dictionary    ${param_cell_dict}    param_type=cellList   param_value=${NR_cell_list}
##    Set To Dictionary    ${param_ru_dict}    param_type=ruList   param_value=${ru_dist_name_list}
##    append to list   ${fixed_param_and_values_list}   ${param_cell_dict}   ${param_ru_dict}
##    log to console    ${fixed_param_and_values_list}
##    ${status}   ${res}   Run Keyword And Ignore Error   Get Troubleshooting Script Log By M2M  alias=${alias}
##    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}   script_name=RU_Common_capture_IQ_data_
##    log to console   ${res}
##    ${re_complie}   Get Regexp Matches    ${res}   does not exist
##    should not be empty  ${re_complie[0]}
##
##    ${res}   Get Troubleshooting Script Log By M2M   alias=${alias}
##    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}   script_name=RU_Common_capture_IQ_data
##
##    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
##    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status
##    ...                                                                    operation_id=${res["operation_id"]}
##    ...                                                                    vdu_connection=${alias}
##    Delete Troubleshooting Script Runner Operation   operation_id=${res["operation_id"]}   vdu_connection=${alias}
#
#[2]CB009552_A_013_Launch_and_execute_troubleshooting_RMOD_script_reject_from_M2M
#    [Tags]    QC_145607       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    24.11.2023,rong.nie@nokia-sbell.com, draft
#
#    ${vdu_index}  set variable   0
#    ${alias}  set variable   vdu_connection
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    ${Snapshot_path_legacy}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
#    ...                 directory_name=vdu_snapshot_legacy
#    vdu.trigger_local_snapshot    vdu_connection=${alias}  use_m2m=${false}
#
#    @{NR_cell_list}   create list
#    @{ru_dist_name_list}   create list
#    append to list   ${NR_cell_list}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    append to list   ${ru_dist_name_list}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    @{fixed_param_and_values_list}   create list
#    &{param_cell_dict}    Create Dictionary
#    &{param_ru_dict}    Create Dictionary
#    Set To Dictionary    ${param_cell_dict}    param_type=cellList   param_value=${NR_cell_list}
#    Set To Dictionary    ${param_ru_dict}    param_type=ruList   param_value=${ru_dist_name_list}
#    append to list   ${fixed_param_and_values_list}   ${param_cell_dict}   ${param_ru_dict}
#    log to console    ${fixed_param_and_values_list}
#    ${status}   ${res_2}   Run Keyword And Ignore Error   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}  script_name=RU_Common_capture_IQ_data
#    log to console   ${res_2}
#    ${re_complie}   Get Regexp Matches    ${res_2}   Conflict
#    should not be empty  ${re_complie[0]}
#
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Reset vDU
#    Sleep   180s
#    Check both vDU and vCU cells should be onair
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#
#
#    ${res_5}   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}  script_name=RU_Common_capture_IQ_data
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status
#    ...                                                                    operation_id=${res_5["operation_id"]}
#    ...                                                                    vdu_connection=${alias}
#    ${Snapshot_path_1}   Save CB009552-F Local Snapshot In vDU With Judge   alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_1}    vdu_snapshot_path=vdu_snapshot_1
#    should not be empty   ${match_file}
#
#    @{NR_cell_list_6}   create list
#    @{ru_dist_name_list_6}   create list
#    ${alias}  set variable   vdu_connection
#    ${vdu_index}  set variable   0
#    append to list   ${NR_cell_list_6}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    append to list   ${ru_dist_name_list_6}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    @{fixed_param_and_values_list_6}   create list
#    &{param_cell_dict}    Create Dictionary
#    &{param_ru_dict}    Create Dictionary
#    Set To Dictionary    ${param_cell_dict}    param_type=cellList   param_value=${NR_cell_list_6}
#    Set To Dictionary    ${param_ru_dict}    param_type=ruList   param_value=${ru_dist_name_list_6}
#    append to list   ${fixed_param_and_values_list_6}   ${param_cell_dict}   ${param_ru_dict}
#    log to console    ${fixed_param_and_values_list_6}
#    ${res_6}   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list_6}  script_name=RU_Common_capture_IQ_data
#
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status_1
#    ...                                                                    operation_id=${res_6["operation_id"]}
#    ...                                                                    vdu_connection=${alias}
#    ${Snapshot_path_2}   Save CB009552-F Local Snapshot In vDU With Judge     alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_2}    vdu_snapshot_path=vdu_snapshot_2
#    should not be empty   ${match_file}
#    Sleep   60s
#
#[3]CB009552_A_014_Launch_and_execute_troubleshooting_interaction_with_snapshot_Exc3b1_from_M2M
#    [Tags]    QC_145605       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    24.11.2023,rong.nie@nokia-sbell.com, draft
#    @{NR_cell_list}   create list
#    @{ru_dist_name_list}   create list
#    ${alias}  set variable   vdu_connection
#    ${vdu_index}  set variable   0
#    append to list   ${NR_cell_list}   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    append to list   ${ru_dist_name_list}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    @{fixed_param_and_values_list}   create list
#    &{param_cell_dict}    Create Dictionary
#    &{param_ru_dict}    Create Dictionary
#    Set To Dictionary    ${param_cell_dict}    param_type=cellList   param_value=${NR_cell_list}
#    Set To Dictionary    ${param_ru_dict}    param_type=ruList   param_value=${ru_dist_name_list}
#    append to list   ${fixed_param_and_values_list}   ${param_cell_dict}   ${param_ru_dict}
#    log to console    ${fixed_param_and_values_list}
#    ${res}   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}  script_name=RU_Common_capture_L1low_data
#    ${Snapshot_path_1}  Save Legacy Local Snapshot In vDU With Judge   alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_1}    vdu_snapshot_path=vdu_snapshot_1
#    should be empty   ${match_file}
#
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status
#    ...                                                                    operation_id=${res["operation_id"]}
#    ...                                                                    vdu_connection=${alias}
#
#    ${Snapshot_path_2}   Save Legacy Local Snapshot In vDU With Judge  alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_2}    vdu_snapshot_path=vdu_snapshot_2
#    should not be empty   ${match_file}
#    Sleep   60s
#
#[4]CB009552_A_015_Launch_and_execute_troubleshooting_interaction_with_snapshot_Exc3b2_3_from_M2M
#    [Tags]    QC_145606       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    24.11.2023,rong.nie@nokia-sbell.com, draft
#
#    ${alias}  set variable   vdu_connection
#    ${vdu_index}  set variable   0
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    @{ru_dist_name_list}   create list
#    append to list   ${ru_dist_name_list}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    @{fixed_param_and_values_list}   create list
#    &{param_ru_dict}    Create Dictionary
#    Set To Dictionary    ${param_ru_dict}    param_type=ruList   param_value=${ru_dist_name_list}
#    append to list   ${fixed_param_and_values_list}   ${param_ru_dict}
#    log to console    ${fixed_param_and_values_list}
#    ${res}   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}  script_name=RU_Common_capture_register_dump
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status
#    ...                                                                    operation_id=${res["operation_id"]}
#    ...                                                                    vdu_connection=${alias}
#
#    ${res_1}   ${operation_id}    Run Keyword And Ignore Error   vdu.trigger_local_snapshot   vdu_connection=${alias}
#
#    ${Snapshot_path_legacy}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}
#    ...                 directory_name=vdu_snapshot_legacy
#    ${status}   ${res_2}   Run Keyword And Ignore Error   vdu.trigger_local_snapshot    vdu_connection=${alias}  use_m2m=${False}
#    log to console   ${res_2}
#    ${re_complie}   Get Regexp Matches    ${res_2}   already ongoing
#    should not be empty  ${re_complie[0]}
#
#    vdu.cancel_snapshot_operation    ${operation_id}   vdu_connection=${alias}
#    Sleep   90s
#
#    ${res}   Get Troubleshooting Script Log By M2M   alias=${alias}
#    ...                 fixed_param_and_values_list=${fixed_param_and_values_list}  script_name=RU_Common_capture_register_dump
#    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
#    Wait Until Keyword Succeeds    1200    60    Check Troubleshooting Script Runner Operation Status
#    ...                                                                    operation_id=${res["operation_id"]}
#    ...                                                                    vdu_connection=${alias}
#
#    ${Snapshot_path_3}  Save CB009552-F Local Snapshot In vDU With Judge   alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_3}    vdu_snapshot_path=vdu_snapshot_3
#    should not be empty    ${match_file}
#
#    ${Snapshot_path_4}   Save CB009552-F Local Snapshot In vDU With Judge   alias=${alias}
#    ${match_file}   parse trobshooting log For VDU  snapshot_path=${snapshot_path_3}     vdu_snapshot_path=vdu_snapshot_4
#    should be empty    ${match_file}
#
##[5]CB009552_A_020_Launch_and_execute_troubleshooting_RMOD_script_from_UTF
##    [Tags]    QC_32394       QCD_MN_RAN      QCP_RAN_VRF
##    [Documentation]
##    ...    Author: rong.nie@nokia-sbell.com
##    ...    history change: <date>,<who>,<what and how>
##    ...    31.01.2024,rong.nie@nokia-sbell.com, draft
##    Start To Collect Log By DCAP    ${dcap_info}    ${log_type}
##    ...    product_type=vdu    gnb_index=${0}    cudu_index=${0}
##    ...    &{trace_info_1}
##    sleep    2min
##
##    # download log
##    ${dcap_local_file_path}=     Download tss Log In vDU    wait_time=1080s
##    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
##    ${archive}    set variable    ${dcap_local_file_path}/@{files}[0]
##
##    # check tss log
##    ${log_file_paths}=    Extract tss log from trace file    ${archive}    ${dcap_local_file_path}
##    ...    ru_index=${1}    substring=SCRIPT_RESULT
##    should not be empty    ${log_file_paths}
##
##    Start To Collect Log By DCAP    ${dcap_info}    ${log_type}
##    ...    product_type=vdu    gnb_index=${0}    cudu_index=${0}
##    ...    &{trace_info_2}
##    sleep    2min
##
##    # download log
##    ${dcap_local_file_path}=     Download tss Log In vDU    wait_time=1080s
##    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
##    ${archive}    set variable    ${dcap_local_file_path}/@{files}[0]
##
##    # check tss log
##    ${log_file_paths}=    Extract tss log from trace file    ${archive}    ${dcap_local_file_path}
##    ...    ru_index=${1}    substring=SCRIPT_RESULT
##    should not be empty    ${log_file_paths}
##
##    Start To Collect Log By DCAP    ${dcap_info}    ${log_type}
##    ...    product_type=vdu    gnb_index=${0}    cudu_index=${0}
##    ...    &{trace_info_3}
##    sleep    2min
##
##    # download log
##    ${dcap_local_file_path}=     Download tss Log In vDU    wait_time=1080s
##    @{files}    OperatingSystem.List Files In Directory    ${dcap_local_file_path}    *.zip
##    ${archive}    set variable    ${dcap_local_file_path}/@{files}[0]
##
##    # check tss log
##    ${log_file_paths}=    Extract tss log from trace file    ${archive}    ${dcap_local_file_path}
##    ...    ru_index=${2}    substring=SCRIPT_RESULT
##    should not be empty    ${log_file_paths}
#
#[6]CB010507_A_B1_Activation of 2 dedicated BWPs_small BWP configured in Legacy Canadian n77 frequency range
#    [Tags]    QC_145686       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie
#    ...    Contact: rong.nie@nokia-sbell.com
#    ...    11.14.2023,rong.nie@nokia-sbell.com
#    ...    The purose of this test case is verify CB010507 enable and disable.
#
#    ${out}            Parameter Operation    operation=full_commission   product_type=vdu
#    ...               scf_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009552/10507vdu.xml
#    Log To Console    VDU full commission result: ${out}
#
#    ${out}            Parameter Operation    operation=full_commission   product_type=vcu
#    ...               scf_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009552/10507vcu.xml
#    Log To Console    VCU full commission result: ${out}
#
#    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=vdu
#    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
#    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=vcu
#    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
#
#    @{para_list}          Create List    actLegExt2N77Coexist
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-2147483647
#    @{value_list_true}    Create List    false
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU paramter update result: ${out}
#
#    @{para_list}          Create List    actLegExt2N77Coexist
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-2147483647
#    @{value_list_true}    Create List    false
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VCU paramter update result: ${out}
#
#    wait until keyword succeeds    5 min    10 sec    get alarm for vdu   expect_fault_id=7516    alarm_exist_flag=${True}
#
#    @{para_list}          Create List    actLegExt2N77Coexist
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-2147483647
#    @{value_list_true}    Create List    true
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VDU paramter update result: ${out}
#
#    @{para_list}          Create List    actLegExt2N77Coexist
#    @{mo_list_vdu}        Create List    MRBTS-4294967294/NRBTS-4294967294/NRCELL-2147483647
#    @{value_list_true}    Create List    true
#    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
#    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
#    Log To Console        VCU paramter update result: ${out}
#
#    wait until keyword succeeds    5 min    10 sec    get alarm for vdu   expect_fault_id=7516    alarm_exist_flag=${False}
#
#    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify    product_type=vdu
#    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
#    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=vcu
#    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
#
#[7]CB010507_A_B5_Deactivation of NR Cell which is partly in Legacy and partly in Extended Canadian n77 frequency range
#    [Tags]    QC_145687       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie
#    ...    Contact: rong.nie@nokia-sbell.com
#    ...    05.07.2024,rong.nie@nokia-sbell.com
#    ...    This case was covered by CB010507_A_B1_Activation of 2 dedicated BWPs_small BWP configured in Legacy Canadian n77 frequency range.
#
#    Log To Console    VCB010507_A_B5_Deactivation of NR Cell which is partly in Legacy and partly in Extended Canadian n77 frequency range
#
#[8]CB010507_C_B1_NSA_EN_DC Setup of Legacy Canadian n77 UE_configured with small BWP profile
#    [Tags]    QC_145688       QCD_MN_RAN      QCP_RAN_VRF
#    [Documentation]
#    ...    Author: rong.nie
#    ...    Contact: rong.nie@nokia-sbell.com
#    ...    05.07.2024,rong.nie@nokia-sbell.com
#    ...    This case was covered by CB010507_A_B1_Activation of 2 dedicated BWPs_small BWP configured in Legacy Canadian n77 frequency range.
#
#    Log To Console    CB010507_C_B1_NSA_EN_DC Setup of Legacy Canadian n77 UE_configured with small BWP profile

*** Keywords ***
Check Troubleshooting Script Runner Operation Status
    [Arguments]    ${operation_id}   ${vdu_connection}=vdu_con
    log to console    Check Troubleshooting Script Runner Operation Status
    ${res_operation}   Get Troubleshooting Script Runner Operation   operation_id=${operation_id}
    ...                                                              vdu_connection=${vdu_connection}
    should be True  "${res_operation}"=="succeeded"

Check Troubleshooting Script Runner Operation Status_1
    [Arguments]    ${operation_id}   ${vdu_connection}=vdu_con
    log to console    Check Troubleshooting Script Runner Operation Status
    ${res_operation}   Get Troubleshooting Script Runner Operation   operation_id=${operation_id}
    ...                                                              vdu_connection=${vdu_connection}
    should be True  "${res_operation}"=="partialSucceeded"

Get Troubleshooting Script Log By M2M
    [Arguments]    ${fixed_param_and_values_list}   ${vdu_index}=${0}   ${script_name}=RU_Common_capture_IQ_data
    ...            ${gnb_index}=${0}   ${alias}=vdu_con
    [Documentation]  Get Troubleshooting Script Log By M2M
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | param_value_cell_list | yes | NRCELL distname list,
    ...     for example:[MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1,MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1] |
    ...    | param_value_ru_list | yes | ru distname list,
    ...     for example:[MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1,MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2] |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | alias | yes | VduConnection object or string name alias if used|
    ...
    ...    Example
    ...    | Get Troubleshooting Script Log By M2M | alias=vdu_con |
    ...
    log to console    Get Troubleshooting Script Log By M2M
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}     alias=${alias}
    ${res}    Launch Troubleshooting Script By M2M   fixed_param_and_values_list=${fixed_param_and_values_list}
    ...                                              script_name=${script_name}
    ...                                              vdu_conn=${alias}
    [Return]   ${res}
    [Teardown]    vDU Logout By Rest   vdu_index=${0}   alias=${alias}

Save Legacy Local Snapshot In vDU With Judge
    [Arguments]    ${vdu_index}=${0}
    ...            ${filter_regx}=[A-Z]\\w+   ${alias}=VDU_connect
    [Documentation]    Save Legacy Local Snapshot
    ...    Author: Yang Menglinokia-sbell.com
    ...    Contact: mengli.yang@ation | No | local_snapshot_location  |
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | use_m2m | No | m2m feature activation flag.If set to False, internal API will be used instead of M2M |
    ...    | compressed_or_not | No | if it is assigned to True, compressed all the files to one zip file. |
    ...    | filter_regx | No | snapshot filter regular expression, default is None. |
    ...    | alias | yes | define alias of connect to vDU |
    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    log to console    Save Legacy Local Snapshot In vDU With Judge
    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
    ${Snapshot_path}   Save Local Snapshot In vDU With Judge   use_m2m=${True}   filter_regx=${filter_regx}   alias=${alias}
    sleep   10s
    vDU Login By Rest    vdu_index=${0}    alias=${alias}
#    Delete Troubleshooting Script Runner Operation   operation_id=${res["operation_id"]}   vdu_connection=${alias}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout By Rest   vdu_index=${0}   alias=${alias}

Save CB009552-F Local Snapshot In vDU With Judge
    [Arguments]    ${vdu_index}=${0}
    ...            ${filter_regx}=\.*SCRIPT_RESULT\.*   ${alias}=VDU_connect
    [Documentation]    Save CB009552-F Local Snapshot
    ...    Author: Yang Menglinokia-sbell.com
    ...    Contact: mengli.yang@ation | No | local_snapshot_location  |
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | use_m2m | No | m2m feature activation flag.If set to False, internal API will be used instead of M2M |
    ...    | compressed_or_not | No | if it is assigned to True, compressed all the files to one zip file. |
    ...    | filter_regx | No | snapshot filter regular expression, default is None. |
    ...    | alias | yes | define alias of connect to vDU |


    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    log to console    Save CB009552-F Local Snapshot In vDU With Judge
    vDU Login By Rest    vdu_index=${vdu_index}    alias=${alias}
    ${Snapshot_path}   Save Local Snapshot In vDU With Judge   use_m2m=${True}   filter_regx=${filter_regx}   alias=${alias}
    sleep   10s
    vDU Login By Rest    vdu_index=${0}    alias=${alias}
#    Delete Troubleshooting Script Runner Operation   operation_id=${res["operation_id"]}   vdu_connection=${alias}
    [Return]    ${Snapshot_path}
    [Teardown]    vDU Logout By Rest   vdu_index=${0}   alias=${alias}

Reset vDU
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Reset VDU By REST
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | need_check_on_air | no | if need to check cell on air |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset vDU With Check Cell On Air | need_check_on_air=${False} |
    ...
    log to console  Reset VDU By REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${error_msg}    set variable  ${out["error_message"]}
    should contain    ${error_msg}    No error
    ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
    ...                                                                                expected_status=ongoing
#    Sleep    100s
#    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s   30s
#    ...                            vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
#    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Check both vDU and vCU cells should be onair
    Log To Console    \n*** check on air state in cu ***
    wait until keyword succeeds    1200    20
    ...        Check All Cells On Air In vCU
    Log To Console    \n*** check on air state in du ***
    wait until keyword succeeds    1200    20
    ...        vDU Check All Cells Status Should Be Onair

Download tss Log In vDU
    [Arguments]    ${product_type}=vdu
    ...            ${wait_time}=300s
    ...            ${timeout}=${600}
    [Documentation]   this kw is used to Stop And Decode TTI Log In vDU
    ...     Author: Liu Renhui
    ...    | Input Parameters | Man. | Description |
    ...    | product_type | no |  |
    ...
    ...    | Return Value | Description |
    ...    | dcap_local_file_path | required file paths |
    ...
    ${bts_http_con_info}=    Get BTS Http Connection Info    product_type=${product_type}
    ...    gnb_index=${0}    cudu_index=${0}
    ${dcap_local_file_path}=    Download Trace File    ${bts_http_con_info.host}
    ...    wait_time=${wait_time}    timeout=${timeout}
    [Return]    ${dcap_local_file_path}

Set The Value of x2LinkLock to ${value}
    Log To Console      Set The Value of x2LinkLock in vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/LTEENB-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/x2LinkLock
    ...                                                                         value=${value}
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=x2LinkLock
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}

Check CU Counter for M55110C00004
    ${cu_counter_id_list}    Create List    M55110C00004
    ${cu_counter_values_final_list}    Create List
    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
        ${cu_counter_values_final_list}    Check Counter For vCU   counter_id=${cu_counter_id}
        ...                                            measurement_id=55110
        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
        ...                                            expected_value=1
        ...                                            get_number=60
        ...                                            comparison=equal
    END

get alarm for vdu
    [Arguments]  ${vdu_index}=${0}  ${gnb_index}=${0}   ${alias}=vdu_connection  ${expect_fault_id}=49
    ...          ${alarm_exist_flag}=${False}
    vDU Login By Rest    vdu_index=${vdu_index}      gnb_index=${gnb_index}  alias=${alias}
    ${out}    vdu.vdu_get_active_alarms  vdu_connection=${alias}
    ${flag_exist}  set variable   ${False}
    log to console   ${out["alarms"]}
    FOR  ${alarm_dict}  IN   @{out["alarms"]}
       log to console   ${alarm_dict["fault_id"]}
       Run Keyword If   "${alarm_dict["fault_id"]}"=="${expect_fault_id}"  run keywords
       ...     Set Test Variable    ${flag_exist}   ${True}
       ...    AND    exit for loop
    END
    should be equal    ${flag_exist}   ${alarm_exist_flag}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest   vdu_index=${vdu_index}   alias=${alias}

Create NRDRB_TCP_BOOST-1 in vDU
    Log To Console      \n*** create NRDRB_TCP_BOOST-1 in vDU ***
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDRB-3
    &{parameter_dict}    Create Dictionary   nrDrbTcpBoostDN=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDRB_TCP_BOOST-1
    vDU Online Create MO With Modify Parameter Via Rest    updated_paras_dict=${parameter_dict}
    ...                                                    mo_dn=${mo_dn}
    ...                                                    mo_dn1=${mo_dn1}
    ...                                                    mo_name=NRDRB_TCP_BOOST-1
    ...                                                    operation=add
    Log to Console    \n*** stop create Mo In vDU ***

Enable/Disable CB009409
    [Arguments]     ${feature_value}=disabled
    Log to Console    \n*** Enable/Disable CB009409 with ${feature_value} ***
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{parameter_dict_new}    Create Dictionary   actTcpBoostPug=${feature_value}
    &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict_new}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict_new}
	...                                          operation=replace
	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${True}
    ...                                          wait_vdu_up=${False}

Collect and Check counter M55308C00038_39_40_41_41_42
    Log To Console      \n*** Check DU Counter ***
    ${du_counter_id_list}    Create List    M55308C00038    M55308C00039    M55308C00040    M55308C00041    M55308C00042
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
        ...                                            expected_value=0
        ...                                            get_number=5
        ...                                            comparison=equal
    END