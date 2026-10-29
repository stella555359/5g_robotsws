*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_pm_counters
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_ue_measurements
Library     ta5g_delta
Library     ta_pcmd.tshark_plugin_configurator
Library     ta_pcmd
# Libraries for tti trace collecting and decoding
Library      taf.collectors.tcpdump    WITH NAME  tct
Library      taf.collectors.l2stream3  WITH NAME  tcl
Library      taf.collectors.core       WITH NAME  tcc
Library      taf.converters.eventdecoder  WITH NAME  tce


*** Keywords ***
Set UL CA Capabilties
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=UE_UL_CA_CAPA_M80
    ${command} =  catenate  SEPARATOR=
    ...           ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...           \ capability_file=${CURDIR}/CB006449_Capabilities.cfg
    Execute Egate Command    cmd=${command}

Set UL CA Capabilties For Multiple Ues
    [Arguments]    ${ues_amount}=30    ${ue_nr_capabilities}=UE_UL_CA_CAPA_M80
    ${ues_amount}=    Evaluate    ${ues_amount} + 1
    FOR    ${i}    IN RANGE    1    ${ues_amount}
       Set UL CA Capabilties    ue_id=${i}    ue_nr_capabilities=${ue_nr_capabilities}
    END

Deregister Multiple Ues
    [Arguments]    ${ues_amount}=30
    ${ues_amount}=    Evaluate    ${ues_amount} + 1
    FOR    ${i}    IN RANGE    1    ${ues_amount}
        Deregister Ue Without Confirmation    ue_id=${i}
    END

Assert Mba And Sba Trace Sessions
    [Arguments]    ${ca_ue_amount}=1
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}    number_of_messages=${ca_ue_amount}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...                    number_of_messages=${ca_ue_amount}
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...                    number_of_messages=${ca_ue_amount}
    Verify Tcp Messages    packet_filter=${RRC_SETUP_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...                    number_of_messages=${ca_ue_amount}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    ...                    number_of_messages=${ca_ue_amount}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...                    number_of_messages=${ca_ue_amount}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    ...                    number_of_messages=${ca_ue_amount}    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...                    number_of_messages=${ca_ue_amount}    relation_symbol= >=

Verify Pcell Related Counters
    ${pm_counter_file}=    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Verify Any Counters In All Files
    ...    M55114C01584    >1    PCELL_UE_CAP_2_CC_UL_MAX_SA       #This counter provides the maximum number of SA UEs
                                                                  #supporting maximum 2 CC UL in the PCell.
    ...    M55118C01000    >1    SAMPLES_UE_AMOUNTS               #This counter indicates the number of samples taken to
                                                                  #"user amount" counters. The counter can be used to
                                                                  #calculate "the average number of UEs"
    ...    M55118C10005    >1    UE_PCELL_1_CONF_SCELL_UL_SA      #This counter divided by SAMPLES_UE_AMOUNTS provides
                                                                  #the average number of CA UEs in the current cell
                                                                  #configured as a PCell, which have 1 configured SCell in UL.
    ...    M55118C10001    >1    RRC_RECONF_ADD1ULSCELL_ATT_SA     #This counter indicates the total number of RRC
                                                                  #Reconfiguration attempts for 1 SCell Addition in UL
                                                                  #for SA mode
    ...    M55118C10002    >1    RRC_RECONF_ADD1ULSCELL_SUCC_SA    #This counter indicates the total number of successful
                                                                  #RRC Reconfiguration attempts for 1 SCell Addition in
                                                                  #UL for SA mode
    ...    M55139C05516    >1    GNB_DU_UL_SCELL_1_ADMI_REQ_SA     #This counter provides the number of radio admission
                                                                  #requests for 1 UL SCell in DU. This counter is
                                                                  #updated to the PCell.
    ...    M55139C05519    >1    GNB_DU_UL_SCELL_1_ADMI_SUCC_SA    #This counter provides the number of radio admission
                                                                  #successes for 1 UL SCell in DU. This counter is
                                                                  #updated to the PCell.
    ...    M55138C03524    >1    GNB_UL_SCELL_1_ADMI_REQ_SA        #Number of radio admission requests for 1 UL SCell in
                                                                  #the addition of the PCell. This counter is updated to the
                                                                  #PCell whenever there is an admission request for the UE
    ...    M55138C03527    >1    GNB_UL_SCELL_1_ADMI_SUCC_SA       #Number of successful radio admissions for 1 UL SCell in
                                                                  #the addition of the PCell. This counter is updated to the
                                                                  #PCell whenever there is an admission request for the UE
    ...    M55118C11058    >1    GNB_UL_SCELL_1_CONFIG_REQ_SA      #Number of successful selections for 1 UL SCell in the
                                                                  #addition of the PCell. This counter is updated to the
                                                                  #PCell whenever there is an admission request for the UE
    ...    M55118C11068    >1    GNB_UL_SCELL_1_CONFIG_SUCC_SA     #This counter provides the number of 1 UL SCells configured.
                                                                  #This counter is updated on the PCell
    ...    M55118C00094    >1   PCELL_UL_1_SCELL_CONFIG_DUR_SA    #The counter counts the duration in which a UE is configured
                                                                  #with 1 UL SCell in a PCell. The counter starts when a UE is
                                                                  #configured with 1 UL SCell and stops when the configured SCell is
                                                                  #released ot number of SCells.
                                                                  #counter replaced M55156C00060 PCELL_UL_1_SCELL_CONF_DUR_SA
    ...    M55316C04001    >1    PSCELL_UE_1_ACT_SCELL_UL         #This counter indicates number of P(S)Cell UEs with 1
                                                                  #activated SCells in UL. Instantaneous value by "sample
                                                                  #interval" is measured, and sum of the instantaneous values
                                                                  #over the reporting period is reported
    ...    M55316C06001    >1    MAX_PSCELL_UE_1_ACT_SCELL_UL      #maximum number of "P(S)Cell UEs with 1 activated SCells in
                                                                  #UL" in sample time. "P(S)Cell UEs with 1 activated SCells
                                                                  #in UL" is calculated during the sample time. Calculated
                                                                  #value is then compared to previous sample value
    ...    M55316C15039    >1    PCELL_UE_1_ACT_SCELL_UL_SA       #Number of PCell UEs with 1 activated SA SCells in UL.
                                                                  #It measures instantaneous values by "sample interval",
                                                                  #and reports the sum of the instantaneous values over
                                                                  #the reporting period.
    ...    M55316C14001    >1    UL_RLC_PDU_VOL_RX_PRI_PATH       #Number of UL RLC PDU bytes received over the primary path
                                                                  #when UL carrier aggregation is configured for the UE.
                                                                  #It only includes received UL RLC Data PDUs. Every received
                                                                  #UL RLC Data PDU is counted regardless if it's a complete
                                                                  #or segmented PDU
    ...    M55316C14003    >1    UL_RLC_PDU_RX_PRI_PATH           #Number of UL RLC PDUs received over the primary path when
                                                                  #UL carrier aggregation is configured for the UE. It only
                                                                  #includes received UL RLC Data PDUs. Every received UL RLC
                                                                  #Data PDU is counted regardless if it's a complete or segmented PDU
    ...    M55310C02030    >1    RLC_PDU_VOL_RX_PRI_SA_CA         #This counter provides the UL data volume at SA PCell,
                                                                  #which shows traffic volume received through the primary path.
                                                                  #It doesn't include Control PDU bytes.
    ...    M55349C00025    >1    RLC_PDU_VOL_RX_SEC_SA_CA_FR1     #This counter provides the UL data volume at SA PCell,
                                                                  #which shows traffic volume received through the secondary
                                                                  #path for FR1 SA CA. It doesn't include Control PDU bytes.
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    files_path=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    ...    report_pm_counter=True

Verify Scell Related Counters
    ${pm_counter_file}=    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Verify Any Counters In All Files
    ...    M55118C10006    >1    UE_SCELL_1_CONF_SCELL_UL_SA      #Sum of samples for the total number of CA UEs in the current
                                                                  #cell configured as a UL SCell, while pegged in the secondary
                                                                  #cell, which have 1 configured UL SCell in UL;
    ...    M55139C01001    >1    GNB_DU_SCELL_ADMI_REQ_SA          #Total number of radio admission requests for the SCell before
                                                                  #the CA configuration on RRC. It's measured in the SCell in SA
                                                                  #mode in DU only;
    ...    M55139C01002    >1    GNB_DU_SCELL_ADMI_SUCC_SA         #Total number of successful radio admission requests for the
                                                                  #SCell before the CA configuration on RRC. It's measured in the
                                                                  #SCell in SA mode in DU only;
    ...    M55310C02032    >1    RLC_PDU_VOL_RX_SCELL_SA_CA       #This counter provides the UL data volume at SA SCell
                                                                  #for the UEs that use this cell as SCell for SA CA.
    ...    M55316C14004    >1    UL_RLC_PDU_RX_SEC_PATH           #Number of UL RLC PDUs received over the secondary path
                                                                  #when UL carrier aggregation is configured for the UE.
                                                                  #It only includes received UL RLC Data PDUs. Every received
                                                                  #UL RLC Data PDU is counted regardless if it's a complete
                                                                  #or segmented PDU;
    ...    M55316C14002    >1    UL_RLC_PDU_VOL_RX_SEC_PATH       #Number of UL RLC PDU bytes received over the secondary
                                                                  #path when UL carrier aggregation is configured for the UE.
                                                                  #It only includes received UL RLC Data PDUs. Every
                                                                  #received UL RLC Data PDU is counted regardless if it's a
                                                                  #complete or segmented PDU;
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    files_path=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    ...    report_pm_counter=True

Verify CB006449 AB B4 Cell_1 Counters
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Verify Any Counters In All Files
    ...    M55156C10007    5    MAX_UE_PCELL_1_CONF_SCEL_UL_SA    #Max CA UEs in the current cell configured as a PCell,
                                                                   #which have 1 configured SCell in UL
    ...    M55316C00032    1     SCELL_UL_SUSPEND_PCEL_POWLM_SA    #This counter is updated with the maximum number of SCell
                                                                   #UEs with 1 configured SCell in UL when the sample timer expires.
    ...    M55316C15016    1    SCELL_SUSP_RECOV_SA               #This counter shows the maximum of samples for total number of CA
                                                                   #UEs in the current cell configured as a PCell, which have 1
                                                                   #configured SCell in UL.
                                                                   #suspended in milliseconds for CA UEs when the current cell is
                                                                   #configured as a PCell.
                                                                   #released or recovered for a UE.

    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    files_path=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    ...    report_pm_counter=True

Verify CB006449 AB B4 Cell_2 Counters
    Get All Unpacked Full PM Counters Files Classical    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    Verify Any Counters In All Files
    ...    M55156C10007    5    MAX_UE_PCELL_1_CONF_SCEL_UL_SA    #Max CA UEs in the current cell configured as a PCell,
                                                                   #which have 1 configured SCell in UL
    ...    M55316C00032    1     SCELL_UL_SUSPEND_PCEL_POWLM_SA    #This counter is updated with the maximum number of SCell
                                                                   #UEs with 1 configured SCell in UL when the sample timer expires.
    ...    M55316C15016    1     SCELL_SUSP_RECOV_SA              #This counter shows the maximum of samples for total number of CA
                                                                   #UEs in the current cell configured as a PCell, which have
                                                                   #1 configured SCell in UL.
    ...    M55316C00001    >1    DUR_UL_SCELL_SCHED_SUSP           #This counter measures the time for which UL SCell scheduling was
                                                                   #suspended in milliseconds for CA UEs when the current cell is
                                                                   #configured as a PCell.
    ...    M55316C00002    1    DUR_UL_SCELL_SCHED_SUSP_DNOM       #This counter is incremented by 1 when suspended UL SCells are
                                                                   #released or recovered for a UE.

    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    files_path=${OUTPUT_DIR}/${TEST_NAME}/pmlogs
    ...    report_pm_counter=True


################### UE / CELL TRACES KEYWORDS ########################
Add Nestapx Prototcol Plugin To Tshark
     Load Tshark Bin Plugin    technology=5G

Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49151,49392" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    IF    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for 1778

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    IF   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    RETURN    ${preferences_exist}

Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Start Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=minimum
    ...           \ ifaces_to_trace=Uu,NG-C,Xn-C trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

Setup PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Start Tshark For Nsetapx
    ${tshark_alias_tcp}=     Start Tshark For Custom Interface
    ...                          eth_interface='eth3'
    ...                          log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                          log_filename_prefix='tcp_nsetapx'
    ...                          capture_filter='tcp'
    RETURN    ${tshark_alias_tcp}

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Verify Tcp Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_stop id=${ue_id} trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
    ...           \ trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${command}

################### MEASURMENT KEYWORDS ########################
Send A2 Event For S-Cell Release
    [Arguments]    ${ue_id}=1    ${scell}=1    ${scell_id}=1    ${get_ue_meas_cfg}=${True}
    ...            ${scell_rsrq}=1    ${scell_rsrp}=1    ${scell_sinr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A2 Scell Release With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    scell_id=${scell_id}
    ...    pass_regexp=${pass_regexp}
    ...    get_ue_meas_cfg=${get_ue_meas_cfg}
    ...    scell=${scell}
    ...    scell_rsrq=${scell_rsrq}
    ...    scell_rsrp=${scell_rsrp}
    ...    scell_sinr=${scell_sinr}

    Sleep    3s    reason=ensure A2 Event For S-Cell Release is sent

Send A1 Event For S-Cell Addition
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${scellTechnology}=FDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    scellTechnology=${scellTechnology}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    Sleep    3s    reason=ensure A1 event for S-Cell Addition is sent


Send A2 Event Related To Pcell
    [Arguments]    ${ue_id}    ${pcell_id}    ${srsrp_nr}=1    ${srsrq_nr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete    ${get_ue_meas_cfg}=${True}

    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    pass_regexp=${pass_regexp}
    ...    get_ue_meas_cfg=${get_ue_meas_cfg}
    ...    srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr}

    Sleep    3s    reason=ensure A2 event


Send A1 Event Related To Pcell
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${scellTechnology}=TDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    scellTechnology=${scellTechnology}
    ...    pass_regexp=${pass_regexp}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}

    Sleep    3s    reason=ensure A1 event

#################### BLER KEYWORDS #########################

Trigger Egate Command For Max Attenuation
    [Arguments]    ${ue_id}=1    ${scell}=1
    ${command_bler_prepare} =  catenate   SEPARATOR=
    ...           bler_testmode_nr profile_id=1 target_mcs=2 target_bler=0, 0, 0, 0.1, 0.5, 1, 5, 10,
    ...           \ 50, 95, 100, 100, 100, 100, 90, 95, 50, 10, 5, 1, 0.5, 0.1, 0, 0, 0 mcs_table=all
    ${command_bler_activate} =  catenate   SEPARATOR=
    ...           ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=bler profile_id=2 action=activate
    Execute Egate Command    cmd=${command_bler_prepare}
    Execute Egate Command    cmd=${command_bler_activate}

#################### COUNTERS KEYWORDS #########################

Check Counters Related To Scell Addition 3cc
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55138C02501    +1    GNB_SCELL_2_ADMI_REQ_SA
    ...    M55138C02502    +1    GNB_SCELL_2_ADMI_SUCC_SA
    ...    M55118C07004    +1    RRC_RECONF_ADD2DLSCELL_ATT_SA
    ...    M55118C07003    +1    RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...    M55118C07001    >1    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    M55118C07002    >0   UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C05508    0    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    M55118C07002    >0   UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

# TTI Traces
Start TTI Trace Collection
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/tti_trace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias    alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3

Stop TTI Trace Collection
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3    target_dir=${OUTPUTDIR}/${TESTNAME}/
    tcc.Teardown Collectors    names=l2stream3

# Throughput
Decrease nonGBR Data Throughput For UEs
    [Arguments]    ${ue_id}    ${pdu_session_range}
    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=dl
        Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=ul
    END

Establish Multiple PDU Sessions With Traffic
    [Arguments]    ${ue_id}    ${pdu_session_range}    ${throughput}=1mbps
    FOR    ${pdu_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}    pdu_id=${pdu_id}    nwslice=1    gw_id=${pdu_id}    direction=both    throughput=${throughput}
    END


Establish Multiple PDU Sessions With Additional Traffic
    [Arguments]    ${ue_id}    ${pdu_session_range}    ${throughput}    ${traffic_pdu_id}

    FOR    ${idx_id}    IN RANGE    1    ${pdu_session_range}
        Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}
        ...    pdu_id=${idx_id}
        ...    nwslice=1
        ...    gw_id=${idx_id}
        ...    direction=both
        ...    throughput=20mbps
    END

    FOR    ${idx_id}    IN RANGE    1    ${pdu_session_range}
        Start Data Traffic
        ...    ues=${ue_id}
        ...    direction=dl
        ...    pdu=${traffic_pdu_id}
        ...    throughput=${throughput}
        ...    traffic_id=${idx_id}
        Sleep    5s
    END

Start Additional Traffic
    [Arguments]    ${range}    ${ue_id}    ${throughput}    ${direction}
    FOR    ${index}    IN RANGE    2   ${range}
        Start Data Traffic
        ...    ues=${ue_id}
        ...    direction=${direction}
        ...    pdu=1
        ...    throughput=${throughput}
        ...    traffic_id=${index}
       sleep     5s
    END
    Sleep    30s    reason=Wait for SCell Activation

Assert UlDl Traffic On SCells
    # Sleep here is required due to the fact that sometimes, probing AP for throughput returns errors
    Sleep    20s
    Assert Ul Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=1    traffic=True
    Sleep    5s
    Assert Dl Traffic On Every Scell    ue_id=${UE2_CELL1}    scells_amount=2    traffic=True

# Admin Operations
Custom Setup Testline
    [Arguments]    ${scfc}    ${iphy}
    Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/backup_iphy.xml
    Get Scfc File    output_filepath=${CURDIR}/config/backup/initial_commissioning.xml
    Setup Test Line
    ...    iphy_xml_filepath=${CURDIR}/../config/${iphy}
    ...    scfc_filename=${scfc}
    ...    perform_testline_reset=${RESET_TL}
    ...    output_dirpath=${OUTPUT_DIR}/testline_prep

Roll Config Back
    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/backup/backup_iphy.xml
    Send Full Commissioning    input_filepath=${CURDIR}/config/backup/initial_commissioning.xml

# Egate Helper Keywords
Execute Long Egate Command
    [Arguments]    @{args}
    ${result}=    Catenate    @{args}
    Execute Egate Command    cmd=${result}
