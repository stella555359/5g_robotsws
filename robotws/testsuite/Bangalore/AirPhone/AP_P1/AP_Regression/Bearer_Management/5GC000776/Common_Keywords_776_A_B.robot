*** Settings ***
Documentation      Common keyword file for 776A_B feature
Library         Collections
Library         ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library         ../../../Resources/Python/bearer_utilities.py    WITH NAME    bearer

Resource        ../../../Resources/robot/gnb.robot
Resource        ../../../Resources/robot/ute_setup.robot
Resource        ../../../Resources/robot/wts.robot
Resource        ../../../Resources/robot/swconfig_keywords.robot
Resource        ../../../Resources/Variables/Common_Variables.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
${WTS_CFG_PATH}         ${CURDIR}/cfg
&{RD_FLAGS}             0x580017=1    0x580019=1    0x580011=0    0x580012=0    0x580013=0    0x580014=0    0x58000E=0
#   0x580017,0x580019 -  DL and UL Rank is set to 1 (13Mbps (DL) and 5Mbps (UL) is the maximum limit)
#   0x580011,0x580012,0x580013,0x580014 - DL and UL link adaptation is being disabled
#   0x58000E - mcs is set to 0

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC000776
    Modify gnb swconfig file
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom

Suite Teardown
    Common Suite Teardown Keywords
    Disable feature flags
    Restore to Original    ${downloaded_swconfig_path}
    Wait for gNB To Be Ready

Start DL Data Transfer
    [Arguments]   ${bearer}   ${ue_id}   ${speed}   ${timeout}=${DEFAULT_DATATIMEOUT}
    wts.Start Downlink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Sleep   ${timeout}

Get DL data transfer rate
    [Arguments]   ${bearer}   ${ue_id}
    ${out}=    Execute Egate Command and wait for data    bearer_stats id\=${bearer} ue\=${ue_id} dir\=dl dc_cell_group\=scg
    Create File       ${OUTPUT_DIR}/dl_${bearer}.txt    ${out}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'

    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN
    [Return]    ${average_dl}

Start UL Data Transfer
    [Arguments]   ${bearer}   ${ue_id}   ${speed}   ${timeout}=${DEFAULT_DATATIMEOUT}
    wts.Start Uplink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Sleep   ${timeout}

Get UL data transfer rate
    [Arguments]   ${bearer}   ${ue_id}
    ${out}=    Execute Egate Command and wait for data    bearer_stats id\=${bearer} ue\=${ue_id} dir\=ul dc_cell_group\=mcg
    Create File       ${OUTPUT_DIR}/ul_${bearer}.txt    ${out}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'

    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN
    [Return]    ${average_ul}

Check data rate ratio of bearers according to scheduling weights
    [Arguments]    ${scheduling_weight_data_rate}=${SCHEDULING_WEIGHT_DATARATE}
    ${ratio_matched}    bearer.check_data_rate_scheduling_weight_ratio    ${scheduling_weight_data_rate}
    Run Keyword If    '${ratio_matched}' == 'False'    Fail    Preconfigured Scheduling Weight to Throughput ratio doesn't match
    ...    ELSE    Log    Preconfigured Scheduling Weight to Throughput ratio matches

Store scheduling weight and data rate
    [Arguments]    ${scheduling_weight}    ${data_rate}
    set to dictionary    ${SCHEDULING_WEIGHT_DATARATE}    ${scheduling_weight}    ${data_rate}

Initialise Scheduling Weight to Data Rate Dictionary
   &{SCHEDULING_WEIGHT_DATARATE}    Create Dictionary
   set test variable    &{SCHEDULING_WEIGHT_DATARATE}

Disable feature flags
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    actNonGbrServiceDiff=false
    ...    actMultiDrbNSA=false
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Modify gnb swconfig file
    ${downloaded_swconfig_path}    Download SWConfig File From GNB    sw_config_path=/tmp/
    Set Suite Variable     ${downloaded_swconfig_path}
    ${updated_swconfig_path_gnb}    Modify SWConfig File For GNB    sw_config_filepath=${downloaded_swconfig_path}
    ...    &{RD_FLAGS}
    Upload Swconifg File to GNB And Perform Signature    ${updated_swconfig_path_gnb}
    Reboot GNB
    Reboot Airphone For Recovery

Restore to Original
    [Arguments]    ${original_file}
    Upload Swconifg File to GNB And Perform Signature    ${original_file}
    Reboot GNB
    Reboot Airphone For Recovery

Download current scf file from gnb
    ${test_log_path}    log_store.get_test_log_folder
    admin.Setup admin
    admin.get current scf file    local_dir_path=${test_log_path}     file_name=SCF_from_gnb.xml
    [Teardown]    admin.Teardown admin