*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CNI129151_B1_TC2_PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error_CA_5CC.robot
...             TEST SET NAME:     CNI129151_B1_TC2_PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error_CA_5CC.robot
...             TESTING SPLIT:     See CNI129151 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CNI129151 CFAM

Resource         ../CB012261/CB012261_resource.robot
Resource         ./basic_resource.robot

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/SCF_B1_TC02_5CC_FFTTT.xml
${AP_XML}=      ${CURDIR}/config/SCF/iphy_B1_TC02_5CC_FFTTT.xml
${SCFC_1}=        ${CURDIR}/config/SCF/CB005935_SCFC_BOO_AP_LOO.xml
${AP_XML_1}=      ${CURDIR}/config/SCF/CB005935_BOO_AP_LOO_iphy.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_B1_TC02_5CC_FFTTT.cfg
${wts_cfg_file_1}    ${CURDIR}/config/wts/wts_CB005935_BOO_AP_LOO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID2}    2
${TRF_ID}    1
${TEST_NAME}        test_case
${radparam}         SEPARATOR=${EMPTY}    0x890073 = 0      # it resolves E1 packects visibility issue in wireshark
${duration}         60
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CNI129151_B1_TC2_PDU_Session_Resource_Release_due_to_RLC_max_retransmission_error_CA_5CC.robot
    [Setup]          Run keywords    Log To console  Suitesetup
    ...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
    ...                 AND     Prepare TL with all config files
    ...                 AND     Suite setup from scratch
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
#    ...                 AND     start log    btslog\
    Log to console   Your setup is ready with CA_5CC...
    log to console   UE attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      3      nw_id=1
    2nd PDU addition    1    1
    PDU Modfication to add additional qfi    1    1   pdu_id=1    qosflows_to_add=2

    start log    cprt
    Start traffic for UE    1      1    pdu_id=1
    Start traffic for UE    1      1    pdu_id=2
    Trigger RLC max retransmission error    1    1     prof=1      lcid=4    sn=1
    Sleep      60s
    ${path_cprt_TC2_CA_5CC}    Stop log      cprt     test_scenario=cprt_TC2_CA_5CC
    Sleep      10s
    Check UE has Scell still activated    1    1

    verify pduSessionNotify message     ${path_cprt_TC2_CA_5CC}[cprt]/NODECPRT_GNB.pcap
    verify RLC injected DRB is in toBeRealeased item     ${path_cprt_TC2_CA_5CC}[cprt]/NODECPRT_GNB.pcap
    Sleep      10s
    OperatingSystem.Run    cp ${WTS_DIR}/egate_console.log ${LOG_PATH}

#    [Teardown]       Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1]CB012261_C_IWK1_03_InterBand_UL_CA_inFDD_CB005935_AAB9_Scell_LongPrachFromat0_inPcell_longPrachFormat1_inScell

    [Setup]         Run keywords    Log To console  Suitesetup
    ...                 AND     Prepare TL with all config files1
    ...                 AND     Suite setup from scratch
    #...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file1}

	Start log       btslog
    log to console   Starting tti logs...
    start log       ttitrace
    log to console   UE1 attach trigerring now...
    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    Start traffic for UE_new    1    1
    sleep     3s
    ${path_tti}    Stop Log      ttitrace    test_scenario=SCN1
    sleep     5s

###### TTITRACE Verification


    Common TTI PCAP to CSV Converter    SCN1    dir=ul
    sleep     10s
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${LOG_PATH}
    ${path_syslog}    Stop log    btslog
    ${search_string}        Create List      WRN/     ERR/
    syslog_search      ${path_syslog}[btslog]/gnb_syslog.log         ${search_string}

    ${pusch_BW}    ${prach_prb_off}      ${msg1fdm}      Read Cellsetup msg for uplink  ${cprt_log_1}[cprt]    53    51
    Log to console    PUSCH_BW=${pusch_BW} prach_prb_offset=${prach_prb_off} msg1fdm=${msg1fdm}

    ${ret}    Verify_2prb_CB012261    ${path_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    1_42   ${53}
    ...            ${pusch_BW}       ${prach_prb_off}[53]       ${msg1fdm}     Enabled
    Should Contain    ${ret}     Pass

    ${ret}    Verify_2prb_CB012261    ${path_tti}[ttitrace]/output_ul_formated.csv    FDD    longpucch    longprach    0_13   ${51}
    ...            ${pusch_BW}       ${prach_prb_off}[51]       ${msg1fdm}     Disabled
    Should Contain    ${ret}     Pass
    Multiple Feature Activate Deactivate
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Start traffic for UE
    [Arguments]    ${S_UE_id}     ${E_UE_id}    ${pdu_id}=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=${pdu_id}      trf_id=1       qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=${pdu_id}      trf_id=2       qfi_id=1
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=${pdu_id}      trf_id=3       qfi_id=2
    MultiUE Trigger DL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   dl_rate=175   pdu_id=${pdu_id}      trf_id=4       qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=175   pdu_id=${pdu_id}      trf_id=1       qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=l175   pdu_id=${pdu_id}      trf_id=2       qfi_id=1


PDU Modfication to add additional qfi
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}=1     ${qosflows_to_add}=1
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...             by=amf
     Sleep      2s
     END

2nd PDU addition
    [Arguments]    ${start_ue_id}     ${end_ue_id}

    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.set_pdu_param    ue=${ue_idx}    pdu=2    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=2    gw=1    ue=${ue_idx}    nwslice=1
    Sleep      2s
    END

verify pduSessionNotify message
    [Arguments]    ${cprt_log}

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=ngap.PDUSessionResourceNotifyReleasedTransfer_element
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   24

verify RLC injected DRB is in toBeRealeased item
    [Arguments]    ${cprt_log}
    ${filter}   Set variable    f1ap.radioNetwork==1
    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ${filter}
    ${drbid}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=f1ap.radioNetwork
    ...                                        path=.*dRBID$
    ...                                        endPacket=1
    Should BE Equal    ${drbid}   4

    ${fail_cause_code}    analyzer.get_unique            pdmlFile=${pdmlFile}
    ...                                        packetName=f1ap.radioNetwork
    ...                                        path=.*radioNetwork$
    ...                                        endPacket=1
    Should BE Equal    ${fail_cause_code}   1

    ${pdmlFile}          analyzer.pcap_to_pdml    ${cprt_log}         ngap
    ${rc}    Run and Return RC   cat ${pdmlFile}|grep -i ngap.UEContextReleaseCommand_element
    log to console    ${rc}
    Should Not Be Equal     ${rc}      ${0}

Check UE has Scell still activated
    [Arguments]     ${start_ue_id}    ${end_ue_id}
    ${state}    set variable     4 cells
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${op}    Run      cat /opt/iphy/latest/egate_console.log|grep -i -A 10 ue_stats_nr |grep -i CellIndex-|awk -F ' ' '{print $2}'
    log to console    ${op}
    ${op}     Split String    ${op}    \n
    END
    FOR    ${i}    IN     ${op}
     Should Not Be Equal     ${i}      ${0}
    END

Start traffic for UE_new
    [Arguments]    ${S_UE_id}     ${E_UE_id}
    MultiUE Trigger UL Traffic for SA   ${S_UE_id}   ${E_UE_id}   Traffic_rate=mbps   ul_rate=100   pdu_id=1      trf_id=1       qfi_id=1


Prepare TL with all config files1
     Log To Console    Configure ENV with SCFC/AP.xml/LUA
     add gnb configuration    scfc=${SCFC_1}
     add simulator  sim_type=airphone  config=${AP_XML_1}
##     add 5gc  config=${BASIC_CFG}  edaemon_ports=10000
     configure environment       rmod_detection_timeout=300s
     Log To Console    After Configure ENV

Multiple Feature Activate Deactivate
    [Documentation]    Alternates NIDD feature enable and disable 3 times.
    Log To Console    \nChanging feature flag value
    taf.sbts.oam.coam.admin.Setup Admin
    @{values}    Create List    enabled_Level1    disabled    enabled_Level1    disabled    enabled_Level1    disabled
    FOR    ${val}    IN    @{values}
        Log To Console    Setting feature to ${val}
        Online NIDD parameter change upd   paramName=actPrachMultiplexingLevel    paramValue=${val}    paramDst=MRBTS-1/NRBTS-1/NRCELL-3
        Sleep    10s
    END
    [Teardown]    taf.sbts.oam.coam.admin.Teardown Admin

Online NIDD parameter change upd
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set this False
     ...                       then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
