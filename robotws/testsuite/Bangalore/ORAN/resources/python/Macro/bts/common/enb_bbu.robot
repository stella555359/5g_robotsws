*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.bbu.EnbBbu    WITH NAME      enbbbu



*** Keywords ***
Get eNB Sw Version
    [Arguments]    ${enb_id}=0  ${du_id}=${0}
    [Documentation]    Get current software version provided by M-Plane
    ...    :param enb_id:    ENB id - releated to test line configuration
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbbbu.get_bts_sw_version    bts_id=${enb_id}  du_id=${du_id}

Reset eNB
    [Arguments]    ${enb_id}=0  ${wait_for_reconnection}=True  ${du_id}=${0}
    [Documentation]    Reset eNB and wait for reconnection.
    ...    :param enb_id:    ENB id - releated to test line configuration.
    ...    :param wait_for_reconnection:   flag which define if admin api will wait for reconnection to bts.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbbbu.reset_bts    bts_id=${enb_id}    wait_for_reconnection=${wait_for_reconnection}  du_id=${du_id}

Verify eNB is onAir
    [Arguments]    ${enb_id}=0  ${du_id}=${0}
    [Documentation]    Verify if eNB is in OnAir state.
    ...     :param enb_id:    ID of eNB, default set to 0
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbbbu.verify_bts_is_onair   bts_id=${enb_id}  du_id=${du_id}

Verify eNB Configuration Parameters Have Expected Values
    [Arguments]    ${param_dict}    ${enb_id}=${0}  ${du_id}=${0}
    [Documentation]  Verify that given parameters have given values.
    ...    :param param_dict:    dictionary where the main key is a distNames of the managedObject
    ...                          where given parameters are located and the value is dictionary
    ...                          with parameters and their expected values, e.g.
    ...                              {  distName1: {
    ...                                   param1: expected_value1,
    ...                                   param2: expected_value2
    ...                              },
    ...                                 distName2: {
    ...                                   param1: expected_value1,
    ...                                   param2: expected_value2
    ...                                 }
    ...                             }
    ...    :param enb_id:       ENB id - releated to test line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbbbu.verify_configuration_parameters_values    param_dict=${param_dict}    bts_id=${enb_id}  du_id=${du_id}

Verify eNB Has Hanging Resources
    [Arguments]    ${enb_id}=0  ${raise_exception}=False  ${du_id}=${0}
    [Documentation]    Verify eNB Hanging Resources.
    ...    :param enb_id:    ENB id - releated to test line configuration.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...    :param raise_exception:   If set to True - raise HangingResourcesDetected exception. Otherwise log warning.

    enbbbu.verify_hanging_resources    enb_id=${enb_id}    raise_exception=${raise_exception}  du_id=${du_id}
