
*** Settings ***
Documentation       Just an exemple about how to get the NR Cell Group

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot
Resource            ../Oam.robot

Suite Setup         Suite setup         # listBackupFiles=${FD_ALL}

*** Variables ***
${NB_ITERATION}         2


*** Test Cases ***
Test
    FOR   ${ii}   IN RANGE   0   ${NB_ITERATION}
        Run keyword if                              ${isAic}
        ...                                         My Get NR Cell Group Test Vran
        ...         ELSE                            My Get NR Cell Group Test Classical
    END


*** Keywords ***
My Get NR Cell Group Test Classical
    Dated log New Line                          === Call with no input parameter
    Dated Log                                   ==> Will use the oam=GNB_DU.oam and NRCellId=1
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === Call with oam=GNB_DU.oam and NRCellId=1
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP       oam=${GNB_DU.oam}
    ...                                                                         NRCellId=1
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === Call with oam=GNB_DU.oam and NRCellId=2
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP       oam=${GNB_DU.oam}
    ...                                                                         NRCellId=2
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === Call with oam=GNB_DU.oam and NRCellId=5 : ERROR CASE
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Run keyword and ignore error
    ...                                         Oam.OAM Get NR Cell GROUP       oam=${GNB_DU.oam}
    ...                                                                         NRCellId=5
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

My Get NR Cell Group Test Vran
    Dated log New Line                          === VDU CASE - Call with no input parameter
    Dated Log                                   ==> Will use the oam=GNB_DU.oam and NRCellId=1
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === VDU CASE - Call with oam=GNB_DU.oam and NRCellId=2
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP       oam=${GNB_DU.oam}
    ...                                                                         NRCellId=2
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === VDU CASE - Call with oam=GNB_DU.oam and NRCellId=5 : ERROR CASE
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Run keyword and ignore error
    ...                                         Oam.OAM Get NR Cell GROUP       oam=${GNB_DU.oam}
    ...                                                                         NRCellId=5
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === VCU CASE (not implemented) - Call with no input parameter
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}

    Dated log New Line                          === VCU CASE (not implemented) - Call with oam=GNB_CU.oam and NRCellId=1
    ${nrCellGrp} =                              set variable                    ${None}
    ${nrCellGrp} =                              Oam.OAM Get NR Cell GROUP       oam=${GNB_CU.oam}
    ...                                                                         NRCellId=1
    Dated log                                   =======> nrCellGrp = ${nrCellGrp}
