*** Settings ***
Documentation       Test Set SCF Element

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot
Resource            ../Oam.robot
Resource            ../Scf.robot

Suite Setup         Suite setup         # listBackupFiles=${FD_ALL}


*** Test Cases ***
Test Scf Set Element
    StringTool.printLineWithTitle   title=SCF Config
    ${DU_CU_SCF_list}               Get All SCF File
    My SCF config                   scf_file=${DU_CU_SCF_list}
    StringTool.printLineWithTitle   title=-

    StringTool.printLineWithTitle   title=Full Commissionning
    OAM Perform Full Commissioning  scf_list=${DU_CU_SCF_list}
    OAM wait available
    StringTool.printLineWithTitle   title=-

*** Keywords ***
My SCF config
    [Arguments]                 ${scf_file}
    Dated Log new line          === Start SCF configuration
    ${DU_SCF}                   Set Variable    ${scf_file}[0]
    ${CU_SCF}                   Set Variable    ${scf_file}[1]
    SCF StartSession            scf_file=${DU_SCF}    second_scf_file=${CU_SCF}

    Dated Log new line          === Case Existing Vcu Param
    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=actInactDetNSAUe
    ...                         element_value=false
    ...                         aicListEntity=vcu
    ...                         scope=Both

    Dated Log new line          === Case Existing Vdu Param
    SCF Set element             dist_name=${NRCELL_DIST_NAME}
    ...                         element_name=actUlCgType2
    ...                         element_value=true
    ...                         aicListEntity=Vdu
    ...                         scope=Classical

    Dated Log new line          === Case Existing VduVcu Param
    SCF Set element             dist_name=${NRCELL_DIST_NAME}
    ...                         element_name=actAperCsi
    ...                         element_value=true
    ...                         aicListEntity=vduVcu
    ...                         scope=both

    Dated Log new line          === Case Non Present Vcu Param (i.e. param in grey on VCU WebEM)
    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=excludedEutranCellPeriod
    ...                         element_value=10
    ...                         aicListEntity=vcu
    ...                         scope=both

    Dated Log new line          === Case Non Present Vdu Param (i.e. param in grey on VDU WebEM)
    SCF Set element             dist_name=${NRCELL_DIST_NAME}
    ...                         element_name=firstRE
    ...                         element_value=0
    ...                         aicListEntity=vdu
    ...                         scope=both

    Dated Log new line          === Case Non Present VduVcu Param (i.e. param in grey on VDU and VCU WebEM)
    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=applyPriorityAccess
    ...                         element_value=none
    ...                         aicListEntity=vduvcu
    ...                         scope=both

    Dated Log new line          === Case Non Existing Vcu Param (bad element_name)
    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=nImporteQuoi
    ...                         element_value=true
    ...                         aicListEntity=vcu
    ...                         scope=both

    Dated Log new line          === Case Non Existing Vdu Param (bad element_name)
    SCF Set element             dist_name=${NRCELL_DIST_NAME}
    ...                         element_name=nImporteQuoi
    ...                         element_value=true
    ...                         aicListEntity=vdu
    ...                         scope=both

    Dated Log new line          === Case Non Existing VduVcu Param (bad element_name)
    SCF Set element             dist_name=${NRCELL_DIST_NAME}
    ...                         element_name=nImporteQuoi
    ...                         element_value=true
    ...                         aicListEntity=vduvcu
    ...                         scope=both

    Dated Log new line              === Case Non Existing Vcu dist_name (bad dist_name)
    run keyword and continue on failure
    ...                         SCF Set element
    ...                                 dist_name=MRBTS-${MRBTS_ID}/NRBTS-255
    ...                                 element_name=actInactDetNSAUe
    ...                                 element_value=true
    ...                                 aicListEntity=vcu
    ...                                 scope=both

    Dated Log new line              === Case Non Existing Vdu dist_name (bad dist_name)
    run keyword and continue on failure
    ...                         SCF Set element
    ...                                 dist_name=${NRCELL_DIST_NAME}-255
    ...                                 element_name=actUlCgType2
    ...                                 element_value=true
    ...                                 aicListEntity=vdu
    ...                                 scope=both

    Dated Log new line              === Case Non Existing VduVcu dist_name (bad dist_name)
    run keyword and continue on failure
    ...                         SCF Set element
    ...                                 dist_name=${NRCELL_DIST_NAME}-255
    ...                                 element_name=actAperCsi
    ...                                 element_value=true
    ...                                 aicListEntity=vduvcu
    ...                                 scope=both

    SCF StopSession             scf_file=${DU_SCF}    second_scf_file=${CU_SCF}


Get All SCF File
    OAM Get SCF Files
    ${TC_file_name}             getFormattedTestName
    ${DU_SCF}                   Set Variable        ${LOG_PATH}/SCF_DU_${TC_file_name}.xml
    ${CU_SCF}                   Set Variable If     ${isAic}
    ...                                             ${LOG_PATH}/SCF_CU_${TC_file_name}.xml    ${EMPTY}

    ${std_output}               Run                 cp ${SCF_SETUP_PATH} ${DU_SCF}
    ${std_output}               Run                 cp ${SCF_CU_SETUP_PATH} ${CU_SCF}
    [Return]                    ${DU_SCF}           ${CU_SCF}

