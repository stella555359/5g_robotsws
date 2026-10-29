*** Settings ***
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature AVQE bootcamp in 5G24R2 program
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G }/Baseband_module_reset_via_WEBUI.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G }/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G }/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G }/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G }/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G }/Cell/General_SiSo_Online_Cell_addition_deletion_Sametimes.robot
Resource    ${BASIC_PATH_5G }/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G }/Test_Model/General_SiSo_DL_Test_Model_Verification.robot
Resource    ${BASIC_PATH_5G }/General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot

*** Keywords ***
Change RAT restart needed parameter
    log to console    change actFdmUeSkippingOlc to true
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate FDM UE skipping overload control    abbr=actFdmUeSkippingOlc    new_value=true
    sleep    1s
    Activate Parameters
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate FDM UE skipping overload control    abbr=actFdmUeSkippingOlc    new_value=false
    sleep    1s
    Activate Parameters
    [Teardown]    Selenium Logout And Close Browser
Disable energy powing
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false    
    [Teardown]    Selenium Logout And Close Browser
Change prach configuration
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PRACH configuration index    abbr=prachConfigurationIndex    new_value=${101}
    [Teardown]    Selenium Logout And Close Browser
Change msg1frequencyStart configuration
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=PRACH Frequency start    abbr=msg1frequencyStart    new_value=${108}
    Selenium Logout And Close Browser
Online add cells
    [Documentation]    shifu.lan@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${lcrid_list}    ${cell_grp}    ${scf_path}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    FOR    ${addition_deletion_cell}    ${addition_deletion_cellgrp}    ${lcrid}    IN ZIP    ${addition_deletion_cell_list}
    ...    ${addition_deletion_cellgrp_list}    ${lcrid_list}
        Log To Console    \nAdd cell ${addition_deletion_cell}
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${1}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${1}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${0}
        ...    id_value=${addition_deletion_cellgrp}    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Physical cell identifier     abbr=physCellId    new_value=${553}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Maximum output power     abbr=pMax    new_value=${31}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${1}
        ...    filter_param=Maximum output power     abbr=pMax    new_value=${31}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    filter_param=List of NR cells assigned to cell group     abbr=nrCellList    new_value=${addition_deletion_cell}
        ...    node_index=${0}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=NR Absolute radio frequency channel number     abbr=nrarfcn    new_value=${640000}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Synchronization channel number     abbr=gscnOrSsPbchArfcn    new_value=${1}
        # recover NRDU-1 as prev
        selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    timeout=15
    END
    FOR  ${index}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     abbr=refNrCellGroup    new_value=${index}
        ...    node_index=${index}
    END
    Activate Parameters
Online delete cells
    [Documentation]    shifu.lan@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${lcrid_list}    ${cell_grp}    ${scf_path}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    FOR    ${addition_deletion_cell}    ${addition_deletion_cellgrp}    ${lcrid}    IN ZIP    ${addition_deletion_cell_list}
    ...    ${addition_deletion_cellgrp_list}    ${lcrid_list}
        Log To Console    \nAdd cell ${addition_deletion_cell}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    END
    FOR  ${index}  IN  @{cell_grp}
        selenium_coam.remove_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     abbr=refNrCellGroup
        ...    node_index=${index}
    END
    Activate Parameters
