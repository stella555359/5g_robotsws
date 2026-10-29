*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R4    CONFIGURED

Resource         ./basic_resource.robot
Resource         ../resources/robot/PM_Counters.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS23R4/basic_delta.json   ${intgr}    ${ciph}
...                 AND     Perform SCF Delta Commissioning with delta_gen.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_4CC_tdd_ref.cfg      ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      80

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Test Teardown       Run Keywords
...                 Link SCOUT SCF to Configuration ID for Reporting
...                 AND    Run Keyword if test failed     Stop Log  cprt  test_scenario=teardown
...                 AND    Log To Console       Test_Case_Tear_down

Documentation
...
...             author:            Prasanta
...             maintainer:        Prasanta.kumar_nayak@nokia.com
...
...             INTRODUCTION:     This user scenario describes the behaviour of  gNB in SA mode with multiple UEs using
...                               AES,SNOW3G,ZUC algo for UP IP for UL/DL data and UP IP plane traffic up to 64kbps.ICS is
...                               containging multiple PDU sessions

...             TEST SET NAME:    CNI_98256_A_B2_1_US1_UPIP_traffic_64kbps_UPIPInd-Preferred-AES_SNOW3_ZUC-64Kbps_5QI6_ICS_With_multiple
...                               PDU_session_multi_UE_DL_TDD_Classical_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16456,5G_CP_OTH_8630

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
# nea0 is NULL , nea1_128 is SNOW3G , nea2_128 is AES, nea3_128 is ZUC
&{ciph}         nea0=0      nea1_128=2  nea2_128=4  nea3_128=6
# nia0 is NULL , nia1_128 is SNOW3G , nia2_128 is AES, nia3_128 is ZUC
&{intgr}        nia0=0      nia1_128=2  nia2_128=4  nia3_128=6
${ip_prof}      zuc
${ip_prof1}      null
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof2}    ${2}=${ip_prof}    ${3}=${ip_prof3}   ${4}=${ip_prof3}

&{ip_ie}    ${1}=preferred    ${2}=preferred    ${3}=preferred   ${4}=preferred
&{max_ip_rate}    ${1}=bitrate64kbs    ${2}=bitrate64kbs    ${3}=bitrate64kbs  ${4}=bitrate64kbs

&{max_ip_rate_dl}    ${1}=bitrate64kbs    ${2}=bitrate64kbs    ${3}=bitrate64kbs    ${4}=bitrate64kbs

&{ip_result}      ${1}=performed   ${2}=not-performed   ${3}=performed   ${4}=performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3

#@{QOS_Prof1}               1        2          3
#@{QOS_Prof1_speed_ul}      5       32         amr_wb_18_25
#@{QOS_Prof1_speed_dl}      5       32         amr_wb_18_25
#@{QOS_Prof1_unit}          kbps    kbps        rtp_codec

@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      6
@{QOS_Prof1_speed_dl}      6
@{QOS_Prof1_unit}          mbps
@{pdu_profile}     preferred    preferred

*** Test Cases ***
[1]CNI_98256_A_B2_1_US1_UPIP_traffic_64kbps_UPIPInd-Preferred-AES_SNOW3_ZUC-64Kbps_5QI6_ICS_With_multiple_PDU_session_multi_UE_DL_TDD_Classical_LN
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}   ics_only=${1}


    Modify NIDD parameters   MRBTS-1/NRBTS-1   update   actUPIPSupportForPreferred    false

    sleep  20s
    Set To Dictionary	${ip_result}	${1}	performed
    Custom MultiUE PDU Addition should be Successful    1  1  nw_id=1   pdu_id=2

    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    sleep   60s
    Check Integrity failure count
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=2   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=2   qfi_id=1


    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${2}    ${2}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}   ics_only=${1}    negtive=${1}
     Set To Dictionary	${ip_ie}	${2}	required
     Set To Dictionary	${ip_result}	${2}	performed
     Enable 64kbps integrity dat rate    pdu_session_setup     ${ip_ie[${2}]}    required
     Custom MultiUE PDU Addition should be Successful    2  2  nw_id=1   pdu_id=2

    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${2}  ${2}  Traffic_rate=mbps     dl_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    sleep   60s
    Check Integrity failure count
    Validate DL Traffic For MultiUE for SA    ${2}    ${2}     dl_rate=1   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${2}    ${2}     dl_rate=1   pdu_id=2   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${2}    ${2}     ul_rate=1   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${2}    ${2}     ul_rate=1   pdu_id=2   qfi_id=1

    Modify NIDD parameters   MRBTS-1/NRBTS-1   update   actUPIPSupportForPreferred    true
    sleep  20s

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${3}    ${3}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}   ics_only=${1}
     Set To Dictionary	${ip_ie}	${3}	required
     Set To Dictionary	${ip_result}	${3}	performed
     Enable 64kbps integrity dat rate    pdu_session_setup     ${ip_ie[${3}]}    required
     Custom MultiUE PDU Addition should be Successful    3  3  nw_id=1   pdu_id=2

    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     ul_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${3}  ${3}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${3}  ${3}  Traffic_rate=mbps     dl_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    sleep   60s
    Check Integrity failure count

    Wait until the next Measurement Period starts
    MultiUE register Multi PDU should be Successful   4   4   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     ${pdu_profile}   pdu_id=1    nw_id=1
    Wait until the current Measurement Period stops

    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    sleep   60s
    Collect PM Counter

    ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${6}   ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${5}  ${PDU_SES_STP_ATT_UPIP_REQD}=${2}

    ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${5}   ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${4}  ${PDU_SES_STP_ATT_UPIP_REQD}=${2}

    ${Counters}    Create Dictionary  ${PDU_SES_STP_SUC_UPIP_ACT_REQ}=${2}    ${PDU_SES_STP_SUC_UPIP_NACT_PREF}=${1}
    Verify Counters upip   ${Counters}


    Validate DL Traffic For MultiUE for SA    ${1}    ${4}     dl_rate=1   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${1}    ${4}     dl_rate=1   pdu_id=2   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${1}    ${4}     ul_rate=1   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${1}    ${4}     ul_rate=1   pdu_id=2   qfi_id=1
    Check Integrity failure count
    MultiUE Deregister should be Successful      ${1}    ${4}
