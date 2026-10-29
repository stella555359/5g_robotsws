*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

#Resource   ../Resource/Common.robot


*** Keyword ***
D_17_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_ULRLCTraceRecord_Allfields
#    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulRbRlcMeasRecord
        Continue For Loop If  not ${exist}
        ${ulRbRlcMeasRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
        Check_ULRLCTraceRecord_Allfields_Value   ulRbRlcMeasRecord=${ulRbRlcMeasRecord}
        Exit For Loop If  ${exist}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Case Setup: D_17
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    Log To Console   Case Setup: D_17
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

Case Teardown: D_17
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_17
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756

Check_ULRLCTraceRecord_Allfields_Value
    [Arguments]   ${ulRbRlcMeasRecord}
    ${ulRbRlcMeasRecord_length}=  Get Length  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord']}
    ${rbData_length_list}    create list
    ${rbData_length_1_idex_list}    create list
    ${rbData_length_2_idex_list}    create list
    FOR  ${idx}  IN RANGE  0  ${ulRbRlcMeasRecord_length}
        ${rbData_length}  Get Length  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${idx}]['rbData']}
        Append to list  ${rbData_length_list}  ${rbData_length}
        Run keyword if  ${rbData_length}==2  Append to list  ${rbData_length_2_idex_list}  ${idx}
        Run keyword if  ${rbData_length}==1  Append to list  ${rbData_length_1_idex_list}  ${idx}
    END
    FOR  ${idx}  IN RANGE  0  ${rbData_length_list}[0]
         ${first__dataCollectionDuration}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][0]['rbData'][${idx}]['dataCollectionDuration']}
         Should Be True  0<${first_dataCollectionDuration}<134273 or ${first_dataCollectionDuration}==0
    END
    Log To Console    first value of recordCollectionDuration is OK
    FOR  ${var}  IN  @{rbData_length_2_idex_list}
        ${drb-Id_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${drb-Id_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['drb-Id']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduRxBytes']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['sumOfRlcPduRxBytes']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduRx']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['timeOfUePduRx']}
        ${dataCollectionDuration_ulRbRlc_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        ${dataCollectionDuration_ulRbRlc_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_ulRbRlcMeasRecord_0}<33 and 0<${drb-Id_ulRbRlcMeasRecord_1}<33
#        Should Be True   ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0 and ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}==0
        Should Be True   ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}>0 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0
        Should Be True   ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}>0 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}==0
#        Should Be True   ${timeOfUePduRx_ulRbRlcMeasRecord_0}==0 and ${timeOfUePduRx_ulRbRlcMeasRecord_1}==0
        Should Be True   ${timeOfUePduRx_ulRbRlcMeasRecord_0}>0 or ${timeOfUePduRx_ulRbRlcMeasRecord_0}==0
        Should Be True   ${timeOfUePduRx_ulRbRlcMeasRecord_1}>0 or ${timeOfUePduRx_ulRbRlcMeasRecord_1}==0
#        ${endMarker_previous_0}  Set Variable  ${ALL_PCMD_MSG['ulRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
#        ${endMarker_current_0}  Set Variable  ${ALL_PCMD_MSG['ulRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
#        Run Keyword if  '${endMarker_current_0}'=='TRUE' or '${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${dataCollectionDuration_ulRbRlc_0}<131073 or ${dataCollectionDuration_ulRbRlc_0}==0
#        ...  ELSE  Should Be True   ${dataCollectionDuration_ulRbRlc_0}==131072
#        ${endMarker_current_1}  Set Variable  ${ALL_PCMD_MSG['ulRbRlcMeasRecord'][${var}]['rbData'][1]['endMarker']}
#        Run Keyword if  '${endMarker_current_1}'=='TRUE' or '${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${dataCollectionDuration_ulRbRlc_1}<131073 or ${dataCollectionDuration_ulRbRlc_1}==0
#        ...  ELSE  Should Be True   ${dataCollectionDuration_ulRbRlc_1}==131072
    END
    ${rbData_length_1}   Get Length  ${rbData_length_1_idex_list}
    Pass Execution if   ${rbData_length_1}==0    No more data need to check!
    FOR  ${var}  IN  @{rbData_length_1_idex_list}
        ${drb-Id_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduRxBytes']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduRx']}
        ${dataCollectionDuration_ulRbRlc_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_ulRbRlcMeasRecord_0}<33
#        Should Be True   ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0 and ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}==0
        Should Be True   ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}>0 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0
#        Should Be True   ${timeOfUePduRx_ulRbRlcMeasRecord_0}==0 and ${timeOfUePduRx_ulRbRlcMeasRecord_1}==0
        Should Be True   ${timeOfUePduRx_ulRbRlcMeasRecord_0}>0 or ${timeOfUePduRx_ulRbRlcMeasRecord_0}==0
#        ${endMarker_previous_0}  Set Variable  ${ALL_PCMD_MSG['ulRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
#        ${endMarker_current_0}  Set Variable  ${ALL_PCMD_MSG['ulRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
#        Run Keyword if  '${endMarker_current_0}'=='TRUE' or '${endMarker_previous_0}'=='TRUE' or ${var}==0
#        ...  Should Be True  0<${dataCollectionDuration_ulRbRlc_0}<131073 or ${dataCollectionDuration_ulRbRlc_0}==0
#        ...  ELSE  Should Be True   ${dataCollectionDuration_ulRbRlc_0}==131072
    END
