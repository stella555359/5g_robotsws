*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 samik.sarkar@nokia.com
...             maintainer:             samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB013468
...             TEST SET NAME:     CB013468
...             TESTING SPLIT:     See CB013468 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB013468 CFAM

Resource         ./CB013468_Resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_to_create_NSA_CA_NRREL.json
...                 AND     sleep   10s
...                 AND     Perform SCF Delta Commissioning with Delta_CB013468_BIWK31.json
...                 AND     sleep   10s
#...                 AND     Perform SCF Delta Commissioning with Disable_extra_pdsch.json
#...                 AND     sleep   10s
...                 AND     Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
...                 AND     sleep   10s
...                 AND     Perform SCF Delta Commissioning with Enable_actMultiReqSgNBMod.json
...                 AND     sleep   10s
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Enhanced Buffer Size for VM and IPHY
...                 AND     Load CFG and verify cell status TMO     ${wts_cfg_file}		${cell_list}
...                 AND     NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    wts_sim_keywords.Clean edaemon and egate

Test Teardown       Run keywords
...                 Run Keyword and Ignore Error   NSA Multi UE Detach should be Successful    ${st_nsa_ue}     ${en_nsa_ue}
...                 AND      Stop log     cprt   btslog    test_scenario=ue_test_tear_sgnb_modify
...                 AND      Stop Log     snapshot_ims2   sosreport
...                 AND      Run Keyword and Ignore Error   Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
@{cell_list}            1   2   3   4   7   8   10  11

${TEST_NAME}            CB013468_AB21
#${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x8900B0=1;0x590089=0
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x590089=0;0x10042=0xc0a8ff7e

*** Test Cases ***
[1]CB013468_AB11_SgNB_Modification_Request_with_identical_allowedBC_ListMRDC_and_Measurement_Gaps_change_received_CA_Disabled
    [Tags]    AB11
    [Documentation]
    ...    SgNB receives X2AP: SgNB Modification Request for the UE without NR CA, with measConfigMN-> measGapConfig
    ...    indicating Measurement Gaps change, without SgNBSecurityKey IE, with different allowedBC-ListMRDC IE than
    ...    already received in X2AP: SgNB Addition Request or previous X2AP: SgNB Modification Request. SgNB performs
    ...    intra-cell PSCell Change,during which applies measurement gaps change and responds with X2AP:SgNB Modification
    ...    Request Acknowledge to MeNB.Measurement gaps are requested to be setup,UE is already configured with DRX
    ...    so DRX is released
    ...    Test Case Requirement:5G_RAN_USR_RRM_31088, 5G_RAN_USR_RRM_31109

    Perform SCF Delta Commissioning with Enable_actcdrx.json
    sleep   30s

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable       ${10}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${st_nsa_ue}+2    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_fdd3}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue}    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}    ${crnti_list_nsa_fdd3}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     30     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    #Trigger SgNB Modification FDD NSA UEs
    Wait until the next Measurement Period starts  additional_time=${0}
    #FDD NSA UEs
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=on
    ...    measFreq=off

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=off
    sleep   6m
    Wait until the current Measurement Period stops  additional_time=${0}
    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${0}    M55114C00028=${0}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${0}     M55118C03000=${0}
    ...     M55308C11001=${0}    M55308C11002=${0}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    sleep   2m

    #Comparison of Tput PRE and POST SgNB Modification
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Validation of measConfigMN
    ${physCellId}   Create List    60

    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=1     physCellId=${physCellId}   drx_Config=1
    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=1     physCellId=${physCellId}   drx_Config=0

    ${measConfigVal}    Create Dictionary   181=${profile_release}   182=${profile_setup}   183=${profile_setup}    184=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    Perform SCF Delta Commissioning with Disable_actcdrx.json
    sleep   30s

[1]CB013468_AB21_SgNB_Modification_Request_with_different_allowedBC_ListMRDC_and_Measurement_Gaps_change_received
    [tags]    AB21
    [documentation]
    ...    This user scenario verifies the behavior of the SgNB when it receives an X2AP: SgNB Modification Request
    ...    containing a different allowedBC-ListMRDC IE and a measConfigMN->measGapConfig requesting measurement gap
    ...    release for a UE in EN-DC mode with NR CA initially configured and measurement gaps active.The SgNB selects
    ...    a different {Band Combination, Feature Set Entry Index} pair and replaces the existing SCell with a new one
    ...    during an intra-cell PSCell change, releasing the measurement gaps.After the change,the SgNB detects
    ...    inactivity, initiates DRX setup due to NRBTS/NRCELL/actCDrx=TRUE, and configures DRX for the UE.
    ...    The SgNB responds with an X2AP: SgNB Modification Request Acknowledge for the initial request and later sends
     ...   an X2AP:SgNB Modification Required for DRX setup.
    ...    Test Case Requirement:5G_RAN_USR_RRM_31030, 5G_RAN_USR_RRM_31109

    #Perform Delta changes to Enable actAllowedBcListMrdcPrioBcSel
    Perform SCF Delta Commissioning with Enable_actAllowedBcListMrdcPrioBcSel.json
    sleep    30s
    Perform SCF Delta Commissioning with Enable_actcdrx.json
    sleep    30s

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable       ${10}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|11:1,2|8:1,2|7:1,2|6:1,2|5:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     30     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    5:1,2|1:1,2|2:1,2|7:1,2|6:1,2|11:1,2|8:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    5:1,2|1:1,2|2:1,2|6:1,2|7:1,2|8:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    5:1,2|1:1,2|2:1,2|6:1,2|7:1,2|8:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${4}     M55118C03000=${4}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    sleep   2m

    #Comparison of Tput PRE and POST SgNB Modification
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Validation of measConfigMN
    ${physCellId1}   Create List    60   51
    ${physCellId2}   Create List    60   54
    ${profile_setup_182}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId2}
    ${profile_release_181}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=5     physCellId=${physCellId1}
    ${profile_setup_183}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId1}
    ${profile_setup_184}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId2}
    ${measConfigVal}    Create Dictionary   181=${profile_release_181}   182=${profile_setup_182}   183=${profile_setup_183}
    ...    184=${profile_setup_184}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    Perform SCF Delta Commissioning with Disable_actcdrx.json
    sleep    30s
    #Perform Delta changes to Disable actAllowedBcListMrdcPrioBcSel
    Perform SCF Delta Commissioning with Disable_actAllowedBcListMrdcPrioBcSel.json

[1]CB013468_AB31_UE_in_EN_DC_mode_without_NR_CA_SgNB_Modification_Request_with_different_allowedBC_ListMRDC_and_Measurement_Gaps_change_received
    [tags]    AB31
    [Documentation]
    ...    SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap change,
    ...    without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE without NR CA.
    ...    The same {Band Combination, Feature Set Entry Index} pair is chosen but it can't select SCell (NR CA is not possible).
    ...    SgNB performs intra-cell PSCell Change, during which applies measurement gaps change.
    ...    SgNB responds with X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...    Test Case Requirement: 5G_RAN_USR_RRM_31086

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    1m
    #Perform Delta changes to set  maxNumOfSCellAlloc=2 on NRCELL-2
    Perform SCF Delta Commissioning with Set_maxNumOfSCellAlloc_to_2_0_cell-1_4.json
    sleep    30s
    #Perform Delta changes to Enable actAllowedBcListMrdcPrioBcSel
    Perform SCF Delta Commissioning with Enable_actAllowedBcListMrdcPrioBcSel.json
    sleep    30s

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable       ${10}

    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|11:1,2|8:1,2|7:1,2|6:1,2|1:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     101    102    meas_gap_config=gp0:0   Trgt_Cell=1   bc_list=3:1,2|4:1,2|9:1,2|10:1,2|11:1,2
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     30     id=2    trf_id=1

    MultiUE Trigger DL Traffic for NSA    101    102   mbps     5     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    101    102   mbps     5     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|11:1,2|8:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    5:1,2|1:1,2|2:1,2|6:1,2|7:1,2|8:1,2|11:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    5:1,2|1:1,2|2:1,2|6:1,2|7:1,2|8:1,2|11:1,2   measFreq=on
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${0}    M55114C00035=${4}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    sleep   2m

    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Deregister UE-101 and UE-102
    NSA Multi UE Detach should be Successful    101     102

    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5

    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=5
    ${measConfigVal}    Create Dictionary   181=${profile_release}   182=${profile_setup}   183=${profile_setup}   184=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    #Perform Delta changes to Disable actAllowedBcListMrdcPrioBcSel
    Perform SCF Delta Commissioning with Disable_actAllowedBcListMrdcPrioBcSel.json
    sleep    30s
    #Perform Delta changes to revert maxNumOfSCellAlloc=250 on NRCELL-1, 2 and 4
    Perform SCF Delta Commissioning with Revert_maxNumOfSCellAlloc_to_250.json

[1]CB013468_AB41_UE_in_EN_DC_mode_without_NR_CA_SgNB_Mod_Req_with_different_allowedBC_ListMRDC_and_Meas_Gaps_change_received_A1_SCell_addition_method
    [tags]    AB41
    [Documentation]
    ...     SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap
    ...     change,without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE
    ...     without NR CA. New selected BC allows to activate A1 measurement for SCell Addition. SgNB performs intra-cell
    ...     PSCell Change, during which configures A1 measurement and applies measurement gaps change. SgNB responds with
    ...     X2AP: SgNB Modification Request Acknowledge to MeNB
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31038

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${131}
    ${en_nsa_ue}     Set Variable             ${134}
    ${Target_Cell_tdd}     Set Variable       ${3}

    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=9:1,2|4:1,2|3:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=9:1,2|4:1,2|3:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=2
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=3
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=4
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=5
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=6
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=7
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=8
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=9
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=10
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   131=${avg_data_pre}   132=${avg_data_pre}   133=${avg_data_pre}   134=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   131=${avg_data_pre}   132=${avg_data_pre}   133=${avg_data_pre}   134=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    9:1,2|11:1,2|3:1,2|10:1,2|4:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    9:1,2|11:1,2|3:1,2|10:1,2|4:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    9:1,2|11:1,2|3:1,2|10:1,2|4:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath1}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath1}

    #Trigger Coverage Based A1 Measurement for SCell Addition
    Wait until the next Measurement Period starts  additional_time=${0}
    sleep   1m
    A1 based SCell Addtion    ${st_nsa_ue}    ${en_nsa_ue}
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath2}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/A1_Based_SCell_Add
    Collect PM Counter  target_dir=${counterPath2}

    sleep   5m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   131=${avg_data_post}   132=${avg_data_post}   133=${avg_data_post}   134=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   131=${avg_data_post}   132=${avg_data_post}   133=${avg_data_post}   134=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value after SgNB Modification
    ${counter_sgnb_mod}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${0}    M55114C00028=${0}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${0}

    Validate Counters   ${counterPath1}    MRBTS-1/NRBTS-1/NRCELL-3     ${counter_sgnb_mod}

    #Create Dictionary of counter and expected value after A1 measurement
    ${counter_A1_meas}      Create Dictionary
    ...     M55112C04001=${0}    M55112C04002=${0}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${0}    M55112C00023=${0}    M55112C00029=${0}     M55112C00030=${0}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${0}    M55112C00042=${0}    M55118C02000=${4}

    Validate Counters   ${counterPath2}    MRBTS-1/NRBTS-1/NRCELL-3     ${counter_A1_meas}

    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=3
    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=3
    ${measConfigVal}    Create Dictionary   131=${profile_release}   132=${profile_setup}   133=${profile_setup}   134=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    #Validate SCell Addition after A1 measurement trigger
    ${physCellId}   Create List    53   61
    ${scell_add}    Create Dictionary     bandCombinationIndex=11     sCellIndex=9     physCellId=61
    ${scell_add_Val}    Create Dictionary   131=${scell_add}   132=${scell_add}   133=${scell_add}   134=${scell_add}
    log to console    ${scell_add_Val}
    Validation of SCell Addition due to A1    ${scell_add_Val}

[1]CB013468_AB81_SgNB_Mod_Req_with_diff_allowedBC_ListMRDC_and_Meas_Gaps_change_rec_SgNB_selects_BC_FSEI_pair_is_not_in_use_BuffBaseSCellAdd_disable
    [tags]    AB81
    [Documentation]
    ...   SgNB receives X2AP:SgNB Modification Request with measConfigMN->measGapConfig indicating measurement gap change,
    ...   without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE with NR CA.
    ...   SgNB selects different {Band Combination, Feature Set Entry Index} and different SCell. SgNB performs intra-cell
    ...   PSCell Change, during which applies measurement gaps change, replaces SCell with newly selected SCell according
    ...   to the SCell addition method configured.  SgNB responds with X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...   Test Case Requirement: 5G_RAN_USR_RRM_31077

    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   30s
    Perform SCF Delta Commissioning with Enable_actcdrx.json
    sleep   30s

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable        ${10}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2    isDefCap=False

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2   isDefCap=False

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50    id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     30    id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}

    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    6:1,2|1:1,2|2:1,2|7:1,2|11:1,2|8:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    6:1,2|1:1,2|2:1,2|7:1,2|11:1,2|8:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    6:1,2|1:1,2|2:1,2|7:1,2|11:1,2|8:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}

    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    ${physCellId}   Create List    60   54

    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0    bandCombinationIndex=6
    ...     sCellIndex=9     physCellId=${physCellId}   drx_Config=0

    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=6     sCellIndex=9
    ...     physCellId=${physCellId}   drx_Config=1

    ${measConfigVal}    Create Dictionary   181=${profile_release}   182=${profile_setup}   183=${profile_setup}   184=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    Perform SCF Delta Commissioning with Disable_actcdrx.json
    sleep   30s
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json

[1]CB013468_AB101_SgNB_Mod_Req_with_diff_allowedBC-ListMRDC_and_Meas_Gaps_change_received_with_CB013468AB2
    [tags]    AB101
    [Documentation]
    ...     SgNB receives X2AP:SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap change,
    ...     without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE. SgNB decides
    ...     to add/replace SCell. SgNB performs intra-cell PSCell Change, during which SCell addition/replacement fails and
    ...     measurement gaps change is successful.  SgNB responds with X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31097

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable        ${10}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     30     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   10s
    Perform SCF Delta Commissioning with Set_maxNumOfSCellAlloc_to_0_0_0_cell-2_4_1.json
    sleep   20s
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    4:1,2|5:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    4:1,2|5:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    4:1,2|5:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${0}    M55114C00035=${4}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    sleep   5m
    Perform SCF Delta Commissioning with Revert_maxNumOfSCellAlloc_to_250.json

    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5
    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=5

    ${measConfigVal}    Create Dictionary   181=${profile_release}   182=${profile_setup}   183=${profile_setup}   184=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

[1]CB013468_AEC12_SgNB_Mod_Req_with_allowedBC-ListMRDC_and_Meas_Gaps_to_be_setup_received_SgNB_fails_to_allocate_Meas_Gaps_CA_List_set_to_401
    [tags]    AEC12
    [Documentation]
    ...    SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap to
    ...    be setup, without SgNBSecurityKey IE and with allowedBC-ListMRDC IE the same or different than already stored
    ...    for the UE is without NR CA.SgNB triggers intra-cell PSCell Change, during  with calculates measurement gaps
    ...    and finds that configured CSI-RS and measurement gaps are all overlapped and SgNB cannot resolve this overlapping.
    ...    SgNB responds with X2AP: SgNB Modification Request Rejects to MeNB. SgNB sends X2AP: SgNB Release Required
    ...    Test Case Requirement: 5G_RAN_USR_RRM_31096

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    1m
    Perform SCF Delta Commissioning with Set_csiMeasGapOverlap_to_overlapChecked.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${101}
    ${en_nsa_ue}     Set Variable             ${104}
    ${Target_Cell_fdd}     Set Variable       ${1}
    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=3:1,2|4:1,2|9:1,2|10:1,2|11:1,2
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     10    id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     5     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}    ${en_nsa_ue}
    ...    3:1,2|4:1,2|9:1,2|10:1,2|11:1,2   measGap=gp4:9   measFreq=on    isCsiOverride=True

    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}
    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

#   Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${0}    M55112C04003=${4}     M55112C04004=${0}
    ...     M55112C00022=${4}    M55112C00023=${0}    M55112C00029=${0}     M55112C00030=${0}
    ...     M55113C00003=${4}    M55112C00041=${0}    M55112C00042=${0}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}
    Validation of X2AP Modification Failure    ${st_nsa_ue}    ${en_nsa_ue}
    Validation of F1AP Context Modification Failure    ${st_nsa_ue}    ${en_nsa_ue}
    Perform SCF Delta Commissioning with Revert_csiMeasGapOverlap_to_overlapNotCheckedNsa.json

[1]CB013468_AEC21_SgNB_Mod_Req_with_allowedBC-ListMRDC_and_Meas_Gaps_to_be_setup_received_SgNB_fails_to_allocate_Meas_Gaps_CA_List_set_to_201
    [tags]    AEC21
    [Documentation]
    ...    A#EC2
    ...    SgNB receives X2AP:SgNB Modification Request with different allowedBC-ListMRDC IE than already stored for the
    ...    UE.The measurement gap reconfiguration (setup or release) is also requested. Due to NRBTS/actMultiReqSgNBMod
    ...    set to FALSE, MeNB request is rejected by SgNB via X2AP: SgNB Modification Request Reject.
    ...    Test Case Requirement: 5G_RAN_USR_RRM_31176
    ...    A#EC3
    ...    UE is in EN-DC mode. No Measurement Gaps coordination with MeNB was performed so far-
    ...    measConfigMN was not received from MeNB during SgNB Addition procedure nor in SgNB
    ...    Modification procedure, or Measurement Gaps coordination with MeNB was performed to
    ...    release MG. (measConfigMN is not stored internally by SgNB) SgNB receives X2AP: SgNB Modification Request
    ...    with invalid measConfigMN (measGapConfig not present, gapPurpose present, measuredFrequenciesMN optionally
    ...    present or measGapConfig indicating measurement gaps release present, gapPurpose optionally present,
    ...    measuredFrquenciesMN present or measGapConfig IE indicating measurement gaps setup present, gapPurpose not
    ...    present, measuredFrquenciesMN optionally present), without SgNBSecurityKey IE and with allowedBC-ListMRDC IE.
    ...    SgNB responds with X2AP: SgNB Modification Request Rejects to MeNB.
    ...    Test Case Requirement: 12439896
    ...    A#EC4
    ...    UE is in EN-DC mode without CA. Measurement Gaps setup coordination has been done befor-measConfigMN was
    ...    received from MeNB during SgNB Addition procedure or SgNB Modification procedure.
    ...    (measConfigMN is stored internally by SgNB).SgNB receives X2AP: SgNB Modification Request without
    ...    SgNBSecurityKey IE, with different allowedBC-ListMRDC IE than already stored and with measConfigMN with
    ...    measGapConfig indicating MG release and with gapPurpose. SgNB responds with X2AP: SgNB Modification
    ...    Request Rejects to MeNB.
    ...    Test Case Requirement: 12484779

    #Disable actMultiReqSgNBMod
    Perform SCF Delta Commissioning with Disable_actMultiReqSgNBMod.json
    sleep   30s

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue1}    Set Variable             ${184}
    ${st_nsa_ue2}    Set Variable             ${185}
    ${en_nsa_ue}     Set Variable             ${188}
    ${Target_Cell_fdd}     Set Variable        ${10}

    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue1}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue1}   mbps     4     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue1}   mbps     3     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue1}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue1}   scell_id=9

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m

    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    4:1,2|5:1,2    isFeatureTrue=False

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    4:1,2|5:1,2   measFreq=on      isFeatureTrue=False

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue1}    ${en_nsa_ue1}
    ...    4:1,2|5:1,2   measFreq=on      isFeatureTrue=False
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    ##Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}
    ##Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${0}    M55112C04003=${4}     M55112C04004=${0}
    ...     M55112C00022=${0}    M55112C00023=${0}    M55112C00029=${0}     M55112C00030=${0}
    ...     M55112C00041=${0}    M55112C00042=${0}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    Validation of X2AP Modification Failure    ${st_nsa_ue}    ${en_nsa_ue1}

    ##CB013468 UPD EC-3 and EC-4 are added
    ##Enable actMultiReqSgNBMod
    Perform SCF Delta Commissioning with Enable_actMultiReqSgNBMod.json
    sleep   10s
    ##Enable CA Support list for NSA
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   10s

    ${crnti_list_nsa_fdd3}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue2}    ${st_nsa_ue2}+1    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd4}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue2}+2    ${st_nsa_ue2}+2    meas_gap_config=forced_release   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=5:1,2|4:1,2

    ${crnti_list_nsa_fdd5}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue}    ${en_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     gapTrig=enb_and_gnb_triggered     bc_list=5:1,2|4:1,2

    ${crnti_nsa_fdd_upd} 	Combine Lists   ${crnti_list_nsa_fdd3}    ${crnti_list_nsa_fdd4}    ${crnti_list_nsa_fdd5}
    log to console     crnti_list_nsa_tdd-${crnti_nsa_fdd_upd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue}   mbps     4     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue2}    ${en_nsa_ue}   mbps     3     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue2}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue2}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue2}    ${en_nsa_ue}   scell_id=8

    Wait until the next Measurement Period starts  additional_time=${0}

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue2}    ${st_nsa_ue2}
    ...    5:1,2|4:1,2   measGap=no_gap_config   measFreq=on    isCsiOverride=True

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue2}+1    ${st_nsa_ue2}+1
    ...    5:1,2|4:1,2   gap_pur=none   measFreq=off    isCsiOverride=True

    Trigger SgNB Modification with measConfigMN release     ${st_nsa_ue2}+2    ${st_nsa_ue2}+2
    ...    5:1,2|4:1,2    isCsiOverride=True

    Trigger SgNB Modification with measConfigMN release    ${en_nsa_ue}    ${en_nsa_ue}
    ...    4:1,2|5:1,2   gap_pur=perUE   measFreq=off    isCsiOverride=True
    sleep   6m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}
    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${0}    M55112C04003=${4}     M55112C04004=${0}
    ...     M55112C00022=${0}    M55112C00023=${0}    M55112C00029=${0}     M55112C00030=${0}
    ...     M55112C00041=${0}    M55112C00042=${0}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}
    Validation of X2AP Modification Failure    ${st_nsa_ue2}    ${en_nsa_ue}    isUpd=True

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    10s

[1]CB013468_BIWK31_SgNB_Mod_Req_with_different_allowedBC_ListMRDC_and_Meas_Gaps_release_received_CB013468_AB8
    [tags]    BIWK31
    [Documentation]
    ...     This user scenario verifies the behavior of the SgNB when it receives an X2AP: SgNB Modification Request
    ...     containing a different allowedBC-ListMRDC IE and a measConfigMN->measGapConfig requesting measurement gap
    ...     release for a UE in EN-DC mode without NR CA initially, while the UE is running inter-frequency measurements
    ...     A3/A5 with measurement gaps coordinated between MeNB and SgNB. The SgNB selects the same {Band Combination,
    ...     Feature Set Entry Index} pair already in use, adds an SCell using the blind method, and releases the
    ...     measurement gaps during an intra-cell PSCell change. After the change, the SgNB initiates an
    ...     X2AP: SgNB Modification Required procedure to request the MeNB to re-establish measurement gaps for
    ...     supporting ongoing A3/A5 inter-frequency measurements
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31182

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    10s
    Perform SCF Delta Commissioning with cell_3_change_sCellAdd_to_blind.json
    sleep    10s

    ${st_nsa_ue}     Set Variable             ${131}
    ${en_nsa_ue}     Set Variable             ${132}
    ${Target_Cell_tdd}     Set Variable       ${3}

    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${en_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=2
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=3
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175    id=2    trf_id=4
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1

#    Display UE Meas Config and Trigger A2    ${st_nsa_ue}    ${en_nsa_ue}

    sleep   2m
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   131=${avg_data_pre}   132=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   131=${avg_data_pre}   132=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${en_nsa_ue}
    ...    1:1,2|2:1,2|11:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|3:1,2|10:1,2|12:1,2
    ...    gap_trig=enb_and_gnb_triggered
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath}

    sleep   2m
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   131=${avg_data_post}   132=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   131=${avg_data_post}   132=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C04001=${2}    M55112C04002=${2}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${0}    M55112C00023=${0}    M55112C00029=${2}     M55112C00030=${2}
    ...     M55114C00021=${2}    M55114C00028=${2}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${2}    M55112C00042=${2}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-3     ${counter}
    sleep   2m

    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=11
    ${measConfigVal}    Create Dictionary   131=${profile_release}   132=${profile_release}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

    Perform SCF Delta Commissioning with cell_3_change_sCellAdd_to_covBasedA1.json
    sleep    10s

[1]CB013468_AB91_SgNB_Mod_Req_with_the_Same_allowedBC_ListMRDC_and_diff_CapInfo_IE_and_Meas_Gaps_change_received_BufferBasedSCellAdd_disable
    [tags]    AB91
    [Documentation]
    ...     SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap
    ...     change, without SgNBSecurityKey IE and with the same allowedBC-ListMRDC IE as already stored for the UE with
    ...     NR CA and with different CapabilityInfo IE as already stored for the UE. SgNB selects different
    ...     {Band Combination}, Feature Set Entry Index and different SCell. SgNB performs intra-cell PSCell Change,
    ...     during which applies measurement gaps change, replaces SCell with newly selected SCell according to the
    ...     SCell addition method configured. SgNB responds with X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31091

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${105}
    ${en_nsa_ue}     Set Variable             ${108}
    ${Target_Cell_tdd}     Set Variable       ${1}

    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=3:1,2|11:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=3:1,2|11:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     100    id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   105=${avg_data_pre}   106=${avg_data_pre}   107=${avg_data_pre}   108=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   105=${avg_data_pre}   106=${avg_data_pre}   107=${avg_data_pre}   108=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    sleep   30s
    Trigger UE Capability IE Modification     ${st_nsa_ue}	    ${en_nsa_ue}	#${ue_nr_cap}		${ue_eu_nr_cap}

    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    3:1,2|11:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    3:1,2|11:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    3:1,2|11:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath1}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath1}

    sleep   5m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   105=${avg_data_post}   106=${avg_data_post}   107=${avg_data_post}   108=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   105=${avg_data_post}   106=${avg_data_post}   107=${avg_data_post}   108=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value after SgNB Modification
    ${counter_sgnb_mod}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${4}     M55118C02000=${4}

    Validate Counters   ${counterPath1}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter_sgnb_mod}

    ${physCellId}   Create List    51   61
    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=11     physCellId=${physCellId}
    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=11     physCellId=${physCellId}
    ${measConfigVal}    Create Dictionary   105=${profile_release}   106=${profile_setup}   107=${profile_setup}   108=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}
    Trigger UE Capability IE Modification     ${st_nsa_ue}	 ${en_nsa_ue}    inc_ue_cap=False

[1]CB013468_AB51_SgNB_Mod_Req_with_different_allowedBC_ListMRDC_and_Meas_Gaps_change_received_SgNB_selects_BC,FSEI_pair_that_is_not_in_use
    [tags]    AB51
    [Documentation]
    ...    SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap
    ...    change,without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE
    ...    without NR CA.New selected BC allows to start buffer monitoring for SCell Addition. SgNB performs intra-cell
    ...    PSCell Change, during which applies measurement gaps change and starts buffer monitoring. SgNB responds with
    ...    X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...    Test Case Requirement: 5G_RAN_USR_RRM_31040

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep    30s
    Perform SCF Delta Commissioning with Enable_actBufferBasedSCellAddition.json
    sleep    30s

    ${st_nsa_ue}     Set Variable             ${101}
    ${en_nsa_ue}     Set Variable             ${104}
    ${Target_Cell_tdd}     Set Variable       ${1}

    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=9:1,2|4:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=9:1,2|4:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175   id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175   id=2    trf_id=2
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50    id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   101=${avg_data_pre}   102=${avg_data_pre}   103=${avg_data_pre}   104=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   101=${avg_data_pre}   102=${avg_data_pre}   103=${avg_data_pre}   104=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2    isbuf=True

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2   measFreq=on    isbuf=True

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2   measFreq=off    isbuf=True
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath1}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath1}

    sleep   5m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   101=${avg_data_post}   102=${avg_data_post}   103=${avg_data_post}   104=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   101=${avg_data_post}   102=${avg_data_post}   103=${avg_data_post}   104=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value after SgNB Modification
    ${counter_sgnb_mod}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${4}     M55118C03000=${4}

    Validate Counters   ${counterPath1}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter_sgnb_mod}

    ${physCellId}   Create List    52
    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=3     sCellIndex=9     physCellId=${physCellId}
    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=3     sCellIndex=9     physCellId=${physCellId}

    ${measConfigVal}    Create Dictionary   101=${profile_release}   102=${profile_setup}   103=${profile_setup}   104=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}  isBuffBasedScellAdd=1
    Perform SCF Delta Commissioning with Disable_actBufferBasedSCellAddition.json
    sleep    30s

[1]CB013468_AB61_SgNB_Mod_Req_with_different_allowedBC_ListMRDC_and_Meas_Gaps_change_received_SgNB_selects_BC_FSEI_pair_already_in_use
    [tags]    AB61
    [Documentation]
    ...     SgNB receives X2AP:SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap
    ...     change,without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE
    ...     with NR CA.The same {Band Combination, Feature Set Entry Index} pair is chosen but it can't select SCell
    ...     (NR CA is not possible).SgNB performs intra-cell PSCell Change, during which applies measurement gaps change
    ...     and releases SCell.SgNB responds with X2AP: SgNB Modification Request Acknowledge to MeNB.
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31073

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${101}
    ${en_nsa_ue}     Set Variable             ${104}
    ${Target_Cell_tdd}     Set Variable       ${1}

    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=3:1,2|4:1,2|9:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=3:1,2|4:1,2|9:1,2|10:1,2|11:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175   id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175   id=2    trf_id=2
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175   id=2    trf_id=3
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50    id=2    trf_id=1

    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   101=${avg_data_pre}   102=${avg_data_pre}   103=${avg_data_pre}   104=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   101=${avg_data_pre}   102=${avg_data_pre}   103=${avg_data_pre}   104=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}
    Perform SCF Delta Commissioning with Disable_only_NSA_CA_in_CASupportList.json
    sleep   1m
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    3:1,2|11:1,2|9:1,2|10:1,2|4:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath1}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath1}

    sleep   5m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   101=${avg_data_post}   102=${avg_data_post}   103=${avg_data_post}   104=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   101=${avg_data_post}   102=${avg_data_post}   103=${avg_data_post}   104=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value after SgNB Modification
    ${counter_sgnb_mod}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${0}    M55114C00028=${0}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${0}     M55118C03000=${0}

    Validate Counters   ${counterPath1}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter_sgnb_mod}

    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=3
    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=3

    ${measConfigVal}    Create Dictionary   101=${profile_release}   102=${profile_setup}   103=${profile_setup}   104=${profile_setup}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}

[1]CB013468_AB71_SgNB_Mod_Req_with_diff_allowedBC_ListMRDC_and_Meas_Gaps_change_rec_SgNB_selects_BC_FSEI_pair_is_in_use_BufferBasedSCellAdd_disable
    [tags]    AB71
    [Documentation]
    ...     SgNB receives X2AP: SgNB Modification Request with measConfigMN-> measGapConfig indicating measurement gap
    ...     change, without SgNBSecurityKey IE and with different allowedBC-ListMRDC IE than already stored for the UE
    ...     with NR CA. SgNB selects different {Band Combination, Feature Set Entry Index} and the same SCell. SgNB
    ...     performs intra-cell PSCell Change, during which applies measurement gaps change.  SgNB responds with X2AP:
    ...     SgNB Modification Request Acknowledge to MeNB.
    ...     Test Case Requirement: 5G_RAN_USR_RRM_31038

    #Disbale ALL NSA CA Parameters from carrierAggregationSupportList parameter
    Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_tdd}     Set Variable       ${10}

    #Attach NSA UE for TDD
    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=5:1,2|2:1,2|1:1,2|6:1,2|7:1,2|8:1,2|11:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     100    id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    sleep   1m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   181=${avg_data_pre}   182=${avg_data_pre}   183=${avg_data_pre}   184=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=9
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}

    sleep   30s
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    5:1,2|2:1,2|1:1,2|6:1,2|8:1,2|7:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    5:1,2|2:1,2|1:1,2|6:1,2|8:1,2|7:1,2   measFreq=on

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    5:1,2|2:1,2|1:1,2|6:1,2|8:1,2|7:1,2   measFreq=off
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath1}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/SGNB_Mod
    Collect PM Counter  target_dir=${counterPath1}

    #Trigger Coverage Based A1 Measurement for SCell Addition
    Wait until the next Measurement Period starts  additional_time=${0}
    sleep   1m
    A1 based SCell Addtion    ${st_nsa_ue}    ${en_nsa_ue}
    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath2}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC/A1_Based_SCell_Add
    Collect PM Counter  target_dir=${counterPath2}

    sleep   5m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   181=${avg_data_post}   182=${avg_data_post}   183=${avg_data_post}   184=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}    pscell=8     scell=9
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #Create Dictionary of counter and expected value after SgNB Modification
    ${counter_sgnb_mod}      Create Dictionary
    ...     M55112C04001=${4}    M55112C04002=${4}    M55112C04003=${0}     M55112C04004=${0}
    ...     M55112C00022=${3}    M55112C00023=${3}    M55112C00029=${4}     M55112C00030=${4}
    ...     M55114C00021=${4}    M55114C00028=${4}    M55114C00035=${0}     M55114C00038=${0}
    ...     M55112C00041=${1}    M55112C00042=${1}    M55118C02000=${4}

    Validate Counters   ${counterPath1}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter_sgnb_mod}

    # Validating if the same Scell is chosen after Sgnb modification request
    ${physCellId1}   Create List    60   51
    ${physCellId2}   Create List    60   54
    ${profile_setup_182}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId2}
    ${profile_release_181}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=5     physCellId=${physCellId1}
    ${profile_setup_183}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId1}
    ${profile_setup_184}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=5     physCellId=${physCellId2}
    ${measConfigVal}    Create Dictionary   181=${profile_release_181}   182=${profile_setup_182}   183=${profile_setup_183}
    ...    184=${profile_setup_184}
    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}
