*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: SyncE Assisted Holdover

Resource            CommonKeywords.robot


*** Keywords ***
CB006627 Setup
    Log To Console    CB006627 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # If test stops early, restore PTP (done for nothing if test passed)
    # Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}
    # Run Keyword And Continue on failure    Trigger change of synce SSM    ${tl.tl_synce['4G']}    prc

Test Debug Upgrade
    Wait Until Keyword Succeeds    10 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    coam.connect_to    bts_host=${bts_addr}    name=coam_admin

    ${sw_info}=    coam.Get Software Info    connection=coam_admin
    ${active_sw}=    Get From Dictionary    ${sw_info}    Active SW version
    Log To Console    ${active_sw}

    ${is_trunk}=    Contains Substring    ${active_sw}    ENB_9999
    IF    ${is_trunk}
        Log To Console    Rollback is necessary
    ELSE
        Log To Console    Rollback is not necessary
    END

    IF    ${is_trunk}
        coam.Rollback Software    timeout=1200    connection=coam_admin
    END

    coam.teardown    connection=coam_admin

    Wait Until Keyword Succeeds    20 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

Test Benoit
    FOR    ${index}    IN RANGE    300
        Wait Until Keyword Succeeds    10 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

        coam.connect_to    bts_host=${bts_addr}    name=coam_admin
        Run Keyword    coam.update_software    sw_package=${sw_target}    timeout=1800    connection=coam_admin
        coam.teardown    connection=coam_admin

        Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

        ${value}=    COAM Get Value From First Object    ${bts_addr}    SYNCE_R
        ${synce_status}=    Get From Dictionary    ${value}    synceStatus

        Should be Equal    ${synce_status}    OK

        coam.connect_to    bts_host=${bts_addr}    name=coam_admin
        Run Keyword    coam.Rollback Software    timeout=1200    connection=coam_admin
        coam.teardown    connection=coam_admin

        Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

        ${value}=    COAM Get Value From First Object    ${bts_addr}    SYNCE_R
        ${synce_status}=    Get From Dictionary    ${value}    synceStatus

        Should be Equal    ${synce_status}    Disabled
    END

Test RU MTIE
    ${old_value}=    Set Variable    0

    FOR    ${index}    IN RANGE    9999
        TRY
            ${RU_shell}=    Connect to RU with Type
            ...    ${bts_addr}
            ...    toor4nsn
            ...    oZPS0POrRieRtu
            ...    serviceuser
            ...    kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
            ...    AVQL
        EXCEPT
            Log To Console    can't connect to RU
            CONTINUE
        END

        Switch Connection    ${RU_shell}
        ${thor}=    Set Variable    ssh 192.168.101.17
        TRY
            SSHLibrary.Write    text=${thor}
        EXCEPT
            Log To Console    can't connect to Thor
            CONTINUE
        END

        Sleep    10s
        ${banner}=    SSHLibrary.Read

        ${check}=    Set Variable    wc -l /var/volatile/log/hwapi/sync/SyncE_MTIE_measurements.txt

        SSHLibrary.Write    text=${check}
        Sleep    10s
        ${result}=    SSHLibrary.Read

        ${taille}=    Get Length    ${result}
        IF    ${taille} == 0    CONTINUE

        ${first}=    Get Line    ${result}    0
        @{word}=    Split String    ${first}
        ${value}=    Get From List    ${word}    0
        Log To Console    ${value}

        ${isInteger}=    Evaluate    isinstance(${value}, int)
        IF    ${isInteger} == ${False}    CONTINUE

        IF    ${value} == ${old_value}
            COAM get bts snapshot    ${bts_addr}    /home/ute/robot_temporary/robot_output/
        END
        Should Not Be Equal    ${value}    ${old_value}
        ${old_value}=    Set Variable    ${value}

        Sleep    100s
    END
