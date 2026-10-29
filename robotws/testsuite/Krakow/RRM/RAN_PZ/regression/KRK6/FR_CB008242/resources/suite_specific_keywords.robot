*** Settings ***
Documentation
...  author:  Sara Nowak
...  contact: sara.nowak@nokia.com

Library      DateTime
Library      ute_fsmaccess
Library      ute_wtssim
Library      ute_ue
Library      ta5g_pm_counters
Library      ta5g_tshark
Library      SSHLibrary                                 WITH NAME    ssh_lib
Library      taf.ue                                     WITH NAME    ue
Library      taf.rfrl.ue.ute_ue_config.UteUeConfig      WITH NAME    uteueconfig
Library      taf.ccs.aashell                            WITH NAME    cli
Library      taf.sbts.oam.coam.admin                    WITH NAME    admin_cli
Library      taf.rfrl.utilities.test_config.DefaultFileLocation    WITH NAME  dfl
Library      taf/rfrl/bts/devices/du/logs_collecting/bip_collector.py
Library      testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py
Library      ./keywords.py

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./variables.py
Variables    ./delta.py

*** Variables ***
${CURRENT_TEST_SCF_NAME}    current_test_scf.xml
${skip_commissioning}        ${NONE}

*** Keywords ***
Suite Setup
    [Documentation]    Common part for all test cases
    Run Keyword If    '${skip_commissioning}' != 'true'     Run Keywords
    ...                Upload Swconfig On Classical Gnb    bts_id=0    prefix_tag=CB008294_CB008242   AND
    ...                common_setups_and_teardowns.Common Suite Setup With Commissioning  prefix_tag=CB008294_CB008242
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    ${release}=    dfl.Get Commissioning Branch
    Set Suite Variable    ${release}
    Activate automatic unified access control

Test Setup
    [Documentation]     Test setup
    Log Action To Console    Test Setup started
    Activate automatic unified access control

D 300 Test Setup
    [Documentation]     Test setup
    Log Action To Console    Test Setup started
    Setup UE Before Test
    Activate automatic unified access control

G 100 Test Setup
    [Documentation]     Test setup
    Log Action To Console    Test Setup started
    Download Current Scfc File    ${CURRENT_TEST_SCF_NAME}
    Activate automatic unified access control

Test Teardown
    [Documentation]     Test teardown for A_100 test
    Log Action To Console    Test Teardown started
    Exit Overload State on gNB-CU
    Deactivate automatic unified access control
    Common Postconditions

D 300 Test Teardown
    [Documentation]     Test teardown for D_300 test
    Log Action To Console    Test Teardown started
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Deactivate automatic unified access control
    Common Postconditions

G 100 Test Teardown
    [Documentation]     Test teardown for A_100 test
    Log Action To Console    Test Teardown started
    Common Postconditions
    Exit Overload State on gNB-CU
    Deactivate automatic unified access control
    Perform Commissioning    ${CURRENT_TEST_SCF_NAME}

G 300 Test Teardown
    [Documentation]     Test teardown for A_100 test
    Log Action To Console    Test Teardown started
    Exit Overload State on gNB-CU
    Deactivate automatic unified access control
    Set actUacAuto on gNB     value=true
    Common Postconditions

Setup UE Before Test
    ${status}=    Run Keyword And Return Status    ue.Require Ue    UE    QC_2
    Run Keyword If    '${status}' == '${False}'    Run Keywords     Restart UE PROXY Service     AND    ue.Require Ue    UE    QC_2
    Run Keyword And Ignore Error    ue.Detach UE   UE

Download Current Scfc File
    [Arguments]    ${scf_name}
    [Documentation]    Downloads scf file from gNB.
    ...                :param scf_name: name of scf file (default location is output direcotry)
    Log Action To Console    Download Current Scfc File
    Download gNB Configuration File    local_dir=${OUTPUT DIR}    filename=${scf_name}

Collect BIP Log And Verify SIB1 Message With Static Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for static uac settings
    Log Action To Console    Start collecting BIP log for static UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${static_uac_message}   description=static

Collect BIP Log And Verify SIB1 Message With Th4(max) Auto Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for Th4 auto uac settings
    Log Action To Console    Start collecting BIP log for Th4(max) auto UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${th4_auto_uac_message}   description=Th4(max) auto

Collect BIP Log And Verify SIB1 Message With New Th4(max) Auto Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for Th4 auto uac settings
    Log Action To Console    Start collecting BIP log for New Th4(max) auto UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${th4_auto_uac_message_G_100}   description=New Th4(max) auto

Collect BIP Log And Verify SIB1 Message With Th3 Auto Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for Th3 auto uac settings
    Log Action To Console    Start collecting BIP log for Th3 auto UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${th3_auto_uac_message}   description=Th3 auto

Collect BIP Log And Verify SIB1 Message With Th2 Auto Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for Th2 auto uac settings
    Log Action To Console    Start collecting BIP log for Th2 auto UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${th2_auto_uac_message}   description=Th2 auto

Collect BIP Log And Verify SIB1 Message With Th1 Auto Uac Settings
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message for Th1 auto uac settings
    Log Action To Console    Start collecting BIP log for Th1 auto UAC settings
    Collect BIP Log And Verify SIB1 Message     msg=${th1_auto_uac_message}   description=Th1 auto

Collect BIP Log And Verify SIB1 Message
    [Documentation]     This keyword collects BIP log and verifies SIB1 Message
    ...                 :param msg: name of message
    ...                 :param description: description of message whiich should be checked
    [Arguments]    ${msg}   ${description}
    Collect BIP log
    Log Action To Console    Verify If SIB1 contains ${description} UAC settings
    Get BIP File Name and Verify SIB1 message      msg=${msg}

Collect PM Counters Before Test
    [Documentation]     This keyword collects PM Couters before test
    Log Action To Console     Collect M55164C00001 Counter Before Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File
    &{counters_before_tests}=    Collect Counters Values    ${time_auto_uac_ovl_counters}    ${pm_counters_file}
    Log    Value of counters before test: ${counters_before_tests}

    Set Global Variable    ${counters_before_tests}

Collect Counters Values
    [Documentation]     This keyword collects PM Couters values
    ...                 :param counters: id of counters which values should be collected
    ...                 :param pm_counters_file: path name of pm counter file
    [Arguments]    ${counters}    ${pm_counters_file}

    &{counters_values}=    Create Dictionary

    FOR    ${counter}    IN    @{counters}
        @{values}    get_pm_counter_value    counter=${counter.id}    localmoid=${counter.localmoid}   filepath=${pm_counters_file}
        ${values_length}=  Get Length    ${values}
        ${value}=  	Set Variable If	   ${values_length} != 0	${values[0]}	${-1}
        Set To Dictionary    ${counters_values}    ${counter.label}=${value}
        Log    Value of ${counter}: ${value}
    END
    [Return]    ${counters_values}

Collect PM Counters After Test
    [Documentation]     This keyword collects PM Couters after test
    Log Action To Console     Collect M55164C00001 Counter After Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File
    &{counters_after_tests}=    Collect Counters Values    ${time_auto_uac_ovl_counters}    ${pm_counters_file}
    Log    Value of counters after test: ${counters_after_tests}

    Set Global Variable    ${counters_after_tests}

Verify M55164C00001 Counter Updates
    [Documentation]     This keyword verifies M55164C00001 Counter update
    Log Action To Console    Verify Counter Updates
    Compare Counter Values    ${counters_before_tests}    ${counters_after_tests}

Enter Overload State on gNB-CU
    [Documentation]     This keyword enters overload state on gNB-CU
    Log Action To Console    Enter overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    0

Exit Overload State on gNB-CU
    [Documentation]     This keyword exits overload state on gNB-CU
    Log Action To Console    Exit overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    100

Verify Network Access Rate Reduction
    [Documentation]     This keyword verifies NetworkAccessRateReduction message in pcap log
    Log Action To Console    Verify Network Access Rate Reduction message
    Collect PCAP Log On gNB     pcap_filename=${cu_overload_pcap_filename}
    Verify PCAP Log     msg=${network_access_rate_reduction_message}
    ...                 pcap_path=${OUTPUT_DIR}/${cu_overload_pcap_filename}

Wait Until StartUacBarringTimerOverload Expires
    [Documentation]     This keyword waiting until StartUacBarringTimerOverload expires
    Log Action To Console    Wait until startUacBarringTimerOverload expires
    Sleep    30s

Wait Until StartUacBarringTimer Expires
    [Documentation]     This keyword waiting until StartUacBarringTimer expires
    Log Action To Console    Wait until startUacBarringTimer expires
    Sleep    50s

Wait Until StopUacBarringTimerOverload Expires And SIB1 UAC Downgrade Procedure Finishes
    [Documentation]     This keyword waiting until StopUacBarringTimerOverload expires and UAC Downgrade Procedure Finishes
    Log Action To Console    Wait until stopUacBarringTimerOverload expires
    Sleep    90s
    Log Action To Console    Wait until SIB1 UAC downgrade procedure finishes
    Sleep    360s

Wait Until StopUacBarringTimerOverload And UacUpdateTimer expires
    [Documentation]     This keyword waiting until stopUacBarringTimerOverload and uacUpdateTimer expires
    Log Action To Console    Wait until stopUacBarringTimerOverload expires
    Sleep    50s
    Log Action To Console    Wait until uacUpdateTimer expires
    Sleep    80s

Wait Until UacUpdateTimer Expires
    [Documentation]     This keyword waiting until uacUpdateTimer expires
    Log Action To Console    Wait until uacUpdateTimer expires
    Sleep    60s

Wait Until UacUpdateTimer Expires After uacAcCatList Modification
    [Documentation]     This keyword waiting until uacUpdateTimer expires
    Log Action To Console    Wait until uacUpdateTimer expires after uacAcCatList modification
    Sleep    90s

Verify Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cell
    [Documentation]     This keyword verifies if auto UAC alarm is active on gNB
    Log Action To Console    Verify alarm EFaultId_AutomaticUnifiedAccessControlBarringAl is active on gNB
    Verify Alarm is Active on gNB    fault_name=Automatic Unified Access Control Barring is active
    ...                              fault_id=7533

Verify No Alarm EFaultId_AutomaticUnifiedAccessControlBarringAl On Cell
    [Documentation]     This keyword verifies if auto UAC alarm is not active on gNB
    Log Action To Console    Verify alarm EFaultId_AutomaticUnifiedAccessControlBarringAl is not active on gNB
    Verify Alarm is not Active on gNB    fault_name=Automatic Unified Access Control Barring is active
    ...                                  fault_id=7533

Get BIP File Name and Verify SIB1 message
    [Arguments]    ${msg}
    [Documentation]     This keyword finds BIP log location and verifies the content of the SIB message
    ...                 :param msg: name of the message to verifing in BIP log
    ${pcap_filename}=    Get Bip File Name  path=${OUTPUT_DIR}/BipCollectorAdmin_GNB0_DU0/
    Verify PCAP Log      msg=${msg}    pcap_path=${pcap_filename}

Verify PCAP Log
    [Arguments]   ${msg}    ${pcap_path}
    [Documentation]     This keyword verifies if SIB1 with static UAC settings occured
    ...                 :param msg: name of the message to verifing in BIP log
    ...                 :param pcap_path: path name of the pcap file created during the test
    @{message_query}=   Create List    ${msg}
    ${message_found}=   Expect Messages In Flow    awaited_messages=${message_query}   pcap_file=${pcap_path}
    Run Keyword If      ${message_found} == ${False}    Fail    msg=Message doesn't available in PCAP log.

Collect BIP log
    [Documentation]     This keyword collects L1L2 logs
    bip_collector.Start Bip Trace Log Capturing
    Sleep    1s
    bip_collector.Stop Bip Trace Log Capturing
    bip_collector.Download Bip Logs    download_dir=${OUTPUT_DIR}

Get Cells ID
    [Documentation]     This keyword gets cells ID
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${gnb_cell1_id}      ${abstract_lib_config.CELLS.GNB1.CELL1.NRCELLID}

Change RnD Flags By aaShell
    [Arguments]    @{args}    ${is_permanent}=no
    [Documentation]     This keyword changes R&D flags by aashell
    ...                 :param args: dictionary with R&D flags and their values to change
    ...                 :param is_permanent: indication if the change should be permanent
    cli.create_aashell_cli    name=aashell
    cli.setup    aashell
    cli.change_rad_params    aashell    ${args}    ${is_permanent}
    Sleep  2s    Wait for r&d param application
    [Teardown]    cli.teardown   aashell

Collect PCAP Log On gNB
    [Arguments]    ${pcap_filename}
    [Documentation]     This keyword stops collecting pcap on gNB on any interface
    ...                 :param pcap_filename: name of the pcap file created during the test
    Start tcpdump on CU     filename=${pcap_filename}    interface=any
    Sleep    1s
    Stop tcpdump on CU and Download Logs    filename=${pcap_filename}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Change Automatic UAC Parameters
    [Documentation]  This keyword performs delta commissioning with new Auto Uac parameters
    Perform Delta Commissioning On gNB     delta=${delta_g_100_uacAcCatList_modification}     gnb_id=0

Deactivate automatic unified access control
    Log Action To Console    Deactivate automatic unified access control
    Set actUacAuto on gNB     value=false

Activate automatic unified access control
    Log Action To Console    Activate automatic unified access control
    Set actUacAuto on gNB     value=true

Set actUacAuto on gNB
    [Arguments]    ${value}=true
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actUacAuto
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${360}

Set triggersBitmap on gNB
    [Arguments]    ${value}=3
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRUAC_AUTO_PROFILE-0
    ...    param_name=triggersBitmap
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${360}

Perform Commissioning
    [Arguments]    ${scf_name}    ${scf_dir}=${OUTPUT DIR}
    [Documentation]    Performs Commissioning of gNB.
    ...                :param scf_name: name of scf file (default location is output direcotry)
    Log Action To Console    Performs Commissioning
    Perform Full Commissioning On Classical Gnb    bts_id=0    scf_path=${scf_dir}/${scf_name}
    Wait until keyword succeeds     300 sec    15 sec    Verify gNB is onAir

Detach UE
    Log Action To Console    Detach UE
    ue.Detach UE   UE

Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Log Action To Console    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Attach UE

Attach UE
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_attach_${date}.pcap
    collect_logs.Start tcpdump on CU     filename=${pcap_file}    interface=any -U
    Set Test Variable    ${pcap_attach_log_path}    ${pcap_file}
    ue.Attach UE   UE
    ue.Create PDU Session    UE
    Sleep  20s
    collect_logs.Stop tcpdump on CU and Download Logs    filename=${pcap_file}

Restart UE PROXY Service
    Log Action To Console        Restart UE PROXY Service

    ${host}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_ip}
    ${username}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_login}
    ${password}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_password}

    ssh_lib.Open Connection      host=${host}    timeout=60s
    ssh_lib.Login                username=${username}    password=${password}
    ssh_lib.Execute Command      net stop UE_PROXY_AT && net start UE_PROXY_AT
    Sleep                        10s

    [Teardown]   ssh_lib.Close Connection
