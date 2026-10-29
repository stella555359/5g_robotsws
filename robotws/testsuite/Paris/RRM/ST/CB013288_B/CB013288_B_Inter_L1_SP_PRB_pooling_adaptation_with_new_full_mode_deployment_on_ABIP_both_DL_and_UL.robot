*** Settings ***
Documentation
...  **Feature Name:**
...                     CB013288 (Large BB Pool TDD FR1 Enhancements)
...  **Feature Purpose:**
...    This feature enables intra-L1 SP PRB pooling adaptation with new full mode deployment on ABIP/ABIQ RUs, both for DL and UL.
...    The feature CB013288 introduces a new full mode deployment and refines the pooling concept for full board cell sets in FR1 TDD.
...    It enables a more efficient and flexible way to pool resources in FR1 TDD, allowing for better performance and capacity utilization.
...
...     * Introducing a new full mode deployment
...     * Using the legacy baseband resource pooling (CB008940)
...     * ZAB and RIM-RS interworking with new full mode deployment on ABIP/ABIQ
...     * Supporting 6 cells 16DL8UL on RINLINE2 with new full mode deployment
...     * Verifying PRB pooling and UE pooling functions on top of new full mode deployment on ASOG/ASOH/RINLINE2
...
...   **Key Functionality:**
...     1. When NRBTS/actLargeBbPoolTddFr1Enh is set to TRUE, the feature is activated.
...     2. The slowPrbPoolingTddFr1DlAllowed flag is set to TRUE.
...     3. The slowPrbPoolingTddFr1UlAllowed flag is set to TRUE.
...     4. The scheUePoolingAllowed flag is set to TRUE.
...     5. The connRrcPoolingAllowed flag is set to TRUE.
...     6. The subcellDeactivationDlAllowed flag is set to FALSE.
...
...  **How it Works:**
...     When the `NRBTS.actLargeBbPoolTddFr1Enh` flag is set to TRUE, the feature is activated. This enables the following:
...     * Intra-L1 SP PRB pooling adaptation for TDD FR1 eCPRI and BF capable RUs.
...     * New full mode deployment on ABIP/ABIQ RUs, both for DL and UL.
...
...     **Supported Hardware:**
...     This feature is applicable on TDD FR1 eCPRI and BF capable RUs with supported BB HW being Thor BB HW (like ABIP/ABIQ/ASOG/ASOH/RINLINE2).
...     It's not supported on Loki BB HW (like ABIO/ASOE/ABIN).
...
...    **Notes:**
...     * When the CB013288 function is fully delivered from 25R2 onwards, it will be activated by default.
...     * If NRBTS.actLargeBbPoolTddFr1Enh is modified and the conditions are met (i.e., Classical BTS only), the feature will be handled accordingly.
...     * If you want to deactivate the feature, set `NRBTS.actLargeBbPoolTddFr1Enh` to FALSE.
...
...     CONTACT: VRF_NPS_T02
...     AUTHOR: Abderrahmane NEZROUK
...

Suite Setup       CB013288-B Test Suite Setup
Suite Teardown    CB013288-B Test Suite Teardown


Library         BuiltIn
Library	        OperatingSystem
Library	        taf.ue                                 WITH NAME    taf_ue
Library	        taf.transport.ssh          		        WITH NAME    ssh
Library	        taf.collectors.btslog      		        WITH NAME    btslog
Library	        taf.collectors.core        		        WITH NAME    core
Library         taf.analyzer.iperf_throughput           WITH NAME    tput
Library         taf.sbts.oam.coam.admin                  WITH NAME  coam_admin
Library         taf.selenium.sbts                        WITH NAME  selenium_sbts
Library         taf.hw.pdu                               WITH NAME  pdu
Library			ArchiveLibrary
Library			DateTime
Library			Collections
Library			String
Library         Process
Library         json
Library         taf.sw.reporting_portal
Library         taf.rfrl.utilities.tl_config                             WITH NAME  tl_config
Library         taf.internal.wireshark.installation                      WITH NAME  wireshark_installer


Library         ../resources/vrf_nps_2/python/utilities.py
Library         ../resources/vrf_nps_2/python/radParams_handler.py           WITH NAME  radParams
Library         ../resources/vrf_nps_2/python/useful_keywords.py             WITH NAME  useful_keywords
Library         ../../../resources/ST/python/scout_utils.py                  WITH NAME  scout_utils
Library         ../resources/vrf_nps_2/python/tti_trace_collector.py         WITH NAME  tti_trace_collector
Library         ../resources/vrf_nps_2/python/tti_trace_tool_installer.py    WITH NAME  tti_tool_installer
Library         ../resources/vrf_nps_2/python/ims/ims_analyzer.py            WITH NAME  ims_analyzer
Library         ../resources/vrf_nps_2/python/files_operations.py            WITH NAME  files_operations
Library         ../resources/vrf_nps_2/python/bts_utilities.py               WITH NAME  bts_utilities

Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource        taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Resource        taf/rfrl/bts/robot/common/gnb_ru.robot
Resource        taf/rfrl/bts/robot/common/gnb_log.robot
Resource        taf/rfrl/bts/robot/common/gnb_scf.robot
Resource        taf/rfrl/common_resources/robot/coam.robot

Resource        ../resources/vrf_nps_2/robot/Test_Suite_Preparation.robot
Resource        ../resources/vrf_nps_2/robot/var_test_suite.robot
Resource        ../resources/vrf_nps_2/robot/logs_collector.robot
Resource        ../resources/vrf_nps_2/robot/scf_utilities.robot
Resource        ../resources/vrf_nps_2/robot/common_useful_keywords.robot
Resource        ./resources/common_keywords_CB013288.robot

Force Tags      CA_RAN_VRF_NPS   QCD_MN_RAN   QCP_RAN_ST   SBTS00   SBTS25R2

*** Variables ***
@{custom_patterns}=       critical
...                       err\\/\\|error
...                       wrn\\/\\|warning
...                       unknown
@{custom_msg_to_skip}=    INF
${NB_NRCELLs}    6
@{patterns_lis}                PRB_POOLING.BASIC    poolId:${EMPTY}
@{expected_colums}             poolId    NrCellIdentity
# &{expected_colums_count}       poolId=${1}    NrCellIdentity=${6}

*** Test Cases ***
[1][1.0] CB013288-B7_02_Cell_addition_with_DL_UL_PRB_pooling_enabled_mixed_cell_bandwidth_mixed_nrcelltype_ABIP
    [Setup]     run keywords
    ...    Initialize Configuration For test    Init_Step_AEHCx3-Cellx6_reverse_plan.json
    ...    AND
    ...    TC Setup Action
    [Teardown]   TC Teardown Action

    # Check Initial Configuration
    Log    Check Initial Configuration
    Verify CB013288 Activation
    Set Suite Variable    ${init_cells_count}         ${6}
    Verify Total Cell Count    ${init_cells_count}

    Step 1: Configure First Cell on RMOD-7
    Step 2: Add Second Cell on RMOD-8
    Step 3: Add Third Cell on RMOD-9
    Step 4: Add Fourth Cell on RMOD-7
    Step 5: Add Fifth Cell on RMOD-8
    Step 6: Add Sixth Cell on RMOD-9
    # Finally we have 12 cell
    Verify PoolInfo    ${syslog_file_path}    ${patterns_lis}    ${expected_colums}

[1][1.0] CB013288-B7_04_Cell_deletion_with_DL_UL_PRB_pooling_enabled_ABIP
    [Setup]      run keywords
    ...    Reset Configuration for Test
    ...    AND
    ...    TC Setup Action
    [Teardown]   TC Teardown Action

    # Check Initial Configuration
    Log    Check Initial Configuration
    Verify CB013288 Activation
    Set Suite Variable    ${init_cells_count}         ${12}
    Verify Total Cell Count    ${init_cells_count}

    # Deleting Cells progressively
    Step 1: Delete Cell 12 from RMOD-9
    Step 2: Delete Cell 11 from RMOD-8
    Step 3: Delete Cell 10 from RMOD-7
    Step 4: Delete Cell 9 from RMOD-9
    Step 5: Delete Cell 8 from RMOD-8
    # Finally we keep Cell 7 on RMOD-1 as the final cell
    Verify PoolInfo    ${syslog_file_path}    ${patterns_lis}    ${expected_colums}



*** keywords ***
TC Setup Action
    Test Case Dir Preparation
    Backup SBTS Configuration    local_dir=${res_path}     filename_prefix=current_conf
    Validate SCF Plan    ${res_path}/current_conf_scf.xml
    ${Active_Alarms}=    Collect Active Alarms    alarms_path=${res_path}    alarms_prefix=current_
    Run Keyword If     ${Active_Alarms}
    ...    Fail  Warning BTS Alarm appear raise, please check the logs.
    gnbcell.Verify All Cells Are Onair
    gnb_log.Setup gNB Btslog Collector
    Set BTSLog Rad Parameters on Classical gNB


TC Teardown Action
    Run Keyword and Ignore Error    scout_utils.set_scout_config_id_tc    ${BTS_SCOUT_NAME}
    Run Keyword and Ignore Error    gnb_log.Teardown gNB Btslog Collector
    ${is_true}           Evaluate    "${GET_SNAPSHOT}" in ['yes', 'Yes', 'YES']
    Run Keyword If    ${is_true}
    ...  Run Keyword and Ignore Error  gnb_log.Collect Snapshot From gNB  log_dir=${res_path}
    ...  snapshot_coverage=Full  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword and Ignore Error    gnblog.disconnect
    Run Keyword and Ignore Error    Useful_keywords.instance_disconnect  gnbbbu
    interface.Common step trigger
