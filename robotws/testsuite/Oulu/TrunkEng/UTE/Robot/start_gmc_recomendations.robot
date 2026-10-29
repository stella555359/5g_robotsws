*** Settings ***

Documentation
...   Author:   Marko Niemelä
...   Contact:  I_MN_RAN_TRUNK_UTE_OULU2

Library     Collections
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger  WITH NAME  LOG
Library     testsuite.Oulu.TrunkEng.UTE.Python.GmcRecomendations   WITH NAME   GMC



*** Test Cases ***
Start Collecting Gmc Recomendation
    [Documentation]    Starts Collecting GMC-Recomendations
    Run Keyword and Continue On Failure  GMC.Collect GMC logs
