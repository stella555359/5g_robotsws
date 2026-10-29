*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 nagesh.k_v@nokia.com
...             maintainer:             nagesh.k_v@nokia.com
...
...             INTRODUCTION:      CB013468
...             TEST SET NAME:     CB013468
...             TESTING SPLIT:     See CB013468 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB013468 CFAM

#Library          Dialogs
Resource         ./CB013468_Resource.robot

Suite Setup         Run keywords    Log To console  Suitesetup
...                 AND     Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with delta_set_D12_precondition.json
...                 AND     sleep   1m
#...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Enhanced Buffer Size for VM and IPHY
...                 AND     Load CFG and verify cell status TMO     ${wts_cfg_file}		${cell_list}
...                 AND     NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop log     cprt   btslog    test_scenario=ue_suite_tear_sgnb_modify
...                 AND     Stop Log     snapshot   sosreport

Test Teardown       Run keywords
...                 Run Keyword and Ignore Error   NSA Multi UE Detach should be Successful    ${st_nsa_ue}     ${en_nsa_ue}
...                 AND      Stop log     cprt   btslog    test_scenario=ue_test_tear_sgnb_modify
...                 AND      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_FR2.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
@{cell_list}            1
${TEST_NAME}            CB013468_DB12
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x8900B0=1;0x590089=0
${TEST_NAME_D12}            CB013468_DB12
${TEST_NAME_E12}            CB013468_EB12
${TEST_NAME_EC301}          CB013468_EC301

*** Test Cases ***
[1]CB013468D#B12_SgNB_Modification_Request_with_identical_allowedBC-ListMRDC_and_Measurement_Gaps_change_received_CA_enable
    [tags]    DB12  EC301

    ${st_nsa_ue}     Set Variable             ${11}
    ${en_nsa_ue}     Set Variable             ${12}
    ${Target_Cell_fdd}     Set Variable        ${1}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME_E12}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with delta_Activate_CDRX.json
    Perform SCF Delta Commissioning with delta_set_ScellAlloc_100.json
    sleep   5s
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=22:1,2|2:1,2|5:1,2|6:1,2|7:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${en_nsa_ue}    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=22:1,2|2:1,2|5:1,2|6:1,2|7:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     150     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     50     id=2    trf_id=1
    sleep   1m
    ${avg_data_pre}    Create List
    ${avg_dl_pre}    Create Dictionary   11=${avg_data_pre}   12=${avg_data_pre}
    ${avg_ul_pre}    Create Dictionary   11=${avg_data_pre}   12=${avg_data_pre}

    ${pre_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_pre}    pscell=8     scell=15
    log to console    pre_avg_data_dl-${pre_avg_data_dl}
    ${pre_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_pre}   pscell=8     scell=10
    log to console    pre_avg_data_ul-${pre_avg_data_ul}

    Wait until the next Measurement Period starts  additional_time=${0}

    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    22:1,2|2:1,2|5:1,2|6:1,2|7:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    22:1,2|2:1,2|5:1,2|6:1,2|7:1,2   measFreq=on

    sleep   5m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C00041=${1}    M55112C00042=${1}    M55112C04001=${2}    M55112C04002=${2}    M55112C04003=${0}    M55112C04004=${0}
    ...     M55112C00022=${1}	 M55112C00023=${1}    M55112C00029=${2}    M55112C00030=${2}    M55308C11001=${0}    M55118C02003=${2}
    ...     M55118C02012=${2}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}
    sleep   2m

    ${avg_data_post}    Create List
    ${avg_dl_post}    Create Dictionary   11=${avg_data_post}   12=${avg_data_post}
    ${avg_ul_post}    Create Dictionary   11=${avg_data_post}   12=${avg_data_post}

    ${post_avg_data_dl}    Get Avg DL Data Traffic per CC    ${avg_dl_post}     pscell=8     scell=15
    log to console    avg_data_dl-${post_avg_data_dl}
    ${post_avg_data_ul}    Get Avg UL Data Traffic per CC    ${avg_ul_post}     pscell=8     scell=10
    log to console    avg_data_ul-${post_avg_data_ul}

    Validation of Data before and After PSCell Change   ${pre_avg_data_dl}   ${post_avg_data_dl}
    Validation of Data before and After PSCell Change   ${pre_avg_data_ul}   ${post_avg_data_ul}

    #pcap validation follow the same sequence
    ${sCellIndex}   Create List  9  10  11  12  13  14  15
    ${profile_setup}    Create Dictionary
    ...     measGapConfig=1     gapPurpose=0     bandCombinationIndex=22     sCellIndex=${sCellIndex}   drx_Config=0

    ${profile_release}    Create Dictionary
    ...     measGapConfig=0     bandCombinationIndex=22     sCellIndex=${sCellIndex}    drx_Config=1

    ${measConfigVal}    Create Dictionary   11=${profile_release}   12=${profile_setup}

    log to console    ${measConfigVal}
    Validation of measConfigMN    ${measConfigVal}
    UE Detach   ${11}   ${12}
#######  Scenario EC301 ##################
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME_EC301}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with delta_DeActivate_CDRX.json
    Perform SCF Delta Commissioning with delta_set_ScellAlloc_0.json
    sleep   5s
    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=22:1,2|2:1,2|5:1,2|6:1,2|7:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${st_nsa_ue}   mbps     150     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${st_nsa_ue}   mbps     50     id=2    trf_id=1
    sleep   5s
    Wait until the next Measurement Period starts  additional_time=${0}

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}    ${st_nsa_ue}
    ...    22:1|4:1,2,3,4|5:1,2|6:1,2|7:1,2     measFreq=on     gap_pur=perFR1      isFeatureTrue=False

    sleep   7m
    Wait until the current Measurement Period stops  additional_time=${0}

    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     M55112C00041=${0}    M55112C00042=${0}    M55112C04001=${1}    M55112C04002=${0}    M55112C04003=${1}    M55112C04004=${0}
    ...     M55112C00022=${1}	 M55112C00023=${0}    M55112C00029=${0}    M55112C00030=${0}

    Run Keyword And Continue On Failure     Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}
    sleep   2s

    Validation of X2AP Modification Failure    ${st_nsa_ue}    ${st_nsa_ue}
    UE Detach   ${st_nsa_ue}   ${st_nsa_ue}
