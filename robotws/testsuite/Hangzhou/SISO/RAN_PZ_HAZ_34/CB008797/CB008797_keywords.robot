# @Time    : 2022/3/16 9:44
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008797_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Library    check_technical_logs.py
Library     taf.selenium.sbts    WITH NAME    selenium_sbts
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Link_Diagnostic_and_Monitoring.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/rf_diagnostic_test.robot

*** Keywords ***
"${Case002-Step1}" in Parameter Edit search rapID
    CB008797 Common Keyword Setup With Selenium
    ${result}    selenium_sbts.Get Parameter Value By Global Search    filter_param=Radio access point identifier
    Should Be Empty    ${result}
    [Teardown]    CB008797 Common Keyword Teardown With Selenium

"${Case002-Step2}" check the EQM/APEQM/CABINET/SMOD-prodCodePlanned
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...    filter_param=Product code planned    abbr=prodCodePlanned    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case002-Step3}" check the EQM/APEQM/FHS-radioProtSearchOrder
    Connect to gnb coam via ssl
    ${parameter1}    Create Dictionary    parameterName=prodCodePlanned    operation=update    value=474611A.102
    ${parameter2}    Create Dictionary    parameterName=radioProtSearchOrder    operation=update    value=OBSAI
    ${parameters}    Create List    ${parameter1}    ${parameter2}
    coam.perform_object_recommissioning    connection=GNB_OAM
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/FHS-1
    ...    parameter=${parameters}
    ...    operation=create
    ...    skip_parameter_relation_errors=true
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/FHS-1
    ...    filter_param=Radio protocol search order    abbr=radioProtSearchOrder    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case002-Step4}" change radioProtSearchOrder to value 2:CPRI
    ${parameters}    Create List
    Modify Parameter On Webem And PDL Verification Failed    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/FHS-1
    ...    parameter=radioProtSearchOrder    value=CPRI
    Connect to gnb coam via ssl
    coam.perform_object_recommissioning    connection=GNB_OAM
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/FHS-1
    ...    parameter=${parameters}
    ...    operation=delete
    ...    skip_parameter_relation_errors=true
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case002-Step5}" check the EQM/APEQM/RMOD-radioMasterDN
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Radio master distinguished name    abbr=radioMasterDN    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case002-Step6}" check the EQM/HWTOP/CABLINK-firstEndpointLabel
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-1
    ...    filter_param=First endpoint port label    abbr=firstEndpointLabel    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case003-Step1}" check the MNL-productVariantPlanned
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1
    ...    filter_param=Product variant planned    abbr=productVariantPlanned    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case003-Step2}" check the MNL/MNLENT/PMMNL-eCpriMasterStatisticsInterval
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS NR eCPRI Master Statistics    abbr=eCpriMasterStatisticsInterval
    ...    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case003-Step3}" change eCpriMasterStatisticsInterval to value 5min --- PDL verification should be passed
    Modify Parameter On Webem And PDL Verification Passed    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=eCpriMasterStatisticsInterval    value=5min

"${Case003-Step4}" check the MNL/MNLENT/PMMNL-loosePhaseAndTimeStatisticsInterval
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=Loose Phase and Time Sync Statistics    abbr=loosePhaseAndTimeStatisticsInterval
    ...    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case003-Step5}" change eCpriMasterStatisticsInterval to value 15min --- PDL verification should be passed
    Modify Parameter On Webem And PDL Verification Passed    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=eCpriMasterStatisticsInterval    value=15min

"${Case008-Step1}" check the MNL/MNL_R-productVariant
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNL_R-1
    ...    filter_param=Product variant    abbr=productVariant    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case008-Step2}" check the MNL/MNLENT/SECADM-sshMaxAuthAttempts
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    filter_param=SSH maximum authentication attempts per connection    abbr=sshMaxAuthAttempts
    ...    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case008-Step3}" change sshMaxAuthAttempts to value 4 --- PDL verification should be passed
    Modify Parameter On Webem And PDL Verification Passed    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=sshMaxAuthAttempts    value=${SSH_MAX_AUTH_ATTEMPTS_VALUE}

"${Case008-Step4}" check the MNL/MNLENT/TEST/RFTHLD-bandRfTestThresholds
    Verify Parameter Same With NIDD Defination    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ...    filter_param=LTE band RF test thresholds    abbr=bandRfTestThresholds    nidd_file=${CURDIR}/TestData/CB008797_nidd.csv

"${Case008-Step5}" configure bandRfTestThresholds --- PDL verification should be failed
    Modify Parameter On Webem And PDL Verification Failed    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TEST-1/RFTHLD-1
    ...    parameter=bandRfTestThresholds    value=@{BAND_RF_TEST_THRESHOLDS_LIST}

"${Case115-Step136}" All services within tested cell are verified
    Connect to gnb coam via ssl
    FOR    ${cell_index}    IN    @{L3_CALL_CELLS_INDEX}
        LOG    Start L3 Call In ${cell_index}
        ${nr_cell_identity}    Get NR Cell Identity Via Index "${cell_index}"
        Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}
        Wait Until Keyword Succeeds    3x    5s    UE Attach And Check Throughput With Detach
        ...    global_cell_id=${cell_index}
        ...    ul_tp=100M    ul_tp_threshold=1
        ...    dl_tp=700M    dl_tp_threshold=1
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case115-Step2}" NR RAT reset is triggered via ADMIN
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_rat    rat_type=NR    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Verify BTS 5G Cells Status Is Cell Reset State
    Wait Until Keyword Succeeds    10min    60s    Verify BTS 5G Cells Status Is Normal State
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case115-Step4}" NR multiple cells block triggered from WebEM
    Selenium Login With Version
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    connection=GNB_OAM
    FOR    ${cell_info}    IN    @{cells_info}
        selenium_sbts.Block Cell    cell_idx=${cell_info['globalCellId']}
    END
    Verify BTS 5G Cells Status Is BTS Block State
    FOR    ${cell_info}    IN    @{cells_info}
        ${alarms}    coam.get_active_alarms    severity=critical    connection=GNB_OAM
        Wait Until Keyword Succeeds    5min    5s    Should Contain    '${alarms}'    ${cell_info['id']['configuration']}
    END
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case115-Step5}" NR multiple cells unblock triggered from WebEM
    Selenium Login With Version
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    connection=GNB_OAM
    FOR    ${cell_info}    IN    @{cells_info}
        selenium_sbts.Unblock Cell    cell_idx=${cell_info['globalCellId']}
    END
    Wait Until Keyword Succeeds    2min    10s    Verify BTS 5G Cells Status Is Normal State
    coam.assert_alarm_inactive    parameters=faultId=49    connection=GNB_OAM
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case118-Step1}" Run RF Diagnostic Test on Webem And Check
    Connect to gnb coam via ssl
    Selenium Login With Version
    selenium_coam.configure_rf_diagnostic_test    cell=NRCELL-9 (cell5)
    selenium_coam.start_rf_diagnostic_test
    Check General Test Information    cell_id=NRCELL-9
    Check Detailed Antenna    cell_id=NRCELL-9    RSSI_high=1
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case118-Step2}" Check SFP_R related Diagnostic data on Detailed Site View/Configuration Management
    Connect to gnb coam via ssl
    Selenium Login With Version
    General_SiSo_Link_Diagnostic_and_Monitoring
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    ...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case119-Step1}" Lock all NR cells from both cores
    Connect to gnb coam via ssl
    Lock BTS All 5G Cells
    Wait Until Keyword Succeeds    2min    10s    Verify BTS 5G Cells Status Is Cell Lock State
    Verify BTS X2LinkStatus Is "unavailable"
    Wait Until Keyword Succeeds    5min    30s    Verify The Target Alarm ID State In ENB    alarm_id=${6327}

"${Case119-Step2}" Set x2LinkLock value to lock
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/LTEENB-0
    ...    parameter=x2LinkLock    value=locked
    Verify BTS X2LinkStatus Is "unavailable"

"${Case119-Step3}" Unlock NR cells from primary core
    ${cells_distname}    Get BTS Cells DistName List Via ActiveRole    active_role=Primary
    FOR    ${dist_name}    IN    @{cells_distname}
        Modify Parameter On BTS With Activate    dist_name=${dist_name}
        ...    parameter=administrativeState    value=Unlocked
        Verify BTS Single Cell Status Is Normal State    dist_name=${dist_name}    operational_state=disabled
    END
    Wait Until Keyword Succeeds    5min    30s    Verify The Target Alarm ID State In ENB    alarm_id=${6327}

"${Case119-Step4}" Set x2LinkLock value to unlock
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/LTEENB-0
    ...    parameter=x2LinkLock    value=unlocked
    Wait Until Keyword Succeeds    10min    10s    Verify BTS X2LinkStatus Is "available"
    Wait Until Keyword Succeeds    5min    30s    Verify The Target Alarm ID State In ENB    alarm_id=${6327}    if_exist=false

"${Case119-Step5}" Unlock remain NR cells from secondary core
    ${cells_distname}    Get BTS Cells DistName List Via ActiveRole    active_role=Secondary
    FOR    ${dist_name}    IN    @{cells_distname}
        Modify Parameter On BTS With Activate    dist_name=${dist_name}
        ...    parameter=administrativeState    value=Unlocked
        Wait Until Keyword Succeeds    5min    10s    Verify BTS Single Cell Status Is Normal State    dist_name=${dist_name}
    END

"${Case120-Step1}" Check content of Radio Unit logs in snapshot
    Connect to Common Unit Master
    ${ru_index}    Set Variable    1
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    Verify RFSW Log Include In Snapshot    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ...    snapshot_path=${SAVE LOG DIRECTORY}    is_get_snapshot_via_selenium=True
    check_xml_exist_technical_logs    zip_src=${SAVE LOG DIRECTORY}
    csn.Disconnect    connection=RU_${ru_index}
    [Teardown]    csn.Disconnect    connection=ASIK Master

"${Case120-Step2}" Create new snapshot and cancel it during creation
    Selenium Login With Version    download_dir=/tmp/snapshot_ta
    selenium_coam.Snapshot Collection Settings    coverage=All log files    save_location=Local
    ${temp_snapshot_file_path}    selenium_coam.Collect Snapshot    snapshot_waiting_timeout=30
    ${cancel_result}    selenium_coam.Cancel Collect Snapshot    snapshot_waiting_timeout=600
    Sleep    60
    ${files}    List Files In Directory    path=/tmp/snapshot_ta
    Should End With    ${files[-1]}    _partial.zip
    Remove File    ${files[-1]}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

"${Case120-Step3}" Check content of Radio Unit logs in snapshot with Most important log files option
    Selenium Login With Version    download_dir=/tmp/snapshot_ta
    selenium_coam.Snapshot Collection Settings    coverage=Most important log files    save_location=Local
    ${temp_snapshot_file_path}    selenium_coam.Collect Snapshot
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

"${Case121-Step2}" create SMOD_EXT, set eutraTDDSupport to true, set nrcnOfChnBnd=1
    Connect to gnb coam via ssl
#define variables
    ${paraClassname1}    Set Variable    com.nokia.srbts.eqm:SMOD_EXT
    ${paraDistname1}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/SMOD_EXT-1
    ${paraDistname2}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10
    ${parameter1}    Set Variable    eutraTDDSupport
    ${parameter2}    Set Variable    nrcnOfChnBnd
    ${paraValue1}    Set Variable    true
    ${paraValue2}    Set Variable    1
    ${check_point1}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/SMOD_EXT-1.eutraTDDSupport
    ${check_point2}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10
#download and generate new scf file
    ${scf_file}    COAM Download scf from cluster
    scf.Load Scf    file_path=${scf_file}
    ${paraVersion}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}/EQM-1    attribute=version
    scf.add_object_to_scf    class_name=${paraClassname1}    dist_name=${paraDistname1}    version=${paraVersion}
    scf.add_element_to_scf    dist_name=${paraDistname1}    p_name=${parameter1}    value=${paraValue1}
    scf.add_element_to_scf    dist_name=${paraDistname2}    p_name=${parameter2}    value=${paraValue2}
    scf.Save Scf    file_path=${SUITE_LOG_PATH}/CB008797_case121_2.xml
    ${scf_dir}    Set Variable    ${SUITE_LOG_PATH}/CB008797_case121_2.xml
#validate scf online
    ${result}    read result validate scf    ${scf_dir}    GNB_OAM
#check point
    Should Contain    ${result}    ${check_point1}
    Should not Contain    ${result}    ${check_point2}

"${Case121-Step3}" create object LCELC
#define variables
    ${paraClassname}    Set Variable    com.nokia.srbts.mnl:LCELC
    ${paraDistname}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELC-1
    ${check_point}    Set Variable    LCELC cannot be configured on the radio module if parameter geranFrequencyBandList does not exist.
#download and generate new scf file
    ${scf_file}    COAM Download scf from cluster
    scf.Load Scf    file_path=${scf_file}
    ${paraVersion}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}/MNL-1    attribute=version
    scf.add_object_to_scf    class_name=${paraClassname}    dist_name=${paraDistname}    version=${paraVersion}
    scf.Save Scf    file_path=${SUITE_LOG_PATH}/CB008797_case121_3.xml
    ${scf_dir}    Set Variable    ${SUITE_LOG_PATH}/CB008797_case121_3.xml
#validate scf online
    ${result}    Read Result Validate Scf    ${scf_dir}    GNB_OAM
#check point
    Should Contain    ${result}    ${check_point}

"${Case121-Step4}" create productVariantPlanned to tetraBTS
#define variables
    ${paraClassname3}    Set Variable    com.nokia.srbts:MRBTSDESC
    ${paraDistname1}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1
    ${paraDistname2}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
    ${paraDistname3}    Set Variable    MRBTS-${MRBTS_ID}/MRBTSDESC-0
    ${paraDistname4}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${parameter1}    Set Variable    productVariantPlanned
    ${parameter2}    Set Variable    location
    ${parameter3}    Set Variable    radioTopology
    ${parameter4}    Set Variable    actTrsSepaNSARanSharing
    ${paraValue1}    Set Variable    tetraBTS
    ${paraValue2}    Set Variable    HZ
    ${paraValue3}    Set Variable    ccc
    ${paraValue4}    Set Variable    true
    ${check_point2}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1.location
    ${check_point3}    Set Variable    MRBTS/MRBTSDESC.radioTopology
    ${check_point4}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}.actTrsSepaNSARanSharing
#download and generate new scf file
    ${scf_file}    COAM Download scf from cluster
    scf.Load Scf    file_path=${scf_file}
    ${paraVersion}    scf.get_mo_attribute    dist_name=MRBTS-${MRBTS_ID}    attribute=version
    scf.add_object_to_scf    class_name=${paraClassname3}    dist_name=${paraDistname3}    version=${paraVersion}
    scf.Modify Scf Element    value=${paraValue1}    dist_name=${paraDistname1}    p_name=${parameter1}
    scf.add_element_to_scf    dist_name=${paraDistname2}    p_name=${parameter2}    value=${paraValue2}
    scf.add_element_to_scf    dist_name=${paraDistname3}    p_name=${parameter3}    value=${paraValue3}
    scf.Modify Scf Element    value=${paraValue4}    dist_name=${paraDistname4}    p_name=${parameter4}
    scf.Save Scf    file_path=${SUITE_LOG_PATH}/CB008797_case121_4.xml
    ${scf_dir}    Set Variable    ${SUITE_LOG_PATH}/CB008797_case121_4.xml
#validate scf online
    ${result}    read result validate scf    ${scf_dir}    GNB_OAM
#check point
    Should Contain    ${result}    ${check_point2}
    Should Contain    ${result}    ${check_point3}
    Should Contain    ${result}    ${check_point4}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case124-Step1}" Lock all radios of both cores
    CB008797 Common Keyword Setup With Selenium
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    2min    10s    Verify BTS 5G Cells Status Is RU Lock State
    Verify BTS RUs Status Is RU Lock State

"${Case124-Step2}" SBTS block is triggered from WebEM. Faults and states are checked
    selenium_sbts.block_site
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS22R3' or '${release}'=='SBTS22R4'    Wait Until Keyword Succeeds    1min
    ...    10s    Verify BTS 5G Cells Status Is BTS Block And RU Lock State
    ...    ELSE    Wait Until Keyword Succeeds    1min    10s
    ...    Verify BTS 5G Cells Status Is BTS Block And RU Lock State    availability_status=off line
    Verify BTS RUs Status Is BTS Block And RU Lock State
    Verify BTS Alarm Exist    fault_id=50    fault_name=BTS blocked

"${Case124-Step3}" SBTS unblock is triggered from WebEM. Faults and states are checked
    selenium_sbts.unblock_site
    Wait Until Keyword Succeeds    10min    10s    Verify BTS 5G Cells Status Is BTS Unblock And RU Lock State
    Wait Until Keyword Succeeds    10min    10s    Verify BTS RUs Status Is RU Lock State
    Verify BTS Alarm Not Exist    fault_id=50    fault_name=BTS blocked

"${Case124-Step4}" Unlock all radios of both cores
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    10s    Verify BTS 5G Cells Status Is Normal State
    Verify BTS RUs Status Is Normal State
    [Teardown]    CB008797 Common Keyword Teardown With Selenium

"${Case124-Step5}" Make L3 call for one cell from each core
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Connect to gnb coam via ssl
    FOR    ${cell_index}    IN    @{CASE124_L3_CALL_CELLS_INDEX}
        LOG    Start L3 Call In ${cell_index}
        ${nr_cell_identity}    Get NR Cell Identity Via Index "${cell_index}"
        Enable BTS NR Cell Via ENB Cell LnRelGnbCellId    nr_cell_id=${nr_cell_identity}
        Wait Until Keyword Succeeds    3x    5s    UE Attach And Check Throughput With Detach
        ...    global_cell_id=${cell_index}
        ...    ul_tp=100M    ul_tp_threshold=1
        ...    dl_tp=700M    dl_tp_threshold=1
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case125-Step1}" From webem select "reset to test dedicated state", click "Enable" button
    CB008797 Common Keyword Setup With Selenium
    selenium_coam.enable_test_dedicated_state
    Wait Until Keyword Succeeds    5min    10s    Verify BTS Status Is "Test"
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    Should Be True    ${alarm_status}

"${Case125-Step2}" From Webem, select "TestModels", into UL or DL TestModels state
    [Documentation]    Reference Suite Level Parameter
    ...    LOCAL_CELL    FRC_INDEX    REPORT_TIME_INTERVAL    TEST_MODEL    P_MAX
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS22R3'    selenium_coam.start_5g_uplink_test    local_cell=${LOCAL_CELL_22R3}
    ...    frc_index=${FRC_INDEX}    reporting_time_interval=${REPORT_TIME_INTERVAL}
    ...    ELSE    selenium_coam.start_5g_uplink_test    local_cell=${LOCAL_CELL_AFTER_22R4}
    ...    frc_index=${FRC_INDEX}    reporting_time_interval=${REPORT_TIME_INTERVAL}
    selenium_coam.wait_for_5g_uplink_test_to_start
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    Should Be True    ${alarm_status}
    selenium_coam.stop_5g_uplink_test
    selenium_coam.wait_for_5g_uplink_test_to_stop
    Run Keyword If    '${release}'=='SBTS22R3'    selenium_coam.start_5g_downlink_test    local_cell=${LOCAL_CELL_22R3}
    ...    test_model=${TEST_MODEL}    p_max=${P_MAX}
    ...    ELSE    selenium_coam.start_5g_downlink_test    local_cell=${LOCAL_CELL_AFTER_22R4}
    ...    test_model=${TEST_MODEL}    p_max=${P_MAX}    timeout=300    polarization=P_plus45_or_0
    selenium_coam.wait_for_5g_downlink_test_to_start
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    Should Be True    ${alarm_status}
    selenium_coam.stop_5g_downlink_test
    selenium_coam.wait_for_5g_downlink_test_to_stop

"${Case125-Step3}" From webem select "reset to test dedicated state",click "Disable" button
    selenium_coam.disable_test_dedicated_state
    Wait Until Keyword Succeeds    10min    10s    Verify BTS Status Is "OnAir"
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    Should Be True    ${alarm_status}
    [Teardown]    CB008797 Common Keyword Teardown With Selenium

"${Case126-Step1}" Delete cells deployed on secondary core and activate plan
    Connect to gnb coam via ssl
    ${scf_file}    COAM Download scf from cluster
    Set Test Variable    ${TEMP_SCF_126}    ${scf_file}
    Selenium Login With Version
    ${cells_distname}    Get BTS Cells DistName List Via ActiveRole    active_role=Secondary
    FOR    ${dist_name}    IN    @{cells_distname}
        ${rest}    ${cell_id}    Split String From Right    ${dist_name}    -    1
        selenium_coam.remove_object    object_name=${dist_name}
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cell_id}
    END
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_id}
    selenium_coam.remove_element   dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${cellgrp_id}  abbr=refNrCellGroup
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=300
    Wait Until Keyword Succeeds    10min    10s    Verify BTS Status Is "OnAir"
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

"${Case126-Step2}" Add cells deleted in step1 and activate plan
    Connect to gnb coam via ssl
    coam.perform_commissioning    bts_id=${MRBTS_ID}    scf_file=${TEMP_SCF_126}
    ...    skip_parameter_relation_errors=true    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    10s    Verify BTS Status Is "OnAir"
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

CB008797 Common Keyword Setup With Selenium
    Connect to gnb coam via ssl
    Selenium Login With Version

CB008797 Common Keyword Teardown With Selenium
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Run Keyword And Ignore Error    COAM Teardown gnb connections

Check UE Throughput With BTS Block And Unblock
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${global_cell_id}
    ...    ${ul_tp}    ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}
    ...    ${ue_index}=${0}
    CB008797 Common Keyword Setup With Selenium
    Verify UE Voice Call Can Be Performed
    ${ul_tp_before}    ${dl_tp_before}    UE Attach And Check Throughput With Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}
    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}    iperf_type=via_app
    selenium_sbts.block_site
    coam.assert_alarm_active    parameters=faultId=50    timeout=60    connection=GNB_OAM
    Wait Until Keyword Succeeds    1min    10s    Verify BTS 5G Cells Status Is BTS Block State
    selenium_sbts.unblock_site
    coam.assert_alarm_inactive    parameters=faultId=50    timeout=300    connection=GNB_OAM
    Wait Until Keyword Succeeds    10min    30s    Verify BTS 5G Cells Status Is Normal State
    Verify UE Voice Call Can Be Performed
    ${ul_tp_after}    ${dl_tp_after}    UE Attach And Check Throughput With Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=${UL_TP}    ul_tp_threshold=${UL_TP_THRESHOLD}
    ...    dl_tp=${DL_TP}    dl_tp_threshold=${DL_TP_THRESHOLD}    iperf_type=via_app
    ${status}    Evaluate    -${THROUGHPUT_ERROR_VALUE} < ${ul_tp_before}-${ul_tp_after} < ${THROUGHPUT_ERROR_VALUE}
    Should Be Equal As Strings    '${status}'    'True'
    ${status}    Evaluate    -${THROUGHPUT_ERROR_VALUE} < ${dl_tp_before}-${dl_tp_after} < ${THROUGHPUT_ERROR_VALUE}
    Should Be Equal As Strings    '${status}'    'True'
    [Teardown]    CB008797 Common Keyword Teardown With Selenium
