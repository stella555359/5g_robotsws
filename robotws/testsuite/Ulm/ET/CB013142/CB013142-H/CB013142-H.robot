*** Settings ***

Documentation
...    author: VRF ULM T04 04
...    Team: 'MN RAN RD VRF ULM 04'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
...    Description: This is a Robot Test Suite for sub-feature CB013142-H
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource                        ../CB013142_Keywords.robot
Resource                        ../CB013142_Commissioning.robot
Resource                        ../CB013142_PM.robot

Suite Setup                     CB013142_Keywords.Prepare TL For CB013142
Suite Teardown                  sqd65_keywords.Sqd65 Common Teardown

Test Setup                      CB013142_Keywords.Perform Preconditions Of Test Scenario
Test Teardown                   CB013142_Keywords.Perform Postconditions Of Test Case

*** Variables ***
@{CA_MSG_SEQ}                   sCellToAddModList
...                             sCellIndex 1
...                             physCellId 50
...                             downlinkConfigCommon
...                             sCellIndex 2
...                             physCellId 54


@{SCELL_SWAP}                   sCellToAddModList
...                             sCellIndex 3
...                             physCellId 51
...                             downlinkConfigCommon
...                             sCellToReleaseList


@{A1_BASED_PCELL_SWITCH_MSG_SEQ}                spCellConfig
...                                             spCellConfigCommon
...                                             physCellId 50
...                                             frequencyInfoDL
...                                             absoluteFrequencySSB 518910
...                                             frequencyInfoUL

*** Test Cases ***

CB013142_H_ET_TC04_B7_SA_Online_modification
    [Documentation]
    ...   Main scenario: This user scenario intends to verify the gNB behavior when feature is activated/deactivated online,
    ...   or parameters introduced by this feature are online modified.
    [Tags]    H_B7
    [Setup]   CB013142_Keywords.Setup For CB013142-H-B7
    Set Test Variable    &{UE_IDs_to_index_mapping}
    ...    4=1
    CB013142_Keywords.Register And Establish PDU Session    ue_id=4  nwslice=2
    CB013142_Keywords.Verify Whether UEs Are Configured With A1 Measurement For SCell Addition   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Initiate Both Uplink And Downlink Data Traffic On UEs   dl_data=20  ul_data=10
    CB013142_Keywords.Send A1 MR For SCell Addition And Verify Whether GNB Configures CA_A6   carrier_freq=${CARRIER_FREQ_4}
    CB013142_Keywords.Send A6 MR For SCell Swap
    CB013142_Keywords.Stop Data transfer And Deregister All UEs
    Sleep    180s
    CB013142_Keywords.Collect And Verify PM Counters   test_instance=H_B7