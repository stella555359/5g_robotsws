*** Settings ***
Documentation    Test keyword resource file for CB008574-B

*** Keywords ***
CB008574-B Testsuite Setup
    Timestamp Prints  log=Testsuite Setup Start
		Run Keywords  Put Swconfig File  ${SWCONFIG}
		...  AND  Update And Put Iphy Xml    input_filepath=${IPHY_XML}
    #...  AND  Enable RD flag of rdCellBlacklistSDL
		...  AND  Find Scfc And Fix And Send Full Commissioning  scfc_filename=${SCFC_FILE}  alias=commission
		...  AND  Initialize Misc Configurations
		...  AND  Wait for gNB Configured state
		...  AND  Start TCE
		...  AND  start_default_tshark_on_s1_mme_and_uu_interfaces_for_testcase  log_dirpath=${OUTPUT_DIR}/tshark
		...  AND  Start Egate
		...  AND  Links up
    Timestamp Prints  log=Testsuite Setup End

Verify F1AP UeContextReleaseCommand
    [Arguments]  ${isPresent}=${True}  ${RRCRelease}=${False}  ${cause}=10

    ${f1apMsgs}=  Set Variable If
    ...  "${isPresent}"=="${False}"  <1
    ...  "${isPresent}"=="${True}"   1

    ${causePart}=  Set Variable If
    ...  "${isPresent}"=="${False}"  ${EMPTY}
    ...  "${isPresent}"=="${True}"   && f1ap.radioNetwork == ${cause}

    ${releasePart}=  Set Variable If
    ...  "${RRCRelease}"=="${False}"  ${EMPTY}
    ...  "${RRCRelease}"=="${True}"   && nr-rrc.c1 == 2

    # procedureCode: id-UEContextRelease (6),
    # cause : radioNetwork: unspecified (0), normal-release (10)
    ${UeCtxRelCmd}=    Set Variable
    ...    f1ap.procedureCode == 6 ${causePart} ${releasePart}

    Log to console  Verify F1AP UeContextReleaseCommand, tshark alias: ${TSHARKALIAS_XN}

    Verify Tshark
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${UeCtxRelCmd}
    ...    pass_criteria=${f1apMsgs}  pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify F1AP UeContextReleaseCommand: Check msg with filter=${UeCtxRelCmd} and message count ${f1apMsgs} verified OK!

Verify FullConfig CB008574-B
    [Arguments]  ${fullConfigSet}=${False}

    Log to console  Verify CB008699 FullConfig is ${fullConfigSet}, tshark alias: ${TSHARKALIAS_XN}

    ${found}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  !
    ...  "${fullConfigSet}"=="${True}"   ${EMPTY}

    ${foundSourceConfig}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  ${EMPTY}
    ...  "${fullConfigSet}"=="${True}"   !

    ${f1apMsgs}=  Set Variable If
    ...  "${fullConfigSet}"=="${False}"  1
    ...  "${fullConfigSet}"=="${True}"   2

    # SourceConfig:
    ${filter1}=  Set Variable  f1ap.UEContextSetupRequest_element && ${foundSourceConfig}nr-rrc.sourceConfig_element

    Verify Tshark
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pass_criteria=${f1apMsgs}  pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify SourceConfig IE in UEContextSetupRequest: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  f1ap.UEContextSetupResponse_element && ${found}f1ap.id == 94

    Verify Tshark
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pass_criteria=${f1apMsgs}  pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify FullConfig IE in UEContextSetupResponse: Check msg with filter=${filter1} verified OK!

    ${filter1}=  Set Variable  xnap.HandoverRequestAcknowledge_element && ${found}nr-rrc.fullConfig

    Verify Tshark
    ...    alias=${TSHARKALIAS_XN}  packet_filter=${filter1}
    ...    pass_criteria=1  pcap_file_path=${TSHARKALIAS_XN_PATH}  timeout=10

    Log to console  Verify FullConfig IE in HandoverRequestAcknowledge: Check msg with filter=${filter1} verified OK!

Verify PCMD Records for Fallback to RRCSetup
    [Arguments]  ${interrupt}=${False}    ${RRCSetupCause}=2

    # gNB-CU UESetup Record with UE Setup Reason "other" and with Result "failure"
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_ueSetup_HO_a2a.pdm    field=trigger    value=0    step=1
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_ueSetup_HO_a2a.pdm    field=result    value=1    step=1
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_HO_a2a.pdm    step=1

    # gNB-CU PDU Session Info Record with Result "failure"
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_FB_a2a.pdm    step=2

    # XnAPTargetHO Record with Result "Misc_Failure"
    IF  "${interrupt}"=="${True}"
    ...  CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_xnHoTgt_a2a.pdm    step=3

    # DU UE Context Setup report with Initial UL RRC message receive time
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_RRE_a2a.pdm    step=4

    #gNB-CU UeDuConnectivity report with Initial UL RRC message receive time
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueDuConnectivity_HO_a2a.pdm    step=5

    ##gNB-CU RRCSetup Record
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_rrcSetup_FB_a2a.pdm    field=reestablishmentCause    value=${RRCSetupCause}    step=6
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_rrcSetup_FB_a2a.pdm    step=6

    #gNB-CU UESetup report with UE Setup Reason "Fallback to RRC Setup
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_ueSetup_HO_a2a.pdm    field=trigger    value=2    step=7
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_ueSetup_HO_a2a.pdm    field=result    value=0    step=7
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_ueSetup_HO_a2a.pdm    step=7

    # gNB-CU PDU Session Info Record with for RRCsetup
    CB008574-B Replace Field Value in PDM File    pdm_file=CU_pduSessionInformation_HO_a2a.pdm    field=trigger    value=1    step=8
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=CU_pduSessionInformation_HO_a2a.pdm    step=8

    #Target gNB-DU sends DU UE Context Setup Record
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_ueCtxSetup_HO_a2a.pdm    step=9

    #Target gNB-DU sends gNB-DU RRCSetup Record
    CB008574-B Replace Field Value in PDM File    pdm_file=DU_rrcSetup_FB_a2a.pdm   field=reestablishmentCause    value=${RRCSetupCause}    step=10
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_rrcSetup_FB_a2a.pdm    step=10

    # DU Bearer Record
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_bearer_HO_a2a.pdm    step=11

    # RLC layer periodical record, containing endMarker flag set to "true"
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_dlRbRlcMeasRecord_a2a.pdm    step=12

    # MAC layer periodical record, containing endMarker flag set to "true"
    CB008574-B Modify A2A Ini File Template And Run A2A Analysis  PDM_file=DU_dlSchedulingRecord_a2a.pdm    step=13

    Save Wireshark Txt Files With Timestamp

Save Wireshark Txt Files With Timestamp
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%S    exclude_millis=${True}
    Run    mv ${OUTPUT_DIR}/wireshark.txt ${OUTPUT_DIR}/wireshark_${time}.txt
    Run    mv ${OUTPUT DIR}/wireshark.txt.a2a_decode ${OUTPUT DIR}/wireshark.txt_${time}.a2a_decode
    Run    mv ${OUTPUT DIR}/tshark/${TEST_NAME}_wireshark.txt.a2a_decode ${OUTPUT DIR}/tshark/${TEST_NAME}_wireshark.txt_${time}.a2a_decode

CB008574-B Check Log With Au2analysis
    [Arguments]  ${ini_file}
    Log to console  A2A analyze ${OUTPUT DIR}/wireshark.txt file contents against ${ini_file}
    Check Log With Au2anlysis    ini_path=${ROBOT_SUITE_DIR}${/}a2a${/}${ini_file}  log_need_to_check=w  save_log_directory=${OUTPUT DIR}
    Run    cp ${OUTPUT DIR}/wireshark.txt.a2a_decode ${OUTPUT DIR}/tshark/${TEST_NAME}_wireshark.txt.a2a_decode
    #Run    cp ${OUTPUT DIR}/wireshark.txt.a2a_decode ${OUTPUT DIR}/tshark/${ini_file}_wireshark.txt.a2a_decode

CB008574-B Replace PDM Info In A2A Ini File
    [Arguments]   ${ini_file}=test.ini  ${PDM_file}=test.pdm  ${step}=1
    Log to console  Replace PDM Info In A2A Ini File. ini_file: ${ini_file} pdm_file: ${PDM_file}

    Run    sed -i 's/PARADIGM.*/PARADIGM: .\\\\${PDM_file}/g' ${ROBOT_SUITE_DIR}/a2a/${ini_file}
    # Backup changed file as part of testlogs:
    Run    cp ${ROBOT_SUITE_DIR}/a2a/${ini_file} ${OUTPUT DIR}/${TEST_NAME}_step${step}_${ini_file}
    #Run    cp ${ROBOT_SUITE_DIR}/a2a/${ini_file} ${OUTPUT DIR}/${ini_file}_step${step}_${ini_file}

CB008574-B Replace Field Value in PDM File
    [Arguments]   ${pdm_file}=test.pdm  ${field}=trigger  ${value}=1  ${step}=1
    Log to console  Replace Field Value in PDM File: ${ROBOT_SUITE_DIR}/a2a/${pdm_file} field: ${field} value: ${value}
    Run    sed -i 's/${field}.=.*/${field} = ${value}/' ${ROBOT_SUITE_DIR}/a2a/${pdm_file}
    # Backup changed file as part of testlogs:
    Run    cp ${ROBOT_SUITE_DIR}/a2a/${pdm_file} ${OUTPUT DIR}/${TEST_NAME}_step${step}_${pdm_file}

CB008574-B Modify A2A Ini File Template And Run A2A Analysis
    [Arguments]  ${PDM_file}  ${step}
    CB008574-B Replace PDM Info In A2A Ini File  ini_file=Template.ini  PDM_file=${PDM_file}  step=${step}
    CB008574-B Check Log With Au2analysis  ini_file=Template.ini

CB008574-B Start PCMD Capture
    Log to console  Start PCMD capture..
    Start Tshark  log_filename=${TEST_NAME}_pcmd.pcap  eth_interface=eth3:TCE  capture_filter=host 10.0.1.11
    ...    log_dirpath=${OUTPUT_DIR}/tshark  alias=PCMD

CB008574-B Stop PCMD Capture and Convert To TXT
    Log to console  Stop PCMD Capture and Convert To TXT ..
    Sleep  3s
    ${time}    Get current date    result_format=%Y-%m%d_%H:%M:%S    exclude_millis=${True}

    Stop Tshark  alias=PCMD
    ${VAR1}=  Set variable  tshark -o ntrstr.defragment:TRUE -d tcp.port==15000-15100,ntrstr -d tcp.port==49151,ntrstr -r
    ${VAR2}=  Set variable  ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.pcap -V > ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.txt
    Log  Tshark decoding cmd: ${VAR1} ${VAR2}
    Run  ${VAR1} ${VAR2}
    # Copy latest step file for analysis later and store all pcmd txt instances with timestamp:
    Run  cp ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.txt ${OUTPUT_DIR}/tshark/${TEST_NAME}_PCMD_${time}.txt
    Run  cp ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.txt ${OUTPUT_DIR}/wireshark.txt



