*** Settings ***
Documentation    This is for common setup and teardown keywords
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/hanging_resource.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/gnb_operations.py

*** Variables ***
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
@{ALLOWED_FAULT}    4655    4654    61652    61524    4592    7311    7300    61649
${log_path_ute}    /opt/workspace/CIT/Master/Case_Logs
@{gnb_list}    ${0}
@{Expect_FAULT}    1850
*** Keywords ***
Common Case TestLine Setup
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...           1.If${Is_Swconfig}=True,will upload swconfig for gnb
    ...           2.If${ModifySCF_Beforecommission}=True,will modify scf first,then commission
    ...           3.If${Enb_commission}=True,commission enbscf for enb
    ...           4.If${is_commission}=True, will commission gnb without modify.
    ...           5.If${ModifySCF_Aftercommission}=True, will modify or add or delete parameter online
    ...           6.If${Lock_ENB_Need}=True, will lock enb cell
    [Arguments]
    ...     ${golden_scf_name}=${None}                   ${golden_scf_name_gnb2}=None
    ...     ${swconfig_file}=${None}                     ${swconfig_file_gnb2}=None
    ...     ${swconfig_modify}=${None}                   ${swconfig_modify_gnb2}=${None}
    ...     ${Is_Swconfig}=False                         ${Is_Swconfig_for_GNB2}=False
    ...     ${reset_site}=${None}                        ${reset_site_GNB2}=${None}
    ...     ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    ...     ${swconfig_target_path_gnb2}=${epc_log_path}/gnb2/swconfig.txt
    ...     ${is_commission}=False                       ${is_commission_for_second_gnb}=False
    ...     ${ModifySCF_Beforecommission}=False          ${ModifySCF_Beforecommission_GNB2}=False
    ...     ${scf_path}=/opt/workspace/SCF/
    ...     ${scf_dir_path}=${epc_log_path}
    ...     ${is_pdl_checking_needed}=${True}
    ...     ${ParameterToDelete}='NULL'                  ${ParameterToDelete_gnb2}='NULL'
    ...     ${MOsToAdd}='NULL'                           ${MOsToAdd_gnb2}='NULL'
    ...     ${ParamterToModify}='NULL'                   ${ParamterToModify_gnb2}='NULL'
    ...     ${ListParamterToModify}='NULL'               ${ListParamterToModify_gnb2}='NULL'
    ...     ${ListToAdd}='NULL'                          ${ListToAdd_gnb2}='NULL'
    ...     ${gnb_type}='SA'                             ${gnb2_type}='SA'
    ...     ${is_x2_check_from_gnb_needed}=${False}      ${is_x2_check_from_gnb2_needed}=${False}
    ...     ${is_check_gnb_ready_needed}=${True}         ${is_check_gnb2_ready_needed}=${True}
    ...     ${connection}=GNB_OAM0                       ${connection_for_second_gnb}=GNB_OAM1
    ...     ${Enb_commission}=False                      ${Enb_commission_For_ENB2}=False
    ...     ${enb_scf}=${None}                           ${enb2_scf}=${None}
    ...     ${enb_scf_dir_path}=/opt/workspace/SCF/
    ...     ${enb_index}=${0}                            ${enb2_index}=${1}
    ...     ${ModifySCF_Aftercommission}=False           ${ModifySCF_Aftercommission_for_GNB2}=False
    ...     ${Modify_Para_Online}='NULL'                 ${Modify_Para_Online_GNB2}='NULL'
    ...     ${Delete_Mo_Online}='NULL'                   ${Delete_Mo_Online_GNB2}='NULL'
    ...     ${Delete_Para_Online}='NULL'                 ${Delete_Para_Online_GNB2}='NULL'
    ...     ${Add_Para_Online}='NULL'                    ${Add_Para_Online_GNB2}='NULL'
    ...     ${Add_Mo_Online}='NULL'                      ${Add_Mo_Online_GNB2}='NULL'
    ...     ${skip_parameter_relation_errors}=True
    ...     ${Lock_ENB_Need}=False
    ...     ${enb_dist_name}=${None}
    ...     ${enb_parameter}=${None}
    ...     ${enb_value}=${None}
#    ...     ${timeout}=15 min
    ...     ${alarm_check}='NULL'                        ${ALLOWED_FAULT}=${ALLOWED_FAULT}
    ...     ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min     ${is_pdl_checking_needed_gnb2}=${True}
    Run Keyword If    ${Enb_commission}    run keyword
    ...     Upload SCF to eNB
    ...                                    scf_file=${enb_scf}
    ...                                    tl_scf_dir_path=${enb_scf_dir_path}
    ...                                    enb_index=${enb_index}
    Run Keyword If    ${Enb_commission_For_ENB2}    run keyword
    ...     Upload SCF to eNB
    ...                                    scf_file=${enb2_scf}
    ...                                    tl_scf_dir_path=${enb_scf_dir_path}
    ...                                    enb_index=${enb2_index}
    Run Keyword If    ${Is_Swconfig}    run keyword
    ...    Upload Swconfig with modification        swconfig_template_path=${swconfig_file}
    ...                                             swconfig_target_path=${swconfig_target_path}
    ...                                             swconfig_modify=${swconfig_modify}
    ...                                             gnb_index=${0}
    ...                                             connection=${connection}
    ...                                             reset_site=${reset_site}
    Run Keyword If    ${Is_Swconfig_for_GNB2}       run keyword
    ...    Upload Swconfig with modification        swconfig_template_path=${swconfig_file_gnb2}
    ...                                             swconfig_target_path=${swconfig_target_path_gnb2}
    ...                                             swconfig_modify=${swconfig_modify_gnb2}
    ...                                             gnb_index=${1}
    ...                                             connection=${connection_for_second_gnb}
    ...                                             reset_site=${reset_site_GNB2}
    Run Keyword If    ${ModifySCF_Beforecommission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Modify SCF first then Perform Commission    scf_file_name=${golden_scf_name}
    ...                                                scf_path=${scf_path}
    ...                                                scf_dir_path=${scf_dir_path}
    ...                                                is_pdl_checking_needed= ${is_pdl_checking_needed}
    ...                                                ParameterToDelete=${ParameterToDelete}
    ...                                                MOsToAdd=${MOsToAdd}
    ...                                                ParamterToModify=${ParamterToModify}
    ...                                                ListParamterToModify=${ListParamterToModify}
    ...                                                ListToAdd=${ListToAdd}
    ...                                                gnb_type=${gnb_type}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...                                                is_check_gnb_ready_needed=${is_check_gnb_ready_needed}
    ...                                                connection=${connection}    AND
    ...    COAM Teardown gnb connections    connection=${connection}
    Run Keyword If    ${ModifySCF_Beforecommission_GNB2}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Modify SCF first then Perform Commission    scf_file_name=${golden_scf_name_gnb2}
    ...                                                scf_path=${scf_path}
    ...                                                scf_dir_path=${scf_dir_path}
    ...                                                is_pdl_checking_needed= ${is_pdl_checking_needed_gnb2}
    ...                                                ParameterToDelete=${ParameterToDelete_gnb2}
    ...                                                MOsToAdd=${MOsToAdd_gnb2}
    ...                                                ParamterToModify=${ParamterToModify_gnb2}
    ...                                                ListParamterToModify=${ListParamterToModify_gnb2}
    ...                                                ListToAdd=${ListToAdd_gnb2}
    ...                                                gnb_type=${gnb2_type}
    ...                                                gnb_index=${1}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb2_needed}
    ...                                                is_check_gnb_ready_needed=${is_check_gnb2_ready_needed}
    ...                                                connection=${connection_for_second_gnb}    AND
    ...    COAM Teardown gnb connections    connection=${connection_for_second_gnb}
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    COAM Commission with scf file    scf_file_path=${scf_path}/${golden_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}    AND
    ...    COAM Teardown gnb connections    connection=${connection}
    Run Keyword If    ${is_commission_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    COAM Commission with scf file    scf_file_path=${scf_path}/${golden_scf_name_gnb2}
    ...                                     connection=${connection_for_second_gnb}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed_gnb2}    AND
    ...    COAM Teardown gnb connections    connection=${connection_for_second_gnb}
    Run Keyword If    ${is_commission}    run keywords
    ...    COAM Wait For Gnb Ready And Cell Setup     timeout=${wait_gnb_up_timeout}
    ...                                               connection=${connection}
    ...                                               gnb_type=${gnb_type}
    ...                                               gnb_index=${0}
    ...                                               is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    AND
    ...    COAM Teardown gnb connections    connection=${connection}
    Run Keyword If    ${is_commission_for_second_gnb}    run keywords
    ...    COAM Wait For Gnb Ready And Cell Setup    timeout=${wait_gnb_up_timeout}
    ...                                                connection=${connection_for_second_gnb}
    ...                                                gnb_type=${gnb2_type}
    ...                                                gnb_index=${1}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb2_needed}    AND
    ...    COAM Teardown gnb connections    connection=${connection_for_second_gnb}
    Run Keyword If    ${ModifySCF_Aftercommission}     run keyword
    ...    Modify Parameters for Cases                 Modify_Para_Online=${Modify_Para_Online}
    ...                                                Delete_Mo_Online=${Delete_Mo_Online}
    ...                                                Delete_Para_Online=${Delete_Para_Online}
    ...                                                Add_Para_Online=${Add_Para_Online}
    ...                                                Add_Mo_Online=${Add_Mo_Online}
    ...                                                timeout=${wait_gnb_up_timeout}
    ...                                                gnb_type=${gnb_type}
    ...                                                gnb_index=${0}
    ...                                                connection=${connection}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...                                                alarm_check=${alarm_check}
    ...                                                ALLOWED_FAULT=${ALLOWED_FAULT}
    ...                                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If    ${ModifySCF_Aftercommission_for_GNB2}     run keyword
    ...    Modify Parameters for Cases                 Modify_Para_Online=${Modify_Para_Online_GNB2}
    ...                                                Delete_Mo_Online=${Delete_Mo_Online_GNB2}
    ...                                                Delete_Para_Online=${Delete_Para_Online_GNB2}
    ...                                                Add_Para_Online=${Add_Para_Online_GNB2}
    ...                                                Add_Mo_Online=${Add_Mo_Online_GNB2}
    ...                                                timeout=${wait_gnb_up_timeout}
    ...                                                gnb_type=${gnb2_type}
    ...                                                gnb_index=${1}
    ...                                                connection=${connection_for_second_gnb}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb2_needed}
    ...                                                alarm_check=${alarm_check}
    ...                                                ALLOWED_FAULT=${ALLOWED_FAULT}
    ...                                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If    ${Lock_ENB_Need}            run keyword
    ...     Connect and Modify the ENB parameter     dist_name=${enb_dist_name}
    ...                                              parameter=${enb_parameter}
    ...                                              value=${enb_value}
    ...                                              enb_index=${enb_index}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}

Common Case TestLine Setup with singe BTS
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...           1.If${Is_Swconfig}=True,will upload swconfig for gnb
    ...           2.If${ModifySCF_Beforecommission}=True,will modify scf first,then commission
    ...           3.If${Enb_commission}=True,commission enbscf for enb
    ...           4.If${is_commission}=True, will commission gnb without modify.
    ...           5.If${ModifySCF_Aftercommission}=True, will modify or add or delete parameter online
    ...           6.If${Lock_ENB_Need}=True, will lock enb cell
    [Arguments]
    ...     ${gnb_index}=${0}    ${enb_index}=${0}
    ...     ${golden_scf_name}=${None}
    ...     ${swconfig_file}=${None}    ${swconfig_modify}=${None}    ${Is_Swconfig}=False
    ...     ${is_commission}=False    ${ModifySCF_Beforecommission}=False
    ...     ${scf_path}=/opt/workspace/SCF/    ${scf_dir_path}=${epc_log_path}    ${is_pdl_checking_needed}=${True}
    ...     ${ParameterToDelete}='NULL'
    ...     ${MOsToAdd}='NULL'
    ...     ${ParamterToModify}='NULL'
    ...     ${ListParamterToModify}='NULL'
    ...     ${ListToAdd}='NULL'
    ...     ${gnb_type}='SA'
    ...     ${is_x2_check_from_gnb_needed}=${False}
    ...     ${is_check_gnb_ready_needed}=${True}
    ...     ${connection}=GNB_OAM${gnb_index}
    ...     ${Enb_commission}=False
    ...     ${enb_scf}=${None}
    ...     ${enb_scf_dir_path}=/opt/workspace/SCF/
    ...     ${ModifySCF_Aftercommission}=False
    ...     ${Modify_Para_Online}='NULL'
    ...     ${Delete_Mo_Online}='NULL'
    ...     ${Delete_Para_Online}='NULL'
    ...     ${Add_Para_Online}='NULL'
    ...     ${Add_Mo_Online}='NULL'
    ...     ${Lock_ENB_Need}=False
    ...     ${enb_dist_name}=${None}
    ...     ${enb_parameter}=${None}
    ...     ${enb_value}=${None}
#    ...     ${timeout}=15 min
    ...     ${alarm_check}='NULL'
    ...     ${timeout_for_commission}=900    ${wait_gnb_up_timeout}=20 min     ${is_pdl_checking_needed}=${True}
    ...     ${reset_site}=${None}
    Run Keyword If    ${Enb_commission}    run keyword
    ...     Upload SCF to eNB
    ...                                    scf_file=${enb_scf}
    ...                                    tl_scf_dir_path=${enb_scf_dir_path}
    ...                                    enb_index=${enb_index}
    Run Keyword If    ${Is_Swconfig}    run keyword
    ...    Upload Swconfig with modification        swconfig_template_path=${swconfig_file}
    ...                                             swconfig_modify=${swconfig_modify}
    ...                                             gnb_index=${gnb_index}
    ...                                             reset_site=${reset_site}
    Run Keyword If    ${ModifySCF_Beforecommission}    run keyword
    ...    Modify SCF first then Perform Commission    scf_file_name=${golden_scf_name}
    ...                                                scf_path=${scf_path}
    ...                                                scf_dir_path=${scf_dir_path}
    ...                                                is_pdl_checking_needed= ${is_pdl_checking_needed}
    ...                                                ParameterToDelete=${ParameterToDelete}
    ...                                                MOsToAdd=${MOsToAdd}
    ...                                                ParamterToModify=${ParamterToModify}
    ...                                                ListParamterToModify=${ListParamterToModify}
    ...                                                ListToAdd=${ListToAdd}
    ...                                                gnb_type=${gnb_type}
    ...                                                gnb_index=${gnb_index}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...                                                is_check_gnb_ready_needed=${is_check_gnb_ready_needed}
    Run Keyword If    ${is_commission}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}    AND
    ...    COAM Commission with scf file    scf_file_path=${scf_path}/${golden_scf_name}
    ...                                     connection=${connection}
    ...                                     timeout=${timeout_for_commission}
    ...                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If    ${is_commission}    run keyword
    ...    COAM Wait For Gnb Ready And Cell Setup     timeout=${wait_gnb_up_timeout}
    ...                                     gnb_type=${gnb_type}
    ...                                     gnb_index=${gnb_index}
    ...                                     is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Run Keyword If    ${ModifySCF_Aftercommission}     run keyword
    ...    Modify Parameters for Cases                 Modify_Para_Online=${Modify_Para_Online}
    ...                                                Delete_Mo_Online=${Delete_Mo_Online}
    ...                                                Delete_Para_Online=${Delete_Para_Online}
    ...                                                Add_Para_Online=${Add_Para_Online}
    ...                                                Add_Mo_Online=${Add_Mo_Online}
    ...                                                timeout=${wait_gnb_up_timeout}
    ...                                                gnb_type=${gnb_type}
    ...                                                gnb_index=${gnb_index}
    ...                                                is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...                                                alarm_check=${alarm_check}
    Run Keyword If    ${Lock_ENB_Need}            run keyword
    ...     Connect and Modify the ENB parameter     dist_name=${enb_dist_name}
    ...                                              parameter=${enb_parameter}
    ...                                              value=${enb_value}
    ...                                              enb_index=${enb_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify Parameters for Cases
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...      this keyword only support modify parameter
    ...      ${Modify_Para_Online}=[{'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'actDynUlDataSplitMode',
    ...      'value': 'true'}, {'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'pucchDataDtxNumOfSamples', 'value': '100'}]
    [Arguments]    ${Modify_Para_Online}='NULL'
    ...            ${Delete_Mo_Online}='NULL'
    ...            ${Delete_Para_Online}='NULL'
    ...            ${Add_Para_Online}='NULL'
    ...            ${Add_Mo_Online}='NULL'
    ...            ${timeout}=15 min
    ...            ${gnb_type}=SA
    ...            ${is_x2_check_from_gnb_needed}=False
    ...            ${gnb_index}=${0}
    ...            ${alarm_check}='NULL'
    ...            ${ALLOWED_FAULT}=${ALLOWED_FAULT}
    ...            ${skip_parameter_relation_errors}=True
    ...            ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    run keyword if  not ${Modify_Para_Online}=='NULL'
    ...    COAM Update Several Parameters Via Rest Api    connection=${connection}
    ...                                      parameters_to_update_via_api=${Modify_Para_Online}    timeout=${timeout}
    ...                                      skip_parameter_relation_errors=${skip_parameter_relation_errors}
    COAM Wait For Gnb Ready And Cell Setup    connection=${connection}    timeout=${timeout}    gnb_type=${gnb_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    gnb_index=${gnb_index}
    run keyword if  not ${Delete_Mo_Online}=='NULL'
    ...    COAM delete objects via rest api    connection=${connection}    objects_to_delete_via_api=${Delete_Mo_Online}    timeout=${timeout}
    run keyword if  not ${Delete_Para_Online}=='NULL'
    ...    COAM delete parameters via rest api    connection=${connection}    parameters_to_delete_via_api=${Delete_Para_Online}    timeout=${timeout}
    run keyword if  not ${Add_Para_Online}=='NULL'
    ...    COAM add several parameters via rest api    connection=${connection}    parameters_to_add_via_api=${Add_Para_Online}    timeout=${timeout}
    run keyword if  not ${Add_Mo_Online}=='NULL'
    ...    COAM add several MOs via rest api     connection=${connection}    objects_to_add_via_api=${Add_Mo_Online}    timeout=${timeout}
    COAM Wait For Gnb Ready And Cell Setup    connection=${connection}    timeout=${timeout}    gnb_type=${gnb_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    gnb_index=${gnb_index}
    run keyword if  not ${alarm_check}=='NULL'
    ...    Run Keyword And Continue On Failure    Check Unexpect Alarm whether exist    gnb_index=${gnb_index}    connection=${connection}
    ...                                                                                                        ALLOWED_FAULT=${ALLOWED_FAULT}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Upload Swconfig with modification
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...                ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                    ['0x580002=0', '0x580121=0']
    ...                ${swconfig_template_path}: swconfig file path.Should be like:/opt/workspace/swconfig/swconfig.txt
    [Arguments]    ${swconfig_template_path}    ${swconfig_modify}=${None}    ${swconfig_target_path}=${epc_log_path}/swconfig.txt
    ...    ${gnb_index}=${0}    ${du_index}=${0}    ${connection}=GNB_OAM    ${alias}=ASIK Master
#    ...    ${wait_for_reconnection}=True    ${reset_site}=${None}
    ...    ${reset_site}=${None}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${swconfig_target_path}
    Run keyword if    ${swconfig_modify}!=${None}
    ...    Run keywords    Log to console    Swconfig file modification is needed.    AND
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}
    Run keyword if    ${reset_site}!=${None}    COAM gNB Reset site and check gnb onair    gnb_index=${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

COAM gNB Reset site and check gnb onair
    [Arguments]   ${gnb_index}=${0}    ${is_need_check_cell_onair}=True    ${wait_for_reconnection}=True
    Connect to gnb coam via ssl    connection=coam_admin    gnb_index=${gnb_index}
    coam.reset_site    wait_for_reconnection=${wait_for_reconnection}    connection=coam_admin
    Run Keyword If    ${is_need_check_cell_onair}==True    run keyword
    ...    Wait Until Keyword Succeeds    15min    30sec    COAM Check GNB cell on air    connection=coam_admin
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=coam_admin

Modify SCF first then Perform Commission
    [Documentation]
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    ...              two ways can be used for commission:
    ...              '${scf_file_name}' != '${None}, commission with given ${scf_path}/${scf_file_name}
    ...              set ${scf_file_name} to ${None}, download current scf from cluster, modify it and perform commission.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]       ${scf_file_name}=${None}
    ...               ${scf_path}=/opt/workspace/SCF/
    ...               ${scf_dir_path}=${epc_log_path}
    ...               ${is_pdl_checking_needed}=${True}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ...               ${gnb_type}='SA'
    ...               ${gnb_index}=${0}
    ...               ${is_x2_check_from_gnb_needed}=${False}
    ...               ${is_check_gnb_ready_needed}=${True}
    ...               ${connection}=GNB_OAM
#    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    ${modified_scf_file_path}    Load SCF and Define modified scf path    scf_file_path=${scf_file_path}    scf_dir_path=${scf_dir_path}
    ${modified_scf_file_path}    Run keyword if    '${scf_file_name}'=='${None}'
    ...    Load Current SCF And Define modified scf path    connection=${connection}
    ...    ELSE    Load SCF and Define modified scf path    scf_file_name=${scf_file_name}    scf_path=${scf_path}
    ...    gnb_index=${gnb_index}    connection=${connection}
    run keyword if  not ${ParameterToDelete}=='NULL'     Remove object or Mo or list or element in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with the Given version
    ...                                                   parameters_lists=${MOsToAdd}
    ...                                                   gnb_index=${gnb_index}
    run keyword if  not ${ParamterToModify}=='NULL'     Add or Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements only to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists and elements to SCF     parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    Log to console    Start to modify scf files and commission, please wait...
    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=${connection}
    sleep    60s
    run keyword IF    '${is_check_gnb_ready_needed}'=='True'
    ...    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min    gnb_type=${gnb_type}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    gnb_index=${gnb_index}    connection=${connection}


Only Modify SCF before Perform Commission
    [Documentation]  Author: xiaodan.li@nokia-sbell.com
    ...              Description: This keyword can only support to modify elements parameter and list elements in scf
    ...              Element under MOs, Add if element not present
    ...              Element under List/Items match by index
    ...              two ways can be used for commission:
    ...              '${scf_file_name}' != '${None}, commission with given ${scf_path}/${scf_file_name}
    ...              set ${scf_file_name} to ${None}, download current scf from cluster, modify it and perform commission.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]       ${golden_scf_name}=${None}
    ...               ${scf_path}=/opt/workspace/SCF/
    ...               ${scf_dir_path}=${epc_log_path}
#    ...               ${is_pdl_checking_needed}=${True}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
#    ...               ${gnb_type}='SA'
    ...               ${gnb_index}=${0}
    ...               ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    ${modified_scf_file_path}    Run keyword if    '${golden_scf_name}'=='${None}'    Load Current SCF And Define modified scf path
    ...    ELSE    Load SCF and Define modified scf path    scf_file_name=${golden_scf_name}    scf_path=${scf_path}
    ...    gnb_index=${gnb_index}
    run keyword if  not ${ParameterToDelete}=='NULL'     Remove object or Mo or list or element in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with the Given version
    ...                                                   parameters_lists=${MOsToAdd}
    ...                                                   gnb_index=${gnb_index}
    run keyword if  not ${ParamterToModify}=='NULL'     Add or Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements only to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists and elements to SCF     parameters_lists=${ListToAdd}
    scf.Save scf    ${modified_scf_file_path}
    [Return]    ${modified_scf_file_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Multi-gNB commission
    [Arguments]    ${index_list}    ${scf_list}    ${skip_parameter_relation_errors}=True    ${timeout}=600
    ...    ${bts_type}=gnb    ${is_pdl_checking_needed}=True
    multi bts commission    index_list=${index_list}    scf_list=${scf_list}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    timeout=${timeout}
    ...    bts_type=${bts_type}     is_pdl_checking_needed=${is_pdl_checking_needed}

Load SCF and Define modified scf path
    [Documentation]      Description: This keyword load scf and return modified scf path for future use.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=/home/ute/SCF    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${scf_file_path}    Join Path    ${scf_path}    ${scf_file_name}
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${TS_CASE_LOG_PATH}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${scf_dir_path}    String.Replace string    ${scf_file_path}    /${scf_file_name}    ${EMPTY}
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

#    [Arguments]      ${scf_file_path}    ${scf_dir_path}=${epc_log_path}
#    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${scf_dir_path}
#    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
#    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
#    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extention}    _${timestamp}_updated.xml
#    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
#    scf.Load scf    ${default_scf_file_path}
#    [Return]    ${modified_scf_file_path}

Load Current SCF And Define modified scf path
    [Arguments]  ${connection}=GNB_OAM
    ${default_scf_file_path}    COAM Download scf from cluster   scf_dir_path=${TS_CASE_LOG_PATH}    connection=${connection}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${modified_scf_file_path}    set variable    ${TS_CASE_LOG_PATH}/${timestamp}_updated.xml
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Remove object or Mo or list or element in SCF
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

Add MOs To SCF with the Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}    ${gnb_index}=${0}    ${DRB_index}=${12}
    ${channel_version}=    scf.get_mo_attribute
    ...    MRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRDRB-${DRB_index}    version
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${channel_version}
    END

Add or Modify elements to scf
    [Documentation]    add or modify the item with p_name
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]    dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Modify ListElements only to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify only SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
    END

Modify only SCF ListElements
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
    FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
    END

AddLists and elements to SCF
    [Documentation]   add List items and elements, if the items are present, remove it first.
    ...       add_list:  B008_Add_List_22R2 = [
    ...                       dict(
    ...                       dist_name=_NRCELL2_name,
    ...                       list_name='tddFrameStructure',
    ...                       elements=dict(
    ...                       frameStructureType='semiStatic',
    ...                       guardPeriodLength='2Symbols',
    ...                       ulDlDataSlotRatio='3/7'))
    ...                       ]
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

Upload SCF to eNB
    [Arguments]    ${scf_file}    ${tl_scf_dir_path}=${enb_scf_dir_path}     ${enb_index}=${0}
    ...   ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte
    enblte.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300


Connect and Modify the ENB parameter
    [Arguments]     ${dist_name}     ${parameter}    ${value}    ${enb_index}=${0}
    Connect to eNB via ssl    enb_index=${enb_index}
    Modify the parameter on enblte    ${dist_name}     ${parameter}    ${value}
    enblte.teardown    connection=enblte

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

check hanging resource for per UE on gnb
    [Arguments]    ${gnb_ips}    ${UE_Type_Index}=${2}    ${ute_log_path}=${log_path_ute}
    ${ue_num}    get length    ${tl.ues}
#    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[${UE_Type_Index}]}    ue_index=${ue_index}
        make airplane mode to enable    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Should Be Equal    ${passed}    ${True}
    END
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}

Check hanging resource for gnb
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: check if there is hanging resource or not on gnb
    ...    para server_ip: iperf server ip
    ...    para server_name: iperf server username
    ...    para server_pwd: iperf server password
    ...    para pc_ip: control pc ip
    ...    para pc_name: control pc username
    ...    para pc_pwd: control pc password
    ...    gnb_ip: gnb_ip(type is list) '@{gnb_ips}'
    ...    ue_index: ue id
    ...    ute_log_path: log path on ute
    [Arguments]    ${gnb_ips}    ${ue_index}=${0}    ${server_ip}=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    ${server_name}=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    ${server_pwd}=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    ${pc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${pc_name}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${pc_pwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${ute_log_path}=${log_path_ute}    ${timeout}=300    ${gnb_list}=all    ${recovery_cell}=True
    modify cellBarred state of all gnb cell on testline    barred_status=barred    gnb_list=${gnb_list}
    Wait Until Keyword Succeeds    3x    10s
    ...    download_file_to_ute    server_ip=${server_ip}    server_name=${server_name}    server_pwd=${server_pwd}
    Wait Until Keyword Succeeds    3x    10s
	...    upload_file_to_pc    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}
    Wait Until Keyword Succeeds    3x    10s
    ...    execute_hanging_resource_file    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}    gnb_ip=${gnb_ips}
    [Teardown]    Run Keywords    Wait Until Keyword Succeeds    3x    10s
    ...    save_check_result_to_ute    pc_ip=${pc_ip}    pc_name=${pc_name}    pc_pwd=${pc_pwd}    ute_log_path=${ute_log_path}
    ...    timeout=${timeout}
    ...    AND    Run keyword If    '${recovery_cell}' == 'True'
    ...    modify cellBarred state of all gnb cell on testline    barred_status=notBarred    gnb_list=${gnb_list}

Check Unexpect Alarm whether exist
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${ALLOWED_FAULT}=${ALLOWED_FAULT}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    @{alarm_list}    COAM Get active alarms    connection=${connection}
    FOR    ${alarms}    IN    @{alarm_list}
       ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
       List Should Contain Value    ${ALLOWED_FAULT}    ${alarms_tmp}
    END
    [Teardown]  COAM Teardown gnb connections    connection=${connection}

get cell list on bts
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: get cell info of nr or lte or others
    ...    Return: list of cells info
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Wait Until Keyword Succeeds    1 min    20 sec
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    ${cell_list}    coam.get_cell_list    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${cell_list}

get cell dist names from cell list
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: get distname of cells
    ...    Return: list of distname
    ...    e.g. ['MRBTS-xxx/NRBTS-xxx/NRCELL-1', 'MRBTS-xxx/NRBTS-xxx/NRCELL-2']
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr
    ${cell_list}    get cell list on bts    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${cell_num}    Get Length    ${cell_list['cells']['${bts_type}']}
    ${cell_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${cell_num}
        Append To List    ${cell_dist_name_list}    ${cell_list['cells']['${bts_type}'][${index}]['id']['configuration']}
    END
    [Return]    ${cell_dist_name_list}

operate state of one cell
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: operate cell of nr or lte, Lock or Unlock
    [Arguments]    ${dist_name}    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM
    ...    ${operation}=Unlock    ${bts_type}=nr    ${timeout}=60
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    Run Keyword If    '${operation}' == 'Unlock'
    ...    coam.unlock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    ELSE IF    '${operation}' == 'Lock'
    ...    coam.lock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

operate state of all cell
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: operate all cells of nr or lte, Lock or Unlock
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${operation}=Unlock    ${bts_type}=nr
    ...    ${timeout}=60
    ${cell_dist_name_list}    get cell dist names from cell list    gnb_index=${gnb_index}    connection=${connection}
    ...    bts_type=${bts_type}    enb_index=${enb_index}
    FOR    ${item}    IN    @{cell_dist_name_list}
        operate state of one cell    dist_name=${item}    gnb_index=${gnb_index}    connection=${connection}
        ...    operation=${operation}    bts_type=${bts_type}    enb_index=${enb_index}    timeout=${timeout}
    END

operation state of all gnb cell on testline
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: operate all cells of nr or lte on whole testline, Lock or Unlock
    [Arguments]    ${connection}=GNB_OAM    ${operation}=Unlock    ${bts_type}=nr    ${timeout}=60
    ${gnb_num}    Get Length    ${tl.gnbs}
    ${enb_num}    Get Length    ${tl.enbs}
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Set Suite Variable    ${bts_num}    ${gnb_num}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Set Suite Variable    ${bts_num}    ${enb_num}
    FOR    ${i}    IN RANGE    ${bts_num}
        operate state of all cell    gnb_index=${i}    enb_index=${i}    connection=${connection}    operation=${operation}
        ...    bts_type=${bts_type}    timeout=${timeout}
    END

get required cell info
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: get required info of cell
    ...    Argument: ${required_info}: e.g. cellDepType, physicalCellId, status, id, chBwDl, nrarfcnDl, band
    ...    Return: get value of required info, retun type may String, List, Dictonary
    [Arguments]    ${required_info}    ${cell_index}    ${gnb_index}=${0}    ${enb_index}=${0}
    ...    ${connection}=GNB_OAM    ${bts_type}=nr
    ${cell_list}    get cell list on bts    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${cell_num}    Get Length    ${cell_list['cells']['${bts_type}']}
    ${cell_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${cell_num}
        Append To List    ${cell_dist_name_list}    ${cell_list['cells']['${bts_type}'][${index}]['id']['configuration']}
    END
    FOR    ${index}    ${cell}    IN ENUMERATE    @{cell_dist_name_list}
        ${cell_serch}    Split String    ${cell}    /
        Run keyword if    '${cell_serch}[-1]' == 'NRCELL-${cell_index}'
        ...    Run keywords    Set Test Variable    ${cell_index_find}    ${index}    AND    Exit For Loop
    END
    Set Test Variable    ${required_cell_info}    ${cell_list['cells']['${bts_type}'][${cell_index_find}]['${required_info}']}
    [Return]    ${required_cell_info}

get cellBarred online commission info
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: get required info of cell
    ...    Argument: ${barred_status}: notBarred, barred
    ...    Return: list of cellBarred parametets and vaues
    ...    [{'value': 'barred', 'dist_name': 'MRBTS-xxx/NRBTS-xxx/NRCELL-2', 'parameter': 'cellBarred'},
    ...    {'value': 'barred', 'dist_name': 'MRBTS-xxx/NRBTS-xxx/NRCELL-2', 'parameter': 'cellBarred'}]
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr
    ...    ${barred_status}=notBarred
    ${cell_dist_name_list}    get cell dist names from cell list    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${info_list}    Create List
    &{cell_barred}    Create Dictionary
    FOR    ${cell}    IN    @{cell_dist_name_list}
        Set To Dictionary    ${cell_barred}    value=${barred_status}    dist_name=${cell}    parameter=cellBarred
        ${cell_barred_cp}    Copy Dictionary    ${cell_barred}
        Append To List    ${info_list}    ${cell_barred_cp}
    END
    [Return]    ${info_list}

modify cellBarred state of all gnb cell on testline
    [Documentation]    ming.shi@nokia-sbell.com
    ...    Description: operate all cells cellBarred state of nr or lte on whole testline
    [Arguments]    ${connection}=GNB_OAM    ${barred_status}=notBarred    ${bts_type}=nr    ${gnb_list}=all
    ${gnb_num}    Run keyword If    '${gnb_list}' == 'all'    Get all index from list    ${tl.gnbs}
    ...    ELSE    Set Variable    ${gnb_list}
    ${enb_num}     Get all index from list    ${tl.enbs}
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Set Suite Variable    ${bts_num}    ${gnb_num}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Set Suite Variable    ${bts_num}    ${enb_num}
    FOR    ${i}    IN    @{bts_num}
        ${info_list}    get cellBarred online commission info    gnb_index=${i}    enb_index=${i}    connection=${connection}
        ...    bts_type=${bts_type}    barred_status=${barred_status}
        Run Keyword If    '${bts_type}' == 'nr'    Connect to gnb coam via ssl    gnb_index=${i}    connection=${connection}
        ...    ELSE IF    '${bts_type}' == 'lte'
        ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
        ...    name=${connection}
        COAM Update several parameters via rest api    parameters_to_update_via_api=${info_list}    timeout=${300}
        ...    connection=${connection}
        sleep    5
        COAM Teardown gnb connections    connection=${connection}
    END

Get all index from list
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get all index from list
    [Arguments]    ${list}
    ${list_indexs}    Create List
    FOR    ${index}    ${list_value}   IN ENUMERATE    @{list}
        Append To List    ${list_indexs}    ${index}
    END
    [Return]    ${list_indexs}

Check if stop run all cases
     Run Keyword If    ${SG03_all_TL}=="False"   Fatal Error    prepare testline failed!!!
     ...   ELSE    sleep    1s

get unexpect alarm stop run all TL robot
    Check if unexpect alarm

Check Everygnb unexpect alarm
    @{alarm_list}    COAM Get active alarms    connection=gnb${index}
	FOR    ${alarms}    IN    @{alarm_list}
	     ${alarms_tmp}    Convert To String    ${alarms}[alarmId]
#	     List Should Contain Value    ${Expect_FAULT}    ${alarms_tmp}
	     List Should Not Contain Value     ${Expect_FAULT}    ${alarms_tmp}
	END
	[Teardown]  Run Keywords
    ...    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Set Global Variable   ${SG03_all_TL}    True
    ...    ELSE IF    "${KEYWORD STATUS}"=="FAIL"    Set Global Variable   ${SG03_all_TL}    False     AND
    ...    COAM Teardown gnb connections    connection=gnb${index}

Check if unexpect alarm
    [Arguments]    ${gnb_list}=${gnb_list}
    FOR    ${index}    IN    @{gnb_list}
        Connect to gnb coam via ssl    connection=gnb${index}    bts_host=${tl.gnbs[${index}].cu.oam_http_connection_details.addr}
        Set Suite Variable    ${index}    ${index}
        Check Everygnb unexpect alarm
        Check if stop run all cases
	END

get required RU info
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get required info of RU
    ...    Argument: ${required_info}: e.g. cellDepType, physicalCellId, status, id, chBwDl, nrarfcnDl, band
    ...    Return: get value of required info, retun type may String, List, Dictonary
    [Arguments]    ${required_info}    ${RU_index}    ${gnb_index}=${0}    ${enb_index}=${0}
    ...    ${connection}=GNB_OAM    ${bts_type}=nr
    ${RU_list}    get RU list on bts    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${RU_num}    Get Length    ${RU_list}
    ${RU_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${RU_num}
        Append To List    ${RU_dist_name_list}    ${RU_list[${index}]['id']['configuration']}
    END
    FOR    ${index}    ${RU}    IN ENUMERATE    @{RU_dist_name_list}
        ${RU_search}    Split String    ${RU}    /
        Run keyword if    '${RU_search}[-1]' == 'RMOD-${RU_index}'
        ...    Run keywords    Set Suite Variable    ${RU_index_find}    ${index}    AND    Exit For Loop
    END
    Set Suite Variable    ${required_RU_info}    ${RU_list[${RU_index_find}]['status']['${required_info}']}
    [Return]    ${required_RU_info}

get RU list on bts
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get cell info of nr or lte or others
    ...    Return: list of cells info
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr    ${timeout}=900
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Wait Until Keyword Succeeds    1 min    20 sec
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${list_RUs}
