*** Settings ***
Documentation   covers the commissioning for the CB010559 TCs on 2 gNBs

# -----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.scf             WITH NAME    scf
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../resources/Common/commissioning.robot
Resource    ../resources/scf_info.robot


*** Keywords ***
Block Adjacent Cells On GNB
    [Documentation]    This keyword is used to block adjacent cells on the gNB and on the same RF module
    ...                to avoid interference or wrong cell attaches
    [Arguments]        ${gnb_id}=${0}   ${adjacentCellsToBeBlocked}=${0}
    ${oam_alias}=   connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ${nrbts_id}        scf_info.Get NRBTS-Id  ${gnb_id}
    ${adjacent_cell}   Set Variable    ${0}
    FOR  ${adjacent_cell}  IN  @{adjacentCellsToBeBlocked}
        Log To Console   gNB-${gnb_id} with NRBTS ID ${nrbts_id}: adjacent cell NRCELL-${adjacent_cell} is BLOCKED
        admin.Block Cell   dist_name=MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${adjacent_cell}   connection=${oam_alias}
    END


Commissioning GNB
   [Arguments]   ${test_name}   ${gnb_id}=0   ${enb_id}=0

   Log To Console  [Info:] ==> START commissioning for gNB-${gnb_id} and \n testcase ${test_name}
   Run Keyword  Commissioning GNB For ${test_name}   gnb_id=${gnb_id}  enb_id=${enb_id}
   Log To Console  [Info:] ==> Commissioning for gNB-${gnb_id} FINISHED


Commissioning GNB For CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
    [Documentation]   Commissioning of gnb for CCB010559_A_RE_TC01_B1
    ...               the purpose of test case is to verify the successful RRC RRE to an unprepared gNB with the
    ...               parameter in both gNBs: actRrcRREUnprepgNB is set to intergNB
    ...               to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...               that means that there can be additional variable or not
    [Arguments]       ${gnb_id}=${0}   ${enb_id}=${0}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.Load SCF  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    # to overcome the 150 sign limitation
    ${nrbts_id}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id}/NRBTS-${nrbts_id}

    #  - START SCF parameter changes
    @{gnb_params_in_scf}   Create List

    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    #  for test of feature CB010559
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRRCC=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRRCD=5min
    #  for other features
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSADU=5min

    #  NRBTS parameters
    #...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    #...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    #...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    #...  modify:${nrbts_nidd}\$:actInterFreqHoSA=true
    ...  modify:${nrbts_nidd}\$:actRrcRREUnprepgNB=intergNB

    #  - END - parameter changes

    scf.Perform SCF Modification    modification_strings=${gnb_params_in_scf}
    scf.Save SCF  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM HTTP Session   node_id=${gnb_id}
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


Commissioning GNB For CB010559_A_RE_TC06_EC5_ALT2_Fallback_RRC_Setup_XnAP_RetrieveUeContextFailure
   [Documentation]    Commissioning of gnb for CB010559_A_RE_TC06_EC5_ALT2
    ...     the purpose of test case is to verify the failure and fallback case of a RRC RRE to an unprepared gNB,
    ...     because the parameter in the NRCELL-X/NRREL-Y objects of both gNBs:
    ...     handoverAllowedSA is set to the value XnHoNotAllowed
    ...     to overcome linter warning in case of unused variables, variable "enb_id=${enb_id}" was exchanged with "&{_}"
    ...     that means that there can be additional variable or not
    [Arguments]       ${gnb_id}=${0}   ${enb_id}=${0}

    Log To Console  Start commissioning for gNB-${gnb_id}
    ${configDir}=    testline.Get Testcase Log Directory
    Log To Console  SCF files are stored in the config Dir, get testcase log directory  ${configDir}
    scf_info.Set MNL Version String For Branch    basic_scf_name=${configDir}/SCFC_gNB${gnb_id}_DU.xml
    scf.Load SCF  file_path=${configDir}/SCFC_gNB${gnb_id}_DU.xml

    # to overcome the 150 sign limitation
    ${nrbts_id}    scf_info.Get NRBTS-Id  ${gnb_id}
    ${nrbts_nidd}=   Set Variable    MRBTS-${nrbts_id}/NRBTS-${nrbts_id}

    #  - START SCF parameter changes
    @{gnb_params_in_scf}   Create List

#   ********** START **********
#   *** template for this TC is taken from testcase CB009267-A_TC04_SA_4CC_DL-UL_CA_and_PCell_switch_reestablishment_bufferBased_B4
#   ***************************
    #  ensure PMcounter reporting period is 5 minutes
    ...  modify:MRBTS-${nrbts_id}/MNL-1/MNLENT-1/PMCADM-1\$:reportingIntervalPm=5min
    #  for test of feature CB010559
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRRCC=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRRCD=5min
    #  for other features
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaCu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrCaDu=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSACU=5min
    ...  modify:${nrbts_nidd}/NRPMRNL-1\$:miNrRSADU=5min

    #  NRBTS parameters
    #...  modify:${nrbts_nidd}\$:actCarAgPmCount=true
    #...  modify:${nrbts_nidd}\$:actBufferBasedSCellAddition=oneShot_Dl_Fr1
    #...  modify:${nrbts_nidd}\$:sCellActivationMethod=bufferBased
    #...  modify:${nrbts_nidd}\$:actInterFreqHoSA=true
    ...  modify:${nrbts_nidd}\$:actRrcRREUnprepgNB=intergNB

    # *** S O U R C E gNB-0 on TL126 / TL387 and TL351 / TL364 specific part **********
    IF   ${nrbts_id} in [401261,403871,403511,403641]

        #   --- configure Cells with NRHOIF and NRREL objects: ---
        #   NRCELL-X/NRHOIF-Y   NRCELL-X/NRREL-Z parameters
        #   NRHOIF MOs: cell-8 to cell-9 and vice versa are existing, activated with the a2BasedPCellSwitchEnabled=true
        FOR    ${nrcell}   ${nrrel}   IN
        ...    ${GNB0_SOURCE_P_CELL_UE_1}           ${GNB0_NRREL_TO_TARGET_P_CELL_UE_1}
            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
            #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}\$:handoverAllowedSA=XnHoNotAllowed
            #  handoverAllowedSARedCap=forbidden is the default value, but it has to be set again, because the
            #  modify:...:handoverAllowedSA=XnHoNotAllowed before also changes this value and XnHoNotAllowed is not
            #  a valid value for this parameter
            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}\$:handoverAllowedSARedCap=forbidden
        END

    # *** T A R G E T gNB-1 on TL126 / TL387 and TL351 / TL364 specific part **********
    ELSE IF   ${nrbts_id} in [401262,403872,403512,403642]
        Log To Console  NO NRREL objects has to be commissioned for gNB-${gnb_id}: ${nrbts_id} at the moment
#       FOR    ${nrcell}   ${nrrel}   IN
#       ...    ${GNB1_TARGET_P_CELL_UE_1}           ${GNB0_SOURCE_P_CELL_UE_1}
#
#            Collections.Append To List  ${GNB_PARAMS_IN_SCF}
#            #  NRCELL-X/NRREL-Y   objects already exist, only the parameters inside has to be added !!!
#            ...  modify:${nrbts_nidd}/NRCELL-${nrcell}/NRREL-${nrrel}\$:handoverAllowedSA=XnHoNotAllowed
#        END

    ELSE
        Fail    No commissioning defined for gNB with NRBTS ID ${nrbts_id}
    END
    #  - END - parameter changes

    scf.Perform SCF Modification    modification_strings=${gnb_params_in_scf}
    scf.Save SCF  ${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml

    scf.Calculate Delta SCF
    ...  target_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_mod.xml
    ...  actual_scf_path=${configDir}/SCFC_gNB${gnb_id_}_DU.xml
    ...  delta_scf_path=${configDir}/SCFC_gNB${gnb_id}_${TC_NUMBER}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM HTTP Session   node_id=${gnb_id}
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
