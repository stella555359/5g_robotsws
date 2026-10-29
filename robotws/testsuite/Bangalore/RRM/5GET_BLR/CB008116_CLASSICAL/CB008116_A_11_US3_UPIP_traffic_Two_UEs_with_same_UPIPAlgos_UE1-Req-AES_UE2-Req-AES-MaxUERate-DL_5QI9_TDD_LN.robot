*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R2    CONFIGURED

Resource         ./basic_resource.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS23R2/basic_delta.json
...                 ${intgr}    ${ciph}
...                 AND     Sleep       10
#...                 AND     Perform SCF Delta Commissioning with delta_gen.json
#...                 AND     sleep     120
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   360s    reason=wait for RMOD- to comeup
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_tdd_ref.cfg
...                 ${ue_profile}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Test Teardown       Run Keywords
...                 Run Keyword if test failed     Stop CPRT capture  ${CaptureCPRT}
...                 AND    Log To Console       Test_Case_Tear_down

Documentation
...
...             author:            navin.kumar_ray@nokia.com
...             maintainer:        navin.kumar_ray@nokia.com
...             INTRODUCTION:     This user scenario describes the behaviour of Nokia gNB in SA mode for the successful
...                               setup and operation of integrity protection for user plane traffic with multiple DRBs
...                               for two 5G-UEs with same IP algorithms – 1st UE with AES and 2nd UE with AES algorithm
...             TEST SET NAME:    CB008116_A_11_US3_UPIP_traffic_Two_UEs_with_same_UPIPAlgos_UE1-Req-AES_UE2-Req-AES
...           -MaxUERate-DL_5QI9_TDD_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16458,5G_CP_OTH_8630


*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CIT_A_11_US3_UPIP_TDD_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CIT_A_11_US3_UPIP_TDD_iphy.xml

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

&{ue_profile}    ${1}=${ip_prof2}    ${2}=${ip_prof2}  ${3}=${ip_prof2}  ${4}=${ip_prof3}
...              ${5}=${ip_prof}+${ip_prof1}  ${6}=${ip_prof3}+${ip_prof2}  ${7}=${ip_prof1}+${ip_prof3}

&{ip_ie}    ${1}=required       ${2}=required     ${3}=required   ${4}=required       ${5}=required
&{max_ip_rate}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate     ${3}=maximum-UE-rate   ${4}=maximum-UE-rate
...         ${5}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate     ${3}=maximum-UE-rate    ${4}=maximum-UE-rate
...     ${5}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=performed     ${3}=performed    ${4}=not-performed       ${5}=not-performed

${st_ue_id}      ${1}
${en_ue_id}      ${2}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1
@{QOS_Prof1_speed_ul}       1
@{QOS_Prof1_speed_dl}       1
@{QOS_Prof1_unit}           kbps

@{QOS_Prof2}                1           20
@{QOS_Prof2_speed_ul}       1           5
@{QOS_Prof2_speed_dl}       1           5
@{QOS_Prof2_unit}           kbps        mbps

@{QOS_Prof3}               1
@{QOS_Prof3_speed_ul}      10
@{QOS_Prof3_speed_dl}      10
@{QOS_Prof3_unit}          mbps

@{QOS_Prof7}               1        2          3                20
@{QOS_Prof7_speed_ul}      5       32         amr_wb_18_25     3
@{QOS_Prof7_speed_dl}      5       32         amr_wb_18_25     3
@{QOS_Prof7_unit}          mbps    kbps        rtp_codec        mbps


*** Test Cases ***
[1]CB008116_A_11_US3_UPIP_traffic_Two_UEs_with_same_UPIPAlgos_UE1-Req-AES_UE2-Req-AES-MaxUERate-DL_5QI9_TDD_LN
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof3}              ${2}=${QOS_Prof3}
    ...     ${3}=${QOS_Prof3}                ${4}=${QOS_Prof2}      ${5}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof3_speed_ul}     ${2}=${QOS_Prof3_speed_ul}
    ...     ${3}=${QOS_Prof3_speed_ul}     ${4}=${QOS_Prof2_speed_ul}     ${5}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof3_speed_dl}     ${2}=${QOS_Prof3_speed_dl}
    ...     ${3}=${QOS_Prof3_speed_dl}     ${4}=${QOS_Prof2_speed_dl}   ${5}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof3_unit}         ${2}=${QOS_Prof3_unit}
    ...     ${3}=${QOS_Prof3_unit}            ${4}=${QOS_Prof2_unit}       ${5}=${QOS_Prof2_unit}

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}
    ...      pdu_session_setup   ${ip_ie}   ${max_ip_rate}     pdu_id=1    nw_id=1

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}   ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}
    ...     ${qos_profile_unit}  ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

    Check Integrity failure count
    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}
    ...     both   ${trf_id}   ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}
    ...     ${qos_profile}

    [Teardown]    Run Keywords    MultiUE Deregister should be Successful     ${st_ue_id}    ${en_ue_id}
    ...           AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
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
    Log to Console      ${gfbr_mfbr_profile}

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






