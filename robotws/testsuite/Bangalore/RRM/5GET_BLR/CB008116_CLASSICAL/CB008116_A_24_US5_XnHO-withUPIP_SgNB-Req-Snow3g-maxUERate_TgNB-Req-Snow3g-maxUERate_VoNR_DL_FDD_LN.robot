*** Settings ***
Force Tags      CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R2     CONFIGURED

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
...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G.json
...                 AND     sleep    120
...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_XnLinkDel.json
...                 AND     sleep    90
...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_xnlink.json
...                 AND     sleep    120
...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_NRAdjGNB.json
...                 AND     sleep    90
...                 AND     Perform SCF Delta Commissioning with basic_delta_snow3G.json
...                 AND     sleep    90

#...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS23R2/basic_delta.json   ${intgr}    ${ciph}
#...                 AND     sleep     60
#...                 AND     Perform SCF Delta Commissioning with delta_gen.json
#...                 AND     sleep     60

...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...           AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_FDD_XnHO_VoNR_Snow3G.cfg
...                             ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            vuyyuri.satyanarayana_raju@nokia.com
...             maintainer:        vuyyuri.satyanarayana_raju@nokia.com
...             INTRODUCTION:      This test case describes the behaviour of Nokia gNB in SA mode
...                                during Xn based handover of a SA call with active UP IP in
...                                downlink direction with UPIP Indication as Required with snow3G algorithm.
...    TEST NAME:    CB008116_A_24_US5_XnHO-withUPIP_SgNB-Req-Snow3g-maxUERate_TgNB-Req-Snow3g-maxUERate_VoNR_DL_FDD_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:  5G_RAN_USR_RRM_16602

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=6  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=6  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof1}    ${2}=${ip_prof1}

&{ip_ie}    ${1}=required      ${2}=required
&{max_ip_rate}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof2}                1
@{QOS_Prof2_speed_ul}       2
@{QOS_Prof2_speed_dl}       2
@{QOS_Prof2_unit}           mbps

@{QOS_Prof1}               1        2          3
@{QOS_Prof1_speed_ul}      2       32         amr_wb_18_25
@{QOS_Prof1_speed_dl}      2       32         amr_wb_18_25
@{QOS_Prof1_unit}          mbps    kbps        rtp_codec

*** Test Cases ***
[1][1.0] CB008116_A_24_US5_XnHO-withUPIP_SgNB-Req-Snow3g-maxUERate_TgNB-Req-Snow3g-maxUERate_VoNR_DL_FDD_LN

    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    Increase Buffer Size for VM and IPHY
    X2AP Link Should be UP
#    Establish Xn Link To UPIP gNB3
    ue location change
    Sleep   20
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}


    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}
    ... 	pdu_session_setup   ${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}   ue_to_bearer_list=${ue_to_bearer_list[1]}  ho=${1}
    ${duration}      Set Variable    500
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}
    ...     ${qos_profile_unit}     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${60}s

    Establish Xn Link To UPIP gNB3

    Enable Max integrity dat rate       path_switch    ${ip_ie[${st_ue_id}]}    ${ip_ie[${st_ue_id}]}

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    HO SA A3 UE measurements
    sleep   ${120}s
    Stop CPRT capture  ${CaptureCPRT}

    Verify Bearer_context_setup_req_ho     ${CaptureCPRT.path}      ${st_ue_id}

    Check Integrity failure count

    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=0.0185   pdu_id=2   qfi_id=3
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=0.0185   pdu_id=2   qfi_id=3

    [Teardown]    Run Keywords    MultiUE Deregister should be Successful     ${st_ue_id}    ${en_ue_id}
    ...           AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true
    ...    ciphering_disabled=6:false,5:false,1:false
    ...     integrityProtection_enabled=6:true,5:true,1:true     ciphering_algorithm=nea1
    ...     integrityprotection_algorithm=nia1
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}

Create Modify PDU session
    [Arguments]     ${st_ue_id}     ${en_ue_id}    ${qos_profile}   ${pdu_id}     ${gfbr_mfbr_profile}=-1
         ...        ${num_ues}=${en_ue_id}          ${ue_to_bearer_list}=${bearer_list}   ${ho}=${-1}
    [Documentation]    This keyword is wrepar for the ADD PDU  session and modification
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${QOS_prof}=      Set Variable  ${qos_profile}[${ue_id}][1:]
        ${len}=     Get Length  ${QOS_prof}
        ${QOS_strng}=    Run Keyword If  ${len} >0   Evaluate    ",".join(${QOS_prof})  #Got the QOS string
        ${pdu_id}=   Set Variable If      '2' in ${QOS_prof} or '3' in ${QOS_prof} or '4' in ${QOS_prof}   2   1

        ${gw_id}=       Evaluate    ${ue_id}+${num_ues}
        ${capture_cprt}     Capture CPRT Set Upon Config
        Set test variable    ${CaptureCPRT}    ${capture_cprt}
        Run Keyword if  ${len} >0       Set CPRT capture    ${CaptureCPRT}


        Run Keyword if  ${len} >0   Add PDU session     ${ue_id}      ${pdu_id}      ${gw_id}     ${QOS_strng}
        ...    ue_to_bearer_list=${ue_to_bearer_list}    ho=${ho}

        Run Keyword if  ${len} >0     Stop CPRT capture  ${CaptureCPRT}

        Run Keyword if  ${len} >0     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap
        ...     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap
        Run Keyword if  ${pdu_id}==2 and ${ho} == ${-1}  Verify PDU Session Request
        ...     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_id}_PDU.pcap   ${ue_id}
    END
    Log to Console     ${gfbr_mfbr_profile}

Start Data Transfer
    [Arguments]    ${st_ue_id}     ${en_ue_id}    ${duration}    ${Dir}  ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    [Documentation]    This keyword is used to start the data transfer in UL and DL
    FOR     ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
        ${ul_timestamp}=    Run Keyword If  '${Dir}' == 'ul'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=${Dir}    pdu_id=1    trf_id=${trf_id}
        ...     qfi_id=${qos_profile}[${ue_id}]   sec=${duration}

         ${dl_timestamp}=   Run Keyword If  '${Dir}' == 'dl'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=${Dir}    pdu_id=1
        ...    trf_id=${trf_id}    qfi_id=${qos_profile}[${ue_id}]  sec=${duration}

        ${dl_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_dl}[${ue_id}]    dir=dl    pdu_id=1    trf_id=${trf_id}
        ...   qfi_id=${qos_profile}[${ue_id}]   sec=${duration}
        ${ul_timestamp1}=   Run Keyword If  '${Dir}' == 'both'
        ...    UE Trigger Traffic for SA QFI Based    ${ue_id}    Traffic_rate=${qos_profile_unit}[${ue_id}]
        ...    data_rate=${qos_profile_speed_ul}[${ue_id}]    dir=ul    pdu_id=1    trf_id=${trf_id}
        ...    qfi_id=${qos_profile}[${ue_id}]  sec=${duration}
    END

