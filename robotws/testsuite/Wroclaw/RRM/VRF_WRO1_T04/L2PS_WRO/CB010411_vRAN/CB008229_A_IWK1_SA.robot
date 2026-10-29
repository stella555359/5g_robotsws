*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC     	VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD     CONFIGURED
...           RAN_5G_FDD    RAN_5G    SBTS00    SBTS24R1

Resource     resources/8608_keywords.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../CB008697/CB008697_variables.robot
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../resources/Python/webem_alarms.py
Library      resources/commissioning_vran.py
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ta5g_ue_mobility
Library     ../CB008697/CB008697_keywords.py
Library      resources/counters_vdu.py
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Enable Cloud
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${CURDIR}/config/1_AZQJ_1_AHFIB_1_AHCA.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Call Ap Console Reboot
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${CURDIR}/config/default/du_25mhz_1cell.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${CURDIR}/config/default/cu_25mhz_1cell.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...            AND             Check Radios Availability Aic
...                               timeout=400
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            check_edaemon_port=${True}
...                            lua_cfg=${CURDIR}/config/basic_config.cfg


Suite Teardown    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${GNB_SA_DU_ADM_SUCC_BWP1} =    M55139C02501
${GNB_SA_DU_ADM_SUCC_BWP2} =    M55139C02502

*** Test Cases ***
CB008229-A_IWK1_UE1_served_with_large_BWP_and_UE2_served_with_small_BWP_profiles_in_cell_simultaneously_CB007552_active_SA
    Enable PDSCH decoding in the multiplexed slots
    Set Internal Traffic Type To UE    ue=51    pdu=1
    Set Internal Traffic Type To UE    ue=71    pdu=2
    Attach Ue With Large BWP
    Attach Ue With Small BWP
    Start 100MB DL and 70MB UL Data Traffic For Both UEs
    Verify If PM Counters For Small and Large BWP Updated
    Verify Tput For UEs
#    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Enable PDSCH decoding in the multiplexed slots
    Execute Egate Command    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH

Set Internal Traffic Type To UE
    [Arguments]   ${ue}=1    ${pdu}=1
    Execute Egate Command   cmd=set_pdu_param ue=${ue} pdu=${pdu} trf_type=internal

Verify Tput For UEs
    Verify Average Tput For UE SA     ue_id=51    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=65    accuracy=86
    Verify Average Tput For UE SA     ue_id=51    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=50    accuracy=86
    Verify Average Tput For UE SA     ue_id=71    pdu=2    qfi=1    dir=dl    unit=M    expected_tput=65    accuracy=86
    Verify Average Tput For UE SA     ue_id=71    pdu=2    qfi=1    dir=ul    unit=M    expected_tput=50    accuracy=86

Verify Average Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}    ${accuracy}=99
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}*0.${accuracy}

Attach Ue With Large BWP
    Attach Ue    ue_id=51
    Establish Pdu Session    ue_id=51    pdu_id=1    gw_id=1

Attach Ue With Small BWP
    Attach Ue    ue_id=71
    Establish Pdu Session    ue_id=71    pdu_id=2    gw_id=2

Start 100MB DL and 70MB UL Data Traffic For Both UEs
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=51 pdu=1 dir=dl mbps=100
#    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=51 pdu=1 dir=ul mbps=70
#    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=71 pdu=2 dir=dl mbps=100
#    ...    pass_regexp=UE2: Started Downlink Internal traffic Receiver on Ue:2 Pdu:2 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=71 pdu=2 dir=ul mbps=70
#    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1

Verify If PM Counters For Small and Large BWP Updated
	Wait For Next Full Pm Interval Aic
    Collect_coam_vdu_pm_counters
    Find Counter In Dir
    ...  counter_id=${GNB_SA_DU_ADM_SUCC_BWP1}
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    Find Counter In Dir
    ...  counter_id=${GNB_SA_DU_ADM_SUCC_BWP2}
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

