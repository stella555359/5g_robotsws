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
${TOPOLOGY}         CLOUD_5G_O_E_AP_LOO
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${VLANIF_DISTNAME}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DeltaConfigDir}                                       ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${PC_filter_UEcontextmodreq}          nr-rrc.c1 == 0 and nr-rrc.ue_PowerClass == 0 and not ngap.procedureCode == 44
${ue_PowerClass}         nr-rrc.ue_PowerClass
${pc_1}      0
${pMax_filter_UEcontextmodresp}     f1ap and nr-rrc.p_Max == 31 and f1ap.procedureCode == 7 and not nr-rrc.c1 == 0
${pMax_field}     nr-rrc.p_Max
${pMax_rrcreconfig}     nr-rrc.p_Max == 31 and nr-rrc.physCellId == 51 and not f1ap.procedureCode == 7
${expected_pMax}     31
${pMax_rrcreconfig_HO}     nr-rrc.p_Max == 31 and nr-rrc.physCellId == 50 and not f1ap.procedureCode == 7
${Full_SCF_n31}      ${CURDIR}/../../config/scf/SCF_n31.xml
${dummy4_uecapinfo}      nr-rrc.ueCapabilityInformation_element
${uecap_d4}     nr-rrc.mAC_ParametersCommon.dummy -e nr-rrc.burstLength -e nr-rrc.maxSimultaneousResourceSetsPerCC
                ...    -e nr-rrc.maxConfiguredResourceSetsPerCC -e nr-rrc.maxConfiguredResourceSetsAllCC
${APCONFIGDIR}      ${CURDIR}/../../config/ap_iphy/
${eutra_fields}     nr-rrc.bandEUTRA -e nr-rrc.ca_BandwidthClassDL_EUTRA -e nr-rrc.ca_BandwidthClassUL_EUTRA
${dummy4_ueradioacesscapinfo}      ngap.id == 117
${filter_for_uecapenq}     nr-rrc.ueCapabilityEnquiry_element
${rad_parameter}      0x890073=0;0x60001F=1

*** Keywords ***
Prepare for test Case - CB012981_D_20
    [Documentation]     This Keyword is specifically used for setting up testcase for CB012981_D_20
    ${Log_Path}    Create Log Directory        CB012981_D_20
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB012981_D_20.json
    Add RD Parameters Directly On GNB      ${rad_parameter}
    Sleep    10s
    log to console                      Rebooting GNB wait for 360 seconds...
    GNB Reboot
    sleep   360s
    Wait Coam Site to be Ready
    Start UTE WTS                       basic_setup.cfg
    Basic Bring Up for rjio
    Sleep   180s
    [Return]                            ${Log_Path}

Prepare for test Case - CB012981_C_5
    [Documentation]     This Keyword is specifically used for setting up testcase for CB012981_C_5
    ${Log_Path}    Create Log Directory        CB012981_C_5
    Link SCOUT SCF To Configuration ID For Reporting
    Wait Coam Site to be Ready
    Start UTE WTS                       basic_setup_C.cfg
    Basic Bring up
    [Return]                            ${Log_Path}

Prepare for test Case - CB012981_B_1
    [Documentation]     This Keyword is specifically used for setting up testcase for CB012981_B_1
    Link SCOUT SCF To Configuration ID For Reporting
    ${Log_Path}    Create Log Directory        CB012981_B_1
    Update And Put Iphy Xml             ${APCONFIGDIR}/new_iphy.xml
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB012981_B_B1.json
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB012981_B_B1_1.json
    Log To Console                      Rebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
    Start UTE WTS                       basic_setup_rel17.cfg
    Basic Bring up
    [Return]                            ${Log_Path}

Tear Down for test Case - CB012981_D_20
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB012981_D_20
    Collect Logs For The Test           ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012981_D20.zip ${LOG_PATH}
    GNB Delta commission                ${DeltaConfigDir}/Delta_Configuration_CB012981_D_20_reverse.json

Tear Down for test Case - CB012981_C_5
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB012981_C_5
    Collect Logs For The Test           ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012981_C5.zip ${LOG_PATH}

Tear Down for test Case - CB012981_B_1
    [Documentation]     This Keyword is used for reverting back all changes we have made to testcase CB012981_B_1
    Collect Logs For The Test           ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012981_B1.zip ${LOG_PATH}
    Update And Put Iphy XML         ${APCONFIGDIR}/iphy.xml
    Full Commission With SCF File For UTE       ${DeltaConfigDir}/gNB_LO_AP_LO_GMC_SCF.xml
    log to console              Rebooting GNB wait for 360 seconds...
    Sleep          360s
    Wait Coam Site to be Ready

Basic Bring up for gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link , X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    log to console      config setup Done
    NG Link Should be UP
    log to console      NG link is up
    X2AP Link Should be UP
    log to console      X2AP link should be Up
    Sleep               60s

get powerclass value from UEcontextmodreq
    [Documentation]      this keyword helps to get powerclass information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  PC_filter       =   filter for powerclass
    [Arguments]         ${pcap_file}            ${PC_filter}=${PC_filter_UEcontextmodreq}     ${expected_pc}=${pc_1}
    ${PC_values}         Get Fields from Pcap    ${pcap_file}        ${PC_filter}           ${ue_PowerClass}
    @{PC_value_list}     split string and return list                ${PC_values}                 ,
    should be equal      ${PC_value_list}[2]     ${expected_pc}

get pMax value from UEcontextmodresp
    [Documentation]      this keyword helps to get pMax value information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  pMax_filter       =   filter for pMax value
    [Arguments]         ${pcap_file}            ${pMax_filter}=${pMax_filter_UEcontextmodresp}     ${pMax0}=${expected_pMax}
    ${PC_values}         Get Fields from Pcap    ${pcap_file}        ${pMax_filter}           ${pMax_field}
    @{PC_value_list}     split string and return list                ${PC_values}                 \n
    should be equal     ${PC_value_list}[0]      ${pMax0}

get pMax value from RRCreconfiguration
    [Documentation]      this keyword helps to get pMax value information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  pMax_filter       =   filter for pMax value
    [Arguments]         ${pcap_file}            ${pMax_filter}=${pMax_rrcreconfig}     ${pMax0}=${expected_pMax}
    ${PC_values}         Get Fields from Pcap    ${pcap_file}        ${pMax_filter}           ${pMax_field}
    @{PC_value_list}     split string and return list                ${PC_values}                   ,
    should be equal     ${PC_value_list}[0]     ${pMax0}

get pMax value from RRCreconfiguration HO
    [Documentation]      this keyword helps to get pMax value information from the pcap file
    ...                  [Arguments]     pcap_file       =   need to give complete path of the pcap file
    ...                                  pMax_filter       =   filter for pMax value
    [Arguments]         ${pcap_file}            ${pMax_filter}=${pMax_rrcreconfig_HO}     ${pMax0}=${expected_pMax}
    ${PC_values}         Get Fields from Pcap    ${pcap_file}        ${pMax_filter}           ${pMax_field}
    @{PC_value_list}     split string and return list                ${PC_values}                   ,
    should be equal     ${PC_value_list}[0]     ${pMax0}

GNB validate scf online
    [Documentation]    This keyword validates and return relation error
    [Arguments]    ${scf_file}=${Full_SCF_n31}
    admin.Setup Admin
    Log To Console   ${EXEC_DIR}
    admin.validate_scf_online        scf_file=${scf_file}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=False
    ...    timeout=60
    ...    detailed_output=True
    [Teardown]    admin.Teardown Admin

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
    [Arguments]    ${eutra_op}
    @{eutra_list1} =    Create List        200    0    3
    @{eutra_list2} =    Create List        201    0    4
    @{eutra_list3} =    Create List        202    0    2
    @{eutragroups}=    Split String By Space    ${eutra_op}
    @{list1_group}=    Split String By Comma    ${eutragroups[0]}
    @{list2_group}=    Split String By Comma    ${eutragroups[1]}
    @{list3_group}=    Split String By Comma    ${eutragroups[2]}
    ${list1}=    Create List    ${list1_group[0]}    ${list2_group[0]}    ${list3_group[0]}
    ${list2}=    Create List    ${list1_group[1]}    ${list2_group[1]}    ${list3_group[1]}
    ${list3}=    Create List    ${list1_group[2]}    ${list2_group[2]}    ${list3_group[2]}
    Run Keyword If    ${list1} == @{eutra_list1}    Log    List1 matches eutra List1
    Run Keyword If    ${list2} == @{eutra_list2}    Log    List2 matches eutra List2
    Run Keyword If    ${list3} == @{eutra_list3}    Log    List3 matches eutra List3
    Run Keyword If    ${list1} != @{eutra_list1}    Log    List1 does not match eutra List1
    Run Keyword If    ${list2} != @{eutra_list2}    Log    List2 does not match eutra List2
    Run Keyword If    ${list3} != @{eutra_list3}    Log    List3 does not match eutra List3

Split String And Return Multiple List
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
    [Arguments]    @{d4_value_list}
    @{dummy4values} =    Create List    0    1    5    37    12
    FOR    ${index}    IN RANGE    0    5
        ${first_value}=    Get From List    ${d4_value_list[${index}]}   0
        ${predefined_value}=    Get From List    ${dummy4values}    ${index}
        Run Keyword If    '${first_value}' == '${predefined_value}'    Log    ${first_value} matches ${predefined_value}
        Run Keyword If    '${first_value}' != '${predefined_value}'    Log    ${first_value} does not match ${predefined_value}
    END

Split String By Space
    [Arguments]    ${string}
    ${split}    Split String    ${string}
    [Return]    ${split}

Split String By Comma
    [Arguments]    ${string}
    ${split}    Split String    ${string}    ,
    [Return]    ${split}

Basic Bring Up for rjio
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should Be UP
    Sleep   60s
