*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_feature_status.robot


*** Variables ***

*** Keywords ***
General_basic_counters
    [Documentation]
    ...    *****************
    ...    [TEST DESCRIPTION] Cehck Basic Counters existence, Example: miNrEcpriUpFCp set to 5 min, and check FCP counters data
    ...    *****************
    ...    [TEST STEPS]
    ...    1. Precondition: Check vDU status. vDU state is “onAir”. Cells status: Procedural status: Configured Operational state:
    ...    Enabled Availability status: On line Administrative state: Unlocked Blocking status: Unblocked All cells have power.
    ...    2. select random counters and check the results in WebEM for example we can select miNrEcpriUpFCp and set to 5min,
    ...    3. then check the counters data(M55318C00002,M55318C00004,M55318C00006,M55318C00008,M55318C000010) of miNrEcpriUpFCp,
    ...    data of miNrEcpriUpFCp should be normal. M55318C00002:ECPRI_UP_MSG_RU_RCV_ALL M55318C00004:ECPRI_UP_MSG_RU_RCV_TIME

    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.11.2024 - - Created ticket:https://jiradc.ext.net.nokia.com/browse/REX-19703
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${counter_check_time}=6min
    ${cell_ids}=    Cloud Get Cells Id List
    ${mo_dn}  Set Variable  MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    log to console   \nparameter "miNrEcpriUpFCp" is set to 5min
    Cloud Modify Single Paramter Online  mo_dn=${mo_dn}  param_name=miNrEcpriUpFCp  param_value=5min  operation_type=update
    log to console   \nwait 6min to check counters
    Sleep  ${counter_check_time}
    log to console   \nCheck miNrEcpriUpFCp counters
    FOR  ${cell_id}  IN  @{cell_ids}
        Cloud Check miNrEcpriUpFCp Counter Data  dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
    END
    [Teardown]   Cloud Modify Single Paramter Online  mo_dn=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1  param_name=miNrEcpriUpFCp
    ...  param_value=disabled  operation_type=update

Cloud Check miNrEcpriUpFCp Counter Data
    [Documentation]    *****************
    ...    This keyword is used to check the miNrEcpriUpFCp counter data.
    ...    - [Keyword Details]
    ...    It creates a list of counter IDs related to miNrEcpriUpFCp.
    ...    It then calls the 'Cloud Check Counter Data' keyword with the distribution name and counter IDs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | dist_name | Yes | The distribution name. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${dist_name}
    ${counter_ids}=  Create List  M55318C00002  M55318C00004  M55318C00006  M55318C00008
    Cloud Check Counter Data  dist_name=${dist_name}  counter_ids=${counter_ids}
