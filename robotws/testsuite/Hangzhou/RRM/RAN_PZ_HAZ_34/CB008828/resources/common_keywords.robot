*** Settings ***
Library     OperatingSystem
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     common_keywords.py
Library     ta5g_testline_management
Library     ute_tshark
Library     ta5g_commissioning
Library     taf.ccs.aashell
Library     taf.transport.ssh         WITH NAME    ssh
Library     String
Library     Process
Library     Collections
Library     XML    use_lxml=true
Library     taf.trafficgenerator.iperf       WITH NAME    iperf
Library     taf.config.wts       WITH NAME    wts
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/DeltaStore.py
Library     taf.hw.rf_attenuator    WITH NAME    attenuator

Resource    common_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/outsides/AP_resources/AP_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/common_8196/l3call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/common_8196/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

Documentation
...    author: Yang Di
...    contact: di.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Keywords ***
Register Ue With Default Pdu Session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${gw}=1    ${nwslice}=1  ${other_pud}=${True}  ${other_plmn}=${True}
    ...  ${pass_regexp}=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    Run keyword If  ${other_plmn}  AP_lib.Execute Egate Command    ue_register id=${ue_id} selected_plmn=${ue_id} nwslice=all
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...  ELSE  AP_lib.Execute Egate Command    ue_register id=${ue_id}
    ...                      pass_regexp=${pass_regexp}
    AP_lib.Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    Run Keyword If  ${other_pud}  AP_lib.Execute Egate Command  ue_pdu_session_setup ue=${ue_id} pdu=${${pdu_id}+1} nwslice=${${nwslice}+1} gw=${gw}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${${pdu_id}+1} setup/reestablishment complete

Enable Syslog Info Level Prints
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogOutputLevel}    value=2
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogInputLevel}    value=2
    Change Rad Param With Aashell    param=${ERadCcs_AaSysLogOutputMode}    value=5

Prepare Test Environement And Reach Onair
    [Arguments]    ${perform_tl_reset}     ${cfg_filepath}
    ${BBU_TYPE}  Get Bbu Type
    Log  bbu_type\=${BBU_TYPE}  console=True
    Set Suite Variable  ${BBU_TYPE}
    Run Keyword If    ${perform_tl_reset}    Reset Testline
    Configure VM interfaces
    Modify SCTP Timeout
    Make Sure GNB AP SSH OK
    run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    AP_lib.Start To Capture Wireshark Log
    ...    startup_1
    ${onair_status}    Wait Gnb Configured State and Start Wts    ${cfg_filepath}
    run keyword if  not ${onair_status}  _Retry To Start BTS
    ${match_string}    Create List    GNB-5: XnAP Link with GNB-2    GNB-6: XnAP Link with GNB-2
    Egate Console Log Should Contain  ${WTS_DIR}${/}egate_console.log  ${match_string}

Wait Gnb Configured State and Start Wts
    [Arguments]    ${cfg_filepath}
    ${configured_status}  Set Variable  ${False}
    ${configured_status}    wait gnb configured state  600
    _handle cfg bts1    ${cfg_filepath}
    Return From Keyword If    '${configured_status}'=='${False}'    ${configured_status}
    Run Keyword And Ignore Error    _Start Capture SosReport
    configure and start wts    ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}
    ${onair_status}  Set Variable  ${False}
    Run Keyword And Ignore Error    _Stop Capture SosReport
    ${onair_status}    wait for gnb onair  ${WTS_FILE_PATH}
    Return From Keyword    ${onair_status}

Get Band Type
    [Arguments]    ${cell_id}=1    ${param}=band
    ${nBandIndicator}=     Check Cell Parameter Value    global_cell_id=${cell_id}    parameter=${param}
    ${BandIndicator}=   Remove String    ${nBandIndicator}    n
    ${bandId}=    Set Variable If     ${BandIndicator} > 256    mmWv  cmWv
    [Return]    ${bandId}

Display Qfi stats
    [Arguments]    ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1
    AP_lib.Execute Egate Command    qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=bi
    ...    pass_regexp=Average packet interval

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}=1     ${pdu_id}=1
    AP_lib.Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Configure VM interfaces
    Run and return rc and output     sudo ip addr add 10.0.1.131/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.132/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.133/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.134/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.135/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.136/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.137/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.121/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.3/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.4/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.5/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.6/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.10/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.11/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.30/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.40/24 dev eth3

Modify SCTP Timeout
    Run    sudo sysctl -w net.sctp.sack_timeout=10
    Run    sudo sysctl -w net.sctp.rto_min=200
    Run    sudo sysctl -w net.sctp.rto_initial=200
    Run    sudo sysctl -w net.sctp.rto_max=800
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.sack_timeout=10'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_min=200'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_initial=200'
    Run    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'sysctl -w net.sctp.rto_max=800'

Enable Actslicenumext
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_enable_actSliceNumExt.json
    Modify Json and Commissioning    ${file}

Enable Actransharing
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_enable_actRanSharing.json
    Modify Json and Commissioning    ${file}

Verify Throughput SA
    [Arguments]    ${ue_id}=1    ${Tput_dl}=8    ${Tput_ul}=8    ${sleep_time}=15s  ${pdu_id}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}=  Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}=  Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}=  AP_lib.Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop PDU and release UE
    [Arguments]    ${ue_count}=6  ${ue_id}=1  ${other_pud}=${True}
    ${ue_list}  Set Variable  ${${ue_id}}
    FOR  ${id}  IN RANGE    2  ${${ue_count}+1}
      ${ue_list}    catenate     SEPARATOR=,    ${ue_list}    ${id}
    END
    AP_lib.Execute Egate Command   trf_data_stop ue=${ue_list} pdu=1   pass_regexp=Stopped Downlink Internal traffic on Ue
    Run Keyword If  ${other_pud}  AP_lib.Execute Egate Command  trf_data_stop ue=${ue_list} pdu=2
    ...  pass_regexp=Stopped Downlink Internal traffic on Ue
    AP_lib.Release UEs    ue_type=all

Configure NRPMQAP
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_configure_NRPMQAP.json
    Modify Json and Commissioning    ${file}

Enable M55160 and M55161
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_enable_M55160_M55161.json
    Modify Json and Commissioning    ${file}

Enable 5GC002637 and CB006898
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_enable_5GC002637_CB006898.json
    Modify Json and Commissioning    ${file}

NSA UE attach and trigger ENDC with GNB2
    [Arguments]    ${ue_id}=11    ${cell_id}=1
    AP_lib.Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    AP_lib.Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity

Trigger NSA UE Traffic
    [Arguments]    ${ue_id}=11
    AP_lib.Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=15 trf_id=1    pass_regexp=UDP DL
    sleep    2s
    AP_lib.Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    pass_regexp=UDP UL
    sleep    10s
    Verify Throuput NSA    ue_id=${ue_id}    Tput_dl=9    Tput_ul=3

Verify Throuput NSA
    [Arguments]    ${ue_id}=11    ${sleep_time}=10s    ${Tput_dl}=90    ${Tput_ul}=8
    sleep    ${sleep_time}
        ${ue_id}=    Convert to string    ${ue_id}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg
    ...    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${Tput_dl}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all
    ...    rate_type=ave
    Should Be True    ${ul_throuput}/1000>${Tput_ul}

Stop Traffic NSA UE and release
    [Arguments]    ${ue_id}=11
    AP_lib.Execute Egate Command    trf_data_stop ue=${ue_id} id=2    pass_regexp=Traffic was stopped
    sleep    10s    #sleep for stable traffic
    AP_lib.Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Start SA Data Traffic In Dl Ul
    [Arguments]    ${ue_id}=1     ${pdu_id}=1  ${other_pud}=${True}
    AP_lib.Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=10
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue
    AP_lib.Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue
    Run Keyword If  ${other_pud}  AP_lib.Execute Egate Command    trf_data_start ue=${ue_id} pdu=${${pdu_id}+1} qfi=1 dir=dl mbps=10
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue
    Run Keyword If  ${other_pud}  AP_lib.Execute Egate Command    trf_data_start ue=${ue_id} pdu=${${pdu_id}+1} qfi=1 dir=ul mbps=10
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue

Display Ue Statistics
    [Arguments]    ${ue_id}=1     ${pdu_id}=1  ${other_pud}=${True}
    Display Qfi stats    qfi_id=1    ue_id=${ue_id}    pdu_id=${pdu_id}
    Run Keyword If  ${other_pud}  Display Qfi stats    qfi_id=1    ue_id=${ue_id}    pdu_id=${${pdu_id}+1}
    AP_lib.Execute Egate Command    uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    ...    pass_regexp=Packets received

Verify M55160 Counters For Nsa Users
    Wait For Next Raw Pm Interval
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_AVE_NUMBER_OF_NSA_USERS_PMQAP}
    ...    value=1800    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_AVE_NUM_NSA_USERS_DENOM_PMQAP}
    ...    value=300    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_PEAK_NUMBER_OF_NSA_USERS_PMQAP}
    ...    value=6    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}

Verify M55161 Counters For Sa Users
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    FOR   ${pmqap_id}   IN RANGE    1    7
        Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_AVE_NUMBER_OF_SA_RRC_PMQAP}
        ...    value=300    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
        ...    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_AVE_NUMB_OF_SA_RRC_DENOM_PMQAP}
        ...    value=300    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
        ...    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_PEAK_NUMB_OF_SA_RRC_USER_PMQAP}
        ...    value=1    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
        ...    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
    END

Commisioning Case Scf
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${720}    ${skip_error}=${True}    ${scf_path}=${026_D_SCF_PATH}
    Change Swconfig File    ${PARAMS_IN_SWCONFIG}    ${CONFIG_PATH}/gnb_swconfig.txt
    ${SCF}    Select the Right SCF    ${scf_path}
    wait until keyword succeeds    5x   5s   Connect to gnb coam via ssl
    &{result}    taf.sbts.oam.coam.admin.perform_commissioning    scf_file=${SCF}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${skip_error}    connection=${connection}
    Should be equal as strings
    ...    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    Make Sure GNB AP SSH OK
#    Wait Until Keyword Succeeds    480 sec   20 sec     COAM Check GNB cell on air
#    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online
    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections

Disable actSliceAwareScheduler
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_disable_actSliceAwareScheduler.json
    Modify Json and Commissioning    ${file}

NG and Xn Link Should be active
    BuiltIn.Log    NG and Xn link should be available...     console=${True}
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    XNLINK-1:xnLinkStatus=available
    Object Should Exist    XNLINK-2:xnLinkStatus=available

Network Slices State Should be enabled
    [Arguments]  ${slice_list}
    BuiltIn.Log    Network Slices State Should be enabled...     console=${True}
    @{snssailist}    Create List
    FOR   ${snssai_id}   IN    @{slice_list}
        Append To List    ${snssailist}    SNSSAI-${snssai_id}:operationalState=enabled
    END
    Object Should Exist    ${snssailist}

Continuous Network Slices State Should be enabled
    [Arguments]  ${last_slice}=2000
    @{slices_to_check}    create list
    FOR   ${snssai_id}   IN RANGE    1    ${${last_slice}+1}
        Append To List    ${slices_to_check}    ${snssai_id}
    END
    Network Slices State Should be enabled    ${slices_to_check}

CB008828 Common Test Teardown
    [Arguments]  ${tag}=${empty}
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    AP_lib.Release UEs    ue_type=all
    Check No New Active Faults
    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error  Run Keyword If Test Failed    _Stop Capture SosReport  ${tag}
    Run Keyword And Ignore Error    _Stop Capture Extra Iphy Logs  ${tag}
    Run Keyword And Ignore Error    _Stop Capture UTE Wireshark
    Run Keyword And Ignore Error    Stop Capture Wireshark Log  ${tag}
    robot_common_operations.Common Case Teardown

6 SA UEs Attach on cell1
    ${nwslice}  Set Variable  ${101}
    FOR    ${ue_id}    IN RANGE    1    5
        Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}
        ${nwslice}             evaluate              ${nwslice}+500
    END
    ${nwslice}  Set Variable  ${1981}
    FOR    ${ue_id}    IN RANGE    5    7
        Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}
        ${nwslice}             evaluate              ${nwslice}+10
    END
    FOR    ${ue_id}    IN RANGE    1    7
        Start SA Data Traffic In Dl Ul    ue_id=${ue_id}
        Sleep    ${TRAFFIC_DURATION_SEC}
        Display Ue Statistics    ue_id=${ue_id}
        Verify Throughput SA    ue_id=${ue_id}
    END

Stop Traffic and Release PDU
    [Arguments]    ${ue_count}=6
    FOR  ${ue_id}  IN RANGE    1    ${${ue_count}+1}
        AP_lib.Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    pass_regexp=Traffic was stopped
        AP_lib.Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2    pass_regexp=Traffic was stopped
        AP_lib.Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1
        ...    pass_regexp=Successfully released PDU Session
        AP_lib.Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2
        ...    pass_regexp=Successfully released PDU Session
    END

Suite Case Setup for TL1920
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    _Create Suite Log Directory
    Enable Syslog Info Level Prints
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error  Download Wireshark Plugin
    Run Keyword And Ignore Error  Setup SSH keys on WTS

Add 1990 SNSSAIs
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_add_1990_SNSSAIs.json
    Modify Json and Commissioning    ${file}

Check Slices in SERVEDAMF
    ${result}    Run Keyword And Return Status    Should Contain    ${Active_SW_version}    SBTS24R2
#    ${extendedSnssaiAMFList_length} =    Get Length    ${servedamf_r_list[0]['parameters']['extendedSnssaiAMFList']}
    Run Keyword If    ${result}    Get snssaiAMFList Length    ELSE    Check Slices in NRPLMN_SUPPORT
#    should be true    ${extendedSnssaiAMFList_length}==${926}

Check NRCELL onair
    wait until keyword succeeds    5x   5s   Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    480 sec   20 sec     COAM Check GNB cell on air
    Wait Until Keyword Succeeds    15min    20s    CI_commssion.Verify all cells should be Online

Setup SSH keys on WTS
    Run and return rc and output     sshpass -p ${NOKIA_PASS} ssh-copy-id toor4nsn@192.168.255.129

6 SA UEs Attach with Basic Setup
    Register Ue With Default Pdu Session    ue_id=1    nwslice=${101}
    ${nwslice}  Set Variable  ${1951}
    FOR    ${ue_id}    IN RANGE    2    7
        Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}
        ${nwslice}             evaluate              ${nwslice}+10
    END
    FOR    ${ue_id}    IN RANGE    1    7
        Start SA Data Traffic In Dl Ul    ue_id=${ue_id}
        Sleep    ${TRAFFIC_DURATION_SEC}
        Display Ue Statistics    ue_id=${ue_id}
        Verify Throughput SA    ue_id=${ue_id}
    END

Lock 105 SNSSAIs
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_lock_105_SNSSAIs.json
    Modify Json and Commissioning    ${file}

Network Slices State Should be disabled
    BuiltIn.Log    Network Slices State Should be disabled...     console=${True}
    @{snssailist}    Create List
    FOR   ${snssai_id}   IN RANGE    1    4
        Append To List    ${snssailist}    SNSSAI-${snssai_id}:operationalState=disabled
    END
    FOR   ${snssai_id}   IN RANGE    5    101
        Append To List    ${snssailist}    SNSSAI-${snssai_id}:operationalState=disabled
    END
    FOR   ${snssai_id}   IN RANGE    1996    2001
        Append To List    ${snssailist}    SNSSAI-${snssai_id}:operationalState=disabled
    END
    Object Should Exist    ${snssailist}

Not Locked Network Slices State Should be enabled
    @{slices_to_check}    Create List    4
    FOR   ${snssai_id}   IN RANGE    101    1996
        Append To List    ${slices_to_check}    ${snssai_id}
    END
    Network Slices State Should be enabled    ${slices_to_check}

PDU Session Cannot be Setup for Locked Network Slice
    ${nwslice}  Set Variable  ${1}
    FOR    ${ue_id}    IN    1    6
        AP_lib.Execute Egate Command    ue_register id=${ue_id} selected_plmn=${ue_id} nwslice=all
        ...              pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
        ...              timeout=10
        AP_lib.Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=1
        ...              pass_regexp=Received Initial Context Setup Failure from GNB-2 with cause RAN slice not supported
        ...              timeout=10
        ${nwslice}             evaluate              ${nwslice}+1999
    END

Unlock 105 SNSSAIs
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_unlock_105_SNSSAIs.json
    Modify Json and Commissioning    ${file}

PDU Session Can be Setup for Unlocked Network Slice
    Register Ue With Default Pdu Session    ue_id=${1}    nwslice=${1}
    Register Ue With Default Pdu Session    ue_id=${6}    nwslice=${2000}    other_pud=${false}
    Start SA Data Traffic In Dl Ul    ue_id=${1}
    Start SA Data Traffic In Dl Ul    ue_id=${6}    other_pud=${false}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ue_id=${1}
    Display Ue Statistics    ue_id=${6}    other_pud=${false}
    FOR    ${ue_id}    IN    1    6
        Verify Throughput SA    ue_id=${ue_id}
    END

Add 105 SNSSAIs Case 15A
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_add_105_SNSSAIs_Case_15A.json
    Modify Json and Commissioning    ${file}

Lock 100 SNSSAIs Case 18A
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_lock_100_SNSSAIs_Case_18A.json
    Modify Json and Commissioning    ${file}

Delete 100 SNSSAIs
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_delete_100_SNSSAIs.json
    Modify Json and Commissioning    ${file}

Disable actSliceNumExt and actRanSharing
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_disable_actRanSharing_actSliceNumExt.json
    Modify Json and Commissioning    ${file}

One PDU Session Can be Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}
    Start SA Data Traffic In Dl Ul    ue_id=${ue_id}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics    ue_id=${ue_id}
    Verify Throughput SA    ue_id=${ue_id}

Disable actSliceNumExt
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_disable_actSliceNumExt.json
    Modify Json and Commissioning  ${file}

Case 022_A Network Slices State Should be enabled
    @{slices_to_check}    create list    1    2    101    102    103    1951    1952    1953    1961    1962    1963
    Append To List    ${slices_to_check}    1971    1972    1973    1981    1982    1991    1992
    Network Slices State Should be enabled    ${slices_to_check}

Enable M55352 M55159 M55328
    [Arguments]  ${file}=${DELTA_FILES_PATH}/delta_enable_M55352_M55159_M55328.json
    Modify Json and Commissioning    ${file}

Verify M55159 M55352 M55328 Counters
    Wait For Next Raw Pm Interval
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    FOR   ${pmqap_id}   IN RANGE    1    7
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_UL_PDCP_SDU_CU_PMQAP}
        ...    value=500000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_UL_PDCP_SDU_VOL_SNT_PMQAP}
        ...    value=5000000000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PDCP_SDU_USDAT_CU_PMQAP}
        ...    value=500000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PDCP_SDU_VOL_RCV_PMQAP}
        ...    value=5000000000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PDCP_SDU_DLY_CUUP_PMQAP}
        ...    value=20000000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_UL_PDCP_SDU_DLY_CUUP_PMQAP}
        ...    value=5000000    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
        ...    filepath=${PM_COUNTERS}    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
    END
    FOR   ${counter_id}   IN    ${COUNTER_UL_PDCP_SDU_CU_PMQAP}    ${COUNTER_UL_PDCP_SDU_VOL_SNT_PMQAP}
    ...    ${COUNTER_DL_PDCP_SDU_USDAT_CU_PMQAP}    ${COUNTER_DL_PDCP_SDU_VOL_RCV_PMQAP}
    ...    ${COUNTER_DL_PDCP_SDU_DLY_CUUP_PMQAP}    ${COUNTER_UL_PDCP_SDU_DLY_CUUP_PMQAP}
        Verify If Latest Pm Counter Has Exact Value    counter_id=${counter_id}
        ...    value=0    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
        ...    pmqap=PLMN-PLMN/NRPMQAP-7
    END
    FOR   ${counter_id}   IN    ${COUNTER_MEAS_PERIOD_NR_PDCP_SLICE}    ${COUNTER_PDCP_SDU_DATA_NUM_DL_SLICE}
    ...    ${COUNTER_PDCP_SDU_DATA_VOL_DL_SLICE}    ${COUNTER_PDCP_SDU_DATA_NUM_UL_SLICE}
    ...    ${COUNTER_PDCP_SDU_DATA_VOL_UL_SLICE}    ${COUNTER_PDCP_SDU_DELAY_DL_SLICE}
    ...    ${COUNTER_PDCP_SDU_DELAY_UL_SLICE}
        Verify If Pm Counter Does Not Exist    counter_id=${counter_id}
        ...    local_moid=PLMN-PLMN/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    filepath=${PM_COUNTERS}
    END

Add 1980 SNSSAIs and Enable ActSliceNumExt
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_add_1980_SNSSAIs_and_enable_actSliceNumExt.json
    Modify Json and Commissioning    ${file}

Prepare env with UEs
    Wait Until Keyword Succeeds    2x    1min    UE precondition   ue_index=${0}
    Wait Until Keyword Succeeds    2x    1min    UE precondition   ue_index=${1}

UEs attach
    [Arguments]  ${ue_index}=${0}
#    power_ue.Prepare UE   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    timeout=1m
#    power_ue.Verify attach    ue_type=${ue_${ue_index}_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}

Start UL data transfer
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}    ${iperf_port}=default    ${duration}=1500
    ${iperf_type}  Set Variable If  '${ue_${ue_index}_type.lower()}'=='huawei'    via_app    via_command
    power_ue.Start traffic    ue_type=${ue_${ue_index}_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}    iperf_type=${iperf_type}

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default    ${duration}=1500
    UE Start DL Traffic    throughput=${dl_throughput}    dl_time=${duration}    dl_port=${iperf_port}
    ...    ue_index=${ue_index}

Start DL and UL data transfer
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${ue_index}=${0}    ${dl_port}=default    ${ul_port}=default
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    dl_throughput=${dl_throughput}    ue_index=${ue_index}    iperf_port=${dl_port}
    Start UL data transfer    ul_throughput=${ul_throughput}    ue_index=${ue_index}    iperf_port=${ul_port}

Check PM counters Ratio
    [Arguments]    ${counter_id}    ${filepath}    ${minQuota1}    ${minQuota2}    ${dnid_1}    ${dnid_2}
    ${DL_resourcegroup_1}    Get Latest Pm Counter Value    counter_id=${counter_id}
    ...    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${filepath}
    ...    pmqap=${dnid_1}
    ${DL_resourcegroup_2}    Get Latest Pm Counter Value    counter_id=${counter_id}
    ...    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${filepath}
    ...    pmqap=${dnid_2}
    ${ratio1}                Evaluate            "%.2f" % (${minQuota1}*1.0 / ${100}*1.0)
    ${maxratio1}             Evaluate            "%.2f" % (${ratio1}+0.02)
    ${minratio1}             Evaluate            "%.2f" % (${ratio1}-0.01)
    ${ratio2}                Evaluate            "%.2f" % (${minQuota2}*1.0 / ${100}*1.0)
    ${maxratio2}             Evaluate            "%.2f" % (${ratio2}+0.01)
    ${minratio2}             Evaluate            "%.2f" % (${ratio2}-0.02)
    Should be true      ('${DL_resourcegroup_1}' != '0') and ('${DL_resourcegroup_2}' != '0')
    ${ratio1}    Evaluate  "%.3f" % (${DL_resourcegroup_1}*1.0 / (${DL_resourcegroup_1}*1.0 + ${DL_resourcegroup_2}*1.0))
    ${ratio2}    Evaluate  "%.3f" % (${DL_resourcegroup_2}*1.0 / (${DL_resourcegroup_1}*1.0 + ${DL_resourcegroup_2}*1.0))
    Should be true      (${ratio1} <= ${maxratio1}) and (${ratio1} >= ${minratio1})
    Should be true      (${ratio2} <= ${maxratio2}) and (${ratio2} >= ${minratio2})

Verify M55910 M55338 M55308 M55363 Counters
    Wait For Next Raw Pm Interval
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    ${minQuota1}  ${minQuota2}  Check minQuota
    Check PM counters Ratio    counter_id=${COUNTER_DL_PRB_USED_DATA_NRG}    filepath=${PM_COUNTERS}
    ...    minQuota1=${minQuota1}    minQuota2=${minQuota2}    dnid_1=PLMN-PLMN/${MOID_NRRG1}
    ...    dnid_2=PLMN-PLMN/${MOID_NRRG2}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=${${minQuota1}-2}    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
    ...    pmqap=PLMN-PLMN/${MOID_NRRG1}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PRB_UTIL_SLOT_MAX_NRG}
    ...    value=${${minQuota2}-2}    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
    ...    pmqap=PLMN-PLMN/${MOID_NRRG2}
    FOR   ${counter_id}   IN    ${COUNTER_PRB_AVAIL_PDSCH_NSA_PLMN}    ${COUNTER_PRB_USED_PDSCH_NSA_PLMN}
    ...   ${COUNTER_PRB_PDSCH_UTIL_RATIO_PLMN_MAX}
        Verify If Pm Counter Does Not Exist    counter_id=${counter_id}
        ...    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
    END
    ${counter}  Set Variable If    '${stream}'=='SBTS24R2'    ${COUNTER_PRB_AVAIL_PDSCH_SLICES}
    ...    ${COUNTER_DL_PRB_AVAIL_SAS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter}
    ...    value=2000000000    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
    ${NRPMQAP_ID1}=       Run Keyword If  '${MRBTS_ID}'=='1915'    Set Variable    ${3}
    ...  ELSE IF  '${MRBTS_ID}'=='1916'    Set Variable    ${10}
    ${NRPMQAP_ID2}=       Run Keyword If  '${MRBTS_ID}'=='1915'    Set Variable    ${4}
    ...  ELSE IF  '${MRBTS_ID}'=='1916'    Set Variable    ${9}
    Check PM counters Ratio    counter_id=${COUNTER_DL_PRB_USED_DATA_PMQAP}    filepath=${PM_COUNTERS}
    ...    minQuota1=${minQuota1}    minQuota2=${minQuota2}    dnid_1=PLMN-PLMN/NRPMQAP-${NRPMQAP_ID1}
    ...    dnid_2=PLMN-PLMN/NRPMQAP-${NRPMQAP_ID2}
    FOR   ${pmqap_id}   IN    ${NRPMQAP_ID1}    ${NRPMQAP_ID2}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PRB_UTIL_SLOT_MAX_PMQAP}
        ...    value=20    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
        ...    pmqap=PLMN-PLMN/NRPMQAP-${pmqap_id}
    END

Check minQuota
    [Arguments]    ${dnid_1}=${MOID_NRRG1}    ${dnid_2}=${MOID_NRRG2}
    ${group1}              Fetch from right    ${dnid_1}    -
    ${group2}              Fetch from right    ${dnid_2}    -
    wait until keyword succeeds    5x   5s   Connect to gnb coam via ssl
    ${get_managed_objects}    coam.get_managed_objects    class_name=NRRESOURCEGROUP_A    connection=GNB_OAM
    FOR    ${mo_id}    IN    @{get_managed_objects}
        ${minQuota1}    Run Keyword If
    ...   ${mo_id['distName'].endswith('NRRESOURCEGROUP_PROFILE_A-2/NRRESOURCEGROUP_A-${group1}')}   Set Variable
    ...   ${mo_id['parameters']['schedulerParams']['minQuota']}
        Exit For Loop If    '${minQuota1}'!='${None}'
    END
    FOR    ${mo_id}    IN    @{get_managed_objects}
        ${minQuota2}    Run Keyword If
    ...   ${mo_id['distName'].endswith('NRRESOURCEGROUP_PROFILE_A-2/NRRESOURCEGROUP_A-${group2}')}   Set Variable
    ...  ${mo_id['parameters']['schedulerParams']['minQuota']}
        Exit For Loop If    '${minQuota2}'!='${None}'
    END
    [Return]  ${minQuota1}  ${minQuota2}

Stop DL and UL data transfer
    power_ue.Stop traffic    ue_type=${ue_0_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_0_type}    direction=ul
    power_ue.Stop traffic    ue_type=${ue_1_type}    direction=dl    iperf_port=${tl.ues[1].iperf_details.ports[0]}
    ...    ue_index=${1}
    power_ue.Stop traffic    ue_type=${ue_1_type}    direction=ul    ue_index=${1}

UEs detach
    power_ue.UE Detach    ue_type=${ue_0_type}
    power_ue.UE Detach    ue_type=${ue_1_type}    ue_index=${1}

Enable M55910 M55308 M55363
    Modify Json and Commissioning    ${DELTA_FILES_PATH}/delta_enable_M55910_M55308_M55363.json

Change Quotas of Resource Groups
    [Arguments]    ${minQuota1}=${40}    ${minQuota2}=${60}
    Initialise delta store
    Log to console          Change Quotas of Resource Groups.
    ${moid}  Set Variable  1
    ${nrbts_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${nrcell_path}      Set variable    ${nrbts_path}/NRCELL-${NRCELL_ID}
    ${nrresourcegroup_path}      Set variable    ${nrbts_path}/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP
    Add param to delta  ${nrcell_path}    nrResourceGroupProfileDN       value=${nrbts_path}/NRRESOURCEGROUP_PROFILE-2
    FOR    ${i}    IN    ${minQuota1}  ${minQuota2}
      Add List Parameters To Delta  ${nrresourcegroup_path}-${moid}    nrResourceList
      ...      resourceDN=${nrbts_path}/NRSPIDGRP-${moid}
      Add List Parameters To Delta  ${nrresourcegroup_path}-${moid}    schedulerParams    maxQuota=100   minQuota=${i}
      ${moid}  Evaluate  ${moid}+1
    END
    ${delta}                Collect delta store
    Send Delta Commissioning    input_filepath=${delta}

UEs attach and Start data transfer
    [Arguments]    ${attach_mode}=5G_NSA
    Get Full SCF
    ${dl_tput}  ${ul_tput}  Get Theoretical TP  cellid=${NRCELL_ID}  attach_mode=${attach_mode}
    ${dl_throughput}   Evaluate   int(${dl_tput})+1
    ${ul_throughput}   Evaluate   int(${ul_tput})+1
    UEs attach   ue_index=${0}
    Wait for Start Data Transfer
    Start DL and UL data transfer    dl_throughput=${dl_throughput}M    ul_throughput=${ul_throughput}M
    ...    dl_port=${tl.ues[0].iperf_details.port}
    UEs attach   ue_index=${1}
    Start DL and UL data transfer    dl_throughput=${dl_throughput}M    ul_throughput=${ul_throughput}M    ue_index=${1}
    ...    dl_port=${tl.ues[1].iperf_details.ports[0]}    ul_port=${tl.ues[1].iperf_details.ports[1]}

Change Quotas Json after Testing
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_change_quotas.json
    ${minQuota1}  ${minQuota2}  Check minQuota
    Modify json file  json_file=${file}    old_string=${minQuota1}  new_string=minQuota-1
    Modify json file  json_file=${file}    old_string=${minQuota2}  new_string=minQuota-2

Wait for Start Data Transfer
    [Arguments]     ${guardtime}=160    ${asik_alias}=ASIK Master
    Connect to Common Unit Master
    csn.send command    command=date -u +"%s"    connection=${asik_alias}
    ${date_time}    csn.read output    connection=${asik_alias}
    ${date_time}    Strip String   ${date_time}
    ${basetime}=                    Evaluate                (${date_time} + ${guardtime})
    ${timetowait}=                  Evaluate            300 - (${basetime} % 300)
    log                             time to wait : ${timetowait}
    sleep    ${timetowait}

Change Default nrResourceGroupId
    [Arguments]    ${file}=${DELTA_FILES_PATH}/delta_change_nrResourceGroupId.json
    Modify json file before testing    json_file=${file}
    Modify json file  json_file=${file}    old_string=NRCELLID  new_string=${NRCELL_ID}
    Run Keyword If  '${MRBTS_ID}'=='1915'    Modify json file  json_file=${file}    old_string=NRPLMNID
    ...  new_string=NRPLMN-4  ELSE IF  '${MRBTS_ID}'=='1916'    Modify json file  json_file=${file}   old_string=NRPLMNID
    ...  new_string=NRPLMN-3
    Send Delta Commissioning    input_filepath=${file}

Delete NRRESOURCEGROUP
    Modify Json and Commissioning    ${DELTA_FILES_PATH}/delta_delete_NRRESOURCEGROUP.json

Verify M55910 Counter
    [Arguments]    ${dnid_1}    ${dnid_2}
    Wait For Next Raw Pm Interval
    Wait For Next Raw Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    FOR   ${pmqap_id}   IN    ${dnid_1}    ${dnid_2}
        Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_DL_PRB_USED_DATA_NRG}
        ...    value=800000000    local_moid=PLMN-PLMN/${local_moid_nrcell}    filepath=${PM_COUNTERS}
        ...    pmqap=${pmqap_id}
    END

Change Bandwidth
    Log to console          Change bandwidth.
    &{cellBwpList_1}    create dictionary
    ...      actPdcchCceFragmentControl=false
    ...      actUpperThrAckNackFiltering=false
    ...      actUpperThrAckNackHrFiltering=false
    ...      bwpDN=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7
    ...      cellBwpId=0
    ...      pdcchResourcePreference=peakRate
    &{cellBwpList_2}    create dictionary
    ...      actPdcchCceFragmentControl=false
    ...      actUpperThrAckNackFiltering=false
    ...      actUpperThrAckNackHrFiltering=false
    ...      bwpDN=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70
    ...      cellBwpId=1
    ...      pdcchResourcePreference=peakRate
    Initialise delta store
    ${nrbts_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${servedamf_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    Add list of dictionaries to delta  ${local_moid_nrcell}  cellBwpList  ${cellBwpList_1}  ${cellBwpList_2}
    Add List Parameters To Delta  ${local_moid_nrcell}    pdcchAutoConfig        cellCoverageLevel=normal
    ...        initialBWPMode=sameAsCoreset0        pucchSize=10        startCRBOfCoreset0=0
    Add param to delta  ${local_moid_nrcell}    actPowerSavingBWP       value=false
    Add param to delta  ${local_moid_nrcell}    actUlCgType2            value=false
    Add param to delta  ${local_moid_nrcell}    chBw                    value=20MHz
    Add param to delta  ${local_moid_nrcell}    dmrsTypeAPosition       value=pos2
    Add param to delta  ${local_moid_nrcell}    msg1FrequencyStart      value=14
    Add param to delta  ${local_moid_nrcell}    nrarfcn                 value=638000
    Add param to delta  ${nrbts_path}    actMultipleDedicatedBWPs       value=false
    Add param to delta  ${servedamf_path}    administrativeState        value=Unlocked
    ${delta}                Collect delta store
    Send Delta Commissioning    input_filepath=${delta}

Select the Right SCF
    [Arguments]   ${scf_path}=${SBTS00_SCF_PATH}
    ${dir_path}    ${file}    Split String From Right    ${scf_path}    separator=/    max_split=1
    ${scfpath_other}=               Catenate                  ${dir_path}/${MRBTS_ID}_${file}
    ${selectedScfFile}=       Run Keyword If  '${MRBTS_ID}'=='1920'    Set Variable    ${scf_path}
    ...                       ELSE    Set Variable    ${scfpath_other}
    [Return]                  ${selectedScfFile}

Modify Json and Commissioning
    [Arguments]   ${file}
    Modify json file before testing    json_file=${file}
    Send Delta Commissioning    input_filepath=${file}

Get Full SCF
    taf_coam.COAM Login
    taf_coam.COAM Backup Full SCF  local_dir=${SAVE LOG DIRECTORY}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Get Theoretical TP
    [Arguments]     ${cellid}=2  ${attach_mode}=5G_NSA
    ${ue_ul_layer}  Set Variable If  '${attach_mode}'=='5G_NSA'  1  2
    ${ue_ul_layer}   convert to integer    ${ue_ul_layer}
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...    scf_path=${SAVE LOG DIRECTORY}/full_commission.xml    cell_id=${cellid}    ue_dl_layer=4
    ...    ue_ul_layer=${ue_ul_layer}
    [Return]  ${theoretical_dl}    ${theoretical_ul}

Get Some Variables
    ${NRCELL_ID}=       Run Keyword If  '${MRBTS_ID}'=='1915'    Set Variable    ${2}
    ...  ELSE IF  '${MRBTS_ID}'=='1916'    Set Variable    ${4}
    Set Test Variable  ${NRCELL_ID}
    ${local_moid_nrcell}  Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_ID}
    Set Test Variable  ${local_moid_nrcell}
    ${MOID_NRRG1}  Set Variable    NRRESOURCEGROUP-1
    Set Test Variable  ${MOID_NRRG1}
    ${MOID_NRRG2}  Set Variable    NRRESOURCEGROUP-2
    Set Test Variable  ${MOID_NRRG2}

Commissioning 1916 Case C
    return from keyword if    '${MRBTS_ID}' == '1915'
    Log to console          Commissioning 1916.
    Initialise delta store
    ${nrpmqap_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1/NRPMQAP-
    ${nrresourcegroup_path}       Set variable
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-
    ${snssai_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SNSSAI-
    ${trackingarea_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/TRACKINGAREA-
    ${snssai}  Set Variable  ${1}
    FOR  ${index}  IN RANGE    2  7
       Add List Parameters To Delta  ${nrpmqap_path}${index}        snssaiList      snssaiDN=SNSSAI-${snssai}
       ...  snssaiDNLast=SNSSAI-${${snssai}+1}
       ${snssai}             evaluate              ${snssai}+2
    END
    Add List Parameters To Delta  ${nrpmqap_path}4        cfgPlmnId      mcc=262      mnc=3      mncLength=2
    Add List Parameters To Delta  ${nrresourcegroup_path}2        nrResourceList    resourceDN=SNSSAI-2
    ${snssai}  Set Variable  ${1991}
    FOR  ${index}  IN RANGE    11  21
       Add List Parameters To Delta  ${nrresourcegroup_path}${index}        nrResourceList    resourceDN=SNSSAI-${snssai}
       ${snssai}             evaluate              ${snssai}+1
    END
    FOR  ${index}  IN RANGE    21  33
       Delete Managed Object From Delta  ${nrresourcegroup_path}${index}
    END
    Add List Parameters To Delta  ${trackingarea_path}200    snssaiList      snssaiDN=SNSSAI-1
   ...  snssaiDNLast=SNSSAI-10
    FOR  ${index}  IN RANGE    11  1991
       Delete Managed Object From Delta  ${snssai_path}${index}
    END
    ${delta}                Collect delta store
    Send Delta Commissioning    input_filepath=${delta}

Online Cell And TRACKINGAREAs Addition
    [Arguments]  ${addition_cell}=4
    ${file_path}   ${filenames}=    Split Path     ${scf_path}
    Log To Console    Filenames: ${filenames}
    ${file_name}   ${extention}=    Split Extension     ${filenames}
    Log To Console    File name: ${file_name}
    ${file}        Catenate     SEPARATOR=_   CONF-1   ${file_name}
    ${result}    run keyword and return status    should contain any    ${Active_SW_version}    24R2    24R3    25R1
    ${bts_configuration}    Set Variable If    ${result}    Current    CURRENT_BTS_CONF-1
    ${plan_to_copy_from}    Set Variable If    ${result}    CONF-1     ${file}
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=${bts_configuration}
    log to console  Add object
    FOR  ${i}  IN RANGE   202    204
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=TRACKINGAREA    plan_to_copy_from=${plan_to_copy_from}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/TRACKINGAREA-${i}
        ...    include_subobject=${True}   id_value=${i}    timeout=15
    END
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${plan_to_copy_from}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${plan_to_copy_from}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${plan_to_copy_from}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
    ...    id_value=${addition_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_cell}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    [Teardown]  selenium logout and close browser

Online Cell And TRACKINGAREAs Deletion
    [Arguments]  ${deletion_cell}=4    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${deletion_cellgrp}    Get Cell Group From Cell    cell_id=${deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    Set Test Variable  ${addition_cellgrp}  ${deletion_cellgrp}
    Set Test Variable  ${cell_grp}
    Set Test Variable  ${scf_path}
    log to console  Delete object
    FOR  ${i}  IN RANGE   202    204
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/TRACKINGAREA-${i}    timeout=15
    END
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    COAM Check GNB cell on air
    [Teardown]  selenium logout and close browser

Check Slices in NRPLMN_SUPPORT
    ${amf_distname}   set variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/SERVEDAMF-1
    ${snssai_Number} =    Set Variable    ${0}
    taf_coam.COAM Login
    FOR  ${id}  IN RANGE    1  7
       ${number}     COAM Get Parameter Value By XPath
       ...  xpath=cmData/managedObject[@distName="${amf_distname}/NRPLMN_SUPPORT-${id}"]/p[@name="snssaiAMFNumber"]
       ${snssai_Number} =    Evaluate    ${number} + ${snssai_Number}
    END
    should be true    ${snssai_Number}==${2000}
    [Teardown]  taf_coam.COAM Logout

Get snssaiAMFList Length
    wait until keyword succeeds    5x   5s   Connect to gnb coam via ssl
    @{servedamf_r_list}    coam.Get managed objects    class_name=SERVEDAMF_R    connection=GNB_OAM
    ${snssaiAMFList_length} =    Get Length    ${servedamf_r_list[0]['parameters']['snssaiAMFList']}
    should be true    ${snssaiAMFList_length}==${1024}

Perform commissioning FID7516
    Log to console          Perform commissioning to clear FID7516.
    connect to gnb coam via ssl
    ${cell_list}    Get All Cell Id
    ${first_bwp}          Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-0
    ${second_bwp}          Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-44
    ${nrcell_path}          Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-
    Initialise delta store
    &{searchSpaceCommon_1}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=3
    ...      monitoringSymbolWithinSlot=symbol_0      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl5      searchSpaceId=1
    ...      searchSpaceType=Type0A      slotOffset=0
    &{searchSpaceCommon_2}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=1
    ...      monitoringSymbolWithinSlot=symbol_0_1      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl1      searchSpaceId=2
    ...      searchSpaceType=Type1      slotOffset=0
    &{searchSpaceCommon_3}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=3
    ...      monitoringSymbolWithinSlot=symbol_0      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl20      searchSpaceId=3
    ...      searchSpaceType=Type2      slotOffset=5
    &{searchSpaceCommon_4}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=3
    ...      monitoringSymbolWithinSlot=symbol_0      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl5      searchSpaceId=4
    ...      searchSpaceType=Type0A      slotOffset=0
    &{searchSpaceCommon_5}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=1
    ...      monitoringSymbolWithinSlot=symbol_0_1      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl1      searchSpaceId=5
    ...      searchSpaceType=Type1      slotOffset=0
    &{searchSpaceCommon_6}    create dictionary      coresetId=0      dciFormat=formats0-0-And-1-0      duration=3
    ...      monitoringSymbolWithinSlot=symbol_0      numOfPdcchCandidatesInAL2=n0      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n0      numOfPdcchCandidatesInAL16=n0      periodicity=sl20      searchSpaceId=6
    ...      searchSpaceType=Type2      slotOffset=5
    Add list of dictionaries to delta  ${first_bwp}/PDCCH-1/PDCCH_CONFIG_COMMON-1  searchSpaceCommon
    ...  ${searchSpaceCommon_1}  ${searchSpaceCommon_2}  ${searchSpaceCommon_3}
    Add list of dictionaries to delta  ${second_bwp}/PDCCH-1/PDCCH_CONFIG_COMMON-1  searchSpaceCommon
    ...  ${searchSpaceCommon_4}  ${searchSpaceCommon_5}  ${searchSpaceCommon_6}
    FOR     ${cell}    IN     @{cell_list}
        Add param to delta  ${nrcell_path}${cell}    administrativeState                       value=Locked
        Add param to delta  ${nrcell_path}${cell}    msg1FrequencyStart                        value=14
        Add param to delta  ${nrcell_path}${cell}    pagingOffset                              value=3
        Add param to delta  ${nrcell_path}${cell}    type0SearchSpaceConfigurationIndex        value=5
    END
    ${delta}                Collect delta store
    Wait until keyword succeeds  10min   1min   Send Delta Commissioning    input_filepath=${delta}

Set param Based On The Release
    [Arguments]    ${wireshark_flag}=${FALSE}
    ${status}=    Run Keyword And Return Status    Should Contain Any    ${Active_SW_version}    24R2    24R3
    run keyword if  not ${status}    Run Keywords    Perform commissioning FID7516    AND    Unlock NRCELLs    AND
    ...    Run keyword if   ${wireshark_flag} == True   Set test variable   ${RESET_TL}   ${True}

Unlock NRCELLs
    Log to console          Unlock NRCELLs
    ${cell_list}    Get All Cell Id
    Initialise delta store
    ${nrcell_path}          Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-
    FOR     ${cell}    IN     @{cell_list}
        Add param to delta  ${nrcell_path}${cell}    administrativeState                       value=Unlocked
    END
    ${delta}                Collect delta store
    Wait until keyword succeeds  10min   1min   Send Delta Commissioning    input_filepath=${delta}

UE Preparation At Case Setup
    power_ue.Prepare UE   ue_type=${ue_0_type}   ue_index=0
    wait until keyword succeeds    5x   10s    power_ue.Prepare UE   ue_type=${ue_1_type}   ue_index=1

update swconfig
    log to console    \n update /ffs/run/swconfig.txt
    ${asik_addr_temp}   set variable if      '${testline_name}' == 'null'    192.168.255.129    ${asik_addr}
    ${swconfig_path}   Set Variable    ${CONFIG_PATH}/swconfig.txt
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${swconfig_path}
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p ${asik_password} scp ${swconfig_path} ${asik_username}@${asik_addr_temp}:/ffs/run/
    ...    shell=yes
    csn.connect_to    ${asik_addr_temp}    ${asik_username}    ${asik_password}    alias=OAM
    csn.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=OAM
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=OAM
    log to console    \n ${swconfig_output}
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=OAM
    [Teardown]  run keywords  COAM Teardown gnb connections    AND    csn.disconnect    connection=OAM

