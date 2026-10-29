*** Settings ***
Documentation
...   Keywords for regression testing of feature CB012611
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Library     taf.transport.ssh                                  WITH NAME    ssh
Library     taf.sbts.oam.coam.admin                            WITH NAME    admin
Library     taf.rfrl.utilities.logger.custom_logger            WITH NAME    logger
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
@{additional_allowed_alarms} =  Baseband Module Hardware Failure
...                             No X2 link available for a specific LTEENB
...                             No X2 link available
...                             BTS configuration error (not enough HW for LCR)
${prefix_tag_GNB}               CustomerGNB
${prefix_tag_ASIR}              CustomerASIR


*** Keywords ***
Suite Setup
    [Arguments]         ${prefix_tag_GNB}
    ...                 ${prefix_tag_ASIR}
    Perform Full Commissioning On Classical gnb     prefix_tag=${prefix_tag_GNB}      update_timeout=1200
    Perform Full Commissioning on gNB ASIR hub      prefix_tag=${prefix_tag_ASIR}
    Wait until keyword succeeds                     900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Common Suite Setup


Test Setup
    Common Preconditions With Watching Alarms


Test Teardown
    Common Postconditions With Watching Alarms


Suite Teardown
    Common Suite Teardown


Trigger Loki failure
    ssh.connect to          hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                     username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                     password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                     alias=alias_bbmod
    ssh.execute             command=bmutool -s 1 -r 0x10 0xA0    connection=alias_bbmod


Verify ABIO status is degraded
    ${bbmod_data}    Get All BBMOD Status
    ${item}=    Get From List    ${bbmod_data}    0
    ${bbmod_status}=  Get From Dictionary    ${item}    status
    ${availability_status}=    Get From Dictionary    ${bbmod_status}    availabilityStatus
    Should Be Equal    ${availability_status}    degraded


Verify cells on Loki are failed
    Wait Until Keyword Succeeds     120 sec     10 sec     Verify Cell Statuses
    ...    cell_id=27
    ...    availability_status=failed


Verify fault ID 252 is raised with critical severity
    Wait Until Keyword Succeeds     120 sec     10 sec     Verify Alarm is Active on gNB
    ...    fault_id=252
    ...    fault_name=Baseband Module Hardware Failure
    ...    severity=Critical


Trigger Loki recovery
    ssh.connect to          hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                     username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                     password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                     alias=alias_bbmod
    ssh.execute             command=bmutool -s 1 -r 0x1F 1    connection=alias_bbmod


Get All BBMOD Status
    ${connection}    admin.Connect To    bts_host=192.168.255.129
    ${bts_info} =    admin.Get BTS info       connection=${connection}
    ${raw_bbmod_list}  Set Variable  ${bts_info['basebandModules']}
    ${bbmods_list}  Create List
    FOR  ${raw_bbmod_info}  IN  @{raw_bbmod_list}
       Keep In Dictionary  ${raw_bbmod_info}  id  status
       logger.log_info_to_console  ${raw_bbmod_info}
       Append To List  ${bbmods_list}  ${raw_bbmod_info}
    END
    logger.log_info_to_console  All BBMOD Status: ${bbmods_list}
    [Return]  ${bbmods_list}
