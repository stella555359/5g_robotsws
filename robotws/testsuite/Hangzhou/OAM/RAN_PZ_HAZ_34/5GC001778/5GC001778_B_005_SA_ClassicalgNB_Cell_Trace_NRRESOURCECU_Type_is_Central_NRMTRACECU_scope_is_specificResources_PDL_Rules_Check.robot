# *** Settings ***
# Documentation
# ...  author: Heng Liangliang
# ...  contact: jingmin.he@nokia-sbell.com   liangliang.heng@nokia-sbell.com
# Resource   Resource/emil.robot
# Resource   Resource/coam.robot
# Resource   Resource/common.robot
# 
# Force Tags   SG_07   CA_5G_OAM     CIT_21B    CIT_20B   CIT_21A   CIT_TRUNK
# ...    PY36
# 
# *** Variables ***
# @{key_error}    NRBTS.distname equal to NRRESOURCECU-1.resourceDN
#                ...   quantity of NRRESOURCECU equal to 1
# 
# *** Test Cases ***
# [1]5GC001778_B_005_SA_ClassicalgNB_Cell_Trace_NRRESOURCECU_Type_is_Central_NRMTRACECU_scope_is_specificResources_PDL_Rules_Check
#     [Setup]    Case Common Setup
#     Get Validation Error Before Modify Parameter
#     Add Cell Trace Object of TCE
# 	Add Cell Trace Object of NRMTRACECU
# 	Add Cell Trace Object of NRRESOURCECU   radio_resoure=central   resource=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
# 	Set PCMD CU Flag   pcmd_flag=false
# 	Modify Parameter actPCMDReport to False
# 	Set Cell Trace CU Flag   scope=specificResources
#     Check PDL Error for NRRESOURCECU
#     Config The Seond NRRESOURCECU
# 	Check PDL Error for NRRESOURCECU   new_error_num=2   validation_error_check=@{key_error}[1]   validation_error_num=2
#     [Teardown]    Case Common Teardown
# 
# *** Keywords ***
# Check PDL Error for NRRESOURCECU
#     [Arguments]   ${new_error_num}=1   ${validation_error_check}=@{key_error}[0]   ${validation_error_num}=1
#     ${errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
#     ...   Validate Plan and Return Error
#     ${new_errors}   Evaluate   ${errors_num}-${errors_num_before}
#     Run Keyword If   ${new_errors} != ${new_error_num}   Log To Console   Validation Error check Failed: ${new_errors}!=1.
#     ${validation_check}   Evaluate   str(@{relation_errors.values()}).count('${validation_error_check}')
#     Run Keyword If      ${validation_check} == ${validation_error_num}      Log To Console  Validation report error which meet case expectation.
#     ...         ELSE    Log To Console  Case Failed!
#     Should Be True      ${new_errors} == ${new_error_num} and ${validation_check} == ${validation_error_num}
# 
# Config The Seond NRRESOURCECU
#     selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
# 	...   filter_param=Resource distinguished name
# 	...   new_value=${INSID}
# 	selenium_coam.add_object   object_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1   object_class_name=NRRESOURCECU   id_value=2
#     ...   is_load_default_values=${true}
# 	selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-2
# 	...   filter_param=Type of New Radio Resource
# 	...   new_value=central
#     selenium_coam.set_parameter_value
# 	...   dist_name=${INSID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-2
# 	...   filter_param=Resource distinguished name
# 	...   new_value=${INSID}