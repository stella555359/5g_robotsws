*** Settings ***

Documentation
...    | This robot resource file contains SCF related KWs used by SyVe.  |
...    | Also some ReP or QC related KWs are here listed.  |

Library     Collections
Library     String
Library     DateTime

Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/testline.robot
Resource    ./syve_testline.robot


*** Keywords ***
Get NRBTS-Id
    [Documentation]     Get nrbts id from SCF of the given `gnb_id`.
    [Arguments]    ${gnb_id}=${0}
    ${bts_distNames}=    gnb.Get DistNames From GNB SCF   regex=NRBTS-\\d+   gnb_id=${gnb_id}

    ${bts_distName}=     Collections.Get From List    ${bts_distNames}    ${0}
    ${nrbts_id}=         String.Fetch From Right      ${bts_distName}     -
    RETURN  ${nrbts_id}


Get MRBTS-Id
    [Arguments]    ${enb_id}=${0}
    [Documentation]     Get mrbts id from SCF of the given `enb_id`.
    ${bts_distNames}=    scf_info.Get DistNames From ENB SCF    regex=MRBTS-\\d+    enb_id=${enb_id}
    ${bts_distName}=    Get From List    ${bts_distNames}    ${0}
    ${mrbts_id}=  string.Fetch From Right  ${bts_distName}  -
    RETURN  ${mrbts_id}


Get LNBTS-Id
    [Documentation]     Get lnbts id from SCF of the given LTE-Part for SBTS.
    [Arguments]    ${gnb_id}=${0}
    ${bts_distNames}=    gnb.Get DistNames From gNB SCF   regex=LNBTS-\\d+   gnb_id=${gnb_id}

    ${bts_distName}=     Collections.Get From List    ${bts_distNames}    ${0}
    ${lnbts_id}=         String.Fetch From Right      ${bts_distName}     -
    RETURN  ${lnbts_id}


Get IPADDRESSV4
    [Documentation]     Get IPADDRESSV4 from SCF for all gnbs.

    ${LocalIpAddrList}    Get Variable Value   ${LocalIpAddrList}
    IF   '${LocalIpAddrList}'=='${None}'
        Fetch IPADDRESSV4
    END
    RETURN  ${LocalIpAddrList}


Fetch IPADDRESSV4
    [Documentation]     Fetch IPADDRESSV4 from SCF for all gnbs, if LocalIpAddrList!=none
    [Arguments]
    ${LocalIpAddrList}=    Create List

    ${gnb_count}=    Get Length  ${tl.gnbs}
    FOR    ${gnb_id}  IN RANGE  ${gnb_count}
        ${gnb_scf}=  gnb.Get SCF From GNB  gnb_id=${gnb_id}
        scf.Load SCF  ${gnb_scf}
        ${bts_distNames}=    gnb.Get DistNames From Local SCF File    regex=TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-\\d+    scf_path=${gnb_scf}
        Log To Console  ${bts_distNames}
        FOR    ${bts_distNames_elem}    IN    @{bts_distNames}
            ${localIpAddr}=  scf.Get Value From SCF    p_name=localIpAddr  dist_name=${bts_distNames_elem}
            Collections.Append To List    ${LocalIpAddrList}    ip host ${localIpAddr}
        END
    END
    Set Test Variable   ${LocalIpAddrList}
    RETURN  ${LocalIpAddrList}


Get DistNames From ENB SCF
    [Documentation]    get name for eNB
    [Arguments]    ${regex}    ${enb_id}=${0}  ${with_auto_configured_parameters}=${True}
    ${oam_alias}=    connect.Setup OAM HTTP Session  node_id=${enb_id}  node_type=enb
    ${scf_content}=  admin.Get SCF    parameters_save_variant=actualValues
    ...                               timeout=${20}
    ...                               connection=${oam_alias}
    ...                               with_auto_configured_parameters=${with_auto_configured_parameters}

    ${distNames}=    gnb_internal.Get DistNames From SCF    regex=${regex}    scf_content=${scf_content}
    connect.Teardown OAM HTTP Session    node_type=enb  node_id=${enb_id}
    RETURN    ${distNames}


Get PhysCellId
    [Documentation]     Get the physical Cell Id for the given `nrcell_id` of the given `gnb_id`.
    [Arguments]    ${gnb_id}  ${nrcell_id}
    ${oam_alias}=   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${physCellId}  coam_ulm.Get SCF Single Value From Current XML File
    ...               dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${nrcell_id}
    ...               parameter=physCellId
    ...               alias=${oam_alias}
    RETURN  ${physCellId}


Get PhysCellIds
    [Documentation]     This KW sets the Test scope global variables 'physCellIdTarget' and 'physCellIdSource'
    ...                 with their physCellId based on other global variables. 'gnb_id_target' and 'gnb_id_source'
    ...                 as well as 'ru_id_target' and 'ru_id_source' must exist!
    ...
    ${ru_id_target}=      Evaluate  ${ru_id_target}+${1}
    ${physCellIdTarget}   scf_info.Get PhysCellId  gnb_id=${gnb_id_target}  nrcell_id=${ru_id_target}
    Set Test Variable     ${physCellIdTarget}

    ${ru_id_source}=      Evaluate  ${ru_id_source}+${1}
    ${physCellIdSource}   scf_info.Get PhysCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_source}
    Set Test Variable     ${physCellIdSource}


Set MNL Version String For Branch
    [Arguments]    ${basic_scf_name}
    Log To Console  Checking MNL version string
    ${str}=  OperatingSystem.Get File  ${basic_scf_name}
    ${version_list}=  String.Get Regexp Matches
    ...  ${str}  <managedObject class=\"com.nokia.srbts:MRBTS\" distName=\"MRBTS-.*?\" version=\"SBTS(?P<vers>.*?)\"  vers
    ${version}=    Get From List  ${version_list}  0
    Set Suite Variable  ${version}  ${version}


Get GNB PhysCellIds For CA
    [Documentation]     get the physCellId for the testscenario
    [Arguments]    ${physSCell}=${None}  ${physPCell}=${None}
    ${ru_id_Psource}=    Evaluate  ${ru_id_source_pcell}+${1}
    IF  '${physPCell}'=='${None}'    Set Test Variable  ${ru_id_Psource}
    ...    ELSE    Set Test Variable  ${ru_id_Psource}  ${physPcell}
    ${PHYSCELLIDSOURCEPCELL}  Get GNB PhysCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Psource}
    Set Suite Variable  ${PHYSCELLIDSOURCEPCELL}
    ${ru_id_Ssource}=    Evaluate  ${ru_id_source_scell}+${1}
    IF  '${physSCell}'=='${None}'     Set Test Variable  ${ru_id_Ssource}
    ...    ELSE    Set Test Variable  ${ru_id_Ssource}  ${physSCell}
    ${PHYSCELLIDSOURCESCELL}  Get GNB PhysCellId  gnb_id=${gnb_id_source}  nrcell_id=${ru_id_Ssource}
    Set Suite Variable  ${PHYSCELLIDSOURCESCELL}


Setup QC_ID For Report
    [Documentation]
    ...    | Setup QC_ID for SBTS00 (TRUNK) or SBTS24R3 or or SBTSyyRx  |
    ...    | e.g.: set the same Value as "Test Instance ID" in Trunk or SBTS24R3 as showed in QC. |
    ...    | Return QC_ID in form of num (123456)  |

    [Arguments]    ${gnb_id}=${0}    &{Build_to_QCid_Mapping}

    Log To Console    ${\n}The saved gNB SW is:${P_GNBSWVERSION.gnb_${gnb_id}} ${\n}Reset the fetched SW Version.
    Set Suite Variable          &{P_GNBSWVERSION}  gnb_${gnb_id}=${None}

    ${gnb_sw_version}=    testline.Get GNB SW Version    gnb_id=${gnb_id}
    Log to console    ${\n}Set QC_ID for the gNB SW Version: ${gnb_sw_version}

    ${BTS_Build}=    Fetch From Left    ${gnb_sw_version}    _

    ${gNB_Build}    Set Variable    ${BTS_Build}
    Should Contain  ${Build_to_QCid_Mapping}  ${gNB_Build}    msg=Please provide correct set of Build/QC_ID mapping!

    ${QC_ID}    Set Variable    QC_${Build_to_QCid_Mapping}[${gNB_Build}]

    Set Tags  ${QC_ID}
    Log to console    ${\n}Set QC_ID Tag to ${QC_ID}
    ${QC_ID_Num}=    Fetch From Right    ${QC_ID}    _
    RETURN    ${QC_ID_Num}


Setup QCP_ For Report
    [Documentation]
    ...    | Setup QCP_ for Trunk or 24R3 or 24R2 before upgrade. (The running gNB SW is the SOURCE SW.)  |
    ...    | e.g.: set the same Value as "Project" in Trunk or 24R3  |
    ...    | Return QCP_ in form of Name (RAN_VRF)  |
    ...    | ToDo: Use 00 as Trunk and yyRx as Brunch... SBTS is always the same...  |

    [Arguments]    ${gnb_id}=${0}    &{Build_to_QCPrj_Mapping}

    Log To Console    ${\n}The saved gNB SW is:${P_GNBSWVERSION.gnb_${gnb_id}} ${\n}Reset the fetched SW Version.
    Set Suite Variable          &{P_GNBSWVERSION}  gnb_${gnb_id}=${None}

    ${gnb_sw_version}=    testline.Get gNB SW version    gnb_id=${gnb_id}
    Log to console    ${\n}Set QC Project for the gNB SW Version: ${gnb_sw_version}

    ${BTS_Build}=    Fetch From Left    ${gnb_sw_version}    _

    ${gNB_Build}    Set Variable    ${BTS_Build}
    Should Contain  ${Build_to_QCPrj_Mapping}  ${gNB_Build}       msg=Please provide correct set of Build/QC_Project mapping!

    Log To console   QC Project: ${Build_to_QCPrj_Mapping}[${gNB_Build}]

    ${QCPrj}    Set Variable    QCP_${Build_to_QCPrj_Mapping}[${gNB_Build}]

    Set Tags  ${QCPrj}
    Log to console    ${\n}Set QC_Project Tag to ${QCPrj}

    ${QCP_Name}    Set Variable    ${Build_to_QCPrj_Mapping}[${gNB_Build}]
    RETURN    ${QCP_Name}


Collect And Validate The Current SCF File
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} and Validate it online.  |
    [Arguments]    ${node_id}=0    ${node_type}=gnb    ${file_name}=${None}

    ${filname_prefix}=   datetime.Get Current Date    result_format=%Y%m%d_%H%M
    ${file_name}=   Set Variable If   ${file_name == None}   ${filname_prefix}_${node_type.upper()}-${node_id}_current_scf.xml   ${file_name}
    ${current_SCF_Location}    Collect The Current SCF File    node_id=${node_id}    node_type=${node_type}    file_name=${file_name}

    Log To Console    Validating the SCF file located at '${current_SCF_Location}'
    ${oam_alias}    connect.Setup OAM HTTP Session    node_id=${node_id}    node_type=${node_type}
    admin.Validate SCF Online    scf_file=${current_SCF_Location}    detailed_output=True  connection=${oam_alias}


Collect The Current SCF File
    [Documentation]
    ...  |  Get The Current SCF file of ${node_type}${node_id} ...  |
    ...  |  Return: File (local_dir_path, file_name)
    [Arguments]    ${node_id}=0    ${node_type}=gnb    ${file_name}=${None}
    ${filname_prefix}=   datetime.Get Current Date    result_format=%Y%m%d_%H%M
    ${file_name}=   Set Variable If   ${file_name == None}   ${filname_prefix}_${node_type.upper()}-${node_id}_current_scf.xml   ${file_name}
    Log To Console    Collecting the current SCF file of ${node_type.upper()}-${node_id} to file '${file_name}'
    ${resultSuiteBaseDir}=    testline.Get Test Suite Result Base Directory
    ${oam_alias}    connect.Setup OAM HTTP Session    node_id=${node_id}    node_type=${node_type}
    ${current_SCF_Location}    admin.Get Current SCF File
    ...    local_dir_path=${resultSuiteBaseDir}
    ...    file_name=${file_name}
    ...    connection=${oam_alias}
    ...    timeout=30
    RETURN    ${current_SCF_Location}


Store Original Config Files
    [Documentation]
    ...  |  Store the Start SCFC and swconfig.txt files.  |
    ${gNB#1_Original_SCF_Path}=  Store Current SCF from gNB
    Set Suite Variable    ${gNB#1_Original_SCF_Path}
    Log To Console    ${\n}Path to gNB#1 Original SCF: ${\n}${gNB#1_Original_SCF_Path}
    ${gNB#1_Original_swconfig_Path}=  Store Current SWCONFIG From GNB    gnb_id=${0}
    Set Suite Variable    ${gNB#1_Original_swconfig_Path}
    Log To Console    ${\n}Path to gNB#1 Original swconfig.txt: ${\n}${gNB#1_Original_swconfig_Path}
