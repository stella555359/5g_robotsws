*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in gnb.robot for classical deployments.

Library     Collections
Library     taf.sbts.oam.coam.admin             WITH NAME   admin
Library     ../python/CustomizeCollections.py   WITH NAME   data_ops_py

Resource    ../gnb.robot
Resource    ../connect.robot

Test Setup  Setup Log Dir

*** Test Cases ***
Test Reset all gNBs and wait for availability
    [TAGS]              GNB
    Reset All GNBs And Wait For Availability

Test Wait for Node state
    [TAGS]              GNB
    ${oam_alias}    connect.Setup OAM Http Session  node_type=gnb   node_id=0
    Log To Console  \nGet the current state to use it afterwards as expected states
    ${bts_state}      admin.Get Mrbts State       connection=${oam_alias}
    connect.Teardown OAM Http Session  node_type=gnb   node_id=0
    Log To Console  \nExpected state used for KW 'Wait for Node state': ${bts_state}
    Wait For Node State     target_proceduralState=${bts_state}  node_type=gnb  node_id=${0}  timeout=0s
    Log To Console  \nCheck the KW fails if a wrong state is expected
    Run Keyword And Expect Error    *   Wait For Node State
    ...                             proceduralState=notInstalled  timeout=0s

Test Get gNB Physical Cell ID
    [TAGS]              GNB
    ${nr_cells}=    Get GNB Physical Cell ID
    Should Not Be Empty     ${nr_cells}


Test Get distNames from gNB SCF
    [TAGS]              GNB
    ${distnames}=   Get DistNames From GNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Should Not Be Empty     ${distnames}


Test Get distNames from gNB DU
    [TAGS]              GNB
    ${distnames}=   Get DistNames From GNB DU   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Should Not Be Empty     ${distnames}


Test Get distNames from Local SCF File
    [TAGS]              GNB
    ${du_scf}=      gnb.Get SCF From GNB
    ${distnames}=   Get DistNames From Local SCF File  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+  scf_path=${du_scf}
    Should Not Be Empty     ${distnames}


Test Get Current Alarms From Node
    [TAGS]              GNB
    Get Current Alarms From Node    node_type=gnb   node_id=0


Test Check faultId in Node active alarm list
    [TAGS]              GNB
    Check FaultId In Node Active Alarm List    node_type=gnb   node_id=0   expected_fault_number=61524


Test Get Radio Module Cell Mapping
    [TAGS]              GNB
    Run Keyword And Expect Error   'dummy' isn't supported, use NRCEL, LNCEL or GNCEL instead!
    ...   Get Cell Radio Module Mapping   class=dummy
    ${mapping1}   Get Radio Module Cell Mapping
    Should Not Be Empty   ${mapping1}
    ${mapping2}   Get Radio Module Cell Mapping   class=NRCEL
    Should Be Equal   ${mapping1}   ${mapping2}


Test Generate Cells Status Dictionary
    [TAGS]              GNB
    ${oam_alias}     connect.Setup OAM Http Session  node_type=gnb   node_id=0
    ${cells_info}    admin.Get Cells Info    connection=${oam_alias}

    ${cells_state}   Generate Cells Status Dictionary   data_structure=${cells_info}
    FOR    ${key}    IN    @{cells_state.keys()}
        Log To Console   ${\n}${key}: ${cells_state['${key}']['status']['blockingState']}
    END

    ${cells_state}   Generate Cells Status Dictionary   data_structure=${cells_info}   id_type=configuration
    FOR    ${key}    IN    @{cells_state.keys()}
        Log To Console   ${\n}${key}: ${cells_state['${key}']['status']['blockingState']}
    END


Test Sort Collection Naturally With List
    @{original_list}    Create List
    ...   /MRBTS-1/NRBTS-1/NRCELL-1
    ...   /MRBTS-1/NRBTS-1/NRCELL-4
    ...   /MRBTS-1/NRBTS-1/NRCELL-3
    ...   /MRBTS-1/NRBTS-1/NRCELL-12

    Log To Console   ${\n}Original List:
    FOR   ${idx}   ${value}   IN ENUMERATE   @{original_list}
       Log To Console   ${idx}: ${value}
    END

    ${sorted_list}       data_ops_py.Sort Collection Naturally    ${original_list}

    Log To Console   ${\n}Sorted List:
    FOR   ${idx}   ${value}   IN ENUMERATE   @{sorted_list}
       Log To Console   ${idx}: ${value}
    END

    @{expected_list}    Create List
    ...   /MRBTS-1/NRBTS-1/NRCELL-1
    ...   /MRBTS-1/NRBTS-1/NRCELL-3
    ...   /MRBTS-1/NRBTS-1/NRCELL-4
    ...   /MRBTS-1/NRBTS-1/NRCELL-12
    Lists Should Be Equal    ${sorted_list}    ${expected_list}


Test Sort Collection Naturally With Dictionary
    &{original_dict}    Create Dictionary
    ...                 /MRBTS-1/NRBTS-1/NRCELL-1=status_1
    ...                 /MRBTS-1/NRBTS-1/NRCELL-14=status_14
    ...                 /MRBTS-1/NRBTS-1/NRCELL-31=status_31
    ...                 /MRBTS-1/NRBTS-1/NRCELL-2=status_2

    Log To Console       ${\n}Original Dictionary:
    FOR    ${key}    IN    @{original_dict.keys()}
        Log To Console    ${key}: ${original_dict}[${key}]
    END

    ${sorted_dict}       data_ops_py.Sort Collection Naturally    ${original_dict}

    Log To Console       ${\n}Sorted Dictionary:
    FOR    ${key}    IN    @{sorted_dict.keys()}
        Log To Console    ${key}: ${sorted_dict}[${key}]
    END

    # To verify the sorting of keys, we extract the keys and compare them.
    ${sorted_keys}       Get Dictionary Keys    ${sorted_dict}   sort_keys=${False}
    @{expected_keys}     Create List
    ...   /MRBTS-1/NRBTS-1/NRCELL-1
    ...   /MRBTS-1/NRBTS-1/NRCELL-2
    ...   /MRBTS-1/NRBTS-1/NRCELL-14
    ...   /MRBTS-1/NRBTS-1/NRCELL-31
    Lists Should Be Equal    ${sorted_keys}    ${expected_keys}

    # Also verify that the values remained correct
    Should Be Equal    ${sorted_dict}[/MRBTS-1/NRBTS-1/NRCELL-1]    status_1
    Should Be Equal    ${sorted_dict}[/MRBTS-1/NRBTS-1/NRCELL-14]   status_14


Test Sort Collection Naturally With Unsupported Type
    ${string_var}=       Set Variable    "This is a string"
    Run Keyword And Expect Error   TypeError: Unsupported collection type.*
    ...   data_ops_py.Sort Collection Naturally   ${string_var}


*** Keywords ***
Setup Log Dir
    ${target_dir}   testline.Get Test Case Log Directory
    Set Test Variable   ${TARGET_DIR}   ${target_dir}
