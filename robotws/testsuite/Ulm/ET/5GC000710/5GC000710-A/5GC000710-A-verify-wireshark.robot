*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part verification
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${filter_RRC_reconfiguration}      (x2ap.procedureCode==27)&&(x2ap.X2AP_PDU==1)
${filter_RRC_reconfiguration_all}      (x2ap.procedureCode==27)
${filter_RRC_reconfiguration2}     (x2ap.procedureCode==29)&&(x2ap.X2AP_PDU==1)
${filter_RRC_reconfiguration2_all}     (x2ap.procedureCode==29)

${filter_UEContextRelease}         (x2ap.procedureCode==5)&&(ip.src==10.0.1.137)&&(ip.dst==${wts_GNB_X2_ADDR})
${filter_RRC_sgNBChangeRequired}   (x2ap.procedureCode==34)


@{t1_events_present}      eventA3   eventA5
@{t1_events_not_present}  eventA2
@{t1_rrc1_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2


@{t2_UE11_events_present}          eventA3   eventA5   eventA2
@{t2_UE11_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...          measId2-measObjectId1-reportConfigId2   measId3-measObjectId1-reportConfigId3

@{t2_UE12_events_present}          eventA3   eventA5
@{t2_UE12_events_not_present}      eventA2
@{t2_UE12_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2

@{t3_rrc1_events_present}      eventA3   eventA5   eventA2
@{t3_rrc1_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...          measId2-measObjectId1-reportConfigId2   measId3-measObjectId1-reportConfigId3

@{t3_rrc2_events_present}      eventA1   eventA3
@{t3_rrc2_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId4-measObjectId1-reportConfigId4   measId5-measObjectId2-reportConfigId5
@{t3_rrc2_remove_ReportConfigId}      3
@{t3_rrc2_remove_MeasId}      3

@{t3_rrc3_events_present}      eventA2
@{t3_rrc3_measId_measObjectId_reportConfigId_list}     measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId3-measObjectId1-reportConfigId3
@{t3_rrc3_remove_ReportConfigId}      4    5
@{t3_rrc3_remove_MeasId}      4    5

@{t4_rrc1_events_present}      eventA3   eventA5   eventA2
@{t4_rrc1_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...          measId2-measObjectId1-reportConfigId2   measId3-measObjectId1-reportConfigId3

@{t4_rrc2_events_present}      eventA1   eventA5
@{t4_rrc2_remove_ReportConfigId}      3
@{t4_rrc2_remove_MeasId}      3
@{t4_rrc2_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId4-measObjectId1-reportConfigId4   measId5-measObjectId2-reportConfigId5

@{t4_rrc3_events_present}      eventA3   eventA1
${t4_rrc3_events_present_twice}      eventA5
@{t4_rrc3_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId4-measObjectId1-reportConfigId4   measId5-measObjectId2-reportConfigId5

@{t5_rrc1_events_present}      eventA3   eventA5   eventA2
@{t5_rrc1_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1
...          measId2-measObjectId1-reportConfigId2   measId3-measObjectId1-reportConfigId3

@{t5_rrc2_events_present}      eventA1   eventA3
@{t5_rrc2_remove_ReportConfigId}      3
@{t5_rrc2_remove_MeasId}      3
@{t5_rrc2_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId4-measObjectId1-reportConfigId4   measId5-measObjectId2-reportConfigId5

@{t5_rrc3_events_present}      eventA5   eventA1
${t5_rrc3_events_present_twice}      eventA3
@{t5_rrc3_measId_measObjectId_reportConfigId_list}   measId1-measObjectId1-reportConfigId1   measId2-measObjectId1-reportConfigId2
...          measId4-measObjectId1-reportConfigId4   measId5-measObjectId2-reportConfigId5



*** Keywords ***


verify wireshark t1
    [Documentation]    [PRIVATE]    verify wireshark for default mobility profile test
    ...       :Autor: Sylvia Schneider
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    get all items from reportConfigToAddModList        ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present      @{t1_events_present}
    verify reportConfigToAddModList event not present  @{t1_events_not_present}

    get all items from measIdToAddModList          ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t1_rrc1_measId_measObjectId_reportConfigId_list}


verify wireshark t2
    [Documentation]    [PRIVATE]    verify wireshark for A2 with mobility test
    ...       :Autor: Sylvia Schneider
    Log To Console    \n-------verify wireshark from UE11
    generate pdml
    ...     folder=${resultDir}/UE11
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    get all items from reportConfigToAddModList    ${resultDir}/UE11/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present      @{t2_UE11_events_present}

    get all items from measIdToAddModList          ${resultDir}/UE11/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t2_UE11_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark from UE12
    generate pdml
    ...     folder=${resultDir}/UE12
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    get all items from reportConfigToAddModList    ${resultDir}/UE12/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present      @{t2_UE12_events_present}
    verify reportConfigToAddModList event not present  @{t2_UE12_events_not_present}

    get all items from measIdToAddModList          ${resultDir}/UE12/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t2_UE12_measId_measObjectId_reportConfigId_list}


verify wireshark t3
    [Documentation]    [PRIVATE]    verify wireshark for A1 with mobility test
    ...       :Autor: Sylvia Schneider
    Log To Console    \n-------verify wireshark 1st RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    get all items from reportConfigToAddModList    ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t3_rrc1_events_present}

    get all items from measIdToAddModList          ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t3_rrc1_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 2nd RRC reconfiguration message
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
    verify reportConfigToRemoveList ReportConfigId present   @{t3_rrc2_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t3_rrc2_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{t3_rrc2_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t3_rrc2_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 3rd RRC reconfiguration message
    get all items from reportConfigToRemoveList         ${resultDir}/X2_RRC_reconfiguration_2.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{t3_rrc3_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_2.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t3_rrc3_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration_2.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{t3_rrc3_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_2.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t3_rrc3_measId_measObjectId_reportConfigId_list}


verify wireshark t4
    [Documentation]    [PRIVATE]    verify wireshark for no SPID test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark events of reportConfigToAddModList for 1st RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    ${frames}    count messages in pdml file       ${resultDir}/X2_RRC_reconfiguration.xml
    create single pdml file
    ...    folder=${resultDir}
    ...    pcap_file=wireshark.pcap
    ...    pdml_file=X2_RRC_reconfiguration
    ...    filter=${filter_RRC_reconfiguration}
    ...    frames=${frames}

    Log To Console    \n-------verify wireshark 1st RRC reconfiguration message
    get all items from reportConfigToAddModList    ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t4_rrc1_events_present}

    get all items from measIdToAddModList          ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t4_rrc1_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 2nd RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration2}

    get all items from reportConfigToRemoveList         ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{t4_rrc2_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t4_rrc2_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{t4_rrc2_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t4_rrc2_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 3rd RRC reconfiguration message, SgNBChangeRequired
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration_CR.xml
    ...     filter=${filter_RRC_sgNBChangeRequired}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_CR.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present        @{t4_rrc3_events_present}    amount_of_double_events=${2}
    verify reportConfigToAddModList event twice present  ${t4_rrc3_events_present_twice}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_CR.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t4_rrc3_measId_measObjectId_reportConfigId_list}

    verify SgNBChangeRequired successful message present
    verify UEContextRelease message present


verify wireshark t5
    [Documentation]    [PRIVATE]    verify wireshark for interGnb_interFreq_PSCell_change test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark events of reportConfigToAddModList for 1st RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration}
    ${frames}    count messages in pdml file       ${resultDir}/X2_RRC_reconfiguration.xml
    create single pdml file
    ...    folder=${resultDir}
    ...    pcap_file=wireshark.pcap
    ...    pdml_file=X2_RRC_reconfiguration
    ...    filter=${filter_RRC_reconfiguration}
    ...    frames=${frames}

    Log To Console    \n-------verify wireshark 1st RRC reconfiguration message
    get all items from reportConfigToAddModList    ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t5_rrc1_events_present}

    get all items from measIdToAddModList          ${resultDir}/X2_RRC_reconfiguration_1.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t5_rrc1_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 2nd RRC reconfiguration message
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration.xml
    ...     filter=${filter_RRC_reconfiguration2}

    get all items from reportConfigToRemoveList         ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToRemoveList
    verify reportConfigToRemoveList ReportConfigId present   @{t5_rrc2_remove_ReportConfigId}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present  @{t5_rrc2_events_present}

    get all items from measIdToRemoveList               ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToRemoveList
    verify measIdToRemoveList MeasId present   @{t5_rrc2_remove_MeasId}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t5_rrc2_measId_measObjectId_reportConfigId_list}

    Log To Console    \n-------verify wireshark 3rd RRC reconfiguration message, SgNBChangeRequired
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration_CR.xml
    ...     filter=${filter_RRC_sgNBChangeRequired}

    get all items from reportConfigToAddModList         ${resultDir}/X2_RRC_reconfiguration_CR.xml
    Log To Console    \nchecking reportConfigToAddModList
    verify reportConfigToAddModList event present        @{t5_rrc3_events_present}    amount_of_double_events=${2}
    verify reportConfigToAddModList event twice present  ${t5_rrc3_events_present_twice}

    get all items from measIdToAddModList               ${resultDir}/X2_RRC_reconfiguration_CR.xml
    Log To Console    \nchecking measIdToAddModList
    verify measIdToAddModList measId measObjectId reportConfigId present    @{t5_rrc3_measId_measObjectId_reportConfigId_list}

    verify SgNBChangeRequired successful message present
    verify UEContextRelease message present


verify wireshark t6
    [Documentation]    [PRIVATE]    verify wireshark for SgNB_modification test
    ...       :Autor: Sylvia Schneider
    FOR   ${operation}   IN   attach   modify1   unassign   modify2
        Log To Console    \nwireshark verify for SPID ${operation} started
        Run Keyword    create xml from wireshark    ${operation}
        Run Keyword    verify xml ${operation}
    END


verify SgNBChangeRequired successful message present
    [Documentation]    [PRIVATE]    verify SgNBChangeRequired Confirm successful message present
    ...       :Autor: Sylvia Schneider
    Log To Console    \nchecking that 1 SgNBChangeRequired Confirm successful present
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_RRC_reconfiguration_CR_confirm.xml
    ...     filter=${filter_RRC_sgNBChangeRequired}&&(x2ap.X2AP_PDU==1)
    ${pdml_xml}    parse xml    ${resultDir}/X2_RRC_reconfiguration_CR_confirm.xml
    ${number_of_SgNBChangeConfirm}  Get Element count  ${pdml_xml}
    ...    .//field[@showname="successfulOutcome"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal    ${number_of_SgNBChangeConfirm}    ${1}
    ...     Wrong number of SgNBChangeConfirm messages with showname="successfulOutcome"


verify UEContextRelease message present
    [Documentation]    [PRIVATE]    verify UEContextRelease message present
    ...       :Autor: Sylvia Schneider
    Log To Console    \nchecking that 1 UEContextRelease message present
    generate pdml
    ...     folder=${resultDir}
    ...     pcap_file=wireshark.pcap
    ...     pdml_file=X2_UEContextRelease.xml
    ...     filter=${filter_UEContextRelease}
    ${pdml_xml}    parse xml    ${resultDir}/X2_UEContextRelease.xml
    ${number_of_UEContextRelease}  Get Element count  ${pdml_xml}
    ...    .//field[@showname="UEContextRelease"]
    Run Keyword And Continue On Failure
    ...     Should Be Equal    ${number_of_UEContextRelease}    ${1}
    ...     Wrong number of UEContextRelease messages with showname="UEContextRelease"

create xml from wireshark
    [Arguments]    ${operation}
    ${filter}  Set Variable If  '${operation}'=='modify1' or '${operation}'=='modify2'
    ...             ${filter_RRC_reconfiguration2_all}
    ...             ${filter_RRC_reconfiguration_all}
    setup tshark    eth1
    Log To Console    create xml file for ${operation} with filter "${filter}"
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/part_${operation}/X2_part.xml
    ...   packet_filter=${filter}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/part_${operation}/wireshark.pcap
    [Teardown]    teardown tshark


verify xml attach
    Log To Console    verify that sgNB addition message contains field x2ap.SubscriberProfileIDforRFP with value "111"
    ${pdml_xml}    parse xml    ${resultDir}/part_attach/X2_part.xml
    ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    SgNBAdd_Mod_SPID
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    111
    ...    xpath=${xpath_param}
    verify successful acknowledge    ${pdml_xml}


verify xml modify${run}
    Log To Console    verify run${run} that sgNB modify message contains field x2ap.SubscriberProfileIDforRFP with value "222"
    ${pdml_xml}    parse xml    ${resultDir}/part_modify${run}/X2_part.xml
    ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    SgNBAdd_Mod_SPID
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    show
    ...    222
    ...    xpath=${xpath_param}
    verify successful acknowledge    ${pdml_xml}


verify xml unassign
    Log To Console    verify that no field x2ap.SubscriberProfileIDforRFP present
    ${pdml_xml}    parse xml    ${resultDir}/part_unassign/X2_part.xml
    ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    SgNBAdd_Mod_SPID
    Run Keyword And Continue On Failure   Element Should Not Exist    ${pdml_xml}
    ...    xpath=${xpath_param}
    ...    message=Error SubscriberProfileIDforRFP found
    verify successful acknowledge    ${pdml_xml}


verify successful acknowledge
    [Arguments]    ${pdml_xml}
    Log To Console    verify that successful outcome message present
    ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    successfulOutcome
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    successfulOutcome
    ...    xpath=${xpath_param}

