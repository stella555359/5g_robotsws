*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010564
...   author: Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations           WITH NAME    Cell
Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations               WITH NAME    Du
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup     CBRS Suite Setup
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    CRL Update failure or certificate revoked
...                         SAS Registration Failure
${cert_CA_path}             ${CURDIR}/resources/certs/
${cert_TA_path}             ${CURDIR}/resources/certs/

*** Test Cases ***
[1]CB010564-SR-F_9_CBRS_ecpri_LTE_NR_AWPQZ_ABIO_PreTx_RSSI_Meas_Normal
    Du.Reset Bts
    Wait Until Keyword Succeeds     10 min     15 sec     Cell.Verify All Cells Are onAir
    Du.Verify BTS is onAir

*** Keywords ***
CBRS Suite Setup
    Run Keyword And Ignore Error    Du.Install Certificate    cert_file=${cert_CA_path}/ca-certificate.pem
    ...     cert_type=CBRSAdditionalCa      cert_format=PEM
    Common Suite Setup With OnAir Test Line Preparation
    ...     prefix_tag=CB010564_LTE_NR
    ...     list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     increase_timeout_for_update_sw=${1800}
