*** Settings ***
Documentation     [SUITE PURPOSE]  Common keywords of CB011127 feature

...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 24-12-2024
...               Version History    Date           Author                      Notes
...               1.0                29-07-2025     adrien.hervat@nokia.com     First delivery



Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim                    WITH NAME    wts
Library           taf.sbts.oam.coam.admin       WITH NAME    coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library           ../../../../../resources/SWENG/python/PandasCsv.py
Library           ../../../resources/python/luashark_tools.py

Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Hardening.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot

Resource          ../../../CB011028/resources/robot/CB011028-D-Keywords.robot


Variables         ../../../../../resources/SWENG/python/Colors.py



*** Variables ***

${f}    /home/ute/
${git_user}                              token_BSR_git
${git_token}                             glpat-o94WqjC8d6wspRAgDnsB
${SQR44_L2ET_GOLDEN_FILE_ADDRESS}        https://${git_user}:${git_token}@gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git

# PM counters
&{Num_RRC_Reconf_Sent}                   PM_ID=M55124C03001    # Number of RRC RECONFIGURATION sent
...                                      CELL_1_Expected=11
...                                      CELL_2_Expected=0
...                                      CELL_3_Expected=0
...                                      CELL_4_Expected=0

&{Num_RRC_Reconf_Complete_Received}      PM_ID=M55124C03002    # Number of RRC RECONFIGURATION COMPLETE received
...                                      CELL_1_Expected=11
...                                      CELL_2_Expected=0
...                                      CELL_3_Expected=0
...                                      CELL_4_Expected=0



*** Keywords ***

Get Snaphot Sos Report

    Dated log                       Get Snapshot
  # Get Sos Report
    Get Snapshot



Suite Setup for CB011127

    [Arguments]                    ${custom_bsr_update}=0

    Set Variables For Colors

    Connect to COAM ADMIN

    Run Keyword if     '${custom_bsr_update}' >= '0'
    ...                 Run Keywords    dated log       =====> Get and Update BSR SW
    ...      AND                        Get and Update BSR SW Using Git
    ...                                         ${SQR44_L2ET_GOLDEN_FILE_ADDRESS}
    ...                                         BSR     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip    /home/ute/BSR

    Run Keyword if     '${custom_bsr_update}' == '1'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ASOE/4cells_8DL8UL/scf_CB011127_TDD_4cells_8DL8UL_tdLte_0ms_ASOE.xml
    ...                 basicPathname=${CURDIR}/../../config/ASOE/4cells_8DL8UL/basic_setup_CB011127_TDD_4cells_8DL8UL_ASOE.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ASOE/4cells_8DL8UL/iphy_CB011127_TDD_4cells_8DL8UL_ASOE.xml

    Run Keyword if     '${custom_bsr_update}' == '2'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ABIP/6Cells_8DL8UL/scf_CB011127_TDD_6cells_8DL8UL_tdLte_0ms_ABIP.xml
    ...                 basicPathname=${CURDIR}/../../config/ABIP/6Cells_8DL8UL/basic_setup_CB011127_TDD_6cells_8DL8UL_ABIP.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ABIP/6Cells_8DL8UL/iphy_CB011127_TDD_6cells_8DL8UL_ABIP.xml

    Run Keyword if     '${custom_bsr_update}' == '3'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ABIP/6Cells_4DL4UL_WO_BF/scf_CB011127_TDD_6cells_4DL4UL_tdLte_0ms_ABIP.xml
    ...                 basicPathname=${CURDIR}/../../config/ABIP/6Cells_4DL4UL_WO_BF/basic_setup_CB011127_TDD_6cells_4DL4UL_ABIP.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ABIP/6Cells_4DL4UL_WO_BF/iphy_CB011127_TDD_6cells_4DL4UL_ABIP.xml

    Run Keyword if     '${custom_bsr_update}' == '4'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/scf_CB011127_TDD_3cells_16DL8UL_tdLte_0ms_ABIO_Fwk0.xml
    ...                 basicPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/basic_setup_CB011127_TDD_3cells_16DL8UL_ABIO.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/iphy_CB011127_TDD_3cells_16DL8UL_ABIO.xml

    Run Keyword if     '${custom_bsr_update}' == '5'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/scf_CB011127_TDD_3cells_16DL8UL_tdLte_0ms_ABIO_Fwk1_2-3cells.xml
    ...                 basicPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/basic_setup_CB011127_TDD_3cells_16DL8UL_ABIO.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ABIO/3cells_16DL8UL/iphy_CB011127_TDD_3cells_16DL8UL_ABIO.xml

    Run Keyword if     '${custom_bsr_update}' == '6'
    ...                 Run Keywords    dated log       =====> Update Confifuguration files >> SCF IPHY BASIC.CFG
    ...      AND                        Suite Setup From Scratch        ${FD_ALL}
    ...                 scfcPathname=${CURDIR}/../../config/ASOH/scf_CB011127_TDD_4cells_4DL4UL_tdLte_0ms_ASOH.xml
    ...                 basicPathname=${CURDIR}/../../config/ASOH/basic_setup_CB011127_TDD_4cells_4DL4UL_ASOH.cfg
    ...                 iphyPathname=${CURDIR}/../../config/ASOH/iphy_CB011127_TDD_4cells_4DL4UL_ASOH.xml

    Run Keyword if     '${custom_bsr_update}' == '0'    Suite Setup From Scratch        ${FD_ALL}



Set RAD Params for 11127
    [Documentation]     Add or Modify the RAD params of 11127 To Activate the feature

    Dated Log New Line   Add RAD params of 11127 ......

    ${rad_param_1}=      create dictionary       field=0x4B000F    value=1              # RF_SW_Version_check_disabled
    ${rad_param_2}=      create dictionary       field=0x3F007C    value=2000           # Increase size for BIP TCP Dump
    ${rad_param_3}=      create dictionary       field=0x58057a    value=4              # Debug mode
    ${rad_param_4}=      create dictionary       field=0x58057c    value=2048           # PRB_POOLING.BASIC
    ${rad_param_5}=      create dictionary       field=0x58057f    value=64             # RIM.RS_UL

    ${rad_param_list}=       Create List         ${rad_param_1}
    ...                                          ${rad_param_2}
    ...                                          ${rad_param_3}
 #   ...                                          ${rad_param_4}
    ...                                          ${rad_param_5}

    SetConfig.Set Fields in swconfig DU          param_list=${rad_param_list}
    Dated Log New Line                           RAD params of 11127 update complete



Get Vendor File

    ${original_vendor_file}    SetConfig.Download Vendor File
    Dated Log                  -----> Original Vendor File Name :
    Dated Log                  ${original_vendor_file}



Set 11127 Context TDD
    [Tags]                            SETUP
    OAM Get SCF Files
    Copy File                         ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    ${scf_file_name}                  Fetch from right      ${SCF_SETUP_PATH}      /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}            catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...                               11127_TDD_SA.xml
    ${scf_file_update_path}           set variable    ${LOG_PATH}/${scf_name_for_update}
    SCF StartSession                  scf_file=${SCF_SETUP_PATH}     second_scf_file=${SCF_SETUP_PATH}
    Set Parameters on SCF_COAM_TDD
    SCF StopSession                   scf_file=${scf_file_update_path}     second_scf_file=${scf_file_update_path}

    OAM Perform Full Commissioning    scf_file=${scf_file_update_path}
    Airscale Wait for Ready           ${GNB_DU}



Set 11127 Context FDD
    [Tags]                            SETUP
    OAM Get SCF Files
    Copy File                         ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    ${scf_file_name}                  Fetch from right      ${SCF_SETUP_PATH}      /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}            catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...                               11127_FDD_SA.xml
    ${scf_file_update_path}           set variable    ${LOG_PATH}/${scf_name_for_update}
    SCF StartSession                  scf_file=${SCF_SETUP_PATH}     second_scf_file=${SCF_SETUP_PATH}
    Set Parameters on SCF_COAM_FDD
    SCF StopSession                   scf_file=${scf_file_update_path}     second_scf_file=${scf_file_update_path}

    OAM Perform Full Commissioning    scf_file=${scf_file_update_path}
    Airscale Wait for Ready           ${GNB_DU}



Get New Cell Id List without None Value          # Create a new NRCELL_ID_LIST which does not contains "NONE" value
    [Documentation]                 Returns the number of not 'None' element in the list
    [Arguments]                     ${my_list}
    ${cell_id_list}=                Create List

    FOR     ${elem}     IN          @{my_list}
            Run Keyword If          '${elem}'!='None'
            ...                     Append To List     ${cell_id_list}     ${elem}
    END
    [Return]                        ${cell_id_list}



Set Parameters on SCF_COAM_FDD
   [Documentation]

    @{NRCELL_ID_LIST_UPDATED}     Get New Cell Id List without None Value     ${NRCELL_ID_LIST}

    Set Global Variable    @{NRCELL_ID_LIST_UPDATED}

    FOR    ${i}     IN     @{NRCELL_ID_LIST_UPDATED}

# This parameter activates/deactivates the UL PRB Randomization during RRC Reconfiguration CB013742
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actEnhRrcReconfUlPrbRandom
           ...                                element_value=false
           ...                                aicListEntity=vduvcu
           ...                                scope=Both

# This parameter activates/deactivates the allocation of PRBs to a transient phase UE (FDD)
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actTransPhaseUlPrbNonRandom
           ...                                element_value=false
           ...                                aicListEntity=vduvcu
           ...                                scope=Both
    END



Set Parameters on SCF_COAM_TDD
   [Documentation]

    @{NRCELL_ID_LIST_UPDATED}     Get New Cell Id List without None Value     ${NRCELL_ID_LIST}

    Set Global Variable    @{NRCELL_ID_LIST_UPDATED}

    FOR    ${i}     IN     @{NRCELL_ID_LIST_UPDATED}

# This parameter activates/deactivates the UL PRB Randomization during RRC Reconfiguration CB011127
           ${dn}             set variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
           SCF Set element                    dist_name=${dn}     element_name=actNrRimRsResourcePooling
           ...                                element_value=true
           ...                                aicListEntity=vduvcu
           ...                                scope=Both
    END



# Update basic.cfg and Iphy.xml
Update Basic.cfg and Iphy.xml

    FOR    ${i}     IN     @{NRCELL_ID_LIST_UPDATED}

           ${set_cell_id}=          Set Variable          set_cell id=${i} gnb=2
           ${cellid}=               Convert To String     ${i}

           Configure Parameter In WTS basic_setup File    identifier=${set_cell_id}    param=gscn    value=7878
           Configure Parameter In AP iphy File            identifier=${cellid}         param=GSCN    value=7878
    END



# basic_setup #
Configure Parameter In WTS basic_setup File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}

    Dated Log New Line                ----Configure Parameter In WTS basic_setup File----
    WtsCfgConfig.startSession
    ${default_value}=                 getParam    prefix=${identifier}    param=${param}
    Dated Log                         > default value for ${identifier}: ${param}= ${default_value}
    replaceValue                      prefix=${identifier}    param=${param}    oldValue=${default_value}    newValue=${value}
    Dated Log                         > new value updated for ${identifier} for ${param} is ${value}
    WtsCfgConfig.stopSession          rename=modified


#iphy#
Configure Parameter In AP iphy File
    [Arguments]             ${identifier}
    ...                     ${param}
    ...                     ${value}

    Dated Log New Line                ----Configure Parameter In AP iphy File----
    WtsXmlConfig.startSession         file=iphy
    WtsXmlConfig.setTextUsingIndex    path=//${param}    val=${value}    idx=${identifier}
    Dated Log                         > new value updated for ${param} idx= ${identifier} is ${value}
    WtsXmlConfig.stopSession          file=iphy



Update RIM Profile for all cells and bbmodBoardConfigType

    [Arguments]             ${TC_json}

    Dated Log New Line     Update of RIM Profile for all cells and bbmodBoardConfigType
    coam_parameter.perform_scf_delta_commission    delta_file=${TC_json}
    ...                                            connection=coam_gnb
    ...                                            timeout=120s
    OAM wait available



Build UEs list SA Multi UEs

    [Arguments]             ${dict_ues}
    ${totalNbOfUe}=         get length          ${dict_ues}
    Dated Log New Line      Configure the setting for the ${totalNbOfUe} ue's
    Set Global Variable     ${totalNbOfUe}

    @{listOfUes}=            Create List
    FOR    ${current_id}    IN RANGE    0    ${totalNbOfUe}
        ${current_ue_id}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=            Copy Dictionary               ${BASIC_UE_SA}

        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue_id}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              ${current_ue_id}
        Set To Dictionary             ${current_ueSetting}          target_gnb          2
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          UL_throughput_GBR      ${dict_ues[${current_id}].UL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          ue_nr_capa          ${dict_ues[${current_id}].ue_nr_capa}

        Append To List                ${listOfUes}                  ${current_ueSetting}
    END
    Dated Log New Line                UE_List=${listOfUes}

    [Return]                          ${listOfUes}



Build UEs list NSA Multi UEs

    [Arguments]                                 ${dict_ues}
    ${totalNbOfUe}=                             get length    ${dict_ues}
    Dated Log New Line                          Configure the setting for the ${totalNbOfUe} ue's
    Set Global Variable                         ${totalNbOfUe}

    @{listOfUes}=             Create List
    FOR    ${current_id}    IN RANGE    0       ${totalNbOfUe}
        ${current_ue_id}=                       Evaluate                 ${current_id} + 1
        ${current_ue_setting}=                  Copy Dictionary          ${UE_SIMPLE}


        Set To Dictionary             ${current_ue_setting}    ue                ${current_ue_id}
        Set To Dictionary             ${current_ue_setting}    trf_id            1
        Set To Dictionary             ${current_ue_setting}    bearer            2
        Set To Dictionary             ${current_ue_setting}    target_gnb        2
        Set To Dictionary             ${current_ue_setting}    target_cells      ${dict_ues[${current_id}].originalCell}
        Set To Dictionary             ${current_ueSetting}     DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}     DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}     UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}     UL_throughput_GBR      ${dict_ues[${current_id}].UL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}     ue_nr_capa        ${dict_ues[${current_id}].ue_nr_capa}
        Append To List                ${listOfUes}             ${current_ue_setting}
    END
    Dated Log New Line                UE_List=${listOfUes}

    [Return]                          ${listOfUes}




Set SA UE_Capa Context_WTS CFG

    [Arguments]       ${listOfUes}

    Create UEs in Cfg File             nb_sa_ues=${totalNbOfUe}

    FOR    ${current_elem}    IN    @{listOfUes}
        Modify UE Data in Cfg File     sa_or_nsa=SA    ue_id=${current_elem.ue}    ue_nr_capa=${current_elem.ue_nr_capa}
        ...                            cell_id=${current_elem.target_cells}
    END



Set NSA UE_Capa Context_WTS CFG

    [Arguments]       ${listOfUes}

    Create UEs in Cfg File             nb_nsa_ues=${totalNbOfUe}

    FOR    ${current_elem}    IN    @{listOfUes}
        Modify UE Data in Cfg File     sa_or_nsa=NSA    ue_id=${current_elem.ue}    ue_nr_capa=${current_elem.ue_nr_capa}
        ...                            cell_id=${current_elem.target_cells}
    END



Check Multi Ues Setting In List

    [Arguments]             ${multiUesList}=None

    ${NbOfUes}              get length     ${multiUesList}
    Dated Log New Line      ===> Check Multi Ues Setting In List number of ue's in list: NbOfUes=${NbOfUes}
    FOR    ${current_elem}    IN      @{multiUesList}
        Dated Log    serving cell=${current_elem.target_cells} on gnb=${current_elem.target_gnb} for ue=${current_elem.ue}
    END



Multi Cells Setup SA for 11127

    [Arguments]             ${listOfUes}

    ${msgStr}=    Catenate  Test ${totalNbOfUe} Cells Setup
    Dated Log   ${msgStr}

    Check Multi Ues Setting In List                                 multiUesList=${listOfUes}
    CallSetup.Setup Wtsemu SA                                       nbUe=${totalNbOfUe}
    ...                                                             nbSaUe=${totalNbOfUe}
    ...                                                             shouldUseLua=False
    ...                                                             shouldSaveBasicCfg=True
#    ...                                                             list_of_UE_tobe_created=${listOfUes}
    WTS Set X2 Link
    sleep    5s



Multi Cells Setup NSA for 11127

    [Arguments]             ${listOfUes}

    ${msgStr}=    Catenate  Test ${totalNbOfUe} Cells Setup
    Dated Log   ${msgStr}

    Check Multi Ues Setting In List                                 multiUesList=${listOfUes}
    CallSetup.WTS Setup                                             nbUe=${totalNbOfUe}
    ...                                                             nbSaUe=${totalNbOfUe}
    ...                                                             shouldUseLua=False
    ...                                                             shouldSaveBasicCfg=True
    WTS Set X2 Link
    sleep    5s



SA Register PDU setup

    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === SA Register UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.UE Register                                   ue=${current_elem.ue}

        CallSetup.Launch PDU Session                            ue=${current_elem.ue}
        ...                                                     pdu=${current_elem.pdu}
        ...                                                     gw=${current_elem.ue}
    END



NSA Attach SGNB Addition

    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === NSA Attach UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.SgNB Addition to ENB    ueSetting=${current_elem}
    END



Start Traffic Multi UEs NonGBR

    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.UL_throughput} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.UL_throughput}Mbits/s NonGBR UL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       UL Traffic Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END

    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.DL_throughput} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.DL_throughput}Mbits/s NonGBR DL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       DL Traffic Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END



DL Traffic Not Stopped

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



UL Traffic Not Stopped

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

ueSetting

SA Start Traffic Multi UEs GBR

    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.DL_throughput_GBR} > ${NO_THROUGHPUT} or ${current_elem.UL_throughput_GBR} > ${NO_THROUGHPUT}
        ...                 CallSetup.UE PDU Session Modify
        ...                                                     ue=${current_elem.ue}
        ...                                                     pdu=${current_elem.pdu}
        ...                                                     qfta=2
        ...                                                     by=amf
        Run Keyword If      ${current_elem.DL_throughput_GBR} > ${NO_THROUGHPUT} or ${current_elem.UL_throughput_GBR} > ${NO_THROUGHPUT}
        ...                 CallSetup.UE PDU Session Modify
        ...                                                     ue=${current_elem.ue}
        ...                                                     pdu=${current_elem.pdu}
        ...                                                     qfta=3
        ...                                                     by=amf
    END

    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.DL_throughput_GBR} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.DL_throughput_GBR}Mbits/s GBR DL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       DL Traffic GBR SA Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END

    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.UL_throughput_GBR} > ${NO_THROUGHPUT}     Run Keywords
        ...    Dated Log New Line
        ...         === Launch ${current_elem.UL_throughput_GBR}Mbits/s GBR UL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        ...    AND       UL Traffic GBR SA Not Stopped
        ...                                                     param=${params}
        ...                                                     ueSetting=${current_elem}
    END



DL Traffic GBR SA Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${ueSetting} ${current_trf_id}
    ...     Actions:        it manages the DL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed
    [Arguments]             ${param}
    ...                     ${ueSetting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=20

    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                           ${ueSetting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${ueSetting}    qfi    2
    Traffic UE DL                               ueSetting=${ueSetting}
    ...                                         throughput=${ueSetting.DL_throughput_GBR}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                          Evaluate    ${current_trf_id} + 1
    Set To Dictionary                           ${ueSetting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${ueSetting}    qfi    3
    Traffic UE DL                               ueSetting=${ueSetting}
    ...                                         throughput=${ueSetting.DL_throughput_GBR}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=udp



UL Traffic GBR SA Not Stopped
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${ueSetting} ${current_trf_id}
    ...     Actions:        it manages the UL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        UL traffic is passed
    [Arguments]             ${param}
    ...                     ${ueSetting}=${BASIC_UE_SA}
    ...                     ${current_trf_id}=22

    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary                           ${ueSetting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${ueSetting}    qfi    2
    Traffic UE UL                               ueSetting=${ueSetting}
    ...                                         throughput=${ueSetting.UL_throughput_GBR}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    ${current_trf_id}=                          Evaluate    ${current_trf_id} + 1
    Set To Dictionary                           ${ueSetting}    trf_id    ${current_trf_id}
    Set To Dictionary                           ${ueSetting}    qfi    3
    Traffic UE UL                               ueSetting=${ueSetting}
    ...                                         throughput=${ueSetting.UL_throughput_GBR}
    ...                                         captureCallback=None
    ...                                         capture=None
    ...                                         captureDuration=0
    ...                                         duration=${param.duration}
    ...                                         shouldBeStop=False
    ...                                         deviation=${param.deviation}
    ...                                         protocol=udp


Start Low Traffic SA For Ues

    [Arguments]             ${listOfUes}
    ...                     ${unit}=kbps
    ...                     ${bwp_transition}=from bwpId 1 to 2

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line    ===> traffic is requested for ue id=${current_elem.ue} dl=${current_elem.DL_throughput}${unit}
        Dated Log New Line    ===> traffic is requested for ue id=${current_elem.ue} ul=${current_elem.UL_throughput}${unit}
        Run Keyword If    ${current_elem.DL_throughput} or ${current_elem.UL_throughput} > ${NO_THROUGHPUT}
        ...                      Traffic Low SA Not Stopped            param=${params}    current_ue_setting=${current_elem}
        ...                                                         throughput_low=${current_elem.DL_throughput}
        ...                                                         throughput_ul_low=${current_elem.UL_throughput}
        ...                                                         unit=${unit}
        ...                                                         bwp_transition=${bwp_transition}
    END



Traffic Low SA Not Stopped

    [Arguments]
    ...                     ${current_ue_setting}
    ...                     ${current_trf_id}=1
    ...                     ${throughput_low}=100
    ...                     ${throughput_ul_low}=100
    ...                     ${unit}=kbps
    ...                     ${bwp_transition}=from bwpId 1 to 2

    # downlink
    ${current_trf_id}=                          Evaluate    ${current_trf_id}
    Set To Dictionary                           ${current_ue_setting}    trf_id    ${current_trf_id}
    ${expected_bwp_transition}=                 Set Variable    Bwp Switched ${bwp_transition}
    Dated Log                                   ===> trf_data_start ue=${current_ue_setting.ue} dir=dl ${unit}=${throughput_low}
    Dated Log                                   ===> trf_data_start ue=${current_ue_setting.ue} dir=ul ${unit}=${throughput_ul_low}
    Dated Log                                   ===> the expected transition should be ${expected_bwp_transition}
    wtsemu.trf_data_start    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    ...                                                             ${unit}=${throughput_low}
    wtsemu.trf_data_start    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=ul
    ...                                                             ${unit}=${throughput_ul_low}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=${expected_bwp_transition}    timeout=10
    Run Keyword If                              '${status}'=='FAIL'    Dated log    ===> No entry found for ${expected_bwp_transition}
    ...         ELSE                            Dated log    ===> ${expected_bwp_transition} is found
    Run Keyword If                              '${status}'=='FAIL'    Fail    No entry found for ${expected_bwp_transition}
    Return From Keyword If                      '${status}'=='FAIL'
    wtsemu.bearer_stats_clear    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    Sleep    3s
    wtsemu.Bearer Stats    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=dl
    ...                                                             trf_id=${current_trf_id}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=Average packet interval    timeout=10
    Run Keyword If    '${status}'=='FAIL'       Fail    No entry found for Average data rate in case dir=dl ${unit}=${throughput_low}
    Return From Keyword If    '${status}'=='FAIL'
    ${output_1}                                 Get Lines Matching Regexp    ${output}    Average data rate .*    partial_match=${TRUE}
    Log to Console    ${output_1}

    wtsemu.bearer_stats_clear    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=ul
    Sleep    3s
    wtsemu.Bearer Stats    ue=${current_ue_setting.ue}    pdu=${current_ue_setting.pdu}    qfi=${current_ue_setting.qfi}    dir=ul
    ...                                                             trf_id=${current_trf_id}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=Average packet interval    timeout=10
    Run Keyword If    '${status}'=='FAIL'       Fail    No entry found for Average data rate in case dir=ul ${unit}=${throughput_ul_low}
    Return From Keyword If    '${status}'=='FAIL'
    ${output_1}                                 Get Lines Matching Regexp    ${output}    Average data rate .*    partial_match=${TRUE}
    Log to Console    ${output_1}



SA DeRegister Multi UEs
    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === SA DeRegister UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.UE Deregister       id=${current_elem.ue}
    END



NSA Detach Multi UEs
    [Arguments]       ${listOfUes}

    FOR    ${current_elem}    IN    @{listOfUes}
        Dated Log New Line     === NSA Detach UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
        CallSetup.UE Detach Enb       ueSetting=${current_elem}
    END



Launch RRC Reestablishment SA

    [Arguments]    ${id}=1    ${reestabcause}=otherFailure      ${gnb}=2    ${cell}=1
    wtsemu.ue_rrc_reestablish         id=${id}        cause=${reestabcause}
    ...                               gnb=${gnb}      cell=${cell}
    ${output}                       wtsemu.Read Wtsemu Output Until Re
    ...                             expected=rrcReconfigurationComplete
    ...                             timeout=120
    sleep         5
    [Return]      ${output}



Get TTI Logs

    [Arguments]       ${TTI_Name}=CB011127_TTI_Traffic  #  ${time}=5s

    # TTI capture configuration
    ${TTIdir}                             Get TTI Trace Path    dir_suffix=TTI

    # Start TTI capture
    Dated Log New Line                    Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
 #   Traced Sleep           ${time}        msg=TTI traffic capture during ${time} seconds

    # Stop TTI capture
    Dated Log New Line                    Stop TTI traces capture
    ${TTIpcap}                            Stop TTI Traces in Streaming mode
    ...                                   tti_trace_path=${TTIdir}
    ...                                   tti_trace_filename=${TTI_Name}

    Dated Log New Line                    Convert TTItrace to json and csv
    ${TTIjson}                            Convert TTItrace from pcap to others
    ...                                   input_file_path=${TTIpcap}
    ${TTIcsv}                             ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec
    ...                                   jsonPathName=${TTIjson}  #   num_of_events=10000

    Dated Log New Line                    === TTI csv path : ${TTIcsv} ===
    Set Global Variable                   ${TTIcsv}

    Dated Log New Line                    === TTI json path : ${TTIjson} ===
    Set Global Variable                   ${TTIjson}



Start TTI Logs 11127

    # Start TTI capture
    Dated Log New Line                    Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2



Stop TTI Logs 11127

    [Arguments]       ${TTI_Name}=CB011127_TTI_Attach

    # TTI capture configuration
    ${TTIdir}                             Get TTI Trace Path    dir_suffix=TTI

    # Stop TTI capture
    Dated Log New Line                    Stop TTI traces capture
    ${TTIpcap}                            Stop TTI Traces in Streaming mode
    ...                                   tti_trace_path=${TTIdir}
    ...                                   tti_trace_filename=${TTI_Name}

    Dated Log New Line                    Convert TTItrace to json and csv
    ${TTIjson}                            Convert TTItrace from pcap to others
    ...                                   input_file_path=${TTIpcap}
    ${TTIcsv}                             ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec
    ...                                   jsonPathName=${TTIjson}  #   num_of_events=10000

    Dated Log New Line                    === TTI csv path : ${TTIcsv} ===
    Set Global Variable                   ${TTIcsv}

    Dated Log New Line                    === TTI json path : ${TTIjson} ===
    Set Global Variable                   ${TTIjson}



Get Syslogs

    # Start SYSLOG capture
    ${syslog}         SYSLOG Start        host=${GNB_DU.sys[0].M}    name=${test_name}
    Traced Sleep      duration=5s
    # Stop SYSLOG capture
    SYSLOG Stop       syslog=${syslog}



Start Syslogs 11127

     # Start SYSLOG capture
    ${syslog}         SYSLOG Start        host=${GNB_DU.sys[0].M}    name=${test_name}
    Traced Sleep      duration=5s
    Set Global Variable               ${syslog}



Stop Syslogs 11127

    # Stop SYSLOG capture
    SYSLOG Stop       syslog=${syslog}



Get L1L2 Logs

    [Arguments]       ${L1L2_Name}=CB011127_L1L2_Traffic  #  ${time}=1s

    Dated Log                         ======> Get L1L2 Bip Traces

    ${CaptureBIP}                     Capture L1L2 Set Upon Config     airscale=${GNB_DU}

    ${CaptureBIP.prefix}              set Variable               ${L1L2_Name}

 #   ${bipMsgList}                     Set Variable               ${TrafficFilter}
 #   ${Capture_BIP.filter}             Run Keyword                Get Filter For Particular Msgs    ${bipMsgList}

    Capture Init                      ${CaptureBIP}
    Capture start                     ${CaptureBIP}
 #   Traced sleep                      ${time}    msg=L1L2 capture during ${time} seconds
    Capture stop                      ${CaptureBIP}

    Dated Log New Line                === path capture : ${CaptureBIP.path} ===

    Set Global Variable               ${CaptureBIP}



Start L1L2 Logs

    [Arguments]       ${L1L2_Name}=CB011127_L1L2_Attach

    Dated Log                         ======> Get L1L2 Bip Traces

    ${CaptureBIP}                     Capture L1L2 Set Upon Config     airscale=${GNB_DU}

    ${CaptureBIP.prefix}              set Variable               ${L1L2_Name}

  #  ${bipMsgList}                     Set Variable               ${TrafficFilter}
  #  ${Capture_BIP.filter}             Run Keyword                Get Filter For Particular Msgs    ${bipMsgList}

    Capture Init                      ${CaptureBIP}
    Capture start                     ${CaptureBIP}
    Set Global Variable               ${CaptureBIP}



Stop L1L2 Logs

    Capture stop                      ${CaptureBIP}

    Dated Log New Line                === path capture : ${CaptureBIP.path} ===

    Set Global Variable               ${CaptureBIP}



Start Capture CPRT 11127
    ${CaptureCPRT}             Capture CPRT Set Upon Config    airscale=${GNB_DU}

    Set Suite Variable              ${CaptureCPRT}
    Capture Init                    ${CaptureCPRT}
    Capture Start                   ${CaptureCPRT}



Stop Capture CPRT 11127
    Capture Stop    ${CaptureCPRT}



Start Capture CORE 11127
    ${CaptureCORE}             Capture CORE Set Upon Config    airscale=${GNB_DU}

    Set Suite Variable              ${CaptureCORE}
    Capture Init                    ${CaptureCORE}
    Capture Start                   ${CaptureCORE}



Stop Capture CORE 11127

    Capture Stop    ${CaptureCORE}

    Dated Log New Line                === path capture : ${CaptureCORE.path} ===

    Set Global Variable               ${CaptureCORE}



Get Egate Console Log

    Dated Log New Line                === Get Egate Console Log ===
    wtsemu.Reset_Wtsemu_Cfg
    run    cp ${tl.core.dir_path}/egate_console.log ${LOG_PATH}



Get Iphy.xml

    ${alias}                        SSH Wait For Connect                 ${AP_DU.sys[0].M}
    ${IPHY_LOCAL_PATH}              set variable                        ${LOG_PATH}
    ${IPHY_REMOTE_PATH}             set variable                        /rom/simmode/iphy.xml
    Set Suite Variable              ${IPHY_LOCAL_PATH}
    ...                             ${IPHY_LOCAL_PATH}/iphy.xml
    set suite variable              ${IPHY_REMOTE_PATH}
    Dated Log                       ${MODULE}.startSession : Download ${IPHY_REMOTE_PATH} in ${IPHY_LOCAL_PATH}
    ${outUpload}                    csn.download_file
    ...                             remote_path=${IPHY_REMOTE_PATH}
    ...                             local_path=${IPHY_LOCAL_PATH}
    ...                             connection=${alias}



Set DL MU MIMO Test Mode

    [Arguments]    ${id1}=1    ${id2}=2

    Set Rank for UEs    id1=${id1}    id2=${id2}

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

    wtsemu.ue_testmode_set_nr             id=${id1}
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=${id2}
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate



Set Rank for UEs

    [Arguments]    ${id1}=1    ${id2}=2

    # csi_override testmode (to set UE rank level)
    wtsemu.csi_override_testmode_nr       profile_id=1
    ...                                   cqi=15
    ...                                   cqi_mode=fixed
    ...                                   ri=3
    ...                                   ri_mode=fixed

    wtsemu.csi_override_testmode_nr       profile_id=2
    ...                                   cqi=15
    ...                                   cqi_mode=fixed
    ...                                   ri=3
    ...                                   ri_mode=fixed

    wtsemu.ue_testmode_set_nr             id=${id1}
    ...                                   testmode=csi_override
    ...                                   profile_id=1
    ...                                   scell=0
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=${id2}
    ...                                   testmode=csi_override
    ...                                   profile_id=2
    ...                                   scell=0
    ...                                   action=activate



Set UL MU MIMO Test Mode

    [Arguments]    ${id1}=1    ${id2}=2

    # Create ul_mimo_srs_beam_pos test mode
    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=1
    ...                                   mode=fixed
    ...                                   init_quad_pos=2
    ...                                   init_sub_quad_pos=2
    ...                                   step=5
    ...                                   trigger_puxch_update=0

    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=2
    ...                                   mode=fixed
    ...                                   init_quad_pos=3
    ...                                   init_sub_quad_pos=3
    ...                                   step=5
    ...                                   trigger_puxch_update=0

    wtsemu.ue_testmode_set_nr             id=${id1}
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=${id2}
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate



Set Remote Interference Test Mode

    # Set Remote Interference profile 1
    wtsemu.remote_interference_testmode_nr    profile_id=1
    ...                                       start_symbol_position=0
    ...                                       num_of_symbols=32
    ...                                       noise_power_values=${NOISE_POWER_RI_1}

    # Set Remote Interference profile 2
    wtsemu.remote_interference_testmode_nr    profile_id=2
    ...                                       start_symbol_position=0
    ...                                       num_of_symbols=32
    ...                                       noise_power_values=${NOISE_POWER_RI_2}

    # Set Remote Interference profile 3
    wtsemu.remote_interference_testmode_nr    profile_id=3
    ...                                       start_symbol_position=0
    ...                                       num_of_symbols=32
    ...                                       noise_power_values=${NOISE_POWER_RI_3}

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=1
    ...                                       profile_id=1
    ...                                       action=activate

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=2
    ...                                       profile_id=1
    ...                                       action=activate

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=3
    ...                                       profile_id=1
    ...                                       action=activate

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=4
    ...                                       profile_id=1
    ...                                       action=activate

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=5
    ...                                       profile_id=1
    ...                                       action=activate

    # Enable RI test mode on a specific cell
    wtsemu.cell_testmode_set_nr               testmode=remote_interference
    ...                                       gnb=2
    ...                                       cell_id=6
    ...                                       profile_id=1
    ...                                       action=activate



Set RimRs Test Mode Framework 0

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=1
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=1
    ...                                   victim_cell=1
    ...                                   rsSetId=1111
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=1
    ...                                   gnb=2
    ...                                   profile_id=1
    ...                                   action=activate

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=2
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=2
    ...                                   victim_cell=2
    ...                                   rsSetId=2222
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=2
    ...                                   gnb=2
    ...                                   profile_id=2
    ...                                   action=activate

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=3
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=3
    ...                                   victim_cell=3
    ...                                   rsSetId=3333
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=3
    ...                                   gnb=2
    ...                                   profile_id=3
    ...                                   action=activate

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=4
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=4
    ...                                   victim_cell=4
    ...                                   rsSetId=4444
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=4
    ...                                   gnb=2
    ...                                   profile_id=4
    ...                                   action=activate

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=5
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=5
    ...                                   victim_cell=5
    ...                                   rsSetId=5555
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=5
    ...                                   gnb=2
    ...                                   profile_id=5
    ...                                   action=activate

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr              profile_id=6
    ...                                   config_mode=standalone
    ...                                   aggressor_cell=6
    ...                                   victim_cell=6
    ...                                   rsSetId=6666
    ...                                   numRsSetId=1
    ...                                   rimRsType=rsType1
    ...                                   propagation_delay=16
    ...                                   rsType1NScId=1,2,3,4
    ...                                   rsPattern1Period=50
    ...                                   rsPattern2Period=25
    ...                                   startRbForRs=96
    ...                                   rim_framework=framework_0
    ...                                   numRsType1SetId=65536
    ...                                   repetitionRsType1=2
    ...                                   rsNearFarConfig=0
    ...                                   numRbForRs=48

    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=6
    ...                                   gnb=2
    ...                                   profile_id=6
    ...                                   action=activate



Set RimRs Test Mode Framework 1

    # Set RimRS profile
    wtsemu.rimrs_testmode_nr
    ...    profile_id=1 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=1111 numRsSetId=1 rimRsType=rsType1
    ...    rsNearFarConfig=0 propagation_delay=16 rsSetId=2222 numRsSetId=1 rimRsType=rsType2 rsNearFarConfig=1 propagation_delay=16
    ...    factorRsSequenceRS2=1 factorRsSequence=1 offsetRsSequence=1 offsetRsSequenceRS2=1 rsPattern1Period=50 rsPattern2Period=25
    ...    rim_framework=framework_1 numRbForRs=48 repetitionRsType1=2 repetitionRsType2=2 rsType1NScId=1,2,3,4 rsType2NScId=1,2,3,4
    ...    numRsType1SetId=65536 numRsType2SetId=65536 startFreqOffsetForRs=86 globalF0ForRs=633390

    wtsemu.rimrs_testmode_nr
    ...    profile_id=2 config_mode=standalone aggressor_cell=2 victim_cell=2 rsSetId=3333 numRsSetId=1 rimRsType=rsType1
    ...    rsNearFarConfig=0 propagation_delay=16 rsSetId=4444 numRsSetId=1 rimRsType=rsType2 rsNearFarConfig=1 propagation_delay=16
    ...    factorRsSequenceRS2=1 factorRsSequence=1 offsetRsSequence=1 offsetRsSequenceRS2=1 rsPattern1Period=50 rsPattern2Period=25
    ...    rim_framework=framework_1 numRbForRs=48 repetitionRsType1=2 repetitionRsType2=2 rsType1NScId=1,2,3,4 rsType2NScId=1,2,3,4
    ...    numRsType1SetId=65536 numRsType2SetId=65536 startFreqOffsetForRs=86 globalF0ForRs=633390

    wtsemu.rimrs_testmode_nr
    ...    profile_id=3 config_mode=standalone aggressor_cell=3 victim_cell=3 rsSetId=5555 numRsSetId=1 rimRsType=rsType1
    ...    rsNearFarConfig=0 propagation_delay=16 rsSetId=6666 numRsSetId=1 rimRsType=rsType2 rsNearFarConfig=1 propagation_delay=16
    ...    factorRsSequenceRS2=1 factorRsSequence=1 offsetRsSequence=1 offsetRsSequenceRS2=1 rsPattern1Period=50 rsPattern2Period=25
    ...    rim_framework=framework_1 numRbForRs=48 repetitionRsType1=2 repetitionRsType2=2 rsType1NScId=1,2,3,4 rsType2NScId=1,2,3,4
    ...    numRsType1SetId=65536 numRsType2SetId=65536 startFreqOffsetForRs=86 globalF0ForRs=633390

    wtsemu.rimrs_testmode_nr
    ...    profile_id=4 config_mode=standalone aggressor_cell=4 victim_cell=4 rsSetId=7777 numRsSetId=1 rimRsType=rsType1
    ...    rsNearFarConfig=0 propagation_delay=16 rsSetId=8888 numRsSetId=1 rimRsType=rsType2 rsNearFarConfig=1 propagation_delay=16
    ...    factorRsSequenceRS2=1 factorRsSequence=1 offsetRsSequence=1 offsetRsSequenceRS2=1 rsPattern1Period=50 rsPattern2Period=25
    ...    rim_framework=framework_1 numRbForRs=48 repetitionRsType1=2 repetitionRsType2=2 rsType1NScId=1,2,3,4 rsType2NScId=1,2,3,4
    ...    numRsType1SetId=65536 numRsType2SetId=65536 startFreqOffsetForRs=86 globalF0ForRs=633390


    # Activate Rim Rs Profile on a specific cell
    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=1
    ...                                   gnb=2
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=2
    ...                                   gnb=2
    ...                                   profile_id=2
    ...                                   action=activate

    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=3
    ...                                   gnb=2
    ...                                   profile_id=3
    ...                                   action=activate

    wtsemu.cell_testmode_set_nr           testmode=rim_rs
    ...                                   cell_id=4
    ...                                   gnb=2
    ...                                   profile_id=4
    ...                                   action=activate



Set UlMuMiMo Layer to 2
    &{modify_param1}       Create Dictionary
    ...                                         parameter=ulMaxMuMimoLayer
    ...                                         dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRULMUMIMO-0
    ...                                         value=2

    @{modify_param}    Create List             ${modify_param1}
    Dated Log          Parameters to modify:\n ${modify_param}
    OAM Set Params                ${modify_param}



Set actAperCsi to True
    &{modify_param1}       Create Dictionary
    ...                                         parameter=actAperCsi
    ...                                         dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                         value=true

    @{modify_param}    Create List             ${modify_param1}
    Dated Log          Parameters to modify:\n ${modify_param}
    OAM Set Params                ${modify_param}



Check DCI UL_0_0_FORCE is not used

    ${results}               CheckDCI_UL_0_0_FORCE        jsonPathName=${TTIjson}
    ...                                                   ListofCell=${list_Cells}

    ${wrong_dci}=            Create List

    ${nb_Cell}               get length              ${List_Cells}

    FOR    ${i}    IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1

        Dated Log New Line      ========== Check if DCI_UL_0_0_FORCE is used for Cell ${cell_id} ==========

        ${status}=         run keyword and return status     Should be True          ${results}[${i}] == 0
        Run Keyword if          ${status} == True
        ...                     Dated Log New Line
        ...    DCI_UL_0_0_FORCE is never used ${results}[${i}] >> ${status}
        ...        ELSE         Run Keywords        Append To List     ${wrong_dci}    ${status}
        ...        AND          Dated Log New Line
        ...    DCI_UL_0_0_FORCE is used ${results}[${i}] times >> ${status}
    END

    FOR        ${i}    IN      @{wrong_dci}
        Run Keyword if     ${i} == False          Fail    Failure while checking DCI_UL_0_0_FORCE usage
    END



Check PRB Randomization on PUSCH during RRC Reconfiguration

    Dated Log New Line                Extract RRC Reconfiguration info from PCAP file here : ${CaptureBIP.path}

    set test variable                 ${pcapprocessed}           L1L2.csv
    set test variable                 ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}                    Catenate    tshark -r
    ...                               ${CaptureBIP.path} -T fields
    ...                               -Y "nr-rrc.rrcReconfiguration_element || nr-rrc.rrcReconfigurationComplete_element || uldata_puschreceivereq"
    ...                               -e _ws.col.info
    ...                               -e 3gpp.subcellid
    ...                               -e 3gpp.sfn
    ...                               -e 3gpp.slot
    ...                               -e 3gpp.rnti
    ...                               -e nr-rrc.c1
    ...                               -e UlData_puschReceiveReqGrant_t.startPrb
    ...                               -e UlData_puschReceiveReqGrant_t.numOfPrb
    ...                               -E header=y -E separator=';' > ${pcapprocessed_path}
    Run                               ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${results}              CheckPrbRandomization_V3
    ...                                                   csvPathName=${pcapprocessed_path}
    ...                                                   ListofCell=${list_Cells}


    ${PRBRandomizationIssues}=            Create List

    ${nb_Cell}          get length              ${List_Cells}

    FOR    ${i}    IN RANGE    0       ${nb_Cell}

        ${cell_id}=             Evaluate    ${i} + 1

        Dated Log New Line      ========== Check PRB Randomization on PUSCH for Cell ${cell_id} ==========

            Dated Log New Line      number of RRC Reconfiguration >> ${results}[totalNbRrcReconf][${i}]

            Run Keyword if          ${results}[totalNbRrcReconf][${i}] > 0
            ...                     Dated Log New Line      start PRBs >> ${results}[startprbtabCell][${i}]

            ${status}=              run keyword and return status     Should be True          ${results}[statusNbRrcReconf][${i}] == 0
            Run Keyword if          ${status} == True and ${results}[totalNbRrcReconf][${i}] > 0
            ...                     Dated Log New Line
            ...    No PRB randomization issue on PUSCH during transient phase ${results}[statusNbRrcReconf][${i}] >> issue >> ${status}
            ...        ELSE IF      ${status} == False
            ...                     Run Keywords        Append To List     ${PRBRandomizationIssues}    ${status}
            ...        AND          Dated Log New Line
            ...    Number of PRB randomization issues on PUSCH during transient phase >> ${results}[statusNbRrcReconf][${i}] >> ${status}
    END

    FOR        ${i}    IN      @{PRBRandomizationIssues}
        Run Keyword if     ${i} == False          Fail    Failure while checking PRB Randomization in PUSCH
    END



Check 11127 PM Counters

    Dated Log                       Waiting 540 seconds before checking counters
    sleep                           540s
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    Set suite Variable              ${log_path_pm}     ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log                       The PM counters file collected from gnb will be stored under : ${log_path_pm}
    Collect PM files from BTS       ${log_path_pm}

    Check 11127 PM Counters Expected values      ${Num_RRC_Reconf_Sent}
    Check 11127 PM Counters Expected values      ${Num_RRC_Reconf_Complete_Received}



Check 11127 PM Counters Expected values
    [Documentation]                 To Check 11127 PM counter values are as exepected
    [Arguments]                     ${11127_PM_Counters_Expected}
    Dated Log                       =======================================================================
    Dated Log                       PM counter : ${11127_PM_Counters_Expected.PM_ID}
    Dated Log                       PM counter : ${11127_PM_Counters_Expected}
    Dated Log                       --------------------------------------------------------------------------------
    ${Value_PM_Counter_Cell_1}=            Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                    ${log_path_pm}     NRCELL     ${11127_PM_Counters_Expected.PM_ID}     1
    Dated Log                         Value of PM counter : ${11127_PM_Counters_Expected.PM_ID} : cell : 1 : ${Value_PM_Counter_Cell_1}
    ${Value_PM_Counter_Cell_2}=            Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                    ${log_path_pm}     NRCELL     ${11127_PM_Counters_Expected.PM_ID}     2
    Dated Log                         Value of PM counter : ${11127_PM_Counters_Expected.PM_ID} : cell : 2 : ${Value_PM_Counter_Cell_2}
    ${Value_PM_Counter_Cell_3}=            Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                    ${log_path_pm}     NRCELL     ${11127_PM_Counters_Expected.PM_ID}     3
    Dated Log                         Value of PM counter : ${11127_PM_Counters_Expected.PM_ID} : cell : 3 : ${Value_PM_Counter_Cell_3}
    ${Value_PM_Counter_Cell_4}=            Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                    ${log_path_pm}     NRCELL     ${11127_PM_Counters_Expected.PM_ID}     4
    Dated Log                         Value of PM counter : ${11127_PM_Counters_Expected.PM_ID} : cell : 4 : ${Value_PM_Counter_Cell_4}

    Compare Counters to Reference    value=${Value_PM_Counter_Cell_1}           reference=${11127_PM_Counters_Expected.CELL_1_Expected}
    ...                              name=${11127_PM_Counters_Expected.PM_ID}    delta=50    cell=1
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_2}           reference=${11127_PM_Counters_Expected.CELL_2_Expected}
    ...                              name=${11127_PM_Counters_Expected.PM_ID}    delta=50    cell=2
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_3}           reference=${11127_PM_Counters_Expected.CELL_3_Expected}
    ...                              name=${11127_PM_Counters_Expected.PM_ID}    delta=50    cell=3
    Compare Counters to Reference    value=${Value_PM_Counter_Cell_4}           reference=${11127_PM_Counters_Expected.CELL_4_Expected}
    ...                              name=${11127_PM_Counters_Expected.PM_ID}    delta=50    cell=4



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



Sleep Until PM Availability
    [Arguments]             ${pm_granularity_period}=300
    ...                     ${pm_availability_delay}=60

    Dated Log                                   ===> sleep until PM availability is started
    ${time_of_start}=                           Evaluate    int(time.time())    time
    ${time_of_next_pm_period}=                  Evaluate    (int(${time_of_start} / ${pm_granularity_period}) + 1) * ${pm_granularity_period}
    ${time_of_pm_availability}=                 Evaluate    ${time_of_next_pm_period} + ${pm_availability_delay}
    ${duration_until_pm_availability}=          Evaluate    ${time_of_pm_availability} - ${time_of_start}
    ${timeout_string}=                          Catenate    ${duration_until_pm_availability}  sec
    ${date_of_pm_availability}=                 Convert date    ${time_of_pm_availability}
    Dated Log                                   ===> PM should be available in ${timeout_string}, at ${date_of_pm_availability}
    Sleep                                       ${timeout_string}
    Dated Log                                   ===> sleep until PM availability is ended



Check Counter And KPI Constraints
    [Arguments]             ${pm_path}
    ...                     ${test_name}
    ...                     ${localKpiFileName}=${None}

    Dated Log                                   ===> check counter and KPI constraints is started
    ${localKpiFile}=    Run Keyword If    '${localKpiFileName}' == '${None}'    Set Variable   ${None}
    ...                             ELSE        Set Variable   ${CURDIR}/../../config/counter/KPI/${localKpiFileName}
    KPI Evaluate                                pmFile=${pm_path}
    ...                                         constraintsFile=${test_name}
    ...                                         failOnError=${True}
    ...                                         localKpiFile=${localKpiFile}
    Dated Log                                   ===> check counter and KPI constraints is ended



Check Counters KPI

    [Arguments]             ${KPI_File}=${None}      ${Constraint_File}=${None}

    Sleep Until PM Availability
    ${pm_path}=    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Check Counter And KPI Constraints    ${pm_path}
    ...                                  test_name=${Constraint_File}
    ...                                  localKpiFileName=${KPI_File}



Check R&D Counters

    [Arguments]             ${Min}=${None}
    ...                     ${Max}=${None}

    ${RDCountersIssues}=             Create List

    ${rd_files}=                      RdCounters.Collect RD Counters

    FOR       ${i}      IN      @{NRCELL_ID_LIST_UPDATED}

        ${j}=                Evaluate     ${i} - 1

        Dated Log New Line      ========== Check R&D counters for Cell ${i} ==========

        ${status}=                        RdCounters.Check RD Counter Value With Criteria    counters_dir=${rd_files}
        ...                               counter_name=AVG_RIM_RS_RSC_ALLOC
        ...                               expected_value=${Min[${j}]}
        ...                               moc=NRCELL-${i}
        ...                               comparison='>='

        Run Keyword if          ${status} == False    Append To List     ${RDCountersIssues}    ${status}

        ${status}=                        RdCounters.Check RD Counter Value With Criteria    counters_dir=${rd_files}
        ...                               counter_name=AVG_RIM_RS_RSC_ALLOC
        ...                               expected_value=${Max[${j}]}
        ...                               moc=NRCELL-${i}
        ...                               comparison='<='
        Run Keyword if          ${status} == False    Append To List     ${RDCountersIssues}    ${status}
    END

    FOR        ${i}    IN      @{RDCountersIssues}
        Run Keyword if     ${i} == False          Fail    R&D Counter issues
    END



Get Remote Interference Alarm

    [Arguments]
    ...                     ${alarm_id}=7115
    ...                     ${fault_id}=${None}
    ...                     ${info}=${None}
    ...                     ${list_cell}=${None}

    FOR    ${position}    IN    @{list_cell}
        ${internal_pos}=                  Evaluate    ${position}-1
        ${victim_cell}=                   Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
        ${current_nrcell}=                Set Variable    NRCELL-${victim_cell}
        # [7115][7525](Minor) b'BASE STATION INFORMATION'             :b'Remote interference detected'
        Get Active Alarm And Check Specific Detection       alarm_id=${alarm_id}
        ...                                                 fault_id=${fault_id}
        ...                                                 alarm_object=${current_nrcell}
        ...                                                 suppl_alarm_info=${info}
    END



Get Active Alarm And Check Specific Detection
    [Arguments]
    ...                     ${alarm_id}
    ...                     ${fault_id}=${None}
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_alarm_info}=${None}
    ...                     ${iteration_max}=150

    Dated Log                         ----Get Active Alarm And Check Specific Detection----
    FOR    ${iteration}    IN RANGE    1    ${iteration_max} + 1
        Dated Log New Line            > detection alarm [${alarm_id}][${fault_id}] on object=${alarm_object} (${iteration}/${iteration_max})
        Dated Log                     > and containing the supplementary information if not none: ${suppl_alarm_info}

        ${alarm_information}=         Detection Alarm Id    alarm_id=${alarm_id}    fault_id=${fault_id}    alarm_object=${alarm_object}
        ...                           confirm_presence=${True}    suppl_info=${suppl_alarm_info}
        #DEBUG_LOG#Dated Log          >> alarm_information= ${alarm_information}

        Exit For Loop If              "${alarm_information}" != "${None}"
    END
    # Alarm must be found after ${iteration} attempts

    ${status}=        run keyword and return status       Should Be True    "${alarm_information}" != "${None}"

    Run Keyword If    ${status} == False          Fail    Issue to get Alarm ${fault_id}


Detection Alarm Id
    [Arguments]             ${alarm_id}=7101
    ...                     ${fault_id}=4383
    ...                     ${alarm_object}=${None}
    ...                     ${suppl_info}=${None}
    ...                     ${oam_type}=${GNB_DU.oam}
    ...                     ${confirm_presence}=${True}

    #DEBUG_LOG#Dated Log New Line     ----Detection Alarm----
    @{alarms}=                        OAM Get Active Alarms    oam=${oam_type}
    ${flag_alarm_id}=                 Set Variable    ${False}
    ${i}=                             Set Variable    ${0}
    FOR    ${alarm}    IN    @{alarms}
        ${i}=                         Evaluate    ${i}+${1}
        ${result}=                    Replace String    ${alarm}    ]    [
        @{alarm_words}=               Split String    ${result}    separator=[
        Remove Values From List       ${alarm_words}    ${EMPTY}
        Remove Values From List       ${alarm_words}    ${SPACE}
        ${flag_alarm_id}=    Run Keyword If    ${alarm_words[0]} == ${alarm_id}     Set Variable    ${True}     ELSE    Set Variable    ${False}
        ${flag_fault_id}=             Run Keyword If    ${alarm_words[1]} == ${fault_id} or "${fault_id}" == "${None}"    Set Variable    ${True}
        ...                                       ELSE    Set Variable    ${False}
        #DEBUG_LOG#Dated Log          >> alarm_words_object= ${alarm_words}
        ${is_object_present}=         Run Keyword And Return Status    Should Contain    ${alarm_words[3]}    ${alarm_object}
        ${flag_alarm_object}=         Run Keyword If    ${is_object_present} or "${alarm_object}" == "${None}"    Set Variable    ${True}
        ...                                       ELSE    Set Variable    ${False}
        ${is_suppl_present}=          Run Keyword And Return Status    Should Contain    ${alarm_words[4]}    ${suppl_info}
        ${flag_alarm_suppl}=          Run Keyword If    ${is_suppl_present} or "${suppl_info}" == "${None}"    Set Variable    ${True}
        ...                                       ELSE    Set Variable    ${False}
        #DEBUG_LOG#Dated Log          >> alarm_words_4= ${alarm_words[4]} suppl_info= ${suppl_info} <=> is_suppl_present= ${is_suppl_present}
        Exit For Loop If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
    END
    ${iteration_alarm}=    Run Keyword If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}
    ...                                        Set Variable    ${alarm}
    ...                                ELSE    Set Variable    ${None}
    ${fault_id_word}=                 Run Keyword If    ${flag_fault_id} and "${fault_id}" != "${None}"    Set Variable    ${alarm_words[1]}
    ...                                           ELSE    Set Variable    ${None}
    Run Keyword If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl}    Run Keywords
    ...           Dated Log           ${cc_yellow}> Alarm [${alarm_id}] with fault [${fault_id}] is detected on object=${alarm_object} ${cc_normal}
    ...    AND    Dated Log           ${cc_yellow}> GNB_DU_OAM_ALARM[${i}]=${iteration_alarm} ${cc_normal}
    ...         ELSE    Dated Log     ${cc_green}> Alarm [${alarm_id}] with fault [${fault_id}] is NOT detected ${cc_normal}
    Run Keyword If    ${flag_alarm_id} and ${flag_fault_id} and ${flag_alarm_object} and ${flag_alarm_suppl} and ${confirm_presence}
    ...    Should Be True             "${fault_id}" == "${fault_id_word}"
    [Return]                          ${iteration_alarm}



Set Variables For Colors
    # colors definition based on Variables    ../../../../../resources/SWENG/python/Colors.py
    ${cc_green}                       Evaluate    "${GREEN}"
    ${cc_white}                       Evaluate    "${WHITE}"
    ${cc_yellow}                      Evaluate    "${YELLOW}"
    ${cc_bg_black}                    Evaluate    "${BG_BLACK}"
    ${cc_bg_yellow}                   Evaluate    "${BG_YELLOW}"
    ${cc_normal}                      Evaluate    "${NORMAL}"
    #
    Set Suite Variable                ${cc_green}
    Set Suite Variable                ${cc_white}
    Set Suite Variable                ${cc_yellow}
    Set Suite Variable                ${cc_bg_black}
    Set Suite Variable                ${cc_bg_black}
    Set Suite Variable                ${cc_normal}



clone Gnblogs Tool 11127
    [Arguments]    ${gnb_logs_dir}=${f}/gnb_logs-tool
    ${exist}    List Directory    ${f}
    Return From Keyword If    'gnb_logs-tool' in ${exist}
    dated log    =====> Installing gnb_logs-tool...
    dated log    cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git
    ${result}=   Run Process    cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git
    ...    cwd=${f}
    ...    shell=True
    ...    stdout=${f}/gnblogs_install_result.txt
    Run Process    unzip ${gnb_logs_dir}/gnb_logs.zip -d ${gnb_logs_dir}
    ...    shell=True
    Run Process    chmod 774 ${gnb_logs_dir}/gnb_logs/gnb_logs
    ...    shell=True
    dated log     clone Gnblogs Tool completed



Start collect log by gnb tool 11127
    [Arguments]    ${command}=./gnb_logs 192.168.255.1 -E -f0
    set Test Variable     ${gnb_logs_started}    ${True}
    ${exist}    List Directory    ${f}
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}/gnb_logs-tool ${f}/gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm ${f}/gnb_logs-tool/gnb_logs/stop_mon.log
    OperatingSystem.Run    rm ${f}/gnb_logs-tool/gnb_logs/*.zip
    ssh.Connect To    127.0.0.1    ute    ute    alias=bsh
    ssh.Execute    chmod 777 ${f}/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    ssh.Send Command    cd ${f}/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    ssh.Read Output Until    (Q)uit    connection=bsh



Stop collect log by gnb tool 11127
#    Wait '${time}' for stability
    set Test Variable     ${gnb_logs_started}    ${False}
    OperatingSystem.Run    touch ${f}/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    300    10    file should contain
    ...    ${f}/gnb_logs-tool/gnb_logs/tool.log    Tool finished running
    OperatingSystem.Run    cp ${f}/gnb_logs-tool/gnb_logs/*.zip ${LOG_PATH}



Decrease SINR TO Trigger TransformPrecoder Enabled
    [Documentation]             This KW is used to generate cell noise at Airphone ABIO through a WTS command
    ...                         For AP ABIO, no more need to modify const_customizer.conf file at AP
    ...                         This Test mode will generate noise for Pusch Pucch Srs and Prach
    ...                         leading to decrease ul_sinr
    ...                         Once ul_sinr is 'THRESHOLD_ENABLING_TRANSCODER' times consecutive lower than
    ...                         the threshold 'ulTransPrecodeOnSinrThresh'..... TransformPrecoder is enabled at gNB.

    [Arguments]    ${pathloss}=120   ${profile_id}=1    ${ue_id}=1

    wtsemu.ul_sinr_testmode_nr    profile_id=${profile_id}    pathloss=${pathloss}
    ${console_msg1}        Evaluate     "sending egate command --> ul_sinr_testmode_nr profile_id=${profile_id}"
    ${console_msg2}        Evaluate     "pathloss=${pathloss}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}
    wtsemu.ue_testmode_set_nr    id=${ue_id}    testmode=ul_sinr   action=activate    profile_id=${profile_id}
    ${console_msg1}        Evaluate     "sending egate command --> ue_testmode_set_nr id=${ue_id}"
    ${console_msg2}        Evaluate     "testmode=ul_sinr action=activate profile_id=${profile_id}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}

    ${output}             wtsemu.read_wtsemu_output_until    timeout=30    expected=transformPrecoder enabled
    Log to Console        ${output}
    Sleep                 2s



Increase SINR TO Trigger TransformPrecoder Disabled

    [Arguments]            ${profile_id}=1    ${ue_id}=1

    wtsemu.ue_testmode_set_nr    id=${ue_id}    testmode=ul_sinr   action=deactivate    profile_id=${profile_id}
    ${console_msg1}        Evaluate     "sending egate command --> ue_testmode_set_nr id=${ue_id}"
    ${console_msg2}        Evaluate     "testmode=ul_sinr action=deactivate profile_id=${profile_id}"
    ${console_msg}         Catenate     ${console_msg1}    ${console_msg2}
    Dated Log             ${console_msg}

    ${output}             wtsemu.read_wtsemu_output_until    timeout=30    expected=transformPrecoder disabled
    Log to Console        ${output}
    Sleep                 2s
