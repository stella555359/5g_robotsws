*** Settings ***
Documentation
...    | Team:         |  CSV Ulm                                     |
...    | Contact:      |  I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com    |
...    | Description:  |  Common Keywords used in CSV testcases       |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    String
Library    Collections
Library    OperatingSystem
Library    Process

Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.ue
Library    ute_tshark

Library    ../../../../Ulm/resources/Common/python/reporting.py    WITH NAME    reporting
Resource    ../../../../Ulm/resources/Common/git_handling.robot
Resource    ../../../../Ulm/resources/Common/gnb.robot
Resource    ../../../../Ulm/resources/Common/pmcounters.robot
Resource    ../../../../Ulm/resources/Common/reporting.robot
Resource    ../../../../Ulm/resources/Common/tcpdump.robot
Resource    ../../../../Ulm/resources/Common/testline.robot
Resource    ../../../../Ulm/resources/Common/ute_workarounds.robot
Resource    ../../../../Ulm/resources/Common/wts_ue.robot
Resource    ../../../../Ulm/SyVe/resources/attenuator.robot
Resource    ../../../../Ulm/SyVe/resources/syve_testline.robot
Resource    ../../../../Ulm/SyVe/resources/UEs_handler.robot

Library    ../../../../Ulm/SyVe/CSV/libraries/common_tools.py    WITH NAME    common_tools
Library    ../../../../Ulm/SyVe/CSV/libraries/verification_tools.py    WITH NAME    verification_tools
Resource    ../../../../Ulm/SyVe/CSV/resources/tracing_keywords.robot
Resource    ../../../../Ulm/SyVe/CSV/resources/BTS_Cells_Handler.robot



*** Variables ***
${WITH_PM_COUNTERS}               ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${TCPDUMP_ID}                     0


*** Keywords ***
E2E Data Transfer
    [Documentation]
    ...  TCP Data Transfer Testing
    ...  This KW is used for 5G or LTE; TDD or FDD, SA or NSA.
    ...  NSA (Non-Standalone) and SA (Standalone) refer to two distinct deployment architectures for 5G networks.
    ...  It is possible to select the Radio Access Technology (RAT) 5G or LTE where the UE will attached.
    ...  This test case is aimed at verifying the counters that are introduced as part of Data Transfer Testing
    ...  to monitor DL Per CC UE Throughput Counters and UL Per CC UE Throughput Counters.
    ...  if no cells shall be blocked, @{LNCEL_TO_BLOCK_LIST} must be defined as empty list.
    ...  | Arguments:  |
    ...  | ${RAT_in_use}    | nr | lte | gsm  |
    ...  | ${technology_in_use} | TDD | FDD  |
    ...  | ${deployment} deployment architectures  | SA | NSA  |
    ...  | ${cell_index} e.g. to attach under the Second cell.  | 0  |

    [Arguments]    ${technology_in_use}=TDD    ${RAT_in_use}=nr    ${deployment}=SA    ${cell_index}=${0}
    Log To Console    ${\n}End to End Data Transfer Testing.

    Log To Console    ${\n}Radio Access Technology (RAT) to use is: ${RAT_in_use}
    Log To Console    ${\n}Technology to use is: ${technology_in_use}
    IF  "${deployment}"=="NSA"    Log To Console    ${\n}Deployment Architecture is: ${deployment}

    IF  "${RAT_in_use}"=="nr"
        Set Test Variable    ${node_type}    gnb
    ELSE IF    "${RAT_in_use}"=="lte"
        Set Test Variable    ${node_type}    enb
    END

    # ToDo: Select it automatically!
    ${NRRU}=    BTS_Cells_Handler.Set Active NRRU As Variable Based On Technology In Use    technology_in_use=${technology_in_use}

    Log To Console    ${\n}Lock Cells of same RMOD to avoid RF interference.
    IF  "${RAT_in_use}"=="nr" and "${technology_in_use}"=="FDD"
        @{lte_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=lte
        @{gsm_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=gsm
        @{nr_cells_to_block}=    Create List
        # Combine all cells to block/unblock into a single list for teardown
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List    @{lte_cells_to_block}    @{gsm_cells_to_block}  # Used in teardown to unblock the cells.
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    ELSE IF    "${RAT_in_use}"=="nr" and "${technology_in_use}"=="TDD"
        @{lte_cells_to_block}    Create List  # if no cells shall be blocked, @{CELLS_TO_UNBLOCK_FOR_TEARDOWN} must be defined as empty list
        @{gsm_cells_to_block}    Create List
        @{nr_cells_to_block}=    Create List
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List  @{lte_cells_to_block}  @{gsm_cells_to_block}  @{nr_cells_to_block}
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    ELSE IF    "${RAT_in_use}"=="lte"
        @{lte_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=lte
        # Remove the first element (at index 0); This is a LTE call we do not need to Block the first LTE Cell.
        Remove From List    ${lte_cells_to_block}    ${cell_index}
        # ToDo: Select it automatically! Valid for OFEGSA#13 (RMOD-2400)! All LTE Cells are connect to one Att. Port.
        # OFEGSA#16 (RMOD-1400) have different cells frequency connected to different Attenuators ports. One Cell to one Att. Port.!!!
        IF  "${NRRU}"=="1" or "${NRRU}"=="4"    # OFEGSA's does not have GSM Cells.
            Remove From List    ${lte_cells_to_block}    ${cell_index}  # ToDo: Cell_0 is in DSS with 5G! and already removed...
            Set Test Variable    ${cell_index}    ${1}
            # ToDo: Check how to block GSM... Check max num of RU.
            @{gsm_cells_to_block}    Create List
        ELSE
            @{gsm_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=gsm
        END
        IF  "${deployment}"=="NSA"
            @{nr_cells_to_block}=    Create List    # Empty List. For NSA we do not need to Block 5G cells.
            Log To Console    ${\n}Barring the Cell...    # ToDo: Use admin. to Barr NR cells...
            BTS_Cells_Handler.Set Cell Accessibility    states=barred
        ELSE
            @{nr_cells_to_block}    BTS_Cells_Handler.Get Cells Within RMOD Based On RAT    NRRU=${NRRU}    RAT_to_Block=nr
        END
        # Combine all cells to block/unblock into a single list for teardown
        @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}    Create List  @{lte_cells_to_block}  @{gsm_cells_to_block}  @{nr_cells_to_block}
        Set Test Variable    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}  # Make available for teardown.
    END

    Log To Console    ${\n}Lock LTE Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{lte_cells_to_block}    RAT_to_Block=lte
    Log To Console    ${\n}Lock GSM Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{gsm_cells_to_block}    RAT_to_Block=gsm
    Log To Console    ${\n}Lock NR Cells...
    BTS_Cells_Handler.Guarded Block Cells    cells_to_block=@{nr_cells_to_block}    RAT_to_Block=nr

    BTS_Cells_Handler.Get Specific Cell Info
    ...    NRRU=${NRRU}
    ...    technology_in_use=${technology_in_use}
    ...    RAT_in_use=${RAT_in_use}
    ...    cell_index=${cell_index}

    Log To Console    ${\n}Open attenuation for serving cell...
    attenuator.Set gNB all ports attenuation    value_in_db=${0}    ru_id=${NRRU}

    ${FirstUE}    UEs_handler.Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${FirstUE}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ('NoKPI' in ${ENABLED_LOGS})
        Set Test Variable    ${WITH_PM_COUNTERS}    ${False}
    ELSE
        Set Test Variable    ${WITH_PM_COUNTERS}    ${True}
    END

    IF    ${WITH_PM_COUNTERS}
        pmcounters.Wait Until The Next Measurement Period Starts
        Log To Console    ${\n}Release the resources...
        connect.Teardown OAM HTTP Session    node_type=enb
    END

    Run Keyword And Warn On Failure    taf.ue.Log UE Info    ${FirstUE}

    Log to console    ${\n}Stop the DL Background Traffic...
    taf.ue.Stop Data Transfer    DL_Background_${FirstUE}
    UEs_handler.Start iPerf3 TCP Data Transfer UL DL    ue_alias=${FirstUE}    duration=200s    parallel_thread=4

    Sleep    30sec
    ${1_DL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${FirstUE}
    ${1_UL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${FirstUE}

    Log To Console    ${\n}TPut after 30 Sec. for ${FirstUE}:${\n}DL: ${1_DL_AverageThroughput} [kbits/sec] UL: ${1_UL_AverageThroughput} [kbits/sec]

    Sleep    30sec
    ${2_DL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${FirstUE}
    ${2_UL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${FirstUE}

    Log To Console    ${\n}TPut after 60 Sec. for ${FirstUE}:${\n}DL: ${2_DL_AverageThroughput} [kbits/sec] UL: ${2_UL_AverageThroughput} [kbits/sec]

    taf.ue.Await Data Transfer Finish    TCP_${DT_DL}_${FirstUE}
    taf.ue.Await Data Transfer Finish    TCP_${DT_UL}_${FirstUE}
    taf.ue.Stop Data Transfer    TCP_${DT_DL}_${FirstUE}
    taf.ue.Stop Data Transfer    TCP_${DT_UL}_${FirstUE}
    taf.ue.Get Data Transfer Statistics    TCP_${DT_DL}_${FirstUE}
    taf.ue.Get Data Transfer Statistics    TCP_${DT_UL}_${FirstUE}

    IF    ${WITH_PM_COUNTERS}
        pmcounters.Wait Until The Next Measurement Period Starts
        ${pm_counters_dir}    Collect And Convert PMCs And Calculate KPIs
        Check The Expected KPI Value    pm_counters_dir=${pm_counters_dir}
    END


Check The Expected KPI Value
    [Documentation]
    ...  Check the Expected KPI Value.
    ...  Set Suite Variable    ${KPI_RESULTS}  # ToDo: Use RETURN

    [Arguments]    ${pm_counters_dir}=${None}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${expected_kpi_value}    ${deviation_in_percentages}    Get Expected KPI Value and Deviation    kpi=throughput_UL
    ${taf_ue_return}    Run Keyword And Continue On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=TCP_${DT_UL}_${FirstUE}
    ...                                                       tput=${expected_kpi_value} Mbits/sec
    ...                                                       deviation=${deviation_in_percentages}%
    ${UL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${FirstUE}
    ${ul_tput_dict}    common_tools.Find Actual Average TPut    taf_ue_output_string=Actual average tput=${UL_AverageThroughput} [kbits/sec]

    ${kpi_info}    Run Keyword And Warn On Failure    verification_tools.Get KPIs Info From KPI CSV    ${pm_counters_dir}    throughput_UL
    ${description}    Set Variable If    '${kpi_info[0]}'=='PASS'    ${kpi_info[1]}    ${EMPTY}
    ${device_model}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['device_model']}    ${EMPTY}
    ${imei}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['imei']}    ${EMPTY}
    ${signal_strength}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['signal_strength']}    ${EMPTY}
    ${sinr}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['sinr']}    ${EMPTY}
    ${description}    Set Variable If    '${device_model}'!='${EMPTY}'
    ...    \[${device_model},${imei},signal_strength=${signal_strength},sinr=${sinr}\] ${description}    ${description}
    ${expected_kpi_value_in_kbps}    Evaluate    int(${expected_kpi_value}) * 1000
    Set To Dictionary    ${ul_tput_dict}    description=${description}
    ...                                     name=throughput_UL
    ...                                     target=${expected_kpi_value_in_kbps}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${expected_kpi_value}    ${deviation_in_percentages}    Get Expected KPI Value and Deviation    kpi=throughput_DL

    ${taf_ue_return}    Run Keyword And Continue On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=TCP_${DT_DL}_${FirstUE}
    ...                                                       tput=${expected_kpi_value} Mbits/sec
    ...                                                       deviation=${deviation_in_percentages}%

    ${DL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${FirstUE}
    ${dl_tput_dict}    common_tools.Find Actual Average TPut    taf_ue_output_string=Actual average tput=${DL_AverageThroughput} [kbits/sec]

    ${kpi_info}    Run Keyword And Warn On Failure    verification_tools.Get KPIs Info From KPI CSV    ${pm_counters_dir}    throughput_DL
    ${description}    Set Variable If    '${kpi_info[0]}'=='PASS'    ${kpi_info[1]}    ${EMPTY}
    ${device_model}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['device_model']}    ${EMPTY}
    ${imei}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['imei']}    ${EMPTY}
    ${signal_strength}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['signal_strength']}    ${EMPTY}
    ${sinr}    Get Variable Value    ${${FirstUE}_IDENTITY_DICTIONARY['sinr']}    ${EMPTY}
    ${description}    Set Variable If    '${device_model}'!='${EMPTY}'
    ...    \[${device_model},${imei},signal_strength=${signal_strength},sinr=${sinr}\] ${description}    ${description}
    ${expected_kpi_value_in_kbps}    Evaluate    int(${expected_kpi_value}) * 1000
    Set To Dictionary    ${dl_tput_dict}    description=${description}
    ...                                     name=throughput_DL
    ...                                     target=${expected_kpi_value_in_kbps}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${KPI_RESULTS}    Create List    ${ul_tput_dict}    ${dl_tput_dict}
    Set Suite Variable    ${KPI_RESULTS}


Collect And Convert PMCs And Calculate KPIs
    ${ts_log_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}
    ${return}    Run Keyword And Ignore Error    pmcounters.Collect PM Counter    target_dir=${ts_log_dir}/pmc_${TEST_NAME}
    ${pm_counters_dir}    Set Variable If    '${return[0]}'=='PASS'    ${return[1]}    ${EMPTY}
    Run Keyword And Ignore Error    common_tools.Zip Older PM Files To Save Conversion Time    directory=${pm_counters_dir}
    ...                                                                                        keep_recent=2
    ...                                                                                        zip_name=archived_PM_files.zip
    ...                                                                                        file_name_filter=PM.BTS
    ${return}    Run Keyword And Ignore Error    pmcounters.Convert PM Files To CSV    file_path=${pm_counters_dir}
    ${pm_counters_csv_filepath}    Set Variable If    '${return[0]}'=='PASS'    ${return[1]}    ${EMPTY}
    ${KPIs}    Run Keyword And Ignore Error    verification_tools.Get KPIs From PMCounters    ${pm_counters_csv_filepath}    PMKPI_SBTS25R3_5G.json
    RETURN    ${pm_counters_csv_filepath}


Setup Test Scenario For Data Transfer Testing
    [Documentation]
    ...  |  Setup the test scenario for all Data Transfer Testing TCs...  |

    gnb.Get Current Alarms From Node    node_type=gnb

    IF   'tcpdump' in ${ENABLED_LOGS}
       ${TCPDUMP_ID}=    Evaluate    ${TCPDUMP_ID} + 1
       Set Suite Variable    ${TCPDUMP_ID}
       commonKeywords.Start tcpdump trace via eth3 interface connected to the monitoring port of testline switch
       ...   collector_name=tcpdump_eth3_id${TCPDUMP_ID}
    END

    Log To Console    ${\n}Attenuate all cells in testline,${\n}
    attenuator.Attenuate All Cells In Testline    off_value=${127}

    Log To Console    ${\n}Kill all iPerf* processes...
    Run Keyword And Continue On Failure    iperf_processes.Kill All iPerf Processes On Appserver And UE PC


Start tcpdump trace via eth3 interface connected to the monitoring port of testline switch
    [Documentation]   This KW starts tcpdump on the eth3 interface of the test pc that is connected to the monitoring port of testline switch.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${collector_name}=tcpdump_eth3
    ${tl_capture_filter}=   Get TL-specific tcpdump capture filter if defined or default capture filter otherwise
    builtin.Log To Console   Starting tcpdump trace via eth3 interface on Test VM connected to the monitoring port of the testline switch
    tcpdump.Start TCPDump On TestPc    collector=${collector_name}   options=-i eth3 ${tl_capture_filter}


Stop and collect tcpdump trace via eth3 interface connected to the monitoring port of testline switch
    [Documentation]   This KW stops tcpdump on the eth3 interface of the test pc that is connected to the monitoring port of testline switch.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${collector_name}=tcpdump_eth3   ${target_dir}=${None}
    builtin.Log To Console   Stopping and collecting tcpdump trace via eth3 interface on Test VM
    ${pcap_file_path}=   tcpdump.Stop TCPDump On TestPc    collector=${collector_name}   target_dir=${target_dir}
    RETURN   ${pcap_file_path}


Get TL-specific tcpdump capture filter if defined or default capture filter otherwise
    [Documentation]   This KW starts returns a capture filter that is to be applied for the TL in use in case it is defined or the default capture
    ...   filter 'icmp or sctp' otherwise.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ${tl_name}=     testline.Get Testline Name
    ${tl232_long_capture_filter_string}=   builtin.Catenate
    ...   \\( ip6 host 2a00:8a00:6000:2f21:0:47:221:3221 or ip6 host 2a00:8a00:6000:2f21:0:47:221:32F1 or
    ...       ip6 host 2a00:8a00:6000:2f21:0:47:221:3241 or ip6 host 2a00:8a00:6000:2f21:0:47:221:3242 or
    ...       ip host 10.47.221.73 or ip host 10.47.223.33 or ip host 10.47.223.49 \\)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x38\\)     # exclude all IPv6 packets with DSCP==0x38 (=> U-PLN GTP UL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x00\\)     # exclude all IPv6 packets with DSCP==0x00 (=> U-PLN GTP DL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0xc0\\)     # exclude all IPv6 packets with DSCP==0xc0 (=> ISAKMP packets)
    #...   and \\!\\(ip\\[1:1\\] \\=\\= 0x00\\)                           # exclude all IPv4 packets with DSCP==0x00
    ${tl235_long_capture_filter_string}=   builtin.Catenate
    ...   \\( ip6 host 2a00:8a00:6000:2f21:0:47:223:3521 or ip6 host 2a00:8a00:6000:2f21:0:47:223:35F1 or
    ...       ip6 host 2a00:8a00:6000:2f21:0:47:223:3541 or ip6 host 2a00:8a00:6000:2f21:0:47:223:3542 or ip host 10.47.223.137 \\)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x38\\)     # exclude all IPv6 packets with DSCP==0x38 (=> U-PLN GTP UL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x00\\)     # exclude all IPv6 packets with DSCP==0x00 (=> U-PLN GTP DL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0xc0\\)     # exclude all IPv6 packets with DSCP==0xc0 (=> ISAKMP packets)
    ${tl902_long_capture_filter_string}=   builtin.Catenate
    ...   \\( ip6 host 2a00:8a00:6000:2f21:0:46:160:0221 or ip6 host 2a00:8a00:6000:2f21:0:46:160:02F1 or
    ...       ip6 host 2a00:8a00:6000:2f21:0:46:160:0241 or ip6 host 2a00:8a00:6000:2f21:0:46:160:0242 or ip host 10.46.160.97 \\)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x38\\)     # exclude all IPv6 packets with DSCP==0x38 (=> U-PLN GTP UL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x00\\)     # exclude all IPv6 packets with DSCP==0x00 (=> U-PLN GTP DL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0xc0\\)     # exclude all IPv6 packets with DSCP==0xc0 (=> ISAKMP packets)
    ${tl283_long_capture_filter_string}=   builtin.Catenate
    ...   \\( ip6 host 2a00:8a00:6000:2f21:0:47:14:8321 or ip6 host 2a00:8a00:6000:2f21:0:47:14:83F1 or
    ...       ip6 host 2a00:8a00:6000:2f21:0:47:14:8341 or ip6 host 2a00:8a00:6000:2f21:0:47:14:8342 or ip host 10.47.14.137 \\)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x38\\)     # exclude all IPv6 packets with DSCP==0x38 (=> U-PLN GTP UL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0x00\\)     # exclude all IPv6 packets with DSCP==0x00 (=> U-PLN GTP DL packets)
    ...   and \\!\\(\\(ip6\\[0:2\\] \\& 0x0ff0\\) \\>\\> 4 \\=\\= 0xc0\\)     # exclude all IPv6 packets with DSCP==0xc0 (=> ISAKMP packets)
    ${tl_capture_filter_lookup_dict}=     builtin.Create Dictionary
    ...   7_15_UTESRANTL211=ip host 10.47.211.1 or ip host 10.47.211.9 or ip host 10.47.211.25 or ip host 10.47.211.17
    ...   7_15_UTESRANTL286=ip host 10.47.13.194 or ip host 10.47.13.202 or ip host 10.47.13.218 or ip host 10.47.13.210
    ...   7_15_UTESRANTL285=ip host 10.47.13.193 or ip host 10.47.13.201 or ip host 10.47.13.217 or ip host 10.47.13.209
    ...   7_15_UTESRANTL234=ip host 10.47.223.65 or ip host 10.47.223.73 or ip host 10.47.223.89 or ip host 10.47.223.81
    ...   7_15_UTESRANTL232=${tl232_long_capture_filter_string}
    ...   7_15_UTESRANTL235=${tl235_long_capture_filter_string}
    ...   7_15_UTESRANTL902=${tl902_long_capture_filter_string}
    ...   7_15_UTESRANTL283=${tl283_long_capture_filter_string}
    IF   '${tl_name}' in ${tl_capture_filter_lookup_dict}
       ${tl_capture_filter}=   Collections.Get From Dictionary   dictionary=${tl_capture_filter_lookup_dict}   key=${tl_name}
    ELSE
       ${tl_capture_filter}=   builtin.Set Variable   icmp or sctp
    END
    RETURN   ${tl_capture_filter}


Restart UEPROXY service on UEPC
    [Documentation]   This KW attempts to restart the 'UE PROXY RUNNER' service for all UE CTRL PCs / UEs of the TL and warns upon failure.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ${list_of_handled_uepcs}=   builtin.Create List
    IF   $tl.ues is not None and len($tl.ues) > 0
        ${num_of_ues}=    Get length    ${tl.ues}
        FOR    ${UE_idx}    IN RANGE    ${0}    ${num_of_ues}
            ${ue_pc_address}=     Set Variable    ${tl.ues[${UE_idx}].ssh_connection_details.addr}
            ${ue_pc_username}=    Set Variable    ${tl.ues[${UE_idx}].ssh_connection_details.username}
            ${ue_pc_password}=    Set Variable    ${tl.ues[${UE_idx}].ssh_connection_details.password}
            ${ue_serial}=         Set Variable    ${tl.ues[${UE_idx}].serial_number}
            IF   '${ue_pc_address}' not in ${list_of_handled_uepcs}
                Log To Console   Restarting UEPROXY service on '${ue_pc_address}' for TL UE with index ${UE_idx} and serial_number '${ue_serial}'
                ${long_shell_command}=  builtin.Catenate   sshpass -p ${ue_pc_password} ssh ${ue_pc_username}@${ue_pc_address}
                ...  'net stop "UE PROXY RUNNER" && rm -rfv /cygdrive/c/taf_ue_proxy/logs; echo "" && net start "UE PROXY RUNNER"'
                ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_shell_command}
                Sleep  15   Sleeping 15 seconds to give "UE PROXY RUNNER" service enough time to restart and NAA connections to be restablished
                builtin.Run Keyword and Warn on Failure    builtin.Should Be Equal
                ...   ${rc}   ${0}   Restarting of taf.ue.proxy service on UECTRLPC '${ue_pc_address}' failed with following error:\n${output}
                IF  ${rc} == ${0}
                   Collections.Append To List   ${list_of_handled_uepcs}   ${ue_pc_address}
                END
            ELSE
                ${long_log_string}=   builtin.Catenate   Skipping restarting UEPROXY service on '${ue_pc_address}' for TL UE with index ${UE_idx}
                ...   and serial_number '${ue_serial}' as the UEPC controlling this UE was already handled before
                Log To Console   ${long_log_string}
            END
        END
    END


Get Running ORAN RU FW version if applicable
    [Documentation]   This KW gets the running FW version of the first OFEGSA ORAN RU unit, in case it is installed on the BTS
    ...   and when ${PRIMARY_TL_NODES_DICT} has been previously defined by calling the corresponding keyword during setup phase.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}  ${admin_log_dir}=${P_resultSuiteBaseDir}/admin_logs

    ${all_robot_variables_dict}=   Get variables
    IF   "\${PRIMARY_TL_NODES_DICT}" in $all_robot_variables_dict
		IF  'OFEGSA' in '${{','.join($PRIMARY_TL_NODES_DICT['${node_type.upper()}-${node_id}']['radio_types']) }}'

				#builtin.Log To Console   ${\n}\Get Running ORAN RU FW version
				${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
				...   admin_api_log_path=${admin_log_dir}/Get_running_ORU_FW_version
				${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
				#builtin.Log   ${gnb_bts_info['radioModules']['rmod']}   console=${True}   formatter=repr
				${all_ofegsa_rmod}=   Set Variable
				...   ${{ [el for el in $gnb_bts_info['radioModules']['rmod'] if el['productName'] in ['OFEGSA']] }}
				${all_ofegsa_rmod_fw}=   Set Variable
				...   ${{ [el['swInfo']['runningSwVersion'] for el in $gnb_bts_info['radioModules']['rmod'] if el['productName'] in ['OFEGSA']] }}
				admin.Teardown   connection=${oam_alias}
				${RFSW_BUILD}=   Set variable   ${all_ofegsa_rmod_fw}[0]
				Log to console    INFO: ORU FW Version is: ${all_ofegsa_rmod_fw}[0]
		ELSE
			#builtin.Log To Console  ${\n}\[${node_type.upper()}-${node_id}] This BTS node has no O-RAN RU of type OFEGSA!
			${RFSW_BUILD}=   Set variable   ${EMPTY}
		END
	ELSE
		${RFSW_BUILD}=   Set variable   ${EMPTY}
	END
    Set Suite Variable   ${RFSW_BUILD}
    RETURN   ${RFSW_BUILD}



Test Scenario Teardown
    Log To Console    ${\n}Starting Teardown.
    Log Variables

    Log To Console    ${\n}unBarring the Cells...
    BTS_Cells_Handler.Set Cell Accessibility    states=notBarred

    Log To Console    ${\n}taf.ue.Stop Data Transfers For All Ues.
    taf.ue.Stop Data Transfers For All UEs

    Log To Console    ${\n}Kill all iPerf* processes...
    Run Keyword And Continue On Failure    iperf_processes.Kill All iPerf Processes On Appserver And UE PC

    Log To Console    ${\n}The Phone ${FirstUE} will be detached...
    taf.ue.Detach UE    ${FirstUE}

    Log To Console    ${\n}Unblocking All Used cells.
    ${oam_alias}=    connect.Setup OAM HTTP Session    node_type=gnb    node_id=${0}
    FOR   ${cells_to_unblock}    IN    @{CELLS_TO_UNBLOCK_FOR_TEARDOWN}
      Run Keyword And Warn On Failure    admin.Unblock Cell    dist_name=${cells_to_unblock}    connection=${oam_alias}   timeout=120
    END
    admin.Teardown   connection=${oam_alias}

    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Stop and collect tcpdump trace via eth3 interface connected to the monitoring port of testline switch
       ...   collector_name=tcpdump_eth3_id${TCPDUMP_ID}
    END


Test Scenario Teardown With Reporting
    CSV Online Reporting To ReP
    commonKeywords.Test Scenario Teardown


Get CSV TL Customer Mapping From TL Name And Set It As Suite Variable CUSTOMERS_LIST
    [Documentation]    This keyword may be used to retrieve from the TL name
    ...   the customer mapping that is needed for reporting of UUF4ALL TCs.
    ...   It requires no input parameters, as the TL name is auto-detected.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ${tl_name}=     testline.Get Testline Name
    ${tl_name}   Evaluate   $tl_name.removesuffix('_AP')
    ${tef_tl_expr}=   Catenate
    ...   '${tl_name}' in ['7_15_UTESRANTL118', '7_15_UTESRANTL211', '7_15_UTESRANTL212',
    ...                    '7_15_UTESRANTL285', '7_15_UTESRANTL286', '7_15_UTESRANTL287', '7_15_UTESRANTL288']
    ${dtag_tl_expr}=   Catenate
    ...   '${tl_name}' in ['7_15_UTESRANTL901', '7_15_UTESRANTL902',
    ...                    '7_15_UTESRANTL283', '7_15_UTESRANTL284',
    ...                    '7_15_UTESRANTL231', '7_15_UTESRANTL232', '7_15_UTESRANTL233']
    ${customer}=    Set Variable If
    ...   ${tef_tl_expr}    TEF O2 Germany
    ...   ${dtag_tl_expr}   DTAG
    ...   UNKNOWN CSV TL
    IF    '${customer}' in ['UNKNOWN CSV TL']   Fail
    ...   CSV TL '${tl_name}' is not registered in KW 'Get CSV TL customer mapping from TL name' yet!
    @{CUSTOMERS_LIST}=     Create List   ${customer}
    Set Suite Variable   @{CUSTOMERS_LIST}

    RETURN    @{CUSTOMERS_LIST}


Get TL specific list of custom allowed alarms
    [Documentation]    This keyword returns a list of alarms to ignore
    ...  according to the TL name
    ...  It requires no input parameters, as the TL name is auto-detected.
    ...  | Author:      | Alexandre Cunha <alexandre.cunha@nokia.com>   |

    ${tl_name}=     testline.Get Testline Name

    @{ALARMS_TO_IGNORE}=   Create List  # Faults to be ignored are specified in the lines below
    ...    6322    # fault_name: RIM interface timeout, severity: -, alarm_id: 7107 7657, fault_id: 6322
    ...    61510   # fault_name: Automatic BTS Operator Certificate retrieval unsuccessful, severity: Major, alarm_id: 7220, fault_id: 61510
    ...    6261    # fault_name: Failure in connection between cBTS and 3rd party tool, severity: Minor, alarm_id: 7115 7652, fault_id: 6261
    ...    6351    # fault_name: System information broadcast parameters overflow, severity: Minor, alarm_id: 7115 7655, fault_id: 6351
    ...    7509    # fault_name: EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM, severity: alarm_id: 7114, f_id: 7509
    ...    4527    # fault_name: RIM-RS detected, severity: Minor, alarm_id: 7115, fault_id: 4527
    ...    62003   # fault_name: Transport layer connection lost in XP interface, severity: -, alarm_id: 7107 7657, fault_id: 62003
    ...    62001   # fault_name: Transport layer connection establishment failure in XP interface, severity: -, alarm_id: 7107 7657, fault_id: 62001
    ...    4003    # fault_name: Transmission path failure, severity: Minor, alarm_id: 7115 7655, fault_id: 4003
    ...    6202    # fault_name: Transport layer connection failure in S1 interface, severity: -, alarm_id: 7107 7656 7657, fault_id: 6202
    ...    2403    # fault_name: TRX configuration mismatch between BSC and BTS, severity: Minor, alarm_id: 7115, fault_id: 2403
    ...    6328    # fault_name: X2(gNB) link ANR establishment failure, severity: -, alarm_id: 7107 7657, fault_id: 6328
    ...    7305    # fault_name: NG SCTP setup fail, severity: Critical, alarm_id: 7107, fault_id: 7305
    ...    7307    # fault_name: Xn SCTP setup fail, severity: Major, alarm_id: 7107, fault_id: 7307
    ...    8000    # fault_name: Failure in connection between BTS and 3rd party tool, severity: Minor, alarm_id: 7115, fault_id: 8000
    ...    6150    # GTP-U Path Failure, severity: Major, alarm_id: 7107, fault_id: 6150 if gtpuPathSupint != 0
    ...    2412    # fault_name: OMU signaling connection failure in Abis interface
    # [2025-10-30]: temporarily adding fault ignore for FID 61618 as our ipsectest certificate is about to expire in less than 3 months
    # (current cert with fingerprint A1:B2:3B:3A:A9:83:0E:34:56:81:5E:FB:D8:DA:36:C6:C4:B7:DF:7E expires on 2026-01-28) which triggers
    # this fault to be raised as warning for the operator and out tests to fail; request for new replacement certificate with longer
    # validity period is ongoing and once in use, the fault ignore below may be removed again
    ...   61618    # fault_name: Operator Certificate About to Expire or Expired, severity: Major, alarm_id: 7220, fault_id: 61618

    # following fault ignores are needed on "DTAG" TLs only ==============================================================================
    IF  '${tl_name}' in ['7_15_UTESRANTL901', '7_15_UTESRANTL902', '7_15_UTESRANTL283', '7_15_UTESRANTL284', '7_15_UTESRANTL232']
        Collections.Append To List  ${ALARMS_TO_IGNORE}    6134    # fault_name: EN DSS De-activated on partner side, severity:
                                                       #             Minor, alarm_id: 7115 7655, fault_id: 6134
        Collections.Append To List  ${ALARMS_TO_IGNORE}    6129    # fault_name: No DSS Partner Cell, severity:
                                                       #             Minor, alarm_id: 7115,fault_id: 6129
        Collections.Append To List  ${ALARMS_TO_IGNORE}    2002    # fault_name: Receiving failure in Optical Interface
                                                                   # added [2025-07-07] by Masiar M. due to PR824299 in CNA for 25R2
        #-------------------------------------------------------------------------------------------------------------------------------
                                                       #             Validation information, severity: Major, alarm_id: 7108, fault_id: 4298
                                                       #             Transient fault 4298 may occur at startup of OFEGSA modules
                                                       #             Issue has been fixed with PR805247 only for SW builds 25R2 onwards
        Collections.Append To List  ${ALARMS_TO_IGNORE}    4298    # fault_name: ToP reference missing
                                                       #             Validation information, severity: Minor, alarm_id: 7115, f_id: 4720
                                                       #             fault 4720 may be removed from ignore list when O-RU SW was updated to 25R2
        Collections.Append To List  ${ALARMS_TO_IGNORE}    4720    # fault_name: Mismatch of RU reported capabilities with static HW
        Collections.Append To List  ${ALARMS_TO_IGNORE}    61074    # fault_name: CRL Update failure or certificate revoked Gian is investigating
        Collections.Append To List  ${ALARMS_TO_IGNORE}    61605    # fault_name: BFDID down in ingress, to be removed with fix for PR879005
    END

    # following fault ignores are needed on "TEF O2 Germany" TLs only ====================================================================
    IF  '${tl_name}' in ['7_15_UTESRANTL212', '7_15_UTESRANTL211', '7_15_UTESRANTL286']
        Collections.Append To List  ${ALARMS_TO_IGNORE}    61645   # fault_name: IKE SA failure e.g. due to XMesh setup failure between TL211/TL212
    END

    IF  '${tl_name}' in ['7_15_UTESRANTL211', '7_15_UTESRANTL286']
                                                       # additions below are TEMPORARY only to be removed once fault RMOD-7 got replaced or
                                                       # issue resolved, added [2025-02-26] in 66e6285cc72f
        Collections.Append To List  ${ALARMS_TO_IGNORE}    1907    # fault_name: TX out of order
                                                       # addition below is TEMPORARY only while issue under investigation with SW development
                                                       # added [2025-03-27] by Masiar M. due to transient alarm for 5 seconds after each reboot
        Collections.Append To List  ${ALARMS_TO_IGNORE}    2002    # fault_name: Receiving failure in Optical Interface
                                                                   # added [2025-04-28] by Masiar M. due to PR824299 in CNA for 25R2 and earlier
    END

    IF  '${tl_name}' in ['7_15_UTESRANTL287']
                                                       # additions below are for TL287 (FSMF/FSMr3) only
        Collections.Append To List  ${ALARMS_TO_IGNORE}    61616   # fault_name: Vendor BTS certificate has expired
                                                                   # added [2025-11-07] by Masiar M. due expired vendor cert on HW unit
    END

    IF  '${tl_name}' in ['7_15_UTESRANTL232']
                                                       # additions below are for TL232 (DTAG MORAN site config) only
        Collections.Append To List  ${ALARMS_TO_IGNORE}    7316    # fault_name: NG Setup Failure
        Collections.Append To List  ${ALARMS_TO_IGNORE}    7317    # fault_name: NG Setup retry stopped
                                                                   # added [2026-03-11] by Masiar M. due to CSV4ALL lib issue in MORAN
    END

    RETURN    @{ALARMS_TO_IGNORE}


Get QC_PROJECT QC_ID And Set QC Tags
    [Documentation]
    ...  | Returns the qc_project and qc_id according to the information in qc_mapping.yaml |
    ...  | Uses as keys the name of the testcase that called this keyword and the arguments |
    ...  | customer_name (DTAG, TEF O2 Germany,...) and release_name (SBT00, SBTS24R3,...)  |
    ...  | to return the corresponding pair (qc_project, qc_id)                             |
    ...  | Author:      | Alexandre Cunha <alexandre.cunha@nokia.com>   |
    [Arguments]    ${customer_name}  ${release_name}

    TRY
        ${qc_id}=         Set Variable   ${${TEST_NAME}}[${release_name}][${customer_name}][0][qc_id]
        ${qc_project}=    Set Variable   ${${TEST_NAME}}[${release_name}][${customer_name}][0][qc_project]
    EXCEPT      *has no key 'qc_id'*    type=GLOB
        FAIL    qc_id not found for ${customer_name}, ${release_name} for testcase ${TEST_NAME} in qc_mapping.yaml
    EXCEPT      *has no key 'qc_project'*    type=GLOB
        FAIL    qc_project not found for ${customer_name}, ${release_name} for testcase ${TEST_NAME} in qc_mapping.yaml
    EXCEPT      *accessing item '0' from it is not possible*    type=GLOB
        FAIL    Nothing found under ${release_name} for testcase ${TEST_NAME} in qc_mapping.yaml
    EXCEPT      *${customer_name}*  type=GLOB
        FAIL    Customer ${customer_name} not found under ${release_name} for testcase ${TEST_NAME} in qc_mapping.yaml
    EXCEPT      *${release_name}*  type=GLOB
        FAIL    Release ${release_name} not found in qc_mapping.yaml for testcase ${TEST_NAME} in qc_mapping.yaml
    EXCEPT      *${TEST_NAME}*      type=GLOB
        FAIL    Test: ${TEST_NAME} was NOT found in qc_mapping.yaml
    EXCEPT  AS  ${err}
        FAIL    ${err}
    END

    Log to Console   ${\n}Keys for qc_mapping.yaml: ${TEST_NAME}, ${release_name}, ${customer_name}
    Log to Console   Found qc_project: ${qc_project} qc_id: ${qc_id}

    # Setting tags for QC reporting
    ${QCPrj}     Set Variable    QCP_${qc_project}
    ${QCInstID}  Set Variable    QC_${qc_id}
    Set Tags  ${QCPrj}
    Set Tags  ${QCInstID}
    Log to console    ${\n}Set QC_Project Tag to ${QCPrj}
    Log to console    Set QC_ID Tag to ${QCInstID}${\n}

    Set Test Variable    ${qc_project}
    Set Test Variable    ${qc_id}

    RETURN  ${qc_project}   ${qc_id}


Prepare TL
    builtin.Log To Console   Running Test Suite Setup keyword 'Prepare TL' ...
    testline.Set Console Output
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Save current loads
    git_handling.Save Current Workspace Info
    commonKeywords.Get CSV TL Customer Mapping From TL Name And Set It As Suite Variable CUSTOMERS_LIST
    commonKeywords.Get CURRENT_SW_BRANCH And Set It As Suite Variable
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}
    IF   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...   builtin.Import Variables   ${CURDIR}/../E2E_RAT_Tests/qc_mapping_fsm3.yaml
    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        commonKeywords.Get the SW Version Of SBTS Node And Set It To Suite Variable P_GNBSWVERSION   node_type=${node_type}    node_id=${node_id}
        Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=${node_type}    node_id=${node_id}    timeout=30s
        IF   ('syslog' in ${ENABLED_LOGS})
        ...   syve_testline.Start Syslog Collection For CCRTS    node_id=${node_id}    node_type=${node_type}
        scf_info.Collect the Current SCF file    node_id=${node_id}   node_type=${node_type}
    END
    Log Variables
    builtin.Log To Console   Running Test Suite Setup keyword 'Prepare TL' completed!${\n}


Save all Logs and Teardown TL
    Sleep    3sec

    Log To Console    Running Test Suite Teardown keyword 'Save all Logs and Teardown TL' ...
    ${target_dir}=    testline.Get test suite result base directory
    Log To Console    \ storing log files at path:${\n}\ \ '${target_dir}'

    FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
        ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
        ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
        IF    ('syslog' in ${ENABLED_LOGS})   Run Keyword And Warn On Failure
        ...    syve_testline.Stop syslog collection for CCRTS   node_type=${node_type}    node_id=${node_id}
        IF    ('snapshot' in ${ENABLED_LOGS})   Run Keyword And Warn On Failure
        ...    snapshot.Get snapshot for node   node_type=${node_type}    node_id=${node_id}    target_dir=${target_dir}
    END

    admin.Teardown All Aliases For Admin
    builtin.Log To Console   Running Test Suite Teardown keyword 'Save all Logs and Teardown TL' completed!${\n}


Get CURRENT_SW_BRANCH And Set It As Suite Variable
   [Documentation]  This keyword gets the info about the CURRENT_SW_BRANCH of the current SW from the SRAN_NODE connected via LMP port and sets
    ...   it as Suite Variable.
    ...   | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ${oam_alias}=   admin.Setup Admin
    ${CURRENT_SW_VERSION}=   admin.Get SW Version    connection=${oam_alias}   timeout=10sec
    ${TARGET_SW_VERSION}=   builtIn.Set Variable If   "${TARGET_SW_VERSION}" != ""   ${TARGET_SW_VERSION}   ${CURRENT_SW_VERSION}
    ${CURRENT_SW_BRANCH}=   builtin.Set Variable If
    ...   "_ENB_999" in "${CURRENT_SW_VERSION}" or "_FSM3_999" in "${CURRENT_SW_VERSION}"   SBTS00   ${{$CURRENT_SW_VERSION.split('_')[0]}}
    ${TARGET_SW_BRANCH}=   builtin.Set Variable If
    ...   "_ENB_999" in "${TARGET_SW_VERSION}" or "_FSM3_999" in "${TARGET_SW_VERSION}"   SBTS00   ${{$TARGET_SW_VERSION.split('_')[0]}}
    Set Suite Variable   ${CURRENT_SW_BRANCH}
    Set Suite Variable   ${TARGET_SW_BRANCH}
    admin.Teardown   connection=${oam_alias}
    RETURN   ${CURRENT_SW_BRANCH}


Identify The List Of Unique SMODs And Associated Primary SBTS Nodes Of The Testline
    [Documentation]   This keyword detect from the TL configuration object tree the list of unique SMOD modules and associated primary SBTS nodes.
    ...    This function assumes that the primary SBTS node of a SMOD of a testline is defined in following priority order, according to the RATs that
    ...    SMOD provides: Prio1 (RAT = 5G): GNB-X / Prio2 (RAT = 4G): ENB-X / Prio3 (RAT = 2G): BTS2G-X
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${log_to_console}=${False}
    ${P_TL_NAME}=   testline.Get Testline Name
    ${PRIMARY_TL_NODES_LIST}=   builtin.Create List
    ${PRIMARY_TL_NODES_DICT}=   builtin.Create Dictionary
    ${all_unique_smod_serials_list}=   builtin.Create List
    ${all_unique_smod_hwtype_list}=   builtin.Create List
    ${all_gnb_count}=  builtin.Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    ${all_enb_count}=  builtin.Set Variable If   ${tl.enbs != None}   ${tl.enbs.__len__()}   ${0}
    ${all_bts2g_count}=  builtin.Set Variable If   ${tl.bts2g_objects != None}    ${tl.bts2g_objects.__len__()}   ${0}

    # processing Prio1 SBTS node types: GNB-x
    FOR    ${gnb_node}    IN RANGE    ${all_gnb_count}
        IF   '${tl.gnbs[${gnb_node}].dus[0].airscale.common_units[0].serial_number}' not in ${all_unique_smod_serials_list}
            collections.Append To List   ${all_unique_smod_serials_list}   ${tl.gnbs[${gnb_node}].dus[0].airscale.common_units[0].serial_number}
            collections.Append To List   ${all_unique_smod_hwtype_list}   ${tl.gnbs[${gnb_node}].dus[0].airscale.common_units[0].hardware_type}
            collections.Append To List   ${PRIMARY_TL_NODES_LIST}   GNB-${gnb_node}
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}     GNB-${gnb_node}=${{dict()}}
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}[GNB-${gnb_node}]
            ...   hardware_type=${tl.gnbs[${gnb_node}].dus[0].airscale.common_units[0].hardware_type}
            ...   serial_number=${tl.gnbs[${gnb_node}].dus[0].airscale.common_units[0].serial_number}
            ...   hardware_types=${{ [el.hardware_type for el in $tl.gnbs[${gnb_node}].dus[0].airscale.common_units] }}
            ...   serial_numbers=${{ [el.serial_number for el in $tl.gnbs[${gnb_node}].dus[0].airscale.common_units] }}
            ...   radio_types=${{ sorted([str(el.radio_type) for el in $tl.gnbs[${gnb_node}].dus[0].rus]) }}
        END
    END

    # processing Prio2 SBTS node types: ENB-x
    FOR    ${enb_node}    IN RANGE    ${all_enb_count}
        IF   '${tl.enbs[${enb_node}].system_module.common_units[0].serial_number}' not in ${all_unique_smod_serials_list}
            collections.Append To List   ${all_unique_smod_serials_list}   ${tl.enbs[${enb_node}].system_module.common_units[0].serial_number}
            collections.Append To List   ${all_unique_smod_hwtype_list}   ${tl.enbs[${enb_node}].system_module.common_units[0].hardware_type}
            collections.Append To List   ${PRIMARY_TL_NODES_LIST}   ENB-${enb_node}
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}     ENB-${enb_node}=${{dict()}}
            ${long_python_expr_for_radio_types}=   builtin.Catenate   sorted([str(el.radio_type) for el in $tl.enbs[${enb_node}].rms])
            ...   if $tl.enbs[${enb_node}].system_module.common_units[0].hardware_type != 'FSMF' else
            ...   sorted([str(ru.radio_type) for el in $tl.enbs[${enb_node}].system_module.common_units for cp in el.capacity_units for ru in cp.rus])
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}[ENB-${enb_node}]
            ...   hardware_type=${tl.enbs[${enb_node}].system_module.common_units[0].hardware_type}
            ...   serial_number=${tl.enbs[${enb_node}].system_module.common_units[0].serial_number}
            ...   hardware_types=${{ [el.hardware_type for el in $tl.enbs[${enb_node}].system_module.common_units] }}
            ...   serial_numbers=${{ [el.serial_number for el in $tl.enbs[${enb_node}].system_module.common_units] }}
            ...   radio_types=${{ ${long_python_expr_for_radio_types} }}
        END
    END

    # processing Prio3 SBTS node types: BTS2G-x
    FOR    ${bts2g_node}    IN RANGE    ${all_bts2g_count}
        IF   '${tl.bts2g_objects[${bts2g_node}].system_module.common_units[0].serial_number}' not in ${all_unique_smod_serials_list}
            collections.Append To List
            ...   ${all_unique_smod_serials_list}   ${tl.bts2g_objects[${bts2g_node}].system_module.common_units[0].serial_number}
            collections.Append To List
            ...   ${all_unique_smod_hwtype_list}   ${tl.bts2g_objects[${bts2g_node}].system_module.common_units[0].hardware_type}
            collections.Append To List   ${PRIMARY_TL_NODES_LIST}   BTS2G-${bts2g_node}
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}     BTS2G-${bts2g_node}=${{dict()}}
            Collections.Set To Dictionary   ${PRIMARY_TL_NODES_DICT}[BTS2G-${bts2g_node}]
            ...   hardware_type=${tl.bts2g_objects[${bts2g_node}].system_module.common_units[0].hardware_type}
            ...   serial_number=${tl.bts2g_objects[${bts2g_node}].system_module.common_units[0].serial_number}
            ...   hardware_types=${{ [el.hardware_type for el in $tl.bts2g_objects[${bts2g_node}].system_module.common_units] }}
            ...   serial_numbers=${{ [el.serial_number for el in $tl.bts2g_objects[${bts2g_node}].system_module.common_units] }}
            ...   radio_types=${{ sorted([str(el.radio_type) for el in $tl.bts2g_objects[${bts2g_node}].rms]) }}
        END
    END

    builtin.Log
    ...   Testline '${P_TL_NAME}' is provided by following Primary SMOD and associated Primary TL node:
    ...   console=${log_to_console}
    FOR   ${tl_node_idx}   ${tl_node}    IN ENUMERATE   @{PRIMARY_TL_NODES_LIST}
        ${long_log_string}=   builtin.Catenate   \ \ [${{ $tl_node_idx+1 }}/${PRIMARY_TL_NODES_LIST.__len__()}]:
        ...   SBTS node '${tl_node}' is provided by primaray SMOD of
        ...   hardware_type '${all_unique_smod_hwtype_list}[${tl_node_idx}]' and serial '${all_unique_smod_serials_list}[${tl_node_idx}]'
        builtin.Log   ${long_log_string}   console=${log_to_console}
    END
    Set Suite Variable   ${PRIMARY_TL_NODES_LIST}
    Set Suite Variable   ${PRIMARY_TL_NODES_DICT}
    RETURN   ${PRIMARY_TL_NODES_LIST}


Get The SW Version Of SBTS Node And Set It To Suite Variable P_GNBSWVERSION
    [Documentation]   This keyword gets the SW version currently running n the given SBTS node and sets the info as dictionary item with
    ...    name '\${node_type}_\${node_id}' inside the Suite Variable dictionary \&{P_GNBSWVERSION} holding the software versions of all primary
    ...    testline nodes.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}    ${node_id}   ${sw_version_tag}=current
    ${primary_node_sw_version}=   IF    '${node_type.lower()}' == 'gnb'   testline.Get gNB SW version   gnb_id=${node_id}
    ...  ELSE IF   '${node_type.lower()}' == 'enb'   testline.Get eNB SW version   enb_id=${node_id}
    ...  ELSE                                        Fail   Unsupported node type '${node_type}'
    builtin.Log To Console  [INFO] The ${sw_version_tag} SW Version on primary node '${node_type.upper()}-${node_id}' is: '${primary_node_sw_version}'
    Set Suite Variable   &{P_GNBSWVERSION}  ${node_type}_${node_id}=${primary_node_sw_version}
    RETURN   ${primary_node_sw_version}


CSV Online Reporting To ReP
    [Documentation]
    ...    This KW is used by CSV to report test result to Reporting Portal.
    ...    This keyword has no arguments. All information is taken from
    ...    available testcase/suite scope level variables.
    ...    CSV4ALL tests have own reporting. CSV4ALL tests do should not use this keyword!!
    ...    For reporting the qc_domain, qc_project and qc_id are required. If they are not defined
    ...    as test variables, this keyword will attempt to get them using SW branch and customer
    ...    from the dictionay with the testcase name, typically defined in the yaml file.
    ...    RP_CA, RP_LOCATION, RP_ORGANIZATION are MANDATORY, usually suite level variables and
    ...    must exist, otherwise test reporting will fail.
    ...    Robot Tescase name should be the same as in QC. Variable ${TEST_NAME} is used.
    ...    Testcase result reported is the ${TEST STATUS}
    ...    Other Variables that can be set during the testcase and used for reporting
    ...      GNB_ID: Id/Number of gNB
    ...      ENB_ID: Id/Number of eNB
    ...      FEATURES_COVERED: list of features covered in the test
    ...      PM_COUNTERS: PM Counters under test
    ...      KPI_RESULTS: KPI under test (list of dictionaries)
    ...                   e.g. "[{'target': '800',
    ...                           'name': 'NR_5094',
    ...                           'visible_to_db': 'Yes',
    ...                           'value': '800',
    ...                           'type': '',
    ...                           'description': '5G SA PDCP SDU throughput in downlink',
    ...                           'category': 'Customer',
    ...                           'unit': 'Mbit/s'}, ...]"
    ...      RFSW_BUILD: shall hold SW information about the used radio module(s) on the TL, i.e. OFEGSA FJ 3rd party ORAN RU FW version in DTAG case

    Log To Console  [INFO] Online Reporting To ReP

    ${gnb_id}=             Get Variable Value    $GNB_ID            0
    ${enb_id}=             Get Variable Value    $ENB_ID            0
    ${kpi_results}=        Get Variable Value    $KPI_RESULTS       ${EMPTY}
    ${pm_counters}=        Get Variable Value    $PM_COUNTERS       ${EMPTY}
    ${features_covered}=   Get Variable Value    $FEATURES_COVERED  ${EMPTY}
    ${rfsw_build}=         Get Variable Value    $RFSW_BUILD        ${EMPTY}

    ${enb_sw_version}=   Get eNB SW Version If eNB Is Present   ${enb_id}
    ${gnb_sw_version}=   Get gNB SW Build Version   ${gnb_id}
    ${current_oru_fw_version}=    commonKeywords.Get Running ORAN RU FW version if applicable
    ${sw_build}=   Construct SW Build From   ${gnb_sw_version}   ${enb_sw_version}

    ${qc_id}=     Get Variable Value   $qc_id        0

    # if qc_id is 0 is because was not defined during test execution
    IF  ${qc_id} == 0
        Get CSV TL Customer Mapping From TL Name And Set It As Suite Variable CUSTOMERS_LIST
        ${target_sw_branch}=  String.Fetch From Left   ${sw_build}   _
        ${qc_project}    ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags
        ...    customer_name=${CUSTOMERS_LIST}[0]
        ...    release_name=${target_sw_branch}
    END

    Variable Should Exist    ${qc_project}       qc_project mandatory variable is not defined
    Variable Should Exist    ${QC_DOMAIN}        qc_domain mandatory variable is not defined

    Variable Should Exist    ${RP_CA}            RP_CA mandatory variable is not defined
    Variable Should Exist    ${RP_LOCATION}      RP_LOCATION mandatory variable is not defined
    Variable Should Exist    ${RP_ORGANIZATION}  RP_ORGANIZATION mandatory variable is not defined

    ${tl_name}=     testline.Get Testline Name
    ${tl_name}   Evaluate   $tl_name.removesuffix('_AP')

    &{EMPTY_DICT}    Create Dictionary
    ${PRIMARY_TL_NODES_DICT}    Get Variable Value    ${PRIMARY_TL_NODES_DICT}    ${EMPTY_DICT}

    ${node_type}=   Set Variable If   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...    enb
    ...    gnb
    ${tc_execution_id}=  Set SCOUT TC ID For Reporting  node_type=${node_type}  scout_tl_name=${tl_name}

    ${BUILD_URL}    OperatingSystem.Get Environment Variable    BUILD_URL    ${EMPTY}
    &{links}    Create Dictionary    Test logs    ${BUILD_URL}
    ${reported_test_result}=   Set Variable If   '${TEST STATUS}' == 'SKIP'   PASS   ${TEST STATUS}

    reporting.Report Results To ReP   tcName=${TEST_NAME}
    ...                               tc_execution_id=${tc_execution_id}
    ...                               tsResult=${reported_test_result}
    ...                               swBuild=${sw_build}
    ...                               testLine=${tl_name}
    ...                               suitePath=${SUITE SOURCE}
    ...                               customers=@{CUSTOMERS_LIST}
    ...                               qc_domain=${QC_DOMAIN}
    ...                               qc_project=${qc_project}
    ...                               qc_id=${qc_id}
    ...                               ca=${RP_CA}
    ...                               organization=${RP_ORGANIZATION}
    ...                               location=${RP_LOCATION}
    ...                               featuresCovered=${features_covered}
    ...                               isForDebugging=no
    ...                               kpi_results=${kpi_results}
    ...                               pmCounters=${pm_counters}
    ...                               links=${links}
    ...                               rfsw_build=${rfsw_build}

Save Configs And Prepare For Testing And Logging
    [Documentation]    for "Suite Setup"
    ...    | Author:      | Nikolay Shkulepov <nikolay.shkulepov@nokia.com>   |
    Log To Console    ${\n}Save Configs and Prepare for Testing and Logging...
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Ignore Error  ute_workarounds.Log TL Info as Metadata
    testline.Set Console Output
    testline.Create Test Suite Log Folders
    Store Configuration Files Before Test Begins
    Run Keyword And Warn On Failure    testline.Check TL Infos
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log Variables


Repare For Next Testing If Needed
    [Documentation]    for "Suite Teardown"
    ...    | Author:      | Nikolay Shkulepov <nikolay.shkulepov@nokia.com>   |
    Log To Console    ${\n}There is NOTHING to repare yet.


Start Logging
    [Documentation]    for "Test Setup"
    ...    | Author:      | Nikolay Shkulepov <nikolay.shkulepov@nokia.com>   |
    Log To Console    ${\n}Start Logging...
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Continue On Failure    tracing_keywords.Start X2 and L2 L3 Syscom Trace and Syslogs
    Run Keyword And Continue On Failure    tracing_keywords.Save Resource Usage to File    collection_point=before_scenario
    Run Keyword And Continue On Failure    Process.Run Process   sudo ipsec status   shell=True   stdout=${ts_log_dir}/IPSEC_before_ANR_XMESH.txt
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_PM_COUNTERS}    pmcounters.Wait Until The Next Measurement Period Starts
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log To Console    ${\n}START ROBOT TEST CASE: ${TEST NAME} ...${\n}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]


Stop Logging And Collect Traces
    [Documentation]    for Test Teardown
    ...    | Author:      | Nikolay Shkulepov <nikolay.shkulepov@nokia.com>   |
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log To Console    ${\n}
    IF    ${WITH_PM_COUNTERS}    pmcounters.Wait Until The Next Measurement Period Starts
    IF    ${WITH_PM_COUNTERS}    Sleep    30s    reason=let PM Counters being collected and reported
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log To Console    ${\n}STOP ROBOT TEST CASE: ${TEST NAME}${\n}
    Log To Console    ${\n}Stop Logging and Collect Traces...
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Run Keyword And Continue On Failure    tracing_keywords.Stop X2 Syscom Traces And Stop Btslog Collection
    Run Keyword And Continue On Failure    tracing_keywords.Collect WTS Logs
    Run Keyword And Continue On Failure    tracing_keywords.Save Resource Usage to File    collection_point=after_scenario
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    ${WITH_PM_COUNTERS}
        ${pm_counters_dir}    Run Keyword And Continue On Failure    pmcounters.Collect PM Counter    target_dir=${ts_log_dir}/pmc_${TEST_NAME}
        Set Suite Variable    ${pm_counters_dir}
        Run Keyword And Continue On Failure    common_tools.Zip Older PM Files To Save Conversion Time    directory=${pm_counters_dir}
        ...                                                                                               keep_recent=5
        ...                                                                                               zip_name=archived_PM_files.zip
        ...                                                                                               file_name_filter=PM.BTS
        Run Keyword And Continue On Failure    pmcounters.Convert PM Files To CSV    file_path=${pm_counters_dir}
    END


Store Configuration Files Before Test Begins
    ${configuration_directory}    testline . Get Test Suite Config Directory
    Set Suite Variable     ${configuration_directory}
    ute_workarounds . Patch Testline Configuration For UTE Cloud
    Backup SCF From Classical GNB
    Run Keyword And Ignore Error    gnb.Store Current Swconfig From GNB    gnb_id=${0}    target_dir=${configuration_directory}
    Run Keyword And Ignore Error    wts_ue.Store Current Swconfig From Airphone    ue_id=${0}    target_dir=${configuration_directory}
    Run Keyword And Ignore Error    wts_ue.Store Current WTS Config    target_dir=${configuration_directory}
    ${ret}    Run Keyword And Ignore Error    connect.Connect To Airphone Common Unit
    IF    '${ret[0]}'=='PASS'    ssh.Download File   /rom/simmode/iphy.xml    ${configuration_directory}/iphy_orig.xml    connection=${ret[1]}
    ${ts_log_dir}    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}


Backup SCF From Classical GNB
    ${original_gnb_scf}    gnb.Get SCF From GNB    gnb_id=${0}    target_dir=${configuration_directory}    scf_name=SCFC_gNB0_DU_orig.xml
    Set Suite Variable    ${original_gnb_scf}


Get Expected KPI Value and Deviation
    [Arguments]    ${kpi}
    ${deviation_in_percentages}    Set Variable If
    ...    'throughput_UL' == '${kpi}'    21
    ...    'throughput_DL' == '${kpi}'    20
    ...    ${True}                        100
    ${branch}    Get Variable Value    ${CURRENT_SW_BRANCH}    SBTS00
    ${testline}    testline.Get Testline Name
    ${before}    ${after}    Split String    ${SUITE SOURCE}    /CSV/
    ${path_to_csv_folder}    Set Variable    ${before}/CSV/
    ${json_string_content}    Get File    ${path_to_csv_folder}/resources/expected_kpi_values.json
    ${expected_kpi_values_dict}    Evaluate    json.loads($json_string_content)    modules=json
    ${expected_kpi_value}    Get Variable Value    ${expected_kpi_values_dict}[${branch}][${testline}][${TEST_NAME}][${kpi}]    -1
    IF  '${expected_kpi_value}' == '-1'
        Log    There is an issue with 'Expected KPI Value' look up table. Please double check!!!    level=WARN
        ${expected_kpi_value}    Set Variable    1000
        ${deviation_in_percentages}    Set Variable    100
    END
    RETURN    ${expected_kpi_value}    ${deviation_in_percentages}
