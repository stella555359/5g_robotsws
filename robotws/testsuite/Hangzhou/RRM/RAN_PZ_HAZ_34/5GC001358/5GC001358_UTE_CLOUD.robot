# *** Settings ***
# Documentation
# ...   author: Qian Jianwu
# ...   contact: jianwu.qian@nokia-sbell.com
# ...   squad group: mmw_sg3
# ...   Feature 5GC001358_B
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Link_Diagnostic_and_Monitoring.robot
# Resource    ${BASIC_PATH_5G}/General_RU_Module_Certificate_Integrity.robot
# Resource    ./Resources/5GC001358_common_keyword.robot
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKR_ABILB1_AZQG_ENB   SBTS00   CRT_UTE
# ...    PY36
# 
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND    Coam Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    Coam Suite Teardown
# Test Setup     robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# *** Variables ***
# ${if_commissioning}   False
# &{TOP_DOMAIN_NUMBER_MODIFY}    abbr=topDomainNumber    dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
# ...                            filter_param=ToP domain number    new_value=43
# &{TOP_DOMAIN_NUMBER_ORIGIN}    abbr=topDomainNumber    dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
# ...                            filter_param=ToP domain number    new_value=24
# @{para_modify}    &{TOP_DOMAIN_NUMBER_MODIFY}
# @{para_origin}    &{TOP_DOMAIN_NUMBER_ORIGIN}
# &{fault_16}       faultId=${16}
# &{fault_4298}     faultId=${4298}
# *** Test Cases ***
# [1]5GC001358-C_013_CB005793_General_SiSo_upgrade_from_CPRI_to_eCPRI
#     [Tags]
#     [Setup]    Run Keywords    Coam Test Setup    AND    robot_common_operations.Common Case Setup
#     ${stream}    get stream from version    ${Active_SW_version}
#     run keyword if    '${stream}'=='SBTS22R3'    TDDCPRI_eCPRI_switch_on_WebEM    switch_to_radio_protocol=ECPRI
#     [Teardown]    Run Keywords    Coam Test Teardown    AND    robot_common_operations.Common Case Teardown
# 
# [1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Documentation]
#    ...    The purpose of this test case is to validate installation of Nokia Vendor Certificate and factory trust chains.
#    [Timeout]    20 minutes
#    [Tags]
#    [Setup]    robot_common_operations.Common Case Setup
#    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#    Check If BTS Is OnAir
#    Save snapshot
#    Verify if the snapshot contains the RFSW logs    snapshot_file=${snapshot_path}
#    run keyword and ignore error    admin_cli.teardown    connection=default
#    [Teardown]     Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]5GC000399_eCPRI_Basic_configuration_over_RP1
#     [Documentation]
#     ...    empty.
#     [Tags]
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
#         ${ru_type}    get ru type    ru_index=${ru_index}
#         #${PC_soap_path}    Download soap Log from RU    log_path=${SAVE LOG DIRECTORY}    ru_alias=RU_${ru_index}
#         csn.Disconnect    connection=RU_${ru_index}
#         #check basic configuration by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
#     END
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    csn.Disconnect  connection=ASIK Master
#     ...    AND    run keyword and ignore error    coam.teardown    connection=GNB_OAM
# 
# [1][1.0] 5GC000561_eCPRI_sync_counters
#     [Documentation]
#     ...    empty.
#     [Tags]
#     Selenium Login With Version
#     ${origin_value}    Change NCPRI PM Interval with version    interval=5min
#     selenium logout and close browser
#     Wait until keyword succeeds    30 min    5 min    Check PM counter exception    counter_id=M40102C0
#     ...    exp_counter=4800    counter_type=Transport
#     Wait until keyword succeeds    30 min    5 min    Check PM counter exception    counter_id=M40102C1
#     ...    exp_counter=2400    counter_type=Transport
#     Selenium Login With Version
#     Change NCPRI PM Interval with version    interval=15min
#     selenium logout and close browser
#     sleep    900s
#     Wait until keyword succeeds    30 min    5 min    Check PM counter exception    counter_id=M40102C0
#     ...    exp_counter=14400    counter_type=Transport
#     Wait until keyword succeeds    30 min    5 min    Check PM counter exception    counter_id=M40102C1
#     ...    exp_counter=7200    counter_type=Transport
#     Selenium Login With Version
#     Change NCPRI PM Interval with version    interval=${origin_value}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    selenium logout and close browser
# 
# [1][1.0] General_SiSo_SOAP_RP1_verification
#     [Documentation]
#     ...    empty.
#     [Tags]
#     Connect to gnb coam via ssl
#     #Connect to Common Unit Master
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         Perform RU Reset    ru_index=${ru_index}
#         Wait Until Keyword Succeeds    8min    30s    RU Should Be Offline    ru_index=${ru_index}
#         sleep  300
#         Wait Until Keyword Succeeds    8min    2min    verify all cells should be onair
#         Connect to Common Unit Master    alias=ASIK Master
#         Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
#         ${ru_type}    get ru type    ru_index=${ru_index}
#         #Run Keyword And Continue On Failure    SiSo SOAP RP1 verification  ru_index=${ru_index}    ru_type=${ru_type}
#         csn.Disconnect  connection=RU_${ru_index}
#     END
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    csn.Disconnect  connection=ASIK Master
#     ...    AND    run keyword and ignore error    coam.teardown    connection=GNB_OAM
# 
# [1][2.0] General_SiSo_BTS_startup_with_RF_delayed_startup
#     [Documentation]
#     ...    empty.
#     [Tags]
#     Connect to gnb coam via ssl
#     Perform RU Power Off    ru_index=1      model=hbte
#     sleep    5 sec
#     Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=1
#     Wait Until Keyword Succeeds    3 min    20 sec    Expect Fault Should Present    faultId=${10}
#     Cell Should Be Disabled
#     Perform RU Power On    ru_index=1       model=hbte
#     Wait Until Keyword Succeeds    3 min    20 sec    Expect Fault Should Present    faultId=${10}
#     Wait until keyword succeeds    5 min    1min    RU Should Be Online    ru_index=1
#     COAM Wait for gnb ready and cell setup
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    coam.teardown    connection=GNB_OAM
# 
# [1][2.0] General_SiSo_BTS_startup_with_delayed_RF_link_setup
#     [Documentation]
#     ...    empty.
#     [Tags]
#     Connect to gnb coam via ssl
#     ASIx Power Off
#     Perform RU Power Off    ru_index=${1}    model=HBTE
#     sleep    15s
#     ASIx Power On
#     Wait Until Keyword Succeeds    10min    1min    Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    15min    1min    COAM Check GNB ASIK status
#     Wait Until Keyword Succeeds    15min    1min    COAM Check GNB ABIL status
#     sleep    10min
#     Wait For Expect Fault Present  faultId=10  timeout=20min
#     RU Should Be Power Off    ru_index=${1}
#     Perform RU Power On     ru_index=${1}    model=HBTE
#     sleep    5min
#     Wait Until Keyword Succeeds   15min    1min     COAM Check GNB RU status
#     Wait Until Keyword Succeeds    10min     1min     verify all cells should be onair
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    coam.teardown    connection=GNB_OAM
# 	...    AND    run keyword and ignore error    Perform RU Power On     ru_index=${1}    model=HBTE
# 
# [1][2.0] General_SiSo_ RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Documentation]
#     ...    empty.
#     [Tags]
#     [Timeout]    1 hour
#     Connect to gnb coam via ssl
#     wait until keyword succeeds    15min   30s    COAM Check GNB cell on air
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master    alias=ASIK Master
#     Connect to Capacity Unit Loner AZQG    alias=ABIL Loner_1
#     Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_LIST}
#     Connect to RU With Allocated IP
#     ${ru_reset_tag}    gnb_classical_hangzhou.Create RU temp file
#     run keyword and ignore error    csn.Disconnect  connection=RU
#     run keyword and ignore error    csn.Disconnect  connection=RU_1
#     run keyword and ignore error    csn.Disconnect  connection=ABIL Loner_1
#     run keyword and ignore error    csn.Disconnect  connection=ASIK Master
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     Perform BTS Site Reset
#     Wait Until Keyword Succeeds  3 min  30 sec   Connect to gnb coam via ssl
#     run keyword and ignore error    Wait For Expect Fault Present   faultId=${7300}   timeout=420
#     Wait Until Keyword Succeeds    8 min   1 min     COAM Check GNB cell on air
#     Connect to Common Unit Master
#     Connect to Capacity Unit Master AZQG    hw_slot=${1}
#     Connect to Capacity Unit Loner AZQG    hw_slot=${1}
#     Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM
#     Connect to RU With Allocated IP
#     gnb_classical_hangzhou.Verify RU temp file disappeared     last_ru_tag=${ru_reset_tag}
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT_LIST}
#     run keyword and ignore error    csn.Disconnect  connection=RU
#     run keyword and ignore error    csn.Disconnect  connection=RU_1
#     run keyword and ignore error    csn.Disconnect  connection=ABIL Loner
#     run keyword and ignore error    csn.Disconnect  connection=ABIL Master
#     run keyword and ignore error    csn.Disconnect  connection=ASIK Master
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     [Teardown]     Run Keywords    robot_common_operations.Common Case Teardown
# 
# [1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    Purpose of this case it to check RF module support in SW build.
#     ...    *******************
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     Selenium Login With Version
#     ${output_tmp}    selenium_coam.get_ru_info
#     ${RU_info}    set variable    &{output_tmp}[Status]
#     should match regexp    &{RU_info}[Operational state]    (E|e)nabled
#     should match regexp    &{RU_info}[Administrative state]    Unlocked
#     should match regexp    &{RU_info}[Procedural status]    configured
#     Connect to gnb coam via ssl
#     ${ru_type_init}    get ru type    ru_index=1
#     set suite variable  ${ru_type_init}
#     Verify content of TargetBD file
#     Verify content of BPF file
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     [Teardown]    Run Keywords    selenium logout and close browser
# 
# [1][1.0] 5GC000560_eCPRI_sync_generic_startup_at_RU
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test is to verify eCPRI sync generic startup
#     ...    ******************
#     [Tags]
#     ${stream}    get stream from version    ${Active_SW_version}
#     run keyword if    '${stream}'=='SBTS23R1'    Check eCPRI PTP State via Btsom Log
#     ...    ELSE    Check eCPRI PTP State via Btsom Log    check_content=0
# 
# [1][1.0] 5GC000560_eCPRI_PTP_Failure
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test is to verify when set wrong input sync for RAU
#     ...    the syncstatus and lockstatus changed right both on webUI and RU soap log
#     ...    ******************
#     [Tags]
#     [Setup]    PTP Precondition
#     ${sync_old}    get sync info of GNB
#     set suite variable  ${sync_old}
#     set sync info of GNB
#     check sync status change of GNB
#     Wait For Expect Fault Present    faultId=${16}    timeout=1200
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     Wait For Expect Fault Present    faultId=${4298}    timeout=1200
#     check sync info of RU    status='abnormal'
#     set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
#     Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
#     sleep    60s
#     Wait Until Keyword Succeeds    10 min    1 min    check sync info of RU    status='normal'
#     Wait until keyword succeeds    20 min    1min   verify all cells should be onair
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error    set sync info of GNB
#     ...    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}    AND
# 	...    robot_common_operations.Common Case Teardown
# 
# [1][1.0] General_SiSo_RU_module_reset_from_GUI
#     [Documentation]
#      ...    empty.
#     [Tags]
#     Perform BTS Site Reset
#     sleep    5min
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    20 min    1min   verify all cells should be onair
#     General_SiSo_RF_module_reset_from_GUI
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
# 
# [1][2.0] General_SiSo_Cell_lock_and_unlock
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test case is to verify Reset site shouldn't be performed after cell lock/unlock.
#     ...    ******************
#     [Tags]
#     [Setup]
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Selenium Login With Version
#     Check all cells onAir
#     Get BTSId
#     Lock cell
#     Confirm cell status is locked
#     Unlock cell
#     Confirm cell status is unlocked
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     run keyword and ignore error    selenium logout and close browser
#     [Teardown]    Run Keywords    Run keyword and continue on failure    Unlock cell
# 	...    AND    robot_common_operations.Common Case Teardown
# 	...    AND    admin_cli.teardown    connection=default 
# 
# [1][1.0] General_SiSo_RU_lock_unlock
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test case is to verify Reset site shouldn't be performed and L3 call works as normal after ru lock/unlock.
#     ...    ******************
#     [Timeout]    20 minutes
#     [Tags]
#     [Setup]
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Selenium Login With Version
#     Check If BTS Is OnAir
#     Lock RU via WebEM
#     Run keyword and continue on failure    Check if all RU is locked
#     Unlock RU via WebEM
#     Check if all RU is unlocked
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     L3 call in unlocked RU
#     run keyword and ignore error    admin_cli.teardown    connection=default
#     [Teardown]     Run Keywords
#     ...    Run Keyword And Ignore Error    Selenium Logout And Close Browser
#     ...    AND    Run Keyword And Ignore Error    UE teardown
# 	...    AND    robot_common_operations.Common Case Teardown
# 
# [1][1.0] OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test case is to verify success rate of Radio Unit reset activated from WebUI interface.
# 
#     ...    ******************
#     [Tags]
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Check If BTS Is OnAir
#     Perform RU Reset repetition via WebEM     repitition_num=1
#     Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    15 min    20 sec    Check all cells onAir
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     UE attach and check tp    tp_direction=both    dl_tp=100M    ul_tp=100M    exp_dl_tp=50    exp_ul_tp=50
#     run keyword and ignore error    admin_cli.teardown    connection=default
# 
# [1][1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test case is to verify Reset site shouldn't be performed after cell lock/unlock.
#     ...    ******************
#     [Tags]
#     [Setup]
#     Perform BTS Site Reset
#     sleep    5min
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    20 min    1min   verify all cells should be onair
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Selenium Login With Version
#     Check all cells onAir
#     Get BTSId
#     Lock cell
#     Confirm cell status is locked
#     Unlock cell
#     Confirm cell status is unlocked
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     UE attach and check tp    tp_direction=both    dl_tp=100M    ul_tp=100M    exp_dl_tp=50    exp_ul_tp=50
#     run keyword and ignore error    selenium logout and close browser
#     run keyword and ignore error    admin_cli.teardown    connection=default
#     [Teardown]    Run Keywords
#     ...    Run Keyword And Ignore Error    Unlock cell
#     ...    AND    Run Keyword And Ignore Error    UE teardown
# 	...    AND    robot_common_operations.Common Case Teardown   
# 
# [1][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Documentation]
#     ...    *****************
#     ...    The purpose of this test is to check whether configured BTS components are visible in WebUI.
#     ...    ******************
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Selenium Login With Version
#     Connect to gnb coam via ssl
#     ${ru_type_init}    get ru type    ru_index=1
#     set suite variable  ${ru_type_init}
#     Check RF config via WebEM
#     run keyword and ignore error    selenium logout and close browser
#     run keyword and ignore error    admin_cli.teardown    connection=default
#     [Teardown]     Run Keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]5GC000399_eCPRI_FREERUN_state_handling
#    [Documentation]
#     ...    *****************
#     ...    The purpose of this test is to verify FREERUN state handling for 5G eCPRI RU.
#     ...    ******************
#     [Tags]
#     [Setup]    399 Case Setup
#     COAM Update several parameters via webUI    parameters_to_update_via_webui=${para_modify}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     Wait For Expect Fault Present   faultId=${16}     timeout=180
#     Wait For Expect Fault Present   faultId=${4298}     timeout=180
#     ${allowed_fault_list}    Create list    @{exist_fault}    ${fault_16}    ${fault_4298}
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_fault_list}
#     Set parameters via webUI   parameters_to_update_via_webui=${para_origin}
#     Validate And activate Plan
#     Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
# 	admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Wait Until Keyword Succeeds    300 sec   5 sec     Check all cells onAir
#     Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}
#     run keyword and ignore error    admin_cli.teardown    connection=default
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     [Teardown]   Run Keyword And Ignore Error    Run Keywords    Restore Parameter If Test Case Failed
#     ...          parameters_to_update_via_webui=${para_origin}    AND
#     ...          399 Case TearDown    AND    robot_common_operations.Common Case Teardown
# 
# [1][2.0] General_SiSo_Link_Diagnostic_and_Monitoring
#     [Documentation]
#     ...    *****************
#     ...    This test case has been introduced to cover SFP and QSFP monitoring that is mainly used for troubleshooting
#     ...    purposes or on new installation, in case of SFP/QSFP optical interface problem between Radio Units and DU
#     ...    ******************
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     COAM Check All Cells Onair    connection=GNB_OAM
#     General_SiSo_Link_Diagnostic_and_Monitoring
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    coam.teardown    connection=GNB_OAM
# 
# [1][2.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#      [Documentation]
#     ...    *****************
#     ...    The purpose of this test case is to verify that 5G BTS can report fault 1900:
#     ...   EFaultId_FrConfiguringFailed after configuring frequency to out of range value of selected band.
#     ...    ******************
#     [Tags]
#     [Setup]
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     COAM Check All Cells Onair    connection=GNB_OAM
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
#     Selenium Login With Version
#     ${nrarfcn}  ${gscn}  get origin nraradcn and gscn    cell_id=1
#     ${origin_params}  generate nrarfcn gscn modify parameters   nrarfcn=${nrarfcn}   gscn=${gscn}    cell_id=1
#     Scf para modify    parameters_to_update_via_webui=${PARA_ARFCN_629942}
#     Wait until keyword succeeds    15min    20s    Expect Fault Should Present    faultId=1900    alarmId=7116
#     Selenium Login With Version
#     modify parameters on webem    modify_params=${origin_params}
#     Wait until keyword succeeds    15min    20s    Expect Fault Should Absent    faultId=1900
#     Wait until keyword succeeds    15min    30s    COAM Check All Cells Onair    connection=GNB_OAM
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     run keyword and ignore error    selenium logout and close browser
#     run keyword and ignore error    admin_cli.teardown    connection=default
# 	[Teardown]   Run Keyword And Ignore Error    Run Keywords    Restore Parameter If Test Case Failed
#     ...          parameters_to_update_via_webui=${origin_params}    AND
#     ...          Selenium Logout And Close Browser    AND    robot_common_operations.Common Case Teardown
# 
# [1][1.0] 5GC000584_RU_Module_Certificate_Integrity
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    1min    20s    COAM Check All Cells Onair    connection=GNB_OAM
#     General_RU_Module_Certificate_Integrity
#     run keyword and ignore error    coam.teardown    connection=GNB_OAM
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Coam Test Teardown
# 
# #[1]5GC001358-C_007_5GC002452_Dynamic_SFP_Parameters_saved_into_PM_counters_for_RU
# #    [Tags]
# #    [Timeout]    60 min
# #    ${modify_params}  create list
# #    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
# #    ...    filter_param=Performance measurement data reporting interval  p_name=reportingIntervalPm    value=15min
# #    append to list  ${modify_params}  ${item}
# #    Selenium Login And Disable Screen Lock
# #    Modify Parameters On Webem   modify_params=${modify_params}
# #	${wait_time}    Get wait value minutes    interval=15min
# #    sleep    ${wait_time}min
# #    sleep    15min
# #    Wait Until Keyword Succeeds    40x    120s    Check quantity of RD files on BTS for AZQG
# #    ${parsed_files}=    Get snapshot and return parsed RD files for AZQG
# #    ${RMOD_SFP_dict}=    step_keywords.Get RMODs info
# #    Set test variable    ${measurementType}    SFPRM
# #    Check counters from SFP monitoring- file iteration for AZQG    ${parsed_files}    ${RMOD_SFP_dict}    ${measurementType}
# #    [Teardown]   Run Keywords        Remove Directory    ${unzipped}    recursive=True
# #    ...    AND     Selenium Logout And Close Browser
# 
# [1]5GC001358-C_014_CB005793_General_SiSo_upgrade_from_eCPRI_to_CPRI
#     [Tags]
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Coam Test Setup
#     Connect to gnb coam via ssl
#     ${stream}    get stream from version    ${Active_SW_version}
#     run keyword if    '${stream}'=='SBTS22R3'    TDDCPRI_eCPRI_switch_on_WebEM    switch_to_radio_protocol=CPRI
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Coam Test Teardown
# 
# 
# *** Keywords ***
# Download soap Log from RU
#     [Documentation]    Author: lanwen.cai@nokia-sbell.com
#     [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
#     csn.Download File    remote_path=/ram/UnitOAM_SOAP_Log.xml    local_path=${log_path}/UnitOAM_SOAP_Log0.xml   connection=${ru_alias}
#     ${local_path}    set variable    ${log_path}/UnitOAM_SOAP_Log0.xml
#     [Return]    ${local_path}
# 
