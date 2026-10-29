*** Settings ***
Documentation
...   Author: dongjun.tong@nokia-sbell.com
...   Contact: dongjun.tong@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CA_RAN_PZ_HAZ_3
...      CRT            #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes


Library           taf.ccs.aashell   WITH NAME    cli
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library           taf.sw.scout          WITH NAME    scout
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdPreventOverload=0x89008e
...                             rdOverloadIndicationThreshold=0x590226
...                             rdDelayRrcOvlCountermeasures=0x890070
...                             rdKeepOverloadDuration=0x590221
...                             rdOverloadIndicationDurationThreshold=0x590227
...                             rdOverloadRejectionLowerMessageQueuingTime=0x5901FA
...                             rdOverloadRejectionUpperMessageQueuingTime=0x5901FB
...                             rdOverloadTriggeringMessageNumber=0x5901FC


${XX_function_enable}     ${CURDIR}/CB008242_function_enable.json
${XX_function_disable}    ${CURDIR}/CB008242_function_disable.json

${kill_btslog}     timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_dpkg}       timeout 5 sudo kill -9 $(ps -ef|grep dpkg|grep tti-dec.deb|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1

*** Test Cases ***

CB008242-C_#B2 Downgrade automatic UAC triggered by PUCCH load
    [Tags]    QC_32548    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: dongjun.tong@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.3.2024,dongjun.tong@nokia-sbell.com, draft
    [Setup]    Case Precondition
    Airphone Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Airphone Execute Egate Command    ue_register id=1
    Airphone Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    Airphone Execute Egate Command    ue_register id=2
    Airphone Execute Egate Command    set_pdu_param ue=3 pdu=2 trf_type=internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu=2 ue=3 nwslice=1 gw=1
    sleep    150s
    COAM_Admin.Login    bts_host=192.168.255.129
    Run Keyword And Ignore Error    Check Expect Alarm 7533
    sleep    300s
    Airphone Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off
    Airphone Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off
    sleep    360s
    Run Keyword And Ignore Error     Check Cancel Alarm 7533
    [Teardown]    Case Postcondition


CB008242-D_IWK1_ Automatic UAC load triggers interactions – automatic UAC upgrade by number of RRC connections
    [Tags]    QC_32549    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: dongjun.tong@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.3.2024,dongjun.tong@nokia-sbell.com, draft
    [Setup]    Case Precondition
    Airphone Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Airphone Execute Egate Command    ue_register id=1
    Airphone Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    Start tcpdump by command
    sleep    150s
    COAM_Admin.Login    bts_host=192.168.255.129
    Run Keyword And Ignore Error    Check Expect Alarm 7533
    Airphone Execute Egate Command    ue_register id=2
    Airphone Execute Egate Command    set_pdu_param ue=2 pdu=2 trf_type=internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu=2 ue=2 nwslice=1 gw=1
    sleep    300s
    Stop tcpdump by command
    [Teardown]    Case Postcondition


CB008242_D_IWK3_TC01_ Automatic UAC load and overload triggers interactions
    [Tags]    QC_32550    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: dongjun.tong@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.3.2024,dongjun.tong@nokia-sbell.com, draft
    [Setup]    Case Precondition
    Airphone Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Airphone Execute Egate Command    ue_register id=1
    Airphone Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Airphone Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1

    Start tcpdump by command
    sleep    121s
    COAM_Admin.Login    bts_host=192.168.255.129
    Run Keyword And Ignore Error    Check Expect Alarm 7533
    Enter Overload State on gNB-CU
    sleep    90s
    Stop tcpdump by command
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    #log to console    Case Precondition
    #Setup Ap Env    scf_file_path=../config/scf.xml
    #...             local_wts_dir=../config/wts.cfg
    #...             iphy_path=../config/iphy.xml
    Clean Up Env
    Airphone Common Setup    scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/scf07.xml
    ...                      local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/wts07.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/iphy07.xml
    ...     gnb_swconfig_local_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/swconfig07.txt

Case Precondition1
    #log to console    Case Precondition
    #Setup Ap Env    scf_file_path=../config/scf.xml
    #...             local_wts_dir=../config/wts.cfg
    #...             iphy_path=../config/iphy.xml
    Clean Up Env
    Airphone Common Setup    scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/scfCIWK1.xml
    ...                      local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/wts.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/iphy.xml

Case Precondition2
    #log to console    Case Precondition
    #Setup Ap Env    scf_file_path=../config/scf.xml
    #...             local_wts_dir=../config/wts.cfg
    #...             iphy_path=../config/iphy.xml
    Clean Up Env
    Airphone Common Setup    scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/scf07.xml
    ...                      local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/wts07.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/iphy07.xml

Case Precondition3
    #log to console    Case Precondition
    #Setup Ap Env    scf_file_path=../config/scf.xml
    #...             local_wts_dir=../config/wts.cfg
    #...             iphy_path=../config/iphy.xml
    Clean Up Env
    Airphone Common Setup    scf_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/scf07.xml
    ...                      local_wts_dir=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/wts07.cfg
    ...                      iphy_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB008242/config/iphy07.xml


Enter Overload State on gNB-DU
    Log to Console    Entering overload state on gNB-DU
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    1
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    2
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    1
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    0
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Change RnD Flags By aaShell
    [Arguments]    @{args}    ${is_permanent}=no
    cli.create_aashell_cli    name=aashell
    cli.setup    aashell
    cli.change_rad_params    aashell    ${args}    ${is_permanent}
    Sleep  10s    Wait for r&d param application
    [Teardown]    cli.teardown   aashell

Exit Overload State on gNB-DU
    Log to Console    Exiting overload state on gNB-DU
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    100000
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    125000
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    30
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    100
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Enter Overload State on gNB-CU
    Log to Console    Entering overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    0
    ...                            ${RAD_HEXs['rdPreventOverload']}    0

Exit Overload State on gNB-CU
    Log to Console    Exiting overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    100

Case Postcondition
    log to console    Case Postcondition
    Get SCF Internal Id By Scout    no_ute=False
    Airphone Common Teardown
    COAM_Admin.Logout

Prepare UE History Information
    Airphone Execute Egate Command    cmd=ue_change_location id=1-2 cell=1
    Airphone Execute Egate Command    cmd=ue_change_location id=3 cell=2
    Airphone Execute Egate Command    cmd=state_sim_disp
    Airphone Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Preconditions for UE HO Back
    Airphone Execute Egate Command    cmd=ue_reauth id=1 nr_sec_cap=aes|aes
    Airphone Execute Egate Command    cmd=amf_path_switch_param id=1 include_ue_sec_cap=on
    Airphone Execute Egate Command    cmd=smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

Trigger Xn links is Up
    [Arguments]    ${source_gnb_id}=2    ${target_gnb_id}=3    ${action}=delayed_rsp    ${wait_time}=v60s
    ...            ${xn_link_addr}=10.0.1.124
    Log To Console    ${action}
    Log To Console    ${wait_time}
    ${cmd1}    Catenate    gnb_param id=${source_gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command    cmd=${cmd1}
    ${cmd2}    Catenate    nb_xn_link_up gnb=${source_gnb_id} target=${target_gnb_id} xn_link_addr=${xn_link_addr} duplicate_xn_setup_error=yes
    Airphone Execute Egate Command    cmd=${cmd2}

Trigger UE 5QI5 Setup Successfully Default 5QI9
    ${cmd}   Catenate    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=1 by=amf
    ${out}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}     pass_regexp=QosFlow
#    should contain    ${out}    rrcReconfiguration
#    should contain    ${out}    Added QosFlow with QFI:2 5QI:5

Trigger UE 5QI1 Setup Successfully Default 5QI9
    ${cmd}   Catenate    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ${out}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}     pass_regexp=QosFlow
#    should contain    ${out}    rrcReconfiguration
#    should contain    ${out}    Added QosFlow with QFI:3 5QI:1

Trigger UE from Cell1 to SIM Cell by A3
    [Arguments]    ${expected_tput}=4
    Log To Console    ${expected_tput}
    Airphone Gnb Xn Handover Preparation    ue_id=1
#    ${measid}=    ap.Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=633216    event_type=A3
    Airphone Send Measurement NR    ue_id=1    meas_id=2    phycell_id=381    event=A3    srsrp_nr=11    nrsrp_nr=30
    ...                             cmd_regexp=handover
#    ...                             cmd_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
#    ...                             confirm_regexp=3.1
    ${arg_tput}    Airphone Get Average Throughput    ue_id=1    call_type=SA    pdu_id=1
#    Should Be True    ${arg_tput}/1000>${expected_tput}

Trigger UE from SIM Cell to Cell1 by A3
    [Arguments]    ${expected_tput}=4
    Log To Console    ${expected_tput}
    Preconditions for UE HO Back
#    ${measid}=    ap.Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=633216    event_type=A3
    Airphone Gnb Xn Handover Preparation    ue_id=1
    Airphone Send Measurement NR    ue_id=1    meas_id=1    phycell_id=50    event=A3    srsrp_nr=11    nrsrp_nr=30
    ...                             cmd_regexp=handover
#    ...                             cmd_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
#    ...                             confirm_regexp=2.1
#    ${arg_tput}    Airphone Get Average Throughput    ue_id=1    call_type=SA    pdu_id=1
#    Should Be True    ${arg_tput}/1000>${expected_tput}

Check counter for CB008242
	${pi_list}=  Create List    M55143C00003    M55125C00035    M55147C01001    M55147C01002    M55153C00001    M55153C00002
    ${expect_value}    Set Variable    0
	${counter_values_list_M55125C00035}    Check counter value   counter_ID=${pi_list[0]}
	...                                                          expect_value=${expect_value}

Check counter value equal expect value    M55145C00223    1


Check Expect Alarm 7533
	COAM_Admin.GetActiveAlarms
    Expect Fault Should Present    ${7533}

Check Cancel Alarm 7533
    COAM_Admin.GetActiveAlarms
    Expect Fault Should Absent    ${7533}

Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}

stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}

Attach '${uenum}' ue with ''capability to SA cell
    : FOR    ${num}    IN RANGE    1    ${uenum}+1
    \    Airphone SA Attach    ue_id=${num}
    \    sleep    5s
    \    Airphone SA 5G PDU Session Setup    ${num}    ${num}
    \    sleep    5s

Check tcpdump logs
    Log to console    check PCMD
    sleep  30s
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}    t_detach=${time_system}    cell_id=${first_cell_id}
    ...                       record_type=${record_type}    &{check_filter}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list}
    log        ${check_result}
    should be true    ${check_result}

Check tcpdump log for CB008242_2
    ${measurementReport_filter} =    catenate    nr-rrc.measResultServingCell_element && nr-rrc.physCellId
    ...    && nr-rrc.MeasResultNR_element && nr-rrc.physCellId
    ${measurementReport} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${measurementReport_filter}
	should contain    ${measurementReport}    Measurement Report

    ${handover_filter} =    catenate    x2ap.radioNetwork == 0
    ${handover} =    Parse Pcap by expression	   input_file=${capture_file_path}
	...                                            filter_expression=${handover_filter}
    should contain    ${handover}    RRC Reconfiguration


Check tcpdump log for CB008242_1
    ${filter} =    Set Variable    f1ap
    ${filter_expression} =    Set Variable    nr-rrc.drx_Config == 1
    ${xpath} =    Set Variable    .//nr-rrc.drx_Config
	${value_list} =    Parse Pcap by xpath    input_file=${SUITE_LOG_PATH}/${tcpdump_log_name}
	...   filter=${filter}    filter_expression=${filter_expression}    xpath=${xpath}
	Should Be True    ${value_list[0]} == 1


Check tcpdump log for CB008242 DU
    ${filter} =    Set Variable    f1ap
    ${filter_expression}=    catenate    nr-rrc.uac_BarringFactor == 0
	Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_expression}
Check tcpdump log for CB008242 CU
    ${filter} =    Set Variable    f1ap
    ${filter_expression}=    catenate    nr-rrc.uac_BarringFactor == 0
	Parse Pcap by expression    input_file=${capture_file_path}
    ...                                   filter_expression=${filter_expression}

Clean Up Env
    [Arguments]    ${host_ip}=localhost
    [Documentation]    This keyword is to clean up testline process such as btslog and so on.
    ...    Examples:
    ...    | Clean Up Env |
	Run Keyword If     '${host_ip}'=='127.0.0.1' or '${host_ip}'=='localhost'    Run Keywords    Run     ${kill_btslog}
	...     AND     Run   ${kill_dpkg}
	...     AND     Run    rm /tmp/admin_api_*.txt -f
	...     AND     Run    rm /tmp/disconnect*.ims2 -f
	...     AND     Run    rm /tmp/*.pcap* -rf
	...     AND     Run    sudo rm /tmp/*.pcap* -rf
	...     ELSE    Run keywords    SSH.Connect To    ${host_ip}    ute    ute    alias=remote_connection
	...     AND     SSH.Execute    ${kill_btslog}    connection=remote_connection
    ...     AND     SSH.Disconnect    connection=remote_connection
