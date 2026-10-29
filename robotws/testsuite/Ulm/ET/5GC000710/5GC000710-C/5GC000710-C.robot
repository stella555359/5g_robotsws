*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000710-C
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        5GC000710-C-keywords.robot
Resource        5GC000710-C-commissioning.robot
Resource        5GC000710-C-verify-wireshark.robot
Resource        5GC000710-C-verify-counter.robot
Resource        5GC000710-C-wts.robot
Resource        5GC000710-C-parameter-settings.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/reporting.robot

Suite Setup       Suite Setup 710C
Suite Teardown    Suite Teardown 710C

*** Variables ***
${redirFreqNr-0}                      125900
${redirFreqNr-1}                      128000
${redirFreqNr-2}                      176500
${logs_collected}                     False

&{SCF}                                &{EMPTY}

*** Test Cases ***

5GC000710_C_SA_Redirection_to_target_based_on_priority_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 4 and redirect to gNB1 cell3
    ...                UE3 select profile 4 and redirect to gNB1 cell4
    ...                UE1 select profile 32-default and no redirect
    ...                M55157C00036 NRMOP_SA_PROFILE_SELECTED_04  M55157C00064 NRMOP_SA_PROFILE_SELECTED_32
    ...                M55124C01501 NRRCC_RRC_RELEASE_REDIR_NR
    ...                M55124C02002 NRRCC_MEAS_A2_REC
    ...       :Autor: Sylvia Schneider
    [Tags]   t1    CIT
    [Setup]   Perform Preconditions of Test Scenario 710C

    prepare counters and expected values t1
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set AMF param indexToRFSP     indexToRFSP=99
    setup UE and redirect cell      ue_id=51   redirection_cell=3
    setup UE and redirect cell      ue_id=53   redirection_cell=4
    set AMF param indexToRFSP     indexToRFSP=none
    setup UE52

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t1
    verify wireshark t1

    [Teardown]   Perform Postconditions of Test Scenario 710C


5GC000710_C_SA_Redirection_based_on_UE_capabilities_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 3 and no A2 measurement generated
    ...                UE3 select profile 3 and redirect to gNB1 cell4
    ...                M55157C00037 NRMOP_SA_PROFILE_SELECTED_05
    ...                M55124C01501 NRRCC_RRC_RELEASE_REDIR_NR
    ...                M55124C02002 NRRCC_MEAS_A2_REC
    ...       :Autor: Sylvia Schneider
    [Tags]   t2    CRT
    [Setup]   Perform Preconditions of Test Scenario 710C

    prepare counters and expected values t2
    tc specific update and activate SCF and bring tl onAir with plmn2

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set AMF param indexToRFSP     indexToRFSP=77
    setup UE51
    setup UE and redirect cell      ue_id=53   redirection_cell=4

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t2
    verify wireshark t2

    [Teardown]   Perform Postconditions of Test Scenario 710C


5GC000710_C_SA_Redirection_with_rsrpCombined_and_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE2 select profile 2
    ...                1st A2 no redirect, rsrq criteria not fulfilled
    ...                2nd A2 redirect to gNB1 cell2
    ...                M55157C00034 NRMOP_SA_PROFILE_SELECTED_02
    ...                M55124C01501 NRRCC_RRC_RELEASE_REDIR_NR
    ...                M55124C02002 NRRCC_MEAS_A2_REC
    ...       :Autor: Sylvia Schneider
    [Tags]   t3    CRT
    [Setup]   Perform Preconditions of Test Scenario 710C

    prepare counters and expected values t3
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    setup UE52 and send 2 A2 measurements and redirect cell      redirection_cell=2

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t3
    verify wireshark t3

    [Teardown]   Perform Postconditions of Test Scenario 710C

5GC000710_C_SA_Redirection_after_inter_gNB_handover_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 4
    ...                A3 measurement for handover to gNB 1 cell1
    ...                A3 measurement for handover back to gNB2  with profile 4
    ...                A2 measurement for redirect to gNB1 cell3
    ...                M55157C00036 NRMOP_SA_PROFILE_SELECTED_04
    ...                M55124C01501 NRRCC_RRC_RELEASE_REDIR_NR
    ...                M55124C02002 NRRCC_MEAS_A2_REC
    ...       :Autor: Sylvia Schneider
    [Tags]   t4    CRT
    [Setup]   Perform Preconditions of Test Scenario 710C

    prepare counters and expected values t4
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set AMF param indexToRFSP     indexToRFSP=99
    setup UE51 and trigger handovers and redirect cell      redirection_cell=3

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t4
    verify wireshark t4

    [Teardown]   Perform Postconditions of Test Scenario 710C


5GC000710_C_SA_Redirection_to_LTE_eNB_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 6
    ...                A2 measurement for redirect to eNB1 cell2
    ...                M55157C00038 NRMOP_SA_PROFILE_SELECTED_06
    ...                M55124C01501 NRRCC_RRC_RELEASE_REDIR_NR
    ...                M55124C01502 NRRCC_RRC_RELEASE_REDIR_LTE
    ...                M55124C02002 NRRCC_MEAS_A2_REC
    ...       :Autor: Sylvia Schneider
    [Tags]   t5    CRT    CDRT
    [Setup]   Perform Preconditions of Test Scenario 710C

    prepare counters and expected values t5
    tc specific update and activate SCF and bring tl onAir with plmn1_LTE

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set AMF param indexToRFSP     indexToRFSP=100
    Setup UE51 And Trigger Unsuccessful PDU Modification And Redirect To LTE

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    collect pm file and verify counter values t5
    verify wireshark t5

    [Teardown]   Perform Postconditions of Test Scenario 710C



*** Keywords ***
Suite Setup 710C
    [Documentation]    [PRIVATE]    Prepare TL for 5GC000710-C
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    gnb.Store Current SCF from gNB
    get nrarfcn plmn tac version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC 710C plmn1
    Update wts file for TC 710C plmn2
    Update wts file for TC 710C plmn1_LTE
    Update SCF common part


Perform Preconditions of Test Scenario 710C
    [Documentation]    [PRIVATE]    preconditions for 710C
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder


get nrarfcn plmn tac version from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    parse XML    ${P_ORIG_SCF}
    ${nrarfcnDl}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3/NRCELL_FDD-1"]/p[@name="nrarfcnDl"]
    Set To Dictionary    ${SCF}   nrarfcnDl   ${nrarfcnDl}
    Log To Console    variable SCF.nrarfcnDl contains ${SCF.nrarfcnDl}

    ${nrarfcnUl}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3/NRCELL_FDD-1"]/p[@name="nrarfcnUl"]
    Set To Dictionary    ${SCF}   nrarfcnUl   ${nrarfcnUl}
    Log To Console    variable SCF.nrarfcnDl contains ${SCF.nrarfcnUl}

    ${mcc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set To Dictionary    ${SCF}   mcc   ${mcc}
    Log To Console    variable SCF.mcc contains ${SCF.mcc}

    ${mnc}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set To Dictionary    ${SCF}   mnc   ${mnc}
    Log To Console    variable SCF.mnc contains ${SCF.mnc}

    ${mncLength}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    Set To Dictionary    ${SCF}   mncLength   ${mncLength}
    Log To Console    variable SCF.mncLength contains ${SCF.mncLength}

    ${fiveGsTac}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    Set To Dictionary    ${SCF}   fiveGsTac   ${fiveGsTac}
    Log To Console    variable SCF.fiveGsTac contains ${SCF.fiveGsTac}

    ${version}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set To Dictionary    ${SCF}   version   ${version}
    Log To Console    variable SCF.version contains ${SCF.version}


Perform Postconditions of Test Scenario 710C
    [Documentation]    [PRIVATE]    postconditions for 710C
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 710C
    [Documentation]    [PRIVATE]    suite teardown for 710C
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   stop wireshark trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config
