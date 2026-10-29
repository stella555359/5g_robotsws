*** Settings ***
Documentation
...    Author:  Zefang.xu
...    Contact: zefang.xu@nokia-sbell.com
...    Feature: CB010713
...    Release: 24R1
...    Only NR_TDD_eCPRI_8D8U_8Rx_1cell on CRT testline
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    4298
${scfc_file_US01}      CB010713_ABIP_1AENB_TDD_eCPRI_8D8U_8Rx_80MHz_concurrent_1cell.xml
${scfc_file_US02}      CB010713_ABIP_1AENB_TDD_eCPRI_8D8U_4Rx_80MHz_concurrent_1cell.xml

*** Test Cases ***
CB010713_SR_G_US01_NR_FR1_TDD_eCPRI_Reconfig_One_C8_Cell_into_Two_C4_Cells_ABIP_trunk
    [Tags]    QC_539155    ABIP    CB010713-G    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010713${/}${scfc_file_US01}    15min    600
    online change 8D8U cell1 from C8 to C4
    Wait Until Keyword Succeeds     600s    30s    Check If All Cells Are OnAir
    Qualcomm L3 call    700    80    10%    5G

CB010713_SR_G_US02_NR_FR1_TDD_eCPRI_Reconfig_Two_C4_Cell_into_One_C8_Cells_ABIP_trunk
    [Tags]    QC_539156    ABIP    CB010713-G    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010713${/}${scfc_file_US02}    15min    600
    online change 8D8U cell1 from C4 to C8
    Wait Until Keyword Succeeds     600s    30s    Check If All Cells Are OnAir
    Qualcomm L3 call    700    80    10%    5G

CB010713_SR_G_US01_NR_FR1_TDD_eCPRI_Reconfig_One_C8_Cell_into_Two_C4_Cells_ABIP_branch
    [Tags]    QC_582396    ABIP    CB010713-G    Branch    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010713${/}${scfc_file_US01}    15min    600
    online change 8D8U cell1 from C8 to C4
    Wait Until Keyword Succeeds     600s    30s    Check If All Cells Are OnAir
    Qualcomm L3 call    700    80    10%    5G

CB010713_SR_G_US02_NR_FR1_TDD_eCPRI_Reconfig_Two_C4_Cell_into_One_C8_Cells_ABIP_branch
    [Tags]    QC_582397    ABIP    CB010713-G    Branch    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB010713${/}${scfc_file_US02}    15min    600
    online change 8D8U cell1 from C4 to C8
    Wait Until Keyword Succeeds     600s    30s    Check If All Cells Are OnAir
    Qualcomm L3 call    700    80    10%    5G

*** Keywords ***
online change 8D8U cell${cell_id} from C8 to C4
    ${mrbtsID}    set Variable    ${btsid}
    ${nrbtsID}    set Variable    ${btsid}
    Selenium Coam Login And Disable Screen Lock
    WebUI connection    online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-9
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-10
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-11
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-12
    ...    timeout=15    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=5
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=6
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=7
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=8
    ...    sbts=online_change
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Number of Rx beamforming    new_value=4Rx    abbr=numberOfRxBeamforming
    ...    sbts=online_change
    selenium_coam.validate_plan    sbts=online_change
    selenium_coam.activate_plan   activate_plan_despite_errors=True    sbts=online_change
    [Return]    WebUI disconnection    online_change

online change 8D8U cell${cell_id} from C4 to C8
    ${mrbtsID}    set Variable    ${btsid}
    ${nrbtsID}    set Variable    ${btsid}
    Selenium Coam Login And Disable Screen Lock
    WebUI connection    online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=9
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=10
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=11
    ...    sbts=online_change
    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
    ...    object_class_name=CHANNEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-5
    ...    include_subobject=True
    ...    id_value=12
    ...    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-5
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-6
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-7
    ...    timeout=15    sbts=online_change
    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-8
    ...    timeout=15    sbts=online_change
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Number of Rx beamforming    new_value=8Rx    abbr=numberOfRxBeamforming
    ...    sbts=online_change
    selenium_coam.validate_plan    sbts=online_change
    selenium_coam.activate_plan   activate_plan_despite_errors=True    sbts=online_change
    [Return]    WebUI disconnection    online_change
