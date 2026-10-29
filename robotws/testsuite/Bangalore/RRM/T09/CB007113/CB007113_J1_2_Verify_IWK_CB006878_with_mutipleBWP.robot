*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LO     VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD
...             RAN_5G_TDD    SBTS00    CONFIGURED   CRT   TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :authors: Kshitij Tyagi
...              :contact: kshitij.tyagi@nokia.com
...         This user scenario describes the common gNB behavior at activation of the CB006878 feature when 5GC000937
...         is active and it verifies
...         the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL traffic
...         rate and switch to large BWP on DL traffic increase.CB007113 sub-B already supports the unused PUCCH L1 PRB
...         Library allocated from BBRM can be used by PUSCH. CB007113 sub-J needs align with CB006878 which support
...         Library pCSI physical PRBs in frequency domain are available for PUSCH.
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         testsuite/Bangalore/RRM/5GET_BLR/5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/Setup_Env.robot
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/Airphone.robot
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/WTS_Runner_Keywords.robot
Library          testsuite/Bangalore/RRM/5GET_BLR/resources/python/BIP_Capture.py
Library          testsuite/Bangalore/RRM/5GET_BLR/resources/python/CPRT_Capture.py
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/common_log_collection.robot
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/PM_Counters.robot
Resource         testsuite/Bangalore/RRM/5GET_BLR/CB007113/resources/load_based_validation_keywords.resource
Library          testsuite/Bangalore/RRM/5GET_BLR/CB007113/resources/check_cell_expected_prballocation.py
Resource         ./testsuite/Bangalore/RRM/5GET_BLR/resources/robot/Common_Keywords.robot
#Resource         ./testsuite/Bangalore/RRM/5GET_BLR/ASOE_RJIO/L3_call.robot

Suite Setup         Run keywords     Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Update bsr package
...                 AND     Update GNB R&D Parameters   ${LOG_PATH}   ${r&d_parameter}
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_7113.json
...                AND    Vendor File Download Modify and Commissioning    ${LOG_PATH}    ${bbHwVariant}
...     ${csSize}    ${l1PoolType}   ${maxNumLayerPrbL1Sp_DL}   ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}
...     ${maxNumStreamPrbL1Sp_UL}    ${maxNumWbStreamPrbL1Sp}
...                 AND    Start WTS Using WTS_Runner           ${wts_cfg_file}
...                 AND    sleep    50s
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Setup.Get Sos Report

Test Teardown      Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
...                AND     Check resource hanging

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_7113_rjio.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
###
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
${scf_file}      /home/ute/Downloads/.*xml*
${QFI_ID}    1
${TRF_ID2}    2
${TRF_ID}    1
${PM_dir1}
${PM_dir2}
${Low_data_counter_value_cell1}
${Low_data_counter_value_cell4}
${High_data_counter_value_cell1}
${High_data_counter_value_cell4}
@{PhysCellID}      50    51    52
${r&d_parameter}     0x420068=7;0x58069C=1;0x580612=1;0x580686=0xa;0x58057c = 0x2800;0x58057a = 0x4
${bbHwVariant}    ASOE
${csSize}    48
${l1PoolType}    NR_L1_Loki_TDD_FR1_eCPRI_IQF_Symm_RJconf50MHz
${maxNumLayerPrbL1Sp_DL}    768
${maxNumStreamPrbL1Sp_DL}    768
${maxNumLayerPrbL1Sp_UL}    384
${maxNumStreamPrbL1Sp_UL}   768
${maxNumWbStreamPrbL1Sp}    812
*** Test Cases ***
[1]CB007113_J1_2_Verify_IWK_CB006878_with_mutipleBWP_LongPUCCH_configured_FR1_TDD
    [Documentation]   verifies the behavior of a single UE with multiple PDUs Switch to power saving BWP on low DL/UL
     ...    traffic rate and switch to large BWP on UL traffic increase in 4 cells.

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Log     btslog
    ${crnti_list}=      MultiUE Register should be Successful    1  3
    Set test variable     ${crnti_list}     ${crnti_list}
    Stop Log    btslog          test_scenario=ueattach_TC2
    MultiUE Trigger UL Traffic for SA    1  3    Traffic_rate=mbps     ul_rate=10          trf_id=${TRF_ID}
    Start low UL data in all cells
    sleep    10s
    Run Keyword And Continue On Failure     Collect 6878 counter for low data and verify
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for low data
    Start high UL data in all cells
    sleep    20s
    Run Keyword And Continue On Failure     Capture TTI traces and validate BWPID for high data
    Run Keyword And Continue On Failure     Collect 6878 counter for high data and verify
    Wait Until Keyword Succeeds    12 min    3 min     PRB Validation
    Run Keyword and Ignore Error    Stop MultiUE Data Traffic for SA     1  3
    Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1  3

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Start low UL data in all cells
    Start Log       btslog
    MultiUE Trigger UL Traffic for SA    1  3    Traffic_rate=kbps     ul_rate=45          trf_id=${TRF_ID}
    sleep   10s    reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_lowdata_TC2


Capture TTI traces and validate BWPID for low data
    ${bwpid}    Create List     2     2    2
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start high UL data in all cells
	Start Log        btslog
    MultiUE Trigger UL Traffic for SA    1  3    Traffic_rate=mbps     ul_rate=145          trf_id=${TRF_ID}
    Run Keyword And Continue On Failure    wtsrunner.bearer_stats_clear     ue=${ue_id}    pdu=${Pdu_session_ID}
    sleep   10s      reason=Wait for successful BWP switch
    Stop Log        btslog      test_scenario=ue_highdata_TC2

Capture TTI traces and validate BWPID for high data
    ${bwpid}    Create List     1     1    1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata
    ...     ${crnti_list}     ${bwpid}    ${Branch_22R1}

Collect 6878 counter for low data and verify
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Low_data_counter_value_cell1}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-2
    ${Low_data_counter_value_cell4}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C10002    moc=NRCELL-3
    Should be true      ${Low_data_counter_value_cell1} > ${Low_data_counter_value_cell4}

Collect 6878 counter for high data and verify
    Wait until the next Measurement Period starts
    ${PM_dir2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${High_data_counter_value_cell1}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-2
    ${High_data_counter_value_cell4}=    Get PM counter value    ${PM_dir2}    pi_id=M55308C10002    moc=NRCELL-3
    Should be true      ${High_data_counter_value_cell1} > ${High_data_counter_value_cell4}


Collect TTI Traces
    [Arguments]    ${dir_name}     ${sleep_time}
    Start Log      ttitrace
	Sleep    ${sleep_time}s
    ${tti_log_path}    Stop Log      ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}
    log to console   ${tti_log_path}
	Decode TTI Trace    ${dir_name}
	[Return]    ${tti_log_path}

Verify expected PRB allocation
    FOR     ${cellid}    IN    @{PhysCellID}
        ${UL_Check}    Verify Expected PRB Allocation in UL
        ...     ${TTI_log_dir}[ttitrace]      ${cellid}    46    273    128
        ${DL_Check}    Verify Expected PRB Allocation in DL
        ...     ${TTI_log_dir}[ttitrace]      ${cellid}    48    273    128
    END

Verify Expected PRB Allocation in UL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in ul...
    ${Result}   check_cell_expected_prballocation.check_ulexpectedprb      ${csv_file_path}/output_ul_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}

Verify Expected PRB Allocation in DL
    [Arguments]   ${csv_file_path}      ${cellid}    ${minallocprb}    ${maxallocprb}    ${expected_prb}
    log to console   verify Expected prb allocation in dl...
    ${Result}   check_cell_expected_prballocation.check_dlexpectedprb      ${csv_file_path}/output_dl_formated.csv
    ...     ${cellid}      ${minallocprb}
    ...     ${maxallocprb}    ${expected_prb}
    run keyword and continue on failure     should be true     ${Result}
    [Return]   ${Result}
#Update GNB R&D Parameter
#   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
#   Get GNB Swconfig File    ${LOG_PATH}
#   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
#   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
PRB Validation
    ${TTI_log_dir}     Collect TTI Traces      dir_name=cell_idle     sleep_time=2
    set test variable    ${TTI_log_dir}
    Verify expected PRB allocation

Modify Vendor File DL
    [Arguments]  ${LOG_PATH}    ${bbHwVariant}    ${csSize}    ${l1PoolType}
    ...     ${maxNumLayerPrbL1Sp}=${maxNumLayerPrbL1Sp_DL}
    ...     ${maxNumStreamPrbL1Sp}=${maxNumStreamPrbL1Sp_DL}     ${maxNumStreamPrbL1Sp_DL}=${maxNumWbStreamPrbL1Sp}

    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=${bbHwVariant}
    ...  direction=DL
    ...  csSize=${csSize}
    ...  l1PoolType=${l1PoolType}
    ${data_to_be_modified}=    Create Dictionary
    ...  maxNumLayerPrbL1Sp=${maxNumLayerPrbL1Sp}
    ...  maxNumStreamPrbL1Sp=${maxNumStreamPrbL1Sp}
    ...  maxNumWbStreamPrbL1Sp=${maxNumStreamPrbL1Sp_DL}
    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_list  listname=bbL1SpPrbInitCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  xml_path=${path_in_xml}

Modify Vendor File UL
    [Arguments]  ${LOG_PATH}    ${bbHwVariant}    ${csSize}    ${l1PoolType}
    ...     ${maxNumLayerPrbL1Sp}=${maxNumLayerPrbL1Sp_UL}
    ...    ${maxNumStreamPrbL1Sp}=${maxNumStreamPrbL1Sp_UL}     ${maxNumStreamPrbL1Sp_UL}=${maxNumWbStreamPrbL1Sp}

    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=${bbHwVariant}
    ...  direction=UL
    ...  csSize=${csSize}
    ...  l1PoolType=${l1PoolType}
    ${data_to_be_modified}=    Create Dictionary
    ...  maxNumLayerPrbL1Sp=${maxNumLayerPrbL1Sp}
    ...  maxNumStreamPrbL1Sp=${maxNumStreamPrbL1Sp}
    ...  maxNumWbStreamPrbL1Sp=${maxNumStreamPrbL1Sp_UL}
    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_list  listname=bbL1SpPrbInitCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${LOG_PATH}/vendor_lte.xml
    ...  xml_path=${path_in_xml}

Vendor File Download Modify and Commissioning
    [Arguments]   ${LOG_PATH}    ${bbHwVariant}    ${csSize}    ${l1PoolType}   ${maxNumLayerPrbL1Sp_DL}
    ...     ${maxNumStreamPrbL1Sp_DL}   ${maxNumLayerPrbL1Sp_UL}
    ...     ${maxNumStreamPrbL1Sp_UL}    ${maxNumWbStreamPrbL1Sp}
    [Documentation]    This keyword Download, modifies vendor file and upload it back to GNB and triggers FUll commissioning
    ...     vendor modifications with respect to CB009215 feature
    Download Vendor File From GNB   ${LOG_PATH}
    Modify Vendor File DL   ${LOG_PATH}    ${bbHwVariant}    ${csSize}    ${l1PoolType}   ${maxNumLayerPrbL1Sp_DL}
    ...     ${maxNumStreamPrbL1Sp_DL}    ${maxNumWbStreamPrbL1Sp}
    Modify Vendor File UL   ${LOG_PATH}    ${bbHwVariant}    ${csSize}    ${l1PoolType}   ${maxNumLayerPrbL1Sp_UL}
    ...     ${maxNumStreamPrbL1Sp_UL}    ${maxNumWbStreamPrbL1Sp}
    Upload Modified Vendor File And Trigger Full Commissioning   ${LOG_PATH}

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Update GNB R&D Parameters
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   admin.Setup admin    bts_host=${BTS_ADDRESS}   bts_port=${BTS_PORT}   use_ssl=${USE_SSL}  name=swc
   admin.download_software_config    ${LOG_PATH}/swconfig_gnb.txt   connection=swc
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=OAM-conn
   ssh.upload_file    local_path=${LOG_PATH}/swconfig_gnb.txt     remote_path=/ffs/run/swconfig.txt    connection=OAM-conn
   ssh.send_command     command=crasign /ffs/run/swconfig.txt   connection=OAM-conn
   ssh.send_command     command=craverify /ffs/run/swconfig.txt*    connection=OAM-conn
   ssh.disconnect   connection=OAM-conn