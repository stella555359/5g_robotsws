*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB009422
...             TEST SET NAME:     CB009422
...             TESTING SPLIT:     See CB009422 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB009422 CFAM


Resource         ./CB009422_resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     sleep   60s
...                 AND     Perform SCF Delta Commissioning with AEQE_AB5_A31_new_TMO.json
...                 AND     sleep   60s
...                 AND     Perform SCF Delta Commissioning with Convert_confiig_to_SSB4.json
...                 AND     sleep   60s
...                 AND     Perform SCF Delta Commissioning with ACSI_config.json
...                 AND     sleep   60s
...                 AND     Perform SCF Delta Commissioning with 8370_Preconditions.json
...                 AND     sleep   180s
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status with CPRT    ${wts_cfg_file}	 ${start_cell}	 ${end_cell}
...                 AND     start log    btslog
#0x58085C=true for rdUseDAfterUForPdcchSharingTdd

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log    btslog
...                 AND     Stop Log     snapshot   sosreport


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_TMO.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${st_sa_id}             ${3}
${en_sa_id}             ${4}

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
${end_cell}             2
${TEST_NAME}            CB009422_AB5
${TRF_ID}               2
@{cell_id}              51
${target_bler1}         100,90,80,70,60,50,40,20,10,8,5,0.5,0,0,0
${target_bler2}         100,90,80,70,60,50,40,20,10,8,5,0.5,0,0,0
${target_bler3}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0
${target_bler4}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0

${target_bler5}         100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0
${target_bler6}         100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0
${target_bler7}         100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0

@{target_bler_d}        ${target_bler1}  ${target_bler2}    ${target_bler3}  ${target_bler4}
@{target_mcs_d}         8   4   2   1
@{report_cqi_d}         8   7   6   4

@{target_bler_i}        ${target_bler5}  ${target_bler6}    ${target_bler7}
@{target_mcs_i}         7   14   22
@{report_cqi_i}         7   11   14

${BIP_CSV_NAME}           BIP_L1L2.pcap_filter_SCN1.csv
${BIP_CSV_NAME_PG}        BIP_L1L2.pcap_filter_PG.csv
${BIP_CSV_NAME_TP}        BIP_L1L2.pcap_filter_TP.csv
${FILTER_B003}            dldata_pdcchsendreql1sw
@{COLUMN_NAME}    3gpp.sfn   3gpp.slot   3gpp.rnti   DlData_DciInfoL1sw.startSymbolNumber    DlData_DciInfoL1sw.startCce
...               DlData_DciInfoL1sw.aggregationLevel    DlData_DciInfoL1sw.dciSize    DlData_DciInfoL1sw.numOfSymbols

${IPHY_FILE}=      ${CURDIR}/config/SCF/iphy_TMO.xml

${radparam}             SEPARATOR=${EMPTY}    0x58085C=1

*** Test Cases ***
[1]CB009422_D_IWK61_Interaction_of_TD_LTE_Cfg0_compatible_frame_structure_with_PDSCH_sharing_with_PDCCH

    [Tags]     DIWK6

    NSA X2AP Link Should be UP     ${eNB_ID}		${eNB_target}

    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1      update      actAdaptiveReTxResMcs     true
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-1      update      actPdcchSharingWithPdsch     true

    ${crnti_list}   MultiUE Register should be Successful    ${1}   ${2}    pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}

    MultiUE Trigger DL Traffic for SA        ${1}    ${2}    mbps    175   pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1
    MultiUE Trigger UL Traffic for SA         ${1}    ${2}    mbps   125    pdu_id=${Pdu_session_ID}
    ...     trf_id=1    qfi_id=1

    ${tobad}     TM_Profile_creation_for_varying_channel_condition   ${target_bler_d}    ${target_mcs_d}
    ...    ${report_cqi_d}
    ${togood}    TM_Profile_creation_for_varying_channel_condition   ${target_bler_i}    ${target_mcs_i}
    ...    ${report_cqi_i}    profile_id=${tobad}
    sleep   60s

    sleep   1s
    TM Profile activation for varying channel condition    ${st_sa_id}-${en_sa_id}    ${target_mcs_d}
    ...     pausetime=3s
    TM Profile activation for varying channel condition    ${st_sa_id}-${en_sa_id}    ${target_mcs_i}
    ...     profile_id=${tobad}    pausetime=3s
    sleep   1s

    TM Profile deactivation for varying channel condition   ${st_sa_id}-${en_sa_id}    ${togood}

    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    sleep   180s
    Collect PM Counter  target_dir=${counterPath}
    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55308C03001=${0}    M55308C03005=${0}    M55335C02016=${0}     M55335C02020=${0}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
TM Profile creation for varying channel condition
    [Arguments]  ${target_bler}    ${target_mcs}    ${report_cqi}    ${profile_id}=0
    log to console       TM Profile creation started for varying channel condition
    ${len1}  Get length  ${target_mcs}
    ${len2}  Get length  ${target_bler}
    ${len3}  Get length  ${report_cqi}
    should be equal     ${len1}    ${len2}
    should be equal     ${len1}    ${len3}
    log to console    before-${profile_id}
    FOR    ${idx}   IN RANGE    ${len1}
    ${profile_id}    Evaluate    ${profile_id}+1
    ${a}    Set Variable     ${target_bler}[${idx}]
    ${b}    Set Variable     ${target_mcs}[${idx}]
    ${c}    Set Variable     ${report_cqi}[${idx}]
    ${adv_bler_profile_1}    Set Variable
    ...    adv_bler_testmode_nr profile_id=${profile_id} target_bler_profile_id=1 target_bler=${a} target_mcs=${b}
    ${csi_profile_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=${profile_id} cqi_mode=fixed cqi=${c}
    ute_wtssim.Execute Egate Command        ${adv_bler_profile_1}
    ute_wtssim.Execute Egate Command        ${csi_profile_1}
    sleep   1s
    log to console    created_profile-${profile_id}
    END
    log to console       TM Profile creation finished for varying channel condition
    [return]    ${profile_id}


TM Profile activation for varying channel condition
    [Arguments]    ${ue_id}    ${target_mcs}    ${profile_id}=0    ${pausetime}=10s
    [Documentation]    for Multiple UE provide UE ids with comma sepearted e.g 1,2,3

    Log to console    TM Profile activation started for varying channel condition
    ${len1}  Get length  ${target_mcs}
    FOR    ${idx}   IN RANGE    ${profile_id}+1     ${profile_id}+${len1}+1
    ${adv_bler_profile_activate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=adv_bler profile_id=${idx} action=activate
    ${csi_profile_activate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=csi_override profile_id=${idx} action=activate
    ute_wtssim.Execute Egate Command        ${adv_bler_profile_activate}
    ute_wtssim.Execute Egate Command        ${csi_profile_activate}
    sleep    ${pausetime}
    log to console    profile_id-${idx} activated
    END
    Log to console    TM Profile activation finished for varying channel condition

TM Profile deactivation for varying channel condition
    [Arguments]    ${ue_id}     ${profile_id}
    [Documentation]    for Multiple UE provide UE ids with comma sepearted e.g 1,2,3
    ...     for ${profile_id} need to provide last profile id used in TM Profile deactivation for varying channel condition
    log to console      TM Profile deactivation Started for varying channel condition
    ${adv_bler_profile_deactivate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=adv_bler profile_id=${profile_id} action=deactivate
    ${csi_profile_deactivate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=csi_override profile_id=${profile_id} action=deactivate
    ute_wtssim.Execute Egate Command        ${adv_bler_profile_deactivate}
    sleep   20ms
    ute_wtssim.Execute Egate Command        ${csi_profile_deactivate}
    sleep   20ms
    log to console      TM Profile deactivation Finished for varying channel condition

Validate Counters
    [Arguments]     ${pm_files_location}    ${moc}    ${expected_val}
    [Documentation]    Validation of Below Counters will be done
     ...    M55308C03001: PDSCH_OFDM_SYMBOLS
     ...    M55308C03005: PDSCH_OFDM_SYMBOLS_TIME
     ...    M55335C02016: PDCCH_SYMB_DIF_BWP1_PWS_BWP
     ...    M55335C02020: NUM_2_PDCCH_SYMB_SHARE_PDSCH

    ${pi_list}    Get Dictionary Keys    ${expected_val}
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
    log to console    validation-of-${counter}-is-started
    ${actual_pm_values}    Get PM counter value   pm_files_location=${pm_files_location}/gnb_pm_counters  moc=${moc}    pi_id=${counter}
    ${actual_pm_values}   convert to integer    ${actual_pm_values}
    Should Be True     ${actual_pm_values} > ${expected_val}[${counter}]
    log to console     validation-of-${counter}-is-completed
    END
    log to console    all-counters-validation-successful
