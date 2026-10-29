*** Settings ***
Documentation  This suite contains WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_online_phase TC

Resource  ../test_resources/WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_online_phase.robot


*** Test Cases ***
WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_online_phase
    [Setup]  TC Setup
    TC__WebEM__vDU__Cloud_vDU_Check_Downloaded_SW_for_RMOD_on_passive_partition_in_online_phase
    [Teardown]  TC Teardown
