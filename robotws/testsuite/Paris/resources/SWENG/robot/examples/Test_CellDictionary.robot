*** Settings ***
Documentation
...          Tests on the CellDictionary library

Library                             taf.config.scf   WITH NAME      scf
Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../Oam.robot
Resource                            ../WtsCfgConfig.robot

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
...                                                     keepAllUeDataInCfgFile=${True}

*** Test Cases ***
Mon Test

    StringTool.printLineWithTitle   title=Use of "Get Cell Info" KW
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=TDD    cellRank=1     cellParam=nrCellId
    Dated Log                       >>> We get this response: ${response}
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=TDD    cellRank=2     cellParam=cellDepType
    Dated Log                       >>> We get this response: ${response}

    # exemples de cas avec erreur:
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=TDD    cellRank=3     cellParam=physCellId
    Dated Log                       >>> Error Case: The TDD cell of rank 3 does not exist
    Dated Log                       >>> Then we get this response: ${response}
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=TDD    cellRank=2     cellParam=keyBidon
    Dated Log                       >>> Error Case: We asked for a non existing key : keyBidon
    Dated Log                       >>> Then we get this response: ${response}

    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=FDD    cellRank=1     cellParam=nrCellId
    Dated Log                       >>> We get this response: ${response}
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=FDD    cellRank=2     cellParam=cellDepType
    Dated Log                       >>> We get this response: ${response}

    # exemples de cas avec erreur:
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=FDD    cellRank=3     cellParam=physCellId
    Dated Log                       >>> Error Case: The TDD cell of rank 3 does not exist
    Dated Log                       >>> Then we get this response: ${response}
    ${response}                     Run Keyword And Ignore Error    Get Cell Info   cellType=RDD    cellRank=2     cellParam=cellDepType
    Dated Log                       >>> Error Case: We asked for a non existing cellType : RDD
    Dated Log                       >>> Then we get this response: ${response}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Use of "Get First SA UE Id" KW with basic_setup.cfg
    ${response}                     Get First SA UE Id              cell=NRCELL-2
    ...                                                             basic_file=/opt/iphy/latest/basic_setup.cfg
    Dated Log                       In "basic_setup.cfg", the firrst SA UE On NRCell-2 is: ${response}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Use of "Get First SA UE Id" KW with basic_wts_step2.cfg
    ${response}                     Get First SA UE Id              cell=NRCELL-2
    Dated Log                       In ${tl.core.cfg_filename}, the first SA UE On NRCell-2 is: ${response}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Use of "Is Cell a SA cell or Not" KW with good param
    ${response}                     Is Cell a SA cell or Not        cellId=NRCELL-1
    Dated Log                       >>> RDH: Is NRCELL-1 a SA cell? Response is ${response}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Use of "Is Cell a SA cell or Not" KW with bad param
    ${response}                     Run Keyword And Ignore Error    Is Cell a SA cell or Not        cellId=NRCELL-12
    Dated Log                       >>> Error Case: The NRCELL-12 does not exist
    Dated Log                       >>> RDH: Is NRCELL-12 a SA cell? Response is ${response}

    StringTool.printLineWithTitle   title=Use of "WTS Setup" KW with NRCELL-2 LOCKED
    Oam.OAM Cell Lock               cell_id=2   state=LOCK
    WTS Setup                       shouldUseLua=${False}
    ...                             shouldSaveBasicCfg=${True}
    Oam.OAM Cell Lock               cell_id=2   state=UNLOCK
    StringTool.printLineWithTitle   title=-
