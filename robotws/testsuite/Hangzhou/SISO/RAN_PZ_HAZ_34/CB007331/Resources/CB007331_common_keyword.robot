*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter
Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis.ScfAnalysis    WITH NAME    scfas
Library       testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
*** Variables ***

*** Keywords ***
Reconfiguration of wide NR carrier bandwidth from 20 to 40 to 60 to 20MHz
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    Admin Perform Delta Recommissioning    chbw=20
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=true
    ...                                    size=48
    ...                                    numOfPdcchCandidatesInAL4=n2
    ...                                    legacyWideCarrierMode=false
    Check All Components Status            operation_component=site
    ...                                    gnb_type=${gNb_CuType}
    Admin Perform Delta Recommissioning    chbw=40
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=true
    ...                                    size=96
    ...                                    numOfPdcchCandidatesInAL4=n2
    ...                                    legacyWideCarrierMode=true
    Check All Components Status            operation_component=site
    ...                                    gnb_type=${gNb_CuType}
    Admin Perform Delta Recommissioning    chbw=60
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=false
    ...                                    size=162
    ...                                    numOfPdcchCandidatesInAL4=n5
    ...                                    legacyWideCarrierMode=true
    Check All Components Status            operation_component=site
    ...                                    gnb_type=${gNb_CuType}
    Admin Perform Delta Recommissioning    chbw=20
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=true
    ...                                    size=48
    ...                                    numOfPdcchCandidatesInAL4=n2
    ...                                    legacyWideCarrierMode=false
    Check All Components Status            operation_component=site
    ...                                    gnb_type=${gNb_CuType}

Reconfiguration of wide NR carrier bandwidth from 20 to 60MHz and check alarm 4044
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    Admin Perform Delta Recommissioning    chbw=20
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=true
    ...                                    size=48
    ...                                    numOfPdcchCandidatesInAL4=n2
    ...                                    legacyWideCarrierMode=false
    Check All Components Status            operation_component=site
    ...                                    gnb_type=${gNb_CuType}
    Admin Perform Delta Recommissioning    chbw=60
    ...                                    msg1FrequencyStart=13
    ...                                    actDownSampling=false
    ...                                    size=162
    ...                                    numOfPdcchCandidatesInAL4=n5
    ...                                    legacyWideCarrierMode=true
    Wait For Expect Fault Present          faultId=${4044}
    ...                                    timeout=600
    [Teardown]    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}

Generate Admin Modify Params
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${chbw}=20    ${msg1FrequencyStart}=13    ${actDownSampling}=true    ${size}=48
    ...    ${numOfPdcchCandidatesInAL4}=n2    ${legacyWideCarrierMode}=false
    ...    ${connection}=GNB_OAM    ${modify_params}=@{EMPTY}
    log to console    \nAdmin Perform Delta Recommissioning to ${chbw}MHz
    ${cell_dist_name}    set variable   MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ${new_item}    create dictionary    dist_name=${cell_dist_name}
    ...    parameter=chBw    value=${chbw}MHz
    append to list    ${modify_params}    ${new_item}
    ${new_item}    create dictionary    dist_name=${cell_dist_name}
    ...    parameter=msg1FrequencyStart    value=${msg1FrequencyStart}
    append to list    ${modify_params}    ${new_item}
    ${new_item}    create dictionary    dist_name=${cell_dist_name}
    ...    parameter=actDownSampling    value=${actDownSampling}
    append to list    ${modify_params}    ${new_item}
    ${stream}    get stream from version    ${Active_SW_version}
    ${scf_file_path}    COAM Download scf from cluster    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    scfas.setup    scf_path=${scf_file_path}
    ${dedicated_bwp}    scfas.get_bwpDN_from_scf    cell_id=${cell_id}    index=${1}
    ${dedicated_bwp_distname}    set variable    ${dedicated_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ${size_dict}    create dictionary    size=${size}
    ${size_list}    create list    ${size_dict}
    ${new_item}    create dictionary    dist_name=${dedicated_bwp_distname}
    ...    parameter=coresetDedicated    value=${size_list}
    append to list    ${modify_params}    ${new_item}
    ${numOfPdcchCandidatesInAL4_dict_1}    create dictionary    numOfPdcchCandidatesInAL4=n2
    ${numOfPdcchCandidatesInAL4_dict_2}    create dictionary    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4}
    ${numOfPdcchCandidatesInAL4_list}    create list    ${numOfPdcchCandidatesInAL4_dict_1}    ${numOfPdcchCandidatesInAL4_dict_2}
    ${new_item}    create dictionary    dist_name=${dedicated_bwp_distname}
    ...    parameter=searchSpaceDedicated    value=${numOfPdcchCandidatesInAL4_list}
    append to list    ${modify_params}    ${new_item}
    ${ru_index}    get_ru_index_from_cell_id_via_admin    cell_id=${cell_id}    connection=${connection}
    ${ru_dist_name}    set variable   MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ${new_item}    create dictionary    dist_name=${ru_dist_name}
    ...    parameter=legacyWideCarrierMode    value=${legacyWideCarrierMode}
    append to list    ${modify_params}    ${new_item}
    [Return]     ${modify_params}

Admin Perform Delta Recommissioning
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${chbw}=20    ${msg1FrequencyStart}=13    ${actDownSampling}=true    ${size}=48
    ...    ${numOfPdcchCandidatesInAL4}=n2    ${legacyWideCarrierMode}=false
    ...    ${connection}=GNB_OAM
    ${cell_list}    get all cell id via admin    connection=${connection}
    ${modify_params}    create list
    FOR    ${cell_id}    IN    @{cell_list}
        ${modify_params}    Generate Admin Modify Params    cell_id=${cell_id}
        ...    chbw=${chbw}    msg1FrequencyStart=${msg1FrequencyStart}
        ...    actDownSampling=${actDownSampling}    size=${size}
        ...    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4}    legacyWideCarrierMode=${legacyWideCarrierMode}
        ...    connection=${connection}    modify_params=${modify_params}
    END
    ${delta_file}     coam_parameter.create_update_parameters_delta    parameters=${modify_params}    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['updated']}    connection=${connection}    timeout=360s
