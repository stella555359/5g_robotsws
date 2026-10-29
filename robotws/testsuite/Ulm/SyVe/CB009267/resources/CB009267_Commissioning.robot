*** Settings ***
Documentation   covers the commissioning for the CB009267 TCs

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.scf             WITH NAME    scf
Library    taf.sbts.oam.coam.admin.interface    WITH NAME    admin

Resource    ../../../resources/Common/commissioning.robot
Resource    testsuite/Ulm/SyVe/CB010636/resources/CB010636_Workbench_KW.robot
Resource    ../../resources/scf_info.robot


*** Keywords ***
Block Adjacent Cells On GNB
    [Documentation]    This keyword is used to block adjacent cells on the gNB and on the same RF module
    ...                to avoid interference or wrong cell attaches
    [Arguments]        ${gnb_id}=${0}   ${adjacentCellsToBeBlocked}=${0}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${adjacent_cell}   Set Variable    ${0}
    FOR  ${adjacent_cell}  IN  @{adjacentCellsToBeBlocked}
        Log to Console   gNB-${gnb_id} with NRBTS ID ${nrbts_id}: adjacent cell NRCELL-${adjacent_cell} is BLOCKED
        admin.block_cell   dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${adjacent_cell}   connection=${oam_alias}
    END

Commission delta gnb_scf
    [Documentation]     Settings for file commissioning and executiong of Delta commissioning
    ...                 Set all gnb variables
    [Arguments]         ${gnb_id}=${0}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory
    Set Suite Variable  ${basic_scf_name_gnb_${gnb_id}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${GNB_SW_BRANCH}/${TL_NAME}/GNB-${gnb_id}/scf.xml
    Set Suite Variable   ${target_scf_name_gnb_${gnb_id}}  ${configSuiteDir}/scf_updated_gnb_${gnb_id}.xml
    Set Suite Variable  ${delta_scf_recommissioning_name_${gnb_id}}
    ...                 ${configSuiteDir}/delta_scf__${gnb_id}.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${gnb_id}}
    ...                 ${configSuiteDir}/revert_delta_scf__${gnb_id}.json

    Log To Console    \Loading delta gnb scf parameters

    IF  'CB009267_TC19' in ${TEST TAGS}
        Commissioning gNB for TC19  gnb_id=${0}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${gnb_id}}
    END
    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}  timeout=900s

Revert gNB Delta Commission
    [Documentation]    Commissioning of gnb for CB009267, create new updated SCF with delta changes.
    ...    Only one file is required for updating gnb with delta changes.
    [Arguments]    ${gnb_id}  ${target_scf_name_gnb}  ${revert_delta_scf_recommissioning_name}

    Log To Console  Start commissioning for gnb

    scf.calculate delta scf
    ...    target_scf_path=${basic_scf_name_gnb_${gnb_id}}
    ...    actual_scf_path=${target_scf_name_gnb}
    ...    delta_scf_path=${revert_delta_scf_recommissioning_name}

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name}


Revert Commission delta gnb_scf
    [Documentation]     Reverting delta file commissioning and executiong Revert commissioning
    [Arguments]    ${gnb_id}=${0}
    Log To Console    \Revert delta commissioning
    IF    'CB009267_TC19' in ${TEST TAGS}
         CB009267_Commissioning.Revert gNB Delta Commission   gnb_id=${0}
         ...   target_scf_name_gnb=${target_scf_name_gnb_${gnb_id}}
         ...   revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${gnb_id}}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}  timeout=900s


Commissioning gNB
   [Arguments]   ${test_name}   ${gnb_id}=0   ${enb_id}=0

   Log To Console  [Info:] Start commissioning for gNB-${gnb_id} and \n testcase ${test_name}
   Run Keyword  Commissioning gNB for ${test_name}   gnb_id=${gnb_id}  enb_id=${enb_id}
   Log To Console  [Info:] Commissioning for gNB-${gnb_id} finished


Commissioning gNB for CB009267-A_TC04_SA_4CC_DL-UL_CA_and_PCell_switch_reestablishment_bufferBased_B4
   [Documentation]    Commissioning of gnb for CB009267-A TC04
    ...               to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...               that means that there can be additional variable or not
    [Arguments]       ${gnb_id}=${0}   ${enb_id}=${0}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL version string for branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    #to overcome the 150 sign limitation
    ${nrbts_id_1}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_1}/NRBTS-${nrbts_id_1}

    #  - START - parameter changes
    @{gnb_params_in_scf}   Create List

    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id_1}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSADU=5min

    #  NRBTS parameters
    ...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    ...  modify:${nrbts_nidd}\$:actInterFreqHoSA=true

    #  source and target p-cells specific part
    ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=40
    ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=75


    # *** TL389 specific part **********
    IF   ${nrbts_id_1} == 403891
        #  NRCELL-X parameters
        FOR    ${nrcell}    IN
        ...     ${PCELL_UE_1_P2S}
        ...     ${S_CELL_UE_1_S2P}

            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2ThresholdhoSsbRsrpSA=60
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchEnabled=rsrp
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=65
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
        END

        #   --- configure Cells with NRHOIF and NRREL objects: ---
        #   NRCELL-X/NRHOIF-Y   NRCELL-X/NRREL-Z parameters
        #   NRHOIF MOs: cell-8 to cell-9 and vice versa are existing, activated with the a2BasedPCellSwitchEnabled=true
        FOR    ${nrcell}   ${nrrel}   IN
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_S2P}
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[0]
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[1]
        ...    ${S_CELL_UE_1_S2P}          ${S_CELL_UE_1_TARGET}
        ...    ${S_CELL_UE_1_S2P}          ${1}
        ...    ${S_CELL_UE_1_S2P}          ${7}

            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}\$:sCellAdditionMethod=covBasedA1
        END

        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
        ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70

        ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRHOIF-${S_CELL_UE_1_S2P}\$:a2BasedPCellSwitchEnabled=true
        ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRHOIF-${PCELL_UE_1_P2S}\$:a2BasedPCellSwitchEnabled=true

        #   For cell-9 the MO NRREL-8 to cell-8 has to be activated, all other NRRELs are already active on TL389
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-${PCELL_UE_1_P2S}:sCellAdditionMethod=covBasedA1
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-${PCELL_UE_1_P2S}:sCellOperationalMode=dlAndUl

        #  Deactivate not used NRRELs by deleting the scellAdditionMethod and scellOperationalMode
        ...  delete:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-1:sCellAdditionMethod
        ...  delete:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-1:sCellOperationalMode
        ...  delete:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-7:sCellAdditionMethod
        ...  delete:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}/NRREL-7:sCellOperationalMode

    # *** TL126 - TL387 specific part **********
    ELSE IF   ${nrbts_id} in [401261,403871]
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}

        #  NRCELL-X
        ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
        ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
        # UL CA configuration
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:increasePUSCHPrepTimeULCA=true

        # A1 measurement configration target pcell ${S_CELL_UE_1_S2P}
        ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70
        ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddEnabled=rsrp
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddSsbRsrp
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
        ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

        # A2 measurement configration target pcell ${S_CELL_UE_1_S2P}
        FOR    ${nrcell}    IN
        ...     ${PCELL_UE_1_P2S}
        ...     ${S_CELL_UE_1_S2P}

            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:a2MeasPCellSwitchEnabled=rsrp
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:{"a2HysteresisPCellSwitchSsbRsrp":"0"}
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=65
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
        END

        #   NRCELL-X/NRHOIF-Y   NRCELL-X/NRREL-Z parameters activate a2based pcell switch
        FOR    ${nrcell}   ${nrhoif_targetcell}   IN
        ...    ${PCELL_UE_1_P2S}           ${NRHOIF_S2PCELL_ID}
        ...    ${S_CELL_UE_1_S2P}          ${NRHOIF_P2SCELL_ID}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}/NRHOIF-${nrhoif_targetcell}\$:a2BasedPCellSwitchEnabled=true
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRHOIF-${nrhoif_targetcell}:a2BasedPCellSwitchPriority=2
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRHOIF-${nrhoif_targetcell}:thresholdPCellSwitchTargetRsrp=1
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRHOIF-${nrhoif_targetcell}:thresholdPCellSwitchTargetRsrq=1
        END

        #  NRCELL-X/NRREL-Y for scells with DL AND UL
        FOR    ${nrcell}   ${nrrel}   IN
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_S2P}
        ...    ${S_CELL_UE_1_S2P}          ${PCELL_UE_1_P2S}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellOperationalMode=dlAndUl
        END

        #  NRCELL-X/NRREL-Y for scells with ONLY DL
        FOR    ${nrcell}   ${nrrel}   IN
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[0]
        ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[1]
        ...    ${S_CELL_UE_1_S2P}          ${S_CELL_UE_1_TARGET}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
            ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellOperationalMode=dlOnly
        END
    ELSE
        Fail    No commissioning defind for gNB with NRBTS ID ${nrbts_id}
    END

    #  - END - parameter changes

    scf.perform_scf_modification    modification_strings=${gnb_params_in_scf}
    scf.save_scf  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file_has_content}=  Run Keyword And Return Status  File Should Not Be Empty  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
    IF  ${delta_file_has_content}
         admin.Perform_Delta_Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
         ...                                    skip_parameter_relation_errors=${True}
         ...                                    connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   node_type=gnb   node_id=${gnb_id}
    ...   retry_interval=10s
    ...   cell_types=${{ ['nr'] }}


Commissioning gNB for CB009267-A_TC05_SA_4CC_DL-UL_CA_Scell_release_inact_badRLQ_B201
    [Documentation]    Commissioning of gnb for CB009267 TC05
    ...                to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...                that means that there can be additional variable or not
    [Arguments]        ${gnb_id}=${0}   &{_}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL version string for branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    Set Test Variable  ${TC_NUMBER}  A05

    #to overcome the 150 sign limitation
    ${nrbts_id_1}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_1}/NRBTS-${nrbts_id_1}

    #  START - parameter changes
    @{GNB_PARAMS_IN_SCF}   Create List

    #  NRBTS parameters
    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id_1}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSADU=5min

    ...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    # sCellDeactivationBadRlqCount default is 0 (no scell deactivate will be triggered -> set to 5)
    ...  modify:${nrbts_nidd}\$:sCellDeactivationBadRlqCount=5
    ...  modify:${nrbts_nidd}\$:actSCellReleaseBadSCellRlq=enabled_Fr1
    ...  modify:${nrbts_nidd}\$:actSCellReleaseForInactiveSCell=timer_based_Fr1
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased

    #  NRCELL-X/NRREL-Y parameters

    #  NRCELL-X parameters
    #  --- configure source Cell parameters: ---
    FOR    ${nrcell}    IN
    ...     ${PCELL_UE_1_P2S}
    ...     ${S_CELL_UE_1_S2P}
    ...     ${S_CELL_UE_1_SOURCE}[0]
    ...     ${S_CELL_UE_1_SOURCE}[1]
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellDeactivationTimerGNB=ms1280
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellInactivityReleaseTimer=10
    END

    Collections.Append To List  ${GNB_PARAMS_IN_SCF}
    #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_S2P}:sCellPrio=4
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_SOURCE}[1]:sCellPrio=8
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_SOURCE}[0]:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_SOURCE}[0]:sCellOperationalMode=dlAndUl

    FOR    ${nrcell}   ${nrrel}   IN
    ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_S2P}
    ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[1]
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellOperationalMode=dlOnly
    END

    #  END - parameter changes

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file_has_content}=  Run Keyword And Return Status  File Should Not Be Empty  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
    IF  ${delta_file_has_content}
         admin.Perform_Delta_Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
         ...                                    skip_parameter_relation_errors=${True}
         ...                                    connection=${oam_alias}
    END

    admin.teardown   connection=${oam_alias}


Commissioning gNB for CB009267-B_TC11_NSA_2CC_DL_CA_Scell_release_inact_badRLQ_B201
   [Documentation]    Commissioning of gnb for CB009267 TC11
    ...               to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...               that means that there can be additional variable or not
    [Arguments]       ${gnb_id}=${0}   ${enb_id}=${0}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL version string for branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    #to overcome the 150 sign limitation
    ${nrbts_id_1}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_1}/NRBTS-${nrbts_id_1}

    #  START - parameter changes
    @{gnb_params_in_scf}   Create List

    #  NRBTS parameters
    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id_1}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min

    ...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    # sCellDeactivationBadRlqCount default is 0 (no scell deactivate will be triggered -> set to 3)
    ...  modify:${nrbts_nidd}\$:sCellDeactivationBadRlqCount=5
    ...  modify:${nrbts_nidd}\$:actSCellReleaseBadSCellRlq=enabled_Fr1
    ...  modify:${nrbts_nidd}\$:actSCellReleaseForInactiveSCell=timer_based_Fr1
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  modify:${nrbts_nidd}\$:sCellDeactivationBadRlqCount=10

    # sCellActivationMethod=blind is default on TL389, but not on CCRT2.0 TLs
    # also for all other NRRELs the sCellActivationMethod=blind has to be configured!
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=blind
    ...  modify:${nrbts_nidd}\$:actOverheatingAssistance=false

    ...  modify:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}\$:sCellInactivityReleaseTimer=10

    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}/NRREL-${SCELL_UE_1}:sCellAdditionMethod=blind
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}/NRREL-${SCELL_UE_1}:sCellOperationalMode=dlOnly

    FOR    ${nrcell}    IN RANGE    1    13
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellDeactivationTimerGNB=infinity
    END

    #  END - parameter changes

    scf.perform_scf_modification    modification_strings=${gnb_params_in_scf}
    scf.save_scf  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file_has_content}=  Run Keyword And Return Status  File Should Not Be Empty  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
    IF  ${delta_file_has_content}
         admin.Perform_Delta_Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
         ...                                    skip_parameter_relation_errors=${True}
         ...                                    connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   node_type=gnb   node_id=${gnb_id}
    ...   retry_interval=10s
    ...   cell_types=${{ ['nr'] }}


Commissioning gNB for TC19
    [Documentation]
    ...    |    Commissioning of gNB    |
    [Arguments]        ${gnb_id}  ${target_scf_name_gnb}  ${delta_scf_recommissioning_name}

    ${configSuiteDir}=    testline.Get Test Suite Config Directory

    scf_info.Set MNL version string for branch    basic_scf_name=${basic_scf_name_gnb_${gnb_id}}

    Log To Console  Start commissioning for gnb
    scf.load_scf  file_path=${basic_scf_name_gnb_${gnb_id}}

    #to overcome the 150 sign limitation
    ${nrbts_id}=   Set Variable    MRBTS-${NRBTS_ID_${gnb_id}}/NRBTS-${NRBTS_ID_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   create list
        ...  modify:${nrbts_id}\$:actA2SgnbRelease=false
        ...  modify:${nrbts_id}\$:actInterFreqHoSA=true
        ...  modify:${nrbts_id}\$:sCellActivationMethod=bufferBased
        ...  modify:${nrbts_id}\$:sCellDeactivationBadRlqCount=0
        ...  modify:${nrbts_id}/NRCELL-8\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=75
        ...  modify:${nrbts_id}/NRCELL-8\$:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=40
        ...  modify:${nrbts_id}/NRCELL-8\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
        ...  modify:${nrbts_id}/NRCELL-8\$:ifhoSsbSmtcOffset=0
        ...  modify:${nrbts_id}/NRCELL-8\$:measGapSelectionSA=favourUeThroughput
        ...  add:${nrbts_id}/NRCELL-8:mgta=ms0dot5

        ...  add:[com.nokia.srbts.nrbts:NRHOIF, ${nrbts_id}/NRCELL-8/NRHOIF-2, MNL${version}, create]
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a1BasedPCellSwitchEnabled=false
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a2BasedPCellSwitchEnabled=false
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a3MeasEnabled=rsrp
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a4MeasEnDcSteeringEnabled=none
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a4MeasHigherPrioFreqEnabled=none
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a4MeasNrDcEnabled=none
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a4MeasSCellAddEnabled=none
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasEnabled=rsrp
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:cellDepType=SA+NSA
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:freqBandIndicatorNR=25
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:ifhoSsbScs=15KHz
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:ifhoSsbSmtcDuration=sf5
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:ssBurstSetPeriod=20
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:ssbFrequency=396970
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a3MeasSsbRsrp
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a3MeasSsbRsrp:{"a3HysteresisSsbRsrp":"0"}
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasSsbRsrp
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasSsbRsrp:{"a5HysteresisSsbRsrp":"0"}
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=60
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=70
        ...  add:${nrbts_id}/NRCELL-8/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms80

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${target_scf_name_gnb}

    # create delta to check if modify_scf_element or perform_scf_modification worked correct by glance at generated delta
    # Node: for deleting sCellAdditionMethod "calculate delta scf" creates an 'update' with empty value. 'update' with
    # empty value does also remove the parameter. But correction alredy done in taf. Next taf version
    # creates the expected 'delete'
    scf.calculate delta scf
    ...  target_scf_path=${target_scf_name_gnb}
    ...  actual_scf_path=${basic_scf_name_gnb_${gnb_id}}
    ...  delta_scf_path=${delta_scf_recommissioning_name}

    # if you want to do a delta_recommissioning instead of full commissioning following may work for you:
    # when built up the scf.xml file for the testcase, get current scf file, calculate delta scf and do a delta commissioning.
    # if no reboot is needed, delta_recommissioning is faster.

    syve_commissioning.Execute Recommissioning With Delta SCF File
    ...  node_type=gnb  node_id=${gnb_id}  delta_scf_recommissioning_name=${delta_scf_recommissioning_name}


Commissioning gNB for CB009267-C_TC19_SA_4CC_DL-UL_CA_check_SCell_suspension_and _recovery_meas_gap_bufferBased_B201
    [Documentation]
    ...    |    Commissioning of gNB    |
    [Arguments]        ${gnb_id}=${0}   &{_}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml


    #to overcome the 150 sign limitation
    ${nrbts_id_1}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_1}/NRBTS-${nrbts_id_1}

    #  START - parameter changes
    @{gnb_params_in_scf}   Create List

    #  NRBTS parameters
    ...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    ...  modify:MRBTS-${nrbts_id_1}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrHighRlcCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrLowRlcReport=5min

    ...  modify:${nrbts_nidd}\$:actA2SgnbRelease=false
    ...  modify:${nrbts_nidd}\$:actInterFreqHoSA=true
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    ...  modify:${nrbts_nidd}\$:sCellDeactivationBadRlqCount=0

    #  NRCELL-X changes for primary cell in SA call {PCELL_UE_1_P2S},
    ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=75
    ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=40
    ...  modify:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}\$:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}:ifhoSsbSmtcOffset=0
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}:measGapSelectionSA=favourUeThroughput
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}:mgta=ms0dot5

    ...  add:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_S2P}:increasePUSCHPrepTimeULCA=true

   ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_S2P}:sCellPrio=2
   ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_SOURCE}[0]:sCellPrio=4
   ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_SOURCE}[1]:sCellPrio=6

   ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_SOURCE}[0]\$:csiReportPeriodicity=slots320
   ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_SOURCE}[0]\$:timingAdvanceOffset=n39936

   ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_SOURCE}[1]\$:csiReportPeriodicity=slots320
   ...  modify:${nrbts_nidd}/NRCELL-${S_CELL_UE_1_SOURCE}[1]\$:timingAdvanceOffset=n39936

    #  NRCELL-X/NRREL-Y parameters
    #  Cell-10 has DL+UL CA,   Cell-8 (or 7) and Cell-4 have only DL-CA
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_S2P}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${PCELL_UE_1_P2S}/NRREL-${S_CELL_UE_1_S2P}:sCellOperationalMode=dlAndUl

    Log To Console    scells in TC are  ${S_CELL_UE_1_S2P}, ${S_CELL_UE_1_SOURCE}[0] and ${S_CELL_UE_1_SOURCE}[1]
    FOR    ${nrcell}   ${nrrel}   IN
    ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[0]
    ...    ${PCELL_UE_1_P2S}           ${S_CELL_UE_1_SOURCE}[1]

        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellAdditionMethod=covBasedA1
        ...  add:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}:sCellOperationalMode=dlOnly
    END

    FOR    ${nrcell}    IN RANGE    1    14
        Collections.Append To List  ${GNB_PARAMS_IN_SCF}
        ...  modify:${nrbts_nidd}/NRCELL-${nrcell}\$:sCellDeactivationTimerGNB=infinity
    END

    #  END - parameter changes

    scf.Perform SCF Modification    modification_strings=${gnb_params_in_scf}
    scf.Save SCF                    ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file_has_content}=  Run Keyword And Return Status  File Should Not Be Empty  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
    IF  ${delta_file_has_content}
         admin.Perform Delta Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
         ...                                    skip_parameter_relation_errors=${True}
         ...                                    connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   node_type=gnb   node_id=${gnb_id}
    ...   retry_interval=10s
    ...   cell_types=${{ ['nr'] }}


####################################################################################################################################
# Commissioning for CNI-126924 of feature CB010636 testcase in this file because 9267_keywords are used
# changed from Commissioning gNB for CB010636-A_TC04_TMOUS_NSA_2CC_DL_CA_check_CA_RLC_PDU_bufferBased_config_A202 to
Commissioning gNB for CB010636-A_TC04_NSA_2CC_DL_CA_check_CA_RLC_PDU_bufferBased_config_A202
   [Documentation]    Commissioning of gnb for CB010636-A_TC04_TMOUS
    ...               to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...               that means that there can be additional variable or not
    [Arguments]       ${gnb_id}=${0}   ${enb_id}=${0}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL version string for branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.load_scf  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    #to overcome the 150 sign limitation
    ${nrbts_id_1}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id_1}/NRBTS-${nrbts_id_1}

    #  START - parameter changes
    @{gnb_params_in_scf}   Create List

    #  NRBTS parameters
    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id_1}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrHighRlcCell=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min

    ...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    ...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    ...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased

    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}/NRREL-${SCELL_UE_1}:sCellAdditionMethod=covBasedA1
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}/NRREL-${SCELL_UE_1}:sCellOperationalMode=dlOnly

    # A1 measurement configuration in spcell ${S_PCELL_UE_1} for addition of TDD scell
    ...  modify:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddEnabled=rsrp
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddSsbRsrp
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddSsbRsrp:{"a1HysteresisSCellAddSsbRsrp":"0"}
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70
    ...  add:${nrbts_nidd}/NRCELL-${S_PCELL_UE_1}:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms

    #  END - parameter changes

    scf.Perform SCF Modification    modification_strings=${gnb_params_in_scf}
    scf.Save SCF                    ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file_has_content}=  Run Keyword And Return Status  File Should Not Be Empty  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
    IF  ${delta_file_has_content}
         admin.Perform Delta Recommissioning    delta_file=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml
         ...                                    skip_parameter_relation_errors=${True}
         ...                                    connection=${oam_alias}
    END

    gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   node_type=gnb   node_id=${gnb_id}
    ...   retry_interval=10s
    ...   cell_types=${{ ['nr'] }}


####################################################################################################################################
#  NRBTS.sCellActivationMethod
Modify sCellActivationMethod with Delta Recommissioning
    [Documentation]
    ...    | Modify sCellActivationMethod to the needed value bufferBased or blind  |
    ...    | Secondary cells Activation Method MRBTS-403891/NRBTS-403891  |
    [Arguments]    ${gnb_id}=${0}    ${sCellActivationMethod_Value}=bufferBased
    Log To Console    ${\n}Online Modification of sCellActivationMethod to ${sCellActivationMethod_Value}...

    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+    gnb_id=${gnb_id}
    ${bts_distName}=    Collections.Get From List    ${bts_distNames}    ${0}

    ${resultTestDir}=    testline.Get Testcase Log Directory

    admin.Create delta    sCellActivationMethod_Modification    #the keyword is a must to initiate the commissioning object
    admin.Append managed object to delta    ${bts_distName}    operation=update    delta_id=sCellActivationMethod_Modification
    admin.Append parameter update to delta
    ...    dist_name=${bts_distName}
    ...    parameter=sCellActivationMethod
    ...    value=${sCellActivationMethod_Value}
    ...    delta_id=sCellActivationMethod_Modification

    admin.Get delta    sCellActivationMethod_Modification
    admin.Save delta    ${resultTestDir}/gNB${gnb_id}_delta_scf_file_sCellActivationMethod_${sCellActivationMethod_Value}.json
    ...    sCellActivationMethod_Modification

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    admin.Perform delta recommissioning
    ...    delta_file=${resultTestDir}/gNB${gnb_id}_delta_scf_file_sCellActivationMethod_${sCellActivationMethod_Value}.json
    ...    connection=${oam_alias}


Modify sCellDeactivationTimerGNB with Delta Recommissioning
    [Documentation]
    ...    | Modify the Secondary cell deactivation timer gNB to the needed value infinity or ms1280  |
    ...    | MRBTS-403891/NRBTS-403891/NRCELL-1    sCellDeactivationTimerGNB  |
    [Arguments]    ${gnb_id}=${0}    ${nrcell_id}=${1}    ${sCellDeactivationTimerGNB_Value}=infinity
    Log To Console    ${\n}Online Modification of sCellDeactivationTimerGNB to ${sCellDeactivationTimerGNB_Value}...

    ${NRCELL_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+    gnb_id=${gnb_id}
    Log To Console    ${\n}NRCELLs_distNames: ${NRCELL_distNames}
    ${NRCELL_distName}=    Collections.Get Matches    ${NRCELL_distNames}    *NRCELL-${nrcell_id}
    Log To Console    ${\n}NRCELL_toUse_distName: ${NRCELL_distName}

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    Admin.Perform Parameter Recommissioning
    ...    dist_name=${NRCELL_distName}[0]    # ${NRCELL_distName} is a list... [0] will convert it to a string. (it is already the correct cells.)
    ...    parameter=sCellDeactivationTimerGNB
    ...    operation=update
    ...    value=${sCellDeactivationTimerGNB_Value}
    ...    connection=${oam_alias}


Modify sCellDeactivationTimerGNB with taf.config.scf
    [Documentation]
    ...    |    Modify sCellDeactivationTimerGNB    |
    [Arguments]        ${gnb_id}=${0}    ${nrcell_id}=${1}    ${sCellDeactivationTimerGNB_Value}=infinity
    ${configSuiteDir}=    testline.Get Test Suite Config Directory

    ${actual_scf_path}=    scf_info.Collect the Current SCF file
    scf_info.Set MNL version string for branch    basic_scf_name=${actual_scf_path}

    Log To Console  Start commissioning for gNB(${gnb_id}) under NRCELL-${nrcell_id} sCellDeactivationTimerGNB=${sCellDeactivationTimerGNB_Value}

    scf.load_scf  file_path=${actual_scf_path}

    Set all Suite Variables
    ${nrbts_id}=   Set Variable    MRBTS-${NRBTS_ID_${gnb_id}}/NRBTS-${NRBTS_ID_${gnb_id}}

    @{GNB_PARAMS_IN_SCF}   Create List
    ...    modify:${nrbts_id}/NRCELL-${nrcell_id}\$:sCellDeactivationTimerGNB=${sCellDeactivationTimerGNB_Value}

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${gnb_id}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_mod.xml
    ...  actual_scf_path=${actual_scf_path}
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${gnb_id}
    ${delta_file2}=  get file  ${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml
    IF   ${delta_file2} != []
        admin.Perform_Delta_Recommissioning
        ...    delta_file=${configSuiteDir}/SCFC_gNB${gnb_id}_DU_delta.xml
        ...    skip_parameter_relation_errors=${True}
        ...    connection=${oam_alias}
    END

    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    timeout=60
