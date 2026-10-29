*** Settings ***
Documentation   Keywords for 5GC001831 feature
Resource        ../CA_Common_Keywords.robot
Resource        ../7_5GC001729/1729_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}                           ${CURDIR}/cfg
#@{cells_for_activation_deactivation}     1     2

*** Keywords ***
Test Setup for 1831
    [Arguments]    &{kwargs}
    Create Test Case Folder
    ${testlog_path}    log_store.get test log folder
    Set Suite Variable    ${testlog_path}
    Set variables for TC    &{kwargs}
    Bring Up TL with Custom Configuration    custom_config_folder=${custom_config_folder}    update_required=True    output_dir=${OUTPUT_DIR}
    Configure LOKI interfaces
    Wait for gNB To Be Ready
    Run Keyword And Ignore Error    Get disk space and tmp content
    Collect logs for debug
    Start pcap collection in gNB and WTS    options=-f sctp -i any -s0 -C 200 -W 20 -z gzip
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/basic_setup.lua    edaemon_port=50000
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Establish X2 link    enb_id=1    gnb_id=2
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic
