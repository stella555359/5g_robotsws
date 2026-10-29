*** Settings ***
Documentation    Author:
...              \n Cloud common operate keywords.

Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_common_resource.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/cloud/robot/cloud_operate.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_host_server.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Library        taf.sw.scout    WITH NAME    scout

*** Variables ***
${TOOLS_LIST}    common_config_private

*** Keywords ***
Cloud Common Suite Setup
    [Documentation]    This keyword is cloud common Suite Setup.
    ...    Examples:
    ...    | AIC Common Suite Setup |
    Set Tags     QCP_RAN_ET
    Set Tags     QCD_MN_RAN
    Clean Up Env
    Get Host IP
    Get Host Name
    ${cu_version}    Get Cloud vCU SW Version
    ${du_version}    Get Cloud vDU SW Version
    Set Global Variable    ${VCU_VERSION}    ${cu_version}
    Set Global Variable    ${VDU_VERSION}    ${du_version}
    Set Suite Variable    ${save_snapshot}    ${True}


Cloud Common Suite Teardown
    run keyword if    ${save_snapshot}    Cloud Capture Snapshot and other Log

Cloud Common Test Setup
#    Set Timestamp
    Run Keyword And Ignore Error    Set QC Tag In Case     ${TEST_NAME}     ${VDU_VERSION}

Cloud Common Test Teardown
#    Get all snapshots    ${OAM_VDU}    ${OAM_CU}
    run keyword and ignore error    Ask scout to analyze scf

Ask scout to analyze scf
    # ask scout to analyze scf
    ${hostname}=    Run    cat /etc/hostname | sed 's/-/_/g'
    ${host_name}    Evaluate    re.sub("_1$", "", re.sub("_2$", "", "${host_name}"))    re
    scout.setup_scout    scout_testline_name=${hostname}
    scout.request_scf

Prepare Cloud Onair
    [Arguments]    ${vdu_scf_path}    ${cu_scf_path}
    Backup Cloud vDU SCF From Current Plan
    Backup Cloud vCU SCF From Current Plan
    #include wait gnb onari
    Cloud Full Commission    vdu_scf_path=${vdu_scf_path}    cu_scf_path=${cu_scf_path}


Online Change Cloud Single Paramter
    [Documentation]    *****************
    ...    This keyword is used to Online Change Cloud Single Paramter.
    ...    - [Keyword Details]
    ...    It performs a fast delta commission with the constructed delta data.
    ...    It waits until all cells are on air for all vDUs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | mo_dn | Yes | The managed object distinguished name. |
    ...    | param_name | Yes | The name of the parameter to be modified. |
    ...    | param_value | Yes | The new value of the parameter. |
    ...    | operation_type | No | The operation type for delta commissioning. Default is 'update'. |
    ...     example: Online Change Cloud Single Paramter  | mo_dn=MRBTS-37462/NRBTS-37462/NRCELL-4/NRDLMUMIMO-1 |
    ...     param_name=actMuAwareTdSch | param_value=true | operation_type=update |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    [Arguments]  ${mo_dn}    ${param_name}    ${param_value}    ${operation_type}=update
    ${delta_data}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=${mo_dn}
    ...  operation_type=${operation_type}
    ...  ${param_name}=${param_value}
    ${all_delta_data_list}=  create list   ${delta_data}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    log to console   \nOnline Change Cloud Single Paramter: ${param_name}=${param_value} completed.
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs

Cloud Capture Snapshot and other Log
    [Documentation]    This keyword Cloud Capture Snapshot and other Log from the vDU node.
    ...    *Detail*
    ...    It first logs the start of the operation, then triggers and saves local snapshots for CU and vDU.
    ...    It then logs the start of log collection from the vDU node and collects the logs.
    ...    If the log collection fails, it will not cause the keyword to fail.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |

    log to console    Save CU Snapshot...
    Trigger And Save Local Snapshot For CU
    log to console    Save VDU Snapshot...
    Trigger And Save Local Snapshot For vDU   compressed_or_not=${True}
    log to console    Collect Log from VDU Node...
    run keyword and ignore error    Collect Log from VDU Node    local_log_file_path=${TEST_LOG_DIRECTORY()}
