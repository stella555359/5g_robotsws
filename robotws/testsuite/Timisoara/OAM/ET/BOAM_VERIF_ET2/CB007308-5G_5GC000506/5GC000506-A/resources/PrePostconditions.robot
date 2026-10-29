*** Settings ***
Resource    ../../resources/pretest_posttest.robot
Resource    ../../CommonKeywords/nrbts_states_verification/checkers.robot
Resource    ../../CommonKeywords/custom_commissionings.robot
Library    ../../CommonKeywords/sw_info.py
Resource    specific_keywords.robot
Library     String

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True

*** Keywords ***
506-A Suite Preconditions
    Suite Preconditions
    Configure Rsyslog Service

506-A Suite Preconditions for Common build
    Suite Preconditions
    Configure Rsyslog Service
    admin_cli.perform_parameter_recommissioning
    ...                                  dist_name=${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actApts
    ...                                  value=false
    ...                                  operation=create
    ...                                  skip_parameter_relation_errors=True

#dist_name=MRBTS-111/LNBTS-40/LNCEL-11/SIB-0, parameter=pMaxOwnCell, value=24, operation=update, skip_parameter_relation_errors=True
    Run Keyword And Ignore Error  admin_cli.perform_parameter_recommissioning
    ...                                  dist_name=${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                                  parameter=outputConfiguration1PpsFHS
    ...                                  operation=delete
    ...                                  skip_parameter_relation_errors=true


#   admin_cli.Perform Parameter Recommissioning   dist_name=MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRPMRNL-1    parameter=${parameter_name}
#   ...   value=${interval}   operation=update   skip_parameter_relation_errors=true

506-A Suite Postconditions
    Suite Postconditions

506-A Test Preconditions
    Test Preconditions
    Check NRBTS Configured
    Assure TRBLCADM-1 Object exists
    Configure Rsyslog Service

506-A Test Postconditions
    Disable remote syslog transmission
#    Assert that remote syslog status is disabled
    clear syslogs on server
    Test Postconditions


Perform commissioning with previous scf
    [Arguments]  ${admin_conn}=default
    Perform commissioning with scf   ${OUT_SCF_FILE_PRETEST}   ${admin_conn}
    wait for configured  20min
