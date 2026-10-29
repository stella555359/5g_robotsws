*** Settings ***
Documentation
...   Author: ge.cao@nokia-sbell.com
...   Contact: ge.caao@nokia-sbell.com
...   Description: This set of robot cases is used for CB0010411


Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup   Common Test Setup For AIC
Test Teardown    Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                CRT
...                TRUNK

Test Timeout       630 minutes

Resource           ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
@{condition_1}    dlFdSchedData.rrmDeltaCqiMuMimo    >    0
@{conditions_1}    ${condition_1}
*** Test Cases ***
CB0010411_5GC001796_B_Update_of_iniDeltaCqi_Calculation
    [Tags]    QC_32338       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: ge.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    Attach UE0 And start traffic
    Sleep    10S    reason=Waiting For traffic stable
    ${vdu_web_ip}=     Start TTI Log In vDU       10.69.9.51   username=dcapuser   password=Nokia1234!
	...                        gnb_index=${0}   vdu_index=${0}     alias=dcap
    Sleep    5S    reason=Waiting For TTI capture
    ${tti_csv_file_paths}=    Stop And Decode TTI Log In vDU    ${vdu_web_ip}
    log to console    ${tti_csv_file_paths}
	${path1}    Set Variable    ${tti_csv_file_paths}[0]
    ${matching_rows_tbs}    ${row_nums}    process_csv.filter_rows_with_conditions_from_csv_file
    ...    ${path1}
    ...    ${conditions_1}
    Should Be Empty    ${matching_rows_tbs}

CB0010411_5GC000526_Generating_Artificial_Load_With_Beamforming_Turned_Off
    [Tags]    QC_32353    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: ge.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    Prepare UE0
    Attach UE0
    Start BIP log
    sleep    2s
    ${bip_local_file_path}    Stop Bip Log And Download To K8s Master
    Check Mcshark BIP Log
    Detach UE0

[1]CB0010411_5GC001294_B_TC01_UL_performance_verification_IRC_vs_MRC_with_BF_TDD_eCPRI_1_interference
    [Tags]    QC_32348    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: ge.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    Commissioning SCF And Check On Air   numberOfRxBeamforming_2Rx.xml
#    Start Collect Wireshark Log In vDU
    sleep    10
    Adjust PA Signal To Attach
    sleep    5
    Prepare UE0
    Attach UE0
#    Start DL Call For UE0
    Start UL Call For UE0
    sleep    30
#    Check DL Tput By K8s Log
    ${ULTP_2RX}    Check UL Tput By K8s Log
    Detach UE0
    Commissioning SCF And Check On Air   numberOfRxBeamforming_4Rx.xml
    Prepare UE0
    Attach UE0
    Start UL Call For UE0
    sleep    30
    ${ULTP_4RX}     Check UL Tput By K8s Log
    should be true  ${ULTP_2RX}<=${ULTP_4RX}

*** Keywords ***
Adjust PA Signal To Attach
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TOPYOUNG    du_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=20    ${attenuation_channels[1]}=20    ${attenuation_channels[2]}=40
    ...    ${attenuation_channels[3]}=40    ${attenuation_channels[4]}=40    ${attenuation_channels[5]}=40
    ...    ${attenuation_channels[6]}=40    ${attenuation_channels[7]}=40    ${attenuation_channels[8]}=40
    ...    ${attenuation_channels[9]}=40    ${attenuation_channels[10]}=40   ${attenuation_channels[11]}=40
    ...    ${attenuation_channels[12]}=40   ${attenuation_channels[13]}=40   ${attenuation_channels[14]}=40
    ...    ${attenuation_channels[15]}=40
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    attenuation change complete

Check DL Tput By K8s Log
    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                      container_name=l2rt    pod_name=l2rt   timeout=${10}
    Set Test Variable    ${dl_l2rt_tput_local_file_path}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
    should be true  ${max_dl_tput}>100

Attach UE0 And start traffic
    Prepare UE0
    Attach UE0
    Start DL Call For UE0
Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	Set Test Variable    ${ue0_type}
	Log to Console    \n***Prepare UE***
    Prepare UE    ${ue0_type}    ue_index=${0}    ui_version=MATE40PROUI1.0
Attach UE0
    Log to Console    \n***UE Attach***
    UE Attach    ${ue0_type}    ue_index=${0}    verify_attach=True
Start DL Call For UE0
    [Arguments]    ${throughput}=300M    ${duration}=${6000}
    Log To Console    \nStart the DL TPUT
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=${throughput}    duration=${duration}
Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Common Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error    svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error    vDU Logout By Rest
    Run Keyword And Ignore Error    Detach UE0
    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
    ...                                                             conn=${conn}    timeout=${timeout}

Commission Full SCF For vDU
    [Arguments]    ${scf_path}=${default_scf_path}/7_5_UTE5GAIC015T008_vDU_SCF_0.300_1301.xml    ${vdu_index}=${0}
    vDU Update Full SCF By Rest    scf_path=${scf_path}
    ...                               vdu_index=${vdu_index}
Commission Full SCF For vCU
    [Arguments]    ${plan_file_path_default}   ${plan_name}=TA_plan_file
    vCU Full Commssion By Rest  path_of_commission_file=${plan_file_path_default}  plan_name=${plan_name}

Stop Wireshark
    ${local_file_path}    Stop Wireshark Log And Download To K8s Master With gzip In vCU   gnb_index=${0}
    ...                                                                    container_name=nwmgmt
    ...                                                                    pod_name=cpif
    ...                                                                    timeout=${10}
    ...                                                                    log_name=hondover

Check Mcshark BIP Log
    Log To Console    Check McShark BIP Log
    ${filter}=    Catenate        DlData_PdschGrant.mcs
    ${csv_title_list}   Set Variable    -e DlData_PdschGrant.mcs
    ${csvname}=    Set Variable    ${TEST_LOG_DIRECTORY}/csv_2535_BIP.csv
    Convert BIP To CSV By MCShark    ${bip_local_file_path}    ${csvname}    ${filter}    ${csv_title_list}
    ${csv_matrix}=    read_csv_file_into_matrix    file_path=${csvname}
    ${column_list_dmrs}=    get_column_from_matrix    matrix=${csv_matrix}    column_nubmer=${1}
    ${column_list_mcs}=    get_column_from_matrix    matrix=${csv_matrix}    column_nubmer=${2}
    Remove From List    ${column_list_dmrs}    0
    Remove From List    ${column_list_mcs}    0
    ${len_dmrs}=    get length    ${column_list_dmrs}
    ${len_mcs}=    get length    ${column_list_mcs}
    Should Be Equal    ${len_dmrs}  ${len_mcs}
    Should Be True    ${len_dmrs}>0
    FOR    ${index}    IN RANGE    ${len_dmrs}
        Continue For Loop If    ${column_list_dmrs[${index}]} == 0x01
        ${is_pass}    Set Variable If    ${column_list_mcs[${index}]} == 0x00000009     ${True}    ${False}
        Set Test Variable  ${is_pass}
        Exit For Loop If  ${is_pass}
    END
    Should Be True  ${is_pass}==${True}

Commissioning SCF And Check On Air
    [Arguments]    ${scf_name}
    Log to console    \n***Commissioning SCF ${scf_name}  And Check On Air***
    vDU Update Full SCF By Rest    scf_path=${CURDIR}/${scf_name}
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair

Start UL Call For UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=500M    duration=${600}

Check UL Tput By K8s Log
    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                                     container_name=l2rt    pod_name=l2rt   timeout=${10}
    Set Test Variable    ${ul_l2rt_tput_local_file_path}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
    should be true  ${max_ul_tput}>25
    [Return]    ${max_ul_tput}


Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}


