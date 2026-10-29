*** Settings ***
Documentation     [SUITE PURPOSE]   Common keyword of CB009836 feature
...               Prerequisite : gNB configured with 4 Cells & RU detected
...               Scope : CB009836

...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 20-02-2024
...               Version History    Date           Author                      Notes
...               1.0                13-06-2024     adrien.hervat@nokia.com     First Push
...               1.1                17-09-2024     adrien.hervat@nokia.com     Fix vendor file bbpoolcapacity fronthaulType


Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim                    WITH NAME    wts
Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Library           ../../../../../resources/SWENG/python/PandasCsv.py
Library           ../../../resources/python/luashark_tools.py

Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Hardening.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot

Resource          ../../../CB011028/resources/robot/CB011028-D-Keywords.robot


Variables         ../../../../../resources/SWENG/python/Colors.py



*** Keywords ***

Get Snaphot Sos Report

    Dated log                       Get Snapshot
  # Get Sos Report
    Get Snapshot



Suite Setup for CB009836

    [Arguments]                    ${custom_bsr_update}=1

    Connect to COAM ADMIN

    Run Keyword if     '${custom_bsr_update}' == '1'
    ...                 Run Keywords    dated log       =====> Get and Update BSR SW]
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_1_H1_ALN60_ARP60_P00_COVERAGE_00418_00001.zip    /home/ute/BSR
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001.zip    /home/ute/BSR
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001.zip    /home/ute/BSR
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip    /home/ute/BSR
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_8_H8_ALN60_ARP60_P00_COVERAGE_00426_00001.zip    /home/ute/BSR

    Run Keyword if     '${custom_bsr_update}' == '1'
    ...                 Run Keywords    dated log       =====> Update Configuration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/custom/scf_CB009836_2516_TDD_4cells_8DL8UL_tdLte_3ms_ASOE.xml
    ...                 basicPathname=${CURDIR}/../../config/custom/basic_setup_CB009836_TDD_4cells_8DL8UL_ASOE.cfg
    ...                 iphyPathname=${CURDIR}/../../config/custom/iphy_CB009836_TDD_4cells_8DL8UL_ASOE.xml
    ...      ELSE                       Suite Setup From Scratch        ${FD_ALL}



Set RAD Params for 9836

    Dated Log New Line   Add RAD params for 9836 ......

    ${rad_param_1}=      create dictionary       field=0x4B000F    value=1              # RF_SW_Version_check_disabled
    ${rad_param_2}=      create dictionary       field=0x3F007C    value=250            # Increase size for BIP TCP Dump

    ${rad_param_list}=       Create List         ${rad_param_1}
    ...                                          ${rad_param_2}

    SetConfig.Set Fields in swconfig DU          param_list=${rad_param_list}
    Dated Log New Line                           RAD params update completed



Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity for ASOE

    ${original_vendor_file}    ${modified_vendor_file}              SetConfig.Download Vendor File
    Dated Log               -----> Original Vendor File Name :
    Dated Log               ${original_vendor_file}
    Dated Log               -----> Modified Vendor File Name will be :
    Dated Log               ${modified_vendor_file}

    ScfVendorOperations.setup reader            ${original_vendor_file}
    ${mo_dict}              ScfVendorOperations.get moelements byclass        NRBTS
    # bbL1SpPrbInitCapacity
    # Original value should be related to <!-- 48 CS, only DL -->
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=DL
    ...                               l1PoolType=${vendor_param.l1PoolType}
    ...                               maxNumLayerPrbL1Sp=2184
    ...                               maxNumStreamPrbL1Sp=2184
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.maxNumLayerPrbL1Sp}=         Run Keyword If    ${vendor_param.maxNumLayerPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumLayerPrbL1Sp}

    ${vendor_param.maxNumStreamPrbL1Sp}=        Run Keyword If    ${vendor_param.maxNumStreamPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumStreamPrbL1Sp}

    ${vendor_param.maxNumWbStreamPrbL1Sp}=        Run Keyword If    ${vendor_param.maxNumWbStreamPrbL1Sp} == None    Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumWbStreamPrbL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=DL
    ...                               l1PoolType=${vendor_param.l1PoolType}
    ...                               maxNumLayerPrbL1Sp=${vendor_param.maxNumLayerPrbL1Sp}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.maxNumStreamPrbL1Sp}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.maxNumWbStreamPrbL1Sp}
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}


    # Original value should be related to <!-- 48 CS, only UL -->
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=UL
    ...                               l1PoolType=${vendor_param.l1PoolType}
    ...                               maxNumLayerPrbL1Sp=819
    ...                               maxNumStreamPrbL1Sp=1638
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.ul_maxNumLayerPrbL1Sp}=     Run Keyword If    ${vendor_param.ul_maxNumLayerPrbL1Sp} == None    Set Variable    819
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumLayerPrbL1Sp}

    ${vendor_param.ul_maxNumStreamPrbL1Sp}=    Run Keyword If    ${vendor_param.ul_maxNumStreamPrbL1Sp} == None
    ...                                                                                                                   Set Variable    1638
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumStreamPrbL1Sp}
    ${vendor_param.ul_maxNumWbStreamPrbL1Sp}=  Run Keyword If    ${vendor_param.ul_maxNumWbStreamPrbL1Sp} == None
    ...                                                                                                                   Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumWbStreamPrbL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=UL
    ...                               l1PoolType=${vendor_param.l1PoolType}
    ...                               maxNumLayerPrbL1Sp=${vendor_param.ul_maxNumLayerPrbL1Sp}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.ul_maxNumStreamPrbL1Sp}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.ul_maxNumWbStreamPrbL1Sp}
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    # Principe de fonctionnement:
    # Lors du prochain branch off (par exemple: 25R2), si les vendors parameters ont ete modifies, alors vous allez devoir faire ceci:
    # - step 1 : dupliquer le dictionnaire "original_values_SBTS00" en "original_values_SBTS25R2"
    # - step 2 : dupliquer le dictionnaire "new_values_SBTS00" en "new_values_SBTS25R2"
    # - step 3 : adapter le dictionnaire "original_values_SBTS00" avec les nouveaux vendors parameters
    # - step 4 : adapter le dictionnaire "new_values_SBTS00" avec les nouveaux vendors parameters

    # bbPoolCapacity: original values for SBTS00
    &{original_values_SBTS00}    Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               maxPdschTpSlotL1Pool=0
    ...                               maxPdschTpSlotL2Pool=0
    ...                               maxPuschTpSlotL1Pool=0
    ...                               maxPuschTpSlotL2Pool=0
    ...                               confDuplexMode=TDD
    ...                               fronthaulType=cpriOrEcpri72a
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=120
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=23
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=30
    ...                               maxNumScheUePdschL1Sp=24
    ...                               maxNumScheUePdschL2Sp=24
    ...                               maxNumScheUePuschL1Pool=30
    ...                               maxNumScheUePuschL1Sp=30
    ...                               maxNumScheUePuschL2Sp=24
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40
    ...                               maxNumCellPucchStrPrbL1Pool=50000
    ...                               maxNumPooledPucchStrPrbL1Pool=65535
    ...                               ulCellTpRedFactor=75
    ...                               maxNumPosMeasNRPosCellL2Pool=0
    ...                               maxNumPosMeasNRCellL2Pool=0

    # bbPoolCapacity: original values for SBTS25R1
    &{original_values_SBTS25R1}       Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               maxPdschTpSlotL1Pool=0
    ...                               maxPdschTpSlotL2Pool=0
    ...                               maxPuschTpSlotL1Pool=0
    ...                               maxPuschTpSlotL2Pool=0
    ...                               confDuplexMode=TDD
    ...                               fronthaulType=cpriOrEcpri72a
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=120
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=23
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=30
    ...                               maxNumScheUePdschL1Sp=24
    ...                               maxNumScheUePdschL2Sp=24
    ...                               maxNumScheUePuschL1Pool=30
    ...                               maxNumScheUePuschL1Sp=30
    ...                               maxNumScheUePuschL2Sp=24
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40
    ...                               maxNumCellPucchStrPrbL1Pool=50000
    ...                               maxNumPooledPucchStrPrbL1Pool=65535

    ${vendor_param.maxNumScheUePdschL1Pool}=    Run Keyword If    ${vendor_param.maxNumScheUePdschL1Pool} == None    Set Variable    30
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Pool}

    ${vendor_param.maxNumScheUePdschL1Sp}=      Run Keyword If    ${vendor_param.maxNumScheUePdschL1Sp} == None    Set Variable    24
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Sp}

    # bbPoolCapacity: new values for SBTS00
    &{new_values_SBTS00}    Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               maxPdschTpSlotL1Pool=0
    ...                               maxPdschTpSlotL2Pool=0
    ...                               maxPuschTpSlotL1Pool=0
    ...                               maxPuschTpSlotL2Pool=0
    ...                               confDuplexMode=TDD
    ...                               fronthaulType=cpriOrEcpri72a
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=120
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=23
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=${vendor_param.maxNumScheUePdschL1Pool}
    ...                               maxNumScheUePdschL1Sp=${vendor_param.maxNumScheUePdschL1Sp}
    ...                               maxNumScheUePdschL2Sp=24
    ...                               maxNumScheUePuschL1Pool=30
    ...                               maxNumScheUePuschL1Sp=30
    ...                               maxNumScheUePuschL2Sp=24
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40
    ...                               maxNumCellPucchStrPrbL1Pool=50000
    ...                               maxNumPooledPucchStrPrbL1Pool=65535
    ...                               ulCellTpRedFactor=75
    ...                               maxNumPosMeasNRPosCellL2Pool=0
    ...                               maxNumPosMeasNRCellL2Pool=0

    # bbPoolCapacity: new values for SBTS25R1
    &{new_values_SBTS25R1}    Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               maxPdschTpSlotL1Pool=0
    ...                               maxPdschTpSlotL2Pool=0
    ...                               maxPuschTpSlotL1Pool=0
    ...                               maxPuschTpSlotL2Pool=0
    ...                               confDuplexMode=TDD
    ...                               fronthaulType=cpriOrEcpri72a
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=120
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=23
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=${vendor_param.maxNumScheUePdschL1Pool}
    ...                               maxNumScheUePdschL1Sp=${vendor_param.maxNumScheUePdschL1Sp}
    ...                               maxNumScheUePdschL2Sp=24
    ...                               maxNumScheUePuschL1Pool=30
    ...                               maxNumScheUePuschL1Sp=30
    ...                               maxNumScheUePuschL2Sp=24
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40
    ...                               maxNumCellPucchStrPrbL1Pool=50000
    ...                               maxNumPooledPucchStrPrbL1Pool=65535

    # get the branch name in order to use the correct bbPoolCapacity dictionary:
    ${gnbVersion}=          Split String    ${TLConfig.topo.gnbVersion}     _
    ${branchName}=          set variable    ${gnbVersion}[0]

    # apply the bbPoolCapacity dictionary:
    @{original_items_list}=           Create List         ${original_values}_${branchName}
    @{new_items_list}=                Create List         ${new_values}_${branchName}
    ${list_name}            Set Variable                  bbPoolCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    @{set_9836}=            Create List       actTddCsirsAllocOptimization      true
    @{Param_To_Replace}=    Create List       ${set_9836}
    ${modified_mo}=         ScfVendorOperations.replace params inMo      ${Param_To_Replace}    ${mo_dict}

    ScfVendorOperations.save back toxml                   ${modified_vendor_file}
    ${Tmp_file_ls}          OperatingSystem.run           ls -altr ${modified_vendor_file}
    Dated log               Obtained file ${Tmp_file_ls}
    &{args}                 Create Dictionary             vendor_file="${modified_vendor_file}"
    OAM Run Command         cmd=set_vendor_file           cmd_args=${args}



Set 9836 Context TDD SA

    [Arguments]       ${params}

    Copy File                             ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    ${scf_file_name}                      Fetch from right      ${SCF_SETUP_PATH}      /
    ${file_name_without_extention}        String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}                catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...                                   9836_TDD_SA.xml
    ${scf_file_update_path}               set variable    ${LOG_PATH}/${scf_name_for_update}
    SCF StartSession                      scf_file=${SCF_SETUP_PATH}     second_scf_file=${SCF_SETUP_PATH}
    Set Parameters on SCF_COAM_TDD_SA     params=${params}
    SCF StopSession                       scf_file=${scf_file_update_path}     second_scf_file=${scf_file_update_path}

    OAM Perform Full Commissioning        scf_file=${scf_file_update_path}
    Airscale Wait for Ready               ${GNB_DU}



Get New Cell Id List without None Value          # Create a new NRCELL_ID_LIST which does not contains "NONE" value
    [Documentation]                 Returns the number of not 'None' element in the list

    [Arguments]                     ${my_list}
    ${cell_id_list}=                Create List

    FOR     ${elem}     IN          @{my_list}
            Run Keyword If          '${elem}'!='None'
            ...                     Append To List     ${cell_id_list}     ${elem}
    END
    [Return]                        ${cell_id_list}



Set Parameters on SCF_COAM_TDD_SA

    [Arguments]       ${params}

    @{NRCELL_ID_LIST_UPDATED}     Get New Cell Id List without None Value     ${NRCELL_ID_LIST}

    Set Global Variable    @{NRCELL_ID_LIST_UPDATED}

    FOR    ${i}     IN     @{NRCELL_ID_LIST_UPDATED}

    ${j}           Evaluate         ${i} - 1

# PRB Pooling configuration
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actBbPoolTddFr1
           ...                                element_value=true
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# CB010513 Activation
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actBbPoolExtensionTddFr1
           ...                                element_value=true
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# CB011028 Activation
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actBbPoolTddFr1Enh
           ...                                element_value=false
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# CB002616 Activation
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=actInfTddFrameMuting
           ...                                element_value=${params.CB002516}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# CNI 74648 Activation
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=actBlankDlSymbBorderCoord
           ...                                element_value=${params.cni74648}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# CsiRs configuration
# This parameter indicates the CSI reporting periodicity
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=csiReportPeriodicity
           ...                                element_value=${params.csiReportPeriodicity}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# This parameter defines the maximum number of cell-specific CSI-RS for channel acquisition per UE
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=maxCsirsNumber
           ...                                element_value=${params.maxCsirsNumber}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# This parameter indicates the number of cell specific CSI-RS resource periods in one CSI report period
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=csirsNumberWithinReportPeriod_Set1
           ...                                element_value=${params.CsirsNumberWithin}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both


# Beam Set configuration
# This parameter indicates basic beam set
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=basicBeamSet
           ...                                element_value=${params.basicBeam}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# This parameter indicates basic beam set name
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
           SCF Set element                    dist_name=${dn}     element_name=customBeamSetName
           ...                                element_value=${params.basicBeamSet}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# This parameter indicates the number of ss blocks
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${j}
           SCF Set element                    dist_name=${dn}     element_name=numberOfTransmittedSsBlocks
           ...                                element_value=${params.numSsBlocks}
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

     END



Build UEs list SA Multi UEs

    ${totalNbOfUe}          get length          ${List_UEs}
    Step                    Dated Log           Configure the setting for the ${totalNbOfUe} ue's
    Set Global Variable     ${totalNbOfUe}

    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              ${current_ue}
        Set To Dictionary             ${current_ueSetting}          target_gnb          2
        Set To Dictionary             ${current_ueSetting}          target_cells        ${List_UEs[${current_id}].originalCell}
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${List_UEs[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${List_UEs[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${List_UEs[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          ue_nr_capa          ${List_UEs[${current_id}].ue_nr_capa}

        Append To List                ${listOfUes}                  ${current_ueSetting}
    END
    Dated Log New Line                UE_List=${listOfUes}

    [Return]                          ${listOfUes}



Set UE_Capa Context_WTS CFG

    [Arguments]       ${listOfUes}

    Create UEs in Cfg File             nb_sa_ues=${totalNbOfUe}

    FOR    ${current_elem}    IN    @{listOfUes}
        Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${current_elem.ue}    ue_nr_capa=${current_elem.ue_nr_capa}
        ...                            cell_id=${current_elem.target_cells}
    END



Multi Cells Setup for 9836

    [Arguments]              ${listOfUes}

    ${nb_Cell}          get length          ${List_Cells}

    ${msgStr}=    Catenate  Test ${nb_Cell} Cells Setup
    Dated Log   ${msgStr}

    Check Multi Ues Setting In List                                 multiUesList=${listOfUes}
    CallSetup.Setup Wtsemu SA                                       nbUe=${totalNbOfUe}
    ...                                                             nbSaUe=${totalNbOfUe}
    ...                                                             shouldUseLua=True
  #  ...                                                             shouldSaveBasicCfg=True
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    WTS Set X2 Link
    sleep    5s



Set Rank for UEs

    # csi_override testmode (to set UE rank level)
    wtsemu.csi_override_testmode_nr       profile_id=1
    ...                                   cqi=15
    ...                                   cqi_mode=fixed
    ...                                   ri=3
    ...                                   ri_mode=fixed

    wtsemu.csi_override_testmode_nr       profile_id=2
    ...                                   cqi=15
    ...                                   cqi_mode=fixed
    ...                                   ri=1
    ...                                   ri_mode=fixed

    wtsemu.ue_testmode_set_nr             id=1
    ...                                   testmode=csi_override
    ...                                   profile_id=1
    ...                                   scell=0
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=5
    ...                                   testmode=csi_override
    ...                                   profile_id=2
    ...                                   scell=0
    ...                                   action=activate



Set DL MU MIMO Test Modes

    Set Rank for UEs

    # Create cell_srs_beam_pos test mode

    wtsemu.cell_srs_beam_pos_nr           profile_id=1
    ...                                   num_of_ue_positions=4
    ...                                   azimuth=-70,-19,20,70

    wtsemu.cell_testmode_set_nr           cell_id=1-4
    ...                                   gnb=2
    ...                                   testmode=cell_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    # Create ue_srs_beam_pos test mode

    wtsemu.ue_srs_beam_pos_nr             profile_id=1
    ...                                   init_pos=0
    ...                                   srsMode=fixed

    wtsemu.ue_srs_beam_pos_nr             profile_id=2
    ...                                   init_pos=2
    ...                                   srsMode=fixed

    wtsemu.ue_testmode_set_nr             id=1
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=5
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate



Set UL MU MIMO Test Modes

    # Create ul_mimo_srs_beam_pos test mode
    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=1
    ...                                   mode=fixed
    ...                                   init_quad_pos=1
    ...                                   init_sub_quad_pos=0
    ...                                   step=5
    ...                                   trigger_puxch_update=0

    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=2
    ...                                   mode=fixed
    ...                                   init_quad_pos=3
    ...                                   init_sub_quad_pos=1
     ...                                   step=5
    ...                                   trigger_puxch_update=0

    wtsemu.ue_testmode_set_nr             id=1
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=5
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate



SA Start Traffic Multi UEs NonGBR

    [Arguments]       ${listOfUes}     ${params}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === SA Register UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.UE Register                                   ue=${current_elem.ue}

        CallSetup.Launch PDU Session                            ue=${current_elem.ue}
        ...                                                     pdu=${current_elem.pdu}
        ...                                                     gw=${current_elem.ue}
    END

# Start the UL Non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.UL_throughput} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.UL_throughput}Mbits/s NonGBR UL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       Start UL Traffic SA Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END

# Start the Non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.DL_throughput} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.DL_throughput}Mbits/s NonGBR DL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       Start DL Traffic SA Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END



Start DL Traffic SA Not Stopped

    [Arguments]             ${param}

    ...                     ${ueSetting}=${BASIC_UE_SA}

    Set To Dictionary       ${ueSetting}        trf_id    1
    Traffic UE DL           ueSetting=${ueSetting}
    ...                               throughput=${ueSetting.DL_throughput}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${param.duration}
    ...                               shouldBeStop=False
    ...                               deviation=${param.deviation}



Start UL Traffic SA Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${ueSetting}
    ...     Actions:        it manages the UL traffic on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        UL traffic is passed
    [Arguments]             ${param}
    ...                     ${ueSetting}=${BASIC_UE_SA}

    Set To Dictionary       ${ueSetting}        trf_id    1
    Traffic UE UL           ueSetting=${ueSetting}
    ...                     throughput=${ueSetting.UL_throughput}
    ...                     captureCallback=None
    ...                     capture=None
    ...                     captureDuration=0
    ...                     duration=${param.duration}
    ...                     shouldBeStop=False
    ...                     deviation=${param.deviation}



SA DeRegister Multi UEs
    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === SA DeRegister UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.UE Deregister       id=${current_elem.ue}
    END



Get L1L2 Logs

    Dated Log                         ======> Get L1L2 Bip Traces

    ${CaptureBIP}                     Capture L1L2 Set Upon Config     airscale=${GNB_DU}

  #  ${bipMsgList}                     Set Variable               ${TrafficFilter}
  #  ${Capture_BIP.filter}             Run Keyword                Get Filter For Particular Msgs    ${bipMsgList}

    Capture Init                      ${CaptureBIP}
    Capture start                     ${CaptureBIP}
    Traced sleep                      2
    Capture stop                      ${CaptureBIP}

    Dated Log New Line                === path capture : ${CaptureBIP.path} ===

#    Set Global Variable               ${CaptureBIP.path}   # Not compatible with RF50
    Set Global Variable               ${CaptureBIP}



Check Csi Rs Slots and Symbols

    Dated Log New Line                Extract dldata_csirssendreq info from PCAP file here : ${CaptureBIP.path}

    set test variable                 ${pcapprocessed}           L1L2.csv
    set test variable                 ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}                    Catenate    tshark -r
    ...                               ${CaptureBIP.path} -T fields -Y "dldata_csirssendreql1sw" -e _ws.col.Info
    ...                               -e 3gpp.sfn
    ...                               -e 3gpp.slot
    ...                               -e 3gpp.subcellid
    ...                               -e DlData_CsiRsResourceL1sw_t.startSymbol
    ...                               -e DlData_CsiRsResourceL1sw_t.numOfPrb
    ...                               -e DlData_CsiRsResourceL1sw_t.csiRsConfig
    ...                               -e DlData_CsiRsResourceL1sw_t.trsInfo
    ...                               -E header=y -E separator=';' > ${pcapprocessed_path}
    Run                               ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${results}              CheckCsiRsSlotSymbolPos
    ...                                                   csvPathName=${pcapprocessed_path}
    ...                                                   ListofCell=${list_Cells}
    ...                                                   TrsSlotsList=${TrsSlots}
    ...                                                   TrsSymbolsList=${TrsSymbols}

    ${CsiRstab}=            Create List
    ${TrsSlotstabtab}=      Create List
    ${TrsSymbolstab}=       Create List
    ${CsiRsSlotstab}=       Create List
    ${CsirsSymbolstab}=     Create List

    ${nb_Cell}          get length              ${List_Cells}

    FOR    ${i}    IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1

        Dated Log New Line      ========== Check Csi Rs for Cell ${cell_id} ==========

        ${status}=         run keyword and return status     Should be True          ${results}[csipercell][${i}] > 0
        Run Keyword if          ${status} == True    Run Keywords
        ...                     Dated Log New Line
        ...    Number of Csi Rs = ${results}[csipercell][${i}] / ${results}[total] CsiRsSendReq for all Cells >> ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs Item = ${results}[trsitem][${i}] / ${results}[itempercell][${i}]
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs Item = ${results}[crsitem][${i}] / ${results}[itempercell][${i}]
        ...        ELSE         Run Keywords        Append To List     ${CsiRstab}    ${status}
        ...        AND          Dated Log New Line
        ...    No Csi Rs = ${results}[csipercell][${i}] / ${results}[total] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[trsslot][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Trs slot issues = ${results}[trsslot][${i}] / ${results}[trsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${TrsSlotstabtab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs slot issues = ${results}[trsslot][${i}] / ${results}[trsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[trssymbol][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Trs symbol issues = ${results}[trssymbol][${i}] / ${results}[trsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${TrsSymbolstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs symbol issues = ${results}[trssymbol][${i}] / ${results}[trsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[crsslot][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Csi-Rs slot issues = ${results}[crsslot][${i}] / ${results}[crsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CsiRsSlotstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs slot issues = ${results}[crsslot][${i}] / ${results}[crsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[crssymbol][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Csi-Rs symbol issues = ${results}[crssymbol][${i}] / ${results}[crsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CsirsSymbolstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs symbol issues = ${results}[crssymbol][${i}] / ${results}[crsitem][${i}] >> ${status}
    END

    FOR        ${i}    IN      @{CsiRstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{TrsSlotstabtab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{TrsSymbolstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{CsiRsSlotstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{CsirsSymbolstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END



Check Csi Rs Slots and Symbols 25R1

    Dated Log New Line                Extract dldata_csirssendreq info from PCAP file here : ${CaptureBIP.path}

    set test variable                 ${pcapprocessed}           L1L2.csv
    set test variable                 ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}                    Catenate    tshark -r
    ...                               ${CaptureBIP.path} -T fields -Y "dldata_csirssendreq" -e _ws.col.Info
    ...                               -e 3gpp.sfn
    ...                               -e 3gpp.slot
    ...                               -e 3gpp.subcellid
    ...                               -e DlData_CsiRsResource_t.startSymbol
    ...                               -e DlData_CsiRsResource_t.numOfPrb
    ...                               -e DlData_CsiRsResource_t.csiRsConfig
    ...                               -e DlData_CsiRsResource_t.trsInfo
    ...                               -E header=y -E separator=';' > ${pcapprocessed_path}
    Run                               ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${results}              CheckCsiRsSlotSymbolPos25R1
    ...                                                   csvPathName=${pcapprocessed_path}
    ...                                                   ListofCell=${list_Cells}
    ...                                                   TrsSlotsList=${TrsSlots}
    ...                                                   TrsSymbolsList=${TrsSymbols}

    ${CsiRstab}=            Create List
    ${TrsSlotstabtab}=      Create List
    ${TrsSymbolstab}=       Create List
    ${CsiRsSlotstab}=       Create List
    ${CsirsSymbolstab}=     Create List

    ${nb_Cell}          get length              ${List_Cells}

    FOR    ${i}    IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1

        Dated Log New Line      ========== Check Csi Rs for Cell ${cell_id} ==========

        ${status}=         run keyword and return status     Should be True          ${results}[csipercell][${i}] > 0
        Run Keyword if          ${status} == True    Run Keywords
        ...                     Dated Log New Line
        ...    Number of Csi Rs = ${results}[csipercell][${i}] / ${results}[total] CsiRsSendReq for all Cells >> ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs Item = ${results}[trsitem][${i}] / ${results}[itempercell][${i}]
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs Item = ${results}[crsitem][${i}] / ${results}[itempercell][${i}]
        ...        ELSE         Run Keywords        Append To List     ${CsiRstab}    ${status}
        ...        AND          Dated Log New Line
        ...    No Csi Rs = ${results}[csipercell][${i}] / ${results}[total] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[trsslot][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Trs slot issues = ${results}[trsslot][${i}] / ${results}[trsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${TrsSlotstabtab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs slot issues = ${results}[trsslot][${i}] / ${results}[trsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[trssymbol][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Trs symbol issues = ${results}[trssymbol][${i}] / ${results}[trsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${TrsSymbolstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Trs symbol issues = ${results}[trssymbol][${i}] / ${results}[trsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[crsslot][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Csi-Rs slot issues = ${results}[crsslot][${i}] / ${results}[crsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CsiRsSlotstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs slot issues = ${results}[crsslot][${i}] / ${results}[crsitem][${i}] >> ${status}

        ${status}=         run keyword and return status     Should be True          ${results}[crssymbol][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Number of Csi-Rs symbol issues = ${results}[crssymbol][${i}] / ${results}[crsitem][${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CsirsSymbolstab}    ${status}
        ...        AND          Dated Log New Line
        ...    Number of Csi-Rs symbol issues = ${results}[crssymbol][${i}] / ${results}[crsitem][${i}] >> ${status}
    END

    FOR        ${i}    IN      @{CsiRstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{TrsSlotstabtab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{TrsSymbolstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{CsiRsSlotstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END

    FOR        ${i}    IN      @{CsirsSymbolstab}
        Run Keyword if     ${i} == False          Fail    Failure while checking Csi-Rs messages
    END



Get TTI Logs

    # TTI capture configuration
    ${TTIdir}                             Get TTI Trace Path    dir_suffix=TTI

    # Start TTI capture
    Dated Log New Line                    Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep                5         msg=DL TTI traffic capture 5 seconds

    # Stop TTI capture
    Dated Log New Line                    Stop TTI traces capture
    ${TTIpcap}                            Stop TTI Traces in Streaming mode
    ...                                   tti_trace_path=${TTIdir}
    ...                                   tti_trace_filename=TTI_TC9836

    Dated Log New Line                    Convert TTItrace to json and csv
    ${TTIjson}                            Convert TTItrace from pcap to others
    ...                                   input_file_path=${TTIpcap}
    ${TTIcsv}                             ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec
    ...                                   jsonPathName=${TTIjson}  #   num_of_events=10000

    Dated Log New Line                    === TTI csv path : ${TTIcsv} ===
    Set Global Variable                   ${TTIcsv}

    Dated Log New Line                    === TTI json path : ${TTIjson} ===
    Set Global Variable                   ${TTIjson}



Check Prb Pooling DL in TTI

    ${results}                CheckPrbPoolingDL        jsonPathName=${TTIjson}
    ...                                                ListofCell=${list_Cells}
    ...                                                L1Pool=${L1pool_Conf}
    ...                                                ListofL1Subpool=${List_L1Subpool}

    ${ZabCelltab}=              Create List
    ${MinPrbDltab}=             Create List
    ${CellPrbDltab}=            Create List
    ${BbrmUsablePrbDltab}=      Create List
    ${StreamPrbNonGbrDltab}=    Create List
    ${StreamPrbGbrDltab}=       Create List
    ${L1PoolIdDltab}=           Create List
    ${L1PoolMaxDltab}=          Create List
    ${L1SubpoolPrbDltab}=       Create List

    ${nb_Cell}          get length         ${List_Cells}

    ${status_msgdlAl}=      run keyword and return status     Should be True          ${results}[msgdlAl] > 0
    Run Keyword if          ${status_msgdlAl} == False
    ...                     Dated Log New Line
    ...    Event dlAllocatedPooledResourcesData not present in TTI file >> ${status_msgdlAl}

    ${status_msgdlIn}=      run keyword and return status     Should be True          ${results}[msgdlIn] > 0
    Run Keyword if          ${status_msgdlIn} == False
    ...                     Dated Log New Line
    ...    Event dlInterL1SubpoolReconfData not present in TTI file >> ${status_msgdlIn}

    Run Keyword if          ${status_msgdlAl} == False or ${status_msgdlIn} == False
    ...                     FAIL           Failure due to missing event in TTI

    FOR        ${i}    IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1

        Dated Log New Line      ========== Check Prb Pooling DL for Cell ${cell_id} ==========

        ${status}=      run keyword and return status    Should be True         ${results}[ZabCell][${i}] > 0
        ${status2}=     run keyword and return status    Should be True         ${list_Cells[${i}].Zab} == 1
        Run Keyword if          ${status} == True and ${status2} == True
        ...                     Dated Log New Line
        ...    Zab granted ${results}[ZabCell][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        ELSE IF      ${status} == True and ${status2} == False
        ...        Run Keywords        Append To List       ${ZabCelltab}    ${status2}
        ...        AND          Dated Log New Line
        ...    Zab granted but should not be ${results}[ZabCell][${i}]/${results}[DlReport][${i}] pooling reports >> ${status2}

        ${status}=      run keyword and return status    Should be True         ${results}[ZabCell][${i}] == 0
        ${status2}=     run keyword and return status    Should be True         ${list_Cells[${i}].Zab} == 0
        Run Keyword if          ${status} == True and ${status2} == True
        ...                     Dated Log New Line
        ...    Zab not granted as expected ${results}[ZabCell][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        ELSE IF      ${status} == True and ${status2} == False
        ...        Run Keywords        Append To List       ${ZabCelltab}    ${status2}
        ...        AND          Dated Log New Line
        ...    Zab not granted but should be ${results}[ZabCell][${i}]/${results}[DlReport][${i}] pooling reports >> ${status2}

        ${status}=     run keyword and return status    Should be True         ${results}[MinPrbDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Min PRB DL allocation is ${list_Cells[${i}].minPrbDl} Stream PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${MinPrbDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    Min PRB DL allocation issues ${results}[MinPrbDl][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Value is ${list_Cells[${i}].minPrbDl} Stream PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[CellPrbDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    DL PRB allocation range [${list_Cells[${i}].minCellPrbDl}-${list_Cells[${i}].maxCellPrbDl}] PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CellPrbDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    DL PRB allocation issues ${results}[CellPrbDl][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Range is [${list_Cells[${i}].minCellPrbDl}-${list_Cells[${i}].maxCellPrbDl}] PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[BbrmUsablePrbDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Max DL usable PRB is ${list_Cells[${i}].bbrmUsableCellPrbForDl} PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${BbrmUsablePrbDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    Max DL usable PRB issues ${results}[BbrmUsablePrbDl][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Value is ${list_Cells[${i}].bbrmUsableCellPrbForDl} PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[StreamPrbNonGbrDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    DL Non Gbr stream PRB allocation is >= to ${list_Cells[${i}].StreamPrbNonGbrDl} Stream PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${StreamPrbNonGbrDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    DL Non Gbr stream PRB allocation issues ${results}[StreamPrbNonGbrDl][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Reported Values are < to ${list_Cells[${i}].StreamPrbNonGbrDl} Stream PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[StreamPrbGbrDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    DL Gbr stream PRB allocation is >= to ${list_Cells[${i}].StreamPrbGbrDl} Stream PRBs ${status}
        ...        ELSE         Run Keywords        Append To List     ${StreamPrbGbrDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    DL Gbr stream PRB allocation issues ${results}[StreamPrbGbrDl][${i}]/${results}[DlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Reported Values are < to ${list_Cells[${i}].StreamPrbGbrDl} Stream PRBs
    END


    Dated Log New Line      ========== Check Prb Pooling DL for L1 Pool ==========

    ${status}=     run keyword and return status    Should be True         ${results}[L1PoolIdDl] == 0
    Run Keyword if          ${status} == True
    ...                     Dated Log New Line
    ...    L1 Pool Id is ${L1pool_Conf.L1PoolIdtoCheck} >> ${status}
    ...        ELSE         Run Keywords        Append To List     ${L1PoolIdDltab}    ${status}
    ...        AND             Dated Log New Line
    ...    L1 Pool Id issues : ${results}[L1PoolIdDl]/${results}[DlInterL1Event] pooling reports >> ${status}
    ...        AND          Dated Log    Expected Value is ${L1pool_Conf.L1PoolIdtoCheck}

    ${status}=    run keyword and return status    Should be True         ${results}[L1PoolMaxDl] == 0
    Run Keyword if          ${status} == True
    ...                     Dated Log New Line
    ...    L1 Pool Max Stream DL PRB is ${L1pool_Conf.L1PoolMaxStreamPrbDl} Stream PRBs >> ${status}
    ...        ELSE         Run Keywords        Append To List     ${L1PoolMaxDltab}    ${status}
    ...        AND             Dated Log New Line
    ...    L1 Pool Max Stream DL PRB issues ${results}[L1PoolMaxDl]/${results}[DlInterL1Event] pooling reports >> ${status}
    ...        AND          Dated Log    Expected Value is ${L1pool_Conf.L1PoolMaxStreamPrbDl} Stream PRBs


    FOR        ${i}    IN RANGE    0     2
        Dated Log New Line      ========== Check Prb Pooling DL for L1 Subpool ${i} ==========
        ${status}=    run keyword and return status    Should be True         ${results}[L1SubpoolPrbDl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    DL Stream PRB allocation range [${List_L1Subpool[${i}].minStreamL1SpDl}-${List_L1Subpool[${i}].maxStreamL1SpDl}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${L1SubpoolPrbDltab}    ${status}
        ...        AND             Dated Log New Line
        ...    DL Stream PRB allocation issues ${results}[L1SubpoolPrbDl][${i}]/${results}[DlInterL1Event] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Range is [${List_L1Subpool[${i}].minStreamL1SpDl}-${List_L1Subpool[${i}].maxStreamL1SpDl}]
    END

    FOR        ${i}    IN      @{ZabCelltab}
        Run Keyword if     ${i} == False          Fail     Prb Pooling Failure
    END

    FOR        ${i}    IN      @{MinPrbDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{CellPrbDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{BbrmUsablePrbDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{StreamPrbNonGbrDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{StreamPrbGbrDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1PoolIdDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1PoolMaxDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1SubpoolPrbDltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END



Check Prb Pooling UL in TTI

    ${results}                CheckPrbPoolingUL        jsonPathName=${TTIjson}
    ...                                                ListofCell=${list_Cells}
    ...                                                L1Pool=${L1pool_Conf}
    ...                                                ListofL1Subpool=${List_L1Subpool}

    ${CellPrbUltab}=            Create List
    ${BbrmUsablePrbUltab}=      Create List
    ${StreamPrbNonGbrUltab}=    Create List
    ${StreamPrbGbrUltab}=       Create List
    ${L1PoolIdUltab}=           Create List
    ${L1PoolMaxUltab}=          Create List
    ${L1SubpoolPrbUltab}=       Create List

    ${nb_Cell}          get length          ${List_Cells}

    ${status_msgulAl}=      run keyword and return status     Should be True          ${results}[msgulAl] > 0
    Run Keyword if          ${status_msgulAl} == False
    ...                     Dated Log New Line
    ...    Event ulAllocatedPooledResourcesData not present in TTI file >> ${status_msgulAl}

    ${status_msgulIn}=      run keyword and return status     Should be True          ${results}[msgulIn] > 0
    Run Keyword if          ${status_msgulIn} == False
    ...                     Dated Log New Line
    ...    Event ulInterL1SubpoolReconfData not present in TTI file >> ${status_msgulIn}

    Run Keyword if          ${status_msgulAl} == False or ${status_msgulIn} == False
    ...                     FAIL           Failure due to missing event in TTI

    FOR        ${i}     IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1
        Dated Log New Line      ========== Check Prb Pooling UL for Cell ${cell_id} ==========
        ${status}=    run keyword and return status    Should be True         ${results}[CellPrbUl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    UL PRB allocation range [${list_Cells[${i}].minCellPrbUl}-${list_Cells[${i}].maxCellPrbUl}] PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${CellPrbUltab}    ${status}
        ...        AND             Dated Log New Line
        ...    UL PRB allocation issues ${results}[CellPrbUl][${i}]/${results}[UlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Range is [${list_Cells[${i}].minCellPrbUl}-${list_Cells[${i}].maxCellPrbUl}] PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[BbrmUsablePrbUl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    Max UL usable PRB is ${list_Cells[${i}].bbrmUsableCellPrbForUl} PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${BbrmUsablePrbUltab}    ${status}
        ...        AND             Dated Log New Line
        ...    Max UL usable PRB issues ${results}[BbrmUsablePrbUl][${i}]/${results}[UlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Value is ${list_Cells[${i}].bbrmUsableCellPrbForUl} PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[StreamPrbNonGbrUl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    UL Non Gbr stream PRB allocation is >= to ${list_Cells[${i}].StreamPrbNonGbrUl} Stream PRBs >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${StreamPrbNonGbrUltab}    ${status}
        ...        AND             Dated Log New Line
        ...    UL Non Gbr stream PRB allocation issues ${results}[StreamPrbNonGbrUl][${i}]/${results}[UlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Reported Values are < to ${list_Cells[${i}].StreamPrbNonGbrUl} Stream PRBs

        ${status}=    run keyword and return status    Should be True         ${results}[StreamPrbGbrUl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    UL Gbr stream PRB allocation is >= to ${list_Cells[${i}].StreamPrbGbrUl} Stream PRBs ${status}
        ...        ELSE         Run Keywords        Append To List     ${StreamPrbGbrUltab}    ${status}
        ...        AND             Dated Log New Line
        ...    UL Gbr stream PRB allocation issues ${results}[StreamPrbGbrUl][${i}]/${results}[UlReport][${i}] pooling reports >> ${status}
        ...        AND          Dated Log    Reported Values are < to ${list_Cells[${i}].StreamPrbGbrUl} Stream PRBs
    END


    Dated Log New Line      ========== Check Prb Pooling UL for L1 Pool ==========

    ${status}=     run keyword and return status    Should be True         ${results}[L1PoolIdUl] == 0
    Run Keyword if          ${status} == True
    ...                     Dated Log New Line
    ...    L1 Pool Id is ${L1pool_Conf.L1PoolIdtoCheck} >> ${status}
    ...        ELSE         Run Keywords        Append To List     ${L1PoolIdUltab}    ${status}
    ...        AND             Dated Log New Line
    ...    L1 Pool Id issues : ${results}[L1PoolIdUl]/${results}[UlInterL1Event] pooling reports >> ${status}
    ...        AND          Dated Log    Expected Value is ${L1pool_Conf.L1PoolIdtoCheck}

    ${status}=    run keyword and return status    Should be True         ${results}[L1PoolMaxUl] == 0
    Run Keyword if          ${status} == True
    ...                     Dated Log New Line
    ...    L1 Pool Max Stream UL PRB is ${L1pool_Conf.L1PoolMaxStreamPrbUl} Stream PRBs >> ${status}
    ...        ELSE         Run Keywords        Append To List     ${L1PoolMaxUltab}    ${status}
    ...        AND             Dated Log New Line
    ...    L1 Pool Max Stream UL PRB issues ${results}[L1PoolMaxUl]/${results}[UlInterL1Event] pooling reports >> ${status}
    ...        AND          Dated Log    Expected Value is ${L1pool_Conf.L1PoolMaxStreamPrbUl} Stream PRBs


    FOR        ${i}    IN RANGE    0     2
        Dated Log New Line      ========== Check Prb Pooling UL for L1 Subpool ${i} ==========
        ${status}=    run keyword and return status    Should be True         ${results}[L1SubpoolPrbUl][${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    UL Stream PRB allocation range [${List_L1Subpool[${i}].minStreamL1SpUl}-${List_L1Subpool[${i}].maxStreamL1SpUl}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${L1SubpoolPrbUltab}    ${status}
        ...        AND             Dated Log New Line
        ...    UL Stream PRB allocation issues ${results}[L1SubpoolPrbUl][${i}]/${results}[UlInterL1Event] pooling reports >> ${status}
        ...        AND          Dated Log    Expected Range is [${List_L1Subpool[${i}].minStreamL1SpUl}-${List_L1Subpool[${i}].maxStreamL1SpUl}]
    END


    FOR        ${i}    IN      @{CellPrbUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{BbrmUsablePrbUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{StreamPrbNonGbrUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{StreamPrbGbrUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1PoolIdUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1PoolMaxUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END

    FOR        ${i}    IN      @{L1SubpoolPrbUltab}
        Run Keyword if     ${i} == False          Fail    Prb Pooling Failure
    END



Get Sherpa Logs

    Activate Sherpa
    Traced Sleep                               duration=5s
    Deactivate Sherpa and Stop Collect
    Upload and decode sherpa pcap files        Sherpa_logs_local_path=${trace_dir}
    Calling Panda Extract Csv For PRB Pooling



Get Syslogs

    # Start SYSLOG capture
    ${syslog}         SYSLOG Start        host=${GNB_DU.sys[0].M}    name=${test_name}
    Traced Sleep      duration=5s
    # Stop SYSLOG capture
    SYSLOG Stop       syslog=${syslog}



Start Syslogs 9836

     # Start SYSLOG capture
    ${syslog}         SYSLOG Start        host=${GNB_DU.sys[0].M}    name=${test_name}
    Set Suite Variable              ${syslog}



Stop Syslogs 9836

    # Stop SYSLOG capture
    Dated Log New Line    Stop Syslogs
    SYSLOG Stop       syslog=${syslog}



Start Capture CPRT

    ${CaptureCPRT_ASIB}             Capture CPRT Set Upon Config    airscale=${GNB_DU}

    Set Suite Variable              ${CaptureCPRT_ASIB}
    Capture Init                    ${CaptureCPRT_ASIB}
    Capture Start                   ${CaptureCPRT_ASIB}



Stop Capture CPRT

    Capture Stop    ${CaptureCPRT_ASIB}
    Dated Log New Line    Stop CPRT Capture



Check 9836 PM Counters

    Dated Log                       Waiting 300 seconds before checking counters
    sleep                           300s
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS      ${log_path_pm}
    set Suite Variable              ${LATEST_PM_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    Dated Log                       Latest pm counters file : ${LATEST_PM_FILE}

    Check 9836 PM Counters Expected values      ${PRBs_Available_Pdsch_L1_Pooling}
    Check 9836 PM Counters Expected values      ${PRBs_Available_Pusch_L1_Pooling}



Check 9836 PM Counters Expected values
    [Documentation]                 To Check 9836 PM counter values are as exepected
    [Arguments]                     ${PM_Counters_Expected}
    Dated Log                       =======================================================================
    Dated Log                       PM counter : ${PM_Counters_Expected.PM_ID}
    Dated Log                       --------------------------------------------------------------------------------
    ${Value_PM_Counter_Cell_1}=            Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                    ${LATEST_PM_FILE}       ${PM_Counters_Expected.PM_ID}       1
    Dated Log                         Value of PM counter : ${PM_Counters_Expected.PM_ID} : cell : 1 : ${Value_PM_Counter_Cell_1}
    ${Value_PM_Counter_Cell_2}=            Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                    ${LATEST_PM_FILE}       ${PM_Counters_Expected.PM_ID}       2
    Dated Log                         Value of PM counter : ${PM_Counters_Expected.PM_ID} : cell : 2 : ${Value_PM_Counter_Cell_2}
    ${Value_PM_Counter_Cell_3}=            Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                    ${LATEST_PM_FILE}       ${PM_Counters_Expected.PM_ID}       3
    Dated Log                         Value of PM counter : ${PM_Counters_Expected.PM_ID} : cell : 3 : ${Value_PM_Counter_Cell_3}
    ${Value_PM_Counter_Cell_4}=            Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                    ${LATEST_PM_FILE}       ${PM_Counters_Expected.PM_ID}       4
    Dated Log                         Value of PM counter : ${PM_Counters_Expected.PM_ID} : cell : 4 : ${Value_PM_Counter_Cell_4}

    Compare Counters to Reference    value=${Value_PM_Counter_Cell_1}           reference=${PM_Counters_Expected.CELL_1_Expected}
    ...                              name=${PM_Counters_Expected.PM_ID}    delta=10    cell=1
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_2}           reference=${PM_Counters_Expected.CELL_2_Expected}
    ...                              name=${PM_Counters_Expected.PM_ID}    delta=10    cell=2
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_3}           reference=${PM_Counters_Expected.CELL_3_Expected}
    ...                              name=${PM_Counters_Expected.PM_ID}    delta=10    cell=3
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_4}           reference=${PM_Counters_Expected.CELL_4_Expected}
    ...                              name=${PM_Counters_Expected.PM_ID}    delta=10    cell=4



# Compare PM counters reported value to a reference with a +/- delta in %
Compare Counters to Reference

    [Arguments]        ${value}      ${reference}      ${name}      ${cell}     ${delta}=1

    ${ref_min}         Evaluate       ((100 - ${delta})/100) * ${reference}
    ${ref_max}         Evaluate       ((100 + ${delta})/100) * ${reference}

    Run Keyword If     ${value} >= ${ref_min} and ${value} <= ${ref_max}
    ...                Dated Log
    ...            Value for counter ${name} is correct for cell ${cell} == ref min ${ref_min} < reported value ${value} < ref max ${ref_max} ==
    ...   ELSE IF        ${value} <= ${ref_min}
    ...                  FAIL    Value for counter ${name} is not correct for cell ${cell} == reported value : ${value} < ref min ${ref_min} ==
    ...   ELSE IF        ${value} >= ${ref_max}
    ...                  FAIL    Value for counter ${name} is not correct for cell ${cell} == reported value : ${value} > ref max ${ref_max} ==
