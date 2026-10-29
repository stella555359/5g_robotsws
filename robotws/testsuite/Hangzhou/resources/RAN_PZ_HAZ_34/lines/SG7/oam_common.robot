*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON OAM keywords

Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library   taf.selenium.gnb.oam.core    WITH NAME      selenium_core
Library   Collections
Library   OperatingSystem
Library   DateTime
Library    taf.sw.nrdim    WITH NAME    NRDIM

Library   String
Library   XML   True
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library           taf.hw.rf_attenuator    WITH NAME    att
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Library           taf.analyzer.pcap   WITH NAME    parser


*** Keywords ***
UUF Get RMOD SN Cell Mapping From Full SCF
    [Arguments]   ${source}
    Log To Console   ${EMPTY}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    &{rmod_cell_mapping}   Create Dictionary
    ${total_cells_dn}    Create List
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        # Log To Console   serialNumber: ${serialNumber}
        # Log To Console   configDN: ${configDN}
        ${cell_dn_list}   Get Cell DN List   source=${source}   configDN=${configDN}
#        ${cell_param}   Create Dictionary   configDN=${configDN}   cellDN=${cell_dn_dict}
        ${total_cells_dn}    Combine Lists    ${total_cells_dn}    ${cell_dn_list}
        Set To Dictionary   ${rmod_cell_mapping}   ${serialNumber}=${cell_dn_list}
    END
    # Log To Console   ${rmod_serial_mapping}
    [Return]   ${rmod_cell_mapping}    len(${total_cells_dn})

Get Cell DN List
    [Arguments]   ${source}   ${configDN}

    ${narrorband_eles}
    ...   XML.Get Elements   ${source}
    ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="cellTechnology" and text()="NB-IoT-FDD"]
    ${narrorband_celldn_list}    Create List
    FOR   ${narrorband_ele}   IN   @{narrorband_eles}
         ${narrorband_cell_dn}   XML.Get Element Attribute   ${narrorband_ele}   distName   xpath=..
         Append to list    ${narrorband_celldn_list}    ${narrorband_cell_dn}
    END

    ${channel_list_xpath}   Catenate   SEPARATOR=
    ...   cmData/managedObject[@class="com.nokia.srbts.mnl:CHANNEL"]/
    ...   p[(@name="antlDN" or @name="resourceDN") and contains(text(),'${configDN}/')]
    ${channel_list}   XML.Get Elements   ${source}   xpath=${channel_list_xpath}
    # Log To Console   ${rmod_r_list}
    @{nr_cell_dn_list}   Create List
    @{lte_cell_dn_list}   Create List
    FOR   ${channel}   IN   @{channel_list}
        # Log To Console   ${antlDN}
        ${local_cell}   XML.Get Element Attribute   ${channel}   distName   xpath=..
        ${local_cell}   Get Regexp Matches   ${local_cell}   CELLMAPPING-(.*)/(.*)/CHANNELGROUP   2
        # Log To Console   ${local_cell}
        Continue For Loop If   len(${local_cell})==0
        Continue For Loop If   '${local_cell[0].find("LCELNR")}'=='-1' and '${local_cell[0].find("LCELL")}'=='-1'
        ${local_cell}   Set Variable   ${local_cell[0]}
        ${local_cell_index}   Split String   ${local_cell}   -
        ${local_cell_index}   Set Variable   ${local_cell_index[1]}

        ${lcrid_ele}   Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]/p[@name="lcrId" and text()="${local_cell_index}"]
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   XML.Get Element   ${source}
        ...      xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]/p[@name="lcrId" and text()="${local_cell_index}"]


        ${cell_dn}   XML.Get Element Attribute   ${lcrid_ele}   distName   xpath=..
        # Log To Console   ${cell_dn}

        ${status}   run keyword and return status    List Should Contain Value    ${narrorband_celldn_list}      ${cell_dn}
        Continue For Loop If   ${status}

        Run Keyword If   '${local_cell.find("LCELNR")}'!='-1'
        ...   Append To List   ${nr_cell_dn_list}   ${cell_dn}
        ...   ELSE IF   '${local_cell.find("LCELL")}'!='-1'
        ...   Append To List   ${lte_cell_dn_list}   ${cell_dn}
    END
    ${nr_cell_dn_list}   Remove Duplicates   ${nr_cell_dn_list}
    ${lte_cell_dn_list}   Remove Duplicates   ${lte_cell_dn_list}
#    &{cell_dn_dict}   Create Dictionary   NR=${nr_cell_dn_list}   LTE=${lte_cell_dn_list}
    ${cell_dn_list}   Combine Lists  ${nr_cell_dn_list}    ${lte_cell_dn_list}
    # Log To Console   ${nr_cell_index_list}
    # Log To Console   ${lte_cell_index_list}
    # Log To Console   ${cell_dn_dict}

    # Log To Console   --------------------------------
    [Return]   ${cell_dn_list}

UUF Get RMOD SerialNumber Mapping
    [Arguments]   ${source}
    ${rmod_r_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]
    # @{rmod_detail_list}   Create List
    &{rmod_serial_mapping}   Create Dictionary
    FOR   ${rmod_r}   IN   @{rmod_r_list}
        ${serialNumber}   XML.Get Element Text   ${rmod_r}   p[@name="serialNumber"]
        ${configDN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
        ${configDN}   Should Match Regexp   ${configDN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
        ${productName}   XML.Get Element Text   ${rmod_r}   p[@name="productName"]

        ${serial_mapping}   Evaluate   {"configDN": "${configDN}", "productName": "${productName}"}
        Set To Dictionary   ${rmod_serial_mapping}   ${serialNumber}=${serial_mapping}

    END
    [Return]   ${rmod_serial_mapping}