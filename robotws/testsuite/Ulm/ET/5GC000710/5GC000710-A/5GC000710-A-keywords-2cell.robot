*** Settings ***
Documentation   This is a keyword file for 5GC000710-A-2cell, part keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${filter_RRC_reconfiguration}      (x2ap.procedureCode==27)&&(x2ap.X2AP_PDU==1)
${filter_RRC_reconfiguration2}     (x2ap.procedureCode==29)&&(x2ap.X2AP_PDU==1)
${filter_HO}                       (x2ap.procedureCode == 30)&&(x2ap.radioNetwork == 0)

@{gnbAdd_events_present}      eventA3   eventA5   eventA2   eventA2
@{gnbAdd_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...          measId2-measObjectId1-reportConfigId2   measId3-measObjectId1-reportConfigId3
...          measId4-measObjectId1-reportConfigId4
@{rrc1_events_present}      eventA1

@{rrc1_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...                                               measId2-measObjectId1-reportConfigId2
...                                               measId4-measObjectId1-reportConfigId4
...                                               measId5-measObjectId1-reportConfigId5
...                                               measId6-measObjectId2-reportConfigId1
@{rrc1_remove_ReportConfigId}      3
@{rrc1_remove_MeasId}      3

@{rrc4_events_present}      eventA1   eventA5

@{rrc4_measId_measObjectId_reportConfigId_list}     measId3-measObjectId2-reportConfigId2
...                                                 measId6-measObjectId2-reportConfigId1
...                                                 measId8-measObjectId2-reportConfigId4
...                                                 measId1-measObjectId2-reportConfigId5
...                                                 measId2-measObjectId1-reportConfigId6

@{rrc4_remove_ReportConfigId}        3
@{rrc4_remove_MeasId}        7

@{rrc1_HO_events_present}      eventA2
@{rrc1_HO_measId_measObjectId_reportConfigId_list}     measId6-measObjectId2-reportConfigId1
...                                                    measId3-measObjectId2-reportConfigId2
...                                                    measId7-measObjectId2-reportConfigId3
...                                                    measId8-measObjectId2-reportConfigId4
@{rrc1_HO_remove_ReportConfigId}      5
@{rrc1_HO_remove_MeasId}      1    2    4   5

@{rrc2_HO_events_present}      eventA2
@{rrc2_HO_measId_measObjectId_reportConfigId_list}     measId4-measObjectId1-reportConfigId1
...                                                    measId5-measObjectId1-reportConfigId2
...                                                    measId7-measObjectId1-reportConfigId3
...                                                    measId9-measObjectId1-reportConfigId4
@{rrc2_HO_remove_ReportConfigId}        5   6
@{rrc2_HO_remove_MeasId}        1    2    3    6   8


*** Keywords ***

Create ips for simulated gnb 2 cell config
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3, 10.0.1.12, 10.0.1.102-10.0.1.106, 10.0.1.122, 10.0.1.123
    FOR   ${ip}  IN  12  102  104  104  105  106  122  123
       Configure IP on VM    ip=10.0.1.${ip}     interface=eth3
    END


update gscn in iphy file
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Sylvia Schneider
    Log To Console    setting GSCN to value 7995 in /ffs/run/simmode/new_iphy.xml
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd0}    Replace String Using Regexp    ${all_parts}[0]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>
    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7880<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</RE>   ${upd0}                    ${upd1}
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]

    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File    ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}



prepare counters and expected values 2 cell config
    [Documentation]    [PRIVATE]    set expected counter values for Intra-gNB PS cell change test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00002_1}    NRMOP_NSA_PROFILE_SELECTED_02      1    ${cell1_distName}   NRMOP
    set test variable    @{M55157C00003_1}    NRMOP_NSA_PROFILE_SELECTED_03      1    ${cell1_distName}   NRMOP
    set test variable    @{M55157C00002_2}    NRMOP_NSA_PROFILE_SELECTED_02      0    ${cell2_distName}   NRMOP
    set test variable    @{M55157C00003_2}    NRMOP_NSA_PROFILE_SELECTED_03      1    ${cell2_distName}   NRMOP




send A2 measurement report with srsrp
    [Documentation]    [PRIVATE]   send A2 measurement report with srsrp
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${meas_id}:   measurement id
    [Arguments]   ${ue_id}   ${meas_id}
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A2 srsrp_nr=30 meas_id=${meas_id} id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check for SgNBModificationRequestAcknowledge
    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    pass_regexp=SgNBModificationRequestAcknowledge
    ...    alias=ap_egate


send A2 measurement report with srsrp and srsrq
    [Documentation]    [PRIVATE]   send A2 measurement report with srsrp and srsrq
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${srsrq_nr}:  srsrq_nr
    [Arguments]    ${ue_id}   ${srsrq_nr}
    Sleep    2s
    ${cmd}    set variable    ue_measurement_send_nr event=A2 srsrp_nr=30 srsrq_nr=${srsrq_nr} meas_id=7 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           alias=ap_egate


send A2 measurement report with srsrp and srsrq and check
    [Documentation]    [PRIVATE]   send A2 measurement report with srsrp and srsrq
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    ...     :param ${srsrq_nr}:  srsrq_nr
    [Arguments]    ${ue_id}   ${srsrq_nr}
    Sleep    2s
    ${cmd}    set variable    ue_measurement_send_nr event=A2 srsrp_nr=30 srsrq_nr=${srsrq_nr} meas_id=7 id=${ue_id}
    Log To Console    execute on wts: ${cmd}
    Log To Console    and check for SgNBModificationRequestAcknowledge
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=SgNBModificationRequestAcknowledge
    ...           alias=ap_egate


send A3 measurement report for HO to cell2
    [Documentation]    [PRIVATE]   send A2 measurement report with srsrp phycell_id nrsrp_nr
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    [Arguments]   ${ue_id}    ${phycell_id}=51
    Sleep    2s
    ${cmd}   set variable   ue_measurement_send_nr event=A3 srsrp_nr=50 phycell_id=${phycell_id} nrsrp_nr=100 meas_id=6 id=${ue_id}
    Log To Console
    ...    execute on wts: ${cmd}
    Log To Console    and check for "Proxy (eNB 2 cell 2) reported successful RA"
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=Proxy .eNB 2 cell 2. reported successful RA
    ...           alias=ap_egate


send A5 measurement report no HO triggered
    [Documentation]    [PRIVATE]   send A5 measurement report no HO triggered, nrsrq is below threshold
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    [Arguments]   ${ue_id}    ${phycell_id}=50
    Sleep    2s
    ${cmd}    set variable
    ...   ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=29 meas_id=2 id=${ue_id}
    Log To Console
    ...    execute on wts: ${cmd}
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           alias=ap_egate


send A5 measurement report for HO to cell1
    [Documentation]    [PRIVATE]   send A5 measurement report for HO to cell1
    ...     :Autor: Sylvia Schneider
    ...     :param ${ue_id}:     number of UE
    [Arguments]   ${ue_id}    ${phycell_id}=50
    Sleep    2s
    ${cmd}    set variable
    ...   ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=${phycell_id} nrsrp_nr=100 nrsrq_nr=32 meas_id=2 id=${ue_id}
        Log To Console
    ...    execute on wts: ${cmd}
    Log To Console    and check for "Proxy (eNB 2 cell 1) reported successful RA"
    ute_wtssim.execute egate command and wait for data
    ...           cmd=${cmd}
    ...           pass_regexp=Proxy .eNB 2 cell 1. reported successful RA
    ...           alias=ap_egate


send enb_endc_param to disable allowed_bc_list_mrdc
    [Documentation]    [PRIVATE]   send enb_endc_param to disable allowed_bc_list_mrdc
    ...     :Autor: Sylvia Schneider
    ${cmd}    Set Variable   enb_endc_param id=1 serving_cell_index_range_scg=0:0 allowed_bc_list_mrdc=disable
    Log To Console   execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...           cmd=${cmd}
    ...           alias=ap_egate


get mcc mnc tac version from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    parse XML    ${P_ORIG_SCF}
    ${mcc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    set suite variable   ${mcc_SCF}
    Log To Console    set suite variable mcc_SCF to value: ${mcc_SCF}
    ${mnc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    set suite variable   ${mnc_SCF}
    Log To Console    set suite variable mnc_SCF to value: ${mnc_SCF}
    ${mnclenght_SCF}    get element text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    set suite variable   ${mnclenght_SCF}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght_SCF}
    ${fiveGsTac_SCF}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    set suite variable   ${fiveGsTac_SCF}
    Log To Console    set suite variable fiveGsTac_SCF to value: ${fiveGsTac_SCF}
    ${version_SCF}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    set suite variable   ${version_SCF}
    Log To Console    set suite variable version_SCF to value: ${version_SCF}


collect pm file and verify counter values 2 cell config
    [Documentation]    [PRIVATE]    verify expected counter values
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    Log To Console    \nverify counters for cell1
    &{dict}    Create Dictionary    M55157C00002    ${M55157C00002_1}
    ...                             M55157C00003    ${M55157C00003_1}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END
    Log To Console    verify counters for cell2
    &{dict}    Create Dictionary    M55157C00002    ${M55157C00002_2}
    ...                             M55157C00003    ${M55157C00003_2}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


verify wireshark 2 cell config
    [Documentation]    [PRIVATE]    verify wireshark 2 cell config
    ...       :Autor: Sylvia Schneider
    Log To Console    \n-------verify wireshark RRC reconfiguration message from SgNBAdditionRequest
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    get all items from reportConfigToAddModList        ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present      @{gnbAdd_events_present}

    get all items from measIdToAddModList          ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{gnbAdd_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 1st RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration2}
    ${frames}    count messages in pdml file       ${resultDir}/X2_RRC_reconfiguration.xml
    create single pdml file
    ...    folder=${resultDir}
    ...    pcap_file=wireshark.pcap
    ...    pdml_file=X2_RRC_reconfiguration
    ...    filter=${filter_RRC_reconfiguration2}
    ...    frames=${frames}

    get all items from reportConfigToRemoveList         ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{rrc1_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{rrc1_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{rrc1_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{rrc1_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 4th RRC reconfiguration message
    get all items from reportConfigToRemoveList         ${resultDir}/X2_RRC_reconfiguration_4.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{rrc4_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_4.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{rrc4_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration_4.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{rrc4_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_4.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{rrc4_measId_measObjectId_reportConfigId_list}


    Log To Console    \n-------verify wireshark 1st HO reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_HO_RRC_reconfiguration.xml
    ...     filter=${filter_HO}
    ${frames}    count messages in pdml file       ${resultDir}/X2_HO_RRC_reconfiguration.xml
    create single pdml file
    ...    folder=${resultDir}
    ...    pcap_file=wireshark.pcap
    ...    pdml_file=X2_HO_RRC_reconfiguration
    ...    filter=${filter_HO}
    ...    frames=${frames}

    get all items from reportConfigToRemoveList         ${resultDir}/X2_HO_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{rrc1_HO_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_HO_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{rrc1_HO_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_HO_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{rrc1_HO_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_HO_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{rrc1_HO_measId_measObjectId_reportConfigId_list}



    Log To Console    \n-------verify wireshark 1st HO reconfiguration message
    get all items from reportConfigToRemoveList         ${resultDir}/X2_HO_RRC_reconfiguration_2.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{rrc2_HO_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_HO_RRC_reconfiguration_2.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{rrc2_HO_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_HO_RRC_reconfiguration_2.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{rrc2_HO_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_HO_RRC_reconfiguration_2.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{rrc2_HO_measId_measObjectId_reportConfigId_list}
