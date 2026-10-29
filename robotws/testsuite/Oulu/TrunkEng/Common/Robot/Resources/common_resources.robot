*** Settings ***
Documentation
...  Author:   Essi Passoja
...  Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library      taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi_calculations
Library      taf.ul.oam_kpi_calculations.utilities   WITH NAME  oam_kpi_utilities
Library      taf.rfrl.common_resources.oam_kpi.report_oam_kpi  WITH NAME  report_oam_kpi
Library      taf.sbts.oam.coam.admin  WITH NAME  ADMIN
Library      taf.sw.scout  WITH NAME  scout
Library      taf.ue  WITH NAME  UE
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger  WITH NAME  LOG
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SCF  WITH NAME  SCF
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.SMODs  WITH NAME  SMODS
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.BBMODs  WITH NAME  BBMODS
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.RMODs  WITH NAME  RMODS
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.Antennae  WITH NAME  ANTENNAE
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.CellOperations  WITH NAME  CELLS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.BTS  WITH NAME  BTS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RealtimeAlarms  WITH NAME  RT_ALARMS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.CheckAlarms  WITH NAME  ALARMS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.IMSChecks  WITH NAME  IMS_CHECKS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.BTSStatus  WITH NAME  BTSSTATUS
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.FSPUnits  WITH NAME  FSPUNITS
Library      testsuite.Oulu.TrunkEng.Common.Python.Resources.BTSInfo  WITH NAME  BTSINFO
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SwConfig  WITH NAME  SWCONFIG
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.CollectLogs  WITH NAME  COLLECTLOGS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SyslogSearch  WITH NAME  SYSLOGSEARCH
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.CellResources  WITH NAME  CELL_RESOURCES
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.python_to_robot  WITH NAME  python_helper
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.pass_rate
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.WorkflowTool    WITH NAME    WFT
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.ReservationContent  WITH NAME  ENV_RESERVATION
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.GetFromAdmin  WITH NAME  GET_FROM_ADMIN
Library      testsuite.Oulu.TrunkEng.Common.Reporting.HtmlReport  WITH NAME  HTMLREPORT
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RFS  WITH NAME  RFS
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RealUEDataTransfer  WITH NAME  DataTransfer
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.PowerBreakers  WITH NAME  PowerBreakers
Library      testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingBBMOD
Library      testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.CollectAndCheckL1StartupcheckFile  WITH NAME  L1_STARTUP_CHECK


*** Variables ***
${TEST_CASE}                0
${ADMIN_FOLDER}
${ROBOT_TEMPLATE}           # Robot HTML requires initializing of variables ROBOT_TEMPLATE, TEST_NAME, OMKPI_CASE
${TEST_NAME}
${OMKPI_CASE}
${KW_SUCCESS}               ${True}
${SERIAL_CONSOLE}           ${False}
${WARN_FROM_COUNTER}        ${True}
${FAIL_FAST}                ${False}
${SUITE_ADMIN_DIR}
${UE_IN_USE}
${SCOUT_TL_NAME}            True
${SKIP_KPI_CALCULATIONS}    ${False}
# CNI-127210
${CNI127210}                ${True}
${SUPRESSFAULTS_PATH}       testsuite/Oulu/TrunkEng/Common/Resources/SupressFaultsFiles/suppressFaults.txt
${REMOTE_SCF}
${SYSLOG_FILE_PATH}         /home/ute/syslogs
${CHECK_L1_STARTUP_CHECK_LOGS}     ${False}
${HIGH_AVAILABILITY_ENVIRONMENT}   ${False}

*** Keywords ***
RFS Specific Setup
    [Documentation]          If RFS is set to True, this keyword is called to setup the remote and RFS master BTS.
    ...                      If MASTER is This mplane ip is set as remote admin connection. If MASTER is Other then
    ...                      default admin connection is set to mplane ip and LMP ip is set as remote.
    [Arguments]              ${ADMIN_FOLDER}
    ${OTHER_BTS_MPLANE}=     RFS.Find Other Bts Mplane Ip
    Set Suite Variable       ${OTHER_BTS_MPLANE}
    ${MASTER}=               RFS.Set RFS Value If Not Set  MASTER  This
    IF  '${MASTER}' == 'Other'
        ${remote_name}=       SCF.Get Path Of Current Scf File
        ${path_to_remote_scf}=  Rename File In Logs  ${remote_name}   .xml   _remote.xml
        Run Keyword And Continue On Failure   Print Text To Eventlog  Add remote to file name ${remote_name}
        Set Suite Variable  ${REMOTE_SCF}  ${path_to_remote_scf}
        ADMIN.Teardown Admin  connection=default
        ADMIN.Connect to      admin_api_log_dir=${ADMIN_FOLDER}    bts_host=${OTHER_BTS_MPLANE}
        SCF.Get SCF           update_scf_path=${True}
        ${LMP_OR_MPLANE_IP}=  Get Variable Value  ${DEFAULT_ADMIN_IP}   192.168.255.129
        ADMIN.Connect to      admin_api_log_dir=${ADMIN_FOLDER}    bts_host=${LMP_OR_MPLANE_IP}     name=remote
    ELSE
        ADMIN.Connect to      admin_api_log_dir=${ADMIN_FOLDER}    bts_host=${OTHER_BTS_MPLANE}  name=remote
        ${path_to_remote_scf}=  SCF.Get SCF   extra_name=remote   update_scf_path=${False}   add_timestamp_to_extra=${True}
        ...                     admin_connection=remote
        Set Suite Variable  ${REMOTE_SCF}  ${path_to_remote_scf}
    END

Common Suite Setup
    [Documentation]          Setup test suite: Makes admin connection to BTS and defines log directory. If user have give some
    ...                      variable changing TAGs in reservation/QC grid, for example TEST_LOOPS=5 they are set in this KW.
    Print Text To Eventlog   Used test suite: ${SUITE SOURCE}
    Run Keyword And Continue On Failure    Kill All Admin Connections
    ${ADMIN_FOLDER}=         Create Admin Folder
    Run Keyword And Continue On Failure    Get Ute Cloud Init File
    Set Suite Variable       ${WARN_FROM_COUNTER}  ${True}
    Set Suite Variable       ${SUITE_ADMIN_DIR}    ${ADMIN_FOLDER}
    Set Suite Variable       ${KW_SUCCESS}         ${True}
    Set Suite Variable       ${COLLECT_SYSINFO}    ${False}
    Run Keyword              Check If Variable Tags Are Given And Change Values
#    ADMIN.Connect to         admin_api_log_dir=${ADMIN_FOLDER}    bts_host=192.168.255.129
    ${RFS}=                  RFS.Set RFS Value If Not Set  RFS  ${False}
    ${admin_conn_ok}=        Connect Suite Admin   always_default=${True}    from_common=${True}
    IF   '${admin_conn_ok}' != '${True}'
        Set Suite Variable   ${KW_SUCCESS}    ${False}
        Fail    Could not make admin connection to BTS in suite setup.
    END
    IF   '${RFS}' == '${True}'
        Run Keyword          RFS Specific Setup   ${ADMIN_FOLDER}
    END
# CNI-127210
# Check if TMO sw is in use and suppressed faults should be disabled
    ${TMO_SW}=               Check If Active Sw Is Asked    SBTS24R3_ENB_0000_000425_
    Run Keyword If           '${TMO_SW}' == '${True}'   Run Keywords   Set Suite Variable   ${CNI127210}   ${False}  AND
    ...                      Print Text To Eventlog   TMO SW is in use. Suppress faults are disabled.
    Run Keyword And Continue On Failure    Check If Suppressfaults are in use  ${CNI127210}  ${SUPRESSFAULTS_PATH}

Common Suite Teardown
    [Documentation]          Teardown test suite: Close admin connections to BTS.
    ADMIN.Teardown All Aliases For Admin
    Teardown Realtime Alarms Admin
    Run Keyword And Continue On Failure    Kill All Admin Connections

Common Test Setup
    [Documentation]          Test run setup: Collects BTS information to BTS class, initiates expected BTS states to
                        ...  BTSStatus class and collects SCF.xml.
                        ...  If user has given BREAK_LOKI and LOKI_TO_BREAK variables,
                        ...  BTSStatus class and collects SCF.xml. If user has given BREAK_LOKI and LOKI_TO_BREAK variables,
                        ...  breaks the given LOKI and sets suite variables of faulted loki. BREAK_LOKI can have value True
                        ...  or False and LOKI_TO_BREAK can have for example
                        ...  ABIO1/LOKI#A, ABIO1/LOKI#B, ABIO2/LOKI#A, BBMOD3/LOKI#B...
                        ...  If user has given BBMODS_MASK variable, sets the mask and that breaks the affected BBMODs and sets
                        ...  suite variables of faulted BBMODs/cells/RMODs. BBMODS_MASK can have hexadecimal number in
                        ...  the range [0x02-0xEE] as a value. Breaks the given BBMODs and sets suite variables of faulted BBMODs.
                        ...  BBMODS_MASK variable can have for example
                        ...  BBMODS_MASK=0x02, BBMODS_MASK=0x04, BBMODS_MASK=0x06, BBMODS_MASK=0x20...
    Get BTS Configs
    Update SW Information
    Initiate BTS Status Check
    ${SW}=                   Get Active Sw Of Bts
    Set suite metadata       SW version    ${SW}
    ${suite_variables}=      Get variables
    Set Suite Variable       ${SUITE_VARIABLES_IN_SETUP}   ${suite_variables}
    Run Keyword If           "\${BREAK_LOKI}" in $suite_variables and "\${LOKI_TO_BREAK}" in $suite_variables   Break Another Loki
    IF   "\${BBMODS_MASK}" in $suite_variables
        Run Keyword  Faulty Bbmods With Hpd Debug Config File   ${BBMODS_MASK}
        Run Keyword And Continue On Failure    COLLECTLOGS.Collect Snapshot   connection_name=default
        Run Keyword And Continue On Failure    COLLECTLOGS.Clear Swdl Path Variables
    END
    Run Keyword And Continue On Failure    BTS.Check If Netboot Is Active And Deactivate It

Common Test Teardown
    [Documentation]    If scout testline is given request scout analyze. Test run teardown: Stops writing to debug -file.
    Write Html               ${ROBOT_TEMPLATE}  ${OMKPI_CASE}
    ${SW_TT}=                Get Active Sw Of Bts
    Set suite metadata       SW version    ${SW_TT}
    ${suite_variables}=      Get variables
    Run Keyword If     "\${BREAK_LOKI}" in $suite_variables and "\${LOKI_TO_BREAK}" in $suite_variables   Run Keyword And Ignore Error
    ...                Run Keywords    Restore Another Loki   AND
    ...                               Check Active Alarms    connection=default  test_step_txt=from restoring LOKI   AND
    ...                               Check BTS Status
    Run Keyword If     "\${BBMODS_MASK}" in $suite_variables   Run Keyword And Ignore Error
    ...                Run Keywords    Restore Mask And Suite Variables   AND
    ...                               Check Active Alarms    connection=default  test_step_txt=from restoring BBMODs mask   AND
    ...                               Check BTS Status
    Run Keyword If     "\${SCOUT_TL_NAME}" in $suite_variables   Check If Scout Tl Is Given
    Run Keyword If     "\${USER_DEFINED_RESET}" in $suite_variables  User Defined Reset
    Run Keyword And Continue On Failure    BTS.Check If Netboot Is Deactive And Activate It
    IF    ${HIGH_AVAILABILITY_ENVIRONMENT}
        Run Keyword And Continue On Failure    BTS.Activate Netboot Secondary Smod
    END
    Stop Test Script Debug

Common Preconditions
    [Documentation]          Precondition checks for the test. Checks active alarms and BTS status.
    Run Keyword And Continue On Failure    Print Test Loop
    Run Keyword And Continue On Failure    Print Sw Versions To Eventlog
    Run Keyword And Continue On Failure    Check Active Alarms    test_step_txt=from Preconditions
    Run Keyword And Continue On Failure    Check BTS Status
    Run Keyword And Continue On Failure    Check Value Of Restart Counter    info_text=Preconditions check
    Run Keyword If                         '${UE_IN_USE}' == '${True}'  Run Keywords
    ...                                    Run Keyword And Continue On Failure  Prepare UEs  AND
    ...                                    Run Keyword And Continue On Failure  Make Data Transfer Test
    ${RFS}=                                RFS.Set RFS Value If Not Set  RFS  ${False}
    Run Keyword If                         ${RFS} == ${True}     Run Keyword And Continue On Failure  RFS.Check Other Bts Cells
    Run Keyword If                         "\${OMKPI_CASE}" in $SUITE_VARIABLES_IN_SETUP and "${OMKPI_CASE}" == "${True}"
    ...                                    Run Keyword And Continue On Failure   Check If Graceful Cell Shutdown
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Common Conditions Failed    Preconditions

Common Postconditions
    [Documentation]          Postcondition checks for the test. Checks alarm history and BTS status.
    IF  "\${FAULT_CAUSE_DEGRADED_CELLS}" in $SUITE_VARIABLES_IN_SETUP
        ${DEGRADED_CELLS_FAULT_WAS_ACTIVE}=  Check If Fault Is Active  ${FAULT_CAUSE_DEGRADED_CELLS}  set_fault_to_allowed=${True}
        Set Suite Variable   ${DEGRADED_CELLS_FAULT_WAS_ACTIVE}
        IF   '${DEGRADED_CELLS_FAULT_WAS_ACTIVE}' == '${True}' and '${SERIAL_CONSOLE}' == '${False}'
            Print Text To Eventlog         Add degraded cells set by faults that were active given in FAULT_CAUSE_DEGRADED_CELLS variable
            Run Keyword And Continue On Failure   Set Serial Console Connection Status  value=${True}
        END
    END
    Run Keyword And Continue On Failure    Check Alarm History  reset_alarms=True  test_step_txt=from Postconditions
    Run Keyword And Continue On Failure    Check BTS Status
    Run Keyword And Continue On Failure    Check If Cell Down And No Active Alarm And Wait For Fault
    IF   '${UE_IN_USE}' == '${True}'
# W_BF_DT variable (WAIT_AFTER_TEST_BEFORE_DATATRANSFER) is used to add delay before starting the data transfer in postconditions
        ${wait_for_dt}=   Get Variable Value   ${W_BF_DT}   ${False}
        Run Keyword If    '${wait_for_dt}' != '${False}'  Run Keyword And Continue On Failure   Sleep   ${wait_for_dt}
        Run Keyword And Continue On Failure  Make Data Transfer Test
    END
    ${RFS}=                                RFS.Set RFS Value If Not Set  RFS  ${False}
    Run Keyword If                         ${RFS} == ${True}     Run Keyword And Continue On Failure  RFS.Check Other Bts Cells
    ${asib_in_env}=                        Check If Smod With Given Version    ASIB    print_to_eventlog=${False}
    Run Keyword If                         '${asib_in_env}' == '${True}'  Run Keyword And Continue On Failure
    ...                                    Check If Print In Syslog And If Is Warn From It
    ...     print_to_search=\[INFO: RIO DOWN\]
    ...     warn_print=Check if this "Well-known" ASIB HW related Intel inside problem (PR799064 & PR799103), don't create pronto!
#    Run Keyword And Continue On Failure    Check If Print In Syslog And If Is Error From It
#    ...     print_to_search=ERR\/coco\/PortControl, validateSfpVersion: SFP28 on REL5\.1
#    ...     error_print=A known issue with SFP28 on REL5.1 (ERR/coco/PortControl, validateSfpVersion: SFP28 on REL5.1)
    IF  ${CHECK_L1_STARTUP_CHECK_LOGS}
        Run Keyword And Continue On Failure    Get And Check L1 Startupcheck Files
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Common Conditions Failed    Postconditions

Common Conditions Failed
    [Documentation]         This KW is called in teardown of Precondition and Postcondition checks.
    ...                     If this is called it sets KW_SUCCESS to False and Fails the test.
    [Arguments]             ${CONDITION}
    Print Text To Eventlog  Failure noticed during ${CONDITION} check
    Set Suite Variable      ${KW_SUCCESS}    ${False}
    Run Keyword If          '${CONDITION}' == 'Preconditions'    COLLECTLOGS.Collect Snapshot   extra_name=preconditions
    Fail                    ${CONDITION} check failed

Check If Scout Tl Is Given
    [Documentation]    Check if SCOUT_TL_NAME variable is not empty.
    Run Keyword If     '${SCOUT_TL_NAME}' != '${EMPTY}'    Request Scout SCF

Request Scout SCF
    [Documentation]    Setup Scout API Library. Send request to Scout to fetch new SCF and wait for success
    ...                for timeout seconds. Returns Scout SCF id. Collected SCF file will be analyzed in Scout and the
    ...                analysis will be send to Reporting Portal where will be matched with your execution.
    ${SCOUT_TL_NAME}=  BTS.Find UTE TL name
    Run Keyword And Ignore Error  scout.setup_scout  scout_testline_name=${SCOUT_TL_NAME}
    Run Keyword And Ignore Error  scout.request_scf  timeout=300
    Run Keyword And Ignore Error  scout.teardown_scout_api
