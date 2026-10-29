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
# ${key_error}   TCE-* having NRMTRACECU-1.nrTceIdentifier (value: 1) equal to TCE.tceIdentifier
# 
# *** Test Cases ***
# [1]5GC001778_B_004_SA_ClassicalgNB_Invalid_Cell_Trace_Session_Parameters_Checking_Delete_Referred_NRTCE_Object_Not_Allowed
#     [Setup]    Case Common Setup
#     Add Cell Trace Object Without Activate   pcmd_cu=false
# 	Modify Parameter actPCMDReport to False
#     selenium_coam.validate_plan
#     Get Validation Error Before Modify Parameter
#     selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
#     Delete Object TCEADM and Check PDL Error
#     [Teardown]    Case Common Teardown
# 
# *** Keywords ***
# Delete Object TCEADM and Check PDL Error
#     ${du_remove}   Run keyword and Return Status  selenium_coam.remove_object   MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1
#     Log To Console  Validate Plan and check expect validation error.
#     ${errors_num}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
#     ...   Validate Plan and Return Error
#     wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes
#     ${new_errors}   Evaluate   ${errors_num}-${errors_num_before}
#     Run Keyword If   ${new_errors} != 1   Log To Console   Validation Error check Failed: ${new_errors}!=1.
#     ${validation_check}   Evaluate   str(@{relation_errors.values()}).count('${key_error}')
#     Run Keyword If      ${validation_check} == 1      Log To Console  Validation report error which meet case expectation.
#     ...         ELSE    Log To Console  Case Failed!
#     Should Be True      ${new_errors} == 1 and ${validation_check} == 1
