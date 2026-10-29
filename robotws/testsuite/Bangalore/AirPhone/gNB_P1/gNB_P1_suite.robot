# Copyright (c) 2020 Nokia. All rights reserved.
*** Settings ***
Documentation     This contains gNB_p1 testcases.

Force Tags    RAN_5G
...   STATE_CONFIGURED
Library       taf.transport.ssh    WITH NAME    ssh
Library       OperatingSystem
Library       String
Library       Resources/QTListener.py
Library       taf.sbts.oam.coam.admin    WITH NAME    coam
Resource      External_L3_Call_Common_Keywords.robot
Resource      ../QT/resources/Keywords/gnb_keywords.robot

*** Variables ***
${testsuite}                 /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/L3call_Parallel.robot
${testsuite_seq}             /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/L3call_Sequential.robot
${testsuite_seq_custom}      /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/L3call_Sequential_custom.robot
${testsuite_combo}           /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/L3call_Parallel_4G5GCombo.robot
${testsuite_custom}          /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/L3call_Parallel_custom.robot
${testsuite_multignb}        /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/Multi_GNB_L3_call_parallel.robot
${testsuite_cloud_vran}       /home/ute/test_repository/testsuite/Bangalore/AirPhone/QT/vran_sansa_cmwv_ecpri_tdd.robot
@{verification_list_vran}    x2_is_ok    ue_sib_decoding_is_ok    cell_setup_is_ok
...    ue_register_is_ok    ue_deregister_is_ok    ue_re-register_is_ok    lte_attach_is_ok
...    ue_attach_is_ok    traffic_is_ok    5gdetach_is_ok    detach_is_ok    ue_reattach_is_ok
${gNB_P1_NIDD_Update_Flag}   True
${WTS_CONFIG}                True
${WTS_Config_update_Flag}    False
${TEST_VARIABLES_gNB_P1}    SEPARATOR=${SPACE}
...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v ap_log:startup_l3.log
...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true
...    -v WTS_Config_update_Flag:${WTS_Config_update_Flag}

*** Test Cases ***
7_L3 call on trunk for FS_SANSA_FDD_TDD_ASOE_AP_LOO
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_O_E_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_O_E_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${component_carrier}    8
    Perform L3 call and check status    ${topology}    ${component_carrier}    variable_section=${TEST_VARIABLES_gNB_P1}

12_L3 call on branch for FS_FDD_TDD_FR1_LO_AP_LO
    [Documentation]    In this we are doing the L3 call test for branch runs with Topology - CLOUD_5G_I_LO_AP_LO
    ...    Variant - SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    ...    Modified Date: 03-Dec-2024
    ...    Last Modified by: dilip.revanna@nokia.com
    [Tags]    SBTS23R3    SBTS23R4    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
    Set Test Variable    ${gNB_P1_NIDD_Update_Flag}    False
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    ...    -v MTp_FR1_TDD_SA_dl:100 -v MTp_FR1_TDD_SA_ul:100 -v MTp_FR1_TDD_NSA_dl:100 -v MTp_FR1_TDD_NSA_ul:100
    ...    -v MTp_FR1_FDD_SA_dl_ul:100 -v MTp_FR1_FDD_NSA_dl_ul:100
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    suite=${testsuite_seq_custom}    verification=@{verification_list_seq_custom}
    ...    variable_section=${TEST_VARIABLES_gNB_P1}

13_L3 call on trunk for FS_FDD_SANSA_CPRI_CMWV_MP_AP_LO_2S_1CC
    [Tags]    CIT    SBTS00    RAN_5G_FDD    CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

14_L3 call on trunk for FS_FDD_SANSA_CPRI_CMWV_LO_AP_LO
    [Tags]    CIT    SBTS00    RAN_5G_FDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
    Set Test Variable    ${topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD_TEMP
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

15_L3 call on trunk for FS_TDD_SANSA_ECPRI_CMWV_MP_AP_LO_2S_1CC
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

16_L3 call on trunk for FS_TDD_SANSA_ECPRI_CMWV_LO_AP_LO
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    Set Test Variable    ${topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_TEMP
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

17_L3 call on trunk for CLOUD_5G_I_[LO][LO]_AP_[LOO]
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOO]
    Set Test Variable    ${topology}    CLOUD_5G_I_LOLO_AP_LOO
    Set Test Variable    ${gNB_P1_NIDD_Update_Flag}    False
    Set Test Variable    ${testsuite}    ${testsuite_multignb}
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

18_L3 call on trunk for CLOUD_5G_I_MP_AP_LOOO
    [Tags]    SBTS00    RAN_5G_TDD    CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

19_L3 call on trunk for FS_FDD_TDD_SANSA_CMWV_H_AP_LOO
    [Tags]    CIT    SBTS00    RAN_5G_FDD    CLOUD_5G_O_H_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_O_H_AP_LOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    suite=${testsuite_custom}    verification=@{verification_list_custom}
    ...    variable_section=${TEST_VARIABLES_gNB_P1}

20_L3 call on trunk for FS_TDD_SANSA_ECPRI_CMWV_LN_AP_LO
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    Set Test Variable    ${testsuite}    ${testsuite_custom}
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    suite=${testsuite_custom}    verification=@{verification_list_custom}
    ...    variable_section=${TEST_VARIABLES_gNB_P1}

21_L3 call on trunk for fs_sansa_cpri_cmwv_fdd_eCpri_cmwv_tdd_LOO_AP_LOOO
	[Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    Set Test Variable    ${topology}    CLOUD_5G_I_LOO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:False -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true
    ...    -v custom_cell:True
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    ${bsr_file}    Set Variable    BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Update SCF file for srbInactivityTimerNSA and srbInactivityTimerSA
    Download and Update bsr package    ${bsr_file}
    Perform L3 call without listener and check status    ${topology}    suite=${testsuite_custom}
    ...    verification=@{verification_list_custom}    variable_section=${TEST_VARIABLES_gNB_P1}
    [Teardown]    Update SCF file for srbInactivityTimerNSA and srbInactivityTimerSA    srbInactivityTimerSA=100
    ...    nsaInactivityTimer=100

22_L3 call on trunk for FS_FDD_TDD_SANSA_MP_AP_LOOO
    [Tags]    SBTS00    RAN_5G_TDD    CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Perform L3 call and check status    ${topology}    suite=${testsuite_custom}
    ...    verification=@{verification_list_custom}    variable_section=${TEST_VARIABLES_gNB_P1}

13_L3 call on trunk for FS_FDD_TDD_SANSA_CPRI_ECPRI_CMWV_MP_AP_LO
    [Tags]    CIT    SBTS00    RAN_5G_FDD    CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZHL_GMC
    Set Test Variable    ${topology}    CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZHL_GMC
    Set Test Variable    ${WTS_Config_update_Flag}    True
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    suite=${testsuite_custom}    verification=@{verification_list_custom}
    ...    variable_section=${TEST_VARIABLES_gNB_P1}

23_L3 call on trunk for CLOUD_5G_O_E_AP_LOOO
    [Tags]    SBTS00    RAN_5G_TDD    CLOUD_5G_O_E_AP_LOOO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
    Set Test Variable    ${topology}    CLOUD_5G_O_E_AP_LOOO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1
    Set Test Variable    ${WTS_Config_update_Flag}    False
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:False -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true -v WTS_Config_update_Flag:${WTS_Config_update_Flag}
    ...     --include SA
    Update SCF file for srbInactivityTimer
    ${bsr_file}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Download and Update bsr package    ${bsr_file}
    Perform L3 call and check status    ${topology}    suite=${testsuite_seq}    verification=@{verification_list_sa}
    ...    variable_section=${TEST_VARIABLES_gNB_P1}
    [Teardown]    Update SCF file for srbInactivityTimer    srbInactivityTimerSA=120

24_L3 call on trunk for CLOUD_5G_I_[LO][LO]_AP_[LOOO]
    [Tags]    CIT    SBTS00    RAN_5G_TDD    CLOUD_5G_I_[LO][LO]_AP_[LOOO]
    Set Test Variable    ${topology}    CLOUD_5G_I_LOLO_AP_LOOO
    Set Test Variable    ${gNB_P1_NIDD_Update_Flag}    False
    Set Test Variable    ${testsuite}    ${testsuite_multignb}
    ${TEST_VARIABLES_gNB_P1}    CATENATE    SEPARATOR=${SPACE}
    ...    -v gNB_P1_NIDD_Update_Flag:${gNB_P1_NIDD_Update_Flag} -v WTS_CONFIG:${WTS_CONFIG} -v SKIP_WTS_CONFIG_DL:True -v ap_log:startup_l3.log
    ...    -v SAVE_WTS_PCAP_FLAG:False -v collect_cpu_data_flag:True -v gNB_P1_Run:true
    Set Test Variable    ${TEST_VARIABLES_gNB_P1}
    Perform L3 call and check status    ${topology}    variable_section=${TEST_VARIABLES_gNB_P1}

*** Keywords ***
Update SCF file for srbInactivityTimer
    [Documentation]    This keyword is used to update SCF file on srbInactivityTimer
    ...                Modified Date: 11-Oct-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]     ${srbInactivityTimerSA}=600
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set BTS ID and DIST_NAME
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    srbInactivityTimerSA=${srbInactivityTimerSA}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Update SCF file for srbInactivityTimerNSA and srbInactivityTimerSA
    [Documentation]    This keyword is used to update SCF file on srbInactivityTimer
    ...                Modified Date: 02-Feb-2026
    ...                Last Modified by: kusuma.s@nokia.com
    [Arguments]     ${nsaInactivityTimer}=600    ${srbInactivityTimerSA}=600
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set BTS ID and DIST_NAME
    delta_store.add_parameters_to_delta    dist_name=${NRBTS_DISTNAME}    srbInactivityTimerSA=${srbInactivityTimerSA}
    ...    nsaInactivityTimer=${nsaInactivityTimer}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}

Download and Update bsr package
    [Documentation]    This keyword is used to download and update BSR package
    ...                Modified Date: 02-Feb-2026
    ...                Last Modified by: sravani.k@nokia.com
    [Arguments]     ${bsr_file}=${EMPTY}    ${status_check_interval}=30s
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${wget_cmd}    Set Variable    sudo wget ${dllink}/${bsr_file} --user=app1 --password=AP2ert23WFmnMEDhDkxLs2ojjok -P ${CURDIR}/BSR
    Run    ${wget_cmd}
    Update BSR File    ${bsr_file}    ${status_check_interval}

Update BSR File
    [Arguments]    ${bsr_file}=${EMPTY}    ${status_check_interval}=30s
    admin.setup admin
    FOR    ${i}    IN RANGE    5
        ${status}    admin.Wait Sw Update Possible
        ${is_ready}    Evaluate    '${status}'.strip() in ('completed', 'wait btsReadyForSwUpdate:true succeed')
        Exit For Loop If    ${is_ready}
        Log To Console    msg=Status not ready for SW update (got: ${status}), rechecking after ${status_check_interval}
        Sleep    ${status_check_interval}    msg=Waiting before rechecking status
    END
    Run Keyword If    not ${is_ready}    Fail    SW update status did not become ready after retries. Last status: ${status}
    ${ret}    admin.Update Software    ${CURDIR}/BSR/${bsr_file}
    [Teardown]    admin.teardown admin