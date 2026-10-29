*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.ru.EnbRu    WITH NAME      enbru



*** Keywords ***
Reset eNB Radio Unit
    [Arguments]     ${enb_id}=0    ${radio_unit_id}=1    ${du_id}=${0}    ${confirm}=${True}
    [Documentation]    Reset radio unit with specified number from eNB side.
    ...     :param radio_unit_id:  number of radio unit
    ...     :param enb_id:         ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
     ...    :param confirm: if true set value will be checked afterwards and if it is not set the exception is raised
    enbru.reset_radio_unit    bts_id=${enb_id}    radio_unit_id=${radio_unit_id}    du_id=${du_id}    confirm=${confirm}
