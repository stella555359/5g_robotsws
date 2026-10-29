*** Settings ***
Documentation
...                  == Purpose ==
...                  Module to test the new service: OAM Get Param From Any Of SCF

Resource            ../Setup.robot
Resource            ../Tools.robot
Resource            ../Oam.robot
#Resource            ../Connect.robot
#Resource            ../SetConfig.robot
#Resource            ../Scf.robot

Suite Setup         Suite setup     keepAllUeDataInCfgFile=${False}  # listBackupFiles=${FD_ALL}


*** Test Cases ***
Test_GetParamFromAnyOfSCF
    [Tags]    DEBUG
    ${dist_name}                    Set variable if                     ${isAic}
    ...                                                                 ${TNRCELL_DIST_NAME_DU[0]}
    ...                                                                 ${TNRCELL_DIST_NAME[0]}

    Dated Log New Line              Test: Get the "actSlowPrbPoolingFddFr1Enh" param value from MRBTS-1/NRBTS-1
    Dated Log                       ==> Response should be : true or false
    ${param_value}                  OAM Get Param From Any Of SCF       param=actSlowPrbPoolingFddFr1Enh
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Dated Log                       actSlowPrbPoolingFddFr1Enh value is : ${param_value}

    Dated Log New Line              Test: Get the "physCellId" param value from NRCELL-1
    Dated Log                       ==> Response should be : 50
    ${param_value}                  OAM Get Param From Any Of SCF       param=physCellId
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=${dist_name}
    Dated Log                       Response is : ${param_value}

    Dated Log New Line              Test: Get the "rightEdgeAngle" param value from NRCELL-1
    Dated Log                       ==> Response should be : 60
    ${param_value}                  OAM Get Param From Any Of SCF       param=rightEdgeAngle
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=${dist_name}
    Dated Log                       Response is : ${param_value}

    Dated Log New Line              Test: Get the "crntiAllocationOption" param value from MRBTS-1/NRBTS-1/NRDU-1
    Dated Log                       ==> Response should be : max72cells
    ${dist_name}                    set variable                        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ${param_value}                  OAM Get Param From Any Of SCF       param=crntiAllocationOption
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=${dist_name}
    Dated Log                       Response is : ${param_value}

    Dated Log New Line              Test: Get the "profileType" param value from MRBTS-1/MNL-1/MNLENT-1/SYNC-1
    Dated Log                       ==> Response should be either RAC (Rinline2) or RAU (ClassicalBts)
    ${dist_name}                    set variable                        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ${param_value}                  OAM Get Param From Any Of SCF       param=profileType
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=${dist_name}
    Dated Log                       Response is : ${param_value}

    Dated Log New Line              Test: Get the "actRuIntelligentSynceAstHoTime" param value from MNL-1/MNLENT-1/SYNC-2
    Dated Log                       please note the short distant name (MNL-1/MNLENT-1/SYNC-2). It should work
    Dated Log                       ==> Response should be : false
    ${dist_name}                    set variable                        MNL-1/MNLENT-1/SYNC-2
    ${param_value}                  OAM Get Param From Any Of SCF       param=actRuIntelligentSynceAstHoTime
    ...                                                                 current_scf=${SCF_SETUP_PATH}
    ...                                                                 dist_name=${dist_name}
    Dated Log                       Response is : ${param_value}
