*** Settings ***
Documentation    This file contains Keywords specific to CB008278 Feature
Library         Collections
Library         XML
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Variables       ta5g_global_var
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         ${CURDIR}/../../../resources/PythonLib/UTILS.py
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../ute/ute_wts_runner.robot
Resource        ${CURDIR}/../Keywords/common_keywords.robot


*** Variables ***
${DELTACONFIGDIR}          ${CURDIR}/../../config/gnb_scf/
${IPHYCONFIGDIR}           ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}                CLOUD_5G_I_LO_AP_LO
${LOG_DIR}                 /home/ute/logs

*** Keywords ***
Commission Scf And Iphy For 8278
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]        ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'        Update And Put Iphy Xml    input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'         GNB Delta Commission       ${scf}

Prepare For Test Case - CB008278 AC3
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB008278_AC3
    Link SCOUT SCF To Configuration ID For Reporting
    Create Basic Interface On UTE
    Commission Scf And Iphy For 8278   scf=${DeltaConfigDir}/Delta_Configuration_8278_A_IntraFreqChanges.json
    ...                                iphy=${IPHYCONFIGDIR}/MP_AP_LO_TDD.xml
    Log To Console       \nRebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep               360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Basic Bring Up Gnb          basic_setup_MP_AP_LO.cfg
    [Return]                    ${Log_Path}

Prepare For Test Case - CB008278 AC4
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB008278_AC4
    Link SCOUT SCF To Configuration ID For Reporting
    Create Basic Interface On UTE
    Commission Scf And Iphy For 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_InterFreqChanges.json
    ...                                       iphy=${IPHYCONFIGDIR}/new_iphy_AEHC_AEQE.xml
    Log To Console       Rebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep               360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Basic Bring Up Gnb          wts.cfg
    [Return]                    ${Log_Path}

Prepare For Test Case - CB008278 AC5
    [Documentation]     This Keyword is specifically used for setting up testcase CB008064_B01
    ${Log_Path}        Create Log Directory        CB008278_AC5
    Link SCOUT SCF To Configuration ID For Reporting
    Create Basic Interface On UTE
    Commission Scf And Iphy For 8278           scf=${DeltaConfigDir}/Delta_Configuration_8278_A_Beamforming.json
    ...                                       iphy=${IPHYCONFIGDIR}/new_iphy_AEHC_AEQE.xml
    Log To Console       Rebooting GNB wait for 360 seconds...
    GNB Reboot
    Sleep               360s
    Wait Coam Site To Be Ready
    Start Pcap Collection In GNB CU
    Basic Bring Up Gnb          wts.cfg
    [Return]                    ${Log_Path}

Make SA Call
    [Documentation]    This is normal SA Call without derigister
    [Arguments]    ${UE_ID}=${UE_ID}
    Enable Internal TG   1  1
    UE Register Should Be Successful        ${UE_ID}
    Sleep   10s
    Traffic Should Be Successful For SA

Basic Bring Up Gnb
    [Documentation]     This keyword is for basic bring up the setup it setup config file and then
    ...                 Make sure NG link , X2AP link  and AP cell setup are done to reach on air
    ...                 Arguments passed is the cfg file from config/wts/setupfile.cfg
    [Arguments]         ${config_wts_basic_setup}=basic_setup.cfg
    Start UTE WTS       ${config_wts_basic_setup}
    Log To Console      config setup Done
    NG Link Should Be UP
    Log To Console      NG link is up
    X2AP Link Should Be UP
    Log To Console      X2AP link should be Up

Common Test Case Tear Down LO AP LO
    [Documentation]    This Keyword is for common teardown for all test cases.
    Stop Pcap Collection In GNB       gnbTcpdump      ${Log_Path}
    Delete Basic Interface On UTE
    Collect Logs For The Test           ${Log_Path}
    Update And Put Iphy Xml         ${IPHYCONFIGDIR}/LO_AP_LO_IPHY.xml
    Full Commission With SCF File For UTE       ${DeltaConfigDir}/LO_AP_LO_SCF.xml
    Sleep   300s

Suite TearDown For CB008278
    [Documentation]    This Keyword is for Suite Teardown for our Feature
    RAT Block Unblock
    Common Suite Teardown

Common Test Teardown For MP AP LO
    Delete Basic Interface On UTE
    Collect Logs For The Test       ${Log_Path}
    RAT Block Unblock
