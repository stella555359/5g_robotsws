*** Settings ***
Documentation
...  author:  Krzysztof Michalski, Jakub Bąk
...  contact: jakub.1.bak@nokia.com, krzysztof.michalski@nokia.com

Library     taf.rfrl.ue.ute_ue_config.UteUeConfig
Library     taf.sbts.oam.coam.admin                                           WITH NAME   coam
Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                  WITH NAME   gnbcounter
Library     taf.ue                                                            WITH NAME   taf_ue
Library     taf.sw.qualcomm.license                                           WITH NAME   license
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations         WITH NAME   gnb_cell
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/qc_ids.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.robot

*** Variables ***
${nv_nsa_5g_bands}    74213
${SCELL_CONFG_ALT_BAND_NSA}   M55316C00042
${SCELL_CONFG_ALT_BAND_SA}    M55316C00041

*** Keywords ***

FR2 NSA Test Setup
    [Arguments]    ${scf_prefix_tag}    ${dec_band_value}
    [Documentation]    Perform gNB commissioning. Prepare UE for testing and make commone preconditions.
    ...                :param scf_prefix_tag:    prefix tag of scf file in testline configuration folder.
    ...                :param dec_band_value:    decimal value of bands to change (bands range <n257,n320>)
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Set Suite Variable    $ue_pc     ${abstract_lib_config.UE_PC}
    Get pcat licence
    Repeat Keyword    2 times
    ...    Change Supported NSA n257_n320 Bands    band_dec_value=${dec_band_value}
    Log Action To Console    Perform gNB Commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=${scf_prefix_tag}
    Wait Until Keyword Succeeds    12min    15s    gnbcell.Verify All Cells Are Onair
    Log Action To Console    Common Test Setup
    Common Preconditions
    ue.Require Ue    SDX_75  capabilities=REAL_UE

FR2 NSA Test Teardown
    [Documentation]    Release pcat licence and perform common test teardown.
    Release pcat licence
    suite_specific_keywords.Common Test Teardown

Test_Setup_E2E_TL_Site_reset
    [Documentation]    Test Setup for E2E TL Site Reset. It logs source, target SW, current SW on gNB
    ...                and sets and logs QC ID for specific release for Site Reset test

    Log Action To Console    Test Setup Site Reset ===============================
    ${setup_sw_gnb}=    Get SW From BTS
    Log Action To Console    SW on gNB: ${setup_sw_gnb}
    Set to dictionary     ${GNB}    source_sw=${setup_sw_gnb}    target_sw=${setup_sw_gnb}
    Set Suite Variable    ${SOURCE_SW}    ${setup_sw_gnb}
    Set Suite Variable    ${TARGET_SW}    ${setup_sw_gnb}
    ${release}=    Get Release From SW    ${setup_sw_gnb}
    ${site_reset_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    ...                                                      release=${release}
    Set Suite Variable    ${SITE_RESET_TEST_QC_ID}    ${site_reset_test_qc_id}
    Log Action To Console    QC ID: ${SITE_RESET_TEST_QC_ID}
    Log Action To Console    Common Test Setup
    Common Preconditions
    Log Action To Console    Test Procedure ======================================

Test_Setup_E2E_TL_SW_upgrade_rollback
    [Documentation]    Test Setup for E2E TL SW Upgrade Rollback. It logs source, target SW, current SW on gNB
    ...                and sets and logs QC ID for specific release for SW Rollback Upgrade test

    Log Action To Console    Test Setup SW Upgrade Rollback ======================
    ${setup_source_software}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${setup_target_software}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${GNB}    source_sw=${setup_source_software}    target_sw=${setup_target_software}
    Set Suite Variable    ${SOURCE_SW}          ${setup_source_software}
    Set Suite Variable    ${TARGET_SW}          ${setup_target_software}
    Log Softwares For Test
    ${release}=    Get Release From SW    ${TARGET_SW}
    ${sw_upgrade_rollback_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    ...                                                              release=${release}
    Set Suite Variable    ${SW_UPGRADE_ROLLBACK_TEST_QC_ID}    ${sw_upgrade_rollback_test_qc_id}
    Log Action To Console    QC ID: ${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    Log Action To Console    Common Test Setup
    Common Preconditions
    Log Action To Console    Test Procedure ======================================

Log Softwares For Test
    [Documentation]    Gets SW versions from gNB via Rest API and logs it to console as well as source and target SW
    ...                from Suite Variables

    ${sw_gnb}=    Get SW From BTS
    Log Action To Console    SW on gNB: ${sw_gnb}
    Log Action To Console    Source SW: ${SOURCE_SW}
    Log Action To Console    Target SW: ${TARGET_SW}

Test Teardown
    [Documentation]    Performs Common Postconditions
    Log Action To Console    End Test Procedure ==================================
    Log Action to Console    Perform Common Postconditions
    Common Postconditions

Change NIDD Parameter Value
    [Arguments]    ${value}  ${parameter}
    [Documentation]     Keywords to change value of parameter
    ...    :param value: value of NIDD parameter.
    ...    :param parameter: parameter to change value of.
    Log Action to Console    Set ${parameter} value to ${value} on primary gNB
    gnbscf.Perform Configuration Parameter Recommissioning   operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=${parameter}    value=${value}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}
    Wait until all cells are onair

Check If actMfbiNrCaSupportFr2 Change To NSA Not Impact Already Attached UE
    [Documentation]   Wrapper KW for Check If Parameter Change Not Impact Already Attached UE
    ...               KW check if actMfbiNrCaSupportFr2 value change from none to nsa impact already attached UE
    Check If Parameter Change Not Impact Already Attached UE    parameter=actMfbiNrCaSupportFr2
    ...                                                         value=NSA
    ...                                                         tput_dl_min=480 Mbits/sec
    ...                                                         tput_ul_min=80 Mbits/sec
    ...                                                         tput_dl_max=800 Mbits/sec
    ...                                                         tput_ul_max=350 Mbits/sec

Check If actMfbiNrCaSupportFr2 Change To none Not Impact Already Attached UE
    [Documentation]   Wrapper KW for Check If Parameter Change Not Impact Already Attached UE
    ...               KW check if actMfbiNrCaSupportFr2 value change from NSA to none impact already attached UE
    Check If Parameter Change Not Impact Already Attached UE    parameter=actMfbiNrCaSupportFr2
    ...                                                         value=none
    ...                                                         tput_dl_min=3300 Mbits/sec
    ...                                                         tput_ul_min=300 Mbits/sec
    ...                                                         tput_dl_max=6500 Mbits/sec
    ...                                                         tput_ul_max=850 Mbits/sec

Check If Parameter Change Not Impact Already Attached UE
     [Arguments]  ${parameter}  ${value}   ${tput_dl_min}  ${tput_ul_min}  ${tput_dl_max}  ${tput_ul_max}
     [Documentation]     Keywords to check if change value of parameter not impact already attached UE
     ...    :param parameter: parameter to change value of.
     ...    :param value: value of NIDD parameter.
     ...    :param tput_ul_min:    level of minimum required throughput in uplink direction
     ...    :param tput_dl_min:    level of minimum required throughput in downlink direction
     ...    :param tput_ul_max:    level of maximum required throughput in uplink direction
     ...    :param tput_dl_max:    level of maximum required throughput in downlink direction
     Log Action To Console   Check If ${parameter} change to ${value} not impact already attached UE
     Attach UE
     Log Action To Console    Verify throughput before ${parameter} change
     Verify TCP UL and DL Data Transmission    tput_dl_min=${tput_dl_min}
     ...                                       tput_ul_min=${tput_ul_min}
     ...                                       tput_dl_max=${tput_dl_max}
     ...                                       tput_ul_max=${tput_ul_max}
     Change NIDD Parameter Value    parameter=${parameter}    value=${value}
     Sleep    30s
     Log Action To Console    Verify throughput after ${parameter} change
     Verify TCP UL and DL Data Transmission    tput_dl_min=${tput_dl_min}
     ...                                       tput_ul_min=${tput_ul_min}
     ...                                       tput_dl_max=${tput_dl_max}
     ...                                       tput_ul_max=${tput_ul_max}
     Detach UE

Change Supported NSA n257_n320 Bands
    [Arguments]   ${band_dec_value}
    [Documentation]     Change NSA bands in range n257_n320 by PCAT. KW require active PCAT license.
    ...    :param band_dec_value:  Decimal value of band i.e 7 = 0b111 make bands n257, n258 and n259 active
    Open Connection And Log In   host=${ue_pc.host}   username=${ue_pc.user}    password=${ue_pc.password}
    ${band list}=    get_bands_names    band=${band_dec_value}    treshold=257
    Log Action To Console    Change band on UE_PC to ${band_list}.
    ${pcat_command_head}=    Set Variable    PCAT -PLUGIN NB -DEVICE ${ue_pc.device} -MODE WRITE -NVITEM ${nv_nsa_5g_bands}
    ${pcat_command_tail}=    Set Variable   -JSON True -VALUE "{bits_257_320: ${band_dec_value}}"
    SSHLibrary.Execute Command     ${pcat_command_head} ${pcat_command_tail}
    Log Action To Console    Reboot UE to save nvitem change
    SSHLibrary.Write    adb -s ${ue_pc.device} reboot
    Log Action To Console    Wait for UE reboot
    Sleep    45s
    [Teardown]    Run Keywords             Log Action To Console    Close ssh conection
    ...           AND                      SSHLibrary.Close All Connections

Wait For Next PM measurements period
    [Arguments]   ${interval}=5min    ${delay}=60
    [Documentation]  Wait for the next counter cycle, indicated by the interval
    ...              :param interval:    Interval of the counter
    ...              :param delay:    delay for checking PM counters after specified period
    Log Action To Console   Wait For Next PM measurements period
    gnbcounter.Wait For Next Pm Period    ${interval}    ${delay}


Check SCELL_CONFG_ALT_BAND_NSA counters incremented
    [Documentation]    Check if SCELL_CONFG_ALT_BAND_NSA counters are pegged for all scells.
    Log Action To Console    Check if SCELL_CONFG_ALT_BAND_NSA counters are pegged
    ${counters}=    gnbcounter.Get Counter    ${SCELL_CONFG_ALT_BAND_NSA}
    ${result}=      check_scells_counters   counters=${counters}  counter_name=${SCELL_CONFG_ALT_BAND_NSA}
    Run Keyword If    ${result} == False
    ...    Fail    SCELL_CONFG_ALT_BAND_NSA is not incremented

Check SCELL_CONFG_ALT_BAND_SA counters not incremented
    [Documentation]    Check if SCELL_CONFG_ALT_BAND_SA counters are not pegged for all scells.
    Log Action To Console    Check if SCELL_CONFG_ALT_BAND_SA counters are not pegged
    ${counters}=    gnbcounter.Get Counter    ${SCELL_CONFG_ALT_BAND_SA}
    ${result}=      check_scells_counters   counters=${counters}  counter_name=${SCELL_CONFG_ALT_BAND_SA}
    Run Keyword If    ${result} == False
    ...    Fail    SCELL_CONFG_ALT_BAND_NSA is incremented

Get pcat licence
    [Documentation]    Get pcat licence for futher use on ue_pc.
    Log Action To Console    Get pcat licence
    ${launcher}=  Create Dictionary
            ...  host=${ue_pc.host}
            ...  path=${ue_pc.lk_path}
            ...  user=${ue_pc.user}
            ...  password=${ue_pc.password}
    license.setup    launcher=${launcher}
    license.login    username=${ue_pc.lk_user}  password=${ue_pc.lk_password}
    license.get_licence_pcat_5g

Release pcat licence
    [Documentation]    Release pcat licence.
    Log Action To Console    Release pcat licence
    license.release_licence_pcat_5g
    license.logout
    license.teardown

Lock Cell
    [Arguments]     ${bts_id}=0    ${cell_id}=11  ${du_id}=${0}
    [Documentation]    Lock eNB cell
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param cell_id:   cell id.
    ...     :param du_id:     DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:   (optional) Timeout for the operation.
    Log Action to Console    Lock Cell-${cell_id}
    gnbcell.lock_cell    bts_id=${bts_id}    cell_id=${cell_id}    du_id=${du_id}

Unlock Cell
    [Arguments]     ${bts_id}=0    ${cell_id}=11  ${du_id}=${0}
    [Documentation]    Unlock eNB cell
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param cell_id:   cell id.
    ...     :param du_id:     DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    ...     :param timeout:   (optional) Timeout for the operation.
    Log Action to Console    Unlock Cell-${cell_id}
    gnbcell.unlock_cell    bts_id=${bts_id}    cell_id=${cell_id}    du_id=${du_id}

Verify cell is on Air
    [Arguments]     ${bts_id}=0    ${cell_id}=11  ${du_id}=${0}
    [Documentation]    Verify cell is on Air
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param cell_id:   cell id.
    ...     :param du_id:     DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    Log Action to Console    Verify cell-${cell_id} is on Air
    gnbcell.verify_cell_is_onair    bts_id=${bts_id}    cell_id=${cell_id}    du_id=${du_id}

Change actMfbiNrCaSupportFr2 to None and unlock Cell
    [Documentation]         This KW changed actMfbiNrCaSupportFr2 flag to None and then unlocks Cell2 on the MeNB
    Log Action To Console   Change actMfbiNrCaSupportFr2 to None and unlock Cell
    Attach UE
    Change NIDD Parameter Value    parameter=actMfbiNrCaSupportFr2    value=none
    Unlock Cell
    Sleep   60s
    Verify cell is on Air
    Sleep   30s

Check CA with MFBI without detach
    [Arguments]    ${pcell_id}    ${scell_ids}    ${scell_freqBands}    ${pcell_freqBand}
    [Documentation]    This keyword tests MFBI (Multi Frequency Band Indicator) without detaching the UE
    ...                      :param pcell_id:           Id of PScell used on the gNB
    ...                      :param scell_ids:          Ids of the Scells used/not used on the gNB during CA
    ...                      :param scell_freqBands:    Bands of the Scells used/not used on the gNB during CA
    ...                      :param pcell_freqBand:     Band of the PScell used/not used on the gNB during CA
    Log Action to Console    Checking if MFBI CA feature works
    Change actMfbiNrCaSupportFr2 to None and unlock Cell
    ${date}=  dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_filename}=  Set variable   MFBI_${date}.pcap
    Start tcpdump on gNB    pcap_filename=${pcap_filename}
    Sleep  30s
    Create Directory  ${LOG_PATH}
    Stop tcpdump on gNB    pcap_filename=${pcap_filename}
    Log Action To Console  Verify Pcell Addition
    Verify Cell Addition
    ...    pcap_filename=${LOG_PATH}/${pcap_filename}
    ...    expected_cell_id=${pcell_id}
    ...    expected_cell_band=${pcell_freqBand}
    ...    cell_type=pcell
    Log Action To Console  Verify Scell Addition
    Verify Cell Addition
    ...    pcap_filename=${LOG_PATH}/${pcap_filename}
    ...    expected_cell_id=${scell_ids}
    ...    expected_cell_band=${scell_freqBands}
    ...    cell_type=scell
    Verify TCP UL and DL Data Transmission
    ...    tput_dl_min=480 Mbits/sec
    ...    tput_dl_max=900 Mbits/sec
    ...    tput_ul_min=80 Mbits/sec
    ...    tput_ul_max=180 Mbits/sec
    Detach UE
