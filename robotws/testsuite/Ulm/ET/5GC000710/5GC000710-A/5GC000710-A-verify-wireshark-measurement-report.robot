*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part verification measurements reports
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
${xpath_successful_outcome}           .//field[@name="x2ap.successfulOutcome_element"]

${xpath_reportConfigToAddModList_1}   field[@name="nr-rrc.reportConfigToAddModList"]
${xpath_reportConfigToAddModList_2}   field[@showname="ReportConfigToAddMod"]/field[@name="nr-rrc.reportConfig"]/field[@showname="reportConfigNR"]/
${xpath_reportConfigToAddModList_3}   field[@name="nr-rrc.reportType"]/field[@showname="eventTriggered"]/field[@name="nr-rrc.eventId"]

${xpath_measIdToAddModList_1}   field[@name="nr-rrc.measIdToAddModList"]
${xpath_measIdToAddModList_2}   field[@showname="MeasIdToAddMod"]

${xpath_reportConfigToRemoveList_1}   field[@name="nr-rrc.reportConfigToRemoveList"]
${xpath_reportConfigToRemoveList_2}   field[@name="nr-rrc.ReportConfigId"]

${xpath_measIdToRemoveList_1}   field[@name="nr-rrc.measIdToRemoveList"]
${xpath_measIdToRemoveList_2}   field[@name="nr-rrc.MeasId"]

${xpath_measObjectToRemoveList_1}   field[@name="nr-rrc.measObjectToRemoveList"]
${xpath_measObjectToRemoveList_2}   field[@name="nr-rrc.MeasObjectId"]


*** Keywords ***

generate pdml
    [Documentation]    [PRIVATE]    generate pdml file from wireshark using filter
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${folder}   ${pcap_file}   ${pdml_file}    ${filter}
    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${folder}/${pdml_file}
    ...   packet_filter=${filter}
    ...   output_type=pdml
    ...   pcap_file_path=${folder}/${pcap_file}
    [Teardown]   teardown tshark


count messages in pdml file
    [Documentation]    [PRIVATE]    count messages in pdml file
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number of messages}   Get Element Count    ${pdml_xml}    xpath=.//field[@name="frame.number"]
    ${elements}   get elements    ${pdml_xml}    xpath=.//proto[@name="frame"]
    log list    ${elements}
    ${number of messages}   Get Length    ${elements}
    ${frames}   create list
    FOR    ${item}    IN RANGE       ${number of messages}
        ${frame}   get element attribute    ${elements}[${item}]    show      xpath=.//field[@name="frame.number"]
        Append To List     ${frames}   ${frame}
    END
    RETURN   ${frames}


create single pdml file
    [Documentation]    [PRIVATE]    create single pdml file using filter
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${folder}   ${pcap_file}   ${pdml_file}    ${filter}    ${frames}
    setup tshark    eth1
    ${file_number}    set variable    ${0}
    FOR    ${item}    IN    @{frames}
         ${file_number}   evaluate   ${file_number}+1
         read_pcap_and_save_to_file
         ...   filename=${folder}/${pdml_file}_${file_number}.xml
         ...   packet_filter=${filter}&&(frame.number==${item})
         ...   output_type=pdml
         ...   pcap_file_path=${folder}/${pcap_file}
    END
    [Teardown]   teardown tshark


get all items from reportConfigToAddModList
    [Documentation]    [PRIVATE]    get all items from reportConfigToAddModList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number_items_reportConfigToAddModList}    get element attribute    ${pdml_xml}
    ...    show
    ...    xpath=.//field[@name="nr-rrc.reportConfigToAddModList"]
    @{reportConfigToAddModList_events}    create List
    FOR    ${item}    IN RANGE   ${number_items_reportConfigToAddModList}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath_reportConfigToAddModList_1}     field[@show="Item ${item}"]
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_reportConfigToAddModList_2}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_reportConfigToAddModList_3}
        ${event}    get element attribute    ${pdml_xml}    showname      xpath=.//${xpath}
        @{parts}    split string    ${event}    ${SPACE}
        Append to List    ${reportConfigToAddModList_events}    ${parts}[1]
    END
    Log List             ${reportConfigToAddModList_events}
    Set test variable    ${reportConfigToAddModList_events}


get all items from measIdToAddModList
    [Documentation]    [PRIVATE]    get all items from measIdToAddModList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number_items_measIdToAddModList}    get element attribute    ${pdml_xml}
    ...    show
    ...    xpath=.//field[@name="nr-rrc.measIdToAddModList"]
    ${measIdToAddModList}    create List

    FOR    ${item}    IN RANGE   ${number_items_measIdToAddModList}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath_measIdToAddModList_1}     field[@show="Item ${item}"]
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_measIdToAddModList_2}
        ${measId}    get element attribute    ${pdml_xml}    show      xpath=.//${xpath}/field[@name="nr-rrc.measId"]
        ${measObjectId}    get element attribute    ${pdml_xml}    show      xpath=.//${xpath}/field[@name="nr-rrc.measObjectId"]
        ${reportConfigId}    get element attribute    ${pdml_xml}    show      xpath=.//${xpath}/field[@name="nr-rrc.reportConfigId"]
        Append to List    ${measIdToAddModList}    measId${measId}-measObjectId${measObjectId}-reportConfigId${reportConfigId}
    END
    Log List             ${measIdToAddModList}
    Set test variable    ${measIdToAddModList}


get all items from reportConfigToRemoveList
    [Documentation]    [PRIVATE]    get all items from reportConfigToRemoveList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number_items_reportConfigToRemoveList}    get element attribute    ${pdml_xml}
    ...    show
    ...    xpath=.//field[@name="nr-rrc.reportConfigToRemoveList"]
    ${reportConfigToRemoveList}    create List

    FOR    ${item}    IN RANGE   ${number_items_reportConfigToRemoveList}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath_reportConfigToRemoveList_1}     field[@show="Item ${item}"]
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_reportConfigToRemoveList_2}

        ${ReportConfigId}    get element attribute    ${pdml_xml}    showname      xpath=.//${xpath}
        @{parts}    split string    ${ReportConfigId}    ${SPACE}
        Append to List    ${reportConfigToRemoveList}    ${parts}[1]
    END
    Log List             ${reportConfigToRemoveList}
    Set test variable    ${reportConfigToRemoveList}


get all items from measIdToRemoveList
    [Documentation]    [PRIVATE]    get all items from measIdToRemoveList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number_items_measIdToRemoveList}    get element attribute    ${pdml_xml}
    ...    show
    ...    xpath=.//field[@name="nr-rrc.measIdToRemoveList"]
    ${measIdToRemoveList}    create List

    FOR    ${item}    IN RANGE   ${number_items_measIdToRemoveList}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath_measIdToRemoveList_1}     field[@show="Item ${item}"]
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_measIdToRemoveList_2}

        ${MeasId}    get element attribute    ${pdml_xml}    showname      xpath=.//${xpath}
        @{parts}    split string    ${MeasId}    ${SPACE}
        Append to List    ${measIdToRemoveList}    ${parts}[1]
    END
    Log List             ${measIdToRemoveList}
    Set test variable    ${measIdToRemoveList}


get all items from measObjectToRemoveList
    [Documentation]    [PRIVATE]    get all items from measObjectToRemoveList
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${pdml_xml_file}
    ${pdml_xml}    parse xml    ${pdml_xml_file}
    ${number_items_measObjectToRemoveList}    get element attribute    ${pdml_xml}
    ...    show
    ...    xpath=.//field[@name="nr-rrc.measObjectToRemoveList"]
    ${measObjectToRemoveList}    create List

    FOR    ${item}    IN RANGE   ${number_items_measObjectToRemoveList}
        ${xpath}   Catenate  SEPARATOR=/   ${xpath_measObjectToRemoveList_1}     field[@show="Item ${item}"]
        ${xpath}   Catenate  SEPARATOR=/   ${xpath}    		${xpath_measObjectToRemoveList_2}

        ${MeasObjectId}    get element attribute    ${pdml_xml}    showname      xpath=.//${xpath}
        @{parts}    split string    ${MeasObjectId}    ${SPACE}
        Append to List    ${measObjectToRemoveList}    ${parts}[1]
    END
    Log List             ${measObjectToRemoveList}
    Set test variable    ${measObjectToRemoveList}


verify reportConfigToAddModList event present
    [Arguments]    @{event_list}  ${amount_of_double_events}=${0}
    FOR   ${event}   IN      @{event_list}
       Log To Console    check that ${event} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${reportConfigToAddModList_events}    ${event}   ${event} not present
    END
    ${length_predefined_list}    get length    ${event_list}
    ${length_predefined_list}    evaluate    ${length_predefined_list}+${amount_of_double_events}
    ${lenght_actual_list}        get length    ${reportConfigToAddModList_events}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_predefined_list}     ${lenght_actual_list}
    ...   number of events in reportConfigToAddModList incorrect


verify reportConfigToAddModList event not present
    [Arguments]    @{event_list}
    FOR   ${event}   IN      @{event_list}
       Log To Console    check that ${event} not present
       Run Keyword And Continue On Failure   List Should not Contain Value   ${reportConfigToAddModList_events}    ${event}   ${event} present
    END


verify measIdToAddModList measId measObjectId reportConfigId present
    [Arguments]    @{measId_measObjectId_reportConfigId_list}
    FOR   ${item}   IN      @{measId_measObjectId_reportConfigId_list}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${measIdToAddModList}    ${item}   ${item} not present
    END
    ${length_predefined_list}    get length    ${measId_measObjectId_reportConfigId_list}
    ${lenght_actual_list}        get length    ${measIdToAddModList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_predefined_list}     ${lenght_actual_list}
    ...   number of events in measIdToAddModList incorrect


verify reportConfigToRemoveList ReportConfigId present
    [Arguments]    @{remove_ReportConfigId_list}
    FOR   ${item}   IN      @{remove_ReportConfigId_list}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${reportConfigToRemoveList}   ${item}   ReportConfigId: ${item} not present
    END
    ${length_predefined_list}    get length    ${remove_ReportConfigId_list}
    ${lenght_actual_list}        get length    ${reportConfigToRemoveList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_predefined_list}     ${lenght_actual_list}
    ...   number of events in reportConfigToRemoveList incorrect


verify measIdToRemoveList MeasId present
    [Arguments]    @{remove_MeasId_list}
    FOR   ${item}   IN      @{remove_MeasId_list}
       Log To Console    check that ${item} present
       Run Keyword And Continue On Failure   List Should Contain Value   ${measIdToRemoveList}    ${item}   MeasId: ${item} not present
    END
    ${length_predefined_list}    get length    ${remove_MeasId_list}
    ${lenght_actual_list}        get length    ${measIdToRemoveList}
    Run Keyword And Continue On Failure
    ...   Should Be Equal As Integers    ${length_predefined_list}     ${lenght_actual_list}
    ...   number of events in measIdToRemoveList incorrect


verify reportConfigToAddModList event twice present
    [Arguments]    ${events_present_twice}
    ${number_Of_events}    Count Values In List    ${reportConfigToAddModList_events}   ${events_present_twice}
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${number_Of_events}   ${2}   error-expected 2 ${events_present_twice}
