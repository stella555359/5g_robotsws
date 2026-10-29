*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:lei.jia@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009235/Resources/TestCaseVariables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/CB008360_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Library    taf.config.scf    WITH NAME    scf

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
9235 Suite Setup
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]      ${is_need_to_kill_mcs}=${True}    ${ue_index}=${0}
    ...              ${connection}=GNB_OAM
    ...              ${ues_index}=${${0}}    ${is_do_ue_prepare}=${False}    ${is_concurrent_enb_poweroff}=${True}
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    Get SCF File Path
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable     ${stream}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Run Keyword If    ${is_concurrent_enb_poweroff}    Power Off eNB
    Modify Parameter For CB009235 And Wait Onair
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    Run keyword if    ${is_need_to_kill_mcs}    Wait Until Keyword Succeeds    3 min    30 sec
    ...    Mcs.Kill mcs process    ue_index=${ue_index}
    Run Keyword If    ${is_do_ue_prepare}    Run Keyword And Ignore Error    Clear Temp File Of ELT For MTK
    Run Keyword If    ${is_do_ue_prepare}    Get Ue Type for UES    ues_index=${ues_index}
    Run Keyword If    ${is_do_ue_prepare}    UE Prepare for UES    ues_index=${ues_index}

Suite TearDown For 9235
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    robot_common_operations.Common Suite Teardown
    Log To Console    \n***start to recover gNB and pwoer on eNB***
    Power On eNB
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${scf_file_full_name}    set variable    Configuration_IWK_${stream}.xml
    ${scf_file_full_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    ${recover_scf_file_full_path}    set variable if    'SBTS00' in '${stream}'    ${scf_file_full_path}    ${Golden_SCF_Path}
    COAM Commission with scf file    scf_file_path=${recover_scf_file_full_path}    timeout=600
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Run Keyword And Ignore Error    COAM Teardown gnb connections

9235 Case SetUp
    [Documentation]   Author:xiaoxia.hao@nokia-sbell.com
    ...                 for 8360-A NSA call, keep all NR cell barred
    [Arguments]    ${pcell_index}=3    ${ues_index}=${${1},${2},${3},${4}}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Connect to Capacity Unit Master
    Connect to Capacity Unit Slave
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Create log directory
    Get Ue Type for UES    ues_index=${ues_index}
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_index}    timeout=${180}
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=notBarred
    Wait Gnb Ready And Cell On Air

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${gnb_connection}=ASIK Master
    [Documentation]    Author:xiaoxia.hao@nokia.com
    ...
    ...    Owner:yangyang.zhou@nokia-sbell.com
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${gnb_connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
    sleep    30

Modify Parameter For CB009235 And Wait Onair
    [Documentation]   Author: xiaoxia.hao@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    [Arguments]       ${scf_file_name}=SCF_${stream}_CB009235
    ...               ${is_pdl_checking_needed}=${True}
    ...               ${connection}=GNB_OAM
    ...               ${wait_gnb_up_timeout}=15 min
#    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_file_name=${scf_file_name}
#    Add and Modify elements to scf    parameters_lists=${PARAMS_TO_MODIFY_FOR_9235}
#    scf.Save scf    ${modified_scf_file_path}
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file_full_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    COAM Commission with scf file
    ...                                              scf_file_path=${scf_file_full_path}
    ...                                              connection=${connection}
    ...                                              timeout=${wait_gnb_up_timeout}
    ...                                              is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait Gnb Ready And Cell On Air    timeout=${wait_gnb_up_timeout}

Add and Modify elements to scf
    [Documentation]   Author: xiaoxia.hao@nokia-sbell.com
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

#Get SCF File Path
#    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
#    ${scf_full_path}    Get Variable Value    ${scf_full_path}
#    return from keyword if    '${scf_full_path}' != 'None'
#    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
#    ${testline_name}  Get Variable Value    ${testline_name}
#    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
#    ${pattern}   Set Variable    7_5(.*)
#    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
#    ${testlinename}   Set Variable    7_5@{TLNAME}[0]
#    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename}

Load SCF and Define modified scf path
    [Documentation]   Author: xiaoxia.hao@nokia-sbell.com
    ...              Description: This keyword load scf and return modified scf path for future use.
    [Arguments]      ${scf_file_name}=${None}
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Get SCF File Path
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file_full_path}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    ${default_scf_file_path}    Copy file    source=${scf_file_full_path}    destination=${SAVE LOG DIRECTORY}
    ${file_name_without_extention}    Fetch from right    ${default_scf_file_path}    /
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${SAVE LOG DIRECTORY}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Set MCS Phase For NSA 4UE PAIRED
    [Documentation]   Author:xiaoxia.hao@nokia-sbell.com
#    ${mcs_type}    mcs_common.Get MCS Type
#    Set Test Variable    ${mcs_type}
#    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=2600_1_ALL
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
#    ...    first_beam_horizontal_angle=${-55}    second_beam_horizontal_angle=${-40}    vertical_angle=${-6}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#   ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
##    Mcs.Set Phases And Attenuations For TOPYONG MCS    att_value=8
##    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
##    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
##    ...    first_beam_horizontal_angle=${-55}    second_beam_horizontal_angle=${-40}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
#    ...    first_beam_horizontal_angle=${55}    second_beam_horizontal_angle=${40}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
#    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
#    ...    first_beam_horizontal_angle=${-25}    second_beam_horizontal_angle=${-10}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
#    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
#    ...    first_beam_horizontal_angle=${25}    second_beam_horizontal_angle=${10}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ${mcs_type}    mcs_common.Get MCS Type
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=2600_1_ALL
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-45}    second_beam_horizontal_angle=${-52}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${20}    second_beam_horizontal_angle=${25}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}

Check Mustatus And NumberofCorrCalcDuringSelectUes on TTI
    [Arguments]    ${ttitrace_file}
    Log To Console    \ncheck Mustatus And NumberofCorrCalcDuringSelectUes
    ${mupair}    ${numberOfCorrCalcDuringSelectUes_percent}    calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes
    ...                                                                                                       file_path=${ttitrace_file}
    run keyword and continue on failure    Should Be True    ${mupair}>0
    run keyword and continue on failure    Should Be True    ${numberOfCorrCalcDuringSelectUes_percent}<1

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error       csn.reset_cache
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Check Mustatus Contain NOPAIR_LITTLEDATANOTNEEDPAIR on TTI
    [Arguments]    ${ttitrace_file}
    ${no_pair_littledatanotneedpair}    calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter    file_path=${ttitrace_file}
    run keyword and continue on failure    Should Be True    ${no_pair_littledatanotneedpair}>0

Check Mustatus Not Contain NOPAIR_LITTLEDATANOTNEEDPAIR And Contain MUPAIR on TTI
    [Arguments]    ${ttitrace_file}
    Log To Console    \nMustatus Not Contain NOPAIR_LITTLEDATANOTNEEDPAIR And Contain MUPAIR on TTI
    ${no_pair_littledatanotneedpair}    calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter    file_path=${ttitrace_file}
    run keyword and continue on failure    Should Be True    ${no_pair_littledatanotneedpair}<1
    ${mupair}    ${muStatus_value_count}    calculate_dl_muStatus_mupair_Counter    file_path=${ttitrace_file}
    run keyword and continue on failure    Should Be True    ${mupair}>1
