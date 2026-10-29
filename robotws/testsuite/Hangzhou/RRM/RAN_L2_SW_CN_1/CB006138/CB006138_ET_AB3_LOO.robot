*** Settings ***
Documentation    ...
#Suite Setup      Log To Console    Start cases ABB5002
#Test Teardown    Common Test Teardown
#Force Tags       CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_JSHEN    SBTS00
#...              RAN_5G    RAN_5G_TDD
#Resource         ./CB006138_Resource.robot
#Variables        ./CB006138_ET_LOO.yaml
#
#*** Variables ***
#${FULL_FILE}         basic_2T3F_SCFC_LOO.xml
#${IPHY_2T3F_FILE}    ${CURDIR}/Resource/wts/iphy_2T3F_LOO.xml
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           basic_2T3F_VONR_LOO.cfg
#${SCF_PATH}          ${CURDIR}/Resource/Config
#
#*** Test Cases ***
#CB006138_ET_ABB5002_Setup_VoNR_Call_After_3CC_CA_Configuration_For_A_3CC_CA_UE_With_DRX_Disabled
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_FILE}    iphy_file=${IPHY_2T3F_FILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#    ...    AND    Delta Commission With SCF File    ${ABB5002['DELTA_FILE']}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_3}
#    SA Start DL Traffic Internal    ${UE_ID_3}    ${PDU_ID}    175    ${TRF_ID}
#    SA Start UL Traffic Internal    ${UE_ID_3}    ${PDU_ID}    10    ${TRF_ID}
#    Trigger A1 Scell Addition    ${UE_ID_3}    ${ABB5002['SRSRP_NR']}    ${ABB5002['PHYCELL_ID_PCELL']}
#    Verify Scells Are Activation    2
#    SA Setup VONR    ${UE_ID_3}
#    SA Start VONR Traffic Internal    ${UE_ID_3}    ${PDU_ID}    3    2
#    SA UE Check Throughput    ${UE_ID_3}    ${EXPECTED_TPUT_DL}    ${EXPECTED_TPUT_UL}    ${ABB5002['QFI']}
#    Trigger A2 Scell Release    ${UE_ID_3}    ${ABB5002['SCELL_ID']}    ${ABB5002['SCELL_RSRP']}    ${ABB5002['PHYCELL_ID_SCELL']}
#    Check Scell1 Is Released
#
#*** Keywords ***
#Check Scells Are Activated
#    Sleep    2s    reason=Wait For egate print
#    Save Egate Log    ${TEST_LOG_DIRECTORY}
#    ${CONTENT}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
#    ${PATT}    Set Variable    SCellIndex\\s+\\d\\s+activated successfully
#    ${MATHCES}    String.Get Regexp Matches    ${CONTENT}    ${PATT}
#    Sort List    ${MATHCES}
#    ${PHYSCELLIDLIST}    Create List    SCellIndex 1 activated successfully    SCellIndex 2 activated successfully
#    Sort List    ${PHYSCELLIDLIST}
#    Collections.Lists Should Be Equal    ${MATHCES}    ${PHYSCELLIDLIST}
#
#A1 Triggered Scell Addition
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID_6} meas_id=1 event=A1 srsrp_nr=90 phycell_id=${ABB2002['PHYCELL_ID_PCELL']}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#
#SA Setup VONR
#    [Arguments]    ${ue_id}    ${pdu_id}=1    ${qosflows_id_1}=1      ${qosflows_id_2}=2
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_id_1} by=amf
#    Sleep    5s    reason=wait egate print
#	ute_wtssim.Execute Egate Command
#	...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_id_2} by=amf
#    Sleep    5s    reason=wait egate print
#
#SA Start VONR Traffic Internal
#    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}    ${mbps}    ${trf_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi} dir=dl mbps\=${mbps} trf_id\=${trf_id}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=${qfi} dir=ul mbps\=${mbps} trf_id\=${trf_id}
#    Sleep    5s    reason=wait UL traffic is stable
