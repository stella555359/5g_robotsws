# ##-----------------------------------------------------------------------
# ##
# ## File : CB005750_EBAF_002.robot
# ##
# ##-----------------------------------------------------------------------
# #
# ##-----------------------------------------------------------------------
# #*** Settings ***
# ##-----------------------------------------------------------------------
# #Documentation
# #...    author: Zhu felix
# #...    contact: felix.zhu@nokia-sbell.com
# #...    Feature 5G_CB005750 in 5G21A program
# #
# #Library     XML   use_lxml=True
# #Library     taf.sbts.oam.coam.admin        WITH NAME   coam_admin
# #Library     taf.transport.ssh    WITH NAME    ssh
# #Library     ./resource/vm_util_resources.py
# #Library     ./resource/kw_selenium_classical.py    WITH NAME    sel
# #Resource    ./resource/vm_util_resources.robot
# #Resource    ./resource/kw_selenium_classical.robot
# #Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #Resource      ./resource/kw_CB005750.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# #
# #Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
# #...    AND     CI_interface.Common Suite Setup
# #Suite Teardown       robot_common_operations.Common Suite Teardown
# #Test Setup           robot_common_operations.Common Case Setup 
# #Test Teardown        robot_common_operations.Common Case Teardown
# #
# ## Flag added only to generate a report to Reporting Portal.
# #Force Tags    SBTS00    SBTS22R1    SBTS21B    SBTS22R2    SBTS22R3    RAN_5G
# #...   PY36
# #...           RAN_5G_TDD    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AEQY_ENB
# #
# ##-----------------------------------------------------------------------
# #*** Variables ***
# ##-----------------------------------------------------------------------
# #
# #${gnb_index}=    0
# #${new_gscn_value}=    25
# #
# #${counter}=    M55110C00002
# ##${miNrX2CB_new}=    15min
# ##${reportingIntervalPm_new}=    15min
# #
# #${DU_GNB_IP}=          ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
# #${DU_GNB_USERNAME}=    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# #${DU_GNB_PASSWORD}=    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# #
# #${DU_WEBEM_URL}=         https://${DU_GNB_IP}
# #${DU_WEBEM_USERNAME}=    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
# #${DU_WEBEM_PASSWORD}=    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
# #
# #${cell_DN}=      unknown
# #${connection}            DU_connection
# #
# ## TestVM.
# #${TEST_VM_ADDR}=        ${tl.test_pc.default_ssh_connection_details.addr}
# #${TEST_VM_USERNAME}=    ${tl.test_pc.default_ssh_connection_details.username}
# #${TEST_VM_PASSWORD}=    ${tl.test_pc.default_ssh_connection_details.password}
# #
# ## SCF with pmax modification.
# #${TARGET_SCF_PATH}=    ${CURDIR}/scf/target_scf_MRBTS-1991.xml
# #
# ## BACKUP SCF.
# #${BACKUP_SCF_PATH}=    ${CURDIR}/scf/backup_scf_file_${DU_GNB_IP}.xml
# #
# #
# #${target}                    ${output_dir}/snapshot
# #${target1}                   ${output_dir}/snapshot/snapshot_file_list.txt
# #
# #
# ##-----------------------------------------------------------------------
# #*** Test Cases ***
# ##-----------------------------------------------------------------------
# #
# #[1][1.0] CB005750_5G_EBAF_002_CB005750_5GC000169_Fault7516_EFaultId_IncorrectCellParameterSettingAl
# #    [Documentation]    *****************
# #    ...    The purpose of the test case is to verify fault
# #    ...    which notifies the operator that cell parameter configuration related to NR CELL is wrong
# #    ...    ******************
# #    ...    *******************
# #    [Teardown]    Run Keywords    coam_admin.Teardown
# #    Precondition: NR cells can be on air and no fault 7516 visible
# #    Step 1: change parameter 'gscn'
# #    Step 2: check alarm 7516 is raised
# #    Step 3: revert parameter 'gscn'
# #    Step 4: check alarm 7516 is cleared
# #    Step 5: check no new alarm should be raised after this testing
# #
# #[1][1.0] CB005750_5G_EBAC_101_5GC000159_gNB_state_management_in_WebUI
# #    [Documentation]    gNB_state_management_in_WebUI
# #    log to console    \nStep1:test_start_time
# #    ${test_start_time}=    DateTime.get current date    result_format=epoch
# #
# #    log to console    \nStep2:Open session
# #    Open session    url=${DU_WEBEM_URL}    username=${DU_WEBEM_USERNAME}    password=${DU_WEBEM_PASSWORD}
# #
# #    log to console    \nStep3:Check DU status via DU WebEM
# #    Check DU status via DU WebEM
# #
# #    log to console    \nStep4:Check SMOD status via DU WebEM
# #    Check SMOD status via DU WebEM
# #
# #    log to console    \nStep5:Check BBMOD status via DU WebEM
# #    Check BBMOD status via DU WebEM
# #
# #    log to console    \nStep6:Check RU status via DU WebEM
# #    Check RU status via DU WebEM
# #
# #    log to console    \nStep7:Check Check GNSS status via DU WebEM
# #    Check GNSS status via DU WebEM
# #
# #    log to console    \nStep8:Check Cell onAir via DU WebEM
# #    sleep    120
# #    Check Cell onAir via DU WebEM
# #
# #    log to console    \nStep9:Compute duration from a start time
# #    ${duration}=    Compute duration from a start time    ${test_start_time}
# #    puts    \n- duration = ${duration}
# #
# #[1][1.0] CB005750_5G_EBAR_101_5GC000666_01_5G_Snapshot_collection_in_WebEM
# #    [Documentation]    Snapshot collection in WebEM
# #    [Teardown]       Run Keywords       Clean files
# #    Collect snapshot    BTS_IP=${DU_GNB_IP}
# #    Unzip and Check snapshot    BTS_IP=${DU_GNB_IP}
# #
# #
# #
# #[1][1.0] CB005750_5G_EBAE_004_5GC000165_Configuration_of_measurement_and_reporting_interval_default
# #    [Documentation]    *****************
# #    ...    The purpose of this test is to verify procedure of
# #    ...    PM measurement collection and reporting according to the default
# #    ...    ******************
# #    ...    *******************
# #    [Teardown]   Run Keywords    Step 4: revert measurement and reporting intervals
# #    Precondition: check gNB can be on air
# #    Step 1: change measurement and reporting intervals
# #    Step 2: check if PM WebEM presents Collector uploaded files using the new schedule of reporting interval
# #    Step 3: check measurement counters should appear correct times during reporting interval
# #
# #
# #
# #[1][1.0] CB005750_5G_EBAE_003_5GC000165_Configuration_of_measurement_and_reporting_interval_different_then_default
# #    [Documentation]    *****************
# #    ...    The purpose of this test is to verify procedure of
# #    ...    PM measurement collection and reporting the parameter values different from the default one
# #    ...    ******************
# #    ...    *******************
# #    [Teardown]    Run Keywords    Step 4: revert measurement and reporting intervals
# #    Precondition: check gNB can be on air
# #    Step 1: change measurement and reporting intervals for 003 case
# #    Step 2: Check if PM WebEM presents Collector uploaded files using the first new schedule of reporting interval
# #    Step 3: Check if PM WebEM presents Collector uploaded files using the second new schedule of reporting interval
# #
# #
# #
# #[1][1.0] CB005750_5G_EBAN_003_5GC000341_Parameter_modification_reset_needed
# #    [Documentation]    *****************
# #    ...    The purpose of the test is to verify the gNB behavior
# #    ...    during cell reconfiguration for parameters that require gNB reset
# #    ...    ******************
# #    ...    *******************
# #    [Teardown]    Run Keywords    STEP_004 - Restore DU SCF via DU WebEM
# #    STEP_001 - Backup DU SCF via DU WebEM
# #    STEP_002 - Import DU SCF via DU WebEM
# #    STEP_003 - Wait until gNB cell onAir
# #
# #
# ##-----------------------------------------------------------------------
# #*** Keywords ***
# ##-----------------------------------------------------------------------
# #
# #
# ##-----------------------------end-of-file-------------------------------
