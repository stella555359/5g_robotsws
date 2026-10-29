*** Settings ***
Documentation    This File contains all the commmon keywords required for the Feature CB008187
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         Collections
Library         String
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot

*** Variables ***
${TOPOLOGY}         CLOUD_5G_I_LO_AP_LO
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${VLANIF_DISTNAME}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DeltaConfigDir}          ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${dummy4_uecapinfo}      nr-rrc.ueCapabilityInformation_element
${uecap_d4}     nr-rrc.mAC_ParametersCommon.dummy -e nr-rrc.burstLength -e nr-rrc.maxSimultaneousResourceSetsPerCC
                ...    -e nr-rrc.maxConfiguredResourceSetsPerCC -e nr-rrc.maxConfiguredResourceSetsAllCC
${APCONFIGDIR}      ${CURDIR}/../../config/ap_iphy/
${eutra_fields}     nr-rrc.bandEUTRA -e nr-rrc.ca_BandwidthClassDL_EUTRA -e nr-rrc.ca_BandwidthClassUL_EUTRA
${dummy4_ueradioacesscapinfo}      ngap.id == 117
${filter_for_uecapenq}     nr-rrc.ueCapabilityEnquiry_element

*** Keywords ***
Prepare for test Case - CB008400_D_1
    [Documentation]     This Keyword is specifically used for setting up testcase for CB008400_D_1
    Link SCOUT SCF To Configuration ID For Reporting
    ${Log_Path}    Create Log Directory        CB008400_D_1
    Update And Put Iphy Xml             ${APCONFIGDIR}/iphy_2tdd.xml
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB008400_D1.json
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB008400_D1_1.json
    Log To Console                      Rebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS                       basic_setup_rel18.cfg
    Basic Bring up
    [Return]                            ${Log_Path}

Tear Down for test Case - CB008400_D_1
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB008400_D_1
    Collect Logs For The Test           ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Snapshot Collection     ${LOG_PATH}     Snapshot_AE.zip
    Run     zip -r ${OUTPUTDIR}/CB008400_D1.zip ${LOG_PATH}
    Update And Put Iphy XML         ${APCONFIGDIR}/new_iphy.xml
    Full Commission With SCF File For UTE       ${DeltaConfigDir}/gNB_LO_AP_LO_GMC_SCF.xml
    log to console              Rebooting GNB wait for 360 seconds...
    Sleep          360s
    Wait Coam Site to be Ready

get chipset and RAN id info from UEcapinfo
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  dummy4_filter       =   filter for UEcapinfo
    [Arguments]         ${pcap_file}            ${dummy4_filter}=${dummy4_uecapinfo}
    ${d4_values}         Get Fields from Pcap    ${pcap_file}        ${dummy4_filter}           ${uecap_d4}
    @{d4_value_list}     Split String And Return multiple List            ${d4_values}
    Extract First Values    @{d4_value_list}

get eutra information from UEcapinfo
    [Documentation]      this keyword helps to get eutra information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  eutra_filter       =   filter for eutra information
    [Arguments]         ${pcap_file}            ${eutra_filter}=${dummy4_uecapinfo}
    ${eutra_op}         Get Fields from Pcap    ${pcap_file}        ${eutra_filter}           ${eutra_fields}
    Extract And Compare eutra Lists    ${eutra_op}

check for dummy4 ueradioaccesscap information
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  dummy4_filter       =   filter for ueradioaccesscap
    [Arguments]         ${pcap_file}            ${dummy4_filter}=${dummy4_ueradioacesscapinfo}
    ${d4_values}         Get Fields from Pcap    ${pcap_file}        ${dummy4_filter}           ${uecap_d4}
    @{d4_value_list}     Split String And Return multiple List            ${d4_values}
    Extract First Values    @{d4_value_list}

check if uecapenquiry is not sent by gnb
    [Documentation]      this keyword helps to chipset and RAN information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  uecap_enq       =   filter for uecapenquiry
    [Arguments]         ${pcap_file}            ${uecap_enq}=${filter_for_uecapenq}
    Msg Should Not Be Present In PCAP      ${pcap_file}        ${uecap_enq}

Extract And Compare eutra Lists
    [Documentation]      this keyword helps to extract and compare eutra band values
    [Arguments]    ${eutra_op}
    @{eutra_list1} =    Create List        200    0    3
    @{eutra_list2} =    Create List        201    0    3
    @{eutra_list3} =    Create List        202    0    1
    @{eutragroups}=    Split String    ${eutra_op}
    @{list1_group}=    Split String    ${eutragroups[0]}    ,
    @{list2_group}=    Split String    ${eutragroups[1]}    ,
    @{list3_group}=    Split String    ${eutragroups[2]}    ,
    ${list1}=    Create List    ${list1_group[0]}    ${list2_group[0]}    ${list3_group[0]}
    ${list2}=    Create List    ${list1_group[1]}    ${list2_group[1]}    ${list3_group[1]}
    ${list3}=    Create List    ${list1_group[2]}    ${list2_group[2]}    ${list3_group[2]}
    IF    ${list1} == ${eutra_list1}
            Log    List ${list1} matches eutra List ${eutra_list1}
    ELSE
            Log    List ${list1} does not match eutra List ${eutra_list1}
    END
    IF    ${list2} == ${eutra_list2}
            Log    List ${list2} matches eutra List ${eutra_list2}
    ELSE
            Log    List ${list2} does not match eutra List ${eutra_list2}
    END
    IF    ${list3} == ${eutra_list3}
            Log    List ${list3} matches eutra List ${eutra_list3}
    ELSE
            Log    List ${list3} does not match eutra List ${eutra_list3}
    END

Split String And Return Multiple List
    [Documentation]      this keyword helps to Split String And Return Multiple List
    [Arguments]    ${data}
    ${split_by_space}    Split String    ${data}
    ${list_of_lists}    Create List
    FOR    ${item}    IN    @{split_by_space}
        ${list}    Split String     ${item}     ,
        Append To List    ${list_of_lists}    ${list}
    END
    [Return]    ${list_of_lists}

Register and establish Non-GBR call
    [Documentation]     This keyword shall register UE and establish Non-GBR data call
    ...                 [arguments]     UE_ID           :   parse UE ID
    ...                                 gw_ID           :   Gateway Id is required else it will take deffault value
    ...                                 Pdu_session_ID  :   PDU Session Id is required deffault value set is 1
    ...                                 traffic_dl_rate :   traffic downlink data rate is required deffault value set is 1
    ...                                 traffic_ul_rate :   traffic uplink data rate is required deffault value set is 1
    [Arguments]         ${UE_ID}=${UE_ID}           ${Pdu_session_ID}=${Pdu_session_ID}
    ...                 ${traffic_dl_rate}=${traffic_dl_rate}               ${traffic_ul_rate}=${traffic_ul_rate}
    Enable Internal TG           ${UE_ID}           ${Pdu_session_ID}
    UE Register should be Successful
    Sleep               10s
    Traffic should be successful for SA             ${traffic_dl_rate}          ${traffic_ul_rate}            ${UE_ID}
    Sleep               10s

Stop pcap collection in gNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    core.stop_collectors            names=${name}
    core.collect_collectors         names=${name}       target_dir=${Log_Path}
    core.teardown_collectors        names=${name}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    log to console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Extract First Values
    [Documentation]    This keyword helps to extract first values from each list
    [Arguments]    @{d4_value_list}
    @{dummy4values} =    Create List    0    1    5    37    12
    FOR    ${index}    IN RANGE    0    5
        ${first_value}=    Get From List    ${d4_value_list[${index}]}   0
        ${predefined_value}=    Get From List    ${dummy4values}    ${index}
        IF    '${first_value}' == '${predefined_value}'
            Log    ${first_value} matches ${predefined_value}
        ELSE
            Log    ${first_value} does not match ${predefined_value}
        END
    END
