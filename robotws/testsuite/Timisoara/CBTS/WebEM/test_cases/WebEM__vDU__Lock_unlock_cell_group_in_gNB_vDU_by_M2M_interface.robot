*** Settings ***
Documentation  This suite contains WebEM__vDU__Lock_unlock_cell_group_in_gNB_vDU_by_M2M_interface TC

Resource  ../test_resources/WebEM__vDU__Lock_unlock_cell_group_in_gNB_vDU_by_M2M_interface.robot


*** Test Cases ***
WebEM__vDU__Lock_unlock_cell_group_in_gNB_vDU_by_M2M_interface
    [Setup]  TC Setup
    TC__WebEM__vDU__Lock_unlock_cell_group_in_gNB_vDU_by_M2M_interface
    [Teardown]  TC Teardown
