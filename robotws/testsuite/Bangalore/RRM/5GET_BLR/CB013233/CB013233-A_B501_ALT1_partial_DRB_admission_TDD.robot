*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO

Documentation
...
...             author:           Mohan
...             maintainer:       mohanavel.p@nokia.com
...
...             INTRODUCTION:     The user scenario targets the DRX configuration for SA UE during ICS
...                               when gNB-DU partially admits DRBs. F1AP: UEContextSetupRequest message
...                               to gNB-DU to setup DRB, includes DRXCycle IE. gNB-DU partially admits
...                               DRBs and configures DRX considering admitted DRBs. First RRCReconfiguration
...                               to UE includes DRX configuration. After NGAP:InitialContextSetupResponse to
...                               AMF gNB does not send dedicated RRCReconfiguration to configure DRX to UE
...
...
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26393

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB013233_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot
Library          SSHLibrary

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
#...                 AND     Add GNB RadParam for ICS_DRX feature
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=B501_ALT1_partial_DRB_TDD_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces    ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/B501_ALT1.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${IPHY_FILE}                    ${CURDIR}/config/iphy_B501_ALT1.xml
${rad_params}=     0x890091=1
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${sa_ue_id4}      ${4}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID1}     1
${QFI_ID2}     2
${QFI_ID3}     3
${QFI_ID4}     4
${TEST_NAME}     ALT_TC1
${CELL_ID}    1
${no_of_cells}    2
${GNB_IP}     192.168.255.129
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu

*** Test Cases ***
CB013233-A#B501_ALT1_Successful early DRX setup for UE in SA mode with partial DRB admission (non-emtpy PDU)
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
#Step 1: Attach UE and check for Early DRX steup in UE contextsetup and start Data traffic
    log to console   "SA UE attach "
    Start Log    btslog   cprt
    Register non-CA UE${sa_ue_id1} with multiple bearer traffic
    sleep     2s
    Stop Log   btslog
    ${path1}    Stop Log    cprt   test_scenario=drbsetup
    Verify DRXcycle in F1AP_ICS and partial DRB admitted  ${path1}[cprt]/NODECPRT_GNB.pcap   ${crnti_1}
    UE Deregister should be Successful    ${sa_ue_id1}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=     Get Latest Unpacked Full Pm Counters File Classical  output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >100   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Add GNB RadParam for ICS_DRX feature
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x890091=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Verify DRXcycle in F1AP_ICS and partial DRB admitted
    [Arguments]   ${drx_cprt_pcap}   ${crnti}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${crnti}
    ${gnb_cu_ue_id}   Get gnb CU UEID from CRNTI   ${drx_cprt_pcap}   ${crnti}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ue_id}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)
    ${pdu_fail} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}   ngap.id == 54
    ${pdu_fail1}    analyzer.get_shownames            pdmlFile=${pdu_fail}
    ...                             packetName=PDUSessionResourceModifyResponse
    ...                             kind=showname
    ...                             path=.*radioNetwork$
    ...                             endPacket=1
    ${pdu_fail2}    analyzer.get_shownames            pdmlFile=${pdu_fail}
    ...                             packetName=PDUSessionResourceModifyResponse
    ...                             kind=showname
    ...                             path=.*radioNetwork$
    ...                             startPacket=2
    Should Be True    ${pdu_fail1} == ['radioNetwork: radio-resources-not-available (22)']
    Should Be True    ${pdu_fail2} == ['radioNetwork: invalid-qos-combination (23)']

Register non-CA UE${sa_ue_id} with multiple bearer traffic
    log to console   non-CA UE${sa_ue_id} attach trigerring now...
    ${crnti_1}   UE Register should be Successful And Fetch RNTI   ${sa_ue_id}   ${Pdu_session_ID}    ${nwslice_ID}   ${gw_ID}
    Sleep    2s    reason=wait command finish
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID1}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
#Attach dedicated non-GBR bearer (5QI-7)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID2}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID2}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
#Attach dedicated GBR bearer (5QI-2)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID3}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID3}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Can not start UL/DL traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    qfi:${QFI_ID3} not present in pdu:${Pdu_session_ID}    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_not_started
#Attach dedicated GBR bearer (5QI-3)
    wtsrunner.ue_pdu_session_modify   ue=${sa_ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=${QFI_ID4}   by=amf
    sleep  2s
    wtsrunner.trf_data_start   ue=${sa_ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID4}  dir=dl   protocol=tcp   ack_mode=off  cl_trf_stats=on
    ...    mbps=10
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Can not start UL/DL traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    qfi:${QFI_ID4} not present in pdu:${Pdu_session_ID}    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_not_started
    set suite variable   ${crnti_1}
