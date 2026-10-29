*** Settings ***
Documentation
...   author:        Mateusz Cieciura and Filip Jozefczak
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    filip.jozefczak@nokia.com
...   Description:   Feature CB009059

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/test_specific_keywords_9059.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/test_specific_keywords.py

*** Variables ***
${UE_ALIAS}             DRB_UE
${UE_CAPA}              REAL_UE_SA
${VONR_NUMBER}          +555800903300998
${VC_ALIAS}             VC_1
${PM_INTERVAL}          5


*** Keywords ***
[1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow
	[Documentation]   This test case aims to check the behavior of Nokia gNB in SA mode during Initial Context Setup
	...               establishment and blind SCell Addition with two FR1 CA eligible DRBs, one not FR1 CA eligible DRB
	...               and no FR1 CA incompatible DRB mapped to one PDU Session.
    Start log collection
    Activate feature
    Setup actBufferBasedSCellAddition
    ${drb_dict}          Create Dictionary  NRDRB-13=Not FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Add custom data to PCF    test_4_drb    add78fast
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi7  5qi9
    Perform call on specific 5qis    ${5qis_for_call}
    Wait for next counter interval
    Stop All Data Transfers
    Detach Ue            ${UE_ALIAS}
    Stop log collection
    Verify counters A1 part 1
    Wait for next counter interval
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi8
    Perform call on specific 5qis    ${5qis_for_call}
    Wait for next counter interval
    Stop All Data Transfers
    Detach Ue            ${UE_ALIAS}
    Verify counters A1 part 2


[1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB
    [Documentation]  This test case aims to check the behavior of Nokia gNB in SA mode during PDU Session Modification
    ...              procedure which adds one FR1 CA eligible DRB to already existing FR1 CA incompatible DRB.
    Start log collection
    Activate feature
    Setup actBufferBasedSCellAddition
    ${drb_dict}         Create Dictionary  NRDRB-10=Not FR1 CA eligible  NRDRB-12=Not FR1 CA eligible
    ...                                    NRDRB-13=FR1 CA incompatible
    Setup CellAggrLevel       ${drb_dict}
    Add custom data to PCF    test_4_drb    add8fast
    Attach Ue                 ${UE_ALIAS}
    ${5qis_for_call}    Create List  5qi8  5qi9
    Perform call on specific 5qis    ${5qis_for_call}  2700s
    Add custom data to PCF    test_3_drb    add6fast
    ${5qis_for_call}    Create List  5qi6
    Perform call on specific 5qis    ${5qis_for_call}  2700s
    Wait for next counter interval
    Stop log collection
    test_specific_keywords_9059.Verify counters A3
    Verify logs A3


[1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release
	[Documentation]   This test case aims to check the behavior of Nokia gNB in SA mode during PDU Session Modification
	...               procedure which adds one FR1 CA eligible DRB and releases last DRB which disallows CA.
    [1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB
    Wait for next counter interval
    Add custom data to PCF  test_3_drb  rm8fast
    Wait for next counter interval
    test_specific_keywords_9059.Verify counters A8


[1]CB009059_AB_3_PDU_Session_Modification_last_CA_eligible_DRB_release_CA_release
    [Documentation]   This test case aims to check the behavior of Nokia gNB in SA mode during Initial Context Setup
    ...    	          establishment and blind SCell Addition with two FR1 CA eligible DRBs, one not FR1 CA eligible DRB
    ...               and no FR1 CA incompatible DRB mapped to one PDU Session. All CA eligible DRBs are released.
    [1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow
    ${drb_dict}          Create Dictionary  NRDRB-13=FR1 CA eligible  NRDRB-14=Not FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi7  5qi8  5qi9
    Wait for next counter interval
    Perform call on specific 5qis     ${5qis_for_call}
    Add custom data to PCF  test_3_drb  rm78fast
    Wait for next counter interval
    test_specific_keywords_9059.Verify counters AB3

[1]CB009059_AC_4_Online_DRB_profile_setting_parameter_modification
    [Documentation]    This test case aims to check the behavior of Nokia gNB in SA mode after change of DRB profile
    ...                setting.
    [1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release
    ${drb_dict}          Create Dictionary  NRDRB-13=FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Add custom data to PCF  test_3_drb  add8fast
    Wait for next counter interval
    test_specific_keywords_9059.Verify counters AC4


[1]CB009059_BA_9_DL_buffer_monitoring_for_SCell_Addition_only_FR1_CA_eligible_DRB_blind_SCell_Addition_method_buffer-based_activated
    [Documentation]    This test case aims to check the behavior of Nokia gNB in SA mode during DL buffer monitoring for
    ...                SCell Addition with FR1 CA eligible DRB established for blind SCell Addition method and buffer
    ...                based activated.
    Start log collection
    Activate feature
    Setup actBufferBasedSCellAddition  oneShot_Dl_Fr1
    ${drb_dict}     Create Dictionary  NRDRB-12=FR1 CA incompatible  NRDRB-13=Not FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Add custom data to PCF    test_4_drb    add8fast
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi9
    Wait for next counter interval
    Perform call on specific 5qis  ${5qis_for_call}
    Wait for next counter interval
    Stop All Data Transfers
    Stop log collection
    Verify counters BA9 part 1
    Verify logs BA9                criterion=${True}
    ${5qis_for_call}  Create List   5qi8
    Wait for next counter interval
    Start log collection
    Perform call on specific 5qis   ${5qis_for_call}
    Wait for next counter interval
    Verify counters BA9 part 2
    Verify logs BA9                 criterion=${False}


[1]CB009059_BE_2_Interworking_with_VoNR_Call_setup_after_ICS_one_DRB_FR1_CA_incompatible
    [Documentation]     This test case aims to check the behavior of the gNB during VoNR call setup
    ...                 when CB009059 feature is activated with one FR1 CA incompatible.
    ...                 In this scenario Initial Context Setup is already established.
    Activate feature BE2
    Setup actBufferBasedSCellAddition  disabled
    ${drb_dict}     Create Dictionary  NRDRB-10=Not FR1 CA eligible  NRDRB-15=FR1 CA incompatible
    Setup CellAggrLevel  ${drb_dict}
    attenuation_8238_E3
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}  Create List  5qi9
    Perform call on specific 5qis  ${5qis_for_call}  1200s
    Wait for next counter interval
    Verify counters BE2 part 1
    Start VoNR call
    Wait for next counter interval
    Verify counters BE2 part 2


CB009059_C_2_ICS_and_SCell_Addition_one_FR1_CA_eligible_DRB_no_FR1_CA_incompatible_DRB_UM_RLC_mode_DRB_FR1_CA_eligible
    [Documentation]  This test case aims to check the behavior of the Nokia gNB in SA mode during interaction with flow
    ...              control for UM RLC mode DRBs when at least one FR1 CA eligible DRB is established and at least one
    ...              UM RLC mode non-GBR DRB configured as FR1 CA eligible is established.
    Start log collection
    Activate feature
    Setup actBufferBasedSCellAddition  oneShot_Dl_Fr1
    ${drb_dict}          Create Dictionary  NRDRB-13=RLC_UM
    Setup RlcMode        ${drb_dict}
    Add custom data to PCF    test_4_drb    add8fast
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi8  5qi9
    Perform call on specific 5qis     ${5qis_for_call}
    Wait for next counter interval
    Stop log collection
    Verify counters C2 part 1
    Stop All Data Transfers
    Wait for next counter interval
    ${5qis_for_call}     Create List  5qi8  5qi9
    Perform call on specific 5qis     ${5qis_for_call}  tput_DL_bandwidth=10 Mbits/sec
    Wait for next counter interval
    Verify counters C2 part 2


CB009059_F_2_Interworking_with_PCMD_for_CA_eligible_DRB_release_PDU_Modification
    [Documentation]  This test case aims to check the behavior of Nokia gNB in SA mode during Initial Context Setup
    ...              establishment and blind SCell Addition with two FR1 CA eligible DRBs, one not FR1 CA eligible DRB
    ...              and no FR1 CA incompatible DRB mapped to one PDU Session. All CA eligible DRBs are released with
    ...              PCMD interworking.
    test_specific_keywords_9059.Start IP Traffic Capturing
    Activate feature
    Setup actBufferBasedSCellAddition  disabled
    ${drb_dict}     Create Dictionary  NRDRB-10=Not FR1 CA eligible  NRDRB-14=Not FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Add custom data to PCF    test_4_drb    add78fast
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi7  5qi8  5qi9
    Wait for next counter interval
    Perform call on specific 5qis    ${5qis_for_call}
    Add custom data to PCF    test_3_drb    rm78fast
    BuiltIn.Sleep  10s
    Stop All Data Transfers
    Wait for next counter interval
    test_specific_keywords_9059.Stop IP Traffic Capturing
    Verify logs F2


CB009059_BC_4_Interaction_with_RRC_Resume_procedure_CB008225_SCell_Addition_Method_blind_buffer_based_activated
    [Documentation]  This test case aims to check the behavior of Nokia gNB in SA mode during interaction with RRC
    ...              Resume procedure when the SCell Addition method is blind and buffer based SCell Addition is
    ...              activated.
    Start log collection
    Activate feature
    Setup actBufferBasedSCellAddition  oneShot_Dl_Fr1
    ${drb_dict}     Create Dictionary  NRDRB-10=Not FR1 CA eligible  NRDRB-12=FR1 CA incompatible
    ...                                NRDRB-13=Not FR1 CA eligible
    Setup CellAggrLevel  ${drb_dict}
    Add custom data to PCF    test_4_drb    add5fast
    Attach Ue            ${UE_ALIAS}
    ${5qis_for_call}     Create List  5qi9
    Perform call on specific 5qis    ${5qis_for_call}
    Wait for next counter interval
    test_specific_keywords_9059.Verify counters BC4
    Stop All Data Transfers
    BuiltIn.Sleep   12s
    Perform call on specific 5qis    ${5qis_for_call}
    Wait for next counter interval
    test_specific_keywords_9059.Verify counters BC4
    Stop log collection
    Verify logs BC4
