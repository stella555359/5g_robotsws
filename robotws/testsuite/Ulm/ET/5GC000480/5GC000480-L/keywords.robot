** Settings ***
Documentation   This is a keyword file for 5GC000480-L, part keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../../resources/Common/reporting.robot


*** Keywords ***

Update Sw Config To Trace Missing Pm Counter RACDU
    [Documentation]    [PRIVATE]    update sw config to trace missing pm counter RACDU
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update flags for tracing pm counter RACDU
    Log To Console    \#BSTAT
    Log To Console    0x340001=1 \#enable BStat core flag
    Log To Console    0x340002=1 \#enable BStat PM flag
    Log To Console    0x340006=55115 \#Debug flag for M55115
    Log To Console    0x34000A=1 \#ArrAggrCollectionService
    @{list_add_flags}   Create List
    ...       0x340001=1
    ...       0x340002=1
    ...       0x340006=55115
    ...       0x34000A=1
    ...       0x590072=1
    gnb.Update SW Config File On System Module   param_list=@{list_add_flags}


Get Version mcc mnc From gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update commissioning
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${current_SCF_gnb}
    ${parsed_SCF}    Parse XML    ${current_SCF_gnb}
    ${version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}
    ${MNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="MRBTS-1/MNL-1"]
    Set To Dictionary    ${SCF}   MNL_version   ${MNL_version}
    Log To Console    variable SCF.MNL_version contains ${SCF.MNL_version}
    ${NRPMRNL_version}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_version   ${NRPMRNL_version}
    Log To Console    variable SCF.NRPMRNL_version contains ${SCF.NRPMRNL_version}
    ${NRPMRNL_distName}    Get Element Attribute    ${parsed_SCF}    distName     xpath=.//managedObject[@class="com.nokia.srbts.nrbts:NRPMRNL"]
    Set To Dictionary    ${SCF}   NRPMRNL_distName   ${NRPMRNL_distName}
    Log To Console    variable SCF.NRPMRNL_distName contains ${SCF.NRPMRNL_distName}
    ${mcc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}
    ${mnc}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}


Check All Radio Units Online
    [Documentation]    [PRIVATE]   check that all radio units are online
    ...     :Autor: Sylvia Schneider
    Log To Console    Waiting until all RUs are online
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Wait Until Keyword Succeeds
    ...    10min   20sec
    ...    gnb.Verify All Radios Are Online    connection=${oam_alias}
    Log to console    RUs ready
    [Teardown]     connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Collect Pm File And Verify Counter Values
    [Documentation]    [PRIVATE]    collect pm file and verify counter values
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    Verify Counter Values


Verify Counter Values
    [Documentation]    [PRIVATE]    Verify counter values
    ...       :Autor: Sylvia Schneider
    ${parsed_xml}    Parse Xml    ${pmCounter_xml_file}

    Log To Console    \ncounters for cell NRCELL-1 are verified
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter1}
    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_pm_counter1}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

    Log To Console    \ncounters for cell NRCELL-2 are verified
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter2}
    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_pm_counter2}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

    Log To Console    \ncounters for cell NRCELL-3 are verified
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter3}
    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_pm_counter3}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

    Log To Console    \ncounters for cell NRCELL-4 are verified
    @{dict_keys}    Get Dictionary Keys    ${dict_pm_counter4}
    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict_pm_counter4}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END


Suite Teardown 480L
    [Documentation]    [PRIVATE]    suite teardown for 480L
    ...       :Autor: Sylvia Schneider
    wireshark.Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    keywordbook-480.Collect Snapshot And Sos Report Data   ${resultBaseDir}
    wts_ue.Reload Stored WTS Config


Perform Preconditions Of Test Scenario 480L
    [Documentation]    [PRIVATE]    preconditions for 480L
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create a Test Scenario Folder


Perform Postconditions Of Test Scenario 480L
    [Documentation]    [PRIVATE]    postconditions for 480L
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID for Reporting
    wireshark.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    wts_ue.Teardown Egate Connection for Airphone
    wts_ue.Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    keywordbook-480.Collect Snapshot And Sos Report Data     ${resultDir}
