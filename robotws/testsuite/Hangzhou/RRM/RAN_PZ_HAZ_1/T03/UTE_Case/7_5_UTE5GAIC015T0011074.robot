*** Settings ***
Documentation
...   author: huan.wang
...   contact: huan.wang@nokia-sbell.com
...   this is a robot case for UTE regression
Resource           ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags              CRT
...                     AIC
...                     CLOUD_5G_AIC_SA_1xAndriod_1xvDU_OE20_1xFHGW_1xAEQE
# ...                     SBTS22R4
...                     vCUCNF00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{vCU_reset_Info}
...    Case_Path=${CURDIR}${/}../../../../AIC/RAN_PZ_HAZ_2/ST4_5_Common/Status/Cloud_General_vCU_reset_via_WebEM.robot
&{vCU_cell_lock_unlock_Info}
...    Case_Path=${CURDIR}${/}../../../../AIC/RAN_PZ_HAZ_2/ST4_5_Common/Status/Cloud_General_Status_vCU_cell_lock_unlock_via_WebEM.robot
&{vCU_online_change_parameter_recommission_Info}
...    Case_Path=${CURDIR}${/}../../../../AIC/RAN_PZ_HAZ_2/ST4_5_Common/CM/Cloud_General_CM_online_change_parameter_recommission_vCU_via_WebEM.robot
&{vCU_snapshot_Info}
...    Case_Path=${CURDIR}${/}../../../../AIC/RAN_PZ_HAZ_2/ST4_5_Common/Logging/Cloud_General_Logging_vCU_snapshot_local_via_WebEM.robot
&{vCU_SA_Call_Info}
...    Case_Path=${CURDIR}${/}../../../../AIC/RAN_PZ_HAZ_2/ST4_5_Common/Status/Cloud_General_vCU_reset_via_WebEM.robot
&{Feature_File_INFO}
...    vCU_reset=&{vCU_reset_Info}
...    vCU_cell_lock_unlock=&{vCU_cell_lock_unlock_Info}
...    vCU_online_change_parameter_recommission=&{vCU_online_change_parameter_recommission_Info}
...    vCU_snapshot=&{vCU_snapshot_Info}
...    vCU_SA_Call=&{vCU_SA_Call_Info}
*** Test Cases ***
CB012362-E_03_vCU reset via WebEM
    Run One Case      cases_info=${vCU_reset_Info}
    ...      feature_name=vCU_reset_Info      test_name=${None}
CB012362-E_04_Cell lock unlock via WebEM
    Run One Case      cases_info=${vCU_cell_lock_unlock_Info}
    ...      feature_name=vCU_cell_lock_unlock_Info      test_name=${None}
CB012362-E_05_CM online change parameter recommission vCU via WebEM
    Run One Case      cases_info=${vCU_online_change_parameter_recommission_Info}
    ...      feature_name=vCU_online_change_parameter_recommission_Info      test_name=${None}
CB012362-E_06_Logging_vCU_snapshot_local_via_WebEM
    Run One Case      cases_info=${vCU_snapshot_Info}
    ...      feature_name=vCU_snapshot_Info     test_name=${None}
CB012362-E_02_SA call with vCU maximum reference HW configuration and SNO vDU
    Run One Case      cases_info=${vCU_SA_Call_Info}
    ...      feature_name=vCU_SA_Call    test_name=${None}

