*** Setting ***
Documentation
...     author:         prasun.chakravorty@nokia.com
...     maintainer:     Prasun Chakravorty
...     INTRODUCTION:   CB008608_CB008541 CRT Automation
...     Feature:        CB010411/CB008608-8541
...     TEST SET NAME:  CB008541_A#B.2_SA_UEsupporting_Pcell_LBWP_Scell_SBWP_BlindAdd_for_TDD_TDD_2CC_CA
...     TESTING SPLIT:     See CB010411 testplan
...     CONTACTS:          II_MN_RAN_RD_VRF_BLR1_T09_GMS <I_MN_RAN_RD_VRF_BLR1_T09@internal.nsn.com>
...     REFERENCES:        CB008608 CFAM

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            CB008608_8541_resource.robot
Resource            resources/AIC_8541_TCrelated_keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Library             ../resources/python/IphyUpdate.py
Library             taf.collectors.pmcounters

Suite Setup             Run keywords   BuiltIn.Run Keyword And Ignore Error   Test Suite Setup
...                     AND     BuiltIn.Run Keyword And Ignore Error   AIC Software Build Info
...                     AND     BuiltIn.Run Keyword And Ignore Error   Fetch Taf Library used in TL
...                     AND    Prepare AIC TL with all config files     ${vcu_file_path}    ${vdu_file_path}
...                            ${RMOD_name}   ${iphy_file_path}
#...                     AND    Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
#...                     AND    Fast Delta Commission vDU With Delta XML File      ${delta_du}
#...                     AND    Update vDU TargetBDxml contents in AP_iphyxml   ${RMOD_name}     ${iphy_file_path}
#...                     AND    BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${30}
#...                     AND    Verify RMODs Online Status   ${100}
...                     AND    BuiltIn.Run Keyword And Ignore Error   Add WTS Ipaddr At VM
...                     AND    log to console   loading cfg.................
...                     AND    Start WTS Using WTS_Runner     ${wts_cfg_file}


Suite Teardown          Run keywords        Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/8608_new_bwp_basic_setup.cfg
${vcu_file_path}    ${CURDIR}/config/SBTS24R2/vCUCNF24R2_scf.xml
${vdu_file_path}    ${CURDIR}/config/SBTS24R2/vDUCNF24R2_scf.xml
${RMOD_name}        AEHC
${delta_du}         ${CURDIR}/config/SBTS24R2/PC_Delta_DU_scf.xml
${delta_cu}         ${CURDIR}/config/SBTS24R2/PC_Delta_CU_scf.xml
${iphy_file_path}   ${CURDIR}/config/iphy_8608.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}         1
${QFI_ID}        1
${TRF_ID}        1
${TRF_ID2}       2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/



#${gscn_value}   1
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${UE_ID}   1


*** Test Cases ***
[1]CB008541_A_B_2_SA_UEsupporting_Pcell_LBWP_Scell_SBWP_BlindAdd_for_TDD_TDD_2CC_CA
    [setup]      Testcase Setup
    ${LOG_PATH}  Set Variable     ${LOG_PATH}${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console     ${LOG_PATH}
    log to console   ue attach triggering now....
    UE Register should be Successful And Fetch RNTI   1
    Sync With Measurement Period    "vDU"
    Check Blind SCell Addition and Small BWP in SCell   16499
    Start Big DL Data Transfer And Check SCell Activation for the Blind Scell Added with 2CC
    Run Keyword and continue on failure   Verify DL Tput For 2CC
	sleep   300s
    #Sync With Measurement Period    "vDU"
    Log to Console    Verifying counters.....
	Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Run Keyword and continue on failure    Verify UL and DL ScheduledUes with counter_vDU    M55308C28001
    ...   M55308C28002     *MRBTS*

*** Keywords ***

Verify UL and DL ScheduledUes with counter_vDU
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}    ${pi_file_pattern}
    ${path}   Set Variable    /home/ute/test_results/CB008541/${TEST_NAME}/gnb_pm_counters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_1}>=1
    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_2}>=1



Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -2
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}
