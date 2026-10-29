*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R4     CONFIGURED

Resource         ./basic_resource.robot
Resource         ../resources/robot/PM_Counters.robot

Suite Setup           Run keywords   Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with TC4.json
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/upd.cfg      ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Test Teardown       Log To Console       Test_Case_Tear_down

Documentation
...
...             author:            prerana.n_s@nokia.com
...             maintainer:        prerana.n_s@nokia.com
...
...             INTRODUCTION:      The User scenario  is to verify counter to measure the number of Qos Flows that failed
...                                to Setup due to user plane integrity protection (UPIP) related reasons
...             TEST SET NAME:    CNI_98256_QoS_Flow_Setup_Fail_due_to_UE_AES_gNB_ZUC_UPIP_preferred_LN_CB008116_disabled
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-98256 CFAM
...             Requirement ID:   CNI-98256-A-UPD002-534

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
# nea0 is NULL , nea1_128 is SNOW3G , nea2_128 is AES, nea3_128 is ZUC
&{ciph}         nea0=0      nea1_128=2  nea2_128=4  nea3_128=6
# nia0 is NULL , nia1_128 is SNOW3G , nia2_128 is AES, nia3_128 is ZUC
&{intgr}        nia0=0      nia1_128=0  nia2_128=0  nia3_128=6
${ip_prof}      zuc
${ip_prof1}      null
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof2}
&{ip_ie}    ${1}=preferred
&{max_ip_rate}    ${1}=bitrate64kbs
&{max_ip_rate_dl}    ${1}=bitrate64kbs
&{ip_result}      ${1}=performed
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_iphy.xml
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3

@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      64
@{QOS_Prof1_speed_dl}      64
@{QOS_Prof1_unit}          kbps


*** Test Cases ***
[1]CNI_98256_QoS_Flow_Setup_Fail_due_to_UE_AES_gNB_ZUC_UPIP_preferred_LN_CB008116_disabled
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY

    Wait until the next Measurement Period starts

    ${ue_to_bearer_list}=  MultiUE Register should be Successful upd      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}

    Wait until the current Measurement Period stops
    Collect PM Counter
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}

#${NG_FLOW_SETUP_FAIL_UPIP}             M55125C00032
#${NG_FLOW_SETUP_FAIL_UPIP_5QI1}        M55125C00033
#${NG_FLOW_SETUP_FAIL_UPIP_PMQAP}       M55163C00017

    ${Counters}    Create Dictionary    ${NG_FLOW_SETUP_FAIL_UPIP}=${0}   ${NG_FLOW_SETUP_FAIL_UPIP_5QI1}=${0}  ${NG_FLOW_SETUP_FAIL_UPIP_PMQAP}=${0}
    Verify Counters upip   ${Counters}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
