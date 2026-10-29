*** Settings ***
#Force Tags      CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS
#...   PY27
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     vDUCNF_0.300     CONFIGURED
Documentation
...     author:         Shekhar.Vijay_Barewar@nokia.com
...     maintainer:     Shekhar Barewar
...     INTRODUCTION:   CB007120 AIC conformance cases
...     Feature:        CB008608/8379-F


Resource            ./CB008608_resource.robot


Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
...                     AND                 Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                     AND                 Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND    BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND    Verify RMODs Online Status   ${800}
...                     AND    Clear WTS     ${WTS_DIR}
...                     AND    Add WTS Ipaddr At VM
...                     AND    log to console   loading cfg.................
...                     AND    Start WTS Using WTS_Runner     ${wts_cfg_file}



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_max_gfbr_30_tdd_um_mode_updated_with_vonr.cfg
${delta_vdu}        ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vDU.xml
${delta_cu}         ${CURDIR}/config/SBTS24R1/Delta_configuration_scf_vCU.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}    1
${gw_ID}         1
${QFI_ID}        1
${TRF_ID}        1
${TRF_ID2}       2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${VDU_SCF_PATH}     ${CURDIR}/config/working_8379_vdu.xml
${VCU SCF PATH}     ${CURDIR}/config/working_8379_vcu.xml
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id}      ${1}
${en_ue_id}      ${1}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
@{QOS_Prof1}                1            6
@{QOS_Prof1_speed_ul}       2            30
@{QOS_Prof1_speed_dl}       2            30
@{QOS_Prof1_unit}           mbps         mbps


*** Test Cases ***
[1]CB008379-F_B2_PDCP_discard_GBR_DRB_using_18_bit_PDCP_SN
    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    # Increase VM and IPHY buffer size
    set test variable      ${LOG_PATH}
    #Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    # Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}
    Sync With Measurement Period      "vDU_vCU"
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...     ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}   ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    60
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    Set fixed cqi bler for single UE custom    ${st_ue_id}    ul  # Deteriorate the Radio Condition by Inroducing the BLER
    Set fixed cqi bler for single UE custom    ${st_ue_id}    dl  # Deteriorate the Radio Condition by Inroducing the BLER
    sleep   ${300}s
    Log to console     Collecting vCU and vDU PM Counters..
    Run keyword and Ignore Error   Collect pm counter kubectls      "vCU"
    Run keyword and Ignore Error   Get discard pdcp counters and validate vCU    M55320C20004     *gNB5G*

*** Keywords ***
Set fixed cqi bler for single UE custom
    [Arguments]  ${ue_id}    ${dirct}
    # For DL BLER
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=40    target_mcs=3
    ...    num_dl_pkts=10000
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
    ...     action=activate    profile_id=40

    # Fr UL SINR
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ul_sinr_testmode_nr    profile_id=3    sinr_target_srs=-500    sinr_target_pusch=-500
    ...    sinr_target_pucch=-500    sinr_target_preamble=-500
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=ul_sinr    action=activate    profile_id=3
