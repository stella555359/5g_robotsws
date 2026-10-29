*** Settings ***
Documentation    :copyright: Nokia
...              :author: Wong Annie
...              :contact: wong.annie@nokia.com
...              last 23.03.2021


Library          Collections
Library          OperatingSystem

Library          taf.collectors.tcpdump                 WITH NAME    tcpdump
Library          taf.collectors.core                    WITH NAME    core
Library          taf.analyzer.pdml                      WITH NAME    pdml_analyzer

Library          ../python/luashark_tools.py
Library          luashark_tools.analyzer       WITH NAME       analyzer
Library             ../python/luashark_version_handler.py    WITH NAME    wro_sweng_lua_ver

Resource          Keywords_gNB.robot


*** Keywords ***
Get AF_PATH Value from GNB SW
    [Arguments]       ${gnb_id}=${0}
    Log       Setting Suite Variable AF_PATH to direct to required luascripts:    console=${DEBUG_MODE_CONSOLE}
    ${sw_version} =      Keywords_gNB.Get gNB software version       gnb_id=${gnb_id}
    ${luashark_url} =    wro_sweng_lua_ver.Create luashark package url    ${sw_version}
    ${luashark_available} =     wro_sweng_lua_ver.Check package availability on server    package_url=${luashark_url}
    ${luashark_url} =     Run keyword if    ${luashark_available} == ${TRUE}
    ...                   Set Suite Variable    ${AF_PATH}    ${luashark_url}
    ...    ELSE           wro_sweng_lua_ver.Try to find available package on server
    ...                   sw_version=${sw_version}    version_amount_to_check=20
    Run keyword if    ${luashark_available} == ${FALSE} and '${luashark_url}' != ""
    ...               Set Suite Variable    ${AF_PATH}    ${luashark_url}
    ...    ELSE IF    ${luashark_available} == ${FALSE} and '${luashark_url}' == ""    Set Suite Variable    None
    Log   \nAF_PATH variable points to: ${AF_PATH}          console=${DEBUG_MODE_CONSOLE}


Filter PCAP with Tshark
    [Documentation]     def filter_pcap(self, pcapInFile, filterName=None, filterExp=None):
    ...                 This method apply a filter on a pcap file and generate a new pcap
    ...                 containing only selected packets
    ...                 param pcapInFile: input pcap file
    ...                 param filterName: name of filter to add in root name of generated pcap
    ...                 param filterExp: litteral expression of filter to apply. Exple : uldata_puschreceiverespharqu
    ...                 return: path of generated pcap file
    ...                 !!!! It requires variable (suite) ${AF_PATH} being set !!!
    [Arguments]     ${pcap_file_full_path}     ${filterName}     ${filterExp}
    # generated pcap = pcap_file_full_path (without .pcap) + . + filterName + .pcap
    ${res}     analyzer.filter_pcap
    ...            ${pcap_file_full_path}
    ...            filterName=${filterName}
    ...            filterExp=${filterExp}
    [Return]    ${res}


Convert PCAP to PDML with Tshark
    [Documentation]    Translate a .pcap file into a pdml file (xml format)
    ...  pcap file is a binary file obtained thanks to a tcpdump capture
    ...  it provides a dump of all packets captured on an ethernet interface during a time
    ...  But this format can not be read directly, it required to translate it into a text format
    ...  pdml is a pertinent xml format for this Compute name of pdml file.
    ...  will be located at the same location, but with .pdml extenstion
    ...  !!!!! it requires variable (suite) ${AF_PATH} being set !!!
    [Arguments]     ${pcap_file_full_path}
    ${res}       analyzer.pcap_to_pdml   ${pcap_file_full_path}
    [Return]     ${res}