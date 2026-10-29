*** Settings ***
Suite Setup    Setup BTS env and set keyword prority     scf=SCF1_CB008830.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Test Case Setup and Connect Server
Test Teardown     Test Teardown And Disconnect Server

Documentation    Suite description
...   Author:      Teana Wang
...   Contact:     teana.wang@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     CB008030

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot
Library     taf.transport.ssh    WITH NAME    csn



*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

${SYSCOM_FLAG}  ${True}
#${DEBUG}    ${True}
#${TTITRACE_FLAG}  ${True}
#${EMIL_FLAG}    ${False}
#${SOS_REPORT_FLAG}    pass:False,fail:False
#${SNAPSHOT_FLAG}    pass:False,fail:False
#${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False

${UE1_ALIAS}    UE1
${UE_TYPE}    huawei_sigspark

@{PRECONFIG_PA_VAL}
...    7=${110}
...    8=${110}
...    9=${110}
...    10=${110}

@{ATTACH_CELL1_PA_VAL}
...    7=${50}
...    8=${50}
...    9=${45}
...    10=${45}

@{TF_CA_PA_VAL}
...    7=${10}
...    8=${10}
...    9=${30}
...    10=${30}

@{SCELL_CHANGE_PA_VAL}
...    7=${10}
...    8=${10}
...    9=${10}
...    10=${10}




*** Test Cases ***
CB008830-ET-C007_Verify_SA_HiReliabSupported_SCellAddition_and_Scell_Change
    [Documentation]
    ...    Precondition:
    ...    UE_capabilit:N78A*-N71*
    ...    scell addition A1 threshold: a1ThresholdSCellAddSsbRsrpFDD=76, a1ThresholdSCellAddSsbRsrpTDD=96
    ...    Test steps:
    ...    step1: UE1 attach to Cell-1 with 5QI7 and 5QI6(HR DRB) PDU session 1 and start dl data ransfer
    ...    step2: check A1 meas config in RRC Reconfig
    ...    step3: A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD
    ...           but lower than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...    step4: A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD for SA UE-1
    ...    step5: release 5QI6(HR DRB) via pdu session modify
    ...    step6: release UE
    ...    Expected result:
    ...    1, a, UE attached and PDU setup successfully
    ...       b, Checking IE in RRC:   CellGroupConfig->spCellConfigDedicated->dmrs-DownlinkForPDSCH-MappingTypeA,  DMRSType1 configured.
    ...       c, Check L3->L2 syscom message  PsUser_UserSetupReq/PsUser_UserModifyReq,  DMRS type correctly indicate to L2
    ...       d, Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    2, SA UE-1 configure A1 measurement for SCell addition with threshold for FDD(lower threshold).
    ...    3, a, SA UE-1 will add cell 2 for TDD-FDD 2CC CA.
    ...       b, A1 measurement for SCell addition is reconfigured for SA UE with higher threshold.
    ...       c, check DUToCURRCInformation i.e., CellGroupConfig->sCellToAddModList->sCellConfigDedicated->dmrs-DownlinkForPDSCH-MappingTypeA,
    ...         dmrs type is set to 1
    ...    4, a, SA UE-1 will trigger SCell change, cell 2 is removed and cell 4 is added as SCell for FDD-FR1 TDD 2CC CA.
    ...       b, A1 measurement for SCell addition is deactivated for SA UE-1.
    ...       c, Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    5, a, DMRS Type 2 reconfigured to use
    ...       c, Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    6, UE released.
    [Tags]    C007    QC_47180
    Prepare UE
    UE Attach to Cell-1 and Setup PDU with 5QI7
    Add One PDU Session with HR DRB of 5QI6
    Trigger Scell Addition to TF 2CC CA
    Trigger Scell Change from TF to TT 2CC CA
    Remove One PDU Session with HR DRB of 5QI6
    Stop traffic
    UE Detach
    Check Wireshark Log


*** Keywords ***
Connect to Control PC
    [Arguments]    ${cpc_ip}=${UE_PC_IP}
    ...    ${cpc_usrname}=${UE_PC_USERNAME}
    ...    ${cpc_passwd}=${UE_PC_PASSWD}
    ${ret}    Wait Until Keyword Succeeds    5min    20s
    ...   csn.Connect to   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=cpc_0
    should be true     ${ret}

Connect to EPC APP
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    Log to console    Connect to EPC APP...
    Wait Until Keyword Succeeds    2min    20s    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=EPCAPP

Test Case Setup and Connect Server
    Common Test Setup And Start To Capture Logs
    Connect to Control PC
    Connect to EPC APP
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}

Test Teardown And Disconnect Server
    log to console    Case Teardown...
    run keyword and ignore error    UE Detach
    csn.disconnect    connection=cpc_0
    csn.disconnect    connection=EPCAPP
    Common Test Teardown with scout

Set PA
    [Arguments]      ${pa_values}
    #Note: set some ports failed occasionally, so set twice to avoid this issue temporarily
    log to console    Set PA...
    ${cur_values}    set_pa_values    ${pa_values}
    run keyword if  not ${cur_values}==${pa_values}    set_pa_values    ${pa_values}
    sleep    10s

Prepare UE
    log to console    prepare UE...
    Set PA    ${PRECONFIG_PA_VAL}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}     ue_num_input=2    power_reset=True
    Config UE to SA Mode

Config UE to SA Mode
    log to console    Config UE to SA Mode...
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",0    ue_alias=${UE1_ALIAS}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="nr5g_disable_mode",2    ue_alias=${UE1_ALIAS}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=${UE1_ALIAS}
    spark.send_at_command_on_ue     command=AT+QNWPREFCFG="ue_capability_band"    ue_alias=${UE1_ALIAS}

UE Attach to Cell-1 and Setup PDU with 5QI7
    log to console    UE Attach...
    Set PA    ${ATTACH_CELL1_PA_VAL}
    power_ue.UE Attach    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}    power_reset=True
    Verify Attach Cell    cell_pci=205
    Send Traffic    apn=stdata1    send_dl=100    send_ul=10
    Check Traffic   check_dl=30    check_ul=0
    Get Total Tput Info

UE Detach
    log to console    UE Detach...
    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}

Get Total Tput Info
    ${params}    create list
    ...    NR MAC Thr. DL [Mbps]
    ...    NR MAC Thr. UL [Mbps]
    ...    NR PDSCH BLER[%]
    ...    NR PUSCH BLER[%]
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE1_ALIAS}    param=${params}

Get CA Cell Tput Info
    ${params}    create list
    ...    NR MAC Thr. DL PCell
    ...    NR MAC Thr. UL PCell
    ...    NR PDSCH BLER PCell
    ...    NR PUSCH BLER PCell
    ...    NR MAC Thr. DL SCell1
    ...    NR PDSCH BLER SCell1
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE1_ALIAS}    param=${params}

Verify Attach Cell
    [Arguments]    ${cell_pci}=205
    ${pdu_ip}    spark.get_ue_ip_on_ue    ue_alias=${UE1_ALIAS}    apnaddress=stdata1
    should not be empty      ${pdu_ip}
    ${param_name_list}    create list     NR PCI
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=${UE1_ALIAS}    param=${param_name_list}
    should be true    ${${value_list}[0]}==${cell_pci}

Add One PDU Session with HR DRB of 5QI6
    log to console    Add HR DRB PDU...
    spark.send_at_command_on_ue    ue_alias=${UE1_ALIAS}    command=AT+CGACT?
    ${pdu_ip}    spark.create_pdu_session    ue_alias=${UE1_ALIAS}    id=2    apn=stdata2
    should not be empty      ${pdu_ip}
    Send Traffic    apn=stdata2    send_dl=10    send_ul=5
    #tput decrease after add HRDRB
    Check Traffic   check_dl=30    check_ul=0
    Get Total Tput Info

Remove One PDU Session with HR DRB of 5QI6
    log to console    Remove HR DRB PDU...
#    ${event_name_list}    create list     SA PDU Release Accept
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE1_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==0
    spark.send_at_command_on_ue    ue_alias=${UE1_ALIAS}    command=AT+CGACT?
    spark.release_pdu_session    ue_alias=${UE1_ALIAS}    id=2
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE1_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==1
    spark.send_at_command_on_ue    ue_alias=${UE1_ALIAS}    command=AT+CGACT?
    run keyword and ignore error      Get CA Cell Tput Info
    Check Traffic   check_dl=30    check_ul=0

Send Traffic
    [Arguments]      ${apn}=stdata1    ${send_dl}=100    ${send_ul}=10    ${duration}=1800
    log to console    Send traffic to ${apn}...
    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}    direction=dl    throughput=${send_dl}Mbits/sec
    ...    duration=${duration}    ue_index=0    apn_address=${apn}    dt_name=UE1_DL
    # Note: use iperf to send UL traffic better
    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}    direction=ul    throughput=${send_ul}Mbits/sec
    ...    duration=${duration}    ue_index=0    apn_address=${apn}    dt_name=UE1_UL
    sleep    15s

Stop Traffic
    [Arguments]      ${apn}=stdata1
    log to console    stop traffic...
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}    direction=dl    ue_index=0
    ...    apn_address=${apn}    dt_name=UE1_DL
    power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}    direction=ul    ue_index=0
    ...    apn_address=${apn}    dt_name=UE1_UL

Check Traffic
    [Arguments]      ${check_dl}=90    ${check_ul}=10
    log to console    Check Traffic...
    # Note: check the total traffic, contain all pdus traffic
    wait until keyword succeeds  60s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}
    ...    direction=dl    throughput=${check_dl}    deviation=0
    wait until keyword succeeds  60s    10s    power_ue.Check throughput    ue_type=${UE_TYPE}    ue_alias=${UE1_ALIAS}
    ...    direction=ul    throughput=${check_ul}    deviation=0

Trigger Scell Addition to TF 2CC CA
    log to console    Trigger Scell Addition to TF 2CC CA...
#    ${event_name_list}    create list     NR5G Event A1    NR5G CA Config Success
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE1_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}==0
#    should be true      ${${count_list}[1]}==0
    Set PA    ${TF_CA_PA_VAL}
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE1_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}>=1
#    should be true      ${${count_list}[1]}==1
    run keyword and ignore error      Get CA Cell Tput Info
    ${cell_list}    create list    205    206
    Check Traffic   check_dl=50    check_ul=0

Trigger Scell Change from TF to TT 2CC CA
    log to console    Trigger Scell Change from TF to TT 2CC CA...
    Set PA    ${SCELL_CHANGE_PA_VAL}
#    ${event_name_list}    create list     NR5G Event A1    NR5G CA Config Success
#    ${count_list}    spark.get_event_count_on_ue    index=1    ue_alias=${UE1_ALIAS}    event_name=${event_name_list}
#    should be true      ${${count_list}[0]}>=2
#    should be true      ${${count_list}[1]}==2
    run keyword and ignore error      Get CA Cell Tput Info
    ${cell_list}    create list    205    208
    Check Traffic   check_dl=30    check_ul=0

Check Wireshark Log
    # Note: can use keyword: wireshark_check_by_tshark
    log to console    Check Wireshark Log...
    Stop Capture Logs
    ${TF_usersetupreq}    catenate
    ...    itf_l2_ps_user_UserSetupReq_t.ueAddCause == 9 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1
    ...    and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 0 and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 1
    ...    and itf_l2_ps_CellConfigParam_t.dmrsScramblingId_0 == 206 and itf_l2_ps_CellConfigParam_t.dmrsScramblingId_0 == 205
    ...    and itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers == 4
    ${TT_usersetupreq}    catenate
    ...    itf_l2_ps_user_UserSetupReq_t.ueAddCause == 9 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 1
    ...    and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 0 and itf_l2_ps_CellConfigParam_t.dmrsScramblingId_0 == 205
    ...    and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 1 and itf_l2_ps_CellConfigParam_t.dmrsScramblingId_0 == 208
    ${UserModifyReq}    catenate
    ...    itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 and itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers == 4 and
    ...    itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 0 and itf_l2_ps_cellconfigmodifyparam_t
    ${Reconfiguration_cell1}    catenate
    ...    nr-rrc.drb_ToAddModList == 1 and nr-rrc.pdu_Session == 2 and nr-rrc.dmrs_AdditionalPosition == 0
    ...    and nr-rrc.scramblingID0 == 205 and nr-rrc.c1 == 0 
    ${Reconfiguration_cell2}    catenate
    ...     nr-rrc.measTriggerQuantity.rsrp == 96 and nr-rrc.sCellToAddModList == 1 and nr-rrc.physCellId == 206 
    ...     and nr-rrc.scramblingID0 == 206 and nr-rrc.c1 == 0
    ${scell_change}    catenate
    ...    nr-rrc.physCellId == 208 and nr-rrc.sCellToAddModList == 1 and nr-rrc.dmrs_AdditionalPosition == 1 and 
    ...    nr-rrc.scramblingID0 == 208 and nr-rrc.sCellToReleaseList == 1 and nr-rrc.SCellIndex == 1 and nr-rrc.c1 == 0
    ${PDUSESSION_Release}    catenate
    ...    ngap.pDUSessionID == 2 and ngap.nas == 0 and ngap.procedureCode == 28 and ngap.PDUSessionResourceToReleaseListRelCmd == 1
    ${UserModifyReq_call4}    catenate
    ...    itf_l2_ps_pdsch_PdschConfig.mcsTable == 1 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and
    ...    itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers == 4 and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 1
    ${Reconfig_after_HRDRB}    catenate
    ...    nr-rrc.dmrs_AdditionalPosition == 0 and nr-rrc.scramblingID0 == 205 and nr-rrc.dmrs_Type == 0 and nr-rrc.dmrs_AdditionalPosition == 1
    ...    and nr-rrc.scramblingID0 == 208 and nr-rrc.drb_ToReleaseList == 1 and nr-rrc.c1 == 0
    
tshark message
    ${filter_list}    create list
    # count=1 --- PDUSessionResourceSetupRequest: add second HR DRB pdu
    ...    "ngap.pDUSessionID == 2 and ngap.fiveQI == 6 and ngap.procedureCode == 29"
    # count=1 --- itf_l2_ps_user_BearerSetupReq: check pdschHrLaConfig info
    ...    "itf_l2_ps_PdschHrConfig.dlHrBlerOutageMcsThresh64qam == 3 and itf_l2_ps_user_bearersetupreq_t"
    # count=1 --- itf_l2_ps_user_UserModifyReq: dmrs type change to 1
    ...    "${UserModifyReq}"
    # count=1 --- RRC Reconfiguration: cell-1 dmrs type change to 1
    ...    "${Reconfiguration_cell1}"
    # trigger A1 scell addition to TF CA
    # count=1 --- itf_l2_ps_user_UserSetupReq:  cell-1 dmrs type: 1, cell-2 dmrs type:1
    ...    "${TF_usersetupreq}"
    # count=1 --- RRC Reconfiguration: scell cell-2 added
    ...    "${Reconfiguration_cell2}"
    # trigger Scell change to TT CA
    # count=1 --- itf_l2_ps_user_UserSetupReq:  cell-1 dmrs type: 1, cell-4 dmrs type:1
    ...    "${TT_usersetupreq}"
    # count=1 --- RRC Reconfiguration: scell change from cell-2 to cell-4
    ...    "${scell_change}"
    # count=1 --- PDUSessionResourceReleaseCommand: relese HR DRB pdu
    ...     "${PDUSESSION_Release}"
    # count=1 --- itf_l2_ps_user_UserModifyReq: cell-4 dmrs type change to 2
    ...    "${UserModifyReq_call4}"
    # count=1 --- RRC Reconfiguration: cell-1 and cell-4 dmrs type change to 2 after release HRDRB PDU
    ...     "${Reconfig_after_HRDRB}"
    # count=1 --- PDUSessionResourceReleaseResponse: relese HR DRB pdu
    ...    "ngap.pDUSessionID == 2 and ngap.PDUSessionResourceReleasedListRelRes == 1"
    FOR    ${filter}    IN    @{filter_list}
        ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}/wireshark.pcap -Y ${filter} | wc -l
        ${rest}	${last} 	Split String From Right	    ${output}	   \n    -1
        should be true    ${last}==1
    END

    # 1: count=2 --- itf_l2_ps_user_UserSetupReq: attache to cell-1, dmrs type 1
    ${filter}    catenate
    ...    "itf_l2_ps_pdsch_PdschConfig.dmrsType == 1 and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 1
    ...    and itf_l2_ps_CellConfigParam_t.dmrsScramblingId_0 == 205 and itf_l2_ps_user_UserSetupReq_t.ueAddCause == 0"
    ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}/wireshark.pcap -Y ${filter} | wc -l
    ${rest}	${last} 	Split String From Right	    ${output}	   \n    -1
    should be true    ${last}==2

    # 2: count=2 --- itf_l2_ps_user_UserModifyReq: after firsr pdu setup, dmrs type change to 2, cell1:lDMRSAdditionalPosition=No additional DMRS
    ${filter}    catenate
    ...    "itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers == 4
    ...    and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 0"
    ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}/wireshark.pcap -Y ${filter} | wc -l
    ${rest}	${last} 	Split String From Right	    ${output}	   \n    -1
    should be true    ${last}==2

    # 3: count=1 --- RRC Reconfiguration: cell-1 dmrs type 2
    ${filter}    catenate
    ...    "nr-rrc.dmrs_Type == 0 and nr-rrc.dmrs_AdditionalPosition == 0 and nr-rrc.scramblingID0 == 205
    ...    and nr-rrc.measTriggerQuantity.rsrp == 76 and nr-rrc.c1 == 0"
    ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}/wireshark.pcap -Y ${filter} | wc -l
    ${rest}	${last} 	Split String From Right	    ${output}	   \n    -1
    should be true    ${last}>=1

    # 13: count=2 --- itf_l2_ps_user_UserModifyReq: cell-1 dmrs type change to 2
    ${filter}    catenate
    ...    "itf_l2_ps_pdsch_PdschConfig.mcsTable == 0 and itf_l2_ps_pdsch_PdschConfig.dmrsType == 2 and
    ...    itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers == 4 and itf_l2_ps_pdsch_PdschConfig.dmrsAdditionalPosition == 0"
    ${output}    Execute Cmd On Pc    tshark -r ${SAVE_LOG_DIRECTORY}/wireshark.pcap -Y ${filter} | wc -l
    ${rest}	${last} 	Split String From Right	    ${output}	   \n    -1
    should be true    ${last}==2
