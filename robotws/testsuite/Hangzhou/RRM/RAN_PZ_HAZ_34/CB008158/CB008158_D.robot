*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown   AND    CI_interface.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py

Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK

*** Variables ***
${scf_relative_dir}    commissionings/HGZ


${PMQAP_PATH}    CELLS/NRCELL-1/NRPMQAP-17
${btsname}    SBTS_4G_FXED
${pmcounter_path_based_on_release}    CELLS



*** Test Cases ***
[1]CB008158-D_18_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_FR1_TDD_NSA
    [Documentation]    case is running in NSA testline
     CB008158-D case Preparation
	 #Online modify parameters actNrpmqapProfiles to true
	 Set PMQAP related parameters
     UE attach and start traffic
     Run keyword and continue on failure    Check DRX related counters when actCDrx is false
     Online modify parameters actCDrx to true
	 UE attach and start traffic
	 Run keyword and continue on failure    Check DRX related counters when actCDrx is true
     UE attach and start traffic    dl_tp=300K
	 Run keyword and continue on failure    Check INIT_BURST related counters
	 Detach UE

[1]CB008158-D_20_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_for_PMQAP_FR1_TDD_SA
    [Documentation]    case is running in SA testline:S21 CDRX is not working Inactive counter is always 0
     CB008158-D case Preparation
	 Online modify parameters actNrpmqapProfiles to true
	 Set PMQAP related parameters
	 Online modify parameters actCDrx to false
     UE attach and start traffic
     Run keyword and continue on failure    Check DRX related counters when actCDrx is false
	 Detach UE


[1]CB008158-D_25_Initial_Burst_scheduling_delay_in_DL_for_PMQAP_FR1_TDD_SA
    [Tags]    HAZ3_T03
    [Documentation]    case is running in SA testline
    CB008158-D case Preparation
	Online modify parameters actNrpmqapProfiles to true
	Online modify parameters actCDrx to true
	Set PMQAP related parameters
    UE attach and start traffic    dl_tp=100K
	Run keyword and continue on failure    Check INIT_BURST related counters
    UE attach and start traffic    dl_tp=300K
	Run keyword and continue on failure    Check INIT_BURST related counters
    Detach UE

*** Keywords ***
UE attach and start traffic
    [Arguments]    ${dl_tp}=100K
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=${dl_tp}   iperf_port_dl=50227
    Wait for one counter period     interval_time=5min

Online modify parameters actCDrx to true
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_NR_CELL_NAME}
    ...                                         parameter=actCDrx
    ...                                         operation=update
    ...                                         value=true
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Online modify parameters actCDrx to false

    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_NR_CELL_NAME}
    ...                                         parameter=actCDrx
    ...                                         operation=update
    ...                                         value=false
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Online modify parameters actNrpmqapProfiles to true
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_NR_BTS_NAME}
    ...                                         parameter=actNrpmqapProfiles
    ...                                         operation=update
    ...                                         value=true
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Check DRX related counters when actCDrx is true
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	Check DRX_ACT related counters    check_time=${check_time}
	Check DRX_INACT related counters when actCDrx is true    check_time=${check_time}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check DRX related counters when actCDrx is false
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	Check DRX_ACT related counters    check_time=${check_time}
	Check DRX_INACT related counters when actCDrx is false    check_time=${check_time}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check DRX_ACT related counters
    [Documentation]    M55308C00057:DL_INIT_SCHD_DLY_DRX_ACT
    ...                M55308C00058:DL_INIT_SCHD_DLY_DRX_ACT_DNM
	...                M55356C00004 DL_INIT_SCHD_DLY_DRX_ACT_PMQAP
	...                M55356C00006 DL_INI_SCHD_DLY_DRXACT_PMQP_D
    [Arguments]    ${check_time}
    ${value_M55308C00057}    Get PM Counter via Webem for CB008158    counter_id=M55308C00057    check_time=${check_time}
	${value_M55308C00058}    Get PM Counter via Webem for CB008158    counter_id=M55308C00058    check_time=${check_time}

	${value_M55356C00004}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00004    check_time=${check_time}    full_path=${full_path_qci7_M55356C00004}
	${value_M55356C00006}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00006    check_time=${check_time}    full_path=${full_path_qci7_M55356C00006}
	Should be True      ${value_M55308C00057}>0
	Should be True      ${value_M55308C00058}>0
	Should be True      ${value_M55308C00057}==${value_M55356C00004}
	Should be True      ${value_M55308C00058}==${value_M55356C00006}
    Should be True      ${value_M55308C00057}/${value_M55308C00058}<10000

Check DRX_INACT related counters when actCDrx is true
    [Documentation]    M55308C00060:DL_INIT_SCHD_DLY_DRX_INACT
    ...                M55308C00061:DL_INIT_SCHD_DLY_DRX_INACT_DNM
	...                M55356C00005:DL_INT_SCHD_DLY_DRX_INAC_PMQAP
	...                M55356C00007:DL_INT_SCHD_DLY_DRX_INA_PMQP_D

    [Arguments]    ${check_time}
    ${value_M55308C00060}    Get PM Counter via Webem for CB008158    counter_id=M55308C00060    check_time=${check_time}
	${value_M55308C00061}    Get PM Counter via Webem for CB008158    counter_id=M55308C00061    check_time=${check_time}

	${value_M55356C00005}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00005    check_time=${check_time}    full_path=${full_path_qci7_M55356C00005}
	${value_M55356C00007}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00007    check_time=${check_time}    full_path=${full_path_qci7_M55356C00007}
    Should be True      ${value_M55308C00060}>0
	Should be True      ${value_M55308C00061}>0
	Should be True      ${value_M55308C00060}==${value_M55356C00005}
	Should be True      ${value_M55308C00061}==${value_M55356C00007}
    Should be True      ${value_M55308C00060}/${value_M55308C00061}<300000

Check DRX_INACT related counters when actCDrx is false
    [Documentation]    M55308C00060:DL_INIT_SCHD_DLY_DRX_INACT
    ...                M55308C00061:DL_INIT_SCHD_DLY_DRX_INACT_DNM
	...                M55356C00005:DL_INT_SCHD_DLY_DRX_INAC_PMQAP
	...                M55356C00007:DL_INT_SCHD_DLY_DRX_INA_PMQP_D

    [Arguments]    ${check_time}
    ${value_M55308C00060}    Get PM Counter via Webem for CB008158    counter_id=M55308C00060    check_time=${check_time}
	${value_M55308C00061}    Get PM Counter via Webem for CB008158    counter_id=M55308C00061    check_time=${check_time}

	${value_M55356C00005}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00005    check_time=${check_time}    full_path=${full_path_qci7_M55356C00005}
	${value_M55356C00007}    Get PM Counter via Webem for CB008158
	...        counter_id=M55356C00007    check_time=${check_time}    full_path=${full_path_qci7_M55356C00007}
    Should be True      ${value_M55308C00060}==0
	Should be True      ${value_M55308C00061}==0
	Should be True      ${value_M55356C00005}==0
	Should be True      ${value_M55356C00007}==0

Check INIT_BURST related counters
    [Documentation]    M55350C00029:DL_INIT_SCHD_DLY_GNB
    ...                M55350C00030:DL_INIT_BURST_PDCP
	...                M55159C00007:DL_INIT_SCHD_DLY_GNB_PMQAP
	...                M55159C00008:DL_INIT_BURST_PDCP_PMQAP
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
    ${value_M55350C00029}    Get PM Counter via Webem for CB008158    counter_id=M55350C00029    check_time=${check_time}
	${value_M55350C00030}    Get PM Counter via Webem for CB008158    counter_id=M55350C00030    check_time=${check_time}

	${value_M55159C00007}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00007    check_time=${check_time}    full_path=${full_path_qci7_M55159C00007}
	${value_M55159C00008}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00008    check_time=${check_time}    full_path=${full_path_qci7_M55159C00008}
	Should be True      ${value_M55350C00029}>0
	Should be True      ${value_M55350C00030}>0
	Should be True      ${value_M55350C00029}==${value_M55159C00007}
	Should be True      ${value_M55350C00030}==${value_M55159C00008}
    Should be True      ${value_M55350C00029}/${value_M55350C00030}<300000

CB008158-D case Preparation
    Run keyword If     ${MRBTS_ID}==933    CB008158 SA case Preparation
	Run keyword If     ${MRBTS_ID}==940    CB008158 NSA case Preparation
	${stream}    Get Stream
    #Set test variable    ${PARAMETERS_TO_CB008158_pmqap_add_17}    ${PARAMETERS_TO_CB008158_pmqap_add_17_${stream}}
	#Run keyword If     ${MRBTS_ID}==940    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_17}
	#Run keyword If     ${MRBTS_ID}==933    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_7}
    #Run keyword If     ${MRBTS_ID}==933    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_4}
    #Run keyword If     ${MRBTS_ID}==933    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB008158_pmqap_add_1}

Set PMQAP related parameters
    ${stream}    Get Stream
	Connect to Common Unit Master
	selenium login and disable screen lock
    ${btsname}    selenium_coam.get_bts_name
	Run keyword If     '${stream}'!='SBTS24R1'    Set test variable    ${pmcounter_path_based_on_release}    [${btsname}] ${MR_NR_BTS_NAME}
	Run keyword If     '${stream}'=='SBTS24R1'    Set test variable    ${pmcounter_path_based_on_release}    CELLS
    Run keyword If     ${MRBTS_ID}==933    Set test variable    ${PMQAP_PATH}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1
	Run keyword If     ${MRBTS_ID}==940    Set test variable    ${PMQAP_PATH}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17
    Set test variable    ${full_path_qci7_M55356C00004}    ${PMQAP_PATH}/UESPQ/DL_INIT_SCHD_DLY_DRX_ACT_PMQAP
    Set test variable    ${full_path_qci7_M55356C00006}    ${PMQAP_PATH}/UESPQ/DL_INI_SCHD_DLY_DRXACT_PMQP_D
    Set test variable    ${full_path_qci7_M55356C00005}    ${PMQAP_PATH}/UESPQ/DL_INT_SCHD_DLY_DRX_INAC_PMQAP
    Set test variable    ${full_path_qci7_M55356C00007}    ${PMQAP_PATH}/UESPQ/DL_INI_SCHD_DLY_DRX_INA_PMQP_D
    Set test variable    ${full_path_qci7_M55159C00007}   ${PMQAP_PATH}/PDLTQ/DL_INIT_SCHD_DLY_GNB_PMQAP
    Set test variable    ${full_path_qci7_M55159C00008}  ${PMQAP_PATH}/PDLTQ/DL_INIT_BURST_PDCP_PMQAP
	[Teardown]  Run keyword and ignore error    selenium logout and close browser

