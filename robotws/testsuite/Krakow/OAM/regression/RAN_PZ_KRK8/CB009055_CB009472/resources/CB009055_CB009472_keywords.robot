*** Settings ***
Documentation
...    author: Bartosz Odziomek
...    contact: bartosz.odziomek@nokia.com

Library             taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations         WITH NAME   asir
Library             taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_UE_keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables           vars_deltas.py

*** Keywords ***
Make L3call
    Log To Console  ============start to make l3call============
    Reboot UEs  ue_index=1
    sleep  60s
    Log To Console  Make UE Call on on-air cell
    Lock 4G or 5G Frequency  ue_index=1  tech=5G  xfcn=630720  4g_pci_or_5g_scs=1
    UE Attach And Start ADB Log  ue_index=1
    sleep  60s
    Log To Console  ==try DL now===
    Start DL Async Process  1  1500M  200
    Log To Console  ===try UL now===
    Start UL Async Process  1  200M  200
    Calculate and Verify DL Async Tput  1  1500M  20%  200s
    Calculate and Verify UL Async Tput  1  200M  20%  200s
    Postconditions_ForUE
    Log To Console  Make UE Call Done

Test Setup
    Log to console    \n--Test Setup started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common preconditions with watching alarms
    Log to console    \n--Test Setup done--\n
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    Run keyword And Restart gNB On ASIR Timeout    Common postconditions with watching alarms
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    tl_prep.Power On All Pdu Ports
    Log to console    \n--Performing Full Commissioning--\n
    Run Keyword And Restart gNB On ASIR Timeout
    ...    Perform Full Commissioning and Wait for onAir
    ...    prefix_tag=${None}
    ...    asir_hub=${True}
    Wait For cells To Be OnAir
    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Common Suite Teardown
    Run Keyword and ignore error    Postconditions_ForUE
    Log to console    \n--Suite Teardown done--\n


Run Keyword And Restart gNB On ASIR Timeout
    [Arguments]    ${keyword}    &{args}
    FOR    ${_}    IN RANGE    3
        TRY
            Run Keyword    ${keyword}    &{args}
        EXCEPT    .*AsirConnection.*    type=regexp
            Log    \n--AsirConnection exception occured--\n    console=${True}
            Log    \n--${keyword} timed out, restarting gNB--\n    console=${True}
            Reset gNB
            Wait For cells To Be OnAir
        ELSE
            RETURN
        END
    END

Wait for cells to be OnAir
    Log to console    \n--Wait for cells to be OnAir--\n
    gnbcell.Wait For All Cells To Be Onair    timeout=600
    Log to console    \n--Cells are OnAir--\n
