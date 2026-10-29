*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh

Library         ${CURDIR}/../../pcap_helper.py
Library         ${CURDIR}/../../../../../../resources/ST/python/LK_manager.py    WITH NAME    LK
Library         ${CURDIR}/../../../../../../resources/ST/python/LK_handler.py

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../QCT_androidUe_useful_keywords.robot

*** Variables ***
${Ue_Alias}              UE1
${L1L2_tcpdump}
${L1L2_trace_pcap}
${filtering}             on
${tcpdump_filter}
${filter_file_path}      ${CURDIR}/../../qCatFilter.txt

*** Keywords ***
Abf_Call_setup_with_traffic
    [Arguments]     ${beamset}    ${direction}=DL    ${DL_Tput}=520Mbits/sec
    ...             ${UL_Tput}=110Mbits/sec     ${duration}=40s    ${margin}=8
    [Teardown]      Abf_Call Setup With Traffic TearDown

    #Create L1L2 TCPDUMP Filter for
    # DlData_PatternConfigReq	       0xe101
    # DlData_SlotTypeReq	           0x0122
    # DlData_PdcchSendReq	           0x0133
    # DlData_PdschPayloadTbSendReq     0x0108
    # DlData_CsiRsSendReq	           0x0131

    ${tcpdump_filter}             catenate     ether[0x18:2]==0xe205
    #${tcpdump_filter}         Run Keyword If     '${5GRelease}'=='5G20B'
    #...    catenate    SEPARATOR=${SPACE}\\x26\\x26${SPACE}    ether[0x18:2]!=0xe101    ether[0x18:2]!=0x0122
    #...                              ether[0x18:2]!=0x0133     ether[0x18:2]!=0x0108    ether[0x18:2]!=0x0131
    #...              ELSE
    #...    catenate    SEPARATOR=${SPACE}\\x26\\x26${SPACE}    ether[0x18:2]!=0xe101    ether[0x18:2]!=0x0122
    #...                              ether[0x18:2]!=0x0133     ether[0x18:2]!=0x0108    ether[0x18:2]!=0x0131

    Set Suite Variable    ${tcpdump_filter}    ${tcpdump_filter}

    LK_handler.connect  hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    LK_handler.qcat_5g_get_licence    retry=10    # Reservation Of Qcat Licence

    Run Traffic Scenario and Traces Collection      direction=${direction}      DL_Tput=${DL_Tput}    UL_Tput=${UL_Tput}
    ...             duration=${duration}    margin=${margin}


    # configuration.luashark config       expand_field=0         expand_struct=1
    # In L1L2 logs:
    # - check that rach occasions are consistent with frame structure - beamset used - SSB used by Ue

    @{csv_files}    Create list
    ${index}    Set variable    0
    :FOR    ${pcap_file}   IN    @{L1L2_trace_pcap}
    \       ${str_index}    Convert to string    ${index}
    \       ${csv_file}    Set variable    ${logs_path}/Rach_pcapprocessed${str_index}.txt
    \       ${cmd}    catenate      tshark -X lua_script:/opt/luashark/luashark.lua -r ${pcap_file} -T fields
    ...   -Y "uldata_prachreceiveind" -e _ws.col.Info -e UlData_PrachReceiveInd.PrachReceiveInd.slot
    ...   -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.prachPreambleTimeOccasion -e UlData_PrachReceiveInd.PrachReceiveInd.sfn
    ...   -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.peakMetric -e UlData_PrachReceiveInd.detectedPrachPreambles_item_0.initialTa
    ...   -E header=y -E separator=, > ${csv_file}
    \     Run         ${cmd}
    \     Append To List    ${csv_files}    ${csv_file}
    \     ${index}     Evaluate    ${index} +1

    ${Rach_pcapprocessed}     merge_csv_files    ${csv_files}      Rach_pcapprocessed.txt

     # In Ue log:
    # - check that RACH procedure is successfull
    # - get SSB configuration used by Ue
    Check Rach procedure is successful
    ${list_rach_attempt} =    Get value from Ue logs    NR5G:MAC_RACH_Attempt:    SSB ID
    ${SSB_Id}    set variable    ${list_rach_attempt[0]}

    # configuration.luashark config

    ${extract}   grep file     ${Rach_pcapprocessed}      ICOM_5G/UlData_PrachReceiveInd

    @{extractlines}    Split To Lines      ${extract}
    ${extractFirstLine}     set variable      @{extractlines}[0]

    @{extractlist}     split string    ${extractFirstLine}    ,

    ${slot}      convert to integer      @{extractlist}[1]
    ${occasion}     convert to integer      @{extractlist}[2]
    ${sfn}      convert to integer      @{extractlist}[3]
    ${sfn}      Evaluate    ${sfn}%4
    ${peakmetric}   Set variable    @{extractlist}[4]
    ${ta}       convert to integer      @{extractlist}[5]

    #check match prisma ssb index  vs  pRACH in L1L2 logs
    log     ssb=${SSB_Id}:sfn=${sfn}:slot=${slot}:occasion=${occasion}
    # Les occasions de Rach sont hardcodées dans le fichier GOB.
    ${resp}     grep file   ${CURDIR}/ABFconfig_GOB_frame1_4.txt
    ...                     ssb=${SSB_Id}:sfn=${sfn}:slot=${slot}:occasion=${occasion}
    Should not be empty     ${resp}

*** Keywords ***
Run Traffic Scenario and Traces Collection
    [Documentation]     Run the test scenario:
    ...                 laucnch a traffic and collect Ue and L1L2 tcpdump traces
    [Arguments]     ${direction}=DLUL      ${DL_Tput}=520Mbits/sec    ${UL_Tput}=110Mbits/sec
    ...             ${duration}=40s    ${margin}=8
    [teardown]          gnbMirroring.Stop and Collect Mirroring Traces
    ...                 filtering=${filtering}

    Prepare lib and Ue    ${Ue_Alias}

    gnbMirroring.Start Mirroring Traces   number_of_files=2    file_size_mbytes=2    filtering=${filtering}
    ...            filter=${tcpdump_filter}    connection=asikFhCnx

    Perform Ue Attach Detach Traffic and Collect logs    ${Ue_Alias}    direction=${direction}    duration=${duration}
    ...                                                    DL_Tput=${DL_Tput}    UL_Tput=${UL_Tput}    margin=${margin}
    ...                                                  filter_file_path=${filter_file_path}    local_dir=${logs_path}/Ue_logs

Abf_Call Setup With Traffic TearDown
    LK_handler.qcat_5g_release_licence    retry=10
    #Log out and Disconnect from Licence Keeper Client application
    LK_handler.disconnect
    Run keyword and ignore error      configuration.Close Connections SSH

