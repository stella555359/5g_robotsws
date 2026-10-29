*** Settings ***
Documentation
...    This resource file implements the initialization of all UEs that are defined in the config file of the TL to bring
...    them to the defined state of being detached (i.e. Airplane mode on) and the preferred_net_mode_set to the default setting 'NR/LTE/GSM/WCDMA'.
...    Note that this was designed for Android-based UEs and may not fully be supported on other UE types.
...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
...    | Team:        | MN RAN RD VRF ULM 1 (CSV ULM)                     |
...    | Team Email:  | <I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com>        |

#-------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../MORAN_Tests/resources/moran_tc_kw_lib.robot
Resource    ../../../resources/Common/testline.robot
Resource    ../resources/commonKeywords.robot

Suite Setup     UE Initialization Test Suite Setup Keyword
Suite Teardown  UE Initialization Test Suite Teardown Keyword



*** Variables ***
${consolewidth}=                140
${barwidth}=                    130



*** Test Cases ***
Initialize all TL UEs
    [Documentation]      This testcase implements the initialization of all UEs that are defined in the __init__.py TL configuration file
    [Tags]    TL_UE_initialization
    [Setup]    UE Initialization Test Case Setup Keyword

    ${num_of_ues}=    Get length    ${tl.ues}

    Log To Console    ${\n}INFO: The TL configuration file of '${P_TL_NAME}' has in total '${num_of_ues}' UEs defined

    FOR    ${UE_idx}    IN RANGE    ${0}    ${num_of_ues}


        ${ALIAS_UE}=   Require and connect to UE with Index ${UE_idx}

        Get and Print Ue Info   ALIAS_UE=${ALIAS_UE}  PHASE_DESCRIPTION_STRING=\ PRIOR to UE INITIALIZATION

        # --- BEGIN of UE INTIALIZATION STEPS ------------------------------

        moran_tc_kw_lib.Get and Set the "preferred_net_mode" of the Android UE that is used for the test
        ...    ALIAS_UE=${ALIAS_UE}   preferred_net_mode=NR/LTE/GSM/WCDMA    fail_if_unsuccessful=${False}

        # making sure that the current UE is in AIRPLANE MODE
        Log To Console    ${\n}Making sure that '${ALIAS_UE}' is in AIRPLANE MODE ...
        Log To Console    \ Detaching ${ALIAS_UE}
        taf.ue.Detach UE   ${ALIAS_UE}   validation=${False}   force_change_mode=${True}
        Log To Console    \ \ Done!${\n}

        # --- END of UE INTIALIZATION STEPS ------------------------------

        Get and Print Ue Info   ALIAS_UE=${ALIAS_UE}  PHASE_DESCRIPTION_STRING=\ AFTER UE INITIALIZATION

    END

    builtin.Log To Console   \ IPERF PROCESSES \    format=*^${{int(int($consolewidth)*0.8)-6}}

    Log To Console    Killing all iPerf processes that might be still running on APP_SERV or UC_CTRL_PC hosts ...
    Run Keyword And Continue On Failure    iperf_processes.Kill All iPerf Processes On Appserver And UE PC

    [Teardown]    UE Initialization Test Case Teardown Keyword



*** Keywords ***

Require and connect to UE with Index ${UE_idx}
    [Documentation]   This keyword connects to the UE via taf.ue library
    ${ALIAS_UE}=   Set Variable   UE_${UE_idx+1}

    builtin.Log To Console   \ ${ALIAS_UE} \    format=*^${{int(int($consolewidth)*0.8)-6}}

    ${ueType}=    testline.Get UE type    ue_id=${UE_idx}
    Log To Console    ${\n}INFO: ${ALIAS_UE} with UE index ${UE_idx} is of type '${ueType}'

    Log To Console    ${\n}Calling 'Require UE' KW for ${ALIAS_UE}
    ${UE_NAME}    taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
    Log To Console    ${ALIAS_UE} has following UE object name: ${UE_NAME}

    RETURN   ${ALIAS_UE}


Get and Print Ue Info
    [Documentation]   This keyword gets the UE Info dictionary and prints it to the console
    [Arguments]       ${ALIAS_UE}     ${PHASE_DESCRIPTION_STRING}=${EMPTY}

    ${get_UE_Info_Status}   ${get_UE_Info_Dictionary}   Run Keyword And Warn On Failure    taf.ue.Get UE Info   ${ALIAS_UE}
    IF  '${get_UE_Info_Status}' == 'PASS'
        ${UE_INFO_DICT_pretty_str}=    builtin.Evaluate   pprint.pformat(${get_UE_Info_Dictionary})   modules=pprint
        Log To Console    ${\n}${ALIAS_UE} device information${PHASE_DESCRIPTION_STRING}:${\n}${UE_INFO_DICT_pretty_str}
    ELSE
        Log    Cannot print the ${ALIAS_UE} device information${PHASE_DESCRIPTION_STRING}, as the "taf.ue.Get UE Info" KW call has failed!
        ...   level=WARN
    END


UE Initialization Test Case Setup Keyword
    [Documentation]   This is the keyword implementing the steps to be preformed during "Test Setup" phase of UE Initialization TC executions.

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   Running "UE Initialization Test Case Setup Keyword" ...   format=\ <${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}

    # getting current active alarms on the SBTS MORAN site and displaying them on the console
    gnb.Get Current Alarms From Node    node_type=gnb



UE Initialization Test Case Teardown Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Case Teardown" phase of UE Initialization TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   Running "UE Initialization Test Case Teardown Keyword" ...   format=\ <${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}



UE Initialization Test Suite Setup Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Suite Setup" phase of UE Initialization TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   Running "UE Initialization Test Suite Setup Keyword" ...   format=\ <${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}

    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Start tcpdump trace via eth3 interface connected to the monitoring port of testline switch
    END

    commonKeywords.Restart UEPROXY service on UEPC

    testline.Set Console Output

    # preparing folder path for log files
    testline.Create Test Suite Log Folders
    ${ts_log_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}

    builtin.Log To Console   The logs of this test run will be available at: ${P_resultSuiteBaseDir}
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}

    ##builtin.Log To Console    ${\n}Waiting until all cells of SRAN BTS with MORAN site configuration are in 'OnAir' state ...
    #Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    timeout=30s
    #Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    timeout=30s

    ${gnb_sw_version}=    testline.Get gNB SW version    gnb_id=${0}
    builtin.Log to console    ${EMPTY}
    builtin.Log to console    INFO: GNB SW Version is: ${gnb_sw_version}
    ${current_oru_fw_version}=    commonKeywords.Get Running ORAN RU FW version if applicable
    builtin.Log to console    ${EMPTY}


UE Initialization Test Suite Teardown Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Suite Teardown" phase of UE Initialization TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   Running "UE Initialization Test Suite Teardown Keyword" ...   format=\ <${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}

    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Stop and collect tcpdump trace via eth3 interface connected to the monitoring port of testline switch
       ...   target_dir=${P_resultSuiteBaseDir}
    END

    Log To Console    Storing log files at path: '${ts_log_dir}'


