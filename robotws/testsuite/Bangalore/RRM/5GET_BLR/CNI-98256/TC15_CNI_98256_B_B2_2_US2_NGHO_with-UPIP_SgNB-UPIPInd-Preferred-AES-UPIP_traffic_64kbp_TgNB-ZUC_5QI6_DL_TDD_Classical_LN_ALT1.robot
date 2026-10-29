*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R4     CONFIGURED

Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library          ta5g_commissioning
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
#Resource        ta5g_setups_and_teardowns
Resource         ./basic_resource.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_TDD_NGHO_15.json
...                 AND     sleep    120
#...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_TDD_NGHO_zuc.cfg      ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            prerana.n_s@nokia.com
...             maintainer:        prerana.n_s@nokia.com
...             INTRODUCTION:      This user scenario describes the behaviour of Nokia gNB in SA mode during NG based handover of a SA call with
...                                active UP IP and with Security Indication IE : UP Integrity Protection Indication as preferred
...             TEST SET NAME:    CNI_98256_B_B2_2_US2_NGHO_with-UPIP_SgNB-UPIPInd-Preferred-AES-UPIP_traffic_64kbp_TgNB-ZUC_5QI6_
...                               DL_TDD_Classical_LN_ALT1
...             TESTING SPLIT:    See CNI-98256 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI-98256 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20850,5G_PM_1207


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=2  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=2  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof3}    ${2}=${ip_prof2}

&{ip_ie}    ${1}=preferred      ${2}=preferred
&{max_ip_rate}    ${1}=bitrate64kbs     ${2}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=bitrate64kbs      ${2}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=not-performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_iphy.xml

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1
@{QOS_Prof1_speed_ul}       10
@{QOS_Prof1_speed_dl}       10
@{QOS_Prof1_unit}           mbps

*** Test Cases ***
[1]CNI_98256_B_B2_2_US2_NGHO_with-UPIP_SgNB-UPIPInd-Preferred-AES-UPIP_traffic_64kbp_TgNB-ZUC_5QI6_DL_TDD_Classical_LN_ALT1

    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    Increase Buffer Size for VM and IPHY

    ue location change
    Sleep   20
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}


    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    300
    ${trf_id}      Set Variable    ${1}
    Wait until the next Measurement Period starts
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
  Wait until the current Measurement Period stops
    sleep   ${60}s
    HO SA A3 UE measurements Custom    negtive=${1}
        Collect PM Counter
      ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${1}     ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${0}
  ...    ${PDU_SES_STP_SUC_UPIP_NACT_PREF}=${1}

    sleep   ${120}s

#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=10   pdu_id=1   qfi_id=1

    Check Integrity failure count

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

** Keywords **
Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true     ciphering_disabled=6:false
    ...     integrityProtection_enabled=6:true     ciphering_algorithm=nea2     integrityprotection_algorithm=nia2
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}
