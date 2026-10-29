*** Settings ***
Resource    ../gnb.robot
Resource    ../connect.robot
Library     taf.sbts.oam.coam.admin     WITH NAME   admin


*** Test Cases ***
Test Wait for Node state
    [TAGS]              GNB
    ${oam_alias}    connect.Setup OAM Http session  node_type=gnb   node_id=0
    Log To Console  \nGet the current state to use it afterwards as expected states
    ${bts_state}      admin.Get Mrbts State       connection=${oam_alias}
    connect.Teardown OAM Http session  node_type=gnb   node_id=0
    Log To Console  \nExpected state used for KW 'Wait for Node state': ${bts_state}
    Wait for Node state     target_proceduralState=${bts_state}  node_type=gnb  node_id=${0}  timeout=0s
    Log To Console  \nCheck the KW fails if a wrong state is expected
    Run Keyword And Expect Error    *   Wait for Node state
    ...                             proceduralState=notInstalled  timeout=0s

Test Get gNB Physical Cell ID
    [TAGS]              GNB
    ${nr_cells}=    Get gNB Physical Cell ID
    Should Not Be Empty     ${nr_cells}

Test Get distNames from gNB SCF
    [TAGS]              GNB
    ${distnames}=   Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Should Not Be Empty     ${distnames}

Test Get distNames from gNB DU
    [TAGS]              GNB
    ${distnames}=   Get distNames from gNB DU   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Should Not Be Empty     ${distnames}

Test Get distNames from Local SCF File
    [TAGS]              GNB
    ${du_scf}=     gnb.Get SCF from gNB 
    ${distnames}=  Get distNames from Local SCF File  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+  scf_path=${du_scf}
    
Test Get Current Alarms From Node
    [TAGS]              GNB
    Get Current Alarms From Node    node_type=gnb   node_id=0

Test Check faultId in Node active alarm list
    [TAGS]              GNB
    Check faultId in Node active alarm list    node_type=gnb   node_id=0   expected_fault_number=61524
