*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Dariusz Maciocha
...             :contact: dariusz.maciocha@nokia.com

Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     KeywordsCB008717.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup    Run Keywords
...            Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...            AND     Update And Put Iphy Xml        input_filepath=${CURDIR}/config/CB008717_H/iphy_n66_n257_n261_5CC.xml
...            AND     With Gnb Configuration         commissioning=h_ec1_scf_5cells.xml
...            AND     Wait For Environment To Be Ready

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs
Test Setup        With Retry Context    3
...                                 Trigger Site Reset
...                         AND     Wait For Testline Icmp Echo Replies And Ssh Services
...                         AND     Check Radios Availability
...                         AND     With Teardownable
...                                     keyword=Start Default Logging
...                                     teardown=Stop Default Logging
...                         AND     With Simulator Configuration    config=${CURDIR}/config/CB008717_H/8717_n66_n257_n261_5CC.cfg
Test Teardown     Add Scout Scf Id To Test Data

*** Test Cases ***
CB008717_H_EC1_Not_Configure_NR-DC_A4_Measurement_On_Frequency_Which_Is_Not_In_UE_Supported_NR-DC_Band_Combination
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Verify F1AP Messages For H_EC1 Scenario

*** Keywords ***
Verify F1AP Messages For H_EC1 Scenario
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_H_EC1}
    Verify Tcpdump Log      ${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_H_EC1}
    Verify Tcpdump Log      ${F1AP_RRC_RECONFIGURATION_WITH_S_MEASURE_CONFIG}
