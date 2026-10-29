*** Settings ***
Documentation     author: y63li
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: ying.15.li@nokia-sbell.com

Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./Trigger.robot
#Library           get_pm_counter.py
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap   WITH NAME    cap
#Library           OperatingSystem
#Library           Collections
#Library           taf.pdu
#Library           String
#Library           Process

*** Variables ***
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${AF_PATH}      http://files.ute.nsn-rdnet.net/builds/enb/base/SBTS00_ENB_9999_210927_000007/SBTS00_ENB_9999_210927_000007_luashark.zip
${tmp_log_dir}    /home/ute/log
${data_tranfer_dl}     300Mbits/sec
${ultp}     2
${data_tranfer_ul}     20Mbits/sec
${dltp}     100
${mirror_path}    /home/ute/tools/mirror_script/
${tl_scf_dir_path}     ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T936/SBTS00.xml
${dl_duration}     20
${NSA_UE_MODE}    NSA
${NSA_attach_mode}    5G_NSA
${NSA_nettype}    NSA
${NSA_apn_addr}    wap2.nokia.com
# List of fields to catch per packet
${prachPrbOffset_int}    0
@{MSG_FIELDS_SLOT_SFN}              slot    sfn
@{ULDATA_PUCCH_REQ_FIELDS}          rnti$       pucchFormat$    startPrb$    numOfPrb$    nANPucch$    numOfSymbols$    firstSymbol$
...                                 numOfBitsOfUciInformation$
@{ULDATA_PUCCH_RESP_HARQD_FIELDS}   rnti$       pucchFormat$    startPrb$    ackNack$     dtx$         crc$
@{ULDATA_PUCCH_RESP_PS_FIELDS}      rnti$       pucchFormat$    startPrb$    uciBits$     dtx$         crc$
@{DLDATA_PDCCH_SEND_REQ_FIELDS}     rnti$
@{ULDATA_PUSCH_REQ_FIELDS}          rnti$       startPrb$       numOfPrb$    numOfPuschSymbols$    startSymbol$
@{ULDATA_PUSCH_RESP_HARQU_FIELDS}   rnti$   dtx$         crc$
@{ULDATA_PUSCH_RESP_PS_FIELDS}      rnti$   dtx$
# Response definition : packet name and list of fields to collect for each message
&{ULDATA_PUCCH_REQ}                    msg=uldata_pucchreceivereq          fields=${ULDATA_PUCCH_REQ_FIELDS}
&{ULDATA_PUCCH_RESP_HARQD}             msg=uldata_pucchreceiverespharqd    fields=${ULDATA_PUCCH_RESP_HARQD_FIELDS}
&{ULDATA_PUCCH_RESP_PS}                msg=uldata_pucchreceiverespps       fields=${ULDATA_PUCCH_RESP_PS_FIELDS}
&{DLDATA_PDCCH_SEND_REQ}               msg=dldata_pdcchsendreq             fields=${DLDATA_PDCCH_SEND_REQ_FIELDS}
&{ULDATA_PUSCH_RECEIVE_Req}            msg=uldata_puschreceivereq          fields=${ULDATA_PUSCH_REQ_FIELDS}
&{ULDATA_PUSCH_RECEIVE_RESP_HARQU}     msg=uldata_puschreceiverespharqu    fields=${ULDATA_PUSCH_RESP_HARQU_FIELDS}
&{ULDATA_PUSCH_RECEIVE_RESP_PS}        msg=uldata_puschreceiverespps       fields=${ULDATA_PUSCH_RESP_PS_FIELDS}

# Global response definition for UL Data Prach
@{UlDataPrachRespDefList_PUCCH}           ${ULDATA_PUCCH_REQ}             ${ULDATA_PUCCH_RESP_HARQD}              ${ULDATA_PUCCH_RESP_PS}
@{UlDataPrachRespDefList_PUSCH}           ${ULDATA_PUSCH_RECEIVE_Req}     ${ULDATA_PUSCH_RECEIVE_RESP_HARQU}      ${ULDATA_PUSCH_RECEIVE_RESP_PS}
@{UlDataPrachRespDefList_PUCCH_PUSCH}     ${ULDATA_PUCCH_REQ}             ${ULDATA_PUCCH_RESP_HARQD}              ${ULDATA_PUCCH_RESP_PS}
...                                       ${ULDATA_PUSCH_RECEIVE_Req}     ${ULDATA_PUSCH_RECEIVE_RESP_HARQU}      ${ULDATA_PUSCH_RECEIVE_RESP_PS}
@{UlDataPrachReceiveIndDefList}           ${ULDATA_PUCCH_REQ}             ${ULDATA_PUSCH_RECEIVE_Req}

@{TrafficFilter}                    UlData_PuschReceiveReq
...                                 UlData_PrachReceiveReq
...                                 UlData_PuschReceiveRespHarqU
...                                 UlData_PucchReceiveReq
...                                 UlData_PrachReceiveReq
...                                 UlData_PucchReceiveRespHarqD
...                                 UlData_PucchReceiveRespPs
...                                 UlData_PrachReceiveInd

@{AttachFilter}                     UlData_PucchReceiveReq
...                                 UlData_PrachReceiveReq
...                                 UlData_PucchReceiveRespHarqD
...                                 UlData_PucchReceiveRespPs
...                                 UlData_PrachReceiveInd
...                                 DlData_PdschSendReq
...                                 DlData_PdcchSendReq
...                                 DlData_PdschPayloadTbSendReq
...                                 UlData_PuschReceiveReq
...                                 UlData_PuschReceiveRespHarqU
...                                 UlData_PuschReceiveRespPs
...                                 UlData_PuschReceiveRespLo
*** Keywords ***
Attach ${ue_num} NSA UEs and Data Transfer
    log to console       \nAttach ${ue_num} NSA UEs and Data Transfer
    Attach Multi-UEs and Data Transfer    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}   ue_mode=${NSA_UE_MODE}
    ...    nettpye=${NSA_nettype}    apn_address=${NSA_apn_addr}    tp_direction=${tp_direction}

Stop ${ue_num} traffic and NSA UEs Detach
    log to console    \nStop ${ue_num} traffic and NSA UEs Detach
    Run keyword and ignore error     stop traffic and ue detach    ue_num=${ue_num}     ue_mode=${NSA_UE_MODE}
	...    apn_address=${NSA_apn_addr}

Attach Multi-UEs and Data Transfer
    [Arguments]    ${ue_num}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}    ${tp_direction}=both
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console       Prepare ue${i}
       power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}
       log to console       configure UE${i} mode
       spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${i}
       log to console       UE${i} attach
       ${5Grach_ed}    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
       sleep   5s
       power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
       sleep    3s
       log to console      Start traffic    console = yes
       Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${i}
       ...    direction=ul    apn_address=${apn_address}
       ...   throughput=${data_tranfer_ul}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
       sleep    10s
       Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${i}
       ...    direction=dl    apn_address=${apn_address}
       ...   throughput=${data_tranfer_dl}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
       sleep    5s
       log to console      check throughput  console = yes
       Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    power_ue.Check throughput    ue_type=${UE_TYPE}
       ...    direction=dl    throughput=${dltp}    ue_index=${i}
       Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Check throughput    ue_type=${UE_TYPE}
       ...    direction=ul    throughput=${ultp}    ue_index=${i}
    END

Attach One NSA UE
    [Arguments]    ${ue_id}    ${attach_mode}==${NSA_attach_mode}    ${ue_mode}=${NSA_UE_MODE}    ${nettpye}=${NSA_nettype}
    log to console       Prepare ue${ue_id}
    power_ue.Prepare UE    ue_index=${ue_id}   ue_type=${UE_TYPE}
    log to console       configure UE${ue_id} mode
    spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${ue_id}
    log to console       UE${ue_id} attach
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_id}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
    sleep   5s
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False

stop traffic and ue detach
    [Arguments]    ${ue_num}    ${ue_mode}   ${apn_address}
    log to console     Stop traffic    console = yes
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console      Stop traffic    console = yes
       Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       Run keyword and ignore error     power_ue.Stop traffic    direction=ul    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       log to console      UE Detach    console = yes
       Run keyword and ignore error     power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${i}
    END

Capture and dowload bip log
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Precondition for bip capture with gnbMirroring scripts    script_path=${mirror_path}
    Bip Capture with gnbMirroring scripts        sleep_time=3s
    csn.send command    command=killall tcpdump     connection=ASIK Master
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}=${TS_CASE_LOG_PATH}  log_path=${TS_CASE_LOG_PATH}
    set suite variable    ${bip_log_path}    ${list_log_path_local}[0]
    [Return]    ${list_log_path_local}
#
#Enable Counter collect
#    Log    \nEnable Counter collect    console=yes
#    admin_cli.Perform Parameter Recommissioning
#    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
#    ...    parameter=reportingIntervalPm
#    ...    value=5min
#    ...    operation=update
#    ...    skip_parameter_relation_errors=True
#    ...    connection=${GNB_COAM_ALIAS}
#
#Check Scheduled ${value} UEs per Slot
#    Log    \nCheck Scheduled ${value} UEs per Slot   console=yes
#    sleep    5min
#    Check PM counter Result    full_path=${full_path}    counter_id=M55308C17002    Scheduled_UE_num=${value}
#    Check PM counter Result    full_path=${full_path}    counter_id=M55308C18002    Scheduled_UE_num=${value}
#
#Check PM counter Result
#    [Arguments]    ${counter_id}    ${full_path}    ${Scheduled_UE_num}
#    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
#    List Should Contain Value    ${counter_result}    ${Scheduled_UE_num}
##    :For    ${i}    IN    @{counter_result}
##    \    Exit for loop if    ${i}==${Scheduled_UE_num}
#
#
#Check PM counter
#    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
#    Connect to gnb coam via ssl
#    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=${GNB_COAM_ALIAS}
#    ...    dic_path=${full_path}    date=${date}
#    [Return]    ${counter_value}
#    [Teardown]    COAM Teardown gnb connections
#
#eNB SCF Commission
#    Log To Console     \n *** eNB SCF Commission
#    [Arguments]  ${scf_file_path}    ${connection}=enblte    ${timeout}=300    ${is_pdl_checking_needed}=${True}
#    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
#    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
#    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
#    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
#    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
#    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
#    run keyword and continue on failure    Run keyword if    ${is_pdl_checking_needed}==${True}
#    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
#    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
#    BuiltIn.Log    Commission with scf file via rest API successfully.
#    [Return]  ${result}

Check PUSCH and PUSSCH has multiplexed with PRACH
    [Arguments]               ${testParam}
    Get Triggers and responses UL Data Prach                    pcapFile=${bip_log_path}
    ...                                                         respDefList=${UlDataPrachRespDefList_PUCCH_PUSCH}
    Check Pucch Resp HarqD Is In Rach Slot                      ${testParam}
    Check Pucch Is In Rach Slot                                 ${testParam}
    Check Pucch AN In Rach Slots                                ${testParam}
    Check Pucch Resp HarqD DTX CRC                              ${testParam}
    Check Pucch Resp Ps DTX CRC                                 ${testParam}
    Check Prioritize Pucch For CSI                              ${testParam}
    Check Symbol Guard In Rach Slots                            ${testParam}
    Check Pusch Receive Req Is In Rach Slot                      ${testParam}
    Check Pusch Resp HarqU Is In Rach Slot                       ${testParam}
    Check Pusch Receive Req Match Resp HarqU In Rach Slot        ${testParam}
    Check Pusch Resp HarqU DTX CRC                               ${testParam}

#FDM checks
Check Pusch In Rach Sfn and Slot
    [Documentation]                 Find the corresponding uldata_puschreceivereq to any
    ...                             uldata_prachreceivereq packet, and check that
    ...                             StartPrb and NumOfPrb values are corrects

    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${Capture_BIP_GNB.path}
    #${pdmlFile}=                    analyzer.pcap_to_pdml           /home/aacolats/1348/tcpdumpL2L1_filtering_off.pcap
    #${pdmlFile}=                     Set variable                    /home/aacolats/1348/gNB_bip_traffic_ue2_attach_ue2.pdml
    # 1 - Retrieve from pdml all pucchReq
    Dated log new line              Getting all uldata_prachreceivereq.PdmlFile=${pdmlFile} pathlist=${FIELDS_PRACH_REQ}
    @{listAllPrachReceiveReq}       analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_prachreceivereq
    ...                             pathList=${FIELDS_PRACH_REQ}
    ${lenPrachReq}                  get length                          ${listAllPrachReceiveReq}
    Set Test Variable               @{listAllPrachReceiveReq}
    Dated log                       NB of uldata_prachreceivereq:${lenPrachReq}
    # Show Packet Match List          listPacketMatch=${listAllPrachReceiveReq}
    # ...                             fields=${FIELDS_PRACH_REQ}          isDisplayShort=${False}

    # 2 - Retrieve from pdml all puschReceiveReq
    Dated log                       Getting all uldata_puschreceivereq
    @{listAllPuschReceiveReq}       analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceivereq
    ...                             pathList=${FIELDS_PUSCH_RECEIVED_REQ}
#    ...                             filter='dtx$'==00
    # Show Packet Match List          listPacketMatch=${listAllPuschReceiveReq}
    # ...                             fields=${FIELDS_PUSCH_RECEIVED_REQ}          isDisplayShort=${False}
    ${lenPuschReceiveReq}           get length                   ${listAllPuschReceiveReq}
    Dated log                       NB of uldata_puschreceivereq:${lenPuschReceiveReq}


    # 3 - Retrieve from pdml all puschReceiveRespHarqU
    Dated log                       Getting all uldata_puschreceiverespharqu
    @{listAllPuschReceiveRespHarqU}       analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=uldata_puschreceiverespharqu
    ...                             pathList=${FIELDS_PUSCH_RECEIVE_RESP_HARQU}
#    ...                             filter='dtx$'==00
    # Show Packet Match List          listPacketMatch=${listAllPuschReceiveRespHarqU}
    # ...
    ${lenPuschReceiveRespHarqU}           get length                   ${listAllPuschReceiveRespHarqU}
    Dated log                       NB of uldata_puschreceivereq:${lenPuschReceiveRespHarqU}

    ${cntPuschReceiveReq}                  Set Variable                        ${0}
    ${cntPuschReceiveRespHarpU}            Set Variable                        ${0}
    # 4 - For each prachReq, find corresponding puschReceiveReq and pucchRespHarqU (same slot/sfn) and check ackNack
    ${ListParser}                   analyzer.newListParser              ${listAllPuschReceiveReq}
    FOR    ${packet}   IN          @{listAllPrachReceiveReq}
    #       Retrieve slot and sfn for current pucchReq
            ${slot}                 Get Value In Packet Match
            ...                     packetMatch=${packet}
            ...                     field=slot
            ${sfn}                  Get Value In Packet Match
            ...                     packetMatch=${packet}
            ...                     field=sfn
    #       From list of all puschReceivedReq, extract those with same slot/sfn as current pucchReq
            ${ListParser}                 analyzer.newListParser              ${listAllPuschReceiveReq}
            ${listMatchPuschReceiveReq}   analyzer.getNextFromlistParser
            ...                           parser=${ListParser}
            ...                           filter='slot$'==${slot} and 'sfn$'==${sfn}
            ...                           maxDeep=10
            ${lenPuschReceiveReq}           get length                    ${listMatchPuschReceiveReq}
            Dated log                       lenPuschReceiveReq:${lenPuschReceiveReq}
            ${cntPuschReceiveReq}           Evaluate                      ${cntPuschReceiveReq}+${lenPuschReceiveReq}
            Dated log                       cntPuschReceiveReq:${cntPuschReceiveReq}
            Show Packet Match List          listPacketMatch=${listMatchPuschReceiveReq}
            ...                             fields=${FIELDS_PUSCH_RECEIVED_REQ}          isDisplayShort=${False}
    #       compute list of index of those pucchResp
    #       Compare numOfBitsOfUciInformation and ackNack and update stats upon results
            run keyword if                    ${lenPuschReceiveReq}!=${0}    verifyStartPrbAndNumOfPrb
            ...                                                              reqPacket=${packet}
            ...                                                              respPacketList=${listMatchPuschReceiveReq}
           # ${cnt}=    run keyword if        ${lenPuschReceiveReq}!=${0}          Evaluate                            ${cnt}+1
    #       From list of all puschReceivedRepHardU, extract those with same slot/sfn as current pucchReq
            ${ListParser}                   analyzer.newListParser              ${listAllPuschReceiveRespHarqU}
            ${listMatchPuschReceiveRespHarqU}   analyzer.getNextFromlistParser
            ...                           parser=${ListParser}
            ...                           filter='slot$'==${slot} and 'sfn$'==${sfn}
            ...                           maxDeep=10
            ${lenPuschReceiveRespHarqU}            get length                    ${listMatchPuschReceiveRespHarqU}
            ${cntPuschReceiveRespHarpU}            Evaluate                      ${cntPuschReceiveRespHarpU}+${lenPuschReceiveRespHarqU}
            Show Packet Match List          listPacketMatch=${listMatchPuschReceiveRespHarqU}
            ...                             fields=${FIELDS_PUSCH_RECEIVE_RESP_HARQU}          isDisplayShort=${False}
            Dated log      lenPuschReceiveRespHarqU:${lenPuschReceiveRespHarqU}
    #       compute list of index of those pucchResp
            ${listStr}              List Packet Match Index             ${listMatchPuschReceiveRespHarqU}
    #       Compare numOfBitsOfUciInformation and ackNack and update stats upon results
            run keyword if                    ${lenPuschReceiveRespHarqU}!=${0}    verifDtxAndCrc
            ...                                                              reqPacket=${packet}
            ...                                                              respPacketList=${listMatchPuschReceiveRespHarqU}
    END
    Dated log              cntPuschReceiveReq:${cntPuschReceiveReq}
    Dated log              cntPuschReceiveRespHarpU:${cntPuschReceiveRespHarpU}
    Should Not Be Equal    ${cntPuschReceiveReq}          ${0}
    Should Not Be Equal    ${cntPuschReceiveRespHarpU}    ${0}

verifyStartPrbAndNumOfPrb
    [Documentation]                 Check one and only one pucchResp was found for a pucchReq
    ...                             then check numOfBitsOfUciInformation is in line with ackNack
    ...                             return a string ending with OK, ERROR or NONE
    [Arguments]                     ${reqPacket}
    ...                             ${respPacketList}
    ${lenResp}                      get length                          ${respPacketList}
    #return from keyword if          ${lenResp}!=${1}                    NONE
    ${respPacket}                   set variable                        ${respPacketList[0]}
    # Extracting startPrb and numOfPrb from puschReiceiveReq
    ${startPrb}                     Get Value In Packet Match
    ...                             packetMatch=${respPacket}
    ...                             field=startPrb                       kind=show

    Dated log      startPrb:${startPrb}

    # ${startPrbInHexa}        transformInHexa          pdml_value=${startPrb}     reverse=True
    # Dated log      numOfPrbInHexa:${startPrbInHexa}
    ${startPrbInInteger}     Convert To Integer       ${startPrb}
    Dated log      numOfPrbInInteger:${startPrbInInteger}

    ${numOfPrb}                     Get Value In Packet Match
    ...                             packetMatch=${respPacket}
    ...                             field=numOfPrb                       kind=show

    Dated log      startPrb:${numOfPrb}

    # ${numOfPrbInHexa}        transformInHexa          pdml_value=${numOfPrb}     reverse=True
    # Dated log      numOfPrbInHexa:${numOfPrbInHexa}
    ${numOfPrbInInteger}     Convert To Integer       ${numOfPrb}
    Dated log      numOfPrbInInteger:${numOfPrbInInteger}

    # Check those 2 parameters are aligned
    ${status}                         Compute StartPrbAndNumOFfPrb Diag
    ...                             startPrb=${startPrbInInteger}
    ...                             numOfPrb=${numOfPrbInInteger}

    Dated log      status:${status}

    Should Be Equal         ${status}             OK

  #  [Return]                        ${status}


Compute StartPrbAndNumOFfPrb Diag
    [Documentation]                 Check a numOfBitsOfUciInformation is aligned with a ackNack
    ...                             return a string ending with : and OK or  ERROR
    [Arguments]                     ${startPrb}
    ...                             ${numOfPrb}

    ${prachPrbOffset}               Get Value In Packet Match
    ...                             packetMatch=${listAllPrachReceiveReq[0]}
    ...                             field=prachPrbOffset

    Dated log      prachPrbOffset:${prachPrbOffset}

    ${prachPrbOffsetInteger}        Convert To Integer       ${prachPrbOffset}

    # ${prachPrbOffset}               set variable    ${32}
    ${startPrb_value}               Evaluate     ${prachPrbOffsetInteger}+12
    ${numOfPrb_value}               Evaluate     273-${startPrb_value}
    ${verdict}                         set variable if
    ...                             ('${startPrb}'=='${startPrb_value}' and '${numOfPrb}'=='${numOfPrb_value}')
    ...                             OK                                  ERROR
    [Return]                        ${verdict}


verifDtxAndCrc
     [Documentation]                 Check one and only one pucchResp was found for a pucchReq
    ...                             then check numOfBitsOfUciInformation is in line with ackNack
    ...                             return a string ending with OK, ERROR or NONE
    [Arguments]                     ${reqPacket}
    ...                             ${respPacketList}
    # ${lenResp}                      get length                          ${respPacketList}
    # return from keyword if          ${lenResp}!=${1}                    NONE
    ${respPacket}                   set variable                        ${respPacketList[0]}
    Dated log      respPacket:${respPacket}
    # Extracting dtx and crc from puschReiceiveRespHarqU
    ${dtx}                          Get Value In Packet Match
    ...                             packetMatch=${respPacket}
    ...                             field=dtx                       kind=show

    Dated log      Dtx:${dtx}

    # ${startPrbInHexa}        transformInHexa          pdml_value=${startPrb}     reverse=True
    # Dated log      numOfPrbInHexa:${startPrbInHexa}
    ${dtxInInteger}     Convert To Integer       ${dtx}
    Dated log      dtxInInteger:${dtxInInteger}

    ${crc}                      Get Value In Packet Match
    ...                             packetMatch=${respPacket}
    ...                             field=crc                       kind=show

    Dated log      Crc:${crc}

    # ${numOfPrbInHexa}        transformInHexa          pdml_value=${numOfPrb}     reverse=True
    # Dated log      numOfPrbInHexa:${numOfPrbInHexa}
    ${crcInInteger}     Convert To Integer       ${crc}
    Dated log      crcInInteger:${crcInInteger}

    ${verdict}                         set variable if
    ...                             ('${dtx}'=='${0}' and '${crc}'=='${0}')
    ...                             OK                                  ERROR

    Should Be Equal         ${verdict}             OK


Check Pusch Receive Req Is In Rach Slot
    [Arguments]                     ${param}
    Check At least one Response     respName=${ULDATA_PUSCH_RECEIVE_Req.msg}

Check Pusch Resp HarqU Is In Rach Slot
    [Arguments]                     ${param}
    Check At least one Response     respName=${ULDATA_PUSCH_RECEIVE_RESP_HARQU.msg}

Check Pusch Receive Req Match Resp HarqU In Rach Slot
    [Arguments]                     ${param}
    ${nbErrPs}                      Check Number Of Records in Responses
    ...                                 respName1=${ULDATA_PUSCH_RECEIVE_Req.msg}
    ...                                 respName2=${ULDATA_PUSCH_RECEIVE_RESP_HARQU.msg}
    should be true                 ${nbErrPs} <${10}


Check Pusch Resp HarqU DTX CRC
    [Arguments]                     ${param}
    Check Pusch Resp DTX CRC        respName=${ULDATA_PUSCH_RECEIVE_RESP_HARQU.msg}

Check Pusch Resp DTX CRC
    [Arguments]                     ${respName}
    ${nbErrDtx}                     Check Field in Response
    ...                                 respName=${respName}
    ...                                 field=dtx
    ...                                 expected=${0}
    ...                                 isSlotSfnStr=${True}
    ${nbErrCrc}                     Check Field in Response
    ...                                 respName=${respName}
    ...                                 field=crc
    ...                                 expected=${0}
    ...                                 isSlotSfnStr=${True}
    Should be true                 ${nbErrDtx} < ${10}
    Dated log                             Nb error DTX=${nbErrDtx}
    Should be true                 ${nbErrCRC} < ${10}
    Dated log                       Nb error CRC=${nbErrCrc}


Check StartPrb And NumOfPrb In Pusch Receive Req
    [Arguments]                     ${param}
    ${expected_startPrb}            Evaluate    ${prachPrbOffset_int}+12
    ${expected_numOfPrb}            Evaluate    273-${expected_startPrb}
    ${expected_startPrb_hexa}       Evaluate    StringTool.toHexastr(${expected_startPrb})    modules=StringTool
    ${expected_numOfPrb_hexa}       Evaluate    StringTool.toHexastr(${expected_numOfPrb})    modules=StringTool

    ${nbErr_startPrb}               Check Field in Response
    ...                                 respName=${ULDATA_PUSCH_RECEIVE_Req.msg}
    ...                                 field=startPrb
    ...                                 expected=${expected_startPrb_hexa}

    ${nbErr_numOfPrb}               Check Field in Response
    ...                                 respName=${ULDATA_PUSCH_RECEIVE_Req.msg}
    ...                                 field=numOfPrb
    ...                                 expected=${expected_numOfPrb_hexa}

    Should be equal                 ${nbErr_startPrb}                             ${0}
    ...                             Nb error startPrb=${nbErr_startPrb}
    Should be equal                 ${nbErr_numOfPrb}                             ${0}
    ...                             Nb error numOfPrb=${nbErr_numOfPrb}

Check Pdcch Send Req Is In SSB Slot
    [Arguments]                         ${param}
    Check At least one Response SSB     respName=${DLDATA_PDCCH_SEND_REQ.msg}
    # Check Pusch Receive Req in Pucch slot + ${param.k2min}


#===================================================================================================
#TDM CHECKS
#============================================================================================================
Check Pucch Resp HarqD Is In Rach Slot
    [Arguments]                     ${param}
    run keyword if                  "${param.csiReportPeriodicity}"!="slots20"
    ...                             Check At least one Response
    ...                                 respName=${ULDATA_PUCCH_RESP_HARQD.msg}
    ...                                 expected=${param.PucchFlag}

Check Pucch Resp Ps Is In Rach Slot
    [Arguments]                     ${param}
    Check At least one Response     respName=${ULDATA_PUCCH_RESP_PS.msg}
    ...                             expected=${param.PucchFlag}

Check Pucch Is In Rach Slot
    [Arguments]                     ${param}
    ${nbErrPs}                      Check Number Of Records in Responses
    ...                                 respName1=${ULDATA_PUCCH_REQ.msg}
    ...                                 respName2=${ULDATA_PUCCH_RESP_PS.msg}
    should be true                  ${nbErrPs} < ${3}

Check Pucch Resp HarqD DTX CRC
    [Arguments]                     ${param}
    Check Pucch Resp DTX CRC        respName=${ULDATA_PUCCH_RESP_HARQD.msg}

Check Pucch Resp Ps DTX CRC
    [Arguments]                     ${param}
    Check Pucch Resp DTX CRC        respName=${ULDATA_PUCCH_RESP_PS.msg}

Check Pucch Resp DTX CRC
    [Arguments]                     ${respName}
    ${nbErrDtx}                     Check Field in Response
    ...                                 respName=${respName}
    ...                                 field=dtx
    ...                                 expected=${0}
    ...                                 isSlotSfnStr=${True}
    ${nbErrCrc}                     Check Field in Response
    ...                                 respName=${respName}
    ...                                 field=crc
    ...                                 expected=${0}
    ...                                 isSlotSfnStr=${True}
    Should be true                 ${nbErrDtx} < ${3}
    Dated log                             Nb error DTX=${nbErrDtx}
    Should be true                 ${nbErrCRC} < ${3}
    Dated log                             Nb error CRC=${nbErrCrc}

Check Symbol Guard In Rach Slots
    [Arguments]                     ${param}
    ${nbErrTotal}                   Set variable                            ${0}
    Dated log                       Check Symbol Guard In Rach Slots (firstSymbol==0x0000000d)  #and numOfPrb!=0x00000004)
    FOR    ${trigger}   IN         @{ListTrigger}
            ${nbErr}                Check Symbol Guard In Rach Slot         trigger=${trigger}
            ${nbErrTotal}           Evaluate                                ${nbErrTotal}+${nbErr}
    END
    Should be equal                 ${nbErrTotal}                           ${0}
    ...                             ${nbErrTotal} records don't have firstSymbol==0x0000000d and numOfPrb!=0x00000008

Check Symbol Guard In Rach Slot
    [Arguments]                     ${trigger}
    @{listRec}                      Set Variable                            ${trigger.dictResp['${ULDATA_PUCCH_REQ.msg}'].listRec}
    ${nbErrTotal}                   Set Variable                            ${0}
    FOR    ${rec}  IN              @{listRec}
            ${firstSymbol}          set variable                            ${rec.fields['firstSymbol']}
            ${numOfPrb}             set variable                            ${rec.fields['numOfPrb']}
            ${startPrb}             set variable                            ${rec.fields['startPrb']}
            ${startPrb_int}         Convert To Integer                      ${startPrb}
            ${nbErr}                Is Guard Symbol         ${firstSymbol}
            ...                                             ${startPrb_int}
            ...                                             ${prachPrbOffset_int}
            ...                                             ${numOfPrb}
            ${diag}                 Set variable if                         ${nbErr}==${0}
            ...                     OK                                      ERROR
            ${nbErrTotal}           Evaluate                                ${nbErrTotal}+${nbErr}
            ${packetStr}            Get formated Packet name                ${rec}
            ${prefix}               Set variable                            \tPacket:${packetStr} RNTI:${rec.rnti}
            Dated log               ${prefix} FirstSymbol=${firstSymbol} : DIAG=${diag}
    END
    [Return]                        ${nbErrTotal}

Check Prioritize Pucch For CSI
    [Arguments]                     ${param}
    ${nbErrTotal}                   Set variable                            ${0}
    ${test}                         Set variable if                         ${param.PucchF2flag}
    ...                             ==                                      !=
    ${field}                        Set variable                            numOfPrb
    ${expected}                     Set variable                            0x00000008
    Dated log                       Check Prioritize Pucch For CSI (${field}${test}${expected})
    ${nbErr}                        Check Field in Response                 respName=${ULDATA_PUCCH_REQ.msg}
    ...                                 field=${field}
    ...                                 expected=${expected}
    ...                                 test=${test}
    ...                                 isSlotSfnStr=${True}
    ...                                 checkKind=AtLeastOne
    Should be equal                 ${nbErr}                                ${0}
    ...                             ${nbErr} Records with ${field} not ${test} ${expected}

Check Pucch AN In Rach Slots
    [Arguments]                     ${param}
    ${nbErrTotal}                   Set variable                            ${0}
    set suite variable              ${nbPucchFormatTo2}                     ${0}
    Dated log                       Check Pucch AN In Rach Slots (PucchF2flag=${param.PucchF2flag})
    FOR    ${trigger}   IN         @{ListTrigger}
            ${nbErr}                Check Pucch AN In Rach Slot
            ...                         trigger=${trigger}
            ${nbErrTotal}           Evaluate                                ${nbErrTotal}+${nbErr}
    END
    Dated log                       \tNb pucchFormat set to 2=${nbPucchFormatTo2}
    Should be equal                 ${nbErrTotal}                           ${0}
    ...                             ${nbErrTotal} records have bad pucchFormat
    ${errFormat2}                   set variable if
    ...                                 ${param.PucchF2flag}==${True} and ${nbPucchFormatTo2}==${0}
    ...                                 ${True}                             ${False}
    should not be True              ${errFormat2}
    ...                             No record found with pucchFormat set to 2, while PucchF2flag was True

Check Pucch AN In Rach Slot
    [Arguments]                     ${trigger}
    @{listRec}                      Set Variable                            ${trigger.dictResp['${ULDATA_PUCCH_REQ.msg}'].listRec}
    ${nbErr}                        Set Variable                            ${0}
    FOR    ${rec}  IN              @{listRec}
            ${pucchFormat}          Set variable                            ${rec.fields['pucchFormat']}
            ${nANPucch}             Set variable                            ${rec.fields['nANPucch']}
            ${numOfBitsOfUciInformation}    Set variable                    ${rec.fields['numOfBitsOfUciInformation']}
            ${status}               Get Pucch Status
            ...                         pucchFormat=${pucchFormat}
            ...                         nANPucch=${nANPucch}
            ...                         numOfBitsOfUciInformation=${numOfBitsOfUciInformation}
            Dated log               numOfBitsOfUciInformation=${numOfBitsOfUciInformation}
            ${diag}                 Set Variable if                         ${status}
            ...                     OK                                      ERROR
            ${nbErr}                Set Variable if                         ${status}
            ...                     ${nbErr}                                ${nbErr}+${1}
            ${packetStr}            Get formated Packet name                ${rec}
            ${prefix}               Set variable                            \tPacket:${packetStr} RNTI:${rec.rnti}
            Dated log               ${prefix} pucchFormat=${pucchFormat} nANPucch=${nANPucch} : DIAG=${diag}
    END
    [Return]                        ${nbErr}

Get Pucch Status
    [Arguments]                     ${pucchFormat}
    ...                             ${nANPucch}
    ...                             ${numOfBitsOfUciInformation}
    ${nANPucchValue}                Get Decimal Value                       ${nANPucch}
    ${newFormat2}                   Set variable if                         '${pucchFormat}'=='2'
    ...                             ${1}                                    ${0}
    ${nbPucchFormatTo2}             Evaluate                                ${nbPucchFormatTo2}+${newFormat2}
    ${statusFormat2}                Get Status With Format 2                ${nANPucchValue}    ${numOfBitsOfUciInformation}
    ${statusFormat0}                Get Status With Format 0                ${nANPucchValue}
    Set suite variable              ${nbPucchFormatTo2}
    Return From Keyword If          '${pucchFormat}'=='2'                   ${statusFormat2}
    Return From Keyword If          '${pucchFormat}'=='0'                   ${statusFormat0}
    [Return]                        ${False}

Get Status With Format 2
    [Arguments]                     ${nANPucchValue}
    ...                             ${numOfBitsOfUciInformation}
    return from keyword if          ${nANPucchValue}==0                     ${True}
    return from keyword if          ${nANPucchValue}==1 and ${numOfBitsOfUciInformation}==0x00000009
    ...                                                    ${True}
    return from keyword if          ${nANPucchValue}==2 and ${numOfBitsOfUciInformation}==0x0000000a
    ...                                                    ${True}
    return from keyword if          ${nANPucchValue}>2                      ${True}

    [Return]                        ${False}

Get Status With Format 0
    [Arguments]                     ${nANPucchValue}
    return from keyword if          ${nANPucchValue}==1                     ${True}
    return from keyword if          ${nANPucchValue}==2                     ${True}
    [Return]                        ${False}


Is Guard Symbol
    [Arguments]                    ${A}
    ...                            ${B}
    ...                            ${C}
    ...                            ${D}

    #A:${firstSymbol} - B: ${startPrb_int} - C: ${prachPrbOffset_int} - D:${numOfPrb}

    ${nbErr}      Set variable if
	...    (((${A}==0x0000000c) and (${B}<${C} or ${B}>${C}+11))or ((${A}==0x0000000d) and ((${D}==0x00000008) or (${D}==0x000000016))))
    ...                     ${0}                                    ${1}

    [Return]                ${nbErr}
