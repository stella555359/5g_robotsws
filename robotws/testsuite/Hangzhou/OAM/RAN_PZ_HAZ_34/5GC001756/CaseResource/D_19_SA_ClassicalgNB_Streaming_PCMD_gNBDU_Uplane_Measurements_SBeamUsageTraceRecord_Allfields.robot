*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Keyword ***
D_19_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SBeamUsageTraceRecord_Allfields
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   beamUsageRecord
        Continue For Loop If  not ${exist}
        ${beamUsageRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
        Check_SBeamUsageTraceRecord_Allfields_Value   beamUsageRecord=${beamUsageRecord}
        Exit For Loop If  ${exist}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Case Setup: D_19
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: D_19

Case Teardown: D_19
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_19
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756

Check_SBeamUsageTraceRecord_Allfields_Value
    [Arguments]   ${beamUsageRecord}
    ${beamUsageRecord_length}=  Get Length  ${beamUsageRecord['beamUsageRecord']}
    ${first_value_recordCollectionDuration}  Set Variable  ${beamUsageRecord['beamUsageRecord'][0]['recordCollectionDuration']}
    Run Keyword If  0<${first_value_recordCollectionDuration}<134273 or ${first_value_recordCollectionDuration}==0
    ...  Log To Console    first value of recordCollectionDuration is OK
    FOR  ${idx}  IN RANGE  1  ${beamUsageRecord_length}
        ${recordCollectionDuration}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['recordCollectionDuration']}
        ${endMarker_previous}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx-1}]['endMarker']}
        Run Keyword if  '${beamUsageRecord['beamUsageRecord'][${idx}]['endMarker']}'=='TRUE' or '${endMarker_previous}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration}<131073 or ${recordCollectionDuration}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration}==131072
    END
    ${target_gnb_release}   Get gnb release   host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    FOR  ${idx}  IN RANGE  0  ${beamUsageRecord_length}
#        ${ConfigBeamData}  Set Variable   @{beamUsageRecord['beamUsageRecord'][${idx}]['beamData'].keys()}[0]
#        ${Failed}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfFailedBeamChanges']}
#        ${Success}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfSuccessfulBeamRecoveries']}
#        ${TotalChanges}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfTotalBeamChanges']}
#        ${TotalRecoveries}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfTotalBeamRecoveries']}

        ${ConfigBeamData_dic}    Run Keyword If   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable   ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData'].keys()}
        ...   ELSE    Set Variable   ${beamUsageRecord['beamUsageRecord'][${idx}].keys()}
        ${ConfigBeamData_list}    convert to list    ${ConfigBeamData_dic}
        ${ConfigBeamData}  Run Keyword If   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable   ${ConfigBeamData_list[0]}
        ...   ELSE   Set Variable   ${ConfigBeamData_list[-1]}

        ${common_path}  Set Variable IF   '${target_gnb_release}' <= 'SBTS24R2'
        ...   ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']}
        ...   ${beamUsageRecord['beamUsageRecord'][${idx}]['${ConfigBeamData}']}

        ${Failed}  Set Variable  ${common_path['numOfFailedBeamChanges']}
        ${Success}  Set Variable  ${common_path['numOfSuccessfulBeamRecoveries']}
        ${TotalChanges}  Set Variable  ${common_path['numOfTotalBeamChanges']}
        ${TotalRecoveries}  Set Variable  ${common_path['numOfTotalBeamRecoveries']}

        Should Be True  ${Failed}==0 or ${Failed}>0 or ${Success}==0 or ${Success}>0 or ${TotalChanges}==0 or ${TotalChanges}>0
        Should Be True  ${TotalRecoveries}==0 or ${TotalRecoveries}>0
        ${beamIdUsageCount_0}  Run Keyword IF   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['beamIdUsageCount'][0]}
        ${beamIdUsageCount_1}  Run Keyword IF   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['beamIdUsageCount'][1]}
        ${beamIdUsageCount_2}  Run Keyword IF   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['beamIdUsageCount'][2]}
        ${beamIdUsageCount_3}  Run Keyword IF   '${target_gnb_release}' <= 'SBTS24R2'
        ...   Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['beamIdUsageCount'][3]}

        Run Keyword IF   '${target_gnb_release}' <= 'SBTS24R2'   Run Keywords
        ...   Should Be True   ${beamIdUsageCount_0}==0 or ${beamIdUsageCount_0}>0
        ...   AND   Should Be True   ${beamIdUsageCount_1}==0 or ${beamIdUsageCount_1}>0
        ...   AND   Should Be True   ${beamIdUsageCount_2}==0 or ${beamIdUsageCount_2}>0
        ...   AND   Should Be True   ${beamIdUsageCount_3}==0 or ${beamIdUsageCount_3}>0
    END
