*** Settings ***
Documentation    This is common keywords for siso related cases used in team
...              Please do not modify the file without notification to author

Resource   e2e_common_KW.robot

*** Variables ***

*** Keywords ***
E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex
    [Documentation]
    ...    *****************
    ...    operate RU lock and unlock by RU index
    ...    ******************
    [Arguments]  ${ru_index}=${1}  ${with_call}=${True}   ${with_peak}=${False}   ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex: RU_${ru_index}
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
    ${cell_list}    get all cell id    ru_index=${ru_index}
    run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}
    Create file in RU    ru_index=${ru_index}
    ${ru_index_list}    create list    ${ru_index}
    Lock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'
    Unlock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'
    run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}
    Check file Exist in RU    ru_index=${ru_index}
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}   ${with_peak}=${False}   ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType: ${RU_type}
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        Get X2 link shutdown waiting time
        Selenium Login And Disable Screen Lock
        ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
        ${cell_list}    get all cell id    ru_index=${ru_index}
        run keyword if   ${with_call}   Get UE From Init File and Make call
        ...    cell_list=${cell_list}   with_peak=${with_peak}    duration=${call_duration}
        Create file in RU    ru_index=${ru_index}
        ${ru_index_list}    create list    ${ru_index}
        Lock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        Unlock all RUs and check status    ru_index_list=${ru_index_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${call_duration}
        Check file Exist in RU    ru_index=${ru_index}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex
    [Documentation]
    ...    *****************
    ...    operate cell block and unblock by RU index
    ...    ******************
    [Arguments]  ${ru_index}=${1}   ${with_call}=${True}   ${with_peak}=${False}   ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex: RU_${ru_index}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${block_id}  IN  @{cell_id_list_under_RU}
        ${operate_list}    create list    ${block_id}
        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${operate_list}
        ...    with_peak=${with_peak}  duration=${call_duration}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${operate_list}
        ...    with_peak=${with_peak}  duration=${call_duration}
    END
    [Teardown]   Selenium Logout And Close Browser

E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType
    [Documentation]
    ...    *****************
    ...    operate cell block and unblock by Radio Type
    ...    ******************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}    ${with_peak}=${False}    ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_cell_block_and_unblock_by_RadioType: ${RU_type}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}    set variable if  ${cell_num}==1  ${True}  ${False}
    Set Test Variable    ${check_alarm}
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}
        Cell block and unblock under specify RU    cell_list_under_RU=${cell_id_list_under_RU}
        ...    with_call=${with_call}    with_peak=${with_peak}    duration=${call_duration}
    END
    [Teardown]   Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex
    [Documentation]
    ...    *****************
    ...    operate RF module power reset by RU index
    ...    ******************
    [Arguments]  ${ru_index}=${1}   ${with_call}=${True}   ${with_peak}=${False}   ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex: RU_${ru_index}
    ${ru_index_list}   create list   ${ru_index}
    Create file in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    30s    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    Check file not Exist in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${call_duration}
    END
    [Teardown]  Run Keywords    Power On RU And Check    ru_index_list=${ru_index_list}    AND
                ...             Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_power_reset_by_RadioType
    [Documentation]
    ...    *****************
    ...    operate RF module power reset by RU type
    ...    ******************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}    ${with_peak}=${False}    ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RF_module_power_reset_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        Create file in RU    ru_index=${ru_index}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    30s    RU Should Be Power Off    ru_index=${ru_index}
        ${ru_list_tmp}   create list   ${ru_index}
        Power On RU And Check    ru_index_list=${ru_list_tmp}
        Check file not Exist in RU    ru_index=${ru_index}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${call_duration}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex
    [Documentation]
    ...    *****************
    ...    operate RF module reset from WebEM by RU index
    ...    ******************
    [Arguments]  ${ru_index}=${1}   ${with_call}=${True}   ${with_peak}=${False}   ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex: RU_${ru_index}
    ${ru_index_list}   create list   ${ru_index}
    Create file in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RF Module Reset from GUI    ru_index=${ru_index}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    Check file not Exist in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        run keyword if   ${with_call}   Get UE From Init File and Make call   cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType
    [Documentation]
    ...    *****************
    ...    operate RF module reset from WebEM by RU type
    ...    ******************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}    ${with_peak}=${False}    ${call_duration}=${60}
    log to console    \nE2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        Create file in RU    ru_index=${ru_index}
        Perform RF Module Reset from GUI    ru_index=${ru_index}
        coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
        Check file not Exist in RU    ru_index=${ru_index}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        run keyword if   ${with_call}   Get UE From Init File and Make call   cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${duration}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_site_power_reset
    [Documentation]
    ...    *****************
    ...    operate Site reset by power off and power on
    ...    ******************
    log to console    \nE2E_gNB_SiSo_site_power_reset
    Perform Site Power reset
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

E2E_gNB_SiSo_site_software_reset
    [Documentation]
    ...    *****************
    ...    operate Site reset from WebEM
    ...    ******************
    log to console    \nE2E_gNB_SiSo_site_software_reset
    Perform BTS Site Reset
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

