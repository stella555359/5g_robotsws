# # #*** Settings ***
# # #Documentation
# # #...   author: Shi Ming
# # #...   contact: ming.shi@nokia-sbell.com
# # #...   squad group: SG_03
# # #...   feature : 5GC000749-A
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #Suite Setup    Run Keywords
# # ##...            set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked    AND
# # #...            Prepare env with UE    AND
# # #...            Setup for SA Env cell on-air    AND
# # #...            checking type of system board on gnb1    AND
# # #...            get init value of parameter redirFreqEutra    AND
# # ##...            set value of parameter administrativeState on gnb2 cell    new_value=Locked    despite_errors=True
# # #...            Run Keyword And Ignore Error      Lock_gnb2_Cell    AND
# # #...            Run Keyword And Ignore Error      lock gnb1 cell2
# # #
# # #Suite Teardown    Run Keywords
# # ##...               remove object NRADJGNB and XNLINK    AND
# # #...               unLock_gnb2_Cell    AND
# # #...               Run Keyword And Ignore Error     unlock gnb1 cell2
# # ##...               Run Keyword If Any Tests Failed    Run Keyword And Ignore Error    Save snapshot Teardown for COAM
# # #Resource    ./Resources/5GC000749_common_keywords.robot
# # #
# # #
# # #*** Variables ***
# # ###change the parameter actGnbInitRlf as below have been done at SCF importing
# # #${nglogname1}    749A01_Mate20NG01.pcap
# # #${nglogname2}    749A02_Mate20NG01.pcap
# # #${nglogname3_1}    749A03_Mate20NG01.pcap
# # #${nglogname3_2}    749A03_Mate20NG02.pcap
# # #${nglogname4}    749A04_Mate20NG01.pcap
# # #${nglogname5_1}    749A05_Mate20NG01.pcap
# # #${nglogname5_2}    749A05_Mate20NG02.pcap
# # #${nglogname6}    749A06_Mate20NG01.pcap
# # #${nglogname7_1}    749A07_Mate20NG01.pcap
# # #${nglogname7_2}    749A07_Mate20NG02.pcap
# # #${nglogname8}    749A08_Mate20NG01.pcap
# # #
# # #${enblogname1}    749A01_Mate20enb01.pcap
# # #${enblogname6}    749A06_Mate20enb01.pcap
# # #
# # #@{different_redirFreqEutra_value}    4200    4300
# # #@{diffTL_enb_ID}    36721    38221    911    5395    342
# # #${enbvoiceTDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_TDD-0
# # #${enbvoiceFDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_FDD-0
# # #${enbvoice_para}    actConvVoice
# # #@{enbvoice_value}    true    false
# # #${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
# # #${SCF_path}    /opt/workspace/CIT/Master/Scf_files/
# # #${SCF_file_name}    Configuration_scf_gnb1_749.xml
# # #${SCF_file_name_2}    Configuration_scf_gnb2_749.xml
# # #${enb_path}    /tmp
# # #${ngap_filter}    ngap
# # #${s1ap_filter}    s1ap
# # #${index0}    0
# # #${index1}    1
# # #${index2}    2
# # #
# # #@{counter_id}   M55124C02501
# # #@{full_path}    CELLS/NRCELL-1/NRRCC/NR_RRC_RELEASE_REDIR_VFB_LTE
# # #
# # #${ue_type}    huawei
# # #
# # #*** Test Cases ***
# # #[1]5GC000749-A_002_gNB_reject_the_call_when_actNormVCfallback=0
# # #    [Documentation]
# # #    ...    This user scenario describes the gNB action when UE make a call with actNormVCfallback=0 in gNB.
# # #    [Tags]     5GC000749-A
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Prepare env with UE for 6086
# # #    set value of parameter actNormVCfallback    new_value=false    despite_errors=True
# # #    locked LTE cell
# # #    Enb disbale paramater for voice
# # #    Check UE device exist for 6086
# # #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname2}    interface=${gnb1_interface_name}
# # #    Check phone attach successfully on SA env for 6086
# # #    unlocked LTE cell
# # #    Make a voice call on UE for 6086
# # #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}
# # #    Analysis wireshark log for case 749A02_01
# # #    [Teardown]    Run Keywords    sleep    1m    AND    Huawei Mate X20 UE detach for 6086    AND
# # #    ...    set value of parameter actNormVCfallback    despite_errors=True    AND
# # #    ...    Run Keyword And Ignore Error    Enb enable paramater for voice    AND
# # #    ...    Run Keyword And Ignore Error    unlocked LTE cell    AND
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}    AND
# # #    ...    Run Keyword And Ignore Error    recover close seleium logout    AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #*** Keywords ***
# # #pre-check paramater for 749A01
# # #    check value of parameter actRedirect
# # #    check value of parameter actNormVCfallback
# # #    check value of parameter voiceFBmode
# # #    check value of parameter redirRat
# # #    check value of parameter redirFreqEutra
# # #
# # ##Make a voice call on UE
# # ##    Make a call on UE(dial +6688 on UE)
# # ##    End a call on UE
# # #
# # #Analysis wireshark log for case 749A01_01
# # #    Check support 5QI value and related message flow for call reject    logname=${nglogname1}
# # #
# # #Analysis wireshark log on enb for case 749A01_01
# # #    Check voice falls back to lte to the end of sign    logname=${enblogname1}
# # #
# # #pre-check paramater for 749A02
# # #    check value of parameter actRedirect
# # #    check value of parameter actNormVCfallback    value=false
# # #    check value of parameter voiceFBmode
# # #    check value of parameter redirRat
# # #    check value of parameter redirFreqEutra
# # #
# # #Enb disbale paramater for voice
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceTDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[1]
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceFDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[1]
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceFDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[1]
# # #
# # #Enb enable paramater for voice
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[0]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceTDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[0]
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[1]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceFDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[0]
# # #    run keyword if    '${enb_instance}'=='@{diffTL_enb_ID}[2]'
# # #    ...    Connect and Modify the parameter on enblte    dist_name=${enbvoiceFDD_dist}    parameter=${enbvoice_para}
# # #    ...    value=@{enbvoice_value}[0]
# # #
# # #Analysis wireshark log for case 749A02_01
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname2}
# # #
# # #pre-check paramater for 749A03
# # #    check value of parameter actRedirect
# # #    check value of parameter actNormVCfallback
# # #    check value of parameter voiceFBmode    value=disabled
# # #    check value of parameter redirRat
# # #    check value of parameter redirFreqEutra
# # #
# # #Analysis wireshark log for case 749A03_01
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname3_1}
# # #
# # #Analysis wireshark log for case 749A03_02
# # #    Check support 5QI value and related message flow for call reject    logname=${nglogname3_2}
# # #
# # #pre-check paramater for 749A04
# # #    check value of parameter actRedirect
# # #    check value of parameter actNormVCfallback
# # #    check value of parameter voiceFBmode
# # #    check value of parameter redirRat    value=nr
# # #    check value of parameter redirFreqEutra
# # #
# # #Analysis wireshark log for case 749A04_01
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname4}
# # #
# # #pre-check paramater for 749A05
# # #    pre-check paramater for 749A01
# # #
# # #Analysis wireshark log for case 749A05_01
# # #    Check support 5QI value and related message flow for call reject    logname=${nglogname5_1}
# # #
# # #Analysis wireshark log for case 749A05_02
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname5_2}
# # #
# # #pre-check paramater for 749A06
# # #    pre-check paramater for 749A01
# # #    check value of parameter reportingIntervalPm
# # #
# # #Analysis wireshark log for case 749A06_01
# # #    Check support 5QI value and related message flow for call reject    logname=${nglogname6}
# # #
# # #Analysis wireshark log on enb for case 749A06_01
# # #    Check voice falls back to lte to the end of sign    logname=${enblogname6}
# # #
# # #Check PM counter updated with M55124C02501
# # #    sleep    5m
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
# # #    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
# # #    wait until keyword succeeds    5min    1min    Get counter1
# # #    ${result0}    get dictionary values   ${res0}
# # #    ${counter_value0}=    Get couter value    counter_result=${result0}
# # #    ${counter_value0}=    Convert To Integer    ${counter_value0}
# # ##    should be equal    ${counter_value0}    ${length_SEC_RAT_DATA_USAGE_REP}
# # #    should be equal    ${counter_value0}    ${1}
# # #    selenium_coam.logout
# # #    selenium_coam.disable_virtual_display
# # #    Kill firefox process
# # #
# # #recover close seleium logout
# # #    selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
# # #    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
# # #    sleep    1s
# # #    selenium_coam.logout
# # #    selenium_coam.disable_virtual_display
# # #    Kill firefox process
# # #
# # #pre-check paramater for 749A07
# # #    check value of parameter actRedirect
# # #    check value of parameter actNormVCfallback
# # #    check value of parameter voiceFBmode
# # #    check value of parameter redirRat
# # #
# # #Analysis wireshark log for case 749A07_01
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname7_1}
# # #
# # #Analysis wireshark log for case 749A07_02
# # #    Check not support 5QI value and related message flow for call reject    logname=${nglogname7_2}
# # #
# # #pre-check paramater for 749A08
# # #    pre-check paramater for 749A01
# # #    check value of parameter drbInactivityTimerSA
# # #    check value of parameter srbInactivityTimerSA
# # #
# # #Analysis wireshark log for case 749A08_01
# # #    ${status} =    run_keyword_and_return_status    check value of parameter drbInactivityTimerSA    value=10seconds
# # #    Set Suite Variable    ${749A08_01_status}    ${status}
# # #    Check support 5QI value and related message flow for call reject    logname=${nglogname8}
# # #
# # #Prepare env with UE
# # #    [Arguments]    ${ue_index}=${0}
# # #    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}
# # #
# # #Prepare env with UE for 6086
# # #    [Arguments]    ${ue_index}=${0}
# # #    ${release_info}    Get gnb release
# # #    set global variable    ${release_info}
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}
# # #    ...    ELSE        power_ue.Prepare UE    ue_type=huawei    ue_index=${1}
# # #
# # #Check UE device exist for 6086
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Check UE device exist
# # #    ...    ELSE       Check UE device exist    ue_index=${1}
# # #
# # #Check phone attach successfully on SA env for 6086
# # #    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}    ${ue_index}=${0}
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Check phone attach successfully on SA env
# # #    ...     ELSE      Check phone attach successfully on SA env     ue_index=${1}
# # #
# # #Check phone attach successfully on SA env
# # #    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}    ${ue_index}=${0}
# # #    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}    ue_index=${ue_index}
# # #    power_ue.Verify attach    ue_type=${ue_type}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${ue_index}
# # #
# # #Make a voice call on UE for 6086
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Make a voice call on UE
# # #    ...     ELSE      Make a voice call on UE    ue_index=${1}
# # #
# # #Huawei Mate X20 UE detach for 6086
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Huawei Mate X20 UE detach
# # #    ...     ELSE    Huawei Mate X20 UE detach    ue_index=${1}
# # #
# # #Huawei Mate X20 UE detach
# # #    [Arguments]    ${ue_index}=${0}
# # #    power_ue.UE Detach    ue_type=huawei    ue_index=${ue_index}
