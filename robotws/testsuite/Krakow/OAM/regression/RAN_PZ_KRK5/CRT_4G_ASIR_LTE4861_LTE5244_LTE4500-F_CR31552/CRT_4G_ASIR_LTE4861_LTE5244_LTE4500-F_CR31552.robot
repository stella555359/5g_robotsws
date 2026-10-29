*** Settings ***
Documentation
...   Test suite for regression testing of CRT_4G_ASIR_LTE4861_LTE5244_LTE4500-F_CR31552
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     ./resources/common_keywords.robot
Variables    ./resources/common_variables.py

Suite Setup        Common Suite Setup With Commissioning     asir_hub=${True}     prefix_tag=noTMO
Suite Teardown     Common Suite Teardown

*** Variables ***
${capabilities}             REAL_UE

*** Test Cases ***
#Turn power on
#    Turn test line on
#    Sleep    900

[1]LTE5244_01_TC1_TC11_cell_activation_B1_FDD_from_BBU_and_B8_1cell_from_RFC
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Add_RFC_cell]
    Verify number of Rfc     number=0
    Verify gNB cells state
    Load delta asir from file     delta_xml_file=asir_B1_B8_BBU_adding_RFC_and_B8_RFC.xml
    Wait for Rfc Cpri link establishment     timeout=300
    Verify number of Rfc     number=1
    BuiltIn.Sleep     120s
    Verify state of Rfc channels     state=enabled
    Verify state of antresource under rfcchannel     state=enabled
    Verify Rfc cells state
    Verify gNB cells state
    @{CellIDs}=      Create List      LNCEL-1    LNCEL-8    RFCCELL-1
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=5%
    [Teardown]    Actions after test

[1]LTE4500-F_RFC-1-1_BBU_reset_B1_1_cell_B3_1_cell_from_BBU_and_LTE_B3_1_cell_from_RFC
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BBU_reset]
    local_resources.Perform Setup Reconfiguration
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    Load delta asir from file     delta_xml_file=remove_rfc.xml
    BuiltIn.Sleep     60s
    Load delta asir from file     delta_xml_file=TMO_asir_B1_B8_BBU_adding_RFC_and_B8_RFC.xml
    BuiltIn.Sleep     60s
    Verify Rfc cells state
    Verify state of Rfc channels     state=enabled
    Verify state of antresource under rfcchannel     state=enabled
    Reset gNB and wait until it is up
    @{ant_ids}=     Get Ids Of Ants For Rfc Hub
    Verify number of antennas     ant_ids=@{ant_ids}     nr_of_antennas=${2}
    FOR     ${ant_id}    IN    @{ant_ids}
        @{ant_list}    create list
        Append To List    ${ant_list}    ${ant_id}
        Verify antennas status     ant_ids=@{ant_list}
    END
    Verify Power Consumption
    Verify hub led status
    Verify antennas led status     ant_ids=@{ant_ids}
    Verify state of Rfc channels     state=enabled
    Verify state of antresource under rfcchannel     state=enabled
    Verify Rfc cells state
    BuiltIn.Sleep     120s     # Wait for Reset alarm to pop up and then cease.
    [Teardown]    Actions after test

[1]LTE4500-F_UC_Decommission_a_RFConverter
    [Setup]    Actions before test
    Verify number of Rfc     number=1
    Verify Rfc cells state     expected_state=operational
    Verify state of Rfc channels     state=enabled
    Verify state of antresource under rfcchannel     state=enabled
    Load delta asir from file     delta_xml_file=remove_rfc.xml
    BuiltIn.Sleep     60s
    Verify number of Rfc     number=0
    [Teardown]    Actions after test

#Turn power off
#    Turn test line off
