*** Settings ***
Documentation
...  authors: Mateusz Bugaj, Pawel Grabania
...  contact: mateusz.bugaj@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Library      taf.rfrl.utilities.logger.custom_logger                                           WITH NAME    logger
Library      taf.rfrl.bts.operations                                                           WITH NAME    operations
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.recommissioning.recommissioning    WITH NAME    local_recomm
Variables    testsuite/Krakow/resources/RAN_VRF_KRK5/python/recommissioning/recommissioning_variables.py


*** Keywords ***
Verify that current parameter value is different from planned one
    [Arguments]    ${param_dict}    ${bts_id}=${0}    ${du_id}=${0}

    ${msg}=    Run Keyword And Expect Error    *
    ...    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_dict}    gnb_id=${bts_id}
    ...                                                                du_id=${du_id}
    Should Contain Any    ${msg}    IncorrectParameterValue:    DataNotAvailable:


Verify that incorrect parameter value rise error
    [Arguments]    ${dist_name}    ${param_name}    ${incorrect_value}    ${fault_type}    ${bts_id}=${0}

    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to incorrect value: ${incorrect_value}
    ...                           log_hierarchy=${4}
    ${msg}=    Run Keyword And Expect Error    AdminApiProcedureFailureException*
    ...    Perform Configuration Parameter Recommissioning On gNB
    ...        dist_name=${dist_name}
    ...        param_name=${param_name}
    ...        param_value=${incorrect_value}
    ...        operation=update
    ...        gnb_id=${bts_id}
    ...        skip_parameter_relation_errors=${True}
    ...        should_activate=${True}
    ...        timeout=${120}
    Should Contain    ${msg}    ${fault_type}


Change BTS parameter
    [Arguments]    ${dist_name}    ${param_name}    ${correct_value}    ${incorrect_value}    ${fault_type}
    ...            ${bts_id}=${0}    ${du_id}=${0}

    ${param_to_verify} =    Create Dictionary    ${param_name}=${correct_value}
    ${param_dict} =    Create Dictionary    ${dist_name}=${param_to_verify}

    Run Keyword And Continue On Failure
    ...    Verify that current parameter value is different from planned one    param_dict=${param_dict}
    ...                                                                         bts_id=${bts_id}    du_id=${du_id}

    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to correct value: ${correct_value}.
    ...                           log_hierarchy=${4}
    Run Keyword And Continue On Failure
    ...    Perform Configuration Parameter Recommissioning On gNB    dist_name=${dist_name}    param_name=${param_name}
    ...                                                              param_value=${correct_value}    operation=update
    ...                                                              gnb_id=${bts_id}    skip_parameter_relation_errors=${True}
    ...                                                              should_activate=${True}    timeout=${300}

    operations.wait_until_bts_is_up_and_on_air    bts_id=${bts_id}    timeout=${600}

    Run Keyword And Continue On Failure
    ...    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_dict}    gnb_id=${bts_id}
    ...                                                                du_id=${du_id}

    Run Keyword And Continue On Failure
    ...    Verify that incorrect parameter value rise error    dist_name=${dist_name}    param_name=${param_name}
    ...                                                        incorrect_value=${incorrect_value}    fault_type=${fault_type}
    ...                                                        bts_id=${bts_id}

    Run Keyword And Continue On Failure
    ...    Verify gNB Configuration Parameters Have Expected Values    param_dict=${param_dict}    gnb_id=${bts_id}
    ...                                                                du_id=${du_id}


Change parameters for specific RAT
    [Arguments]    ${rat}    ${cell_id}    ${parameters_to_change}    ${bts_id}=${0}    ${du_id}=${0}
    FOR    ${param_to_change}    IN    @{parameters_to_change}[${rat}]
        ${param_name}           Set Variable    ${param_to_change}[param_name]
        ${dist_name}            Set Variable    ${param_to_change}[dist_name]
        ${correct_value}        Set Variable    ${param_to_change}[correct_value]
        ${incorrect_value}      Set Variable    ${param_to_change}[incorrect_value]
        ${mod_type}             Set Variable    ${param_to_change}[mod_type]
        ${fault_type}           Set Variable    ${param_to_change}[fault_type]
        ${dist_name}    local_recomm.adjust_dist_name    dist_name=${dist_name}    bts_id=${bts_id}    du_id=${du_id}
        ...                                              cell_id=${cell_id}
        logger.log_info_to_console    msg=Modyfication type: ${mod_type}    log_hierarchy=${3}
        Change BTS parameter
            ...   dist_name=${dist_name}
            ...   param_name=${param_name}
            ...   correct_value=${correct_value}
            ...   incorrect_value=${incorrect_value}
            ...   fault_type=${fault_type}
            ...   bts_id=${bts_id}
            ...   du_id=${du_id}
    END


Perform Bts recommissoning
    [Arguments]     ${nrcell_id}=${None}    ${lncel_id}=${None}    ${parameters_to_change}=${None}    ${bts_id}=${0}
    ...             ${du_id}=${0}
    [Documentation]    Main keyword which change different bts parameters to cover all modification types (Bts reset,
    ...                RAT reset, Conditional BTS restart, Online, Object locking), both for NR and LTE.
    ...    param nrcell_id: NR cell id for which some parameters would be modified, if NR part needs to be covered
    ...    param lncel_id: LTE cell id for which some parameters would be modified, if LTE part needs to be covered
    ...    param parameters_to_change: dictionary with parameters to be changed, if not provided DEFAULT_PARAMETERS_FOR_RECOMM
    ...                                would be used, example of dictionary located in
    ...                                testsuite/Krakow/resources/RAN_VRF_KRK5/examples/recommissioning/recommissioning_variables.py
    ...    param bts_id: BTS id, releated to test line configuration

    ${scfs_files}=    operations.download_bts_configuration    bts_id=${bts_id}
    logger.log_info_to_console    BTS configuration saved ${scfs_files}    log_hierarchy=${2}
    ${parameters_to_change}=    Set Variable If    "${parameters_to_change}"=="${None}"    ${DEFAULT_PARAMETERS_FOR_RECOMM}
    ...    ${parameters_to_change}
    logger.log_info_to_console    ${parameters_to_change}
    Run Keyword If    '${nrcell_id}'!='${None}'
    ...    Change parameters for specific RAT    rat=NR    cell_id=${nrcell_id}    parameters_to_change=${parameters_to_change}
    ...                                          bts_id=${bts_id}    du_id=${du_id}
    Run Keyword If    '${lncel_id}'!='${None}'
    ...    Change parameters for specific RAT    rat=LTE    cell_id=${lncel_id}    parameters_to_change=${parameters_to_change}
    ...                                          bts_id=${bts_id}    du_id=${du_id}
    logger.log_info_to_console    Restore BTS configuration ${scfs_files}    log_hierarchy=${2}
    ${asir_scf}    Set Variable If    'ASIR' in ${scfs_files}   ${scfs_files}[ASIR]    ${None}
    operations.perform_bts_commissioning    bts_id=${bts_id}    scf_path=${scfs_files}[BTS]
    ...                                     asir_scf_path=${asir_scf}
    ...                                     commissioning_timeout=${400}
    ...                                     asir_commissioning_timeout=${120}
    ...                                     wait_for_on_air_timeout=${600}
    ...                                     delay_for_checking_on_air=${30}
