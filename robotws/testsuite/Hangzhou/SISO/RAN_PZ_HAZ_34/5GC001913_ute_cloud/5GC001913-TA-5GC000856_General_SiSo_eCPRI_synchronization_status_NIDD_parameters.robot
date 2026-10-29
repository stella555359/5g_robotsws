# # #*** Settings ***
# # #Documentation     author: Zoey Li
# # #...               contact: zoey.li@nokia-sbell.com
# # #...               squad group: MMW_SG_04
# # #Force Tags        5G_SISO    5GC001913    CRT_20B    CRT_TRUNK
# # #...    PY36
# # #Library           OperatingSystem
# # #Library           Collections
# # #Library           BuiltIn
# # #Library           String
# # #Library           taf.transport.ssh    WITH NAME    csn
# # #Library           taf.collectors.core      WITH NAME   core
# # #Library           taf.collectors.btslog    WITH NAME   btslog
# # #Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Variables         resources/5GC001913_modify_para.py
# # #
# # #
# # #
# # #*** Variables ***
# # #${1913_default_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_0.190_DU_1913_default.xml
# # #${TS_LOG_PATH_BASE}    /home/ute/zoey/Logs
# # #${Test_Case_Name}    5GC001913-TA-5GC000856_General_SiSo_eCPRI_synchronization_status_NIDD_parameters
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC001913-TA-5GC000856_General_SiSo_eCPRI_synchronization_status_NIDD_parameters
# # #    [Tags]    5GC001913    CRT_20B    CRT_TRUNK    5GC000856     5GC000959    5GC001591
# # #    [Setup]    Case Setup ready
# # #    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_L_01}
# # #    COAM Wait for gnb ready and cell setup on DU
# # #    [Teardown]    Case Teardown
# # #
# # #
# # #*** Keywords ***
# # #Case Setup ready
# # #    COAM Create log directory
# # #    Cloud DU connect to gnb coam via ssl
# # #
# # #Recover the test ENV
# # #    COAM Teardown gnb connections
# # #
# # #Modify SCF File and Commissioning
# # #    [Arguments]    ${PARAMS_TO_MODIFY_SCF}
# # #    ${new_scf_file}    COAM Modify scf file    scf_file_path=${1913_default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
# # #    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${new_scf_file}
# # #
# # #COAM Wait for gnb ready and cell setup on DU
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Wait until GNB status ready.
# # #    [Timeout]  30 min
# # #    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'
# # #    ${has_cbts}    testline_info.has_cloudBts    ${tl}
# # #    Run keyword if    ${has_cbts}
# # #    ...    Wait until keyword succeeds    ${timeout}    20 sec    Cloud DU connect to gnb coam via ssl    connection=${connection}
# # #    ...    ELSE    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
# # #    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASOD status    connection=${connection}
# # #    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
# # #    Run keyword if  ${gnb_type}=='NSA'    Run keyword if    ${has_cbts}==${False}
# # #    ...    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check X2 link status from GNB
# # #    ...    connection=${connection}
# # #    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
# # #
# # #COAM Check GNB ASOD status
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Support to check multiple ASODs
# # #    [Arguments]    ${connection}=GNB_OAM
# # #    Log to console    Check GNB ASOD status
# # #    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
# # #    @{list_asods}    Set variable    ${hw_info['systemModules']}
# # #    ${count_asods}    Get length    ${list_asods}
# # #    Should be true    ${count_asods}>=${1}    msg=Check ASOD status failed as total ASOD number is less than 1
# # #    FOR  ${asod}  IN  @{list_asods}
# # #         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['administrativeState']}    Unlocked
# # #                                       ...  msg=Current ASOD administrativeState is not in Unlocked status    ignore_case=${True}
# # #         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['operationalState']}    Enabled
# # #                                       ...  msg=Current ASOD operationalState is not in Enabled status    ignore_case=${True}
# # #         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['proceduralStatus']}    configured
# # #                                       ...  msg=Current ASOD proceduralStatus is not in configured status    ignore_case=${True}
# # #         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['availabilityStatus']}    Online
# # #                                       ...  msg=Current ASOD availabilityStatus is not in Online status    ignore_case=${True}
# # #    END
# # #
# # #Case Teardown
# # #    Run Keyword And Ignore Error    Recover the test ENV
# # #    CI_interface.Common Case Teardown