*** Settings ***
Documentation
...          Just a test to check the restart of the TL

Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../Oam.robot
Resource                            ../WtsCfgConfig.robot
Library                             taf.sbts.oam.coam.admin            WITH NAME      admin
Library                             taf.transport.ssh                  WITH NAME      ssh

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
...                                                     keepAllUeDataInCfgFile=${True}

*** Test Cases ***
Test Du Restart TL
    Restart TL
    StringTool.printLineWithTitle   title=-

    # essai du code ULM:
    # Test restart TL
    StringTool.printLineWithTitle   title=-
