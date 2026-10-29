*** Settings ***
Suite Setup       8748 Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Library    OperatingSystem
Library    BuiltIn
Library    String
Library    Collections
Library    ArchiveLibrary
Library    taf.pdu       WITH NAME    pdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001783/TestData/CB008748_A_variables.py
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02
...   Feature CB008748_A

Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CIT
...   PY39

*** Test Cases ***
[1]CB009359-J_02_General_SiSo_Auto_RF_lock_unlock_concurrent_mode_NR1CC_16D8U_100M_LTE3CC_16D16U_3x20M
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

CB007112_5G_A_1_L1_and_L2RT_instances_startup_successfully_based_on_internal_cell_set_ABIO
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]TDD mMIMO Chile AEHC 5GNR Only 3CC_100M_16D8U_50M_8D4U_20M_8D4U_L3_Call
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

CB007777-5G-C_02_01_General_SiSo_Power_Meter_counter_update_for_energy_consumption_on_AEHC
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1][1.0] CB012269_A_10_Sub-band TRS Rate Matching_actSubTrsRateMatch_true
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1][1.0] CB012269_B_2_UE specific CSI-RS optimization_coexist_with_cell_specific_csirs_Ues
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CNI_110468_A_10_Verify_Rank4_Change_During_DLTput
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB009496_5G_A_1_Verify_CellSetup_With_1CC_Configuration
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB010513_I_1_CB007112_E_Load-based_PRB_Pooling_with_Zero_Allocation_Bypass
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1][1.0] CB009496_5G_C_20_Verify_Tput_Performance_In_2CC_Configuration
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB008927-M_46_based on 2 Ues check wide band and sub-band SRS status with dynamicswitch enable
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB011117_A_10_SingleUE_Handover_with_SRS_for_SB_BF_actHoWithSbBf_true_Inter-Frequency_HO_measurement_gap_intra-gNB_32TRX_1116-0ms_and_8406
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1][1.0] CB012269_C_7_Interworking with CB008662 Adaptive re-transmission
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB011117_E_40_Enhanced_Algorithm_DMRS_switch_monitor_One_PDSCH_DMRS_UE_with_subband BF_32TRX_1116-0ms_and_8406
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB008927-M_53_check EIRP meansurement full buffer with signal UE with an active antenna array in digital beamforming with dynamicswitch
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB011160_5G_AB_16_Verify_CellSetup_And_Tput_With_3CC_Configuration_Max_4MMSE_UEs_per_cc_128PRB_8DxU_comb4(Diff bfSubbandSize)
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB008322_D_21_Verify_2UEs_Comb4_UL_DL_BF_100M_2T4R_100M_32TRX
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

[1]CB008322_E_5_Verify_2UEs_IWK_cDRX_CLPC_100M_16_PRBs_32TRX
    [Timeout]   6h
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

*** Keywords ***
Capture RFSW Log and Download
    [Arguments]    ${ru_index}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}
    ${rfsw_path}    ${rfsw_file}    Split Path    ${rfsw_log_path_on_ru}
    ${rfsw_file_name}    ${rfsw_file_ext}    Split Extension    ${rfsw_file}
    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}    connection=RU_${ru_index}    download_dir=${TS_CASE_LOG_PATH}
    [Return]    ${rfsw_file_name}

Lock all RUs
    [Arguments]  ${ru_index_list}
    ${led_status_list_lock}    create list    YELLOW YELLOW
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=${rfsw_file_name}
        selenium_coam.lock_ru    ru_index=${ru_index}
        Run  rm -rf ${SAVE LOG DIRECTORY}/${rfsw_file_name}
        sleep  15
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list_lock}    exclude_led_status=GREEN GREEN
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_lock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        Run  rm -rf ${SAVE LOG DIRECTORY}/${rfsw_file_name}
    END

Unock all RUs
    [Arguments]  ${ru_index_list}
    ${led_status_list}    create list   GREEN GREEN
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=${rfsw_file_name}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run  rm -rf ${SAVE LOG DIRECTORY}/${rfsw_file_name}
        Connect to all rus with allocated IP
        ${rfsw_file_name}    Capture RFSW Log and Download    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=${rfsw_file_name}   timestamp=${new_timestamp}
        check LED list    matches=${mathes}    led_status_list=${led_status_list}    exclude_led_status=YELLOW YELLOW
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message_RU_unlock    PC_soap_path=${PC_soap_path}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
        Run  rm -rf ${SAVE LOG DIRECTORY}/${rfsw_file_name}
    END

UE Attach and Start Traffic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=M40PUI1.1
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}
#    Connect to Common Unit Master  alias=ASIK MASTER
#    connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#    ...    alias=ASIK MASTER    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}
    ...                       duration=${DURATION}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${DL_THROUGHPUT}
    ...                       duration=${DURATION}    ue_index=${1}
    sleep    20min
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
#    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Convert To String    16056321
    ${cell_id}    Create List    ${cell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${UL_EXPECT_30M}    target_avg_percent=0.9    min_percent=0.8
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${DL_EXPECT_30M}
    ${ue_index}    Create List    ${1}
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index}

SiSo_RF_module_power_reset
   [Arguments]  ${ru_index}=1  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}
    END
    [Teardown]  Power On RU And Check    ru_index_list=${ru_index_list}

Power On RU And Check
    [Arguments]  ${ru_index_list}
    log to console    \n***Power On RU And Check***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
    END
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

Perform RU Power Off
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    BuiltIn.Log    Reset RU via Power off and Power On.

Perform RU Power On
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].pdu_port.port_no}
    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Connect to all rus with allocated IP
    [Documentation]  Author: Ren Biyao
    ...    This keyword supports all establishment of rus via allocated IP.
    ...    2020-01-21 Ding Binmei: Return all ru alias
    ...    2020-02-18 Liu Zheng: get the ru list from init to cluster
    ...    2020-09-23 Yan Xin: all rus connection with multi-du scenario
    [Arguments]    ${connection}=GNB_OAM    ${du_index}=${0}    ${du_alias}=du_${du_index}
    connection_alias_store.Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    @{list_ru_alias}    Create list
    ${ru_index_list}    Get RU index list    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
      Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
      ...    asik_alias=${du_alias}    connection=${connection}
      ...    ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
      ...    ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
      Append to list    ${list_ru_alias}    RU_${ru_index}
    END
    [Return]  ${list_ru_alias}

8748 Coam Suite Setup
    SISO Coam Suite Setup
    run keyword if     '${testline_name}' == '${EMPTY}'    add fault to the allowed fault list    faultId=${4681}
    #${version}     get software version
    #Load Case SCF and Commission SCF for 8748       scf_file=commissionings/HGZ/7_5_UTE5G402T980/SCF_${version}_977.xml

Load Case SCF and Commission SCF for 8748
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -69
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version['Active']}    0    8
    [Return]     ${stream}
