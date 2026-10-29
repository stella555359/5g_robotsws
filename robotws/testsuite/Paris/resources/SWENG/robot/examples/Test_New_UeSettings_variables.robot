*** Settings ***
Documentation
...                                 == Purpose ==
...                                 Module to test creation of new SWENG service.

Library                             Collections
Library                             BuiltIn
Library                             OperatingSystem
Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../CallSetup.robot
Resource                            ../../python/OsTool.py

# STANDARD case: keep all data in basic.cfg file:
# Suite Setup                         Suite setup         keepAllUeDataInCfgFile=${True}
# EXCEPTION case: purge the basic.cfg file to keep only first item:
Suite Setup                         Suite setup         keepAllUeDataInCfgFile=${False}

Suite Teardown                      Suite Teardown


*** Test Cases ***
New UE Settings Setup

    # display TDD and FDD first NSA UE Id:
    StringTool.printLineWithTitle   title=Display the first NSA UE of all TDD and FDD cells:
    ${ueId}=                        Get First NSA UE Id         techno=TDD      cell_rank=1
    Dated Log                       TDD CELL 1 - First NSA UE Id : ${ueId}
    ${ueId}=                        Get First NSA UE Id         techno=TDD      cell_rank=2
    Dated Log                       TDD CELL 2 - First NSA UE Id : ${ueId}
    ${ueId}=                        Get First NSA UE Id         techno=FDD      cell_rank=1
    Dated Log                       FDD CELL 1 - First NSA UE Id : ${ueId}
    ${ueId}=                        Get First NSA UE Id         techno=FDD      cell_rank=2
    Dated Log                       FDD CELL 2 - First NSA UE Id : ${ueId}

    # Test to check code when LUA file is NOT used (recommended way of work):
    Display UE Settings contents

    # Test to check code when LUA file is used:
    Display UE Settings contents    shouldUseLua=${True}


*** Keywords ***
Display UE Settings contents
    [Arguments]                     ${shouldUseLua}=${False}
    Dated Log New Line              Go with shouldUseLua=${shouldUseLua}

    StringTool.printLineWithTitle   title= WTS Setup in progress...
    WTS Setup                       shouldUseLua=${shouldUseLua}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Display the content of ... BASIC_UE_SA_TDD:
    Dated Log                       >>> BASIC_UE_SA_TDD.ue = ${BASIC_UE_SA_TDD.ue}
    Dated Log                       >>> BASIC_UE_SA_TDD.target_cells = ${BASIC_UE_SA_TDD.target_cells}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Display the content of ... BASIC_UE_SA_FDD:
    Dated Log                       >>> BASIC_UE_SA_FDD.ue = ${BASIC_UE_SA_FDD.ue}
    Dated Log                       >>> BASIC_UE_SA_FDD.target_cells = ${BASIC_UE_SA_FDD.target_cells}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Display the content of ... BASIC_UE_NSA_TDD:
    Dated Log                       >>> BASIC_UE_NSA_TDD.ue = ${BASIC_UE_NSA_TDD.ue}
    Dated Log                       >>> BASIC_UE_NSA_TDD.target_cells = ${BASIC_UE_NSA_TDD.target_cells}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Display the content of ... BASIC_UE_NSA_FDD:
    Dated Log                       >>> BASIC_UE_NSA_FDD.ue = ${BASIC_UE_NSA_FDD.ue}
    Dated Log                       >>> BASIC_UE_NSA_FDD.target_cells = ${BASIC_UE_NSA_FDD.target_cells}
    StringTool.printLineWithTitle   title=-
