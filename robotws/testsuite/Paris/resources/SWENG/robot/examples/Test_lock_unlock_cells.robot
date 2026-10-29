
*** Settings ***
Documentation       Test lock and unlock cells

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot
Resource            ../Oam.robot

Suite Setup         Suite setup         # listBackupFiles=${FD_ALL}

*** Test Cases ***
Test
    My Block Unblock Test


*** Keywords ***
My Block Unblock Test
    ${NbOfLockedCells}  ${NbOfUnlockedCells}=   Oam.OAM Number of Blocked Unblocked Cells
    Dated log                                   =======> Block de la cellule 2
    ${blockResult}=                             Oam.OAM Cell Lock   cell_id=2   state=LOCK
    Dated log                                   =======> blockResult = ${blockResult}
    sleep                                       60
    Dated log                                   =======> Check after 60sec
    ${NbOfLockedCells}  ${NbOfUnlockedCells}=   Oam.OAM Number of Blocked Unblocked Cells
    Dated log                                   =======> UnLock de la cellule 2
    ${unblockResult}=                           Oam.OAM Cell Lock   cell_id=2   state=UNLOCK
    Dated log                                   =======> unblockResult = ${unblockResult}
    sleep                                       60
    Dated log                                   =======> Check after 60sec
    ${NbOfLockedCells}  ${NbOfUnlockedCells}=   Oam.OAM Number of Blocked Unblocked Cells

