*** Settings ***
Documentation    Keywords operations on NSP NFM-P
...              author: Grzegorz Hajto, Lukasz Skoczylas
...              contact: grzegorz.hajto@nokia.com, lukasz.skoczylas@nokia.com
...              mainteiner: grzegorz.hajto@nokia.com, lukasz.skoczylas@nokia.com

Library    testsuite.Krakow.Cloud.regression.RAN_PZ_KRK3.FR_5GC001590-BA-NSP.resources.generic_nsp.GenericNsp
...                 ${tl.nms.nom.ssh_connections_info.addr}
...                 ${tl.nms.nom.ssh_connections_info.username}
...                 ${tl.nms.nom.ssh_connections_info.password}
...             WITH NAME  generic_nsp
Library    testsuite.Krakow.Cloud.regression.RAN_PZ_KRK3.FR_5GC001590-BA-NSP.resources.nsp_nfmp.NspNfmp
...                 ${tl.nms.nom.https_rest_info.addr}
...                 ${tl.nms.nom.https_rest_info.username}
...                 ${tl.nms.nom.https_rest_info.password}
...                 ${tl.nms.nom.https_rest_info.port}
...             WITH NAME  nsp_nfmp

*** Keywords ***
Send Work Order File to NSP
    [Arguments]    ${work_order_filename}
    generic_nsp.send_wo_file_to_nsp    work_order_filename=${work_order_filename}

NSP Load Config
    [Documentation]     Loads config via NSP
    [Arguments]    ${work_order}
    Send Work Order File To NSP          work_order_filename=${work_order}
    nsp_nfmp.activate_workorder          work_order_filename=${work_order}

NSP Verify Parameter Value
	[Documentation]		Check if managed object parameter has expected value
    [Arguments]			${managed_object}    ${parameter}    ${expected_value}
    nsp_nfmp.verify_parameter_value	   managed_object=${managed_object}
    ...                                parameter=${parameter}
    ...                                expected_value=${expected_value}

NSP Verify Alarm is Active
    [Documentation]     Check if given alarm is active
    [Arguments]			${managed_object_path}    ${fault_name}    ${fault_id}=${None}
    nsp_nfmp.verify_alarm_is_active  managed_object=${managed_object_path}
    ...                              fault_name=${fault_name}
    ...                              fault_id=${fault_id}

NSP Verify Alarm is Not Active
    [Documentation]     Check if given alarm is not active
    [Arguments]			${managed_object_path}    ${fault_name}    ${fault_id}=${None}
    nsp_nfmp.verify_alarm_is_not_active  managed_object=${managed_object_path}
    ...                                  fault_name=${fault_name}
    ...                                  fault_id=${fault_id}

NSP Lock Cell
    [Documentation]     Set NRCELL administrativeState to Locked
    [Arguments]			${nrcell_path}
    nsp_nfmp.lock_cell  nrcell_path=${nrcell_path}

NSP Unlock Cell
    [Documentation]     Set NRCELL administrativeState to Unlocked
    [Arguments]			${nrcell_path}
    nsp_nfmp.unlock_cell  nrcell_path=${nrcell_path}

NSP Lock DU
    [Documentation]     Set NRDU administrativeState to Locked
    [Arguments]			${nrdu_path}
    nsp_nfmp.lock_du    nrdu_path=${nrdu_path}

NSP Unlock DU
    [Documentation]     Set NRDU administrativeState to Unlocked
    [Arguments]			${nrdu_path}
    nsp_nfmp.unlockdu   nrdu_path=${nrdu_path}

NSP Reset gNB
    [Documentation]     Perform gNB site reset
    [Arguments]			${managed_object_path}
    nsp_nfmp.reset_bts  managed_object=${managed_object_path}

NSP Verify Managed Object Not Present
    [Documentation]     Check that given object not exist on NSP
    [Arguments]			${managed_object_path}
    nsp_nfmp.verify_managed_object_not_present  managed_object=${managed_object_path}

