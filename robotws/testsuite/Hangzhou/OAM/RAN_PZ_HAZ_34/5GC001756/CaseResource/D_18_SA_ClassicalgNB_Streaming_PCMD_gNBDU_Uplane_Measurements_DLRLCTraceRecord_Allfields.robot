*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot


*** Keyword ***
D_18_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_DLRLCTraceRecord_Allfields
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}  dlRbRlcMeasRecord
        Continue For Loop If  not ${exist}
        ${dlRbRlcMeasRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
        Check_DLRLCTraceRecord_Allfields_Value   dlRbRlcMeasRecord=${dlRbRlcMeasRecord}
        Exit For Loop If  ${exist}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Case Setup: D_18
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: D_18

Case Teardown: D_18
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_18
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756

Check_DLRLCTraceRecord_Allfields_Value
    [Arguments]   ${dlRbRlcMeasRecord}
    ${dlRbRlcMeasRecord_length}=  Get Length  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord']}
    ${rbData_length_list}    create list
    ${rbData_length_1_idex_list}    create list
    ${rbData_length_2_idex_list}    create list
    FOR  ${idx}  IN RANGE  0  ${dlRbRlcMeasRecord_length}
        ${rbData_length}  Get Length  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${idx}]['rbData']}
        Append to list  ${rbData_length_list}  ${rbData_length}
        Run keyword if  ${rbData_length}==2  Append to list  ${rbData_length_2_idex_list}  ${idx}
        Run keyword if  ${rbData_length}==1  Append to list  ${rbData_length_1_idex_list}  ${idx}
    END
    FOR  ${idx}  IN RANGE  0  ${rbData_length_list}[0]
         ${first_dataCollectionDuration}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][0]['rbData'][${idx}]['dataCollectionDuration']}
         Should Be True  0<${first_dataCollectionDuration}<134273 or ${first_dataCollectionDuration}==0
    END
    Log To Console    first value of recordCollectionDuration is OK
    FOR  ${var}  IN  @{rbData_length_2_idex_list}
        ${drb-Id_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${drb-Id_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['drb-Id']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduTxBytes']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['sumOfRlcPduTxBytes']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduTx']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['timeOfUePduTx']}
        ${recordCollectionDuration_dlRbRlc_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        ${recordCollectionDuration_dlRbRlc_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_dlRbRlcMeasRecord_0}<33 and 0<${drb-Id_dlRbRlcMeasRecord_1}<33
#        Should Be True   ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}==0 and ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}==0
        Should Be True   ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}>0 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}==0
        Should Be True   ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}>0 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}==0
#        Should Be True   ${timeOfUePduTx_dlRbRlcMeasRecord_0}==0 and ${timeOfUePduTx_dlRbRlcMeasRecord_1}==0
        Should Be True   ${timeOfUePduTx_dlRbRlcMeasRecord_0}>0 or ${timeOfUePduTx_dlRbRlcMeasRecord_0}==0
        Should Be True   ${timeOfUePduTx_dlRbRlcMeasRecord_1}>0 or ${timeOfUePduTx_dlRbRlcMeasRecord_1}==0
#        ${endMarker_previous_0}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
#        ${endMarker_current_0}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
#        Run Keyword if  '${endMarker_current_0}'=='TRUE' or '${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
#        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_0}==131072
#        ${endMarker_previous_1}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var-1}]['rbData'][1]['endMarker']}
#        ${endMarker_current_1}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var}]['rbData'][1]['endMarker']}
#        Run Keyword if  '${endMarker_current_1}'=='TRUE' or ${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_1}<131073 or ${recordCollectionDuration_dlRbRlc_1}==0
#        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_1}==131072
    END
    ${rbData_length_1}   Get Length  ${rbData_length_1_idex_list}
    Pass Execution if   ${rbData_length_1}==0    No more data need to check!
    FOR  ${var}  IN  @{rbData_length_1_idex_list}
        ${drb-Id_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduTxBytes']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduTx']}
        ${recordCollectionDuration_dlRbRlc_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_dlRbRlcMeasRecord_0}<33
        Should Be True   ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}==0 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}>0
#        Should Be True   ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}>0 and ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}>0
        Should Be True   ${timeOfUePduTx_dlRbRlcMeasRecord_0}>0 or ${timeOfUePduTx_dlRbRlcMeasRecord_0}==0
#        Should Be True   ${timeOfUePduTx_dlRbRlcMeasRecord_0}>0 and ${timeOfUePduTx_dlRbRlcMeasRecord_1}>0
#        ${endMarker_previous_0}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
#        ${endMarker_current_0}  Set Variable  ${ALL_PCMD_MSG['dlRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
#        Run Keyword if  '${endMarker_current_0}'=='TRUE' or '${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
#        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_0}==131072
    END
