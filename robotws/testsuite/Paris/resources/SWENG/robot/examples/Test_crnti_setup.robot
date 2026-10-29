*** Settings ***
Documentation
...                                 == Purpose ==
...                                 Module to test creation of new SWENG service.

Library                             OperatingSystem
Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../CallSetup.robot

Suite Setup                         Suite setup         # listBackupFiles=${FD_ALL}
Suite Teardown                      Suite Teardown


*** Test Cases ***
Test the CRNTI Setup
    WTS Setup                       shouldUseLua=False

    # Attach SA UE:
    CallSetup.UE Register           ue=${BASIC_UE_SA.ue}
    Save Egate Console Log          pattern=AfterUeSaRegister
    sleep                           10s

    # Attach NSA UE:
    SgNB Addition to ENB            ueSetting=${NSA_UE_NO_PROFILE}
    Save Egate Console Log          pattern=AfterUeNsaAttach
    sleep                           10s

    # Detach SA and NSA UEs:
    CallSetup.UE Deregister         id=${BASIC_UE_SA.ue}
    UE Detach Enb                   ueSetting=${NSA_UE_NO_PROFILE}
