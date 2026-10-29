*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN     SBTS00    SBTS23R2    CONFIGURED


Resource         ./basic_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS25R2/basic_delta_A8_A10_5QI3.json   ${intgr}    ${ciph}
...                 AND     Perform SCF Delta Commissioning with 8116_A8_A10.json
...                 AND     sleep     120
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     sleep     60
...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_tdd_ref.cfg      ${ue_profile}
...                 AND     sleep     30
...                 AND     update_delta_and_create.update_cfg1  ${CURDIR}/config/wts/basic_setup_2CC_tdd_ref.cfg      ${ue_profile1}
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}
Test Teardown       Run Keywords
...                 Run Keyword if test failed     Stop CPRT capture  ${CaptureCPRT}
...                 AND    Log To Console       Test_Case_Tear_down

Documentation
...
...             author:            prakhar
...             maintainer:        prakhar.rastogi@nokia.com
...
...             INTRODUCTION:     This user scenario describes the behaviour of Nokia gNB in SA mode for the successful setup
...                               and operation of integrity protection(SNOW-3G) for user plane traffic up to maximum-UE-rate.

...             TEST SET NAME:    CB008116_A_8_US2_UPIP_traffic_anyDataRate_with_UPIPInd-Req-SNOW3G-maxUERate_5QI9_UL_TDD_Classical_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16457,5G_CP_OTH_8630





*** Variables ***
#${SCFC}=        ${CURDIR}/config/SCF/CB008116_A_8_US2_UPIP_traffic_anyDataRate_TDD_scf.xml
#${AP_XML}=      ${CURDIR}/config/SCF/CB008116_A_8_US2_UPIP_traffic_anyDataRate_TDD_iphy.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_OPT.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=2  nea2_128=3  nea3_128=4
&{intgr}        nia0=1      nia1_128=4  nia2_128=2  nia3_128=3
${ip_prof}      null
${ip_prof1}      zuc
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof3}
&{ue_profile1}    ${3}=${ip_prof1}    ${4}=${ip_prof2}

&{ip_ie}    ${1}=required
&{ip_ie3}    ${3}=preferred

&{max_ip_rate}     ${1}=maximum-UE-rate
&{max_ip_rate3}  	   ${3}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate
&{max_ip_rate_dl3}    ${3}=maximum-UE-rate
&{ip_result}      ${1}=performed
&{ip_result3}     ${3}=not-performed
${st_ue_id}      ${1}
${en_ue_id}      ${4}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3
@{QOS_Prof1}               1        2          3
@{QOS_Prof1_speed_ul}      2       32         amr_wb_18_25
@{QOS_Prof1_speed_dl}      2       32         amr_wb_18_25
@{QOS_Prof1_unit}          mbps    kbps        rtp_codec
@{QOS_Prof7}               1
@{QOS_Prof7_speed_ul}      5
@{QOS_Prof7_speed_dl}      5
@{QOS_Prof7_unit}          mbps

@{QOS_Prof3}                1           5
@{QOS_Prof3_speed_ul}       2           5
@{QOS_Prof3_speed_dl}       2           5
@{QOS_Prof3_unit}           mbps        mbps


*** Test Cases ***
[1]CB008116_A_8_US2_UPIP_traffic_anyDataRate_with_UPIPInd-Req-SNOW3G-maxUERate_5QI9_UL_TDD_Classical_LN
   ${ue_profile}       Create Dictionary   ${1}=${ip_prof3}
   ${ue_profile1}       Create Dictionary   ${3}=${ip_prof1}
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${ip_ie3}      &{ip_ie3}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate3}      &{max_ip_rate3}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${max_ip_rate_dl3}      &{max_ip_rate_dl3}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ip_result3}      &{ip_result3}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Set Suite Variable    ${ue_profile1}      &{ue_profile1}

    Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}	    ${3}=${QOS_Prof3}         ${4}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}		${3}=${QOS_Prof3_speed_ul}     ${4}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}		${3}=${QOS_Prof3_speed_dl}     ${4}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}		${3}=${QOS_Prof3_unit}         ${4}=${QOS_Prof1_unit}

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom       1    1   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1
    sleep   3s

    ${capture_cprt3}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT3}    ${capture_cprt3}

    ${ue_to_bearer_list1}=  MultiUE Register should be Successful Custom1      3    3   pdu_session_setup
    ... 	${ip_ie3}      ${max_ip_rate3}     pdu_id=1    nw_id=1

    Create Modify PDU session   1     1    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    sleep   3s

    Create Modify PDU session   3     3    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list1[1]}

    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     1     1     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

    Start Data Transfer     3     3     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

    Check Integrity failure count
    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    1    1    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    3    3    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    MultiUE Deregister should be Successful      1     1
    sleep   3s
    [Teardown]    Run Keywords    MultiUE Deregister should be Successful     3    3
    ...           AND        Link SCOUT SCF to Configuration ID for Reporting



*** Keywords ***
MultiUE Register should be Successful Custom1
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${msg}    ${ip_ie}      ${max_ip_rate}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    ...     ${ho}=${-1}

    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti

    ${crnti_list}       Create List
    ${ue_to_bearer_list1}=    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1

#    ${capture_cprt3}     Capture CPRT Set Upon Config
#    Set test variable    ${CaptureCPRT3}    ${capture_cprt3}
    Set CPRT capture    ${CaptureCPRT3}
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'bitrate64kbs'     Enable 64kbps integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    ${ip_ie[${ue_idx}]}
    Run Keyword If  '${max_ip_rate[${ue_idx}]}' == 'maximum-UE-rate'     Enable Max integrity dat rate    ${msg}
    ...      ${ip_ie[${ue_idx}]}    ${ip_ie[${ue_idx}]}
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}

    ${output}=      Run Keyword If  ${ho} != ${-1}  Read WTS Output For Pattern And Print matching Lines    ${PDU_session_resource_setup_response}
    ...    ${Timeout_SA}
    ${output1}=      Run Keyword If  ${ho} == ${-1}  Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}
    ...    ${Timeout_SA}

    ${bearer_list}       Create List
    Run Keyword If  ${ho} != ${-1}  Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output}
    Run Keyword If  ${ho} == ${-1}  Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output1}
    ${bearer_id}=    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    Append To List	   ${bearer_list}        ${bearer_id}
    Set To Dictionary	${ue_to_bearer_list1} 	${ue_idx}	    ${bearer_list}
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}

    Stop CPRT capture  ${CaptureCPRT3}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ${ip_req}   Get From Dictionary     ${ip_ie}    ${ue_idx}
    Run Keyword If  ${ho} == ${-1}  Verify Initial_context_setup_req1    ${ip_ie[${ue_idx}]}   ${max_ip_rate[${ue_idx}]}
    ...    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap   ${max_ip_rate_dl3[${ue_idx}]}
    Run Keyword If  ${ho} == ${-1}  Verify Bearer_context_setup_req1     ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap      ${ue_idx}
    Run Keyword If  ${ho} == ${-1} and '${ip_req}'!='required'    Verify Bearer_context_setup_res1    ${LOG_PATH}/NODECPRT_GNB_UE_${ue_idx}.pcap
    ...      ${ue_idx}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list1}


Verify Initial_context_setup_req1
     [Arguments]    ${ip_req}       ${ul_bitrate}       ${pcap_file}     ${dl_bitrate}=${-1}
     ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap_file}    ngap.PDUSessionResourceSetupItemCxtReq_element
     ${packet}        set variable                  ngap.PDUSessionResourceSetupItemCxtReq_element

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.integrityProtectionIndication$
    ...                                                endPacket=${1}

    ${bit_rate_ul}    analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.maximumIntegrityProtectedDataRate_UL$
    ...                                                endPacket=${1}

    ${bit_rate_dl}    Run Keyword If    '${dl_bitrate}' != '${-1}'  analyzer.get_unique_showname     pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=ngap.MaximumIntegrityProtectedDataRate$
    ...                                                endPacket=${1}

    Should Contain         ${ip_ind}    ${ip_req}
    Should Contain         ${bit_rate_ul}    ${ul_bitrate}
    Run Keyword If    '${dl_bitrate}' != '${-1}'    Should Contain         ${bit_rate_dl}    ${dl_bitrate}


Verify Bearer_context_setup_req1
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=   Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupRequest_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupRequest

    ${ip_ind}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionIndication$
    ...                                                endPacket=${1}


    ${selected_algo}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionAlgorithm$
    ...                                                endPacket=${1}
    ${ip_req}   Get From Dictionary     ${ip_ie3}    ${ue_id}
    #   Below logic will be apply when the UE has only one profile and for multiple profile this code can't be used
    ${ip_ue_profile}    Get From Dictionary     ${ue_profile1}       ${ue_id}

    ${up_ip_profiles_id}    Get From Dictionary     ${profiles_mapping}     ${ip_ue_profile}


    Should Contain         ${ip_ind}    ${ip_req}
    Should Contain         ${selected_algo}    ${up_ip_profiles_id}
    ${ue_dl_max_rate}         Get From Dictionary      ${max_ip_rate_dl3}    ${ue_id}
    ${fp}=     Run Keyword if   '${ue_dl_max_rate}'=='bitrate64kbs'  Get filtered PDML file from pcap  ${pcap}  e1ap.BitRate == 65536


 Verify Bearer_context_setup_res1
    [Arguments]     ${pcap}     ${ue_id}
    ${pdmlFile}=    Get filtered PDML file from pcap    ${pcap}    e1ap.BearerContextSetupResponse_element
    ${packet}        set variable                  e1ap.System_BearerContextSetupResponse

    ${ip_res_act}      analyzer.get_unique_showname        pdmlFile=${pdmlFile}
    ...                                                packetName=${packet}
    ...                                                path=e1ap.integrityProtectionResult$
    ...                                                endPacket=${1}
    ${ip_res_exp}   Get From Dictionary     ${ip_result3}    ${ue_id}

    Should Contain         ${ip_res_act}    ${ip_res_exp}

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
