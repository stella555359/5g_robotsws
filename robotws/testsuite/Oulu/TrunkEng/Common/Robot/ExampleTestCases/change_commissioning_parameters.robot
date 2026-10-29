*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/change_commissioning_parameters.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown


Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}

# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
${WAIT_CHECKS}          30    # seconds, 0 if no waiting nor printing before post conditions check
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure

# First test:
# If just some parameter of commissioning needs change, you can use ${PARAMETER} and ${VALUE_OF_PARAMETER}. First test
# updates just one element as an example.
# NOTE all parameters that are in COMMISSIONING_PARAMETERS dictionary of Third test can be used also in this test.
${PARAMETER}           actCategoryAlarms
# Can have values for example: true or false
${VALUE_OF_PARAMETER}    true

# Second test:
# If you want to update for example two element of same object you can use distName or object for example LNBTS
${OBJECT_TO_CHANGE}      LNBTS
&{MULTIPLE_PARAMETERS}   txPathFailureMode=disableCell
            ...          actBbPooling=true

# Third test:
# This dictionary has elements and new values for elements. Re-commissioning with these values will be done with
# delta file. Note all cells and all bbmods will be updated if cell and bbmod elements are in dictionary for example
# bbCardUsage, dlMimoMode, syncSigTxMode and so on. If no need to update some value, just remove it from the
# dictionary and it will not be updated.
# NOTE productVariantPlanned cannot be updated
&{COMMISSIONING_PARAMETERS}     txPathFailureMode=keepCellInService
                   ...          actBbPooling=false
                   ...          allowBbPoolRecoveryReset=false
                   ...          actCategoryAlarms=true
                   ...          bbCardUsage=2
                   ...          dlMimoMode=SingleTX
                   ...          syncSigTxMode=SingleTx
                   ...          actOtdoa=false
                   ...          actPrsTxDiv=false
                   ...          ulChBw=10 MHz
                   ...          dlChBw=10 MHz

# Fourth test:
# For this variable you can give id of cell
${CELL}                       1
${CELL_PARAMETER}             ulChBw
# Can have values for example: 1.4 MHz, 3 MHz, 5 MHz, 10 MHz, 15 MHz, 20 MHz
${VALUE_OF_CELL_PARAMETER}    10 MHz

# Fifth test:
# For this variable you can give id of BBMOD
${BBMOD}                       1
${BBMOD_PARAMETER}             bbCardUsage
# Can have values for example: 0-2
${VALUE_OF_BBMOD_PARAMETER}    1


*** Test Cases ***
Change actCategoryAlarms Parameter
    [Documentation]  Changes value of actCategoryAlarms to user given value true or false.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${PARAMETER}  ${VALUE_OF_PARAMETER}
        ...    name=Change actCategoryAlarms Parameter
        ...    test_case=1
        ...    loops=1
		...    keywords=Change commissioning parameter
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Change Elements of LNBTS
    [Documentation]  Changes value of txPathFailureMode and actBbPooling to user given values.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${OBJECT_TO_CHANGE}  ${MULTIPLE_PARAMETERS}
        ...    name=Change LNBTS Parameters
        ...    test_case=1
        ...    loops=1
		...    keywords=Change commissioning parameters of object
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Create Deltafile And Perform Re-commissioning
    [Documentation]  Changes value of txPathFailureMode and actBbPooling to user given values.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${COMMISSIONING_PARAMETERS}
        ...    name=Create delta file re-commissioning
        ...    test_case=1
        ...    loops=1
		...    keywords=Do commissioning with delta file
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Change Parameter Of Cell
    [Documentation]  Changes value of ulChBw parameter of one cell.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${CELL_PARAMETER}  ${VALUE_OF_CELL_PARAMETER}  ${CELL}
        ...    name=Change ulChBw Parameter of cell-${CELL}
        ...    test_case=1
        ...    loops=1
		...    keywords=Change Parameter Of Cell Or BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Change Parameter Of BBMOD
    [Documentation]  Changes value of bbCardUsage of one BBMOD.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${BBMOD_PARAMETER}  ${VALUE_OF_BBMOD_PARAMETER}  ${BBMOD}
        ...    name=Change bbCardUsage Parameter of cell-${BBMOD}
        ...    test_case=1
        ...    loops=1
		...    keywords=Change Parameter Of Cell Or BBMOD
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
