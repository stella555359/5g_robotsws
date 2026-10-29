*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
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
...                 AND     Perform SCF Delta Commissioning with 8DL8UL_to_4DL4UL_conversion_TMO.json
...                 AND     sleep   10s
...                 AND     Perform SCF Delta Commissioning with DIWK41.json
...                 AND     sleep   10s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status TMO     ${wts_cfg_file}		${cell_list}
...                 AND     NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND      Stop Log     snapshot_ims2   sosreport


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_TMO_multiBwp.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}     /tmp/

${st_id_l}             ${1}
${en_id_l}             ${5}

${st_id_m}             ${6}
${en_id_m}             ${8}

${st_id_s}             ${9}
${en_id_s}             ${10}

${nwslice_ID}           ${1}
${Pdu_session_ID}       ${1}
${eNB_ID}               ${1}
${eNB_target}           ${2}
${start_cell}           1
${end_cell}             2
${TEST_NAME}            CB009422_DIWK41
${TRF_ID}               1
${QFI_ID}               1
@{cell_id}              51
@{cell_list}            1   2   3   4   7   8   10  11
${radparam}             SEPARATOR=${EMPTY}    0x890073=0;0x590072=1;0x10042=0xc0a8ff7e

@{dl_slot}              ${0}   ${1}   ${2}   ${3}   ${10}  ${11}  ${12}  ${13}
@{ul_slot}              ${4}   ${5}   ${6}   ${7}   ${8}   ${9}   ${14}  ${15}  ${16}  ${17}  ${18}  ${19}
@{K1}                   ${6}   ${12}
@{K2}                   ${4}   ${5}   ${6}

*** Test Cases ***
[1]CB009422_D#IWK41

    Run Keyword and Ignore Error        Link SCOUT SCF to Configuration ID for Reporting

    ${crnti_l}  MultiUE Register should be Successful with UE Cap   ${st_id_l}    ${en_id_l}    ue_cap=${large_bwp_sa}
    log to console     crnti_l-${crnti_l}
    ${crnti_m}  MultiUE Register should be Successful with UE Cap   ${st_id_m}    ${en_id_m}    ue_cap=${medium_bwp_sa}
    log to console     crnti_m-${crnti_m}
    ${crnti_s}  MultiUE Register should be Successful with UE Cap   ${st_id_s}    ${en_id_s}    ue_cap=${small_bwp_sa}
    log to console     crnti_s-${crnti_s}

    ${crnti_list} 	Combine Lists   ${crnti_l}    ${crnti_m}    ${crnti_s}
    log to console     crnti_list_${crnti_list}

    Start Log   btslog    ttitrace    cell_id=@{cell_id}

    ## Start Call for UEs supporting Large BWP
    MultiUE Trigger DL Traffic for SA   ${st_id_l}    ${st_id_l}+2    mbps    50
    MultiUE Trigger UL Traffic for SA   ${st_id_l}    ${st_id_l}+2    mbps    50
    MultiUE Trigger DL Traffic for SA   ${st_id_l}+3    ${en_id_l}    kbps    10
    MultiUE Trigger UL Traffic for SA   ${st_id_l}+3    ${en_id_l}    kbps    10

    ## Start Call for UEs supporting Medium BWP
    MultiUE Trigger DL Traffic for SA   ${st_id_m}    ${en_id_m}    mbps    50
    MultiUE Trigger UL Traffic for SA   ${st_id_m}    ${en_id_m}    mbps    50

    ## Start Call for UEs supporting Small BWP
    MultiUE Trigger DL Traffic for SA   ${st_id_s}    ${en_id_s}    mbps    20
    MultiUE Trigger UL Traffic for SA   ${st_id_s}    ${en_id_s}    mbps    20

    sleep   10s
    ${tti_path}     Stop Log   ttitrace    btslog   test_scenario=all_bwp

#    Induce DL BLER     ${st_id_l}-${en_id_s}  5,5,5,5,5,5,5,5,0.5,0.1,0,0,0,0,0    20
#    sleep   20s
#    ${tti_path}     Stop Log   ttitrace    btslog   test_scenario=all_bwp
#    sleep   15m

    MultiUE Deregister should be Successful     ${st_id_l}    ${en_id_s}

    Common TTI PCAP to CSV Converter    all_bwp    dir=dl
    Common TTI PCAP to CSV Converter    all_bwp    dir=ul

    Validate of DL MultiBwp  ${tti_path}[ttitrace]/output_dl_formated.csv    ${dl_slot}   ${K1}   ${80}
    Validate of UL MultiBwp  ${tti_path}[ttitrace]/output_ul_formated.csv    ${ul_slot}   ${K2}   ${80}



*** Keywords ***
Induce DL BLER
    [Arguments]     ${ue_id}  ${target_bler}    ${target_mcs}

    ${adv_bler_profile_1}    Set Variable
    ...    adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1 target_bler=${target_bler} target_mcs=${target_mcs}
    Execute Egate Command        ${adv_bler_profile_1}
    ${adv_bler_profile_activate}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} scell=0-31 testmode=adv_bler profile_id=1 action=activate
    Execute Egate Command     ${adv_bler_profile_activate}



