*** Settings ***
Documentation
...    5GC000637 Xn Management for SA Option 2
...
...    See: https://feature-corner.nsn-net.net/materials/cl8u9708t1194624xkzf7vyr79y

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Resource    ../../resources/main_resources.robot

# -- extra resources --
Variables    ${RESOURCES}/message_definition.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown    RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000637.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA_ACTIVATE_XN_LINK}    ${RESOURCES}/delta_activate_xn_link.json
${DELTA_LOCK_XN}    ${RESOURCES}/delta_lock_xn_procedure.json
${DELTA_UNLOCK_XN}    ${RESOURCES}/delta_unlock_xn_procedure.json
${XN_UPDATE}    ${RESOURCES}/xn_update.json

*** Test Cases ***
5GC000637-A_-_Xn_Management_-_OAM_configuration_of_locked_Xn_Gnb_link
    [Documentation]
    ...    Verifies that Xn state stays "unavailable" when administrative state of adjacent gNodeB is "locked".
    [Setup]    [PRE]5GC000637-A_-_Xn_Management_-_OAM_configuration_of_locked_Xn_Gnb_link
    [Teardown]    [POST]5GC000637-A_-_Xn_Management_-_OAM_configuration_of_locked_Xn_Gnb_link
    Trigger Xn Setup Request And Verify Not Configured
    Verify Xn Link Status Is Unavailable

5GC000637-A_-_Xn_Management_-_establishment_of_Xn_Gnb
    [Documentation]    Verifies that Xn link between 2 gNB can be established.
    [Setup]    [PRE]5GC000637-A_-_Xn_Management_-_establishment_of_Xn_Gnb
    [Teardown]    [POST]5GC000637-A_-_Xn_Management_-_establishment_of_Xn_Gnb
    Start Tshark Packet Capturing
    Unlock Xn Procedure And Wait For Xn Link Available
    Stop Tshark Packet Capturing
    Verify Xn Establishment

5GC000637-I_-_Xn_NG_RAN_Node_Configuration_Update
    [Documentation]
    ...    Verifies that NG-RAN Node Configuration Update procedure can be performed with success.
    [Setup]    [PRE]5GC000637-I_-_Xn_NG_RAN_Node_Configuration_Update
    [Teardown]    [POST]5GC000637-I_-_Xn_NG_RAN_Node_Configuration_Update
    Start Tshark Packet Capturing
    Perform Xn Configuration Update
    Stop Tshark Packet Capturing
    Verify NG RAN Node Configuration Update

*** Keywords ***
Test suite preconditions
    Eth Interfaces
    Commission eNB To SA Mode
    Delta Commissisoning    ${DELTA_ACTIVATE_XN_LINK}

[PRE]5GC000637-A_-_Xn_Management_-_OAM_configuration_of_locked_Xn_Gnb_link
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000637-A_-_Xn_Management_-_OAM_configuration_of_locked_Xn_Gnb_link
    Report miscellaneous KPIs
    Stop WTS

[PRE]5GC000637-A_-_Xn_Management_-_establishment_of_Xn_Gnb
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000637-A_-_Xn_Management_-_establishment_of_Xn_Gnb
    ute_tshark.teardown_tshark
    Report miscellaneous KPIs
    Stop WTS

[PRE]5GC000637-I_-_Xn_NG_RAN_Node_Configuration_Update
    Delta Commissisoning    ${DELTA_LOCK_XN}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir
    Delta Commissisoning    ${DELTA_UNLOCK_XN}
    Verify Xn Link Status Is Available

[POST]5GC000637-I_-_Xn_NG_RAN_Node_Configuration_Update
    ute_tshark.teardown_tshark
    Report miscellaneous KPIs
    Stop WTS

# -- test steps --
Unlock Xn Procedure And Wait For Xn Link Available
    [Tags]    DESIGNSTEP
    Delta Commissisoning    ${DELTA_UNLOCK_XN}
    SLEEP    60s
    ute_admin_infomodel.query_infomodel    //XNLINK_R-1 is [xnLinkStatus=available]    timeout=900

Verify Xn Establishment
    [Tags]    DESIGNSTEP
    ${request}    ute_tshark.get_packets_count
    ...    packet_filter=${XN_ESTABLISHMENT}[XnSetupRequest]
    ${response}    ute_tshark.get_packets_count
    ...    packet_filter=${XN_ESTABLISHMENT}[XnSetupResponse]
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${request}==${1}
    ...    msg=Amount of XnSetupRequest (${request}) is not equal to expected amount (1)
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${response}==${1}
    ...    msg=Amount of XnSetupResponse (${response}) is not equal to expected amount (1)

Trigger Xn Setup Request And Verify Not Configured
    [Tags]    DESIGNSTEP
    #It's required to turn on Xn traces for enb 3
    execute_egate_command_and_wait_for_data
    ...    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=Attempt to SCTP connection
    ...    timeout=30

Verify Xn Link Status Is Unavailable
    [Tags]    DESIGNSTEP
    ute_admin_infomodel.query_infomodel    //XNLINK_R-1 is [xnLinkStatus=unavailable]    timeout=900

Perform Xn Configuration Update
    [Tags]    DESIGNSTEP
    Delta Commissisoning    ${XN_UPDATE}
    #Parameter xnNgRanCfUpNbInfoBackOffTmr needs to be changed to 5 seconds to ensure commands will be visible tshark
    SLEEP    60s    Wait for second NgRanNodeConfigurationUpdate, see: PR632602
    Verify Xn Link Status Is Available

Verify NG RAN Node Configuration Update
    [Tags]    DESIGNSTEP
    ${request}    ute_tshark.get_packets_count
    ...    packet_filter=${RAN_UPDATE}[RANConfigurationUpdateAcknowledge]
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${request}==${2}
    ...    msg=Amount of message (${request}) is not equal to expected (2)

Verify Xn Link Status Is Available
    ute_admin_infomodel.query_infomodel    //XNLINK_R-1 is [xnLinkStatus=available]    timeout=300

Start Tshark Packet Capturing
    [Documentation]    Captures SCTP traffic on eth3 interface
    [Tags]    DESIGNSTEP
    ${nas_tshark_logs}    Prepare Logs Directory Path    tshark/    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    log_dir=${nas_tshark_logs}
    ...    log_name=eth3_sctp.pcap
    ute_tshark.start_capturing    capture_filter=sctp

Stop Tshark Packet Capturing
    [Tags]    DESIGNSTEP
    ute_tshark.stop_capturing

# -- internals --
Eth Interfaces
    Add Eth    ip=10.0.1.101    mask=24    interface=eth3    label=eth3:xn
    Add Eth    ip=10.0.1.102    mask=24    interface=eth3    label=eth3:ng
