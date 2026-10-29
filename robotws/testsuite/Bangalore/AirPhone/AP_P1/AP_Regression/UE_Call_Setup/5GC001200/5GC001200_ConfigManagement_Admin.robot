*** Settings ***
Documentation    This file contains 5GC001200 config management admin keywords

Library     Collections
Library     ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library     ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper

*** Variables ***
${START_NRDRB_INDEX}       1
${END_NRDRB_INDEX}         15
${RLO_SINR_THRESHOLD}      299    # Max value of this param: rloSinrThreshold is 29.9 in GNB

*** Keywords ***
Enable Dynamic UL Data Split Mode Feature Flag in GNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    actDynUlDataSplitMode=true
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Enable Radio Link Detection in GNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRBTS_DISTNAME}    actGnbInitRlf=true
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Configure Primary Path and Data Split Threshold in GNB
    [Arguments]    ${primary_path}    ${data_split_threshold}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${ul_primary_path}    Set Variable IF    "${primary_path}" == "NR"    ulOverNr    ulOverLteNr_PrimaryPathOverNr
    Update Primary Path in all NRDRB Object    ul_primary_path=${ul_primary_path}
    ...    data_split_threshold=${data_split_threshold}

Update Primary Path in all NRDRB Object
    [Arguments]    ${ul_primary_path}    ${data_split_threshold}
    Set Primary Path in NRDRB Objects    ${ul_primary_path}    ${data_split_threshold}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Configure Measurement Thresholds in GNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${threshold_dict}    Create Dictionary
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    rloDtxRatioThreshold=1    rloPathLossThreshold=85
    ...     rloSinrThreshold=${RLO_SINR_THRESHOLD}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Configure DTX Parameters in GNB
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    rloConsecDtxThreshold=1
    ...    puschDataDtxNumOfSamples=100    pucchDataDtxNumOfSamples=100    rlResumePathLossThreshold=83
    ...    rlResumeSinrThreshold=30    rlResumeBackOffTmr=2000
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get Dynamic UL Data Split Mode Parameter From GNB
    ${dynamic_ul_data_splitmode_list}    Create List    actDynUlDataSplitMode
    ${scf_path}    admin_helper.download current scf file
    ${dynamic_ul_data_splitmode_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}
    ...    ${dynamic_ul_data_splitmode_list}    ${NRCELL_DISTNAME}
    [Return]    ${dynamic_ul_data_splitmode_dict}

Get Radio Link Detection Parameter From GNB
    ${radio_link_detection_list}    Create List    actGnbInitRlf
    ${scf_path}    admin_helper.download current scf file
    ${radio_link_detection_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}
    ...    ${radio_link_detection_list}    ${NRBTS_DISTNAME}
    [Return]    ${radio_link_detection_dict}

Update Dynamic UL Data Split Mode Parameter in gNB
    [Arguments]    ${dynamic_ul_data_splitmode_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    &{dynamic_ul_data_splitmode_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Update Radio Link Detection Parameter in gNB
    [Arguments]    ${original_radio_link_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRBTS_DISTNAME}    &{original_radio_link_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get Primary Path and Data Split Threshold From GNB
    ${nrdrb_object_dict}    Create Dictionary
    ${scf_path}    admin_helper.download current scf file
    ${prim_path_data_splt_list}    Create List    ulDataPath    ulDataSplitThreshold
    Fetch nrdrb object params    ${scf_path}    ${nrdrb_object_dict}    ${prim_path_data_splt_list}
    [Return]    ${nrdrb_object_dict}

Update Primary Path and Data Split Threshold in gNB
    [Arguments]    ${nrdrb_object_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update nrdrb object params    ${nrdrb_object_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get Measurement Threshold Parameters From GNB
    ${threshold_param_list}    Create List    rloDtxRatioThreshold    rloPathLossThreshold
    ...    rloSinrThreshold
    ${scf_path}    admin_helper.download current scf file
    ${threshold_param_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}
    ...    ${threshold_param_list}    ${NRCELL_DISTNAME}
    [Return]    ${threshold_param_dict}

Update Measurement Threshold Parameters in gNB
    [Arguments]    ${threshold_param_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    &{threshold_param_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Get DTX Parameters From GNB
    ${dtx_params_list}    Create List    rloConsecDtxThreshold    puschDataDtxNumOfSamples
    ...    pucchDataDtxNumOfSamples    rlResumeBackOffTmr
    ${scf_path}    admin_helper.download current scf file
    ${dtx_params_dict}    scf_helper.get_feature_paramters_from_scf    ${scf_path}
    ...    ${dtx_params_list}    ${NRCELL_DISTNAME}
    [Return]    ${dtx_params_dict}

Update DTX Parameters in gNB
    [Arguments]    ${dtx_param_args}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Update Delta Parameter    distname=${NRCELL_DISTNAME}    &{dtx_param_args}
    ${delta_store}    Collect Delta Store
    Recommission with Updated Parameters    delta_json=${delta_store}    should_activate=${True}

Fetch nrdrb object params
    [Arguments]    ${scf_path}    ${nrdrb_object_dict}    ${prim_path_data_splt_list}
    FOR    ${index}    IN RANGE    ${START_NRDRB_INDEX}    ${END_NRDRB_INDEX}
        ${params_dict}    scf_helper.get_feature_paramters_from_scf    scf_path=${scf_path}
        ...    feature_params=${prim_path_data_splt_list}    distname=${NRBTS_DISTNAME}/NRDRB-${index}
        ...    listname=nsaDrbParam
        Set To Dictionary    ${nrdrb_object_dict}    NRDRB_${index}=${params_dict}
    END

Update nrdrb object params
    [Arguments]    ${nrdrb_object_args}
    FOR    ${index}    IN RANGE    ${START_NRDRB_INDEX}    ${END_NRDRB_INDEX}
        ${prim_path_data_splt_dict}    Get From Dictionary    ${nrdrb_object_args}    NRDRB_${index}
        Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-${index}
        ...    ulDataPath=${prim_path_data_splt_dict['ulDataPath']}    ulDataSplitThreshold=${prim_path_data_splt_dict['ulDataSplitThreshold']}
    END

Set Primary Path in NRDRB Objects
    [Arguments]    ${ul_primary_path}    ${data_split_threshold}
    FOR    ${index}    IN RANGE    ${START_NRDRB_INDEX}    ${END_NRDRB_INDEX}
        Update NRDRB profile    dist_name=${NRBTS_DISTNAME}/NRDRB-${index}
        ...    ulDataPath=${ul_primary_path}    ulDataSplitThreshold=${data_split_threshold}
    END
