*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
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
...                 AND     sleep   1m
...                 AND     Perform SCF Delta Commissioning with Enable_only_NSA_CA_in_CASupportList.json
...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status TMO     ${wts_cfg_file}		${cell_list}
...                 AND     NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Stop Log     snapshot   sosreport

Test Teardown       Run keywords
...                 Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error   NSA Multi UE Detach should be Successful    ${st_nsa_ue}     ${en_nsa_ue}

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

${TEST_NAME}            CB013468_AB12_AB13_AB14
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x8900B0=1

*** Test Cases ***
[1]CB013468_AB12_SgNB_Modification_Request_with_identical_allowedBC_ListMRDC_and_Measurement_Gaps_change_received_CA_combination_201
    [Tags]    AB12

    ${st_nsa_ue}     Set Variable             ${181}
    ${en_nsa_ue}     Set Variable             ${184}
    ${Target_Cell_fdd}     Set Variable        ${10}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_fdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_fdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_fdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_fdd} 	Combine Lists   ${crnti_list_nsa_fdd1}    ${crnti_list_nsa_fdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_fdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     100     id=2    trf_id=1
    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps      50     id=2    trf_id=1
    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    #Trigger SgNB Modification FDD NSA UEs
    Wait until the next Measurement Period starts  additional_time=${0}
    #FDD NSA UEs
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=on
    ...    measFreq=off

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=off

    Wait until the current Measurement Period stops  additional_time=${0}
    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     ${M55112C04001}=${4}    ${M55112C04002}=${4}    ${M55112C04003}=${0}     ${M55112C04004}=${0}
    ...     ${M55112C00022}=${3}    ${M55112C00023}=${3}    ${M55112C00029}=${0}     ${M55112C00030}=${0}
    ...     ${M55112C00041}=${1}    ${M55112C00042}=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-10     ${counter}

    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8

[1]CB013468_AB13_SgNB_Modification_Request_with_identical_allowedBC_ListMRDC_and_Measurement_Gaps_change_received_CA_combination_401
    [Tags]    AB13

    ${st_nsa_ue}     Set Variable             ${101}
    ${en_nsa_ue}     Set Variable             ${104}
    ${Target_Cell_fdd}     Set Variable        ${1}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=2
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=3

    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps      50     id=2    trf_id=1
    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    #Trigger SgNB Modification TDD NSA UEs
    Wait until the next Measurement Period starts  additional_time=${0}
    #FDD NSA UEs
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=on
    ...    measFreq=off

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=off

    Wait until the current Measurement Period stops  additional_time=${0}
    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     ${M55112C04001}=${4}    ${M55112C04002}=${4}    ${M55112C04003}=${0}     ${M55112C04004}=${0}
    ...     ${M55112C00022}=${3}    ${M55112C00023}=${3}    ${M55112C00029}=${0}     ${M55112C00030}=${0}
    ...     ${M55112C00041}=${1}    ${M55112C00042}=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}

    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8


[1]CB013468_AB14_SgNB_Modification_Request_with_identical_allowedBC_ListMRDC_and_Measurement_Gaps_change_received_CA_combination_501
    [Tags]    AB15

    Perform SCF Delta Commissioning with Set_maxNumOfSCellAlloc_to_0.json
    sleep    1m

    ${st_nsa_ue}     Set Variable             ${101}
    ${en_nsa_ue}     Set Variable             ${104}
    ${Target_Cell_fdd}     Set Variable        ${1}
    #Attach NSA UE for FDD
    ${crnti_list_nsa_tdd1}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}    ${st_nsa_ue}    meas_gap_config=gp0:0   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_tdd2}     MultiUE NSA Attach should be Successful and Fetch CRNTI
    ...     ${st_nsa_ue}+1    ${en_nsa_ue}    meas_gap_config=off   Trgt_Cell=${Target_Cell_tdd}
    ...     bc_list=1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    ${crnti_list_nsa_tdd} 	Combine Lists   ${crnti_list_nsa_tdd1}    ${crnti_list_nsa_tdd2}
    log to console     crnti_list_nsa_tdd-${crnti_list_nsa_tdd}

    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=1
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=2
    MultiUE Trigger DL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps     175     id=2    trf_id=3

    MultiUE Trigger UL Traffic for NSA    ${st_nsa_ue}    ${en_nsa_ue}   mbps      50     id=2    trf_id=1
    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9

    #Trigger SgNB Modification TDD NSA UEs
    Wait until the next Measurement Period starts  additional_time=${0}
    #FDD NSA UEs
    Trigger SgNB Modification with measConfigMN release    ${st_nsa_ue}    ${st_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2

    Trigger SgNB Modification with measConfigMN Setup    ${st_nsa_ue}+1    ${st_nsa_ue}+2
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=on
    ...    measFreq=off

    Trigger SgNB Modification with measConfigMN Setup    ${en_nsa_ue}    ${en_nsa_ue}
    ...    1:1,2|2:1,2|3:1,2|4:1,2|5:1,2|6:1,2|7:1,2|8:1,2|9:1,2|10:1,2|11:1,2|12:1,2    measFreq=off

    Wait until the current Measurement Period stops  additional_time=${0}
    #Define Counter Path
    ${counterPath}   Set Variable      ${LOG_PATH}/${TEST_NAME}/PMC
    Collect PM Counter  target_dir=${counterPath}

    #Create Dictionary of counter and expected value
    ${counter}      Create Dictionary
    ...     ${M55112C04001}=${4}    ${M55112C04002}=${4}    ${M55112C04003}=${0}     ${M55112C04004}=${0}
    ...     ${M55112C00022}=${3}    ${M55112C00023}=${3}    ${M55112C00029}=${0}     ${M55112C00030}=${0}
    ...     ${M55112C00041}=${1}    ${M55112C00042}=${1}

    Validate Counters   ${counterPath}    MRBTS-1/NRBTS-1/NRCELL-1     ${counter}

    sleep   10m
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8
    MultiUE Get PDSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=9
    MultiUE Get PUSCH UE Stats for Given CC    ${st_nsa_ue}    ${en_nsa_ue}   scell_id=8











