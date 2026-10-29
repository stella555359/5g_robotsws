*** Settings ***
Documentation     [PURPOSE] Set of keywords used for DSS feature tests cases (used by 1586, 1745, ...)
...
...               Automation author           : christophe.samson@nokia.com
...               Automation contact          : christophe.samson@nokia.com
...               Creation Date               : 11-June-2021
...               Modified Date               : 11-June-2021
...               Last Modified by            : christophe.samson@nokia.com

Library          taf.transport.ssh               WITH NAME    ssh
Library          taf.wts.runner                  WITH NAME    wtsemu
Library          taf.collectors.tcpdump          WITH NAME    tcpdump
Library          ute_wtssim                      WITH NAME    wts
Library          OperatingSystem
Library          DateTime
# taf.config.scf is replaced by resources/SWENG/python/MultiScf.py
# Library          taf.config.scf                  WITH NAME    scf
Library          taf.sbts.oam.coam.admin         WITH NAME    coam
Library          taf.collectors.pmcounters       WITH NAME    tafpmcounters

Resource         ../../../../../resources/SWENG/robot/Container.robot
Resource         ../../../../../resources/SWENG/robot/Restart.robot
Resource         ../../../../../resources/SWENG/robot/Tools.robot

Resource         IpTrafficCapturing.robot
Resource         DedicatedXmlConfig.robot

Library          ../python/aasyslog.py
Library          ../python/Common.py              WITH NAME    nps_dss_Common
Library          ../python/robot_extension.py     WITH NAME    robot_extension
Library          ../python/dss_tools.py           WITH NAME    nps_dss_tools
Library          ../python/Dev_lib.py

Variables        ../python/dss_scf_params.py
Variables        ../python/dss_scf_params_cell1.py
Variables        ../python/dss_scf_params_cell2.py
Variables        ../python/dss_scf_params_cell3.py
Variables        ../python/dss_SA_PDCCH_10MHZ_scf_params.py

*** Variables ***

# ${BLACK}    "\\033[30m"
# ${RED}      "\\033[31m"
# ${BLUE}     "\\033[34m"
# ${GREEN}    "\\033[32m"
# ${NORMAL}   "\\033[0m"

# to remove later !!!
&{OPT_GNB_MIRRORING}                bb_slot=bb_slot_1
...                                 mirroring_mode='manual'
...                                 l2_l1_bip='false'
...                                 syscom_mirroring='false'
...                                 carrier_aggregation='false'
...                                 backhaul_mirroring='false'
...                                 l2hi_l2lo_mirroring='false'
...                                 filtering='off'
...                                 capturing_time_seconds='1'

&{CAPTURE_BH_GNB_FS}                prefix=BH_GNB_FS                   name=
...                                 path=                              filter=${EMPTY}

# for PM Check
${latest_pm_file_name}
${coam_pm_file_path}   gnb_pm_counters

# Table describing list of field we want to collect for each packet
@{FIELDS_PUCCH_REQ}                 slot        sfn         rnti        pucchFormat     startPrb
...                                 numOfBitsOfUciInformation           nANPucch        numOfSymbols
...                                 firstSymbol
@{FIELDS_PUCCH_RESP}                slot        sfn         rnti        pucchFormat     startPrb
...                                 dtx         ackNack     crc
@{FIELDS_PDSCHSendReq}              rat0Bitmap        rbgSize         numOfPrb
@{FIELDS_PUCCHreceivereq}                           pucchFormat          startPrb         nANPucch
@{FIELDS_PUSCHreceivereq}           numOfPrb       startPrb

# Global counters to build status when parsing pucchResp packets
${NbReq}                            0           # Number of pucchReq packets found
${NbNone}                           0           # Number of pucchReq with no pucchResp found
${NbOK}                             0           # Number of pucchReq/resp where numOfBitsOfUci is OK
${NbKO}                             0           # Number of pucchReq/resp where numOfBitsOfUci is KO

# UL/DL throughput
${UL_THROUGHPUT}     200M
${DL_THROUGHPUT}    600M
@{UL_THROUGHPUT_LIST}
@{DL_THROUGHPUT_LIST}
${UL_EXPECT}        30M
${DL_EXPECT}        30M

${PCAP_PATH_GNB}=       /tmp/lte1460/portMirroringTmp.pcap.gz
${PCAP_PATH_TMP_VM}=        /tmp/tmp.pcap

*** Keywords ***

#===================================
#  TestLine Preparation procedure
#===================================

Get Testline Name
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    BuiltIn.Log     Testline Name: ${testline_name}      console=${True}
    BuiltIn.Log     Testline init file is /home/ute/testline_configuration/${testline_name}/       console=${True}
    Set Suite Metadata    Testline Name    ${testline_name}
    Set global variable   ${testline_name}
    # add here some info about  UTE TL
    ${reserve_file}=    Set Variable     /opt/ute/reservation.json
    ${file_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${reserve_file}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["topology"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    run Keyword if   "${file_exist}"=="True"     BuiltIn.Log      Topology is ${ret_cmd}       console=${True}
    run Keyword if   "${file_exist}"=="True"     Set Suite Metadata    Topology    ${ret_cmd}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["user"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    run Keyword if   "${file_exist}"=="True"     BuiltIn.Log      user is ${ret_cmd}       console=${True}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["enb_build"])'
    ${ret}    ${ret_cmd}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    run Keyword if   "${file_exist}"=="True"     BuiltIn.Log      enb_build is ${ret_cmd}       console=${True}
    [return]    ${testline_name}

remove NSA cellBwpList from SCF
    [Arguments]    ${scf_file_path}
    log to console    Remove NSA cellBwpList from SCF
    scf.Load scf    ${scf_file_path}
    FOR    ${item}    IN    @{DSS_NSA_LIST_ITEMS_PARAMS_TO_DELETE}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.Save scf    ${scf_file_path}
    [Return]    ${scf_file_path}

add NSA cellBwpList to SCF
    [Arguments]    ${scf_file_path}  ${cellId}=1
    log to console    Add NSA cellBwpList to SCF
    scf.Load scf    ${scf_file_path}
    ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-1
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    IF   '${cellId}'=='1'
        FOR    ${item}    IN    @{DSS_NSA_LIST_ITEMS_PARAMS_TO_DELETE}
             scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        END
    END
    IF   '${cellId}'=='3'
        FOR    ${item}    IN    @{DSS_NSA_LIST_ITEMS_PARAMS_TO_DELETE_CELL3}
             scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        END
    END
    scf.Save scf    ${scf_file_path}
    [Return]    ${scf_file_path}


remove SA cellBwpList from SCF
    [Arguments]    ${scf_file_path}
    log to console    Remove SA cellBwpList from SCF
    scf.Load scf    ${scf_file_path}
    FOR    ${item}    IN    @{DSS_SA_LIST_ITEMS_PARAMS_TO_DELETE}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.Save scf    ${scf_file_path}
    [Return]    ${scf_file_path}


add SA cellBwpList to SCF
    [Arguments]    ${scf_file_path}    ${cellId}=1
    log to console    Add SA cellBwpList to SCF
    scf.Load scf    ${scf_file_path}
    ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-${cellId}
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    IF   '${cellId}'=='1'
        FOR    ${item}    IN    @{DSS_SA_LIST_ITEMS_PARAMS_TO_DELETE}
             scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        END
    END
    IF   '${cellId}'=='3'
        FOR    ${item}    IN    @{DSS_SA_LIST_ITEMS_PARAMS_TO_DELETE_CELL3}
             scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        END
    END
    scf.Save scf    ${scf_file_path}
    [Return]    ${scf_file_path}


Delete DSS Information If Exist
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}    ${cell1_is_Dss}=${True}
    log to console    Delete DSS Information If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_delete.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version
    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]

    END
    FOR    ${item}    IN    @{DSS_SA_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]

    END
    FOR    ${item}    IN    @{MNL_DSS_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]

    # modify list under object
    # MRBTS-1/NRBTS-1/NRCELL-1
    # cellBwpList
    END
    IF    ${cell1_is_Dss}
        ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-1
        ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
        run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
        scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Add DSS information to scf
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}    ${cellId}=1
    log to console    Add DSS information to scf
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_add/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_add.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_add/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${nrcell_version}=    scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-2/NRCELL-1/NRCELL_FDD-1    version
    ${nrcell_version}=    scf.get_mo_attribute    MRBTS-1/NRBTS-1/NRCELL-${cellId}/NRCELL_FDD-1    version
    ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version

    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${nrcell_version}
    END
    FOR    ${item}    IN    @{DSS_SA_PARAMS_TO_ADD}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${nrcell_version}
    END
    FOR    ${item}    IN    @{MNL_DSS_PARAMS_TO_ADD}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${MNL_version}
    END
    FOR    ${item}    IN    @{DSS_LIST_NAME_PARAMS_TO_ADD}
         scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{DSS_SA_LIST_NAME_PARAMS_TO_ADD}
         scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{DSS_LIST_ITEMS_PARAMS_TO_ADD}
         scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_SA_LIST_ITEMS_PARAMS_TO_ADD}
         scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_LIST_ELEMENTS_PARAMS_TO_ADD}
         scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_SA_LIST_ELEMENTS_PARAMS_TO_ADD}
         scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_ELEMENTS_PARAMS_TO_ADD}
         scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{DSS_SA_ELEMENTS_PARAMS_TO_ADD}
         scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Delete DSS Cell1 Information If Exist
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}      ${cellId}=1
    log to console    Delete DSS Cell1 Information If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_delete_cell1.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version
    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL1}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    # modify list under object
    # MRBTS-1/NRBTS-1/NRCELL-1
    # cellBwpList
    ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-${cellId}
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Add DSS information Cell1 to scf
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}      ${cellId}=1
    log to console    Add DSS information Cell1 to scf
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_add/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_add_cell1.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_add/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${nrcell_version}=    scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-2/NRCELL-1/NRCELL_FDD-1    version
    ${nrcell_version}=    scf.get_mo_attribute    MRBTS-1/NRBTS-1/NRCELL-${cellId}/NRCELL_FDD-1    version
    ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version

    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL1}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${nrcell_version}
    END
    FOR    ${item}    IN    @{DSS_LIST_NAME_PARAMS_TO_ADD_CELL1}
         scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{DSS_LIST_ITEMS_PARAMS_TO_ADD_CELL1}
         scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_LIST_ELEMENTS_PARAMS_TO_ADD_CELL1}
         scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_ELEMENTS_PARAMS_TO_ADD_CELL1}
         scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Delete DSS Cell2 Information If Exist
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}      ${cellId}=2
    log to console    Delete DSS Cell2 Information If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_delete_cell2.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version
    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL2}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    # modify list under object
    # MRBTS-1/NRBTS-1/NRCELL-1
    # cellBwpList
    ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-${cellId}
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Add DSS information Cell2 to scf
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}      ${cellId}=2
    log to console    Add DSS information Cell2 to scf
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_add/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_add_cell2.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_add/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${nrcell_version}=    scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-2/NRCELL-1/NRCELL_FDD-1    version
    ${nrcell_version}=    scf.get_mo_attribute    MRBTS-1/NRBTS-1/NRCELL-${cellId}/NRCELL_FDD-1    version
    ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version

    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL2}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${nrcell_version}
    END
    FOR    ${item}    IN    @{DSS_LIST_NAME_PARAMS_TO_ADD_CELL2}
         scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{DSS_LIST_ITEMS_PARAMS_TO_ADD_CELL2}
         scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_LIST_ELEMENTS_PARAMS_TO_ADD_CELL2}
         scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_ELEMENTS_PARAMS_TO_ADD_CELL2}
         scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Delete DSS Cell3 Information If Exist
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}        ${cellId}=3
    log to console    Delete DSS Cell3 Information If Exist
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_delete/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_delete_cell3.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_delete/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version
    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL3}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    # modify list under object
    # MRBTS-1/NRBTS-1/NRCELL-1
    # cellBwpList
    ${dist_name}  set variable  MRBTS-1/NRBTS-1/NRCELL-${cellId}
    ${result}  scf.is_list_in_object  dist_name=${dist_name}     list_name=cellBwpList
    run keyword if    ${result}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.add list to scf  dist_name=${dist_name}   list_name=cellBwpList
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Add DSS information Cell3 to scf
    [Documentation]   Auther: Ch SAMSON
    [Arguments]    ${scf_file_path}     ${cellId}=3
    log to console    Add DSS information Cell3 to scf
    ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${LOG_PATH}/DSS_add/
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extension}
    ...    _DSS_add_cell3.xml
    ${scf_file_update_path}    set variable    ${LOG_PATH}/DSS_add/${scf_name_for_update}
    scf.Load scf    ${default_scf_file_path}
    # ${nrcell_version}=    scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-2/NRCELL-1/NRCELL_FDD-1    version
    ${nrcell_version}=    scf.get_mo_attribute    MRBTS-1/NRBTS-1/NRCELL-${cellId}/NRCELL_FDD-1    version
    ${MNL_version}=    scf.get_mo_attribute    MRBTS-1/MNL-1    version

    FOR    ${item}    IN    @{DSS_PARAMS_TO_ADD_CELL3}
         scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${nrcell_version}
    END
    FOR    ${item}    IN    @{DSS_LIST_NAME_PARAMS_TO_ADD_CELL3}
         scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{DSS_LIST_ITEMS_PARAMS_TO_ADD_CELL3}
         scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_LIST_ELEMENTS_PARAMS_TO_ADD_CELL3}
         scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{DSS_ELEMENTS_PARAMS_TO_ADD_CELL3}
         scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    [Return]    ${scf_file_update_path}

Commissioning SCF
    [Tags]                          INIT_AND_TEST
    [Arguments]                     ${ScfFile}
    Dated log                       Commisioning SCF : ${ScfFile}
    File should exist               ${ScfFile}                              SCF file ${ScfFile} not found
    OAM Perform Full Commissioning  scf_file=${ScfFile}
    Dated Log    End commissioning, wait for OAM to come back
    OAM wait available
    ${isOAMRebooted}     SSH Was OAM Rebooted        ${GNB_DU}          timeout=60
    # If gNB was rebooted after re-commissioning, wait until it's ready again.
    Run Keyword If                  '${isOAMRebooted}' == 'True'        Airscale Wait for Ready         ${GNB_DU}
    Restart       isOAMRebooted=${isOAMRebooted}    OwnTLReset=${false}     GNBCallback=common_Dss_Keywords.Set Reset Loop Counter

Get GNB BTS Info
   [Documentation]                 Retrieve several info from GNB OAM
    ...                             Information retrieved are :
    ...                                 NRBTS_ID, MRBTS_ID and NRCELL_DIST_NAME
   ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
   OAM Get GNB BTS Info            oam=${GNB_DU.oam}
   Dated log                       \tMRBTS_ID=${MRBTS_ID}
   Dated log                       \tNRBTS_ID=${NRBTS_ID}
   Dated log                       \tNRCELL_DIST_NAME=${NRCELL_DIST_NAME}
   OAM Disconnect                  ${GNB_DU.oam}


Delete NRPLMNSET_SA into SCF If Exist
   [Documentation]    delete NRPLMNSET_SA-1 object if present
   [Arguments]    ${scf_file_path}
    log to console    Remove NRPLMNSET_SA-1 from SCF if present
    scf.Load scf    ${scf_file_path}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1
    run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1
    scf.Save scf    ${scf_file_path}
    [Return]    ${scf_file_path}


add Cell Param RU related to Modify Param list
   [Arguments]      ${connection}=${None}     ${ListParamterToModify}=${EMPTY}   ${ru_index}=1   ${cellId_to_bypass}=1
    ${aliasGNB}   Run Keyword If    '${connection}'=='${None}'         OAM Connect        ${GNB_DU.oam}
    ...              ELSE                                              set variable       ${connection}
   ${cell_list_ru}=         Get All Cell Id        ru_index=${ru_index}         connection=${aliasGNB}
   ${ru_To_Lock}  set variable   False
   FOR    ${CELL_RU}  IN   @{cell_list_ru}
      dated log      cell_ru=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_RU}
      Exit For Loop If    '${CELL_RU}'=='${cellId_to_bypass}'
      ${ListParamterToModify}=     add Param to Modify Param list
      ...                               value=Locked
      ...                               dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELL_RU}
      ...                               p_name=administrativeState
      ...                               ListParamterToModify=${ListParamterToModify}
      ${ru_To_Lock}  set variable   True
   END
   [return]    ${ListParamterToModify}    ${ru_To_Lock}

add Param to Modify Param list
   [Arguments]      ${value}    ${dist_name}    ${p_name}    ${ListParamterToModify}
   &{params}      Create Dictionary  dist_name=${dist_name}
   ...                               p_name=${p_name}
   ...                               value=${value}
   Append To List   ${ListParamterToModify}    ${params}
   # Dated log     ListParamterToModify=${ListParamterToModify}
   [return]    ${ListParamterToModify}

Load SCF and Define modified scf path
    [Documentation]   Description: This keyword load scf and return modified scf path for future use.
    ...              ${scf_dir_path}: Refer to the scf folder for storing the modified scf file
    [Arguments]      ${scf_file_path}    ${scf_dir_path}=${LOG_PATH}
    # ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${scf_dir_path}
    ${default_scf_file_path}     set variable     ${scf_file_path}
    ${scf_file_name}    Fetch from right    ${scf_file_path}    /
    ${file_name_without_extension}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${scf_file_name_after_modify}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extension}    _${timestamp}_updated.xml
    ${modified_scf_file_path}    set variable    ${scf_dir_path}/${scf_file_name_after_modify}
    scf.Load scf    ${default_scf_file_path}
    [Return]    ${modified_scf_file_path}

Modify Elements to scf
    [Documentation]   Modify elt element. report error If not present
    [Arguments]    ${value}      ${target_mo_dist}     ${p_name}
    scf.modify_scf_element   value=${value}   dist_name=${target_mo_dist}   p_name=${p_name}

Modify ListParams to scf
    [Documentation]   Modify List param. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...          value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Modify ListElements to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
    END

Modify SCF ListElements
    [Documentation]
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
    FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
    END

Get All RU Index
    [Arguments]     ${connection}
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    create list
    ${ru_index_list_configuration}    create list
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        append to list    ${ru_index_list}    ${ru_index[0]}
        append to list    ${ru_index_list_configuration}    ${ru_id_configuration}
    END
    Sort List   ${ru_index_list}
    Sort List   ${ru_index_list_configuration}
    [Return]  ${ru_index_list}   ${ru_index_list_configuration}

Get All Cell Id
    [Documentation]  ru_index=None: get all gnb cells, ru_index=ru_index: get all cells under RU
    [Arguments]   ${connection}=${None}    ${ru_index}=${None}
    ${aliasGNB}   Run Keyword If    '${connection}'=='${None}'         OAM Connect        ${GNB_DU.oam}
    ...              ELSE                                              set variable       ${connection}
    ${output}=    coam.get_cells_info    connection=${aliasGNB}
    Log Many      ${output}    level=DEBUG
    ${cell_list}  create list
    FOR  ${cell}  IN  @{output}
        run keyword if  ${ru_index}==${None}    append to list  ${cell_list}  ${cell['globalCellId']}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}  run keyword if  ${ru_index}!=${None}    run keyword and return status
                   ...    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${cell_list}  ${cell['globalCellId']}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Lock in scf all RU and Cells Except CellId
   [Arguments]     ${Cell}=1    ${test_scf_file}=${EMPTY}

    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    # set test variable               ${aliasGNB}
    ${ru_index_list}  ${ru_index_list_configuration}=     Get All RU Index                connection=${aliasGNB}
    ${cell_list}=         Get All Cell Id                 connection=${aliasGNB}
    Dated log     ru_index_list=${ru_index_list}
    Dated log     cell_list=${cell_list}

    ${test_scf_file}      run Keyword if    '${test_scf_file}'=='${EMPTY}'    OAM Get SCF File     dir=${LOG_PATH}      file=SCF.xml
    ...    ELSE     set variable      ${test_scf_file}
    ${modified_scf_file_path}=     Load SCF and Define modified scf path     scf_file_path=${test_scf_file}

    # manage ListParamterToModify
    ${index}=   set variable   ${0}
    @{ListParamterToModify}=    create list
    @{ListCellParamterToModify}=    create list
    FOR    ${RU}  IN  @{ru_index_list}
        dated log    RU=${RU}
        dated log    ru_index_list_configuration=${ru_index_list_configuration}[${index}]
        ${ListCellParamterToModify_o}  ${ru_To_Lock}=     add Cell Param RU related to Modify Param list
        ...                                                      connection=${aliasGNB}
        ...                                                      ListParamterToModify=${ListParamterToModify}
        ...                                                      ru_index=${RU}
        ...                                                      cellId_to_bypass=${Cell}
        # MRBTS-1/EQM-1/APEQM-1/RMOD-2
        ${ListCellParamterToModify_to_apply}=     run Keyword if   '${ru_To_Lock}'=='True'    add Param to Modify Param list
        ...                                                                                      value=Locked
        ...                                                                                      dist_name=${ru_index_list_configuration}[${index}]
        ...                                                                                      p_name=administrativeState
        ...                                                                                      ListParamterToModify=${ListCellParamterToModify_o}
        ...    ELSE            set variable      ${ListCellParamterToModify_o}
        ${index}=   Evaluate    ${index}+${1}
    END
    Dated log   ListCellParamterToModify_to_apply=${ListCellParamterToModify_to_apply}
    ${status}   ${value}=    Run Keyword And Ignore Error      Should Be Empty    ${ListCellParamterToModify_to_apply}
    # '${status}' == 'PASS' means ListParamterToModify is empty
    IF   '${status}' != 'PASS'
        Modify ListParams to scf      parameters_lists=${ListCellParamterToModify_to_apply}
    END
    scf.Save scf    ${modified_scf_file_path}
    [return]   ${modified_scf_file_path}


#===================================
# To manage WTS cfg and xml files
#===================================
#=======================================================================================================================
# CONFIG/SETTINGS services on basic.cfg (the default basic.cfg is for 10MHz)
#=======================================================================================================================
Backup XML AirphoneConfig
    [Documentation]                 Backup current AirphoneConfig file on ePCSim
    ${file}                         Get XML AirPhoneConfig Path
    return from Keyword if   '${file}'=='${EMPTY}'    ${EMPTY}
    Dated log                       On wtsemu, backing up file ${file}
    ${alias}                        SSH Connect                       ${HOST_EPCSIM}
    # Creates a copy of current XML AirphoneConfig
    ${backup_exists}=    csn.execute    test -f ${file}.backup && echo -n "okman" || echo -n "noway"    connection=${alias}
    ${file_exists}=      csn.execute    test -f ${file} && echo -n "okman" || echo -n "noway"    connection=${alias}
    Run Keyword If    '${file_exists}'=='okman' and '${backup_exists}'!='okman'    csn.execute    cp ${file} ${file}.backup    connection=${alias}
    return from Keyword     ${file}

Set FullStack NodeId
    [Arguments]                      ${x_path_l1Hw}
    setText                          ${x_path_l1Hw}/l1UlNodeId          ${Fullstack_NodeId_WtsXml}
    setText                          ${x_path_l1Hw}/l1DlNodeId          ${Fullstack_NodeId_WtsXml}

Set L1ByPass NodeId
    [Arguments]                      ${x_path_l1Hw}
    setText                          ${x_path_l1Hw}/l1UlNodeId          ${L1bypass_NodeId_WtsXml}
    setText                          ${x_path_l1Hw}/l1DlNodeId          ${L1bypass_NodeId_WtsXml}

WTS Preparation
    [Arguments]       ${testParam}
    WTS cfg Preparation                ${testParam}
    WTS xml Preparation             ${testParam}
    WTS Setup                       nbUe=${testParam.seq.totalUE}

WTS cfg Preparation
    [Arguments]       ${testParam}    ${w_rename}=True
    WtsCfgConfig.startSession
    ${oldValue}          getParam           prefix=set_cell          param=nr_arfcn
    replaceValue         prefix=set_cell
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${testParam.wtsXmlFile.ulNrArfcn}:${testParam.wtsXmlFile.dlNrArfcn}
    ${oldValue}          getParam           prefix=set_cell          param=bw
    replaceValue         prefix=set_cell
    ...                  param=bw
    ...                  oldValue=${oldValue}
    ...                  newValue=${testParam.wtsXmlFile.bw}
    IF    '${w_rename}'=='True'
        WtsCfgConfig.stopSession         rename=modified
    ELSE
        WtsCfgConfig.stopSession
    END

WTS xml Preparation
    [Arguments]          ${testParam}
    ${file}       Backup XML AirphoneConfig
    return from Keyword if   '${file}'=='${EMPTY}'    ${EMPTY}
    WtsXmlConfig.startSession
    #set Arfcn
    WtsXmlConfig.setListEltText         //dlNrArfcn                        ${testParam.scfFile.nrcellfdd.nrarfcnDl}
    WtsXmlConfig.setListEltText         //ulNrArfcn                        ${testParam.scfFile.nrcellfdd.nrarfcnUl}
    WtsXmlConfig.setListEltText         //gscn                             ${testParam.scfFile.nrcell.gscn}
    WtsXmlConfig.stopSession

dedicated WTS xml Preparation
    [Arguments]          ${testParam}
    ${file}       Backup XML AirphoneConfig
    return from Keyword if   '${file}'=='${EMPTY}'    ${EMPTY}
    DedicatedXmlConfig.dedicated startSession iphy
    #set Arfcn
    DedicatedXmlConfig.dedicated setListEltText         //dlNrArfcn                  ${testParam.scfFile.nrcellfdd.nrarfcnDl}
    DedicatedXmlConfig.dedicated setListEltText         //ulNrArfcn                  ${testParam.scfFile.nrcellfdd.nrarfcnUl}
    DedicatedXmlConfig.dedicated setListEltText         //gscn                       ${testParam.scfFile.nrcell.gscn}
    DedicatedXmlConfig.dedicated stopSession iphy

# the basic configuration is for 10MHz
Set UE capa on EPCSim
    [Arguments]                     ${ue_nr_capa_value}=${ue_nr_capabilities_20MHz}    ${ue_ue_eutra_nr_capa}=${ue_ue_eutra_nr_capabilities_20MHz}
    Modify Field in WtsEmu Cfg File
    ...                             field=ue_nr_capabilities                 value=${ue_nr_capa_value}
    Modify Field in WtsEmu Cfg File
    ...                             field=ue_eutra_nr_capabilities                 value=${ue_ue_eutra_nr_capa}

Update AirPhoneConfig file name in WTS Config
    [Documentation]    :
    ...    update WTS Config with given file name
    ...    :param remote_cfg: target WTS config file name (default ${tl.core.cfg_filename})
    ...
    ...    **Example:**
    ...    | wts_ue.Update AirPhoneConfig file name in WTS Config    file_name=AirphoneConfig.xml
    ...
    [Arguments]    ${file_name}    ${remote_cfg}=${tl.core.cfg_filename}
    ${core_alias}=    common_Dss_Keywords.Connect to Core
    ${output}=    ssh.execute    command=ls ${tl.core.dir_path}/${file_name}    connection=${core_alias}
    Should Contain    ${output}    ${file_name}
    Update WTS config with Regex    regex= file=\\S+    value= file=${file_name}    remote_cfg=${remote_cfg}


Update gNBId and eNBId In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup DSS configuration
    [Arguments]            ${cfg_file}    ${eNBId}=2     ${gNBId}=1

    # for eNB
    run    command=sed -i 's|set_enb id=1|set_enb id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|enb_param id=1|enb_param id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=1 enb=1|set_cell id=1 enb=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|enb_endc_param id=1|enb_endc_param id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|trace enb=1|trace enb=${eNBId}|g' ${cfg_file}

    # for gNB
    run    command=sed -i 's|set_gnb id=2|set_gnb id=${gNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=1 gnb=2|set_cell id=1 gnb=${gNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=2 gnb=2|#set_cell id=2 gnb=${gNBId}|g' ${cfg_file}
    # adaptation of set_ue simulated id=
    run    command=sed -i 's|enb=1|enb=${eNBId}|g' ${cfg_file}

# to setup DSS configuration In WTS Cfg File
# done once during test suite setup
Update SpecificParameters to setup DSS configuration In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup DSS configuration
    ...      LTE Cell
    ...          set_enb
    ...              id=1
    ...          set_cell
    ...              id=1
    ...              plmn
    ...              earfcn=68787:133323
    ...              enb_id_macro
    ...              xp_management    ===>  ex:  xp_management=on xp=10.0.1.137:32742 xpu=10.0.1.137:32742
    ...              eci
    ...       NR Cell
    ...           set_gnb
    ...               id=2
    ...               gnb_id=0x00000002
    ...               plmn
    ...               xp_management    ===>  ex:  xp_management=on xp=10.0.1.111:32742 xpu=10.0.1.111:32742
    ...           set_cell
    ...               id=1
    ...               gnb=2
    ...       mme_pool_area
    ...               id=1
    ...               plmn
    ...       set_uec file=AirPhoneConfig_19A_V6.0-FDD-FullStack-10MHz_DSS.xml
    ...
    [Arguments]                     ${testParam}

    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${new_cfg_filename}    Set Variable    new_${tl.core.cfg_filename}
    ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Move file    ${current_cfg_file}    ${current_cfg_file}_bkp

    #---------------------------------------------------------------------------------------------------
    # CRM Partnership Creation (Cell-1.1 -> Cell-2.1)
    #---------------------------------------------------------------------------------------------------
    # ENB CONFIGURATION (default configuration is 10MHz)
    #  Cell-1.1
    #---------------------------------------------------------------------------------------------------
    ${cmd}       catenate    plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    ...                      enb_id_macro=0x00001
    ...                      xp_management=on
    ...                      xp=${testParam.scfFile.xpif_xpifremote.ipAddress}:32742
    ...                      xpu=${testParam.scfFile.xpif_xpifremote.ipAddress}:32742
    ${line}    Set Variable  ${cmd}
    wts_cfg.Modify    set_enb id=1    ${line}

    # earfcn is updated to be in same BW (LTE and NR)
    # both LTE and NR freq are aligned (normalized freq are different betwenn LTE and NR )
    # ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68787:133323
    ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68771:133307
    wts_cfg.Modify    set_cell id=1 enb=1    ${line}
    #  for LTE
    # Band Name Bandwidth (MHz) Mode Earfcn DL Downlink (MHz)  Earfcn    UL Uplink (MHz)
    #  71   600     35           FDD    68787     637.10       133323      683.10
    #
    # for NR
    # Band  Name  Mode   ,    Downlink nr-arfcn Frequency (MHz) , Uplink nr-arfcn     Frequency (MHz)
    # n71   600    FD    ,         127420          637.1               136620             683.1
    #

    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    # Cell-2.1
    #---------------------------------------------------------------------------------------------------
    ${cmd}       catenate    gnb_id=0x00000002
    ...                      plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    ...                      xp_management=on
    ...                      xp=${testParam.scfFile.ipif.localIpAddr}:32742
    ...                      xpu=${testParam.scfFile.ipif.localIpAddr}:32742
    ${line}    Set Variable   ${cmd}
    wts_cfg.Modify    set_gnb id=2    ${line}

    # ${line}    Set Variable    nr_arfcn=136620:127420
    # ${line}    Set Variable     nr_arfcn=136620:127420 tdd_cell=off
    ${line}    Set Variable     nr_arfcn=${testParam.scfFile.nrcellfdd.nrarfcnUl}:${testParam.scfFile.nrcellfdd.nrarfcnDl} tdd_cell=off
    #  nr_arfcn=${ul_nr_arfcn}:${dl_nr_arfcn}   => Done during each test cases
    wts_cfg.Modify    set_cell id=1 gnb=2    ${line}
    # DSS Tests are mono Cell only !!! => remove second cell if present
    # Run Keyword And Ignore Error     wts_cfg.Delete    set_cell id=2 gnb=2
    #---------------------------------------------------------------------------------------------------
    # EPC CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Modify    mme_pool_area id=1    plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}

    #---------------------------------------------------------------------------------------------------
    # UE CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    #  ue_nr_capacities is updated during the test cases
    wts_cfg.Modify    set_ue simulated id=1     enb=${testParam.Context.gNBId}

    # to prevent againt suci is not present in cfg file
    ${status}    ${ue_suci}=  Run Keyword And Ignore Error       wts_cfg.Get parameter    set_ue simulated id=1    suci
    ${new_ue_suci}=     Run Keyword if    '${ue_suci}'!='None'
    ...                nps_dss_tools.Modify suci for UE  ${ue_suci}  ${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    # ${new_ue_suci}=  nps_dss_tools.Modify suci for UE  ${ue_suci}  ${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    Run Keyword if    '${ue_suci}'!='None'     Run keywords
    ...                      wts_cfg.Modify     set_ue simulated id=1  suci=${new_ue_suci}     AND
    ...                      Dated log     cfg Modify : new_ue_suci is ${new_ue_suci}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # remove "mapped_earfcn= ..." from the file
    Run          command=sed -i -e 's/mapped_earfcn=[0-9]*:[0-9]*//g' ${new_cfg_file}
    Run          command=sed -i -e 's/GNB_NG_ADDR="10.0.1.2"/GNB_NG_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${new_cfg_file}
    Run          command=sed -i -e 's/GNB_X2_ADDR="10.0.1.2"/GNB_X2_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${new_cfg_file}
    common_Dss_Keywords.Update gNBId and eNBId In WTS Cfg File    ${new_cfg_file}  eNBId=${testParam.Context.eNBId}  gNBId=${testParam.Context.gNBId}
    # BEWARE that enb in set_ue simulated cmd means gnbId !!!
    wts_cfg.Load Wts Cfg        ${new_cfg_file}
    wts_cfg.Modify     set_ue simulated id=1    enb=${testParam.Context.gNBId}
    Dated log     cfg Modify : "set_ue simulated id=1 enb=" modified with ${testParam.Context.gNBId}
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}
    # Move file    ${new_cfg_file}    ${new_cfg_file}_bkp

Update SpecificParameters for VoNR configuration In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup DSS configuration
    [Arguments]                     ${testParam}
    BuiltIn.log     bandwidth is ${testParam.seq.bandwidth}
    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${new_cfg_filename}    Set Variable    new_${tl.core.cfg_filename}
    ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Move file    ${current_cfg_file}    ${current_cfg_file}_bkp_2

    ${cmd}       catenate    gfbr_ul=25  gfbr_dl=25
    ...                      mfbr_ul=30720  mfbr_dl=30720
    ...                      qos_flow_type=gbr ue=all

    ${line}    Set Variable  ${cmd}
    wts_cfg.Modify    set_qosflow id=3 5qi=1    ${line}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}
    # Move file    ${new_cfg_file}    ${new_cfg_file}_bkp

#===================================
# To Start and stop Traces for DSS
#===================================

Initialize Capture
    # [Arguments]                    ${capture}
    #define options of gnbMirroring.sh (BIP L1L2 and BH)
    ${OPT_GNB_MIRRORING_DSS}                 Tools.Dictionary Get              ${OPT_GNB_MIRRORING}
    ${OPT_GNB_MIRRORING_DSS.mirroring_mode}            set Variable	       'manual'
    ${OPT_GNB_MIRRORING_DSS.l2_l1_bip}                 set Variable	       'true'
    ${OPT_GNB_MIRRORING_DSS.backhaul_mirroring}=      run keyword if    '${GNB_DU.sys[0].M.boardType}'=='ASIK'    set Variable	   'true'
    ...         ELSE          set Variable	       'false'
    Set Suite Variable              ${OPT_GNB_MIRRORING_DSS}
    # Execute Mirror Script with options for DSS      ${capture.scriptDef}    ${OPT_GNB_MIRRORING_DSS}

Capture BH Set
    [Arguments]
    ${capture}                      Dictionary Get                          ${CAPTURE_BH_GNB_FS}
    [Return]                        ${capture}

gNB connection
    ssh.Connect to    ${GNB_DU.sys[0].M.sshConnection.addr}
    ...               ${GNB_DU.sys[0].M.sshConnection.username}
    ...               ${GNB_DU.sys[0].M.sshConnection.password}
    ...                alias=gnb

Get mac
    wait until keyword succeeds    1min   10s    gNB connection
    ${output}=  ssh.execute  command=ifconfig br1 | grep ether  connection=gnb
    ssh.disconnect    connection=gnb
    ${mac}=     nps_dss_tools.parse_mac_address  ${output}
    log to console  mac = ${mac}
    [Return]  ${mac}

Start capture BH data on GNB
    # [Arguments]    ${logname}=portMirroringTmp.pcap    ${filter}=None    ${w_disconnect}=true
    [Arguments]    ${logname}=portMirroringTmp.pcap     ${w_disconnect}=true
    return from keyword if    '${GNB_DU.sys[0].M.boardType}'=='ASIK'
    ${mac}=  Get mac
    wait until keyword succeeds    1min   10s    gNB connection
    ssh.execute    command=rm -f /lte1460/${logname}*    connection=gnb
    sleep    2s
    # try with ${mac} in the cmd
    # to see if it is possible to add the filter in the cmd line !!!
    ssh.execute    command=/opt/trs/bin/vtc vtc_traffic_capturing_start_test 1 1 1 0 0xffffffffffff file_name    connection=gnb
    sleep    2s
    run Keyword if     '${w_disconnect}'=='true'     ssh.disconnect    connection=gnb

Filter Pcap
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}   ${lua_path}=None
    [Documentation]    filter wireshark pcap file
     ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target pcap file to be generated in UTE server |
    ...    | filter | Yes | filter used to generate target file |
    ...    | lua_path | Yes | full path to lua script |
    ...
    ...    *RETURN VALUE*
    ...    None

    OperatingSystem.File Should Exist    ${src}
    # ${cmd}   Set Variable      tshark -r ${src} -w ${dest} "${filter}" 2>/dev/null
    ${cmd}   Set Variable if   "${lua_path}"!="None"    tshark -r "${src}" -F pcap -w ${dest} -X lua_script:${lua_path} -Y ${filter} 2>/dev/null
    ...                                                 tshark -r "${src}" -F pcap -w ${dest} -Y ${filter} 2>/dev/null
    # ${cmd}   Set Variable      tshark -r "${src}" -F pcap -w ${dest} -Y ${filter} 2>/dev/null
    ${rc}   ${out}   OperatingSystem.Run And Return Rc And Output    ${cmd}


#  kind of filter to use for BH traces
#  '((ip.src == 10.0.1.111) && (ip.dst == 10.0.1.137) ) || ( (ip.src == 10.0.1.137) && (ip.dst == 10.0.1.111))'
#  'xp_dss_xpdssmessage'
Stop and download BH Log from GNB
   [Arguments]     ${capture}=None    ${target_dir}=None   ${filter}='xp_dss_xpdssmessage'  ${lua_path}=/opt/luashark/generated_luashark/xpshark.lua
    # Dated log    capture=${capture} target_dir=${target_dir} filter=${filter}
    return from keyword if    '${GNB_DU.sys[0].M.boardType}'=='ASIK'
    Run               rm -f ${PCAP_PATH_TMP_VM}*
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}
    wait until keyword succeeds    1min   10s    gNB connection
    ssh.execute     command=/opt/trs/bin/vtc vtc_traffic_capturing_stop_test    connection=gnb
    sleep    2s
    ssh.execute     command=/opt/trs/bin/vtc vtc_traffic_capture_gen_pcap_test dummy    connection=gnb
    sleep    2s
    ssh.download_file   remote_path=/lte1460/portMirroringTmp.pcap.gz   local_path=${target_dir}/${capture.name}.pcap.gz   connection=gnb
    Run               cp ${target_dir}/${capture.name}.pcap.gz ${PCAP_PATH_TMP_VM}.gz
    Run               gunzip -f ${PCAP_PATH_TMP_VM}.gz
    # Run               cp ${PCAP_PATH_TMP_VM} ${capture.path}
    # Dated log         capture_path=${capture.path}
    # ${capture.filter}   set variable    ${filterBH}
    # Run               cp ${capture.path} ${PCAP_PATH_TMP_VM}
    # ${PATH_TO_LUA}=    nps_lua_ver.return_full_path_to_lua_Analyzer_script   ${AF_PATH}
    # Dated log          AF_PATH=${AF_PATH} => ${PATH_TO_LUA}
    ${capture.filter}   set variable   ${filter}
    # Filter Pcap       src=${PCAP_PATH_TMP_VM}    dest=${capture.path}    filter=${capture.filter}   lua_path=${PATH_TO_LUA}
    Filter Pcap       src=${PCAP_PATH_TMP_VM}    dest=${capture.path}    filter=${capture.filter}
    ...                                           lua_path=${lua_path}
    Dated log         pcap ${capture.path} filtered with ${capture.filter}
    ssh.disconnect    connection=gnb

Start capture for DSS to remove in 2 weeks
    [Documentation]                1586-C : Start capture for 1586
    [Arguments]                    ${prefix}=XP

    #define options of gnbMirroring.sh (BH only)
    ${OPT_GNB_MIRRORING_DSS}                 Tools.Dictionary Get              ${OPT_GNB_MIRRORING}
    ${OPT_GNB_MIRRORING_DSS.mirroring_mode}            set Variable	       'manual'
    ${OPT_GNB_MIRRORING_DSS.l2_l1_bip}                 set Variable	       'false'
    ${OPT_GNB_MIRRORING_DSS.backhaul_mirroring}        set Variable	       'false'
    Set Suite Variable              ${OPT_GNB_MIRRORING_DSS}
    Execute Mirror Script with options for DSS      ${CAPTURE_L1L2_GNB_FS_GNB_DSS.scriptDef}    ${OPT_GNB_MIRRORING_DSS}

    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${LOG_PATH}/SCF.xml
    scf.load_scf	 ${current_scf_fullname}
    ${ipAddr}	 scf.get_value_from_scf   p_name=localIpAddr
    ...              dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${ipAddress_XPIFREMOTE}	 scf.get_value_from_scf   p_name=ipAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1

    # set a specific name to keep the trace and set filter
    ${CAPTURE_L1L2_GNB_FS_GNB_DSS.prefix}       set Variable   ${prefix}
    ${CAPTURE_L1L2_GNB_FS_GNB_DSS.withTN}       set Variable   True
    # ${CAPTURE_L1L2_GNB_FS_GNB_DSS.filter}     set variable      host ${ipAddr}
    ${filter}       Catenate      '(src ${ipAddr} and dst ${ipAddress_XPIFREMOTE}) or (src ${ipAddress_XPIFREMOTE} and dst ${ipAddr})'
    ${CAPTURE_L1L2_GNB_FS_GNB_DSS.filter}               set variable        ${filter}
    Dated log          CAPTURE_BH_GNB_FS_DSS.filter = ${CAPTURE_L1L2_GNB_FS_GNB_DSS.filter}
    ${filterBH}   Catenate  '((ip.src == ${ipAddr}) && (ip.dst == ${ipAddress_XPIFREMOTE}) )
    ...                       || ( (ip.src == ${ipAddress_XPIFREMOTE}) && (ip.dst == ${ipAddr}))'
    set suite variable   ${filterBH}

    Capture Start                   ${CAPTURE_L1L2_GNB_FS_GNB_DSS}
    Start capture BH data on GNB


Stop capture for DSS to remove in 2 weeks
    [Arguments]                    ${w_desactive_mirroring}=True
    ${alias}                        SSH Connect                             host=${CAPTURE_L1L2_GNB_FS_GNB_DSS.target.host}
    Capture Stop                   ${CAPTURE_L1L2_GNB_FS_GNB_DSS}
    Stop and download BH Log from GNB     capture=${CAPTURE_L1L2_GNB_FS_GNB_DSS}

    Dated log             pdml files generation ...
    ${pdmlFile}=        pcap.Convert pcap to pdml file without filtering          ${CAPTURE_L1L2_GNB_FS_GNB_DSS.path}
    Dated log             pdml files generation completed ...

    #define options of gnbMirroring.sh - to desactivate mirroring
    ${OPT_GNB_MIRRORING_DSS}                 Tools.Dictionary Get              ${OPT_GNB_MIRRORING}
    ${OPT_GNB_MIRRORING_DSS.mirroring_mode}            set Variable	       'local'
    ${OPT_GNB_MIRRORING_DSS.l2_l1_bip}                 set Variable	       'true'
    ${OPT_GNB_MIRRORING_DSS.backhaul_mirroring}        set Variable	       'false'
    ${OPT_GNB_MIRRORING_DSS.capturing_time_seconds}            set Variable	       '1'
    Set Suite Variable              ${OPT_GNB_MIRRORING_DSS}
    run Keyword if      '${w_desactive_mirroring}'=='True'        Execute Mirror Script with options for DSS
    ...                                                                    ${CAPTURE_L1L2_GNB_FS_GNB_DSS.scriptDef}
    ...                                                                    ${OPT_GNB_MIRRORING_DSS}

    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CAPTURE_L1L2_GNB_FS_GNB_DSS.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CAPTURE_L1L2_GNB_FS_GNB_DSS.path}    ${testCaseDir}
    Dated Log     dss pcap file ${CAPTURE_L1L2_GNB_FS_GNB_DSS.path} copied into ${testCaseDir}

    [return]   ${pdmlFile}

Initialize Filter XP message Capture
    [Documentation]                Initialize Filter XP message Capture
    [Arguments]                    ${capture}=None

    ${capture.filter}     set variable                            'xp_dss_xpdssmessage'
    Dated log          Set Xp message capture filter with ${capture.filter}

    [return]   ${capture}

Initialize Filter Backhaul Xn Capture
    [Documentation]                Initialize Filter Backhaul Capture [Xn protocol]
    [Arguments]                    ${capture}=None

    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${LOG_PATH}/SCF.xml
    scf.load_scf	 ${current_scf_fullname}
    ${ipAddr}	 scf.get_value_from_scf   p_name=localIpAddr
    ...              dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${ipAddress_XPIFREMOTE}	 scf.get_value_from_scf   p_name=ipAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1

    ${filterBH}   Catenate  '((ip.src == ${ipAddr}) && (ip.dst == ${ipAddress_XPIFREMOTE}) )
    ...                       || ( (ip.src == ${ipAddress_XPIFREMOTE}) && (ip.dst == ${ipAddr}))'
    set suite variable   ${filterBH}
    ${capture.filter}     set variable   ${filterBH}
    Dated log          Set Backhaul capture filter with ${capture.filter}

    [return]   ${capture}

Initialize Filter Backhaul Xn and NG Capture
    [Documentation]                Initialize Filter Backhaul Capture [Xn and NG protocol]
    [Arguments]                    ${capture}=None

    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${LOG_PATH}/SCF.xml
    scf.load_scf	 ${current_scf_fullname}
    ${ipAddr}	 scf.get_value_from_scf   p_name=localIpAddr
    ...              dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${ipAddress_XPIFREMOTE}	 scf.get_value_from_scf   p_name=ipAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1
    ${ipAddress_amfIPAddress}	 scf.get_value_from_scf   p_name=amfIPAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    ${filter_BH}   Catenate  '((ip.src == ${ipAddr}) && (ip.dst == ${ipAddress_XPIFREMOTE}))
    ...                       || ((ip.src == ${ipAddress_XPIFREMOTE}) && (ip.dst == ${ipAddr}))
    ...                       || ((ip.src == ${ipAddr}) && (ip.dst == ${ipAddress_amfIPAddress}))
    ...                       || ((ip.src == ${ipAddress_amfIPAddress}) && (ip.dst == ${ipAddr}))'
    set suite variable   ${filter_BH}
    ${capture.filter}     set variable   ${filter_BH}
    Dated log          Set Backhaul Xn and NG capture filter with ${capture.filter}

    [return]   ${capture}

initialize default BH capture
    # set capture
    ${capture}=           Capture BH Set
    ${capture.prefix}     set Variable   BH.XP
    ${TestName}           getFormattedTestName
    ${capture.name}       Set variable                            ${capture.prefix}
    ${capture.name}       Set variable                            ${capture.name}.${TestName}
    ${capture.path}       Set variable                            ${LOG_PATH}/${capture.name}.pcap
    ${capture.filter}     set variable                            'xp_dss_xpdssmessage'

    [return]   ${capture}

set Backhaul Capture
    [Documentation]                Start capture for 1586 [BH Xp protocol]
    [Arguments]                    ${prefix}=BH

    ${L_resultTestDir}=    Get Variable Value    ${testCaseDir}
    ${L_testCaseDir}   Run Keyword If    '${L_resultTestDir}'!='None'   common_Dss_Keywords.Get testcase log directory
    ...                      ELSE                                        Set Variable    ${LOG_PATH}
    # set capture
    ${capture}=           Capture BH Set
    ${capture.prefix}     set Variable   ${prefix}
    ${TestName}           getFormattedTestName
    ${capture.name}       Set variable                            ${capture.prefix}
    ${capture.name}       Set variable                            ${capture.name}.${TestName}
    # ${capture.path}       Set variable                            ${LOG_PATH}/${capture.name}.pcap
    ${capture.path}       Set variable                            ${L_testCaseDir}/${capture.name}.pcap
    Dated log             capture Backhaul ${capture.name} created
    [return]   ${capture}

Start capture Backhaul XP for DSS New
    [Documentation]                Start capture for 1586 [BH Xp protocol]
    ...                             BH Capture need to be creadted first using set Backhaul Capture Kw
    ...                             BH filter need to be updated first using Initialize Filter XP message Capture for ex
    [Arguments]                    ${capture}=None      ${suffix}=test

    BuiltIn.log    test suffix is ${suffix}
    # version de reference
    # run Keyword if    not ${isAiC}    Start capture BH data on GNB
    # ...     ELSE                      common_Dss_Keywords.Start Tcpdump on TestPc   interface=eth3   option=-s0 sctp
    # ...                                                                             collector=testpc-eth3-fronthaul
    # Fin version de reference

    # ASIBTOTO => need CleanUp Later (use of IP Traffic Capturing only!!!)
    # run Keyword if    not ${isAiC} and '${GNB_DU.sys[0].M.boardType}'=='ASIBTOTO'    Start capture BH data on GNB
    run Keyword if    not ${isAiC} and '${GNB_DU.sys[0].M.boardType}'=='ASIL'
    ...                    common_Dss_Keywords.Start Tcpdump on TestPc   interface=eth3
    ...                                                                  option=-U -s0 'sctp or udp'
    ...                                                                  collector=${capture.name}
    ...     ELSE
    ...          run Keyword if    ${isAiC}
    ...                    common_Dss_Keywords.Start Tcpdump on TestPc   interface=eth3
    ...                                                                  option=-s0 'sctp or udp'
    ...                                                                  collector=testpc-eth3-backhaul
    ...          ELSE
    ...                    IpTrafficCapturing.Connect And Start IP Traffic Capturing   measurement_point=NE_Terminated
   ...                                                                                 uplane_capturing=False
   ...                                                                                 password=${EMPTY}

    set suite variable   ${capture}

    [return]   ${capture}

Set Global Variable If It Does Not Exist
    [Arguments]     ${name}     ${value}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist       ${name}
    Run Keyword If   "${status}"=="FAIL"     Set Global Variable     ${name}    ${value}

Stop capture for Backhaul XP DSS New
    [Arguments]       ${capture}=None     ${w_pdml}=True    ${w_traces_archived}=True    ${lua_path}=/opt/luashark/generated_luashark/xpshark.lua
    ...               ${suffix}=test

    BuiltIn.log     test suffix is ${suffix}
    ${default capture}=     initialize default BH capture
    Set Global Variable If It Does Not Exist    ${capture}   ${default capture}

    # ASIBTOTO => need CleanUp Later (use of IP Traffic Capturing only!!!)
    run Keyword if    not ${isAiC} and '${GNB_DU.sys[0].M.boardType}'=='ASIBTOTO'       Stop and download BH Log from GNB     capture=${capture}
    ...                                                                                                                   filter=${capture.filter}
    ...                                                                                                                   lua_path=${lua_path}
    # with ASIL , seems only sctp is present in pcap file when using IP Traffic Capturing , udp is not present for exemple !!!!
    # DssSetup and DL/UL Coordination are sctp
    # D/UL Dss Allocation , KeepLive , DL and UL Qos Load Indication are udp
    ${capture.path}=      run Keyword if    not ${isAiC} and '${GNB_DU.sys[0].M.boardType}'=='ASIL'   common_Dss_Keywords.Stop Tcpdump on TestPc
    ...                                                                                                interface=eth3
    ...                                                                                                collector=${capture.name}
    ...                                                                                                target_dir=${testCaseDir}
    ...    ELSE                                     set variable      ${capture.path}
    ${capture.path}=      run Keyword if    ${isAiC}                                 common_Dss_Keywords.Stop Tcpdump on TestPc
    ...                                                                                               interface=eth3
    ...                                                                                               collector=testpc-eth3-backhaul
    ...                                                                                               target_dir=${testCaseDir}
    ...   ELSE                                     set variable      ${capture.path}
    ${downloaded_file_pcap_gz}    set variable    ${testCaseDir}/${capture.name}.pcap.gz
    run Keyword if    not ${isAiC} and '${GNB_DU.sys[0].M.boardType}'!='ASIL'    Stop IP Traffic Capturing and Download File
    ...                                                                                    target_file_name=${downloaded_file_pcap_gz}
    ...                                                                                    w_unzip=True
    ...                                                                                    dest_unzip=${capture.path}

    run Keyword if    '${w_pdml}'=='True'      Dated log             pdml files generation ...
    ${pdmlFile}=     run Keyword if    '${w_pdml}'=='True'      pcap.Convert pcap to pdml file without filtering          ${capture.path}
    ...   ELSE      set variable    ${EMPTY}
    run Keyword if    '${w_pdml}'=='True'      Dated log             pdml files generation completed ...

    run Keyword if    '${w_traces_archived}'=='True'    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${capture.path}
    run Keyword if    '${w_traces_archived}'=='True'    Run Keyword And Ignore Error    OperatingSystem.Move File    ${capture.path}   ${testCaseDir}
    run Keyword if    '${w_traces_archived}'=='True'    Dated Log     dss pcap file ${capture.path} moved into ${testCaseDir}

    [return]   ${pdmlFile}

Merge pcap files
    [Documentation]  This keyword merge the given pcap file list and return the absolute path of the merged file.
    ...    Packets from the input files are merged in chronological order based on each frame??s timestamp
    [Arguments]     ${pcap_files_list}      ${output_pcap_file}
    @{pcap_files_list_to_merge}    Set variable    ${pcap_files_list}
    ${cmd}    catenate      mergecap    -w    ${output_pcap_file}
    FOR    ${pcap_file}     IN    @{pcap_files_list_to_merge}
           ${cmd}    catenate    ${cmd}    ${pcap_file}
    END
    Dated log    ${cmd}
    ${res}    Run    ${cmd}
    Dated log    ${res}
    [Return]    ${output_pcap_file}

Start capture Bip and Xp for DSS
    [Documentation]                Start capture Bip and Xp for DSS
    [Arguments]                    ${prefix}=XP_L1L2_BIP

    # set a specific name to keep the trace
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}               Capture L1L2 Set Upon Config
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.prefix}         set Variable   ${prefix}
    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.withTN}         set Variable   False
    Set Suite Variable              ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}

    ${capture_BH_GNB}=             set Backhaul Capture                     prefix=BH.XP
    set global variable            ${capture_BH_GNB}
    ${capture_BH_GNB}=             Initialize Filter XP message Capture     capture=${capture_BH_GNB}

    # ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       Get Filter all BIP msgs
    # to manage the case vlan218 encapsulated within vlan305 (seen with ABIO / ABIP) and the case vlan218 only (seen with ABIP & ABIL)
    # ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       set variable   ether[12:2]=0x8951 or ether[16:2]=0x8951
    # ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}       Catenate    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.filter}

    # Initialize Capture                ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    #    ==== Capture Init Kw introduce 30s sleep , not very good !!!!
    Capture Init                    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    Capture Start                   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    # Start capture BH data on GNB
    common_Dss_Keywords.Start capture Backhaul XP for DSS New               capture=${capture_BH_GNB}

Stop capture Bip and Xp for DSS
    [Arguments]
    ${alias}                        SSH Connect                             host=${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.target.host}
    Capture Stop                   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH}
    common_Dss_Keywords.Stop capture for Backhaul XP DSS New     capture=${capture_BH_GNB}    w_pdml=False    w_traces_archived=False
    Run               cp ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path} ${PCAP_PATH_TMP_VM}
    @{pcap_files_list}     set variable   ${PCAP_PATH_TMP_VM}    ${capture_BH_GNB.path}
    Merge pcap files    ${pcap_files_list}    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}

    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path}    ${testCaseDir}
    Dated Log     dss pcap file ${CAPTURE_L1L2_GNB_FS_ASIK_DSS_ATTACH.path} copied into ${testCaseDir}

# to rework ==> used only by 2574
Start capture Backhaul XP for DSS 2574 to remove in 2 weeks
    [Documentation]                Start capture Backhaul XP traces for DSS
    [Arguments]                    ${w_disconnect}=true

    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${LOG_PATH}/SCF.xml
    scf.load_scf	 ${current_scf_fullname}
    ${ipAddr}	 scf.get_value_from_scf   p_name=localIpAddr
    ...              dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${ipAddress_XPIFREMOTE}	 scf.get_value_from_scf   p_name=ipAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1
    ${ipAddress_amfIPAddress}	 scf.get_value_from_scf   p_name=amfIPAddress
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1

    ${filterBH_XP}   Catenate  '((ip.src == ${ipAddr}) && (ip.dst == ${ipAddress_XPIFREMOTE}) )
    ...                       || ( (ip.src == ${ipAddress_XPIFREMOTE}) && (ip.dst == ${ipAddr}))'
    set suite variable   ${filterBH_XP}

    Start capture BH data on GNB      w_disconnect=${w_disconnect}

# to rework ==> used only by 2574
Stop capture Backhaul XP for DSS 2574 to remove in 2 weeks
    [Documentation]                Stop capture Backhaul XP traces for DSS
    [Arguments]        ${name}=CellSetup
    ${CAPTURE_BH_GNB_FS_DSS}              Capture BH Set
    ${CAPTURE_BH_GNB_FS_DSS.prefix}       set Variable   BH.${name}
    ${CAPTURE_BH_GNB_FS_DSS.filter}     set variable     ${filterBH_XP}
    ${TestName}                         getFormattedTestName
    ${CAPTURE_BH_GNB_FS_DSS.name}       Set variable                          ${CAPTURE_BH_GNB_FS_DSS.prefix}
    ${CAPTURE_BH_GNB_FS_DSS.name}       Set variable                          ${CAPTURE_BH_GNB_FS_DSS.name}.${TestName}
    ${CAPTURE_BH_GNB_FS_DSS.path}       Set variable                          ${LOG_PATH}/${CAPTURE_BH_GNB_FS_DSS.name}.pcap
    Stop and download BH Log from GNB     capture=${CAPTURE_BH_GNB_FS_DSS}    filter=${filterBH_XP}

    set test variable   ${CAPTURE_BH_GNB_FS_DSS}

    Dated log             pdml files generation ...
    ${pdmlFile}=        pcap.Convert pcap to pdml file without filtering          ${CAPTURE_BH_GNB_FS_DSS.path}
    Dated log             pdml files generation completed ...

    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CAPTURE_BH_GNB_FS_DSS.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CAPTURE_BH_GNB_FS_DSS.path}    ${testCaseDir}
    Dated Log     dss Backhaul XP pcap file ${CAPTURE_BH_GNB_FS_DSS.path} copied into ${testCaseDir}

    [return]   ${pdmlFile}

################################################################################################################################
#               To test DSS PM counters
################################################################################################################################


Collect PM Counters File
    ${pm_files_path}       Set Variable                 ${LOG_PATH}/PM
    BuiltIn.Log     The PM counters file collected from gnb will be stored under : ${pm_files_path}
    ${latest_pm_file_name}   Counters.Collect PM files from BTS  ${pm_files_path}
    set Suite Variable    ${LATEST_FILE}       ${latest_pm_file_name}
    # BuiltIn.Log     \n***Latest pm counters file : ${LATEST_FILE}  console=yes
    Dated Log New Line     ***Latest pm counters file : ${LATEST_FILE}
    # Log to console  \n***Latest pm counters file : ${LATEST_FILE} ***

Collect PM
    Set suite variable    ${pmDir}    ${LOG_PATH}/PM
    Create Directory      ${pmDir}
    Dated log          LOG_PATH/PM:${pmDir}
    ${pm_latest}       Collect PM files from BTS    ${pmDir}
    Set suite variable    ${LATEST_FILE}    ${pm_latest}

Check 1586 Counters
    # [Arguments]         ${iteration}=0

    ${counter_values_1}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C00001
    ${counter_values_2}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C00002
    ${counter_values_3}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C00003
    ${counter_values_4}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C01001

    ${counter_values_5}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C01002
    ${counter_values_6}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C01003
    ${counter_values_7}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C02001
    ${counter_values_8}        Retrieve Latest Single Counter Value From Pm File         ${LATEST_FILE}               M55332C02002

    BuiltIn.Log       \n ***DSS DL Ratio: Number of DL Slots assigned to NR (M55332C00001)            console=yes
    BuiltIn.Log          ***DSS DL Ratio: Total number of available DL Slots (M55332C02001)            console=yes
    BuiltIn.Log          ***DSS DL Ratio: ${counter_values_1}/${counter_values_7}           console=yes
    # Log to console  \n***DSS DL Ratio: ${counter_values_1} ${counter_values_7}  ***

    BuiltIn.Log       \n ***DSS DL Ratio: Number of DL Slots assigned to NR with maximum share (M55332C00002)            console=yes
    BuiltIn.Log          ***DSS DL Ratio: Number of DL Slots assigned to NR with minimum share (M55332C00003)            console=yes
    BuiltIn.Log          ***DSS DL Ratio: ${counter_values_2}/${counter_values_3}           console=yes

    ${dl_ratio}    Evaluate     (round(${counter_values_1})/round(${counter_values_7}))*100

    BuiltIn.Log          \n***DSS DL Ratio : ${dl_ratio}           console=yes

    BuiltIn.Log       \n ***DSS UL Ratio: Number of UL PRBs assigned to NR (M55332C01001)            console=yes
    BuiltIn.Log          ***DSS UL Ratio: Total number of available UL PRBs (M55332C02002)            console=yes
    BuiltIn.Log          ***DSS UL Ratio: ${counter_values_4}/${counter_values_8}           console=yes

    BuiltIn.Log       \n ***DSS UL Ratio: Number of UL PRBs assigned to NR with maximum share (M55332C01002)            console=yes
    BuiltIn.Log          ***DSS UL Ratio: Number of UL PRBs assigned to NR with minimum share (M55332C01003)            console=yes
    BuiltIn.Log          ***DSS UL Ratio: ${counter_values_5}/${counter_values_6}           console=yes

    ${ul_ratio}    Evaluate     (round(${counter_values_4})/round(${counter_values_8}))*100

    BuiltIn.Log        \n***DSS UL Ratio : ${ul_ratio}           console=yes

# deviation_in_percent = 10 %, the target are 70% for DL DSS and 70 % for UL DSS , linked to DL and UL pattern used for the test
    ${min}=                         Evaluate                                70 * (100 - 10) / 100
    ${max}=                         Evaluate                                70 * (100 + 10) / 100
    ${status}=                      Evaluate                                ${min} <= ${dl_ratio} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average DL DSS Ratio REACHED: expected = 70 , current = ${dl_ratio}
    ...    ELSE
    ...    Dated Log                Average DL DSS RATIO NOT REACHED: expected = 70, current = ${dl_ratio}
    Run Keyword If                  '${status}'!='True'                     Fail    DL DSS Ratio

    ${status}=                      Evaluate                                ${min} <= ${ul_ratio} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average UL DSS Ratio REACHED: expected = 70 , current = ${ul_ratio}
    ...    ELSE
    ...    Dated Log                Average UL DSS RATIO NOT REACHED: expected = 70, current = ${ul_ratio}
    Run Keyword If                  '${status}'!='True'                     Fail    UL DSS Ratio

# get PM files
Collect gNB files
    Create directories for log
    ${dest_dir}=    SET VARIABLE    ${LOG_PATH}
    log to console       !!! dest_dir of PM counter collection :  ${LOG_PATH}
    ${collection_name_dir}=    SET VARIABLE    gnb_pm_counters
    5GC0001329-A_Counters_Keywords.Generic Collect PM files
    ...    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    ${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    ${dest_dir}
    ...    ${collection_name_dir}


# to get PM file at the end of  ths test
Collect PM Counters file and filter last file coam
    Collect PM Counters file coam
    # Filter last PM Counters file coam

Collect PM Counters file coam
   [Arguments]         ${target_dir}=${LOG_PATH}
    BuiltIn.Log To Console    \nuploading pm file from coam
    ${webservice}				Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=coam
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${target_dir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters

Filter last PM Counters file coam
    ${rc}    ${all_pm_file}    Run And Return Rc And Output    ls -r ${LOG_PATH}/${coam_pm_file_path}/PM*ANY.xml
    ${result}    set variable if    '${rc}'=='${0}'    pass    fail
    run keyword if     '${result}'=='fail'    Fail    no measurement file available
    ${temp}    split to lines    ${all_pm_file}
    ${pm_file_name_with_path}    set variable    ${temp[0]}
    ${pm_file_name}    replace string     ${pm_file_name_with_path}    ${LOG_PATH}/${coam_pm_file_path}/    ${EMPTY}

    Run    mv ${pm_file_name_with_path} ${LOG_PATH}/.
    Run    rm ${LOG_PATH}/${coam_pm_file_path}/PM*ANY.xml
    Run    mv ${LOG_PATH}/PM*ANY.xml ${LOG_PATH}/${coam_pm_file_path}/.

    ${file_string}   Get Binary File   ${pm_file_name_with_path}
    ${file_string}  Replace String    ${file_string}  ><  >\n<   count=-1
    Create File    ${LOG_PATH}/pm.xml    ${file_string}

    BuiltIn.Set Test Variable    ${pmCounter_xml_file}    ${LOG_PATH}/pm.xml

    Run Keyword if    '${bts_type}'=='classical'    Return From Keyword    ${pm_file_name_with_path}

    @{pm_parts}   split_string   ${pm_file_name}   _
    ${pm_file_date}    set variable   ${pm_parts[2]}
    @{pm_file_chars}    split string to characters    ${pm_file_date}
    ${pm_file_yyyymmdd}    set variable    ${pm_file_chars[0]}${pm_file_chars[1]}${pm_file_chars[2]}${pm_file_chars[3]}-
    ${pm_file_yyyymmdd}    set variable    ${pm_file_yyyymmdd}${pm_file_chars[4]}${pm_file_chars[5]}-${pm_file_chars[6]}${pm_file_chars[7]}

    ${pm_file_time}    set variable   ${pm_parts[3]}
    @{pm_file_chars}    split string to characters    ${pm_file_time}
    ${pm_file_hhmmss}    set variable    ${pm_file_chars[0]}${pm_file_chars[1]}:${pm_file_chars[2]}${pm_file_chars[3]}:
    ${pm_file_hhmmss}    set variable    ${pm_file_hhmmss}${pm_file_chars[4]}${pm_file_chars[5]}

    ${pm_file}          set variable    ${pm_file_yyyymmdd} ${pm_file_hhmmss}

    ${diff}    subtract date from date    ${pm_file}    ${time_before_detach}    result_format=number     exclude_millis=true
    ${meas_period_sec}    evaluate    ${measurement_period_in_min}*60

    ${result}    set variable if    0 < ${diff} < ${meas_period_sec}   pass    fail
    run keyword if     '${result}'=='fail'    Fail    no valid measurement file found


Check Tput over GP period
    [Documentation]    Computes and checks the Tput UL and DL between start_per_time and end_per_time
    ...                Tputs should be equal to maximum Tputs all along the test, with 5% margin
    [Arguments]    ${nb_cell}=1    ${dl_expected_tput}=550    ${ul_expected_tput}=100

    BuiltIn.log     nb_cell=${nb_cell}
    #M55319C00001: MEAS_PERIOD_NR_PDCP_REPORT1
    #M55319C0200x : DL_VOL_TX_NSA_QOS_GRP_0x: DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C02009 : Tput PDCP DL en bytes sur QoS 9
    #M55319C0600x: UL PDCP SDU volume received for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C06009: Tput PDCP UL en bytes sur QoS 9

    #M55304C00001: Duration of the measurement period for the NR MAC PDU throughput
    # les compteurs suivants sont en bytes
    #M55304C01001 a 28: Initial transmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C02001 a 28: Initial and retransmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput
    #M55304C03001 a 28: Initial transmissions volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH without retrans Tput
    #M55304C04001 a 28: Initial and retransmission volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH with retrans Tput
    #M55304C05001 a 28: Initial transmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C06001 a 28: Initial and retransmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput

    ${NRCELL_ID}                       set variable       1
    # ${counter_values_M55319C02009}  Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55319C02009   ${NRCELL_ID}
    # ${counter_values_M55319C00001}  Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55319C00001   ${NRCELL_ID}
    ${counter_values_M55319C02009}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C02009
    ${counter_values_M55319C00001}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C00001
    BuiltIn.Log   ***DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 09 (M55319C02009) = ${counter_values_M55319C02009}   console=yes
    BuiltIn.Log   ***Duration of the measurement period for the PDCP Report 1 (M55319C00001) = ${counter_values_M55319C00001}       console=yes

    ${Tput_PDCP_DL}                    set variable        ${counter_values_M55319C02009}
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     set variable        ${counter_values_M55319C00001}

    ${tputDL}=              evaluate        8 * ${Tput_PDCP_DL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    Dated log          TPUT PDCP DL = ${tputDL} Mbps

    ${counter_values_M55319C06009}     Retrieve Latest Single Counter Value From Pm File     ${LATEST_FILE}   M55319C06009
    BuiltIn.Log   ***UL PDCP SDU volume received for NSA Bearer - QoS Group 09 (M55319C02009) = ${counter_values_M55319C06009}   console=yes
    ${Tput_PDCP_UL}                    set variable        ${counter_values_M55319C06009}

    ${tputUL}=              evaluate        8 * ${Tput_PDCP_UL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    Dated log          TPUT PDCP uL = ${tputUL} Mbps

    ${dl_min_tput}           evaluate    round(${dl_expected_tput}) * 0.9
    ${ul_min_tput}           evaluate    round(${ul_expected_tput}) * 0.9

    Should be true    ${tputDL} >= ${dl_min_tput}
    Should be true    ${tputUL} >= ${ul_min_tput}

################################################################################################################################
#              END :  To test PM
################################################################################################################################

################################################################################################################################
#               To test DSS Alarms
################################################################################################################################

Check DSS Active Alarms
    [Tags]      ALARMS_CHECK
    [Arguments]    ${fault_id}

    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}

    Fault Should Be Present   fault_id=${fault_id}

    [Teardown]    OAM Disconnect                          ${GNB_DU.oam}

Check Clear DSS Active Alarms
    [Tags]      ALARMS_CHECK
    [Arguments]    ${fault_id}

    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}

    Fault Should Not Be Present   fault_id=${fault_id}

    [Teardown]    OAM Disconnect                          ${GNB_DU.oam}

Fault Should Be Present
    [Documentation]
    ...
    [Arguments]    ${fault_id}
    Dated log          KW - Fault Should Be Present fault_id=${fault_id}
    ${active_alarms}     OAM Get Active Alarms                   oam=${GNB_DU.oam}     textFormat=${False}
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    ${alarm_name_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
         ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
         ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    faultName
         Append To List    ${alarm_id_list}    ${tmp_id}
         Append To List    ${alarm_name_list}    ${tmp_name_id}
    END
    Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    Dated log     Active alarms: alarm_name_list=${alarm_name_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain     ${list}    ${fault_id}

Fault Should Not Be Present
    [Documentation]
    ...
    [Arguments]    ${fault_id}
    Dated log     KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}     OAM Get Active Alarms                   oam=${GNB_DU.oam}     textFormat=${False}
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
         ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
         Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain     ${list}    ${fault_id}

Check Dss active Alarm Should not be present
    # 7507 EFaultId_EnDssSetupIncompMsgSet5gAl
    # 7508 EFaultId_EnDssSetupMaxPartnerExceededSet5gAl - NR CRM Client doesn't get EN-DSS-SETUP-RESPONSE
    # 7509 EFaultId_EnDssSetupNoResponse5gAl
    # 7510 EFaultId_EnDssCellCoordResourceConfigConflict5gAl
    # 7511 EFaultId_EnDssKeepAliveTimeout5gAl
    # 7512 EFaultId_EnDssCellCoordResourceConfigFailure5gAl
    # 7517 EFaultId_EnDssDlCellCoordDssConfigError5gAl
    # 7518 EFaultId_EnDssUlCellCoordResourceConflictConfig5gAl
    # 7519 EFaultId_EnDssUlCellCoordResourceConflictNonMatchingConfig5gAl
    # 7520 EFaultId_EnDssUlCellCoordDssConfigError5gAl
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7507
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7508
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7509
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7510
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7511
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7512
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7517
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7518
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7519
    common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7520

    # check also that fault IncorrectCellParameterSetting (id=7516) for Cell with severity=Degraded is not present
    # only raised a WARNING in this case as severity is Degraded => check Syslog trace in this case !!!
    # exemple from Syslog :
    # rea (Msg1) overlaps PUCCH area (Msg3), msg1FrequencyStart:6 must be configured between 7 and 42
    # 233072 03.01 16:49:20.396 [192.168.255.129] a1 FCT-2515-2-Cprt <2023-01-03T15:49:20.505584Z> 85-cp_rt
    # INF/COMMON/FaultManager.cpp:171 Raising fault IncorrectCellParameterSetting (id=7516) for Cell (id=1) with severity=Degraded
    robot_extension.Run Keyword And Warn On Failure     common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7516
    # gNB CpRtCell configuration update failure', 'alarmDetailNbr': 7506,
    robot_extension.Run Keyword And Warn On Failure     common_Dss_Keywords.Check Clear DSS Active Alarms   fault_id=7506

################################################################################################################################
#              END :  To test DSS Alarms
################################################################################################################################

Enable BLER on F1 side
    [Documentation]                 KW used to enable BLER on DU side. BLER profile is supposed to be
    ...                             configure inside WTS cfg file:
    ...                                     <testModeBler index="0">
    ...                                         <dlBlerTargetUe index="0">200</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="1">100</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="2">100</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="3">0</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="4">0</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="5">0</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="6">0</dlBlerTargetUe>
    ...                                         <dlBlerTargetUe index="7">0</dlBlerTargetUe>
    ...                                         <ulBlerTargetUe>0</ulBlerTargetUe>
    ...                                     </testModeBler>
    ...                             Call to taf function lteemu.ue_testmode_set_param is replaced by a custom call as the option test_mode
    ...                             no more exist and is now testmode (no _).
    [Arguments]                     ${ueSetting}

    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=egate
    ...                         ssh_user=ute
    ...                         ssh_pass=ute

    ute_wtssim.execute_egate_command    cmd=ue_testmode_set id=${ueSetting.ue} bearer=2 testmode=bler profile_index=0 action=activate    alias=egate
    ute_wtssim.teardown_egate    alias=egate

Disable BLER on F1 side
    [Documentation]                 KW used to disable BLER on DU side. . BLER profile is supposed to be
    ...                             configure inside WTS cfg file
    ...                             Call to taf function lteemu.ue_testmode_set_param is replaced by a custom call as the option test_mode
    ...                             no more exist and is now testmode (no _).
    [Arguments]                     ${ueSetting}

    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=egate
    ...                         ssh_user=ute
    ...                         ssh_pass=ute

    ute_wtssim.execute_egate_command   cmd=ue_testmode_set id=${ueSetting.ue} bearer=2 testmode=bler profile_index=0 action=deactivate   alias=egate
    ute_wtssim.teardown_egate    alias=egate

######################################################################################################################
#  Basic procedure
######################################################################################################################

Initialize Colors
    [Documentation]    :   Initialize Colors
    ${BLACK_C}   set variable    "\\033[30m"
    ${black}=   Evaluate   "${BLACK_C}"
    Set suite Variable  ${black}
    ${red}=   Evaluate   "${RED}"
    Set suite Variable  ${red}
    ${blue}=   Evaluate   "${BLUE}"
    Set suite Variable  ${blue}
    ${green}=   Evaluate   "${GREEN}"
    Set suite Variable  ${green}
    ${normal}=   Evaluate   "${NORMAL}"
    Set suite Variable  ${normal}

Connect to test pc proxy
    [Documentation]    :
    ...    It is needed when there is different test_pc for each unit.
    ...    In such case "tl.test_pc.connections" is required
    [Arguments]    ${gnb_id}
    ${gnb_test_pc}=    common_Dss_Keywords.Get Test PC for Object    ${tl.gnbs[${gnb_id}]}
    ${alias}=    Set variable    gnb-${gnb_id}-test_pc
    ssh.Connect_to      hostname=${gnb_test_pc.default_ssh_connection_details.addr}
    ...                 username=${gnb_test_pc.default_ssh_connection_details.username}
    ...                 password=${gnb_test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Get Test PC for Object
    [Documentation]    :
    [Arguments]    ${obj}
    ${result}=    Evaluate    [test_pc for test_pc in $tl.test_pcs for obj in test_pc.connections if obj is $obj][0]
    [Return]    ${result}

Connect to gNB Common Unit
    [Documentation]    :
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${asxx_alias}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    ${test_pc_connection_count}=   Get Length    ${tl.test_pc.connections}
    # ${proxy}   Run keyword If   ${test_pc_connection_count}==0       common_Dss_Keywords.Connect to test pc proxy    gnb_id=${gnb_id}
    # ...    ELSE    Set variable    ${None}
    ${proxy}    Set variable    ${None}
    ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}

Check Airscale Board Status
    [Documentation]    [PRIVATE]
    ...
    ...     :param alias:               ssh connnection alias to common unit board
    ...     :param board_id:            Board ID
    ...     :param CCS_Daemon_node_id:  CC&S Node Id
    [Arguments]     ${alias}  ${board_id}    ${CCS_Daemon_node_id}
    ssh.Force Reconnect    ${alias}
    ${sys_result}=  ssh.execute
    ...     command=PYTHONPATH=/opt/hwmt/python python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n ${CCS_Daemon_node_id} | grep ${board_id}
    ...     connection=${alias}
    ...     timeout=60 sec
    Should Contain  ${sys_result}   ready[0]

Wait for gNB Common and Capacity unit up
    [Documentation]    :
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...     :param du_id:       Id of DU                        [0.. ]  default=0
    ...     :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...     :param timeout:     Time until Common+CapacityUnit have to be up  default=10 minutes
    [Arguments]    ${gnb_id}=0    ${du_id}=0  ${comu_id}=0  ${timeout}=10 min
    ${capu_num}=    Get length    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].capacity_units}
    ${comu_ssh_alias}=  Wait until keyword succeeds     ${timeout}  10 sec
    ...     common_Dss_Keywords.Connect to gNB Common Unit  gnb_id=${gnb_id}  du_id=${du_id}    comu_id=${comu_id}
    # ${CCS_Daemon_node_id}=    gnb_internal.get_CCS_Daemon_node_id    connection=${comu_ssh_alias}
    ${CCS_Daemon_node_id}=    Airscales.getNodeId        connection=${comu_ssh_alias}
    @{boards_ids}=    Run keyword if    '${CCS_Daemon_node_id}'=='0x1011'
    ...    Create List    0x10    0x12    0x13    0x14
    ...    ELSE IF    '${CCS_Daemon_node_id}'=='0x2011'
    ...    Create List    0x20    0x22    0x23    0x24
    ...    ELSE    Fail    Wrong node id ${CCS_Daemon_node_id}!
    ${end_index}=    Evaluate    ${capu_num}+${1}
    @{existing_boards_ids}=    Get slice from list    ${boards_ids}    start=${0}    end=${end_index}
    FOR    ${board_id}    IN    @{existing_boards_ids}
         Wait until keyword succeeds     ${timeout}    20 sec    common_Dss_Keywords.Check Airscale Board Status
         ...     alias=${comu_ssh_alias}   board_id=${board_id}   CCS_Daemon_node_id=${CCS_Daemon_node_id}

    END

Private Restart Gnb Classical
    [Documentation]                 Restart sequence for case GNB is in classical configuration
    [Arguments]                     ${GNBCallback}=None                     ${APCallback}=None
    ...                             ${isOAMRebooted}=False
    Dated log                       Restart Gnb Classical :isOAMRebooted=${isOAMRebooted}
    Run Keyword if                  ${isOAMRebooted}==False
    ...                             Airscale Soft Reboot                    ${GNB_DU}
    Airscale Soft Reboot            ${AP_DU}
    Dated Log                       Waiting for airscales to come back
    Run keyword and ignore error    common_Dss_Keywords.Wait for gNB Common and Capacity unit up    timeout=3 min
    ${gnb_status}=                  WA Airscale Wait For Ready              ${GNB_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    GNB is not ready
    ${ap_status}=                   WA Airscale Wait For Ready              ${AP_DU}
    Run Keyword If                  '${gnb_status}'!='Ready'                Fail    AP is not ready
    Get TL Info Struct
    Run Keyword if                  '${GNBCallback}'!='None'                ${GNBCallback}
    Run Keyword if                  '${APCallback}'!='None'                 ${APCallback}
    WA DCI Wait for service         ${AP_DU}
    F1 Wait Link Classical
    GNSS Check and run
    IRfHead Check Service

Set Reset Loop Counter
    [Documentation]                 INTERNAL USAGE
    ...                             ddal -s ddal_boot_set_reset_loop_count 0
    [Arguments]                     ${rlc_number}=0

    Dated log                       Initialize reset_loop_count on ${GNB_DU.name} (command =ddal -s ddal_boot_set_reset_loop_count ${rlc_number})
    ${alias}                        SSH Connect                          ${GNB_DU.sys[0].M}
    ${file}                         SSH Cmd                              command=ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...                             alias=${alias}

Restart
    [Tags]                          RESTART
    [Arguments]                     ${isOAMRebooted}=${False}       ${OwnTLReset}=${False}    ${GNBCallback}=None
    Run keyword if      '${OwnTLReset}'=='${False}'      Restart TL       isOAMRebooted=${isOAMRebooted}
    ...                                                                   GNBCallback=${GNBCallback}
    ...         ELSE       Private Restart Gnb Classical     isOAMRebooted=${isOAMRebooted}

##################################################################################################################
#  WTS  Setup
##################################################################################################################

Clean Old WTS Logs
    [Documentation]                 Clean unnecessary logs created
    ${alias}            SSH Connect         host=${HOST_EPCSIM}
    Run Keyword And Ignore Error       ssh.execute    cd ${tl.core.dir_path} && sudo rm *.log.* && sudo rm *.tgz
    ...                                                          connection=${alias}

Launch WTS
#   [Arguments]                 ${command}    ${egate_alias}=egate    ${edaemon_alias}=edaemon
    # [Arguments]                 ${egate_alias}=egate    ${edaemon_alias}=edaemon
    [Arguments]                 ${egate_alias}=egate
    ${msg}=     Catenate     [From Launch WTS] Connecting to: ${tl.core.default_ssh_connection_details.addr}, Port: ${tl.core.egate_port}
    ...                         Alias: ${egate_alias}
    BuiltIn.Log    \n${msg}     console=yes
    wts.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=${egate_alias}
    ...                         ssh_user=ute
    ...                         ssh_pass=ute
    ${ute_wtssim_interface}    Get Library Instance    wts
    set suite variable     ${wtsObj}      ${ute_wtssim_interface}

Setup WTS
    [Arguments]              ${remove_logs}=False

    Run keyword if    '${remove_logs}'=='True'    SSH Connect         host=${HOST_EPCSIM}
    Run keyword if    '${remove_logs}'=='True'    ssh.execute    cd ${tl.core.dir_path} && sudo rm *.log.* && sudo rm *.tgz
    ...                                                          connection=${HOST_EPCSIM.alias}

    CallSetup.WTS Setup

Start WTS and setup X2 link
    # [Arguments]                 ${egate_alias}=egate    ${edaemon_alias}=edaemon
    [Arguments]                 ${egate_alias}=egate
    Setup WTS    remove_logs=True
    Launch WTS   egate_alias=${egate_alias}

Start WTS
   # [Arguments]                 ${egate_alias}=egate    ${edaemon_alias}=edaemon    ${shouldUseLua}=${False}    ${nbUe}=1
   [Arguments]                 ${egate_alias}=egate    ${shouldUseLua}=${False}    ${nbUe}=1
    Dated log     Start WTS WITH shouldUseLua=${shouldUseLua}
    Setup WTS Only    shouldUseLua=${shouldUseLua}    nbUe=${nbUe}
    Launch WTS   egate_alias=${egate_alias}

my WTS Configure upon format
    [Arguments]                     ${shouldUseLua}=${True}
    ...                             ${luaFile}=${EMPTY}
    Dated log     my WTS Configure upon format WITH shouldUseLua=${shouldUseLua}
    Run Keyword if                  ${shouldUseLua}
    ...                             my WTS Configure                           ConfigFileName=${luaFile}
    ...   ELSE                      my WTS Configure                           ConfigFileName=${tl.core.cfg_filename}
    ${ute_wtssim_interface}    Get Library Instance    wts
    set suite variable     ${wtsObj}      ${ute_wtssim_interface}

my WTS Configure
    [Documentation]                 Set configuration for WTS from fiole as pointed in __init__.py
    # [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    [Arguments]                     ${ConfigFileName}=${tl.core.cfg_filename}
    Dated Log                       \tConfiguring WtsEmu with ${tl.core.dir_path}/${ConfigFileName}
    wtsemu.Configure                file=${tl.core.dir_path}/${ConfigFileName}
    # Check we reach active state
    ${pattern}                   set variable if    '${NWtype}' == 'SA+NSA'    NG link is Up      CHANGE STATE: ACTIVE - SimMode is ready now
    Dated log    wait for ${pattern}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=${pattern}
    ...                             timeout=90
    # wtsemu.Read Wtsemu Output Until Re
    # ...                             expected=CHANGE STATE: ACTIVE - SimMode is ready now
    # ...                             timeout=45
    # sleep                           30s

#---------------new way to start WTS-------------------------------------------------------------------------------------------------[150 characters]

Send Egate Command and verify output
    [Documentation]
    ...    Same as keyword `ute_wtssim.execute`_ egate command and wait for data.
    ...
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...
    ...    It sends the given ``cmd`` to egate execute.
    ...    ``timeout`` defines the  timeout for this operation.
    ...    ``return_output`` boolean ${False} or ${Ture} indicate whether egate log should be printed out.
    ...    If given regexp ``pass_regexp`` is found in the command response the KW passes whereas if
    ...    the given ``fail_regexp`` is found in the command output the KW fails. The first occurance decides the result.
    ...    If ``return_output`` is True the egate console output will be returned to the caller.
    ...
    ...    | cmd            | Command to execute                                                |
    ...    | timeout        | Timeout for this operation                                        |
    ...    | return_output  | boolean Flag indicating whether egate log should be printed out   |
    ...    | pass_regexp    | Regexp indicating that the command passed                         |
    ...    | fail_regexp    | Regexp indicating that the command failed                         |
    ...    | wts_alias      | alias name to handle egate for ute_wtssim                         |
    ...
    ...    *Example*
    ...    |  `Start WTS for Airphone` |
    ...    |  `Config WTS for Airphone` |
    ...    |   Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ...   ${wts_alias}=ap_egate
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}   alias=${wts_alias}
    [Return]   ${output}

Kill WTS Services
    [Documentation]
    ...    Keyword is used to terminate dedicated WTS service and ute_wtssim alias together.
    ...    Terminate egate and edaemon services running with the given port id.
    ...    Teardown ute_wtssim alias by using given alias name.
    ...
    ...    | egate_port     | used egate port                           |
    ...    | edaemon_port   | used edaemon port                         |
    ...    | wts_alias      | used ute_wtssim alias for egate console   |
    ...    | edaemon_alias  | used ute_wtssim alias for edaemon         |
    ...
    ...    *Example*
    ...    | Kill WTS Services  | egate_port=10000  | edaemon_port=22222  | wts_alias=wts1  | edaemon_alias=edaemon1  |
    ...
    [Arguments]   ${egate_port}=${tl.core.egate_port}   ${edaemon_port}=${tl.core.edaemon_port}
    ...   ${wts_alias}=ap_egate   ${edaemon_alias}=ap_edaemon

    Teardown Egate Connection for Airphone   wts_alias=${wts_alias}
    Teardown Edaemon Connection for Airphone   edaemon_alias=${edaemon_alias}

    BuiltIn.Log   ${\n}Kill WTS Services with egate port: ${egate_port}, edaemon port: ${edaemon_port}   console=${True}
    OperatingSystem.Run   sudo pkill -f './egate.* --port ${egate_port}'
    OperatingSystem.Run   sudo pkill -f './edaemon.* --port ${edaemon_port}'

    BuiltIn.Sleep  1s

    OperatingSystem.Run   sudo pkill -9 -f './egate.* --port ${egate_port}'
    OperatingSystem.Run   sudo pkill -9 -f './edaemon.* --port ${edaemon_port}'
    BuiltIn.Log   WTS services are killed!   console=${True}

Teardown Egate Connection for Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown.
    ...    Could be used as teardown keyword for Start WTS for Airphone.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...
    ...    *Example*
    ...    | Start WTS for Airphone |
    ...    | Teardown Egate Connection for Airphone |
    ...
    [Arguments]   ${wts_alias}=ap_egate
    Run Keyword And Ignore Error   ute_wtssim.teardown_egate   alias=${wts_alias}


Teardown Edaemon Connection for Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown.
    ...    used as teardown keyword for Start WTS for Airphone.
    ...
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...
    ...    *Example*
    ...    | Start WTS for Airphone |
    ...    | Teardown Edaemon Connection for Airphone |
    ...
    [Arguments]   ${edaemon_alias}=ap_edaemon
    Run Keyword And Ignore Error   ute_wtssim.teardown_edaemon   alias=${edaemon_alias}


Start WTS for Airphone
    [Documentation]
    ...    Used for Precondition: GNB and Airphone, at Suite Setup or Testcase setup
    ...    Will setup egate alias ap_egate for keyword  `Send Egate Command and verify output` previous
    ...    WTS processes should be killed at earlier step, before TL reboot
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...    | remove_logs    | remove existing wts logs                      |
    ...    | egate_port     | used egate port                               |
    ...    | edaemon_port   | used edaemon port                             |
    ...
    ...    *Example*
    ...    | Kill WTS Services |
    ...    | Start WTS for Airphone      | wts_alias=ap_egate        |
    ...
    [Arguments]   ${wts_alias}=ap_egate   ${edaemon_alias}=ap_edaemon   ${remove_logs}=${False}
    ...   ${egate_port}=${tl.core.egate_port}   ${edaemon_port}=${tl.core.edaemon_port}
    BuiltIn.log     wts_alias=${wts_alias}  console=${True}
    Teardown Egate Connection for Airphone     wts_alias=${wts_alias}
    Teardown Edaemon Connection for Airphone   edaemon_alias=${edaemon_alias}

    Run Keyword If   ${remove_logs}   OperatingSystem.Run   cd ${tl.core.dir_path} && sudo rm *log*

    ${edaemon_id}   OperatingSystem.Run   sudo pgrep -af 'edaemon.* --port ${edaemon_port}' | grep -v pgrep
    ${egate_id}     OperatingSystem.Run   sudo pgrep -af 'egate.* --port ${egate_port}' | grep -v pgrep

    Run Keyword If   '${edaemon_id}'=='${EMPTY}'   Run Keywords
    ...         OperatingSystem.Run   cd ${tl.core.dir_path} && sudo .\\/edaemon --port ${edaemon_port}
    ...   AND   BuiltIn.Sleep   2s   reason=wait for WTS edaemon startup

    # prevent egate lockup when being started via Run Kw
    Run Keyword If   '${egate_id}'=='${EMPTY}'   Run Keywords
    # ...         OperatingSystem.Run   cd ${tl.core.dir_path} && .\\/egate --port ${egate_port}
    ...         OperatingSystem.Run   cd ${tl.core.dir_path} && .\\/egate --port ${egate_port} > egate.out.${egate_port} 2>&1
    ...   AND   BuiltIn.Sleep   5s   reason=wait for WTS egate startup

    ute_wtssim.setup_egate   egate_port=${egate_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${wts_alias}   save_egate=${True}
    ute_wtssim.setup_edaemon   edaemon_port=${edaemon_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${edaemon_alias}
    ${wts_status}   Run Keyword And Return Status
    ...   Send Egate Command and verify output   cmd=sim_info   pass_regexp=Process ID   wts_alias=${wts_alias}
    ${sim_status}   Run Keyword And Return Status
    ...   Send Egate Command and verify output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}

    ${sim_status}   Run Keyword If  not $sim_status
    ...             BuiltIn.log    sim_state_disp FAILED!!!    level=ERROR     console=${True}
    ...   ELSE      Set Variable    ${sim_status}

    ${ute_wtssim_interface}    Get Library Instance    ute_wtssim
    set suite variable     ${wtsObj}      ${ute_wtssim_interface}

    Run Keyword If   $wts_status==False or $sim_status==False   Fail   WTS is not correctly started

Config WTS for Airphone
    [Documentation]
    ...     Configure WTS with default config file in __init__.py .
    ...     The parameter ``pass_regexp`` can be used to wait for a string in the egate log or ``timeout``.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...    | cfg_file   | path of wts config file to be used        |
    ...
    ...    *Example*
    ...    -  NSA TL
    ...    | Start WTS for Airphone |
    ...    | Config WTS for Airphone | pass_regexp=SystemInformationBlockType2 updated |
    ...    - SA TL
    ...    | Start WTS for Airphone |
    ...    | Config WTS for Airphone | pass_regexp=SystemInformationBlockType1-NR updated | timeout=600 |
    ...
    [Arguments]   ${pass_regexp}=${None}   ${timeout}=30   ${wts_alias}=ap_egate   ${cfg_file}=${tl.core.cfg_filename}
    ute_wtssim.execute egate command and wait for data   cmd=cfg file=${cfg_file}   pass_regexp=${pass_regexp}
    ...   timeout=${timeout}   alias=${wts_alias}

My private WTS Start processes
    [Documentation]                 Start eDaemon and eGate, Establish an eGate connexion
    ...                             and remove configure of WTSEmu eGate controller.
    ...
    ...                             *Argument details:*
    ...                             - alias: VM connection alias (default value = dynamically retrieved)
    ...                             - telnet_egate_addr: VM eGate address (default value = dynamically retrieved)
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    ...                             ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    # The following code is added to take into account that sometimes, the eGate is still running.
    # In these cases, when eGate is still running, this blocks the new session.
    # A solution is: connect to the eGate and launch the "reset" then "exit" commands.
    Dated log                       Starting WTS clean-Up
    wtsemu.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}             directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}
    wtsemu.Configure Wtsemu Egate    egate_ssh_alias=${alias}               directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tl.core.egate_port}
    sleep                           3s
    Run Keyword    wtsemu.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${tl.core.egate_port}
    sleep                           5s
    Dated Log                       \tResetting WTS configuration - Done via "script" KW
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script       file=${CURDIR}/WtsEmuReset.sce
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script_status
    robot_extension.Run Keyword And Warn On Failure                         wtsemu.script_stop
    sleep                           3s

    # Start eDaemon and eGate
    Dated log                       Starting WTS processes
    wtsemu.Configure Wtsemu Edaemon  edaemon_ssh_alias=${alias}             directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}
    wtsemu.Configure Wtsemu Egate    egate_ssh_alias=${alias}               directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}
    # Launch telnet command
    Dated Log                       \tConnecting to: ${telnet_egate_addr}, Port: ${tl.core.egate_port}
    sleep                           3s
    wtsemu.Start Wtsemu             egate_console_ip=${telnet_egate_addr}
    ...                             egate_port=${tl.core.egate_port}
    sleep                           5s
    Dated Log                       \tResetting WTS configuration - Done via "reset_wtsemu_cfg" KW
    wtsemu.Reset_Wtsemu_Cfg

#---------------old way to start WTS-------------------------------------------------------------------------------------------------[150 characters]
Setup WTS Only
    [Documentation]                 Clean WTS (processes, logs), restart ePC simulator
    ...                             and configure it
    [Arguments]                     ${telnet_egate_addr}=${tl.core.default_ssh_connection_details.addr}
    ...                             ${nbUe}=1
    ...                             ${shouldUseLua}=${True}
    Dated log     Setup WTS Only WITH shouldUseLua=${shouldUseLua}
    # Clean WTS from process and logs point of view
    ${alias}		                SSH Wait For Connect                    host=${HOST_EPCSIM}
    Dated Log New Line              Starting WTS setup (WTS:IP=${HOST_EPCSIM.sshConnection.addr})
    # WTS Clear
    # Cloud only
    Run Keyword If                  ${TLConfig.isGnbCloud} and not ${isAic}
    ...                             WTS Set Backhaul IP                     ${alias}
    # Init lua config file with nb of UE
    ${LuaFileName}                  TxtConfig Init                          nbUe=${nbUe}
    set global variable             ${LuaFileName_generated}                ${LuaFileName}
    # Configure eDaemon and eGate
    WTS Start processes             telnet_egate_addr=${telnet_egate_addr}
    # Launching configuration
    my WTS Configure upon format       shouldUseLua=${shouldUseLua}            luaFile=${LuaFileName}


Store Current swconfig from Airphone
    [Documentation]    :
    ...    in case testcase needs to modify swconfig.txt on Airphone, collect current one as backup, Set path as Suite Variable ${P_ORIG_AP_SWCONFIG}
    ...
    ...    :param ue_id:      Id of ue                       [0.. ]  default=0
    ...    :param comu_id:    Id of Common Unit              [0..1]  default=0
    ...    :param target_dir: where to save original swconfig.txt, default with testline.Get Test Suite Config Directory
    ...
    ...    **Example:**
    ...    | wts_ue.Store Current swconfig from Airphone
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${ORIG_SWCONFIG}=    common_Dss_Keywords.Get swconfig from Airphone    ue_id=${ue_id}    comu_id=${comu_id}   target_dir=${target_dir}
    Run    mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_AP_SWCONFIG}    ${ORIG_SWCONFIG}.orig

Connect to Airphone Common Unit
    [Documentation]    :
    ...     setup ssh connection to Airphone Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param ue_id:             Id of UE                       [0.. ]  default=0
    ...     :param ue_comu_id:        Id of AP Common Unit           [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${ap_alias}=   connect.Connect to Airphone Common Unit    ue_id=0  ue_comu_id=0
    ...     | ssh.execute     command=uptime  connection=${ap_alias}
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}  ${alias}=ssh-ap-${ue_id}-${ue_comu_id}
    ssh.Connect_to      hostname=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.addr}
    ...                 username=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.username}
    ...                 password=${tl.ues[${ue_id}].l1.common_units[${ue_comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    [Return]    ${alias}

#########################################################################################################
#               log collection
#########################################################################################################


Get swconfig from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    common_Dss_Keywords.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.Download File    remote_path=/ffs/run/swconfig.txt    local_path=${target_dir}/ap_swconfig.txt    connection=${ap_alias}
    [Return]    ${target_dir}/ap_swconfig.txt


Get APL3 log from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   startup_l3_log for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    common_Dss_Keywords.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    Dated log                       Check the startup_l3.log file: zipped or not zipped
    ssh.send command    ls -ltr /ram/startup_l3.log.xz   connection=${ap_alias}
    ${output_1}=    ssh.read output   connection=${ap_alias}
    ssh.send command    ls -ltr /ram/startup_l3.log   connection=${ap_alias}
    ${output_2}=    ssh.read output   connection=${ap_alias}
    ${lenght_1}                     Get Length                              ${output_1}
    ${length_2}                     Get Length                              ${output_2}
    Dated log                       AP startup_l3 length_xz:${lenght_1} - lenght_non_xz:${length_2}
    ${APL3_log}=    Set Variable If                 ${lenght_1} != 0                        startup_l3.log.xz
    ...                                             ${length_2} != 0                        startup_l3.log
    ...                                                                                     startup_l3.log
    ssh.Download File    remote_path=/ram/${APL3_log}    local_path=${target_dir}/ap_${APL3_log}    connection=${ap_alias}
    [Return]    ${target_dir}/ap_${APL3_log}

Get iPhy.xml file from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None    ${file_name}=ap_new_iphy.xml
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    common_Dss_Keywords.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.Download File    remote_path=/ffs/run/simmode/new_iphy.xml    local_path=${target_dir}/${file_name}    connection=${ap_alias}
    [Return]    ${target_dir}/${file_name}

Restore iPhy.xml file to Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${local_dir}=None    ${file_name}=ap_new_iphy.xml
    ${local_dir}=    Run Keyword If    '${local_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${local_dir}
    ${ap_alias}=    common_Dss_Keywords.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    # WARNING : need to adapt new_iphy.xml  => iphy.xml  for AiC tests !!!
    ${iphy_filename}     set variable if     ${isAic}       iphy.xml
    ...                                                     new_iphy.xml
    ssh.upload File    local_path=${local_dir}/${file_name}    remote_path=/ffs/run/simmode/${iphy_filename}       connection=${ap_alias}
    [Return]    ${local_dir}/ap_new_iphy.xml

Get Common Unit SW Version
    [Documentation]    :
    ...    [PRIVATE]    used to get GNB/Airphone SW on board
    ...    :param alias:               ssh connnection alias to common unit board
    ...    :return: software version
    [Arguments]    ${alias}
    ssh.Force Reconnect    ${alias}
    ssh.send command    cat /ffs/run/Target*xml   connection=${alias}
    ${cmd_output}=    ssh.read output   connection=${alias}
    ${parsed_xml}=    parse xml    ${cmd_output}
    ${software}=    get element attribute    ${parsed_xml}    cbtsSoftwareReleaseVersion
    ${rest}    ${sw_version}=    Split String    ${software}    separator=_
    [Return]    ${sw_version}

Get Airphone SW version
    [Documentation]    :
    ...    reads active software from Airphone
    ...
    ...    :param ue_id: (default=0) Id/Number of UE
    ...    :return: active Software version on Airphone
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}=    common_Dss_Keywords.Connect to Airphone Common Unit    ue_id=${ue_id}
    ${ap_version}=    common_Dss_Keywords.Get Common Unit SW Version    alias=${ap_alias}
    Set Suite Metadata    AirPhone Version    ${ap_version}
    [Return]    ${ap_version}

Collect egate log files
    [Documentation]    Author: Ch SAMSON
    ...    Run keyword before egate teardown
    ...
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param wts_alias:    alias name to handle egate for ute_wtssim    default=ap_egate
    ...
    # [Arguments]    ${target_dir}=None    ${wts_alias}=ap_egate
    [Arguments]    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=ap_egate
    ...                         ssh_user=ute
    ...                         ssh_pass=ute

    ute_wtssim.collect_egate_log_files    unzip=${False}    subdirectory=${target_dir}    alias=ap_egate

    ${alias}            SSH Connect         host=${HOST_EPCSIM}
    # option h added in case of WTS folder is a link
    Dated Log      tar zcvfh WTS.tgz ${tl.core.dir_path}
    ssh.execute    tar zcvfh WTS.tgz ${tl.core.dir_path}    connection=${alias}
    ssh.execute    ls -l ${tl.core.dir_path}/* >ls-l-WTS.txt       connection=${alias}

    csn.download_file               remote_path=/home/ute/WTS.tgz
    ...                             local_path=${target_dir}/WTS.tgz
    ...                             connection=${alias}
    csn.download_file               remote_path=/home/ute/ls-l-WTS.txt
    ...                             local_path=${target_dir}/ls-l-WTS.txt
    ...                             connection=${alias}
    Dated Log                  WTS log files stored to ${target_dir}

    ute_wtssim.teardown_egate    alias=ap_egate

Collect edaemon log files
    [Documentation]    Author: Ch SAMSON
    ...    Run keyword before edaemon teardown
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param edaemon_alias:    alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...
    # [Arguments]    ${target_dir}=None    ${edaemon_alias}=ap_edaemon
    [Arguments]    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=ap_edaemon
    ...                         ssh_user=ute
    ...                         ssh_pass=ute
    ute_wtssim.collect edaemon log files    unzip=${False}    subdirectory=${target_dir}    alias=ap_edaemon
    ute_wtssim.teardown_egate    alias=ap_edaemon

########################################################################################################
# cmd reset eGate
########################################################################################################
Reset_eGate
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    Log to console  \n***Cmd Reset eGate alias=${alias}***
    sleep   2
    wts.execute egate command    cmd=reset   alias=${alias}

#########################################################################################################
#               5g Call Setup
#########################################################################################################

Test SgNB Addition PRACH
    ${capture_path}      CallSetup.SgNB Addition to ENB          ueSetting=${UE_SIMPLE_CellDSS}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${capture_path}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${capture_path}    ${testCaseDir}

#########################################################################################################
#               Specific tools
#########################################################################################################


Verify if nc process is killed
    [Documentation]  Author: Ch Samson
    [Arguments]  ${asik_alias}=ASIK Master
    ${is_nc_process_started}    common.is_process_exist    process_name=51000    connection=${asik_alias}
    Should not be true    ${is_nc_process_started}

kill nc process
    [Documentation]  Author: Ch Samson
    [Arguments]  ${asik_alias}=ASIK Master
    ${is_nc_process_killed}    common.kill_process_by_name    process_name=51000    connection=${asik_alias}
    Should be true    ${is_nc_process_killed}

Start tput log capture
    [Documentation]    Author: Ch Samson
    ...                Description: Start L2LO throughput log capturing from aasyslog and return the log path in GNB
    ...                             It can only support for 1 GNB currently,
    ...                             due to the limitation for common keyword 'Connect to Capacity Unit Master'
    ...                             If started separate nc processes for UL and DL, then log records will be influenced.
    ...                             So captured both UL and DL tput log in one log file at the same time.
    ...                Return the tput file path on GNB: /tmp/Tput_ul_dl.txt
    [Arguments]  ${gnb_index}=0    ${asik_alias}=ASIK Master     ${du_index}=0

    dated log     Start tput log capture Kw with gnb_index=${gnb_index} du_index=${du_index}
    aasyslog.aasyslog_realtime_output_configuration    host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    type=mcu

    ${is_nc_process_started}    common.is_process_exist    process_name=51000    connection=${asik_alias}

    Run keyword if    ${is_nc_process_started}
    ...    Run keywords    Log to console    Existing aasys log process exists, will close it before starting tput log capturing    AND
    ...    kill nc process    asik_alias=${asik_alias}

    Wait until keyword succeeds    5s    200ms    Verify if nc process is killed    asik_alias=${asik_alias}

    #  command="nc -u -w 100 -l 127.0.0.1 51000 > /tmp/Tput_gnb.txt"
    ${tput_log_file_path_gnb_combined}     common.start_nc_aasyslog        connection=${asik_alias}

    Sleep    200ms

    ${is_nc_process_started}    common.is_process_exist    process_name=51000    connection=${asik_alias}

    Should be true    ${is_nc_process_started}

    [Return]    ${tput_log_file_path_gnb_combined}

Check Throughput from aasyslog
    [Documentation]    Author: Ch Samson
    [Arguments]   ${asik_alias}=ASIK Master      ${tput_log_file_path_gnb_combined}=/tmp/Tput_ul_dl.txt

    ${is_nc_process_started}    common.is_process_exist    process_name=51000    connection=${asik_alias}

    # command="ps -ef |grep 51000|grep -v grep| awk '{print $2}'|xargs kill -9"
    Run keyword if    ${is_nc_process_started}
    ...    Run keywords     Dated log      Existing aasys log process exists, will close it before starting tput log capturing    AND
    ...    kill nc process    asik_alias=${asik_alias}

    Wait until keyword succeeds    5s    200ms    Verify if nc process is killed    asik_alias=${asik_alias}

    Dated log     Calculate UL and DL throughput with ${tput_log_file_path_gnb_combined}
    ${ul_tp_l2lo}=        nps_dss_tools.Calculate_UL_throughput2      alias=${asik_alias}     file_name=${tput_log_file_path_gnb_combined}
    ${dl_tp_l2lo}=        nps_dss_tools.Calculate_DL_throughput2      alias=${asik_alias}     file_name=${tput_log_file_path_gnb_combined}
    ${cur_time}    Get Current Date
    log to console    Current time : ${cur_time}, DL actual throughput(Mbps): ${dl_tp_l2lo}
    log to console    Current time : ${cur_time}, UL actual throughput(Mbps): ${ul_tp_l2lo}


Check UL Throughput
    [Documentation]
    [Arguments]    ${ul_expect}=${UL_EXPECT}
    ...            ${ul_throughput_list}=${UL_THROUGHPUT_LIST}

    Calculate UL throughput on gnb L2Lo case    ul_expect=${ul_expect}    ul_throughput_list=${ul_throughput_list}

Check UL DL Throughput
    [Documentation]
    [Arguments]    ${ul_expect}=${UL_EXPECT}    ${dl_expect}=${DL_EXPECT}
    ...            ${ul_throughput_list}=${UL_THROUGHPUT_LIST}    ${dl_throughput_list}=${DL_THROUGHPUT_LIST}

    Calculate UL throughput on gnb L2Lo case    ul_expect=${ul_expect}    ul_throughput_list=${ul_throughput_list}
    Calculate DL throughput on gnb L2Lo case    dl_expect=${dl_expect}    dl_throughput_list=${dl_throughput_list}

Calculate UL throughput on gnb L2Lo case
    [Documentation]
    ...             This keyword check the UL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${ul_expect}    ${ul_throughput_list}
    dated log    ul_expect=${ul_expect} and ul_throughput_list=${ul_throughput_list}
    ${LogL2RT}                      Container.Get Log                                 name=L2RT
    Dated log     SSH on ${GNB_DU.bb[0].S.sshId}
    ${aliasL2RT}         SSH Wait For Connect                    ${GNB_DU.bb[0].S}
    # ${ul_tp_l2lo}=    gNB_l2_lo_throughput.Calculate UL throughoutput    alias=${aliasL2PS}

    # Dated Log       LogL2RT = ${LogL2RT}
    # Dated Log       LIST_LOG = @{LIST_LOG}

    ${ZipLog}                       Set variable                            ${LogL2RT.path.replace('.log','.zip')}
    Dated log                       Check ASP:ZIPLOG=${ZipLog}
    ${output}                       SSH Cmd
    ...                             ls -lrt ${ZipLog}                       alias=${aliasL2RT}
    ${len}                          Get Length                              ${output}
    Dated log                       Presence ${ZipLog} = ${len} output=${output.strip()}
    ${nodeL2RT}                     Get Node         L2RT
    Dated log                       LogL2RT.prefix = /tmp/node_${nodeL2RT.id}/${LogL2RT.prefix}
    Run Keyword If                  ${len} != 0
    ...                             SSH Cmd
    ...                             unzip -o -d /tmp/node_${nodeL2RT.id}/${LogL2RT.prefix} ${ZipLog}              alias=${aliasL2RT}
    Dated log                       Grep into ${LogL2RT.path}
    # ${output}                       SSH Cmd
    # ...                             grep --line-buffered "rlcPduBytes" ${LogL2RT.path}
    # ...                             alias=${aliasL2RT}

    # ${ul_tp_l2lo}=        nps_dss_tools.Calculate_UL_throughput      alias=${aliasL2RT}     file_name=${LogL2RT.path}
    Dated log     Calculate_UL_throughput with ${LogL2RT.path}
    ${ul_tp_l2lo}=        nps_dss_tools.Calculate_UL_throughput2      alias=${aliasL2RT}     file_name=${LogL2RT.path}

    ${cur_time}    Get Current Date
    # log to console    Current time:${cur_time}, grep = ${output}
    log to console    Current time : ${cur_time}, UL actual throughput(Mbps): ${ul_tp_l2lo}
    # Append to list    ${ul_throughput_list}    ${ul_tp_l2lo}
    # should be true    ${ul_tp_l2lo} > ${ul_expect}
    [Teardown]    run keyword and ignore error  csn.disconnect    connection=${aliasL2RT}

Calculate DL throughput on gnb L2Lo case
    [Documentation]
    ...             This keyword check the DL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${ul_expect}    ${ul_throughput_list}
    dated log    ul_expect=${ul_expect} and ul_throughput_list=${ul_throughput_list}
    ${LogL2RT}                      Container.Get Log                                 name=L2RT
    Dated log     SSH on ${GNB_DU.bb[0].S.sshId}
    ${aliasL2RT}         SSH Wait For Connect                    ${GNB_DU.bb[0].S}
    # Dated Log       LogL2RT = ${LogL2RT}
    # Dated Log       LIST_LOG = @{LIST_LOG}

    ${ZipLog}                       Set variable                            ${LogL2RT.path.replace('.log','.zip')}
    Dated log                       Check ASP:ZIPLOG=${ZipLog}
    ${output}                       SSH Cmd
    ...                             ls -lrt ${ZipLog}                       alias=${aliasL2RT}
    ${len}                          Get Length                              ${output}
    Dated log                       Presence ${ZipLog} = ${len} output=${output.strip()}
    ${nodeL2RT}                     Get Node         L2RT
    Dated log                       LogL2RT.prefix = /tmp/node_${nodeL2RT.id}/${LogL2RT.prefix}
    Run Keyword If                  ${len} != 0
    ...                             SSH Cmd
    ...                             unzip -o -d /tmp/node_${nodeL2RT.id}/${LogL2RT.prefix} ${ZipLog}              alias=${aliasL2RT}
    Dated log                       Grep into ${LogL2RT.path}
    # ${output}                       SSH Cmd
    # ...                             grep --line-buffered "SentDataMeasurementCounting" ${LogL2RT.path}
    # ...                             alias=${aliasL2RT}

    # ${dl_tp_l2lo}=        nps_dss_tools.Calculate_DL_throughput      alias=${aliasL2RT}     file_name=${LogL2RT.path}
    Dated log     Calculate_DL_throughput with ${LogL2RT.path}
    ${dl_tp_l2lo}=        nps_dss_tools.Calculate_DL_throughput2      alias=${aliasL2RT}     file_name=${LogL2RT.path}

    ${cur_time}    Get Current Date
    # log to console    Current time:${cur_time}, grep = ${output}
    log to console    Current time : ${cur_time}, DL actual throughput(Mbps): ${dl_tp_l2lo}
    # Append to list    ${dl_throughput_list}    ${dl_tp_l2lo}
    # should be true    ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]    run keyword and ignore error  csn.disconnect    connection=${aliasL2RT}


Get msgId from lua package
    [Documentation]                Generic test for 1586: get msgId from lua package (using Get Filter For Particular Msgs)
    [Arguments]                    ${message}
    # ${sw_version}=       pcap.Get Software Version
    # current_sw_version_for_lua_gNB is filled in test suite setup
    Log to console    \ENB_BUILD variable points to: ${ENB_BUILD}
    Log to console    \nAF_PATH variable points to: ${AF_PATH}
    ${filter}=     run keyword if     "${ENB_BUILD}" != "${empty}"    Get Filter For Particular Msgs       bipMsgList=${message}
    run keyword if     "${ENB_BUILD}" != "${empty}"       Dated log     filter for ${message} are ${filter}
    Return From Keyword If    "${ENB_BUILD}" != "${empty}"     ${filter}
    ${lua_installed}=     nps_lua_ver.is_lua_Analyzer_installed   ${current_sw_version_for_lua_gNB}
    Dated log   lua already installed = ${lua_installed}
    ${sw_version}=     Run keyword if    ${lua_installed} != ${TRUE}    pcap.Point to luashark scripts via AF_PATH variable
    ...    ELSE     Set Variable   ${current_sw_version_for_lua_gNB}

    # csamson : how to manage SBTS case ?
    ${sw_gnb_version} =    Get gNB software version
    ${sw_list}    split string    ${sw_gnb_version}    separator=_
    ${luashark_url}=     run keyword if    '${sw_list[0]}'=='${SRAN_PRE}'    nps_lua_ver.Create luashark package url sbts    ${sw_gnb_version}
    ...    ELSE                                                              nps_lua_ver.Create luashark package url    ${sw_version}
    # END
    # ${luashark_url} =    nps_lua_ver.Create luashark package url   ${sw_version}
    Set Suite Variable    ${AF_PATH}    ${luashark_url}
    ${filter}         Get Filter For Particular Msgs                bipMsgList=${message}
    Dated log     filter for ${message} are ${filter}
    [Return]       ${filter}

Point AF_PATH to current sw package
    [Documentation]                Generic test for 1586: get AF_PATH for current sw package
    # set suite variable     ${AF_PATH}    ${EMPTY}
    # need to unset ${AF_PATH} variable here but ${EMPTY} dont work  with robot
    set suite variable     ${AF_PATH}    ${None}
    Dated log      AF_PATH = ${AF_PATH} and ENB_BUILD = ${ENB_BUILD}
    Return From Keyword If    "${ENB_BUILD}" != "${empty}"
    # ${sw_version}=       pcap.Get Software Version
    # current_sw_version_for_lua_gNB is filled in test suite setup
    ${lua_installed}=     nps_lua_ver.is_lua_Analyzer_installed   ${current_sw_version_for_lua_gNB}
    Dated log   lua already installed = ${lua_installed}
    ${sw_version}=     Run keyword if    ${lua_installed} != ${TRUE}    pcap.Point to luashark scripts via AF_PATH variable
    ...    ELSE     Set Variable   ${current_sw_version_for_lua_gNB}
    ${luashark_url}   Run keyword if    ${lua_installed} == ${TRUE}       nps_lua_ver.Create luashark package url   ${sw_version}
    Run keyword if    ${lua_installed} == ${TRUE}      Set Suite Variable    ${AF_PATH}    ${luashark_url}


if tcpdump Is Running
    [Documentation]                 Basic service to check a capture is running, based on its path for pcap
    [Arguments]                     ${path}                                 # path of capture file to search
    ...                             ${alias}                                # alias of host on which search
    Sleep                           1                                       # To ensure process is properly down
    ${output}                       SSH Cmd
    ...                             ps -ef | grep tcpdump | grep ${path} | grep -v grep
    ...                             alias=${alias}
    [Return]     ${output}

Stop Capture if needed
    [Arguments]                     ${capture}                                 # path of capture file to search
    ${output}         if tcpdump Is Running       ${capture.path}    ${capture.target.host.alias}
    Run Keyword If     "${output}"!="${EMPTY}"      Capture Stop     ${capture}

####################################################################################################################################""
#
#       logs collections
#
####################################################################################################################################""

Log to Console like Next Step
    [Documentation]                 Compute next step index and print step nb and step name
    [Arguments]                     ${StepNb}        ${StepName}
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${WHITE}STEP %-2s : %-70s${NORMAL}" % ('${StepNb}','${StepName}')
    Log to Console                  ${msg}

Collect Logs if needed
    [Documentation]                 Collect logs if needed
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    log many     ${TEST STATUS}
    IF    '${TEST STATUS}' == 'FAIL'
        common_Dss_Keywords.Collect Logs    ${alias}
    ELSE
        Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs
    END

Create Test Suite Folder
    [Documentation]    create test suite folder
    ${timeStamp}    get current date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${testSuiteDir}    ${LOG_PATH}/${SUITE_NAME}/${timeStamp}
    create directory    ${testSuiteDir}

Create Test Case Folder
    [Documentation]    create test case folder
    ${testCaseDir}    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${testCaseDir}    nps_dss_tools.filter_non_printable_and_remove_head    ${testCaseDir}
    ${testCaseDir}    Replace String    ${testCaseDir[0:30]}    ${SPACE}    _
    ${testCaseDir}    Replace String    ${testCaseDir}    .    _
    Dated log       Create Test Case Folder ${testSuiteDir}/${testCaseDir}
    Set Suite Variable    ${testCaseDir}    ${testSuiteDir}/${testCaseDir}
    Create Directory    ${testCaseDir}

Create Test Case Folder OLD
    [Documentation]    create test case folder
    ${testCaseDir}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCaseDir}    Replace String    ${testCaseDir}    .    _
    ${testCaseDir}    Remove String    ${testCaseDir}    [1]
    ${testCaseDir}    Remove String    ${testCaseDir}    [
    ${testCaseDir}    Remove String    ${testCaseDir}    ]
    Dated log       Create Test Case Folder ${testSuiteDir}/${testCaseDir}
    Set Suite Variable    ${testCaseDir}    ${testSuiteDir}/${testCaseDir}
    Create Directory    ${testCaseDir}

Get testcase log directory
    [Documentation]    :Author: Ch SAMSON
    ...    Retuns path for Testcase log directory
    ...    If Testcase Log directory does not exist it will created automatically
    ...
    ...    :returns: Path for Testcase log
    ...
    ${P_resultTestDir}=    Get Variable Value    ${testCaseDir}
    Run Keyword If    '${P_resultTestDir}'=='None'
    ...    Create Test Case Folder
    ${P_resultTestDir} =    Get Variable Value   ${testCaseDir}
    #${P_resultTestDir} =    Set Variable If    '${P_resultTestDir}'=='None'
    #...              ${testCaseDir}
    [Return]    ${P_resultTestDir}

Prepare Test Name
    [Documentation]    :Author: Ch SAMSON
    ...    Retuns formated test name
    ...
    ...    :returns: formated test name
    ...
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set test variable      ${TEST_NAME}
    [Return]    ${TEST_NAME}


Prepare Logs Directory Path
    [Arguments]    ${resultDir}=None   ${subdir}=${EMPTY}    ${with_timestamp}=${FALSE}
    [Documentation]
    ...    Creates directory for storing logs, based on current execution context.
    ...    An absolute path to created directory is returned.
    [Tags]    PRIVATE
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${subdir}    set variable if    '${with_timestamp}'=='${TRUE}'   ${subdir}_${timestamp}
    ...                                                              ${subdir}
    ${resultDir}=    Run Keyword If    '${resultDir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${resultDir}
    ${logs_dir}   set variable     ${resultDir}/${subdir}
    OperatingSystem.Create Directory    ${logs_dir}
    [Return]    ${logs_dir}

Get Temporary Scf From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Get Temporary Scf From Current Plan
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${vdu_conf} | Get Temporary Scf From Current Plan |
    ...
    dated log    gnb_index${gnb_index} vdu_index=${vdu_index}
    ${tmp_scf_path}=    common_Dss_Keywords.Prepare Logs Directory Path     subdir=temp_scf    with_timestamp=True
    ${file_name}   common_Dss_Keywords.get unique id    prefix=scf_tmp_     suffix=.xml     precise=LOW
    ${tmp_scf_full_path}             OAM Get SCF File            dir=${tmp_scf_path}      file=${file_name}
    [Return]  ${tmp_scf_full_path}

Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   Get Unique ID
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  common_Dss_Keywords.Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE   common_Dss_Keywords.Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}

Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}

Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}

Get SosReport
    [Documentation]      Get GNB Logs from Coam. Files are put inside LOG_PATH directory
    # BTS snapshot.
    Get GNB Logs from Coam

Get GNB Logs from Coam old
	coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=    set variable  ${LOG_PATH}/Snapshot_GNB_${timestamp}.zip
    coam.get_snapshot     target_file_name=${snapshot_path}    timeout=720    connection=coam_admin
    [Teardown]  coam.teardown    connection=coam_admin
    [Return]         ${snapshot_path}

Get GNB Logs from Coam
    [Arguments]    ${resultDir}=None   ${subdir}=${EMPTY}    ${with_timestamp}=${TRUE}
    ${snapshot_path}=  run Keyword if    ${isAiC}     Get GNB Logs from VRAN    resultDir=${resultDir}
    ...                                                                         subdir=${subdir}
    ...                                                                         with_timestamp=${with_timestamp}
    return from Keyword if     ${isAiC}    ${snapshot_path}
    ${resultDir}=    Run Keyword If    '${resultDir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${resultDir}
    ${logs_dir}   set variable     ${resultDir}/${subdir}
	coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=    run keyword if   '${with_timestamp}'=='${TRUE}'   set variable  ${logs_dir}/Snapshot_GNB_${timestamp}.zip
    ...    ELSE                                                            set variable  ${logs_dir}/Snapshot_GNB.zip
    coam.get_snapshot     target_file_name=${snapshot_path}    timeout=720    connection=coam_admin
    [Teardown]  run Keyword if   not ${isAiC}    coam.teardown    connection=coam_admin
    [Return]         ${snapshot_path}

#---------------------vCU--------------------------------------------------------------------------
Login To vCU By Rest
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  Create rest session to vCU.
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given |
    ...    | ...             |     'cuoam_21b' other senarios should be use default value - cuoam_21b |
    ...    | alias | No. | alias that identifies this connection, if the argument is given, |
    ...    | ...   |      the alias must be given to the Logout To vCU By Rest keyword as connection argumument. |
	...
    ...    | Return Value | Description |
    ...    | ${alias} | return the connection alias |
    ...
    ...    the connection alias
    ...    Example
    ...    | Login To vCU By Rest | gnb_index=0 |
    ...
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    common_Dss_Keywords.Logout To vCU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

Logout To vCU By Rest
    [Arguments]    ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Logout To vCU By Rest | connection=${None} |
    ...
    # dated log   *** vcu logout ***
    cu.disconnect    connection=${connection}

#---------------------vDU--------------------------------------------------------------------------

vDU Login
    [Arguments]  ${login_type}=rest   ${restapi_version}=cuoam_19b   ${vdu_index}=0
    [Documentation]  Login to vdu via rest or webem.
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes | the index of vdu, default value is 0 |
    ...    |  solution | Yes |  rest or webui, default value is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Login  |     |

    run keyword if  "${login_type}"=="rest"    vDU Rest Login   ${restapi_version}  ${vdu_index}
    ...   ELSE   Dated log   vDU WebEM Login not supported!!!

vDU Rest Login
    [Arguments]  ${restapi_version}=cuoam_19b  ${vdu_index}=0
    [Documentation]  login vdu webem.
    run keyword and ignore error   common_Dss_Keywords.vDU Rest Logout   vdu_index=${vdu_index}
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_19b'  vdu.connect to
    ...  host=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  ELSE  vdu.connect to
    ...  host=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=8081
    ...  username=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].oam_http_connection_details.password}

vDU Rest Logout
    [Arguments]  ${vdu_index}=0
    [Documentation]  Teardown rest session to vdu.
    dated log    vdu_index=${vdu_index}
    # dated log   \n*** vdu logout ***
    vdu.disconnect

#--------------------- VRAN snapshot--------------------------------------------------------------------------
Save Local Snapshot In vCU
    [Arguments]     ${gnb_index}=0    ${local_snapshot_location}=None
    [Documentation]    this kw is used to Gets local snapshot in vcu
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  CU Save Snapshot  |   |
    dated log   *** Start to save vCU snapshot ***
    common_Dss_Keywords.Login To vCU By Rest    gnb_index=${gnb_index}
    ${Snapshot_path}=    run Keyword if  '${local_snapshot_location}'=='None'     common_Dss_Keywords.Prepare Logs Directory Path
    ...                                                                                                    subdir=vcu_snapshot
    ...   ELSE                                                                    set variable    ${local_snapshot_location}
    cu.Get_Local_Snapshot  ${Snapshot_path}
    dated log   *** End save vCU snapshot ***
    [Return]  ${Snapshot_path}
    [Teardown]  Run Keyword And Ignore Error   common_Dss_Keywords.Logout To vCU By Rest

Save Local Snapshot In vDU
    [Arguments]    ${local_snapshot_location}=None    ${vdu_index}=${0}
    [Documentation]    Save Local Snapshot
    ...    |  Input Parameters | Man. | Description |
    ...    | local_snapshot_location | No | local_snapshot_location  |
    ...
    ...    | Return Value | Description |
    ...    | ${Snapshot_path} | return to path of local snapshot |
    ...
    ...    Example
    ...    | Save Local Snapshot In vDU | local_snapshot_location=snapshot |
    ...
    dated log   *** Start to save vDU snapshot ***
    dated log    vdu_index=${vdu_index}
    common_Dss_Keywords.vDU Rest Login
    ${Snapshot_path}=   run Keyword if  '${local_snapshot_location}'=='None'  common_Dss_Keywords.Prepare Logs Directory Path
    ...                                                                                            subdir=vdu_snapshot
    ...   ELSE                                                                set variable     ${local_snapshot_location}
    ${a}    vdu.Get_Local_Snapshot    ${Snapshot_path}   operation_timeout=${900}
    dated log   *** End save vDU snapshot ***
    [Return]    ${Snapshot_path}
    [Teardown]    Run Keyword And Ignore Error    common_Dss_Keywords.vDU Rest Logout

Get GNB Logs from VRAN
    [Arguments]    ${resultDir}=None   ${subdir}=${EMPTY}    ${with_timestamp}=${TRUE}
    return from Keyword if     not ${isAiC}
    ${resultDir}=    Run Keyword If    '${resultDir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${resultDir}
    ${logs_dir}   set variable     ${resultDir}/${subdir}
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_subdir}=    run keyword if   '${with_timestamp}'=='${TRUE}'   set variable  Snapshot_VDU_${timestamp}
    ...    ELSE                                                              set variable  Snapshot_VDU
    ${snapshot_path}=   common_Dss_Keywords.Prepare Logs Directory Path     resultDir=${logs_dir}   subdir=${snapshot_subdir}
    Save Local Snapshot In vDU   local_snapshot_location=${snapshot_path}
    ${snapshot_subdir}=    run keyword if   '${with_timestamp}'=='${TRUE}'   set variable  Snapshot_VCU_${timestamp}
    ...    ELSE                                                              set variable  Snapshot_VCU
    ${snapshot_path}=   common_Dss_Keywords.Prepare Logs Directory Path     resultDir=${logs_dir}   subdir=${snapshot_subdir}
    Save Local Snapshot In vCU   local_snapshot_location=${snapshot_path}
    [Return]         ${logs_dir}

Collect IMS2 Coam
    return from Keyword if   ${isAiC}
	coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=    set variable  ${LOG_PATH}/Snapshot_GNB_IMS2_${timestamp}.zip
    Run Keyword And Ignore Error    admin.collect_im_snapshot
    ...                             target_file_name=${snapshot_path}
    ...                             timeout=720
    ...                             connection=coam_admin
    [Teardown]  coam.teardown    connection=coam_admin
    [Return]         ${snapshot_path}

Collect EGATE console Logs
    [Documentation]    This keyword is used to collect egate_console.log from the /opt/wts/latest/ folder
    ...                This is collected in the Test Log Folder
    [Arguments]       ${target_dir}=None
    ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=ap_egate
    ...                         ssh_user=ute
    ...                         ssh_pass=ute
    ute_wtssim.execute egate command         cmd=sim_log_set flush  timeout=1s  alias=ap_egate
    ute_wtssim.teardown_egate    alias=ap_egate

    ${alias}            SSH Connect         host=${HOST_EPCSIM}
    Dated Log      Collecting ${tl.core.dir_path}/egate_console.log...
    csn.download_file               remote_path=${tl.core.dir_path}/egate_console.log
    ...                             local_path=${local_target_dir}/egate_console.log
    ...                             connection=${alias}
    Dated Log                  egate_console.log file stored to ${local_target_dir}

Collect gNB Logs
    Log many     collect all log ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${gNB_logName}=    catenate    SEPARATOR=_    ${TEST NAME[0:30].replace(" ", "_").replace("(", "").replace(")", "")}   gNB-${tm}.log
    Run Keyword And Ignore Error    common_Dss_Keywords.LogCollector   ${gNB_logName}
    # 29/07/2021 : dont reset cache here (before teardown), if not , stop the lteemu process fails
    # Conn.ResetCache

Collect AirPhone Logs
    return from Keyword if   '${GNB_DU.sys[0].M.boardType}'!='ASIK'
    Log many     collect all log ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .    :
    ${AirP_logName}=    catenate    SEPARATOR=_    ${TEST NAME[0:30].replace(" ", "_").replace("(", "").replace(")", "")}   AirP-${tm}.log
    Run Keyword And Ignore Error    common_Dss_Keywords.Airphone LogCollector   ${AirP_logName}
    # 29/07/2021 : dont reset cache here (before teardown), if not , stop the lteemu process fails
    # Conn.ResetCache

Get and Extract file with pattern from Snapshot
    [Arguments]         ${pattern}=failurehandler
    Dated log     get gNB snapshot...
    common_Dss_Keywords.Prepare Logs Directory Path    subdir=snapshot
    ${snapshot_path}    run Keyword      common_Dss_Keywords.Get GNB Logs from Coam     subdir=snapshot
    Dated Log     gNB snapshot ${snapshot_path} generated
    return from Keyword if    ${isAiC}
    ${file_list}=     nps_dss_Common.assert_crash_file_is_present_in_snapshot     snapshot_zip_path=${snapshot_path}   pattern=${pattern}
    dated log    file_list=${file_list}

Get Gnb Snapshot if TestCase Failed
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Gnb_Snapshot_if_TestCase_Failed}
    ${Gnb_Snapshot_if_TestCase_Failed}  set Variable if    '${status}'=='FAIL'    1
    ...                                                                           ${Gnb_Snapshot_if_TestCase_Failed}
    return from Keyword if   '${TEST STATUS}' != 'FAIL'
    return from Keyword if   '${Gnb_Snapshot_if_TestCase_Failed}' == '0'
    BuiltIn.Log      \nTest ${TEST_NAME} TestCase Failed ending   console=yes
    Run Keyword And Continue On Failure     Get and Extract file with pattern from Snapshot

Connect to Core
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection core and returns connection handle/alias
    ...     KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    [Arguments]    ${alias}=ssh-core
    ssh.Connect_to      hostname=${tl.core.default_ssh_connection_details.addr}
    ...                 username=${tl.core.default_ssh_connection_details.username}
    ...                 password=${tl.core.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Get latest modified file with defined pattern
    [Documentation]    :Author: Vasileios Papoutsis
    ...    It returns the latest modified file from a specified directory
    ...
    ...    :param path:    Path of directory to get the files
    ...    :param pattern: Optional matching pattern (default: ${EMPTY})
    ...
    ...    :returns lastModifiedFile: Latest modified file
    ...
    [Arguments]    ${path}    ${pattern}=${EMPTY}
    ${files}=    OperatingSystem.List files in directory    path=${path}    pattern=${pattern}
    ${lastModifiedFile}=    Get from list    ${files}    0
    ${time1}=    OperatingSystem.Get modified time    ${path}//${lastModifiedFile}    epoch
    FOR    ${file}    IN    @{files}
        ${time}=    Get modified time    ${path}//${file}    epoch
        ${lastModifiedFile}=    Set variable if    ${time1} < ${time}    ${file}    ${lastModifiedfile}
    END
    [Return]    ${lastModifiedFile}

Collect sos report logs
    [Documentation]
    ...    Sos report logs are needed in case of opening airphone pronto
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param script_path:  path where sosReport.sh is located (default: ${tl.core.dir_path})
    ...
    [Arguments]    ${target_dir}=None    ${script_path}=${tl.core.dir_path}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${core_alias}=    common_Dss_Keywords.Connect to Core
    ssh.execute    cd ${script_path}; ./sosReport.sh -c -s -nr -iphyDIR\=${tl.core.dir_path} -btsDIR\=${tl.core.dir_path}   connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/iphyPsSnapshot.zip    local_path=${target_dir}/iphyPsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/btsSnapshot.zip    local_path=${target_dir}/btsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/sosReport.sh.log    local_path=${target_dir}/sosReport.sh.log
    ...    connection=${core_alias}
    ${sos_report_file}=    common_Dss_Keywords.Get latest modified file with defined pattern    path=${script_path}
    ...                                                                                        pattern=SosReport*_complete_iphy1.tgz
    ssh.Download File    remote_path=${script_path}/${sos_report_file}    local_path=${target_dir}/${sos_report_file}
    ...    connection=${core_alias}

Conn.ExecuteUnblock
    [Arguments]     ${cmd}    ${timeout}    ${alias}
    ${result}    ssh.send_command    command=${cmd}    timeout=${timeout}    connection=${alias}
    [Return]    ${result}

Conn.Execute
    [Arguments]     ${cmd}    ${alias}
    ${result}    ssh.execute    command=${cmd}    connection=${alias}
    [return]    ${result}

Conn.ReceiveReply
    [Arguments]    ${size}=10000    ${alias}=${ALIAS_GNB}
    ${result}    ssh.read_output    size=${size}   connection=${alias}
    [Return]    ${result}

Conn.ReceiveUntil
    [Arguments]    ${match}=""   ${alias}=${ALIAS_GNB}
    BuiltIn.log    Conn.ReceiveUntil: match is ${match}
    ssh.await_execution_end    connection=${alias}    timeout=30
    # ${result}    ssh.read_output_until    match=${match}   timeout=30    connection=${alias}
    # [Return]    ${result}

Conn.DownloadFile
    [Arguments]     ${local_path}    ${remote_path}    ${alias}
    ${result}     ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${alias}
    [Return]    ${result}

Conn.ResetCache
    ssh.reset_cache

Conn.Disconnect
    [Arguments]    ${alias}
    ssh.disconnect    connection=${alias}

Collect gNB snapshot via Aashell
   [Arguments]    ${location}=/ram   ${target_dir}=None
   dated log    location=${location}
   ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ssh.Connect to    ${GNB_DU.sys[0].M.sshConnection.addr}
    ...               ${GNB_DU.sys[0].M.sshConnection.username}
    ...               ${GNB_DU.sys[0].M.sshConnection.password}
    ...                alias=ALIAS_GNB

# (echo "log -a -z snapshot.zip";sleep 50)|telnet 0 15007
# (echo "log -a -z snapshot.zip")|telnet 0 15007
    Conn.Execute  cmd=rm -f /ram/snapshot_gnb*.zip   alias=ALIAS_GNB
    # Conn.Execute  cmd=(echo "log -a -c full -z snapshot_gnb.zip"; sleep 50; echo "quit")|telnet 0 15007   alias=ALIAS_GNB
    Conn.Execute  cmd=echo "log -a -z /ram/snapshot_gnb.zip" | nc 0 15007   alias=ALIAS_GNB
    ${reply}    Conn.ReceiveUntil  match=AaShell>   alias=ALIAS_GNB
    # AaSysComUserDeregister succeed!
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Conn.DownloadFile  local_path=${local_target_dir}/Aashell_snapshot_gnb_${timestamp}.zip
    ...                 remote_path=/ram/snapshot_gnb.zip   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB

Collect AirPhone snapshot via Aashell
   [Arguments]    ${location}=/ram   ${target_dir}=None

   dated log    location=${location}
   ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ssh.Connect to    ${AP_DU.sys[0].M.sshConnection.addr}
    ...               ${AP_DU.sys[0].M.sshConnection.username}
    ...               ${AP_DU.sys[0].M.sshConnection.password}
    ...                alias=ALIAS_GNB

# (echo "log -a -z snapshot.zip";sleep 50)|telnet 0 15007
# (echo "log -a -z snapshot.zip")|telnet 0 15007
    Conn.Execute  cmd=rm -f /ram/snapshot_ap*.zip   alias=ALIAS_GNB
    # Conn.Execute  cmd=(echo "log -a -c full -z snapshot_gnb.zip"; sleep 50; echo "quit")|telnet 0 15007   alias=ALIAS_GNB
    Conn.Execute  cmd=echo "log -a -z /ram/snapshot_ap.zip" | nc 0 15007   alias=ALIAS_GNB
    ${reply}    Conn.ReceiveUntil  match=AaShell>   alias=ALIAS_GNB
    # AaSysComUserDeregister succeed!
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Conn.DownloadFile  local_path=${local_target_dir}/Aashell_snapshot_ap_${timestamp}.zip
    ...                remote_path=/ram/snapshot_ap.zip   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB

LogCollector
    [Arguments]    ${logName}=gNB.log    ${location}=/ffs/run/logs    ${target_dir}=None
    return from keyword if    ${isAiC}
    ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ssh.Connect to    ${GNB_DU.sys[0].M.sshConnection.addr}
    ...               ${GNB_DU.sys[0].M.sshConnection.username}
    ...               ${GNB_DU.sys[0].M.sshConnection.password}
    ...                alias=ALIAS_GNB

    # /opt/trs/bin/trs-xpif-d execute dumpconfig
    Conn.Execute  cmd=rm -f /tmp/xpif.dump   alias=ALIAS_GNB
    Conn.Execute  cmd=/opt/trs/bin/trs-xpif-d execute dumpconfig     alias=ALIAS_GNB
    Conn.DownloadFile  local_path=${local_target_dir}/xpif.dump   remote_path=/tmp/xpif.dump   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB
    return from Keyword if   '${GNB_DU.sys[0].M.boardType}'!='ASIK'
    Conn.Execute  cmd=rm -rf ${location}/*gNB*.log   alias=ALIAS_GNB
    Conn.Execute  cmd=rm -rf ${location}/*gNB*.log.tgz   alias=ALIAS_GNB
    Conn.Execute  cmd=/ffs/run/config/scripts/classicalbts_log_collector.sh -o ${location}/${logName}   alias=ALIAS_GNB
    Conn.Execute  cmd=tar czvf ${location}/${logName}.tgz ${location}/${logName}/  alias=ALIAS_GNB
    Conn.DownloadFile  local_path=${local_target_dir}${/}${logName}.tgz  remote_path=${location}/${logName}.tgz   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB

Airphone LogCollector
    [Arguments]    ${logName}=AirP.log    ${location}=/ffs/run/logs    ${target_dir}=None
    return from keyword if    '${AP_DU.sys[0].M.boardType}'!='ASIK'
    ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${target_dir}

    ssh.Connect to    ${AP_DU.sys[0].M.sshConnection.addr}
    ...               ${AP_DU.sys[0].M.sshConnection.username}
    ...               ${AP_DU.sys[0].M.sshConnection.password}
    ...                alias=ALIAS_GNB
    Conn.Execute  cmd=rm -rf ${location}/*AirP*.log   alias=ALIAS_GNB
    Conn.Execute  cmd=rm -rf ${location}/*AirP*.log.tgz   alias=ALIAS_GNB
    Conn.Execute  cmd=/ffs/run/config/scripts/classicalbts_log_collector.sh -o ${location}/${logName}   alias=ALIAS_GNB
    Conn.Execute  cmd=tar czvf ${location}/${logName}.tgz ${location}/${logName}/  alias=ALIAS_GNB
    Conn.DownloadFile  local_path=${local_target_dir}${/}${logName}.tgz  remote_path=${location}/${logName}.tgz   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB

Collect all logs
    [Documentation]      Get GNB Logs from Coam. Files are put inside testCaseDir directory
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}

    BuiltIn.log      alias is ${alias}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${scf}=    set variable  SCF_GNB_${timestamp}_${SUITE_NAME}_${TEST_NAME}_${TEST STATUS}.xml
    ${swconfig}=    set variable  swconfig_GNB_${timestamp}_${SUITE_NAME}_${TEST_NAME}_${TEST STATUS}.txt

    # Save current SCF file used during test cases
    ${current_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=${scf}
    Set Suite Variable              ${current_scf_file}
    Dated Log         Current 1586 SCF file stored to ${current_scf_file}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${current_scf_file}    ${testCaseDir}

    # Get swconfig file that will be used during 1586 tests
    ${status}    ${alias_gnb}             Run Keyword And Ignore Error       SSH Wait For Connect                ${GNB_DU.sys[0].M}
    Run Keyword And Ignore Error    csn.download_file               remote_path=${SWCONFIG_PATH}
    ...                             local_path=${LOG_PATH}/${swconfig}
    ...                             connection=${alias_gnb}
    Dated Log                  Current 1586 swconfig file stored to ${LOG_PATH}/${swconfig}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${LOG_PATH}/${swconfig}    ${testCaseDir}

    common_Dss_Keywords.Prepare Logs Directory Path    subdir=airphone
    Dated Log         Collect /ram/startup_l3.log from Airphone...
    Run keyword and Ignore error      common_Dss_Keywords.Get APL3 log from Airphone        target_dir=${testCaseDir}/airphone

    Dated Log         Collect /ffs/run/simmode/new_iphy.xml from Airphone...
    Run keyword and Ignore error      common_Dss_Keywords.Get iPhy.xml file from Airphone   target_dir=${testCaseDir}/airphone

    ${COLLECT_LOGS}           Set Variable if
    ...                       "${TEST STATUS}" == "FAIL" and "${EXCLUDE_LOGS_IF_FAIL}" == "0"
    ...                       1    ${COLLECT_LOGS}

    Return From Keyword If    "${COLLECT_LOGS}" == "0"

    # BTS snapshot.
    Run Keyword if      '${get_snapshot}' == '1'                       Dated Log New Line         Get gNB snapshot...
    ${snapshot_path}     Run Keyword if  '${get_snapshot}' == '1'       common_Dss_Keywords.Get GNB Logs from Coam
    ...    ELSE      set variable    ${EMPTY}
    ${status}   ${ret}   Run Keyword if  '${snapshot_path}'!='${EMPTY}'   Run Keyword And Ignore Error    OperatingSystem.File Should Exist
    ...                                                                       ${snapshot_path}
    ...  ELSE           set variable    FAIL   ${EMPTY}
    run Keyword if   '${status}'=='PASS'     Run Keyword And Ignore Error    OperatingSystem.Move File    ${snapshot_path}    ${testCaseDir}
    run Keyword if   '${status}'=='PASS'     Dated Log     gNB snapshot ${snapshot_path} generated and copied into ${testCaseDir}

    ${snapshot_ims2_path}     Run Keyword And Ignore Error      common_Dss_Keywords.Collect IMS2 Coam
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${snapshot_ims2_path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${snapshot_ims2_path}    ${testCaseDir}
    run Keyword if    not ${isAiC}    Dated Log     gNB snapshot IMS2 ${snapshot_ims2_path} generated and copied into ${testCaseDir}

    Dated Log         Collect WTS logs...
    common_Dss_Keywords.Prepare Logs Directory Path    subdir=wts
    common_Dss_Keywords.Collect edaemon log files     target_dir=${testCaseDir}/wts
    common_Dss_Keywords.Collect egate log files       target_dir=${testCaseDir}/wts

    common_Dss_Keywords.Prepare Logs Directory Path    subdir=ap_sosreport
    Dated Log         Collect Current swconfig from Airphone...
    common_Dss_Keywords.Store Current swconfig from Airphone     target_dir=${testCaseDir}/ap_sosreport

    Dated Log          Collect gNB Logs...
    common_Dss_Keywords.Collect gNB Logs

    run Keyword if   not ${isAiC}      common_Dss_Keywords.Prepare Logs Directory Path    subdir=aashell
    run Keyword if   not ${isAiC}      Dated Log          Collect gNB snapshot via Aashell...
    run Keyword if   not ${isAiC}      common_Dss_Keywords.Collect gNB snapshot via Aashell    target_dir=${testCaseDir}/aashell

    Dated Log          Collect Airphone Logs...
    common_Dss_Keywords.Collect AirPhone Logs
    common_Dss_Keywords.Collect sos report logs   target_dir=${testCaseDir}/ap_sosreport
    Dated Log     Sos report finished

    Dated Log          Collect AirPhone snapshot via Aashell...
    common_Dss_Keywords.Collect AirPhone snapshot via Aashell     target_dir=${testCaseDir}/aashell

Collect Logs
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    Run Keyword And Ignore Error         common_Dss_Keywords.Get testcase log directory
    Run Keyword And Ignore Error         common_Dss_Keywords.Collect all logs     ${alias}

Software Converter
    [Documentation]    Compatibility with KW: Check Current Software Version
    ...   param: ${input_version} put full or short software version name with dots or commas
    ...   param: ${manipulator} can increace or decrease number of software version
    [Arguments]    ${input_version}    ${manipulator}=0
    ${manipulator}    convert to integer    ${manipulator}
    ${input_version}    replace string   ${input_version}    .    _
    @{string_split}   split string    ${input_version}    _
    # to manage sw knife like 5G20A_GNB_0009_001800_000744_182cc_  ;  5G20A_GNB_0009_001800_000668_0ilsj_
    ${string_split2}     set variable    ${string_split[:5]}
    dated log         swversion split result=${string_split2}
    ${length_list}   get length    ${string_split2}
    @{sw_version}    create list
    @{reverse_list}    Evaluate    list(range(${length_list}-1, ${length_list}-4, -1))
    FOR    ${i}    IN    @{reverse_list}
         ${trunk}    get from list    ${string_split2}    ${i}
         ${trunk}    convert to integer    ${trunk}
         append to list    ${sw_version}    ${trunk}
    END
    ${master}    get from list    ${sw_version}    2
    ${stream}    get from list    ${sw_version}    1
    ${version}    get from list    ${sw_version}    0
    Set Suite Variable     ${convert_version}    ${master}.${stream}.${version+${manipulator}}
    Set Suite Variable     ${master_version}     ${master}
    [Return]    ${convert_version}   ${master_version}

Get gNB mirroring into local repo OLD
    ${local_repo}    set variable    repo
    run   command=mkdir ${LOG_PATH}${/}${local_repo}
    set global variable    ${LOCAL_REPO_DIR}    ${LOG_PATH}${/}${local_repo}
    Dated log        cp ${CURDIR}/../../../../../resources/SWENG/shell/gnbMirroring.sh ${LOCAL_REPO_DIR}
    # /home/ute/NpsTest/robotws5g/testsuite/Paris/resources/SWENG/shell/gnbMirroring.sh
    # /home/ute/NpsTest/robotws5g/testsuite/Paris/RRM/ET/5GC001586/resources/robot
    run   command=cp ${CURDIR}/../../../../../resources/SWENG/shell/gnbMirroring.sh ${LOCAL_REPO_DIR}
    run   command=cp ${CURDIR}/../../../../../resources/SWENG/shell/gnbMirroringConfig.sh ${LOCAL_REPO_DIR}

Get gNB mirroring into local repo
    [Arguments]                     ${scriptDef}
    ${local_repo}    set variable    repo
    run   command=mkdir ${LOG_PATH}${/}${local_repo}
    set global variable    ${LOCAL_REPO_DIR}    ${LOG_PATH}${/}${local_repo}

    FOR    ${script}        IN      @{scriptDef.names}
        Dated log        cp ${CURDIR}/../../../../../resources/SWENG/shell/${script} ${LOCAL_REPO_DIR}
        run   command=cp ${CURDIR}/../../../../../resources/SWENG/shell/${script} ${LOCAL_REPO_DIR}
    END


Mirror Script Install for DSS
    [Documentation]                 Install mirroring script on target for DSS
    [Arguments]                     ${scriptDef}     ${PathToScriptsRepo}=${LOCAL_REPO_DIR}

    # Install mirroring script on target
    # 29/09/2021 : Capture.Mirror Script Install is too verbose => go back to initial solution
    # Capture.Mirror Script Install           ${scriptDef}
    Dated log                       Download scripts for mirroring:${scriptDef.names}
    ${alias}                        SSH Wait For Connect                    ${scriptDef.host}
    FOR    ${script}        IN      @{scriptDef.names}
        SSH Upload Script           alias=${alias}                          scriptFile=${script}    localPath=${PathToScriptsRepo}
        ...                         remotePath=${scriptDef.remotePath}
    END

    ${mirrorslot}                   Set Variable If                         '${GNB_DU.domainId}'=='1'
    ...                             1                                       5
    ${OPT_GNB_MIRRORING.bb_slot}                    set Variable     bb_slot_${mirrorslot}

# &{OPT_GNB_MIRRORING}                bb_slot=bb_slot_1
# ...                                 mirroring_mode='manual'
# ...                                 l2_l1_bip='false'
# ...                                 syscom_mirroring='false'
# ...                                 carrier_aggregation='false'
# ...                                 backhaul_mirroring='false'
# ...                                 L2HI_MIRRORING='false'
# ...                                 L2RT_MIRRORING='false'
# ...                                 CPRT_MIRRORING='false'
# ...                                 filtering='off'
# ...                                 capturing_time_seconds='1'

# L2HI_MIRRORING='false' # true/false, traffic to/from L2-HI, only in ASIK
# L2RT_MIRRORING='false' # true/false, traffic to/from L2-RT, only in ASIK
# CPRT_MIRRORING='false' # true/false, traffic to/from CP-RT, only in ASIK
# BACKHAUL_MIRRORING='false' # true/false, S1/X2 in Classical deployment, F1-U in Cloud deployment, works only in ASIK

Execute Mirror Script with options for DSS
    [Documentation]                 Execute mirroring script on target for DSS
    [Arguments]                     ${scriptDef}     ${opt_gnb_mirroring}   ${location}=/ffs/run/config/scripts    ${local_dir}=None

    ${local_target_dir}=    Run Keyword If    '${local_dir}'=='None'    common_Dss_Keywords.Get testcase log directory
    ...    ELSE    Set Variable    ${local_dir}

    ssh.Connect to    ${GNB_DU.sys[0].M.sshConnection.addr}
    ...               ${GNB_DU.sys[0].M.sshConnection.username}
    ...               ${GNB_DU.sys[0].M.sshConnection.password}
    ...                alias=ALIAS_GNB

    Conn.Execute  cmd=rm -rf ${location}/Launch.gNB*.log   alias=ALIAS_GNB
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${LAUNCH_LOG}   set Variable   Launch.gNB.gnbMirroring.${timestamp}.log
    # BEWARE : --l2_11_bip     instead of   --l2_l1_bip   into gnbMirroring.sh !!!!
    ${cmd}=   catenate     ${scriptDef.cmd}
    ...                     --mirroring_mode=${opt_gnb_mirroring.mirroring_mode}
    ...                     --${opt_gnb_mirroring.bb_slot}='true'
    ...                     --l2_11_bip=${opt_gnb_mirroring.l2_l1_bip}
    ...                     --backhaul_mirroring=${opt_gnb_mirroring.backhaul_mirroring}
    ...                     --filtering=${opt_gnb_mirroring.filtering}
    ...                     --capturing_time_seconds=${opt_gnb_mirroring.capturing_time_seconds}|tee ${location}/${LAUNCH_LOG}
    Dated log      cmd to launch Mirror Script=${cmd}
    Conn.Execute    cmd=${cmd}      alias=ALIAS_GNB
    Conn.DownloadFile  local_path=${local_target_dir}${/}${LAUNCH_LOG}  remote_path=${location}/${LAUNCH_LOG}   alias=ALIAS_GNB
    Conn.Disconnect  alias=ALIAS_GNB

####################################################################################################################################""
#
#       Get and Restore Original configuration
#
####################################################################################################################################""

Get Orignal Configuration DSS
    [Arguments]                   ${BACKUP_DIR}=original_config_files

    # Save current  SCF file
    ${file_name}   set variable     SCF_Original.xml
    ${original_scf_file}            OAM Get SCF File                file=${file_name}
    Set Suite Variable              ${original_scf_file}
    Dated Log New Line         Original SCF file stored to ${original_scf_file}
    Run keyword and Ignore error   OperatingSystem.Copy File    ${original_scf_file}
    ...                                                         ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # Get swconfig file that will be restored during test suite teardown
    ${alias_gnb}                    SSH Wait For Connect                ${GNB_DU.sys[0].M}
    ${file_name}   set variable     swconfig_to_be_restored.txt
    csn.download_file               remote_path=${SWCONFIG_PATH}
    ...                             local_path=${LOG_PATH}/${file_name}
    ...                             connection=${alias_gnb}
    Dated Log                  Default swconfig file stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error   OperatingSystem.Copy File    ${LOG_PATH}/${file_name}
    ...                                                         ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # Get EPC file configuration:
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    ${file_name}   set variable     basic_wts_to_be_restored.cfg
    csn.download_file               remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/${file_name}
    ...                             connection=${alias_epc}
    Dated Log                  Default basic cfg file stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error   OperatingSystem.Copy File    ${LOG_PATH}/${file_name}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    ${file_name}   set variable     new_iphy_to_be_restored.xml
    Run keyword and Ignore error      Get iPhy.xml file from Airphone    target_dir=${LOG_PATH}    file_name=${file_name}
    Dated Log                  Default /ffs/run/simmode/new_iphy.xml from Airphone stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error     OperatingSystem.Copy File    ${LOG_PATH}/${file_name}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # store original Airphone swconfig
    common_Dss_Keywords.Store Current swconfig from Airphone     target_dir=${LOG_PATH}/${BACKUP_DIR}

    # Get AP configuration file
    ${ap_configfile}                Get XML AirPhoneConfig Path
    return from Keyword if     '${ap_configfile}'=='${EMPTY}'
    ${file_name}   set variable     ApOamConfig_to_be_restored.xml
    csn.download_file               remote_path=${tl.core.dir_path}/${ap_configfile}
    ...                             local_path=${LOG_PATH}/${file_name}
    ...                             connection=${alias_epc}
    Dated Log                  Default AP Oam Config file stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error     OperatingSystem.Copy File    ${LOG_PATH}/${file_name}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}

Restore Orignal Configuration DSS

   # Get swconfig file that will be restored during test suite teardown
    ${status}    ${alias_gnb}          Run Keyword And Ignore Error        SSH Wait For Connect                ${GNB_DU.sys[0].M}
    Run Keyword And Ignore Error       csn.upload_file                 remote_path=${SWCONFIG_PATH}
    ...                             local_path=${LOG_PATH}/swconfig_to_be_restored.txt
    ...                             connection=${alias_gnb}

    SSH Exec                        command=crasign ${SWCONFIG_PATH}           alias=${alias_gnb}

    Dated Log                 swconfig file has been restored to default (${LOG_PATH}/swconfig_to_be_restored.txt)

    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/basic_wts_to_be_restored.cfg
    ...                             connection=${alias_epc}

    Dated Log                basic cfg file has been restored to default (${LOG_PATH}/basic_wts_to_be_restored.cfg)

    ${file_name}   set variable     new_iphy_to_be_restored.xml
    Run keyword and Ignore error      common_Dss_Keywords.Restore iPhy.xml file to Airphone    local_dir=${LOG_PATH}    file_name=${file_name}
    Dated Log            /ffs/run/simmode/new_iphy.xml has been restored with default ${LOG_PATH}/${file_name}

    ${ap_configfile}                Get XML AirPhoneConfig Path
    return from Keyword if     '${ap_configfile}'=='${EMPTY}'
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${ap_configfile}
    ...                             local_path=${LOG_PATH}/ApOamConfig_to_be_restored.xml
    ...                             connection=${alias_epc}

    Dated Log            ApOamConfig has been restored to default (${LOG_PATH}/ApOamConfig_to_be_restored.xml)

Fetch common OAM SW version for Classical
    [Documentation]    :
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    admin.connect_to    bts_host=${bts_host}    name=gnb
    ${gnb_sw_version}=    admin.get_sw_version    connection=gnb
    admin.teardown    connection=gnb
    ${gnb_sw_version}=    nps_dss_tools.reform_coam_sw_version    ${gnb_sw_version}
    set global variable    ${TLConfig.release.name}      ${gnb_sw_version}
    [Return]    ${gnb_sw_version}

Fetch common OAM SW version
    [Documentation]    :
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]     ${oam}=${GNB_DU.oam}
    ${gnb_sw_version}                      OAM Get SW Version                      oam=${oam}
    ${gnb_sw_version}=    nps_dss_tools.reform_coam_sw_version    ${gnb_sw_version}
    set global variable    ${TLConfig.release.name}      ${gnb_sw_version}
    [Return]    ${gnb_sw_version}

Log Test description
  [Arguments]                    ${text}
    Run Keyword And Ignore Error    OperatingSystem.touch    ${testCaseDir}/TestDescription_${SUITE_NAME}_${TEST_NAME}.txt
    Run Keyword And Ignore Error    OperatingSystem.run      echo ${text} > ${testCaseDir}/TestDescription_${SUITE_NAME}_${TEST_NAME}.txt

Read L1L2 filter from luaShark
    [Documentation]
    ...  Description: [OBSOLETE] Read L1L2 filter from basic enitity name (should work case insensitive and even uldata prefix)
    ...                OBSOLETE since introduction of MCShark
    ...  Author:
    [arguments]     ${entities}
    ${entities}     replace string    ${entities}  DlData_     ${EMPTY}
    ${entities}     replace string    ${entities}  UlData_     ${EMPTY}
    # @{splitparam}           Split String    ${entities}   ;
    @{splitparam}           Split String    ${entities}

    ${filterlist}       set variable    ${EMPTY}
    FOR            ${element}  IN  @{splitparam}
        ${resp}  Run  grep -A 5 -ri \'${element}\' /opt/luashark/generated_luashark/5G* --include=*.lua |grep -A 2 -i messageId | grep -Po "\\d{5}"
        ${resp1}  Run  grep -A 5 -ri \'${element}\' /opt/luashark/generated_luashark/5G* --include=*.lua |grep -A 2 -i messageId
        Log to console     ${resp1}
        ${resp}        convert to integer      ${resp}
        ${msgid}       convert to hex      ${resp}
        ${filterlist}   set variable    ${filterlist}ether[24:2]==0x0${msgid}||
    END
    ${filterlist}       set variable    ${filterlist}'
    ${filterlist}       replace string     ${filterlist}    ||'    ${EMPTY}
    [return]        ${filterlist}

Start Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Tcpdump on test PC
    ...
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector **Impact on log filename**
    ...
    ...     **Example:**
    ...
    ...         | Start Tcpdump on TestPc     interface=eth0
    ...         | BuiltIn.Sleep     10 sec
    ...         | Stop Tcpdump on TestPc     interface=eth0
    [Arguments]     ${interface}  ${option}=${EMPTY}      ${collector}=testpc-${interface}-tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} started successfully    console=yes
    [RETURN]    ${collector}


Stop Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Stop tcpdump on testpc
    ...     Logs are storred in Testcase Log directory
    ...
    ...     :param interface: (default=fronthaul) Interface for tcpdump
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump-file: Path to tcpdump file
    ...
    [Arguments]     ${interface}  ${collector}=testpc-${interface}-tcpdump    ${target_dir}=None
    IF    '${target_dir}'=='None'
        ${target_dir}=    common_Dss_Keywords.Get Testcase Log Directory
    END
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} stopped and collected successfully    console=yes
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap

PrintTLInformation
    log many    EGATE_CFG_NAME=${tl.core.cfg_filename}    WTS_FILE_PATH=${tl.core.dir_path}    GNB_IP=${GNB_IP}
    log many    UTE_IP=${tl.core.default_ssh_connection_details.addr}
    ...         UTE_USERNAME=${tl.core.default_ssh_connection_details.username}
    ...         UTE_PASSWORD=${tl.core.default_ssh_connection_details.password}

COAM_Admin_Login
    [Arguments]   ${bts_host}=${WEBUI_IP}   ${username}=${WEBUI_USERNAME}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${LOG_PATH}   ${alias}=COAM
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}

COAM_Admin_Logout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

COAM_Admin_BackupSCF
    [Arguments]   ${local_dir}=${LOG_PATH}   ${file_name}=old_commission.xml   ${connection}=COAM
    ${file_name_without_extension}    String.Replace string    ${file_name}    .xml    ${EMPTY}
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${file_name_scf}    catenate  SEPARATOR=${EMPTY}    ${file_name_without_extension}    _${timestamp}.xml
    wait until keyword succeeds   3x   1min    COAM_Admin_Login
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name_scf}   connection=${connection}   timeout=10
    ${backupfile}=   Join Path   ${local_dir}   ${file_name_scf}
    COAM_Admin_Logout
    [Return]  ${backupfile}

gNB BackupSCF old to remove
    # [Arguments]   ${oam_type}=${OAM_TYPE}
    ${bakupfolder}    set variable    backups
    run   command=mkdir ${LOG_PATH}${/}${bakupfolder}
    set global variable    ${BACKUP_DIR}    ${LOG_PATH}${/}${bakupfolder}
    ${scffile}=    run keyword     COAM_Admin_BackupSCF
    ${scf_file_path}    ${scf_file_name}    OperatingSystem.split path    ${scffile}
    sleep    3s
    OperatingSystem.Copy File    ${scffile}    ${BACKUP_DIR}
    set global variable    ${BACKUP_SCF}    ${BACKUP_DIR}/${scf_file_name}

gNB BackupSCF
    # [Arguments]   ${oam_type}=${OAM_TYPE}
    ${bakupfolder}    set variable    backups
    run   command=mkdir ${LOG_PATH}${/}${bakupfolder}
    set global variable    ${BACKUP_DIR}    ${LOG_PATH}${/}${bakupfolder}

    ${sufix}=     set variable if          ${isAic}            _DU
    ...                                                        ${EMPTY}
    ${scffile}                   set variable                old_commission${sufix}.xml
    ${scf_file_path}             OAM Get SCF File           dir=${BACKUP_DIR}      file=${scffile}
    set global variable    ${BACKUP_SCF}    ${scf_file_path}
    return from Keyword if      '${isAic}'=='${FALSE}'
    ${sufix}=     set variable if       ${isAic}     _CU
    ...                                              ${EMPTY}
    ${scffile}                   set variable                old_commission${sufix}.xml
    ${scf_file_path}             OAM Get SCF File           dir=${BACKUP_DIR}      file=${scffile}     oam=${GNB_CU.oam}
    set global variable    ${BACKUP_CU_SCF}    ${scf_file_path}


Remove RAD param for Link Adaptation on swconfig if present
    [Documentation]         workaround on swconfig.txt to remove RAD param for Link adaptation
    ${SWCONFIG_LOCAL_PATH}          getTempDir
    ${SWCONFIG_REMOTE_PATH}         set variable                        /ffs/run/swconfig.txt
    Set Suite Variable              ${SWCONFIG_LOCAL_PATH}
    ...                             ${SWCONFIG_LOCAL_PATH}/swconfig.txt
    set suite variable              ${SWCONFIG_REMOTE_PATH}
    Dated Log                       startSession : Download ${SWCONFIG_REMOTE_PATH} in ${SWCONFIG_LOCAL_PATH}
    ${alias}                        SSH Wait For Connect                 ${GNB_DU.sys[0].M}
    csn.download_file               remote_path=${SWCONFIG_REMOTE_PATH}
    ...                             local_path=${SWCONFIG_LOCAL_PATH}
    ...                             connection=${alias}

    Dated log      Workaround on swconfig.txt to remove RAD param for Link adaptation
    Dated Log      sed -i -e 's/0x580011=0/#0x580011=0/g' ${SWCONFIG_LOCAL_PATH}
    Dated Log      sed -i -e 's/0x580012=0/#0x580012=0/g' ${SWCONFIG_LOCAL_PATH}
    Dated Log      sed -i -e 's/0x580013=0/#0x580013=0/g' ${SWCONFIG_LOCAL_PATH}
    Dated Log      sed -i -e 's/0x580014=0/#0x580014=0/g' ${SWCONFIG_LOCAL_PATH}

    Run          command=sed -i 's/0x580011=0/#0x580011=0/g' ${SWCONFIG_LOCAL_PATH}
    Run          command=sed -i 's/0x580012=0/#0x580012=0/g' ${SWCONFIG_LOCAL_PATH}
    Run          command=sed -i 's/0x580013=0/#0x580013=0/g' ${SWCONFIG_LOCAL_PATH}
    Run          command=sed -i 's/0x580014=0/#0x580014=0/g' ${SWCONFIG_LOCAL_PATH}

    Dated Log                       Upload ${SWCONFIG_LOCAL_PATH} in ${SWCONFIG_REMOTE_PATH}.new
    csn.upload_file                 local_path=${SWCONFIG_LOCAL_PATH}
    ...                             remote_path=${SWCONFIG_REMOTE_PATH}.new
    ...                             connection=${alias}
    Dated Log                       cp ${SWCONFIG_REMOTE_PATH} ${SWCONFIG_REMOTE_PATH}.sav
    SSH Exec                        command=cp ${SWCONFIG_REMOTE_PATH} ${SWCONFIG_REMOTE_PATH}.sav           alias=${alias}
    Dated Log                       remove ${SWCONFIG_REMOTE_PATH}
    SSH Exec                        command=rm ${SWCONFIG_REMOTE_PATH}           alias=${alias}
    ${output}=     SSH Exec         command=ls -lrt ${SWCONFIG_REMOTE_PATH}           alias=${alias}
    Dated log                       output ls ${SWCONFIG_REMOTE_PATH} = ${output.strip()}
    Dated Log                       cp ${SWCONFIG_REMOTE_PATH}.new ${SWCONFIG_REMOTE_PATH}
    ${output}=     SSH Exec         command=cp ${SWCONFIG_REMOTE_PATH}.new ${SWCONFIG_REMOTE_PATH}     alias=${alias}    timeout=20
    ${output}=     SSH Exec         command=ls -lrt ${SWCONFIG_REMOTE_PATH}           alias=${alias}
    Dated log                       output ls ${SWCONFIG_REMOTE_PATH} = ${output.strip()}
    Dated Log                       stopSession : crasign ${SWCONFIG_REMOTE_PATH}
    SSH Exec                        command=crasign ${SWCONFIG_REMOTE_PATH}           alias=${alias}

Update gNB Swconfig for 1745
    [Arguments]                      ${testParam}

    ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}=      create dictionary          field=0x5801a6     value=${testParam.rdEnableFDMPdschDmrs_0x5801a6}

    ${cprt_log_level_0x590072}=       create dictionary                  field=0x590072          value=1
    ${l2ps_rdSupportedUlMCS_0x580010}=      create dictionary   field=0x580010        value=${testParam.RadParam_rdSupportedUlMCS_0x580010}

    ${l2ps_rdLteFlexibleRateMatchingEnabled_0x5900a6}=      create dictionary   field=0x5900a6
    ...                                                                     value=${testParam.RadParam_rdLteFlexibleRateMatchingEnabled_0x5900a6}
    ${l2ps_rrdLteFlexibleRateMatchingAltModeEnabled_0x5900a7}=      create dictionary   field=0x5900a7
    ...                                                               value=${testParam.RadParam_rdLteFlexibleRateMatchingAltModeEnabled_0x5900a7}

    ${swconfig_gnb}=                 Create List           ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}
    ...                                                    ${cprt_log_level_0x590072}
    ...                                                    ${l2ps_rdSupportedUlMCS_0x580010}
    ...                                                    ${l2ps_rdLteFlexibleRateMatchingEnabled_0x5900a6}
    ...                                                    ${l2ps_rrdLteFlexibleRateMatchingAltModeEnabled_0x5900a7}

    Set Fields in swconfig DU       param_list=${swconfig_gnb}


Update gNB Swconfig
    [Arguments]                      ${swconfig_gnb}
    [Documentation]     only update swconfig with ${swconfig_gnb} content
    ...        Exemple :
    ...              ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}=      create dictionary          field=0x5801a6
    ...                                                                value=${testParam.rdEnableFDMPdschDmrs_0x5801a6}
    ...              ${cprt_log_level_0x590072}=       create dictionary                  field=0x590072          value=1
    ...              ${my_swconfig_gnb}=                 Create List           ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}
    ...                                                                        ${cprt_log_level_0x590072}
    ...              Update gNB Swconfig   swconfig_gnb=${my_swconfig_gnb}
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${swconfig_gnb}
    return from keyword if     ${isEmpty}
    Set Fields in swconfig DU       param_list=${swconfig_gnb}


Set Specific RAD & scf parameters
   [Arguments]       ${testParam}    ${swconfig_gnb}
    # set specific RAD param for DSS
    Dated Log New Line   Set Specific RAD parameters for DSS
    Update gNB Swconfig     ${swconfig_gnb}
    # scf for 10Mhz
    Run Keyword If   '${testParam.seq.bandwidth}'=='10MHz'   Dated Log   Scf update for DSS specific ${testParam.scfFile.nrcellfdd.chBwDl} parameters
    # scf for DSS specific parameters  only in case of 10MHz (parameters not BW dependant )
    Run Keyword If   '${testParam.seq.bandwidth}'=='10MHz'   Set SCF NRDBR     ${testParam}
    Run Keyword If   '${testParam.seq.bandwidth}'=='10MHz'   Set SCF NRDDSSLTE     ${testParam}
    Run Keyword If   '${testParam.seq.bandwidth}'=='10MHz'   Set SCF XPIF    ${testParam}
    Dated Log      Scf update for ${testParam.scfFile.nrcellfdd.chBwDl}
    Set SCF     ${testParam}    ${trunk}

Set SCF NRDBR
    [Arguments]          ${testParam}
    Dated log New Line                       NRCELL_DIST_NAME=${NRCELL_DIST_NAME}
#      TestParam is ${testParam}
# MRBTS-69/NRBTS-2/NRDRB-1
    &{nsaDrbParam}    Create Dictionary     ulDataPath=${testParam.scfFile.nrdrb.ulDataPath}
    ...                 ulDataSplitThreshold=${testParam.scfFile.nrdrb.ulDataSplitThreshold}
    ...                 dlDataSplitMode=${testParam.scfFile.nrdrb.dlDataSplitMode}

    &{modify_param1}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-2','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param2}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-3','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param3}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-4','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param4}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-5','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param5}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-6','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param6}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-7','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param7}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-8','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}
    &{modify_param8}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-9','parameter': 'nsaDrbParam','value':[&{nsaDrbParam}]}

    @{modify_param}    Create List    ${modify_param1}
    ...                ${modify_param2}
    ...                ${modify_param3}
    ...                ${modify_param4}
    ...                ${modify_param5}
    ...                ${modify_param6}
    ...                ${modify_param7}
    ...                ${modify_param8}

    BuiltIn.Log      \nParameters to modify:\n @{modify_param}   console=yes
    # coam_gnb_classical.Modify COAM parameters    modify_param=@{modify_param}
    # coam_gnb_classical.Modify COAM parameters with rest API     modify_param=@{modify_param}
    OAM Set Params    modify_param=@{modify_param}

Set SCF NRDDSSLTE
    [Arguments]          ${testParam}
    Dated log New Line                       NRCELL_DIST_NAME=${NRCELL_DIST_NAME}
#      TestParam is ${testParam}
# MRBTS-69/NRBTS-2/NRCELL-1/NRDSSLTE-1
    &{enbPlmn}    Create Dictionary     mcc=${testParam.scfFile.enbPlmn.mcc}
    ...                 mnc=${testParam.scfFile.enbPlmn.mnc}
    ...                 mncLength=${testParam.scfFile.enbPlmn.mncLength}
    &{modify_param}   Evaluate   {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1','parameter': 'enbPlmn','value':[&{enbPlmn}]}

    # 20A specific case needed when using old Airphone sw in front of 20A gNB sw
    &{lteNrDssDlRatio}   Run Keyword If   '${branch}' == '20A'   Create Dictionary   maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                                                              minNrDssRatio=5
    ...                      ELSE    Create Dictionary     maxNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.maxNrDssRatio}
    ...                                                    minNrDssRatio=${testParam.scfFile.lteNrDssDlRatio.minNrDssRatio}
    ${dist}=   Catenate   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    &{modify_param1}    Evaluate    {'dist_name': '${dist}','parameter': 'lteNrDssDlRatio','value':[&{lteNrDssDlRatio}]}
    # &{modify_param1}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1',
    # ...                             'parameter': 'lteNrDssDlRatio','value':[&{lteNrDssDlRatio}]}

    &{lteNrDssMbsfnRatio}    Create Dictionary     maxValue=${testParam.scfFile.lteNrDssMbsfnRatio.maxValue}
    ...                 minValue=${testParam.scfFile.lteNrDssMbsfnRatio.minValue}
    ${dist}=   Catenate   MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    &{modify_param2}    Evaluate    {'dist_name': '${dist}','parameter': 'lteNrDssMbsfnRatio','value':[&{lteNrDssMbsfnRatio}]}
    # &{modify_param2}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1',
    # ...                    'parameter': 'lteNrDssMbsfnRatio','value':[&{lteNrDssMbsfnRatio}]}

    &{lteNrDssUlRatio}    Create Dictionary     maxNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.maxNrDssRatio}
    ...                 minNrDssRatio=${testParam.scfFile.lteNrDssUlRatio.minNrDssRatio}
    ${dist}=   Catenate    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    # &{modify_param3}    Evaluate    {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1',
    # ...                               'parameter': 'lteNrDssUlRatio','value':[&{lteNrDssUlRatio}]}
    &{modify_param3}    Evaluate    {'dist_name': '${dist}','parameter': 'lteNrDssUlRatio','value':[&{lteNrDssUlRatio}]}

    &{modify_param4}    Create Dictionary
    ...    parameter=dssDlTPollRetr
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.dssDlTPollRetr}

    &{modify_param5}    Create Dictionary
    ...    parameter=dssDlTProhib
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.dssDlTProhib}

    &{modify_param6}    Create Dictionary
    ...    parameter=dssUlTPollRetr
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.dssUlTPollRetr}

    &{modify_param7}    Create Dictionary
    ...    parameter=dssUlTProhib
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.dssUlTProhib}

    &{modify_param8}    Create Dictionary
    ...    parameter=eNodeBId
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.eNodeBId}

    &{modify_param9}    Create Dictionary
    ...    parameter=lcrId
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.lcrId}

    &{modify_param10}    Create Dictionary
    ...    parameter=ltePhyCellId
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.ltePhyCellId}

    &{modify_param11}    Create Dictionary
    ...    parameter=ssbPosition
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.ssbPosition}

    &{modify_param12}    Create Dictionary
    ...    parameter=dssMaxNumberOfDlDcis
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRDSSLTE-1
    ...    value=${testParam.scfFile.nrdsslte.dssMaxNumberOfDlDcis}

    @{modify_param_to_apply}    Create List    ${modify_param}
    ...                ${modify_param1}
    ...                ${modify_param2}
    ...                ${modify_param3}
    ...                ${modify_param4}
    ...                ${modify_param5}
    ...                ${modify_param6}
    ...                ${modify_param7}
    ...                ${modify_param8}
    ...                ${modify_param9}
    ...                ${modify_param10}
    ...                ${modify_param11}
    ...                ${modify_param12}

    BuiltIn.Log      \nParameters to modify:\n @{modify_param_to_apply}   console=yes
    # coam_gnb_classical.Modify COAM parameters    modify_param=@{modify_param}
    # coam_gnb_classical.Modify COAM parameters with rest API     modify_param=@{modify_param}
    OAM Set Params    modify_param=@{modify_param_to_apply}

Set SCF XPIF
    [Arguments]          ${testParam}
    Dated log New Line                       NRCELL_DIST_NAME=${NRCELL_DIST_NAME}
#      TestParam is ${testParam}
# MRBTS-69/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    &{modify_param}    Create Dictionary
    ...    parameter=sctpAssocMaxRetrans
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpAssocMaxRetrans}

    &{modify_param1}    Create Dictionary
    ...    parameter=sctpDscp
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpDscp}

    &{modify_param2}    Create Dictionary
    ...    parameter=sctpHeartbeatInterval
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpHeartbeatInterval}

    &{modify_param3}    Create Dictionary
    ...    parameter=sctpMaxPayloadSize
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpMaxPayloadSize}

    &{modify_param4}    Create Dictionary
    ...    parameter=sctpRtoMax
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpRtoMax}

    &{modify_param5}    Create Dictionary
    ...    parameter=sctpRtoMin
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpRtoMin}

    &{modify_param6}    Create Dictionary
    ...    parameter=sctpSackDelay
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpSackDelay}

    &{modify_param7}    Create Dictionary
    ...    parameter=sctpSackFreq
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpSackFreq}

    &{modify_param8}    Create Dictionary
    ...    parameter=sctpWaitTimeInitSeqRetry
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.sctpWaitTimeInitSeqRetry}

    &{modify_param9}    Create Dictionary
    ...    parameter=udpDscp
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=${testParam.scfFile.xpif.udpDscp}

    &{modify_param10}    Create Dictionary
    ...    parameter=ipV4AddressDN1
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
    ...    value=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${IPIF-XP-ID}/IPADDRESSV4-1
#    ...    value=${testParam.scfFile.xpif.ipV4AddressDN1}

    &{modify_param11}    Create Dictionary
    ...    parameter=ipAddress
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1
    ...    value=${testParam.scfFile.xpif_xpifremote.ipAddress}

#    &{modify_param12}    Create Dictionary
#    ...    parameter=localNeDN
#    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/XPAP-1/XPIF-1
#    ...    value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}

    @{modify_param_to_apply}    Create List    ${modify_param}
    ...                ${modify_param1}
    ...                ${modify_param2}
    ...                ${modify_param3}
    ...                ${modify_param4}
    ...                ${modify_param5}
    ...                ${modify_param6}
    ...                ${modify_param7}
    ...                ${modify_param8}
    ...                ${modify_param9}
    ...                ${modify_param10}
    ...                ${modify_param11}
#    ...                ${modify_param12}

    BuiltIn.Log      \nParameters to modify:\n @{modify_param_to_apply}   console=yes
    # coam_gnb_classical.Modify COAM parameters    modify_param=@{modify_param_to_apply}
    # coam_gnb_classical.Modify COAM parameters with rest API     modify_param=@{modify_param_to_apply}
    OAM Set Params    modify_param=@{modify_param_to_apply}

Set SCF IPIF
    [Arguments]          ${testParam}
    Dated log New Line                       NRCELL_DIST_NAME=${NRCELL_DIST_NAME}
#      TestParam is ${testParam}

    &{modify_param}    Create Dictionary
    ...    parameter=localIpAddr
    ...    dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...    value=${testParam.scfFile.ipif.localIpAddr}

    @{modify_param_to_apply}    Create List    ${modify_param}

    BuiltIn.Log      \nParameters to modify:\n @{modify_param_to_apply}   console=yes
    # coam_gnb_classical.Modify COAM parameters    modify_param=@{modify_param_to_apply}
    # coam_gnb_classical.Modify COAM parameters with rest API     modify_param=@{modify_param_to_apply}
    OAM Set Params    modify_param=@{modify_param_to_apply}

#=======================================================================================================================
# SCF settings
#=======================================================================================================================

Set SCF
    [Arguments]          ${testParam}     ${trunk}=False
    Dated log New Line                       NRCELL_DIST_NAME=${NRCELL_DIST_NAME}
    dated log    trunk is ${trunk}
#      TestParam is ${testParam}
    ${btsName}=     Catenate    ${testParam.scfFile.mrbts.btsName} ${testline_name}
    &{modify_param}    Create Dictionary
    ...    parameter=btsName
    ...    dist_name=MRBTS-${MRBTS_ID}
    ...    value=${btsName[0:78]}
    &{modify_param1}    Create Dictionary
    ...    parameter=chBwDl
    ...    dist_name=${NRCELL_DIST_NAME}/NRCELL_FDD-1
    ...    value=${testParam.scfFile.nrcellfdd.chBwDl}
    &{modify_param2}    Create Dictionary
    ...    parameter=chBwUl
    ...    dist_name=${NRCELL_DIST_NAME}/NRCELL_FDD-1
    ...    value=${testParam.scfFile.nrcellfdd.chBwUl}
    &{modify_param3}    Create Dictionary
    ...    parameter=nrarfcnDl
    ...    dist_name=${NRCELL_DIST_NAME}/NRCELL_FDD-1
    ...    value=${testParam.scfFile.nrcellfdd.nrarfcnDl}
    &{modify_param4}    Create Dictionary
    ...    parameter=nrarfcnUl
    ...    dist_name=${NRCELL_DIST_NAME}/NRCELL_FDD-1
    ...    value=${testParam.scfFile.nrcellfdd.nrarfcnUl}
    &{modify_param5}    Create Dictionary
    ...    parameter=${gscnParameterName}
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.gscn}
    &{modify_param6}    Create Dictionary
    ...    parameter=type0CoresetConfigurationIndex
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    &{modify_param7}    Create Dictionary
    ...      parameter=actLteNrDss
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.actLteNrDss}
#    &{modify_param7}    Create Dictionary
#    ...                      parameter=actLteNrDss
#    ...                      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ...                      value=true
##   ...    value=${testParam.seq.feature1586}
    # &{modify_param8}    Create Dictionary
    # ...    parameter=csiReportPeriodicity
    ## ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    # ...    dist_name=${NRCELL_DIST_NAME}
    # ...    value=${testParam.scfFile.nrcellgrp.csiReportPeriodicity}
    &{modify_param9}    Create Dictionary
    ...    parameter=dlDMRSAdditionalPosition
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.dlDMRSAdditionalPosition}
    &{modify_param10}    Create Dictionary
    ...    parameter=cellName
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.cellName}
    &{modify_param11}    Create Dictionary
    ...    parameter=dmrsTypeAPosition
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.dmrsTypeAPosition}
    &{modify_param12}    Create Dictionary
    ...    parameter=lteNrDssMode
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.lteNrDssMode}
    &{modify_param13}    Create Dictionary
    ...    parameter=msg1FrequencyStart
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.msg1FrequencyStart}
    &{modify_param14}    Create Dictionary
    ...    parameter=ullaIniMcs
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.ullaIniMcs}
    &{modify_param15}    Create Dictionary
    ...    parameter=miNrEnDssPerCell
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...    value=${testParam.scfFile.nrpmrnl.miNrEnDssPerCell}
    &{modify_param16}    Create Dictionary
    ...    parameter=miNrCellUtilization
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...    value=${testParam.scfFile.nrpmrnl.miNrCellUtilization}
    &{modify_param17}    Create Dictionary
    ...      parameter=mcc
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.mcc}
    &{modify_param18}    Create Dictionary
    ...      parameter=mnc
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.mnc}
    &{modify_param19}    Create Dictionary
    ...      parameter=mncLength
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.mncLength}
    &{modify_param20}    Create Dictionary
    ...    parameter=ulDMRSAdditionalPosition
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.ulDMRSAdditionalPosition}
    &{modify_param21}    Create Dictionary
    ...    parameter=actFdmScheduling
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    value=${testParam.scfFile.nrbts.actFdmScheduling}
    &{modify_param22}    Create Dictionary
    ...    parameter=actInternalTrace
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    value=${testParam.scfFile.nrbts_trblcadm.actInternalTrace}
    &{modify_param23}    Create Dictionary
    ...    parameter=actCli
    ...    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    value=${testParam.scfFile.nrbts_featcadm.actCli}
    &{modify_param24}    Create Dictionary
    ...    parameter=actPRBBlanking
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.actPRBBlanking}
    &{modify_param25}    Create Dictionary
    ...    parameter=trsMutingInBlankedPRBsEnabled
    ...    dist_name=${NRCELL_DIST_NAME}
    ...    value=${testParam.scfFile.nrcell.trsMutingInBlankedPRBsEnabled}
    &{modify_param26}    Create Dictionary
    ...    parameter=localIpAddr
    ...    dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...    value=${testParam.scfFile.ipif.localIpAddr}
    &{modify_param27}    Create Dictionary
    ...      parameter=actInactDetNSAUe
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.actInactDetNSAUe}
    &{modify_param28}    Create Dictionary
    ...      parameter=drbInactivityTimerSA
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.drbInactivityTimerSA}
    &{modify_param29}    Create Dictionary
    ...      parameter=srbInactivityTimerSA
    ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...      value=${testParam.scfFile.nrbts.srbInactivityTimerSA}
    # &{modify_param30}    Create Dictionary
    # ...      parameter=actGeneralConnectivityGold
    # ...      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...      value=${testParam.scfFile.nrbts.actGeneralConnectivityGold}
    &{modify_param31}    Create Dictionary
    ...      parameter=prachConfigurationIndex
    ...      dist_name=${NRCELL_DIST_NAME}
    ...      value=${testParam.scfFile.nrcell.prachConfigurationIndex}
    @{modify_param_to_apply}    Create List    ${modify_param}
    ...                ${modify_param1}
    ...                ${modify_param2}
    ...                ${modify_param3}
    ...                ${modify_param4}
    ...                ${modify_param5}
    ...                ${modify_param6}
    ...                ${modify_param7}
    # ...                ${modify_param8}
    ...                ${modify_param9}
    ...                ${modify_param10}
    ...                ${modify_param11}
    ...                ${modify_param12}
    ...                ${modify_param13}
    ...                ${modify_param14}
    ...                ${modify_param15}
    ...                ${modify_param16}
    ...                ${modify_param17}
    ...                ${modify_param18}
    ...                ${modify_param19}
    ...                ${modify_param20}
    ...                ${modify_param21}
    ...                ${modify_param22}
    ...                ${modify_param23}
    ...                ${modify_param24}
    ...                ${modify_param25}
    ...                ${modify_param26}
    ...                ${modify_param27}
    ...                ${modify_param28}
    ...                ${modify_param29}
    # ...                ${modify_param30}
    ...                ${modify_param31}
    BuiltIn.Log      \nParameters to modify:\n @{modify_param_to_apply}   console=yes
    # 1) coam_gnb_classical.Modify COAM parameters    modify_param=@{modify_param_to_apply}
    # 2) coam_gnb_classical.Modify COAM parameters with rest API     modify_param=@{modify_param_to_apply}
    OAM Set Params      modify_param=@{modify_param_to_apply}

Modify Bandwidth Parameters for WTS
   [Arguments]       ${testParam}   ${w_force_ue_capa}=True     ${w_rename}=True
   Dated Log New Line  Set WTS cfg and xml parameters for ${testParam.scfFile.nrcellfdd.chBwDl}
   WTS cfg Preparation    ${testParam}    w_rename=${w_rename}
   WTS xml Preparation    ${testParam}
   Run Keyword if   '${w_force_ue_capa}' == 'True'    Dated Log   Set Ue capa for ${testParam.scfFile.nrcellfdd.chBwDl}
   Run Keyword if   '${w_force_ue_capa}' == 'True'    Set UE capa on EPCSim   ${testParam.seq.ue_nr_capa_value}  ${testParam.seq.ue_ue_eutra_nr_capa}

Dedicated Modify Bandwidth Parameters for WTS
   [Arguments]       ${testParam}   ${w_force_ue_capa}=True
   Dated Log New Line  Set WTS cfg and xml parameters for ${testParam.scfFile.nrcellfdd.chBwDl}
   WTS cfg Preparation    ${testParam}
   dedicated WTS xml Preparation    ${testParam}
   Run Keyword if   '${w_force_ue_capa}' == 'True'    Dated Log   Set Ue capa for ${testParam.scfFile.nrcellfdd.chBwDl}
   Run Keyword if   '${w_force_ue_capa}' == 'True'    Set UE capa on EPCSim   ${testParam.seq.ue_nr_capa_value}  ${testParam.seq.ue_ue_eutra_nr_capa}

#=======================================================================================================================
# IPHY settings
#=======================================================================================================================

Set Context_AP IPHY
    [Arguments]          ${testParam}
    WtsXmlConfig.startSession           file=iphy
    #set GSCN
    # WtsXmlConfig.setListEltText         //GSCN                          ${testParam.scfFile.nrcell.gscn}
    # update only gscn for cell1
    WtsXmlConfig.setListEltText         //RE[1]//GSCN                   ${testParam.scfFile.nrcell.gscn}
    WtsXmlConfig.stopSession            file=iphy

Dedicated Set Context_AP IPHY
    [Arguments]          ${testParam}
    #set GSCN
    # update only gscn for cell1
    DedicatedXmlConfig.dedicated startSession iphy
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//GSCN         ${testParam.scfFile.nrcell.gscn}
    DedicatedXmlConfig.dedicated stopSession iphy

#=======================================================================================================================
# PDML postProcessing for DSS
#=======================================================================================================================

Check UL Qos Load Indication MeasuredNgbrNnbrLoad
   [Arguments]    ${pdmlFile}   ${value}=00    ${remove_zero_value}=True   ${with_verdict}=True
    # ${cmd}=    Catenate     cat ${pdmlFile} | grep 'enDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad'
     #  | grep 'MeasuredNgbrNnbrLoad (Uint8)' | awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g'
     #  | awk '{print $1}' > ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_Value_parsed_${TEST_NAME}.txt
    #  > ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_Value_parsed_${TEST_NAME}.txt
    # OperatingSystem.Run      cat ${pdmlFile} | grep 'showname=\"enDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad'
    #  |awk '{print $9}' | sed 's/value="//g' | sed 's/\"\/>//g'
    #   > ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_Value_parsed_${TEST_NAME}.txt

    ${cmd}=    Catenate     cat ${pdmlFile} | grep -i 'enDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad' |
    ...                grep 'MeasuredNgbrNnbrLoad (Uint8)' | awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${MeasuredNgbrNnbrLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${MeasuredNgbrNnbrLoad}
    Run Keyword If   '${remove_zero_value}' == 'True'       Remove Values From List     ${lines}     00
    ${length}=    get length     ${lines}
    @{MeasuredNgbrNnbrLoad_list}    Evaluate    map(lambda x: int(x, 16), @{lines})
    Dated log   UL Qos MeasuredNgbrNnbrLoad = @{MeasuredNgbrNnbrLoad_list} and length = ${length}
    ${avg_ul_MeasuredNgbrNnbrLoad}    Evaluate    round(round(sum(@{MeasuredNgbrNnbrLoad_list}), 1)/round(${length}, 1), 1)

    # ${ul_MeasuredNgbrNnbrLoad_average_hex}=    nps_dss_tools.calculate_average_of_list_in_file
      #  ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_Value_parsed_${TEST_NAME}.txt
    # ${ul_MeasuredNgbrNnbrLoad_average_int}=      Convert To Integer       0x${ul_MeasuredNgbrNnbrLoad_average_hex}
    # ${ul_MeasuredNgbrNnbrLoad_average_int_2}=      Convert To Integer       0x${ul_MeasuredNgbrNnbrLoad_average_int}

    Log many          [DATA TRANSFER] enDssUlQosLoadMeasurement MeasuredNgbrNnbrLoad average: ${avg_ul_MeasuredNgbrNnbrLoad}
    Log To Console    \t\t\tUplink enDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad Avg:\t\t ${avg_ul_MeasuredNgbrNnbrLoad} %
    # OperatingSystem.Run      grep -n -i enDssUlQosLoadInd ${pdmlFile} | grep -n -i 'value="${value}"' | wc -l
    #  > ${LOG_PATH}/nbr_enDssUlQosLoadIndValue_parsed.txt
    ${cmd}=    Catenate    grep -n -i enDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad ${pdmlFile} |
    ...                      grep -n -i 'value="${value}"' | wc -l > ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_parsed_${TEST_NAME}.txt
    OperatingSystem.Run     ${cmd}
    ${output_ul}    OperatingSystem.Run     cat ${LOG_PATH}/nbr_enDssUlQosLoadIndMeasuredNgbrNnbrLoad_parsed_${TEST_NAME}.txt
    Run Keyword If     '${with_verdict}'=='True'      Should Be True    (${output_ul}>20)
    [Return]     ${avg_ul_MeasuredNgbrNnbrLoad}

Check DL Qos Load Indication MeasuredNgbrNnbrLoad
    [Arguments]    ${pdmlFile}      ${value}=100
    Dated log           ${pdmlFile}         #and  ${value}

    ${dl_ratio_to_check_hex}=    Convert to Hex     ${value}
    ${cmd}=    Catenate     cat ${pdmlFile} | grep -i 'dssDlQosLoadMeasurement.measuredNgbrNnbrLoad' | grep 'measuredNgbrNnbrLoad (Uint8)' |
    ...                                             awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${MeasuredNgbrNnbrLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${MeasuredNgbrNnbrLoad}
    Remove Values From List     ${lines}     00
    ${length}=    get length     ${lines}
    @{MeasuredNgbrNnbrLoad_list}    Evaluate    map(lambda x: int(x, 16), @{lines})
    Dated log   MeasuredNgbrNnbrLoad = @{MeasuredNgbrNnbrLoad_list} and length = ${length}
    ${avg_dl_MeasuredNgbrNnbrLoad}    Evaluate    round(round(sum(@{MeasuredNgbrNnbrLoad_list}), 1)/round(${length}, 1), 1)

    Log many          [DATA TRANSFER] dssDlQosLoadMeasurement MeasuredNgbrNnbrLoad average: ${avg_dl_MeasuredNgbrNnbrLoad}
    Log To Console    \t\t\tDownlink dssDlQosLoadMeasurement.MeasuredNgbrNnbrLoad Avg:\t\t ${avg_dl_MeasuredNgbrNnbrLoad} %

    ${min}=                         Evaluate                                ${value} * (100 - 10) / 100
    ${max}=                         Evaluate                                ${value} * (100 + 10) / 100
    ${status}=                      Evaluate                                ${min} <= ${avg_dl_MeasuredNgbrNnbrLoad} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average DL DSS Ratio REACHED: expected = ${value} % , current = ${avg_dl_MeasuredNgbrNnbrLoad}
    ...    ELSE
    ...    Dated Log                Average DL DSS RATIO NOT REACHED: expected = ${value} %, current = ${avg_dl_MeasuredNgbrNnbrLoad}
    Run Keyword If                  '${status}'!='True'                     Fail    DL DSS Ratio

    ${cmd}=    Catenate       grep -n -i dssDlQosLoadMeasurement.measuredNgbrNnbrLoad ${pdmlFile} |
    ...                                grep -n -i 'value="${dl_ratio_to_check_hex}"' |
    ...                                wc -l > ${LOG_PATH}/dssDlQosLoadMeasurement.measuredNgbrNnbrLoad_parsed_${TEST_NAME}.txt
    OperatingSystem.Run         ${cmd}
    ${output_dl}    OperatingSystem.Run     cat ${LOG_PATH}/dssDlQosLoadMeasurement.measuredNgbrNnbrLoad_parsed_${TEST_NAME}.txt
#    Should Be True    (${output_dl}>0)

Check DL Qos Load Indication measuredGbrLoad
    [Arguments]    ${pdmlFile}      ${value}=0
    Dated log           ${pdmlFile}         #and  ${value}

    ${dl_ratio_to_check_hex}=    Convert to Hex     ${value}
    ${cmd}=    Catenate     cat ${pdmlFile} | grep -i 'dssDlQosLoadMeasurement.measuredGbrLoad' | grep 'measuredGbrLoad (Uint8)' |
    ...                                             awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${MeasuredGbrLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${MeasuredGbrLoad}
    Remove Values From List     ${lines}     00
    ${length}=    get length     ${lines}
    @{MeasuredGbrLoad_list}    Evaluate    map(lambda x: int(x, 16), @{lines})
    Dated log   DL MeasuredGbrLoad = @{MeasuredGbrLoad_list} and length = ${length}
    ${avg_dl_MeasuredGbrLoad}    Evaluate    round(round(sum(@{MeasuredGbrLoad_list}), 1)/round(${length}, 1), 1)

    Log many          [DATA TRANSFER] dssDlQosLoadMeasurement measuredGbrLoad average: ${avg_dl_MeasuredGbrLoad}
    Log To Console    \t\t\tDownlink dssDlQosLoadMeasurement.measuredGbrLoad Avg:\t\t ${avg_dl_MeasuredGbrLoad} %

    ${min}=                         Evaluate                                ${value} * (100 - 10) / 100
    ${max}=                         Evaluate                                ${value} * (100 + 10) / 100
    ${status}=                      Evaluate                                ${min} <= ${avg_dl_MeasuredGbrLoad} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average DL DSS Ratio REACHED: expected = ${value} % , current = ${avg_dl_MeasuredGbrLoad}
    ...    ELSE
    ...    Dated Log                Average DL DSS RATIO NOT REACHED: expected = ${value} %, current = ${avg_dl_MeasuredGbrLoad}
    Run Keyword If                  '${status}'!='True'                     Fail    DL DSS Ratio

    ${cmd}=    Catenate       grep -n -i dssDlQosLoadMeasurement.measuredGbrLoad ${pdmlFile} |
    ...                                grep -n -i 'value="${dl_ratio_to_check_hex}"' |
    ...                                wc -l > ${LOG_PATH}/dssDlQosLoadMeasurement.measuredGbrLoad_parsed_${TEST_NAME}.txt
    OperatingSystem.Run         ${cmd}
    ${output_dl}    OperatingSystem.Run     cat ${LOG_PATH}/dssDlQosLoadMeasurement.measuredGbrLoad_parsed_${TEST_NAME}.txt
#    Should Be True    (${output_dl}>0)

Check DL Qos Load Indication measuredPdcchLoad
    [Arguments]    ${pdmlFile}      ${value}=100
    Dated log           ${pdmlFile}         #and  ${value}

    ${dl_ratio_to_check_hex}=    Convert to Hex     ${value}
    ${cmd}=    Catenate     cat ${pdmlFile} | grep -i 'xp_dss_EnDssDlQosLoadMeasurement.measuredPdcchLoad_item' | grep 'measuredPdcchLoad_item_0' |
    ...                                       awk '{print $8}' | sed -e 's/show="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${measuredPdcchLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${measuredPdcchLoad}
    Remove Values From List     ${lines}     00
    ${length}=    get length     ${lines}
    @{measuredPdcchLoad_list}    Evaluate    map(lambda x: int(x), @{lines})
    Dated log   measuredPdcchLoad_list = @{measuredPdcchLoad_list} and length = ${length}
    ${avg_dl_measuredPdcchLoad}    Evaluate    round(round(sum(@{measuredPdcchLoad_list}), 1)/round(${length}, 1), 1)

    Log many          [DATA TRANSFER] dssDlQosLoadMeasurement measuredPdcchLoad_list average: ${avg_dl_measuredPdcchLoad}
    Log To Console    \t\t\tDownlink dssDlQosLoadMeasurement.measuredPdcchLoad_list Avg:\t\t ${avg_dl_measuredPdcchLoad} %

    ${min}=                         Evaluate                                ${value} * (100 - 10) / 100
    ${max}=                         Evaluate                                ${value} * (100 + 10) / 100
    ${status}=                      Evaluate                                ${min} <= ${avg_dl_measuredPdcchLoad} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average DL DSS Ratio REACHED: expected = ${value} % , current = ${avg_dl_measuredPdcchLoad}
    ...    ELSE
    ...    Dated Log                Average DL DSS RATIO NOT REACHED: expected = ${value} %, current = ${avg_dl_measuredPdcchLoad}
    Run Keyword If                  '${status}'!='True'                     Fail    DL DSS Ratio

    ${cmd}=    Catenate       grep -n -i dssDlQosLoadMeasurement.measuredPdcchLoad ${pdmlFile} |
    ...                                grep -n -i 'show="${dl_ratio_to_check_hex}"' |
    ...                                wc -l > ${LOG_PATH}/dssDlQosLoadMeasurement.measuredPdcchLoad_parsed_${TEST_NAME}.txt
    OperatingSystem.Run         ${cmd}
    ${output_dl}    OperatingSystem.Run     cat ${LOG_PATH}/dssDlQosLoadMeasurement.measuredPdcchLoad_parsed_${TEST_NAME}.txt
#    Should Be True    (${output_dl}>0)


Check UL Qos Load Indication measuredGbrLoad
    [Arguments]    ${pdmlFile}      ${value}=0
    Dated log           ${pdmlFile}         #and  ${value}

    ${ul_ratio_to_check_hex}=    Convert to Hex     ${value}
    ${cmd}=    Catenate     cat ${pdmlFile} | grep -i 'dssUlQosLoadMeasurement.MeasuredGbrLoad' | grep 'measuredGbrLoad (Uint8)' |
    ...                                             awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${MeasuredGbrLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${MeasuredGbrLoad}
    Remove Values From List     ${lines}     00
    ${length}=    get length     ${lines}
    @{MeasuredGbrLoad_list}    Evaluate    map(lambda x: int(x, 16), @{lines})
    Dated log   UL MeasuredGbrLoad = @{MeasuredGbrLoad_list} and length = ${length}
    ${avg_ul_MeasuredGbrLoad}    Evaluate    round(round(sum(@{MeasuredGbrLoad_list}), 1)/round(${length}, 1), 1)

    Log many          [DATA TRANSFER] dssUlQosLoadMeasurement measuredGbrLoad average: ${avg_ul_MeasuredGbrLoad}
    Log To Console    \t\t\tDownlink dssUlQosLoadMeasurement.measuredGbrLoad Avg:\t\t ${avg_ul_MeasuredGbrLoad} %

    ${min}=                         Evaluate                                ${value} * (100 - 10) / 100
    ${max}=                         Evaluate                                ${value} * (100 + 10) / 100
    ${status}=                      Evaluate                                ${min} <= ${avg_ul_MeasuredGbrLoad} <= ${max}
    Run Keyword If                  '${status}'=='True'
    ...    Dated Log                Average UL DSS Ratio REACHED: expected = ${value} % , current = ${avg_ul_MeasuredGbrLoad}
    ...    ELSE
    ...    Dated Log                Average UL DSS RATIO NOT REACHED: expected = ${value} %, current = ${avg_ul_MeasuredGbrLoad}
    Run Keyword If                  '${status}'!='True'                     Fail    UL DSS Ratio

    ${cmd}=    Catenate       grep -n -i dssUlQosLoadMeasurement.MeasuredGbrLoad ${pdmlFile} |
    ...                                grep -n -i 'value="${ul_ratio_to_check_hex}"' |
    ...                                wc -l > ${LOG_PATH}/dssUlQosLoadMeasurement.MeasuredGbrLoad_parsed_${TEST_NAME}.txt
    OperatingSystem.Run         ${cmd}
    ${output_dl}    OperatingSystem.Run     cat ${LOG_PATH}/dssUlQosLoadMeasurement.MeasuredGbrLoad_parsed_${TEST_NAME}.txt
#    Should Be True    (${output_dl}>0)

Remove range Values from ${rangeValueMin} to ${rangeValueMax} from ${list}
#         [Arguments]    ${rangeValueMin}    ${rangeValueMax}   ${list}
    Log to console    ranges values are ${rangeValueMin}:${rangeValueMax} and value list: ${list}
    ${length}=    get length     ${list}
    @{list_int}    Evaluate    map(lambda x: int(x, 16), @{list})
    Dated log   wrong MeasuredNgbrNnbrLoad = @{list_int} and length = ${length}
    FOR    ${index}    IN RANGE    ${rangeValueMin}    ${rangeValueMax}
        # ${valueToRemove}   Convert To Integer   ${index}
        # ${value}=    Remove Values From List     ${list_int}     ${valueToRemove}
        # ${value}=    Remove Values From List     ${list_int}     ${index}
        ${valueToRemove}   Convert To String   ${100}
        ${value}=    Remove Values From List     ${list_int}     ${100}
        # ${value}=    Remove Values From List     ${list_int}     ${valueToRemove}
        Log to console    value removed from list is : ${value}
    END
    [Return]     ${list}

Display wrong DL Qos Load Indication MeasuredNgbrNnbrLoad
    [Arguments]    ${pdmlFile}
    Dated log           ${pdmlFile}

    ${cmd}=    Catenate     cat ${pdmlFile} | grep 'dssDlQosLoadMeasurement.measuredNgbrNnbrLoad' | grep 'measuredNgbrNnbrLoad (Uint8)' |
    ...                                             awk '{print $9}' | sed -e 's/value="//g' | sed -e 's/"/ /g' | awk '{print $1}'
    ${MeasuredNgbrNnbrLoad}=    OperatingSystem.Run    ${cmd}
    @{lines}    Split To Lines    ${MeasuredNgbrNnbrLoad}
    Remove range Values from ${0} to ${101} from ${lines}
    ${length}=    get length     ${lines}
    @{MeasuredNgbrNnbrLoad_list}    Evaluate    map(lambda x: int(x, 16), @{lines})
    Dated log   wrong MeasuredNgbrNnbrLoad = @{MeasuredNgbrNnbrLoad_list} and length = ${length}
    ${avg_dl_MeasuredNgbrNnbrLoad}    Evaluate    round(round(sum(@{MeasuredNgbrNnbrLoad_list}), 1)/round(${length}, 1), 1)
    Log many          [DATA TRANSFER] wrong dssDlQosLoadMeasurement MeasuredNgbrNnbrLoad average: ${avg_dl_MeasuredNgbrNnbrLoad}
    Log To Console    \t\t\tDownlink dssDlQosLoadMeasurement.MeasuredNgbrNnbrLoad Avg:\t\t ${avg_dl_MeasuredNgbrNnbrLoad} %


Update nrCellType into "${testParam}" for CellId "${CellId}"
    # Get SCF File (SCF.xml) done in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${nrCellType}	 scf.get_value_from_scf   p_name=nrCellType
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
    ${testParam_dss.Context.nrCellType}      set Variable     ${nrCellType}
    set suite variable    ${testParam_dss}
    [Return]      ${testParam_dss}

Get actSlowPrbPooling for NRBTS "${nrbts_id}"
    # Get SCF File (SCF.xml) done in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1
    ${actSlowPrbPooling}	 scf.get_value_from_scf   p_name=actSlowPrbPooling
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    [Return]      ${actSlowPrbPooling}

Init Trace color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorBlack}          Evaluate                    "${BLACK}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${consTraceColorGreen}          Evaluate                    "${GREEN}"
    ${consTraceColorYellow}         Evaluate                    "${YELLOW}"
    ${consTraceColorBgBlue}         Evaluate                    "${BG_BLUE}"
    ${consTraceColorBgYellow}       Evaluate                    "${BG_YELLOW}"
    ${consTraceColorBgRed}          Evaluate                    "${BG_RED}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorBlack}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${consTraceColorGreen}
    Set Suite Variable              ${consTraceColorYellow}
    Set Suite Variable              ${consTraceColorBgBlue}
    Set Suite Variable              ${consTraceColorBgYellow}
    Set Suite Variable              ${defColor}
    Set Suite Variable              ${consTraceColorBgRed}

update Get Mem Usage Variable
    [Arguments]        ${with_Get_Mem_Usage}=False
    ${w_Get_Mem_Usage}    set Variable If   '${GNB_DU.bb[0].M.boardType}'=='ABIP' or '${with_Get_Mem_Usage}' == 'True'     True   False
    set Test Variable     ${w_Get_Mem_Usage}

Get Mem Usage
    [Documentation]         Based of board id given in argument, check of the Total / Free / Available memory
    ...                     depending on the period given in agument : before, during or after launching trafic
    ...                     Tested and used for ABIP ONLY
    [Arguments]         ${board_id}=1     ${period}=before    ${connection}=${NONE}   ${suffix}=MemUsage

    ${CURRENT_DATE}=    Get current date    result_format=%Y-%m%d_%H:%M:%S

    OperatingSystem.Run    mkdir -p ${testCaseDir}/${suffix}

    ${BBType}=  set Variable    ${GNB_DU.bb[0].M.boardType}
    ${BBType}=  run Keyword if   '${GNB_DU.bb[0].M.boardType}' == 'ABIP'   Catenate          ${BBType} Marlin
    ...            ELSE                                                    set Variable      ${BBType}

    ${RESET_RESULT_FILE}=   Catenate    SEPARATOR=_     Mem_Usage          ${CURRENT_DATE}_${period}.txt

	${MemTotal}			ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemTotal		connection=${connection}
	...                 timeout=10s
	${MemFree}			ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemFree		connection=${connection}
	...                 timeout=10s
	${MemAvailable}		ssh.execute			command=bsh ${board_id}:0 cat /proc/meminfo | grep -i MemAvailable	connection=${connection}
	...                 timeout=10s

	dated log    MemTotal=${MemTotal}
	dated log    MemFree=${MemFree}
	dated log    MemAvailable=${MemAvailable}

    ${valid_lines}    Get Lines Matching Regexp    ${MemTotal}    MemTotal    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${MemTotal_value}      Set variable    ${valid_lines_last.split(' ')[-2]}
    dated log    MemTotal_value=${MemTotal_value}
    ${valid_lines}    Get Lines Matching Regexp    ${MemFree}    MemFree    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${MemFree_value}      Set variable    ${valid_lines_last.split(' ')[-2]}
    dated log    MemFree_value=${MemFree_value}

    ${Marlin DDR usage}=   Evaluate   (${MemTotal_value} - ${MemFree_value})/int(${1000000})

	${HugePages_Total}			ssh.execute		command=bsh ${board_id}:0 cat /proc/meminfo | grep -i HugePages_Total		connection=${connection}
	...                 timeout=10s
	${HugePages_Free}			ssh.execute		command=bsh ${board_id}:0 cat /proc/meminfo | grep -i HugePages_Free		connection=${connection}
	...                 timeout=10s
	${valid_lines}    Get Lines Matching Regexp    ${HugePages_Total}    HugePages_Total    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${HugePages_Total_value}      Set variable    ${valid_lines_last.split(' ')[-1]}
    dated log    HugePages_Total_value=${HugePages_Total_value}
    ${valid_lines}    Get Lines Matching Regexp    ${HugePages_Free}    HugePages_Free    partial_match=true
    ${valid_lines_last}    Set variable    ${valid_lines.split(':')[-1]}
    ${HugePages_Free_value}      Set variable    ${valid_lines_last.split(' ')[-1]}
    dated log    HugePages_Free_value=${HugePages_Free_value}
    ${ABIP Marlin DDR HugePage used}=   Evaluate   ((${HugePages_Total_value} - ${HugePages_Free_value})*2048)/int(${1000000})

    ${mpstat}		ssh.execute			command=bsh ${board_id}:0 mpstat -P 0,1,2,3  	connection=${connection}
	...                 timeout=10s
	dated log    mpstat=${mpstat}

    ${df_k}		ssh.execute			command=bsh ${board_id}:0 df -k  	connection=${connection}
	...                 timeout=10s
	dated log    df_k=${df_k}

	${valid_lines}    Get Lines Matching Regexp    ${df_k}    rootfs    partial_match=true
    ${rootfs_%_value}      Set variable    ${valid_lines.split(' ')[-2]}
    dated log    rootfs_value=${rootfs_%_value}
    ${rootfs_value}      Set variable    ${valid_lines.split(' ')[-7]}
    # on ABIN !!!!
    # ${rootfs_value}      Set variable    ${valid_lines.split(' ')[-8]}
    # Dated log   valid_lines=${valid_lines.split(' ')}
    ${rootfs_value used}=   run Keyword if   '${rootfs_value}' != '${EMPTY}'    Evaluate   ${rootfs_value}/int(${1000})
    ...                       ELSE            set variable   None
    ${valid_lines}    Get Lines Matching Regexp    ${df_k}    logs    partial_match=true
    ${logs_%_value}      Set variable    ${valid_lines.split(' ')[-2]}
    dated log    logs_value_used=${logs_%_value}
    dated log  ${consTraceColor} ${BBType} logs used ${defColor}: ${consTraceColorRed}${logs_%_value}${defColor} used
    ${logs_%_value}    Replace String    ${logs_%_value}    %    ${SPACE}
    ${compare_result}=   Evaluate     int(${logs_%_value}) >= ${40}
    Run Keyword if  '${compare_result}' == 'True'	ssh.execute	         command=echo "df -k results before CleanUp :" >> /tmp/${RESET_RESULT_FILE}
    ...                                                                  connection=${connection}
    Run Keyword if  '${compare_result}' == 'True'	ssh.execute	         command=bsh ${board_id}:0 df -k >> /tmp/${RESET_RESULT_FILE}
    ...                                                                  connection=${connection}
    Run Keyword if  '${compare_result}' == 'True'	ssh.execute	         command=bsh ${board_id}:0 ls -lrt /ffs/run/logs >> /tmp/${RESET_RESULT_FILE}
    ...                                                                  connection=${connection}
    Run Keyword if  '${compare_result}' == 'True'	ssh.execute          command=bsh ${board_id}:0 rm /ffs/run/logs/*.pcap*
    ...                                                                  connection=${connection}
	...                                                                  timeout=10s
	Run Keyword if  '${compare_result}' == 'True'	  dated log       ${consTraceColorRed}=> CleanUp pcap in ${board_id}:0 /ffs/run/logs${defColor}

	${valid_lines}    Get Lines Matching Regexp    ${df_k}    /tmp    partial_match=true
    ${tmp_%_value}      Set variable    ${valid_lines.split(' ')[-2]}
    ${tmp_value}      Set variable    ${valid_lines.split(' ')[-7]}
    # Dated log   valid_lines=${valid_lines.split(' ')}
    ${tmp_value used}=   Evaluate   ${tmp_value}/int(${1000})
    dated log    tmp_value=${tmp_value}
    dated log    tmp_value used=${tmp_value used}

    dated log  ${consTraceColor} ${BBType} DDR usage ${defColor}: ${consTraceColorRed}${Marlin DDR usage}${defColor} GB
    dated log  ${consTraceColor} ${BBType} DDR HugePage used ${defColor}: ${consTraceColorRed}${ABIP Marlin DDR HugePage used}${defColor} GB
    dated log  ${consTraceColor} ${BBType} DDR /tmp used ${defColor}: ${tmp_value used} MB (${consTraceColorRed}${tmp_%_value}${defColor} used)
    ${text}=   Catenate    SEPARATOR=    ${BBType} DDR rootfs used
    dated log  ${consTraceColor} ${text} ${defColor}: ${rootfs_value used} MB (${consTraceColorRed}${rootfs_%_value}${defColor} used)

    ssh.execute	    command=echo "${BBType} DDR usage : ${Marlin DDR usage} GB" >> /tmp/${RESET_RESULT_FILE}     connection=${connection}
    ssh.execute     command=echo "${BBType} DDR HugePage used: ${ABIP Marlin DDR HugePage used} GB" >> /tmp/${RESET_RESULT_FILE}
    ...               connection=${connection}
    ssh.execute	    command=echo "${BBType} DDR /tmp used: ${tmp_value used} MB (${tmp_%_value} used)" >> /tmp/${RESET_RESULT_FILE}
    ...               connection=${connection}
    ssh.execute
    ...    command=echo "${text} : ${rootfs_value used} MB (${rootfs_%_value} used)" >> /tmp/${RESET_RESULT_FILE}  connection=${connection}

	ssh.execute	    command=bsh ${board_id}:0 mpstat -P 0,1,2,3 >> /tmp/${RESET_RESULT_FILE}     connection=${connection}
	ssh.execute	    command=bsh ${board_id}:0 cat /proc/meminfo >> /tmp/${RESET_RESULT_FILE}     connection=${connection}
	ssh.execute	    command=bsh ${board_id}:0 df -k >> /tmp/${RESET_RESULT_FILE}       connection=${connection}
	ssh.Download File    /tmp/${RESET_RESULT_FILE}    ${testCaseDir}/${suffix}/${RESET_RESULT_FILE}   connection=${connection}
	ssh.execute	    command=rm -f /tmp/${RESET_RESULT_FILE}                  connection=${connection}

# 0x58057A 	rdFeatureFlagBitmapLevel  0 VIP  1 ERROR  2 WARNING  3 INFO  4 DEBUG  5 INVALID
# 0x58057B 	rdFeatureFlagBitmap0      Bit 12 DSS
# 0x58057C 	rdFeatureFlagBitmap1      Bit 31 DL.PDSCH_DMRS_FDM    Bit 19 DL.DCI
# L2PS_DSS_DEBUG_RAD_PARAMETERS = {    # Swconfig.txt
#    '0x58057a': '4',
#    '0x58057b': '0x1001',
#    '0x58057c': '0x80080000',
#}

Set DSS L2PS Debug Specific RAD
    [Documentation]   Author: Ch SAMSON , set L2PS DSS and DL FDM debug Rad parameters
    [Arguments]                      ${testParam}
    builtIn.log    bandwidth is ${testParam.seq.bandwidth}
    ${l2ps_0x58057a}=      create dictionary          field=0x58057a     value=4
    ${l2ps_0x58057b}=      create dictionary          field=0x58057b     value=0x1001
    ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x80080000

    ${swconfig_gnb}=       run Keyword if    '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'     Create List     ${l2ps_0x58057a}
    ...                                                                                                   ${l2ps_0x58057b}
    ...                                                                                                   ${l2ps_0x58057c}
    ...   ELSE                                                                      Create List

    [return]    ${swconfig_gnb}

Kill edaemon
    [Documentation]
    [Arguments]    ${alias}
    ssh.send_command    command=sudo netstat -anp | grep edaemon | awk '{print $7}'
    ...    timeout=${10}
    ...    connection=${alias}
    ${edaemon_pid}=    ssh.read_output    connection=${alias}
    ${edaemon_pid}=    Fetch from left    ${edaemon_pid}    marker=/
    ssh.send_command    command=sudo kill -9 ${edaemon_pid}
    ...    timeout=${10}
    ...    connection=${alias}

Kill previous WTS services
    [Documentation]
    [Arguments]    ${ssh_alias}=WTS
    BuiltIn.Log    Kill previous WTS services    console=True
    ${ssh_alias}=   common_Dss_Keywords.Connect to Core     alias=${ssh_alias}
    ssh.send_command    command=sudo netstat -anp | grep edaemon
    ...    timeout=${10}
    ...    connection=${ssh_alias}
    ${output}=    ssh.read_output    connection=${ssh_alias}
    ${length}=    Get length    ${output}
    Run keyword if    '${length}'>'${0}'
    ...    common_Dss_Keywords.Kill edaemon    alias=${ssh_alias}
    ssh.send_command    command=sudo netstat -anp | grep egate
    ...    timeout=${10}
    ...    connection=${ssh_alias}
    ${output}=    ssh.read_output    connection=${ssh_alias}
    ${length}=    Get length    ${output}
    Run keyword if    '${length}'>'${0}'
    ...    ssh.send_command    command=sudo pkill -9 -f './egate.* --port ${tl.core.egate_port}'
    ...    timeout=${10}
    ...    connection=${ssh_alias}
    ssh.disconnect    connection=${ssh_alias}
    BuiltIn.Log    Previous WTS services are killed!    console=True

Connect to COAM ADMIN
    [documentation]   only one Connect to COAM ADMIN call and coam_gnb alias is used by every coam request
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    coam.setup_admin    bts_host=${bts_host}    name=coam_gnb

Admin Validate SCF
    [Documentation]
    ...  KW for SCF validation. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  | Parameter          | Man. | Description                                                     |
    ...  | scf_path_file      | No   | SCF file path                                                   |
    ...  | skip_param_rel_err | No   | skip parameter relation errors                                  |
    ...  | alias              | No   | alias of admin instance                                         |
    ...  | export_type        | No   | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...  | timeout            | No   | time to wait for positive procedure result                      |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                        |
    ...  | definition_errors_file | Path to definition_errors_file.txt |
    ...  | relation_errors_file   | Path to relation_errors_file.txt   |
    ...  | hardware_errors_file   | Path to hardware_errors_file.txt   |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=coam_gnb
    ...    ${export_type}=configuration  ${timeout}=180

    BuiltIn.log    export_type is ${export_type}
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_file_name}=  Set Variable  SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${testCaseDir}/SCF_Validation/${scf_file_name}
    ...  ELSE  Set Variable  ${scf_path_file}

    ${scf_path_folder}  ${scf_name}=  Split Path  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...               COAM Get SCF      local_dir_path=${scf_path_folder}   file=${scf_file_name}   alias=${alias}

    BuiltIn.Log  ${\n}=============  console=True
    BuiltIn.Log  Validate SCF: ${scf_path_file}  console=True
    ${LOOP}=    Set Variable     1
    FOR  ${cycle}  IN RANGE  1  ${LOOP}+1
        BuiltIn.Log  ${\n}=====================  console=True
        BuiltIn.Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  coam.Validate_scf  scf_file=${scf_path_file}  skip_parameter_relation_errors=${skip_param_rel_err}
        ...    timeout=${timeout}  alias=${alias}
        BuiltIn.Log  ${\n}====================================  console=True
        BuiltIn.Log  SCF Validation for Definition Errors  console=True
        ${definitionErrorsSize}=  Run Keyword If  '${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}'=='None'
        ...    Set Variable  0
        ...  ELSE  Get Length  ${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}
        ${def_err_evaluated}  Evaluate  str(${errors_dict["niddValidationResult"]})
        ${definition_errors_file}
        ...    Set Variable  ${testCaseDir}/SCF_Validation/Definition_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${definition_errors_file}  ${def_err_evaluated}
        Run Keyword If  "${errors_dict["niddValidationResult"]["status"]}"=="OK"
        ...    Run Keywords   BuiltIn.Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...         AND       BuiltIn.Log  Definition Errors Verdict: NIDD validation succeeded.  level=INFO  console=True
        ...  ELSE
        ...    Run Keywords   BuiltIn.Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...     AND   BuiltIn.Log  Defined Errors Verdict: Parameter validation errors: ${definitionErrorsSize}, plz check ${definition_errors_file}!
        ...                                     level=WARN

        BuiltIn.Log  ${\n}==================================  console=True
        BuiltIn.Log  SCF Validation for Relation Errors  console=True
        ${relationErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]}
        ${rel_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]})
        ${relation_errors_file}  Set Variable
        ...    ${testCaseDir}/SCF_Validation/Relation_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${relation_errors_file}  ${rel_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${relationErrorsSize}!=0
        ...          Run Keywords    BuiltIn.Log  Relation Errors Count: ${relationErrorsSize}  level=ERROR  console=True
        ...              AND         BuiltIn.Log  Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
        ...                                    level=ERROR
        ...  ELSE
        ...          Run Keywords    BuiltIn.Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...              AND         BuiltIn.Log  Relation Errors Verdict: Parameter relation validation succeeded.  level=INFO  console=True

        BuiltIn.Log  ${\n}==================================  console=True
        BuiltIn.Log  SCF Validation for Hardware Errors  console=True
        ${hardwareErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]}
        ${hard_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]})
        ${hardware_errors_file}  Set Variable
        ...    ${testCaseDir}/SCF_Validation/Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${hardware_errors_file}  ${hard_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${hardwareErrorsSize}!=0
        ...            Run Keywords   BuiltIn.Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...               AND         BuiltIn.Log  Hardware Errors Verdict: Parameter validation errors present, please check ${hardware_errors_file}
        ...                                  level=WARN
        ...  ELSE
        ...            Run Keywords   BuiltIn.Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...               AND         BuiltIn.Log  Hardware Errors Verdict: Hardware relation validation succeeded.  level=INFO  console=True
        Run Keyword If  ${definitionErrorsSize} == 0 and ${relationErrorsSize} == 0 and ${hardwareErrorsSize} == 0
        ...  Return From Keyword  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}
    END
    Run Keyword If  ${relationErrorsSize}!=0  FAIL
    ...                                       msg=Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
    [Return]  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}

All Cells Should Be Onair
    [Arguments]    ${timeout}=120
    dated log      Check All Cells Should Be Onair...
    Dev_lib.cells_should_be_onair     timeout=${timeout}     check_sib=${True}

Cells 1 Should Be Onair
    dated log      Check Cells 1 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    check_sib=${True}
