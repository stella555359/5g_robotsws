*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.scf.EnbScf    WITH NAME      enbscf



*** Keywords ***
Perform Full Commissioning on eNB
    [Arguments]  ${scf_file}    ${enb_id}=${0}    ${skip_parameter_relation_errors}=${False}    ${timeout}=${300}
    ...    ${should_activate}=${True}    ${du_id}=${0}

    [Documentation]    Perform Full eNB commissioning.
    ...     :param scf_file:                          path to the scf file
    ...     :param enb_id:                            eNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param skip_parameter_relation_errors:    skip parameter relation errors
    ...     :param timeout:                           timeout for the operation. It is based on observed test times
    ...     :param should_activate:                   if True it should automatically activate plan
    enbscf.perform_bts_full_commissioning    scf_file=${scf_file}    bts_id=${enb_id}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    du_id=${du_id}

Perform Delta Commissioning On eNB
    [Arguments]    ${delta}    ${skip_parameter_relation_errors}=${false}    ${should_activate}=${true}    ${enb_id}=0
    ...    ${timeout}=${300}    ${du_id}=${0}
    [Documentation]     Perform commissioning using given delta.
    ...     :param delta:     list of parameters to update. Sample delta:
    ...                         delta = [{
    ...                                 'distName': dist_name,
    ...                                 'operation': 'update',
    ...                                 'parameters': [{
    ...                                             'operation': operation,
    ...                                             'parameterName': parameter,
    ...                                             'value': value}]}]
    ...                         where:
    ...                         dist_name: Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0"
    ...                         parameter: Parameter name ie. "ipAddrPrim"
    ...                         operation: Parameter operation (update or delete)
    ...                         value: Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
    ...     :param enb_id:     ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:    Timeout for the operation
    ...     :param skip_parameter_relation_errors:    if True then skip parameter relation errors, default False
    ...     :param should_activate:    if True activate plan automatically
    enbscf.perform_bts_delta_commissioning    delta=${delta}    bts_id=${enb_id}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    du_id=${du_id}

Perform Configuration Parameter Recommissioning On eNB
    [Arguments]   ${dist_name}    ${param_name}    ${param_value}    ${operation}=update    ${enb_id}=0
    ...    ${skip_parameter_relation_errors}=${false}    ${should_activate}=${true}    ${timeout}=${60}    ${du_id}=${0}
    [Documentation]    Perform recommissioning of specified configuration parameter on bts.
    ...     :param dist_name:    object dist name ie. "MRBTS-{}/LNBTS-{}/LNMME-0"
    ...     :param parameter:    parameter name ie. "ipAddrPrim"
    ...     :param operation:    parameter operation (update or delete)
    ...     :param value:        parameter value ie. "locked" or "unlocked"
    ...     :param enb_id:       eNB id - related to Test Line configuration, default 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param skip_parameter_relation_errors:     If True then skip parameter relation errors, default False
    ...     :param should_activate:                    If True activate plan automatically, default True
    ...     :param timeout:                            Time to wait for positive procedure result, default 60
    enbscf.perform_configuration_parameter_recommissioning    dist_name=${dist_name}    parameter=${param_name}
    ...    value=${param_value}    operation=${operation}    bts_id=${enb_id}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    du_id=${du_id}

Verify validation error active on eNB
    [Arguments]    ${enb_id}=0    ${du_id}=${0}
    [Documentation]    Verify that validation error is active on current SCF
    ...     :param enb_id:    ID of eNB, default set to 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbscf.verify_validation_error_active    bts_id=${enb_id}    du_id=${du_id}

Verify Configuration Rejection on eNB
    [Arguments]  ${scf_file}    ${enb_id}=${0}    ${skip_parameter_relation_errors}=${false}    ${timeout}=${60}
    ...    ${should_activate}=${false}    ${du_id}=${0}
    [Documentation]    Verify if given configuration was rejected
    ...     :param scf_file:                          path to the scf file
    ...     :param enb_id:                            eNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param skip_parameter_relation_errors:    skip parameter relation errors
    ...     :param timeout:                           timeout for the operation. It is based on observed test times
    ...     :param should_activate:                   if True it should automatically activate plan
    enbscf.verify_configuration_rejection    scf_file=${scf_file}    bts_id=${enb_id}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...    du_id=${du_id}
