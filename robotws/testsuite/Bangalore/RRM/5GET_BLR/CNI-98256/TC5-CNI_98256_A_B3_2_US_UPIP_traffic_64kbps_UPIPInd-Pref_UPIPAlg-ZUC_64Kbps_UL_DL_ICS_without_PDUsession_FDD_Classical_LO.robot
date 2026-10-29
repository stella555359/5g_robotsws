*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R4    CONFIGURED

Resource         ./basic_resource.robot
Resource         ../resources/robot/PM_Counters.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=TC5.xml
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_fdd_ref.cfg      ${ue_profile}
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
...             maintainer:        prasanta_kumar_nayak@nokia.com
...
...             INTRODUCTION:     This user scenario describes the behaviour of Nokia gNB in SA mode for the successful setup and operation
...                               of integrity protection(ZUC is configured in UE SEcurity Capability) for user plane traffic up to 64kbps.
...             TEST SET NAME:    CNI_98256_A_B3_2_US_UPIP_traffic_64kbps_UPIPInd-Pref_UPIPAlg-ZUC_64Kbps_UL_DL_ICS_without_PDUsession_
...                               FDD_Classical_LO
...             TESTING SPLIT:    CNI-98256 Split-A
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-98256 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20799,5G_RAN_OP_2820,5G_PM_1207

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${WTS_DIR}          /opt/iphy/latest
${IPHY_FILE}         ${CURDIR}/config/wts/iphy_fdd.xml
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
&{ue_profile}    ${1}=${ip_prof}

&{ip_ie}    ${1}=preferred
&{max_ip_rate}    ${1}=bitrate64kbs

&{max_ip_rate_dl}    ${1}=bitrate64kbs

&{ip_result}      ${1}=performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}               1
@{QOS_Prof1_speed_ul}      64
@{QOS_Prof1_speed_dl}      64
@{QOS_Prof1_unit}          kbps


*** Test Cases ***
[1]CNI_98256_A_B3_2_US_UPIP_traffic_64kbps_UPIPInd-Pref_UPIPAlg-ZUC_64Kbps_UL_DL_ICS_without_PDUsession_FDD_Classical_LO
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

    Wait until the next Measurement Period starts
    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...  	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1   only_ul=${1}   ics_only=${1}


    Set To Dictionary	${ip_ie}	${1}	not-needed
    Set To Dictionary	${ip_result}	${1}	not-performed

    Disable integrity Prot   pdu_session_setup
    Custom MultiUE PDU Addition should be Successful    1  1  nw_id=1   pdu_id=2

    Set To Dictionary	${ip_ie}	${1}	preferred
    Set To Dictionary	${ip_result}	${1}	performed
    Run Keyword If  '${max_ip_rate[${1}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    pdu_session_setup
    ...      ${ip_ie[${1}]}    required
    Custom MultiUE PDU Addition should be Successful    1  1  nw_id=1   pdu_id=3

    Set To Dictionary	${ip_ie}	${1}	required
    Set To Dictionary	${ip_result}	${1}	performed
    Run Keyword If  '${max_ip_rate[${1}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    pdu_session_setup
    ...      ${ip_ie[${1}]}    required
    Custom MultiUE PDU Addition should be Successful    1  1  nw_id=1   pdu_id=4
    Wait until the current Measurement Period stops

    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=3   trf_id=1   qfi_id=1
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=4   trf_id=1   qfi_id=1

    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=2   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=3   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=4   trf_id=1   qfi_id=1
    sleep   30s
    Start Log    biptaf
    sleep  2s
    ${scen1}     Stop Log     biptaf     test_scenario=call_bip
    sleep   120s
        Collect PM Counter
      ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${2}   ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${2}  ${PDU_SES_STP_ATT_UPIP_REQD}=${1}
  ...    ${PDU_SES_STP_SUC_UPIP_ACT_REQ}=${1}
  Verify Counters upip   ${Counters}

    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=1   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=2   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=3   qfi_id=1
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=1   pdu_id=4   qfi_id=1

    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=2   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=3   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=1   pdu_id=4   qfi_id=1
   Check Integrity failure count

   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
