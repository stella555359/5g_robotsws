*** Settings ***
Documentation  Script for generic_kw

Library    ute_wtssim
Library    ta5g_commissioning
Library    taf.sbts.oam.coam.admin      WITH NAME    admin
Variables      ../PythonLib/UTILS.py
Library     CSV_validation_and_check1.py

*** Variables ***
${WTS_WORKING_DIR}             /home/ute/WTS_Latest
${LOG_DIR}      /home/ute/logs
${GNB_IP}       192.168.255.1
${GNB_USERNAME}     toor4nsn
${GNB_PASSWORD}     oZPS0POrRieRtu
${AP_IP}        192.168.200.1
${AP_USERNAME}      toor4nsn
${AP_PASSWORD}      oZPS0POrRieRtu
${WTS_IP}       10.63.68.132
${WTS_USERNAME}     ute
${WTS_PASSWORD}     ute

*** Keywords ***
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Perform Reset with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning And Wait For Reset   scfc_filename=${delta_commissioning_file_json}

Perform gNB Delta Commissioning
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup admin
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown admin

Create Basic Interface on UTE
    Run    sudo ip addr add 10.0.1.1/24 dev eth3
    Run    sudo ip addr add 10.0.1.200/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.112/24 dev eth3
    Run    sudo ip addr add 10.0.1.113/24 dev eth3

Delete Basic Interface on UTE
    Run    sudo ip addr del 10.0.1.1/24 dev eth3
    Run    sudo ip addr del 10.0.1.200/24 dev eth3
    Run    sudo ip addr del 10.0.1.131/24 dev eth3
    Run    sudo ip addr del 10.0.1.132/24 dev eth3
    Run    sudo ip addr del 10.0.1.133/24 dev eth3
    Run    sudo ip addr del 10.0.1.134/24 dev eth3
    Run    sudo ip addr del 10.0.1.135/24 dev eth3
    Run    sudo ip addr del 10.0.1.136/24 dev eth3
    Run    sudo ip addr del 10.0.1.137/24 dev eth3
    Run    sudo ip addr del 10.0.1.138/24 dev eth3
    Run    sudo ip addr del 10.0.1.112/24 dev eth3
    Run    sudo ip addr del 10.0.1.113/24 dev eth3

GNB Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the gNB
    ssh.Connect to      ${GNB_IP}   ${GNB_USERNAME}     ${GNB_PASSWORD}     alias=gnb_coam
    ssh.execute     command=ddal -s ddal_boot_set_reset_loop_count 0      connection=gnb_coam
    ssh.execute     command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN      connection=gnb_coam
    [Teardown]      ssh.disconnect      connection=gnb_coam
Enable Internal TG
    [Arguments]     ${UE_ID}    ${Pdu_session_ID}
    wtsrunner.set_pdu_param     ue=${UE_ID}     pdu=${Pdu_session_ID}      trf_type=internal

Update UE capability Online
    [Arguments]    ${ueid}=1
    wtsrunner.ue_param      id=${UE_ID}      ue_nr_capabilities=${ue_cap}

Stop Log Collection
    Collect Logs For Run

Start PCAP on WTS
    [Documentation]     This KW shall help start pcap capture on WTS. Argument passed will be the name of the pcap file.
    [Arguments]     ${test_case_name}
    Run             sudo tcpdump -i any -w ${test_case_name}.pcap > /dev/null 2>&1 &
    ${get_Pid}      Run    sudo pgrep tcpdump
    ${close_session}    Run     disown --help
    [Return]        ${get_Pid}

Stop PCAP on WTS
    [Documentation]    This KW shall help stop pcap on WTS
    [Arguments]        ${get_Pid}
    Run                sudo kill -9 ${get_Pid}

Collect Logs For The Test
    [Arguments]     ${Log_Path}
    Run           /${WTS_WORKING_DIR}/sosReport.sh -nr -c -s
    Run           cp Sos*.tgz ${Log_Path}
    Run           rm Sos*.tgz
    Run           ls ${Log_Path}/SosReport*.tgz

Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${Log_Path}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    set test variable       ${Log_Path}
    [Return]    ${Log_Path}

Updated Suite Setup
#    GNB Reboot
#    Sleep   300s
    RAT Block Unblock
    Common Optimized Suite Setup
    Create Basic Interface on UTE

RAT Block Unblock
    admin.Setup admin
    admin.block_rat     NR
    admin.unblock_rat   NR
    admin.Teardown admin

AP Reboot
    [Documentation]     This KW can be used to do a soft-reboot to the AP
    ssh.Connect to      ${AP_IP}   ${AP_USERNAME}     ${AP_PASSWORD}     alias=ap_coam
    ssh.execute     command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN      connection=ap_coam
    [Teardown]      ssh.disconnect      connection=ap_coam
WTS Reboot
    [Documentation]     This KW is used to soft-reboot WTS
    ssh.Connect to      ${WTS_IP}   ${WTS_USERNAME}     ${WTS_PASSWORD}     alias=wts_coam
    ssh.execute     command=sudo reboot     connection=wts_coam
    [Teardown]      ssh.disconnect          connection=wts_coam
    sleep  120s
    Press  Ctrl+R

Collect BIP and decode
# Commented during AP FT cleanup Below line is modified to remove Keyword column name
    [Arguments]    ${test_scenario}
    log to console      ${SW_VERSION_TOTAL}
    ${SW_VERSION_TOTAL}  Set Variable      ${GNB_SW_VERSION}
    Set Suite Variable    ${SW_VERSION_TOTAL}
    Start log  biptaf
    sleep    200ms
    ${path_SCN_1}   Stop log   biptaf   test_scenario=${test_scenario}
    Set Suite Variable    ${path_SCN_1}


Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}      ${csv_title_list}
    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}    ${output}=    Run And Return Rc And Output    lsb_release -cs|grep bookworm
    Run Keyword If    '${output}'=='bookworm'    Set Suite Variable    ${mcshark_file}
    ...      /home/ute/.local/lib/wireshark/plugins/${tashark_version}/epan/mcshark-*bookworm.so

    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
#    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Validate BIP
#Commented during AP FT cleanup to remove Keyword test scenrio [Arguments]             ${test_scenario}
    [Arguments]
    # Define columns to check in the CSV
    ${column1}              create list             UlData_puschReceiveReqGrant_t.dmrsSequenceType
    ${column2}              create list             UlData_puschReceiveReqGrant_t.mcs
    ${column3}              create list             UlData_puschReceiveReqGrant_t.modulationOrder
    ${message}              create list                 1

    # Validate the message in the specified columns of the CSV

    ${result}    CSV_validation_and_check1.check_message_in_columns    ${path_SCN_1}[biptaf]/BIP_L1L2_filter_SCN1.csv
    ...    @{column1}   @{column2}   @{column3}   @{message}

    # Check the result and fail if necessary
    Run Keyword if   ${result} !=1   Fail   RateMatching check failed
