*** Settings ***
Documentation
...    The purpose of test suite is to Antenna Line Online Monitoring and RF Diagnostics Tests.
...    Maintainer: patryk.wojcik@nokia.com
...    Team in charge: MN RAN VRF Krk 3

Library             ./CB009556_resources.py
Library             taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME    gnbcell
Library             taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME    gnb_scf
Resource            testsuite/Krakow/resources/SMAwave_kws/DevNJ_UE_keywords.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
@{allowed_alarms}    Ethernet port security is disabled   SSH enabled   R&D Service Port enabled
               ...   Service account root access is enabled   Service account root access is enabled   LMP connectivity detected
               ...   BTS Reset Cause    LMP access via port 443    Diagnostic Check Error    Radio autonomous reset as recovery action
               ...   Setup of X2 connectivity to gNB failed

${address}     ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Start DLUL Data Transfer And Verify Throughput
    [Arguments]    ${ue_index}    ${duration}    ${dl_throughput}
    UE Attach And Start ADB Log    ue_index=${ue_index}
    Start DL Async Process    ${ue_index}    ${dl_throughput}    ${duration}
    Sleep    20s    reason=To stabilize data transfer

Antenna Line Monitoring Test
    Sleep    10s    reason=To stabilize conditions
    Selenium_sbts.start_antenna_line_monitoring
    Log to console    \nStarted antenna line online monitoring
    Sleep    10s    reason=To get results from Antenna Line online monitoring
    Selenium_sbts.Stop Antenna Line Monitoring
    Log to console    \nStopped antenna line online monitoring

Preconditions for CB009556
    Common Preconditions
    Selenium_sbts.enable virtual display
    Selenium_sbts.login         url=https://${address}  username=${username}  password=${password}

Postconditions for CB009556
    [Arguments]    ${Postconditions_ForUE}=${True}
    ${start}    Run Keyword If   ${Postconditions_ForUE}   Postconditions_ForUE
    Common Postconditions
    Selenium_sbts.disable virtual display
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Change parameter qrxlevmin to ${value} on cell-${cell_id}
    Perform Configuration Parameter Recommissioning On gNB
    ...                                         dist_name=MRBTS-{}/LNBTS-{}/LNCEL-${cell_id}/SIB-0
    ...                                         param_name=qrxlevmin
    ...                                         operation=update
    ...                                         param_value=${value}
    ...                                         skip_parameter_relation_errors=${false}
    ...                                         timeout=300
    Wait for cell to be OnAir    cell_id=${cell_id}
