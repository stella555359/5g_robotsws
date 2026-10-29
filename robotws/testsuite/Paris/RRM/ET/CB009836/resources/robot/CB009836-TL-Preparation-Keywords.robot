*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB009836-TL-Preparation-Keywords.robot
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 04-18-2024
...               Modified Date               : 04-18-2024
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       04-18-2024    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library      taf.transport.ssh                                   WITH NAME          ssh
Library      taf.sbts.oam.coam.admin.interface
Library      taf.sbts.oam.coam.admin                             WITH NAME          coam
Library      taf.collectors.pmcounters                           WITH NAME          tafpmcounters
Library      taf.collectors.tcpdump                              WITH NAME          tcpdump
Library      taf.collectors.core                                 WITH NAME          core
Library      ute_wtssim
Library      taf.config.wts                                      WITH NAME          wts_cfg
Library      ta_emss
Library      ta_messaging
Library      re
Library      XML    True
Library      json
Library      ute_admin_infomodel

# Libraries SWENG
Library      ../../../../../resources/SWENG/python/StringTool.py
Library      ../../../../../resources/SWENG/python/ScfVendorOperations.py

# Libraries ET
Library      ../../../resources/python/linux_cmds.py
Library      ../../../resources/common/TtiTrace/python/ttitrace.py     WITH NAME          nps_ttitraces_tools
Library      ../../../resources/DSS/python/robot_extension.py          WITH NAME          robot_extension

# Libraries CB009836
Library      ../python/Constants-CB009836.py                           WITH NAME          MyConstants
Library      ../python/Dev_lib.py
Library      ../python/avg_dl_data.py
Library      ../python/avg_ul_data.py
Library      ../python/tools.py                                        WITH NAME          nps_9836_tools
Library      ../python/CB009836-lib.py
Library      ../python/tti_analyzer_framework/set_pandas.py            WITH NAME          set_pandas
Library      ../python/tti_analyzer_framework/tti_dataframe.py         WITH NAME          tti_dataframe
Library      ../python/tti_analysis/check_nack.py
Library      ../python/tti_analysis/check_ul_dtx_crc.py
Library      ../python/file.py
Library      ../python/set_ta_ssh_telnet.py                            WITH NAME          set_ta_ssh_telnet
Library      ../python/set_ta_xml.py                                   WITH NAME          set_ta_xml
Library      ../python/csirs_checker.py                                WITH NAME          csirs_checker
Library      ../python/trs_checker.py                                  WITH NAME          trs_checker
Library      ../python/l1l2_pcap_analyzer_framework/pcap_dataframe.py  WITH NAME          pcap_dataframe

# Resources SWENG
Resource      ../../../../../resources/SWENG/robot/GenericTest.robot
Resource      ../../../../../resources/SWENG/robot/Counters.robot
Resource      ../../../../../resources/SWENG/robot/SetConfig.robot
Resource      ../../../../../resources/SWENG/robot/Setup.robot
Resource      ../../../../../resources/SWENG/robot/CallSetup.robot
Resource      ../../../../../resources/SWENG/robot/Capture.robot
Resource      ../../../../../resources/SWENG/robot/Traffic.robot
Resource      ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource      ../../../../../resources/SWENG/robot/Oam.robot
Resource      ../../../../../resources/SWENG/robot/Tools.robot
Resource      ../../../../../resources/SWENG/robot/Restart.robot
Resource      ../../../../../resources/SWENG/robot/Scf.robot
Resource      ../../../../../resources/SWENG/robot/Container.robot
Resource      ../../../../../resources/SWENG/robot/Sherpa.robot
Resource      ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource      ../../../../../resources/SWENG/robot/WtsXmlConfig.robot

# Resources
Resource     ../../../resources/common/TtiTrace/ttitrace.robot

# Resources CB009836
Resource     btslog.robot
Resource     apUDPlog.robot
Resource     DedicatedXmlConfig.robot
Resource     CB009836-Ue-Commands.robot
Resource     CB009836-Keywords.robot

Variables    ../python/Constants-CB009836.py

*** Variables ***

${f}    /home/ute/
${path_config_custom}                    ${CURDIR}/../config/custom
${block_cell4_delta_file}                ${path_config_custom}/Delta_Configuration_9836-scf_MRBTS-1_Lock_Cell4.json
${block_cell5_6_7_8_delta_file}          ${path_config_custom}/Delta_Configuration_9836-scf_MRBTS-1_Lock_Cell5_6_7_8.json
${update_cipher_delta_file}              ${path_config_custom}/Delta_Configuration_9836-scf_MRBTS-1_update_cipher.json
${Cells_delta_file}                      ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_Update_4Cells.json
${3Cells_delta_file}                     ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_Update_3Cells.json
${6Cells_delta_file}                     ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_Update_6Cells.json
# CS : 09/01/25 : FS Canada is not supported anymore (see CNI-143799 - Phase out of CNI-110347) => change to FS TddLte_3
# ${cfg_file_4Cells}                       basic_setup_TDD_4cells_TddLte_3_Canada.cfg
${cfg_file_4Cells}                       basic_setup_TDD_4cells_TddLte_3.cfg
# ${cfg_file_6Cells}                       basic_setup_TDD_6cells.cfg
${cfg_file_6Cells}                       basic_setup_TDD_6cells_TddLte_3_Canada.cfg
${cfg_file_3Cells_TDD_3Cells_FDD}        basic_setup_TDD_3cells_FDD_3cells_TddLte_3_Canada.cfg
${cfg_file_4Cells_TDD_4Cells_FDD}        basic_setup_TDD_4cells_FDD_4cells_TddLte_3_Canada.cfg
${iphy_file_4Cells}                      ${path_config_custom}/CLOUD_5G_O_E_AP_LOO_8DL8UL/ap_iphy_TDD_4cells_8DL8UL_ASOE_CB008941.xml
${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO}  ${path_config_custom}/CLOUD_5G_O_E_AP_LOO/ap_iphy_TDD_6cells_8DL8UL_ASOE_CB008941.xml
${iphy_file_8Cells_VARIANT_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD}
...  ${path_config_custom}/CLOUD_5G_O_E_AP_LOO/ap_iphy_CLOUD_5G_O_E_AP_LOO_VARIANT_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD_CB008941.xml
${iphy_file_8Cells}                      ${path_config_custom}/CLOUD_5G_O_E_AP_LOO/ap_iphy_TDD_8cells_8DL8UL_ASOE_CB008941.xml
${iphy_file_6Cells}                      ${path_config_custom}/CLOUD_5G_I_MP_AP_LOOO/ap_iphy_TDD_6cells_8DL8UL_ABIP_CB008941.xml
${iphy_file_6Cells_wo_ul_feature}        ${path_config_custom}/CLOUD_5G_I_MP_AP_LOOO/ap_iphy_TDD_6cells_8DL8UL_ABIP_CB008941_wo_ulfearures.xml
${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_100_TddFrameStructure_TdLte_3_Canada.json
${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_80_TddFrameStructure_TdLte_3_Canada.json
${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_RJIO_52}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_80_TddFrameStructure_TdLte_3_Canada_RJIO_52.json
${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_BwpDN_9}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_80_TddFrameStructure_TdLte_3_Canada_bwpDN_9.json
# PROFILE-44 alread used => change with  PROFILE-7 ert PROFILE-77
${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_ABIP}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_80_TddFrameStructure_TdLte_3_Canada_ABIP.json
${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_60_TddFrameStructure_TdLte_3_Canada.json
${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_100_TddFrameStructure_SemiStatic_1_4.json
${PDCCHProfile_BW15_TdLte_3_Canada_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_15_TddFrameStructure_TdLte_3_Canada.json
${PDCCHProfile_BW15_TdLte_3_Canada_delta_file_RJIO_52}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_15_TddFrameStructure_TdLte_3_Canada_RJIO_52.json
${PDCCHProfile_BW15_TdLte_3_Canada_9836_Off_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_15_TddFrameStructure_TdLte_3_Canada_9836_Off.json
${PDCCHProfile_BW10_TdLte_3_Canada_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_10_TddFrameStructure_TdLte_3_Canada.json
${PDCCHProfile_BW10_TdLte_3_Canada_9836_Off_delta_file}
...         ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_PDCCHProfile_BW_10_TddFrameStructure_TdLte_3_Canada_9836_Off.json

# subSector case with AZQJ Simulated RU
${Cells_delta_file_w_2_SubSector}        ${path_config_custom}/Delta_Configuration_scf_MRBTS-1_Update_4Cells_w_2-SubSector.json
${iphy_file_4Cells_AZQJ}                 ${path_config_custom}/CLOUD_5G_O_E_AP_LOO_8DL8UL/ap_iphy_TDD_4cells_8DL8UL_ASOE_CB008941_AZQJ.xml
${scf_file_startup_for_2_SubSectors}
...    ${path_config_custom}/CLOUD_5G_O_E_AP_LOO_8DL8UL/Configuration_scf_MRBTS-1-2_subsectors_4T2R_1_CHANNELGROUP_w_8Tx_8Rx-4Cells-RU-AZQL_ASOE.xml

${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}                ${path_config_custom}/Delta_Configuration_actAdaptiveReTxResMcs_4_Cells.json
${Cells_delta_file_actAdaptiveReTxResMcs_3_Cells}                ${path_config_custom}/Delta_Configuration_actAdaptiveReTxResMcs_3_Cells.json

*** Keywords ***

# ------------------------------------------------------------------------------------------------------------------------------------

SCF Enable CB009836 8DL 8UL 4Cells CFG 1
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
                    BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 4Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 8DL8UL nrCellType    CellId=2
    Modify Channels to support 8DL8UL nrCellType    CellId=3
    Modify Channels to support 8DL8UL nrCellType    CellId=4
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 8DL 8UL 3Cells CFG 1
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
                    BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 3Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify_3cells.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 8DL8UL nrCellType    CellId=2
    Modify Channels to support 8DL8UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 8DL 8UL 4Cells with subSector
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 4Cells with subSector
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    # Modify Channels to support 8DL8UL nrCellType    CellId=1
    # Modify Channels to support 8DL8UL nrCellType    CellId=2
    # Modify Channels to support 8DL8UL nrCellType    CellId=3
    # Modify Channels to support 8DL8UL nrCellType    CellId=4
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 4DL 4UL 4Cells CFG 1
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        4x100MHz 2DL-2UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   4DL-4UL 4Cells BeamSet_1
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_1_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_BeamSet_1}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_BeamSet_1}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_2DL_2UL_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 8DL 8UL 6Cells 8DL8UL
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 6Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify_6Cells.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove_6CELLS}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD_6CELLS}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_6CELLS}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_6CELLS}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD_6CELLS}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD_6CELLS}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD_6CELLS}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 8DL8UL nrCellType    CellId=2
    Modify Channels to support 8DL8UL nrCellType    CellId=3
    Modify Channels to support 8DL8UL nrCellType    CellId=4
    Modify Channels to support 8DL8UL nrCellType    CellId=5
    Modify Channels to support 8DL8UL nrCellType    CellId=6
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 8DL 8UL 6Cells 8DL8UL woBSR
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 6Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify_6Cells.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove_6CELLS}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD_6CELLS}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD_6CELLS}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_6CELLS}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_6CELLS_woBSR}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD_6CELLS}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE_6CELLS}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD_6CELLS}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD_6CELLS}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD_6CELLS}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD_6CELLS}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 8DL8UL nrCellType    CellId=2
    Modify Channels to support 8DL8UL nrCellType    CellId=3
    Modify Channels to support 8DL8UL nrCellType    CellId=4
    Modify Channels to support 8DL8UL nrCellType    CellId=5
    Modify Channels to support 8DL8UL nrCellType    CellId=6
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 4DL 2UL 2_SubSector 4Cells woBSR
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   4DL-2UL 4Cells BeamSet_2SS
    ${FullbtsName}=            set Variable   CB0009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_BeamSet_2SS_woBSR}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_SS_4_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_4_2_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # Modify Channels to support 8DL8UL nrCellType    CellId=1
    # Modify Channels to support 8DL8UL nrCellType    CellId=2
    # Modify Channels to support 8DL8UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB011028 CB006915 CFG 1_woBSR
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   DL CL MIMO 8DL-8UL 4Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB011028 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_woBSR}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
    #     Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    # END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # Modify Channels to support 8DL8UL nrCellType    CellId=1
    # Modify Channels to support 8DL8UL nrCellType    CellId=2
    # Modify Channels to support 8DL8UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB011028 CB006915 CFG 1_woBSR_wPSBWP
    [documentation]
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   DL CL MIMO 8DL-8UL 4Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB011028 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_woBSR}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
    #     Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    # END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE_wPSBWP}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # Modify Channels to support 8DL8UL nrCellType    CellId=1
    # Modify Channels to support 8DL8UL nrCellType    CellId=2
    # Modify Channels to support 8DL8UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 CB006915 CFG 4
    [documentation]
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   DL CL MIMO 8DL-4UL 3Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    # FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
    #     Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    # END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL4UL nrCellType    CellId=1
    Modify Channels to support 8DL4UL nrCellType    CellId=2
    Modify Channels to support 8DL4UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB011028 CB006915 CFG 4_woBSR
    [documentation]
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-4UL 3Cells BeamSet_6
    ${FullbtsName}=            set Variable   CB011028 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_woBSR}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    # FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
    #     Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    # END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL4UL nrCellType    CellId=1
    Modify Channels to support 8DL4UL nrCellType    CellId=2
    Modify Channels to support 8DL4UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 CB006915 CFG 6
    [documentation]   GNB is configured with profile::
    ...              FG#6	"Three cells are configured and setup as the below order
    ...              1x100MHz 8DL-8UL streams NR TDD FR1 BF cell (with any TDD eCPRI 64T64R radio)
    ...              1x100MHz 4DL-4UL streams NR TDD FR1 BF cell (with any TDD eCPRI 32T32R radio)
    ...              1x100MHz 8DL-4UL streams NR TDD FR1 BF cell (with any TDD eCPRI 64T64R radio)
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 1Cell - 4DL-4UL 1Cell - 8DL-4UL 1 Cell - BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD_CFG6}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_CFG_6_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    # FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
    #     Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    # END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 4DL4UL nrCellType    CellId=2
    Modify Channels to support 8DL4UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 CB006915 CFG 10
    [documentation]
    ...               CB006915-N#1 CFG#10
    ...               CFG#10	"Three cells are configured
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8DL-8UL 2Cells 4DL-4UL 1Cell BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_4_4_CFG10_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # remove and/or disable some NIDD param for CELL3 (4DL4UL cellType)
    # NDM-SRS related features on the last cell shall be disabled (fault 5512:EFaultId_SrsResourcesNotConfigurableAl)
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL3}   p_name=actDlMuMimoEnh    value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL3}   p_name=actDlSrsBm        value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL3}   p_name=actUlMuMimo       value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL3}   p_name=actUlSrsBm        value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL3}   p_name=dlMimoMode        value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_CFG10}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_CFG10}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{periodicCsiAcquisition_LIST_NAME_PARAMS_TO_Add_CFG10}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL8UL nrCellType    CellId=1
    Modify Channels to support 8DL8UL nrCellType    CellId=2
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

SCF Enable CB009836 CB006915 CFG 12
    [documentation]
    ...               CB006915-N#1 CFG#12
    ...               CFG#12	"Three cells are configured
    ...                        1x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   4DL-4UL 1Cell 8DL-4UL 1Cell 8DL-8UL 1Cell BeamSet_6
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    scf.load scf    ${input_scf}
    ${SCF_version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}      version
    set global Variable    ${SCF_version}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
         ${result}    scf.is_object_in_scf    dist_name=${item}[dist_name]
         run keyword if    ${result}==True    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    FOR    ${item}    IN    @{NRLIM_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRLIM_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE_ASOE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_8_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_4_4_CFG12_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_CFG12_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRDLMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_PARAMS_TO_ADD}
        scf.add object to scf  class_name=${item}[class_name]
        ...                    dist_name=${item}[dist_name]
        ...                    version=${item}[version]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_ELEMENTS_PARAMS_TO_ADD}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{NRULMUMIMO_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    # remove and/or disable some NIDD param for CELL3 (4DL4UL cellType)
    # NDM-SRS related features on the last cell shall be disabled (fault 5512:EFaultId_SrsResourcesNotConfigurableAl)
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL1}   p_name=actDlMuMimoEnh    value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL1}   p_name=actDlSrsBm        value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL1}   p_name=actUlMuMimo       value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL1}   p_name=actUlSrsBm        value=false
    Set Element    dist_name=${MR_NR_CELL_NAME_CELL1}   p_name=dlMimoMode        value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_CFG12}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD_CFG12}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{periodicCsiAcquisition_LIST_NAME_PARAMS_TO_Add_CFG12}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    Modify Channels to support 8DL4UL nrCellType    CellId=2
    Modify Channels to support 8DL8UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}


SCF Enable CB009836 MicroDtx
    [Arguments]    ${input_scf}    ${output_scf}   ${btsName}=${Host Name}
    IF    '${btsName}'!='${EMPTY}'
        BuiltIn.log     btsName is ${btsName}
    END
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${PartOfBtsName}=          set Variable   8x4 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=            set Variable   CB009836 - ${testline_name} - ${PartOfBtsName}
    set global Variable    ${SCF_btsName}   ${FullbtsName[0:78]}
    import variables    ${CURDIR}/../python/CB009836_nidd_modify.py
    scf.load scf    ${input_scf}
    FOR    ${item}    IN    @{Beamset_LIST_NAME_PARAMS_TO_Remove}
        ${list_exist}=            scf.is_list_in_object     dist_name=${item}[dist_name]         list_name=${item}[list_name]
        Run Keyword IF            ${list_exist}
        ...                       scf.remove list from scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_ELEMENT_PARAMS_TO_ADD}
        Set Element     dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR    ${item}    IN    @{CB009836_LIST_NAME_PARAMS_TO_ADD}
        Set List     dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ITEMS_PARAMS_TO_ADD}
        Set Item To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR    ${item}    IN    @{CB009836_LIST_ELEMENTS_PARAMS_TO_ADD}
         Set Element To List      dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_BF_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_9890_BASE_MICRODTX}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_DL_MIMO_8_4_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    FOR   ${item}    IN    @{MODIFY_SCF_PAGING_BASE}
        Set Element    dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    Modify Channels to support 8DL4UL nrCellType    CellId=1
    Modify Channels to support 8DL4UL nrCellType    CellId=2
    Modify Channels to support 8DL4UL nrCellType    CellId=3
    scf.save scf    ${output_scf}
    [Return]     ${output_scf}

TL_Preparation_CB009836_SCF_CB006915_CFG_1
    [documentation]   GNB is configured :
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured on each BB board"
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   CB009836 8x8 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB009836 CB006915 CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_1 Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

TL_Preparation_CB009836_SCF_CB006915_CFG_1_woBSR_wRIMRs_4Cells
    [documentation]   GNB is configured :
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured on each BB board"
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   CB011028 8DL-8UL BeamSet_6 4Cells
    ${FullbtsName}=      set Variable   CB011028 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB011028.xml
    ${scf_update_11028}    SCF Enable CB011028 CB006915 CFG 1_woBSR    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_1_woBSR_wRIMRs_4Cells Kw : SCF To commit ${scf_update_11028}
    set suite variable     ${test_scf_file}   ${scf_update_11028}
    [Return]     ${scf_update_11028}

TL_Preparation_CB011028_SCF_CB006915_CFG_1_4Cells_woBSR_wRIMRs
    [documentation]   GNB is configured :
    ...               CB006915-N#1 CFG#1
    ...               CFG#1	"Three cells are configured on each BB board"
    ...                        3x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    # first add RIMRS obj if not present
    # Check if RIMRS is already enabled. Otherwise, adding RIMRS structures will fail
    # as they are already there.
    ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actNrRim
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actNrRim flag is set to ${is_rimrs_enabled}

    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${rimrs_delta_file_4cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actNrRim_activate_delta_file_4cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=actNrRim
    # ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    # ...                           connection=coam_gnb
    # Run Keyword If                '${is_rimrs_enabled}'=='framework-0'           Run Keywords
    # ...                           coam_parameter.perform_scf_delta_commission
    # ...                           delta_file=${Cell2_numRbForRs_96_delta_file}
    # ...                           connection=coam_gnb
    # Wait end of commissioning
    # ...                           AND
    # ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   CB011028 8DL-8UL BeamSet_6 4Cells
    ${FullbtsName}=      set Variable   CB011028 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB011028.xml
    ${scf_update_11028}    SCF Enable CB011028 CB006915 CFG 1_woBSR    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_1_woBSR_wRIMRs_4Cells Kw : SCF To commit ${scf_update_11028}
    set suite variable     ${test_scf_file}   ${scf_update_11028}
    [Return]     ${scf_update_11028}

gNB_ModifyBtsName_TO_REMOVE
    [Arguments]    ${json_path}    ${btsname_original}=btsNameToChange     ${btsname_new}=btsNameToChange
    run    command=sed -i 's|${btsname_original}|${btsname_new}|g' ${json_path}

TL_Preparation_CB009836_3Cells_CFG1_8DL_8UL_withTopo4Cells
    [documentation]   GNB is configured :
    ...                        2x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...    Run Keywords    Dated log   default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO}]
    ...         AND        Dated log             Begin of TL preparation...
    ...         AND        OperatingSystem.Run         cp -p ${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO} /tmp/${iphy_filename}
    ...         AND        taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...         AND        taf.ul.ue.sim.env_setup.Configure Environment
    ...         AND        Dated log             End of TL preparation
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell4_delta_file} ${LOG_PATH}/block_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/block_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell4 if needed
    # Check if cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-4
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-4 is set to ${rmod_adminstate}
    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/block_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_3_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_3_Cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 8DL 8UL 4Cells CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_3Cells_CFG1_8DL_8UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell5_6_7_8_delta_file} ${LOG_PATH}/block_cell5_6_7_8_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/block_cell5_6_7_8_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell5, 6, 7 and 8 if needed
    # Check if cell5 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-5
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-5 is set to ${rmod_adminstate}
    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/block_cell5_6_7_8_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL
    [documentation]   GNB is configured :
    ...                        4x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    dated log     TOPOLOGY_LABEL is ${TOPOLOGY_LABEL}
    dated log     TOPOLOGY_VARIANT is ${TOPOLOGY_VARIANT}
    IF      '${TOPOLOGY_LABEL}'=='CLOUD_5G_O_E_AP_LOO' and '${TOPOLOGY_VARIANT}'=='SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD'
        ${iphy_file_to_use}=    Set Variable   ${iphy_file_8Cells_VARIANT_SANSA_FS_CPRI_CMWV_FDD_ECPRI_CMWV_TDD}
    ELSE IF    ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'
       ${iphy_file_to_use}=    Set Variable    ${iphy_file_8Cells}
    ELSE
        ${iphy_file_to_use}=   Set Variable    ${iphy_file_4Cells}
    END
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    # Run Keyword if
    #   '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    # ...        Run Keywords     Dated log          default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_to_use}]
    # ...                          AND          Dated log          Begin of TL preparation...
    # ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_to_use} /tmp/${iphy_filename}
    # ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    # ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    # ...                          AND          OperatingSystem.Run         cp -p ${LOG_PATH}/MODIFIED_${iphy_filename} /tmp/${iphy_filename}
    # ...                          AND          Dated log             End of TL preparation
    IF  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
        Dated log          default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_to_use}]
        Dated log          Begin of TL preparation...
        OperatingSystem.Run         cp -p ${iphy_file_to_use} /tmp/${iphy_filename}
        taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
        ${status}     Run Keyword and ignore error  Run Keyword    taf.ul.ue.sim.env_setup.Configure Environment
        IF  '${status[${0}]}'=='FAIL'
             BuiltIn.log    taf.ul.ue.sim.env_setup.Add Simulator FAILED!!!   level=ERROR
             Log to console  taf.ul.ue.sim.env_setup.Add Simulator failed, trying copy custom iphy file from /tmp/${iphy_filename}
             Setup.copy custom iphy file     file=/tmp/${iphy_filename}
             Dated log      copy custom iphy file [${iphy_filename}]
        ELSE
             OperatingSystem.Run   cp -p ${LOG_PATH}/MODIFIED_${iphy_filename} /tmp/${iphy_filename}
        END
        Dated log             End of TL preparation
    END
    ${num_of_cells}=    Get Cell Number
    # if topo CLOUD_5G_O_E_AP_LOO and VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD is used
    # need to Lock last FDD 4 Cells
    Run Keyword If  ${num_of_cells} > ${4}     Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 4 and 44 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 4 and 44 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 9 and 99 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 9 and 99 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_BwpDN_9}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 7 and 77 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 7 and 77 - TdLte 3 ms Bell Canada - BW 15Mhz - 9836 On
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW15_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 700 and 701 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 700 and 701 - TdLte 3 ms Bell Canada - BW 15Mhz - 9836 Off
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-700/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-700/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW15_TdLte_3_Canada_9836_Off_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 8 and 88 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 8 and 88 - TdLte 3 ms Bell Canada - BW 10Mhz - 9836 On
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW10_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 800 and 801 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 800 and 801 - TdLte 3 ms Bell Canada - BW 10Mhz - 9836 Off
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-800/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-800/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW10_TdLte_3_Canada_9836_Off_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 8DL 8UL 4Cells CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_4Cells_CFG1_8DL_8UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_3Cells_CFG1_8DL_8UL
    [documentation]   GNB is configured :
    ...                        4x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_6Cells_CLOUD_5G_O_E_AP_LOO}
    ...                                                                                             ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    IF  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
        Dated log          default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_to_use}]
        Dated log          Begin of TL preparation...
        OperatingSystem.Run         cp -p ${iphy_file_to_use} /tmp/${iphy_filename}
        taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
        ${status}     Run Keyword and ignore error  Run Keyword    taf.ul.ue.sim.env_setup.Configure Environment
        IF  '${status[${0}]}'=='FAIL'
             BuiltIn.log    taf.ul.ue.sim.env_setup.Add Simulator FAILED!!!   level=ERROR
             Log to console  taf.ul.ue.sim.env_setup.Add Simulator failed, trying copy custom iphy file from /tmp/${iphy_filename}
             Setup.copy custom iphy file     file=/tmp/${iphy_filename}
             Dated log      copy custom iphy file [${iphy_filename}]
        ELSE
             OperatingSystem.Run   cp -p ${LOG_PATH}/MODIFIED_${iphy_filename} /tmp/${iphy_filename}
        END
        Dated log             End of TL preparation
    END
    ${num_of_cells}=    Get Cell Number
    # if topo CLOUD_5G_O_E_AP_LOO and VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD is used
    # need to Lock last FDD 4 Cells
    # Run Keyword If  ${num_of_cells} > ${4}     Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 3Cells TDD
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${3Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${3Cells_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_3_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_3_Cells}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 4 and 44 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 4 and 44 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - TdLte 3 ms Bell Canada - BW 80Mhz - RJIO
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_RJIO_52}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 6 and 66 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 7 and 77 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 7 and 77 - TdLte 3 ms Bell Canada - BW 15Mhz - 9836 On
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW15_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 9 and 99 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 9 and 99 - TdLte 3 ms Bell Canada - BW 15Mhz - 9836 On - RJIO
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW15_TdLte_3_Canada_delta_file_RJIO_52}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 700 and 701 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 700 and 701 - TdLte 3 ms Bell Canada - BW 15Mhz - 9836 Off
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-700/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-700/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW15_TdLte_3_Canada_9836_Off_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 8 and 88 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 8 and 88 - TdLte 3 ms Bell Canada - BW 10Mhz - 9836 On
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW10_TdLte_3_Canada_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 800 and 801 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 800 and 801 - TdLte 3 ms Bell Canada - BW 10Mhz - 9836 Off
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-800/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-800/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW10_TdLte_3_Canada_9836_Off_delta_file}
    ...                           timeout=300
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL 3Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 8DL 8UL 3Cells CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_3Cells_CFG1_8DL_8UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_4Cells_CFG1_4DL_4UL
    [documentation]   GNB is configured :
    ...                        4x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    # ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...                      Run Keywords     Dated log          default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_to_use}]
    ...                          AND          Dated log          Begin of TL preparation...
    ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_to_use} /tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    ...                          AND          Dated log             End of TL preparation
    ${num_of_cells}=    Get Cell Number
    # if topo CLOUD_5G_O_E_AP_LOO and VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD is used
    # need to Lock last FDD 4 Cells
    Run Keyword If  ${num_of_cells} > ${4}     Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   4DL-4UL BeamSet_1 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 4 and 44 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 4 and 44 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   4DL-4UL BeamSet_1 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 4DL 4UL 4Cells CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_4Cells_CFG1_4DL_4UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_4Cells_CFG1_4DL_4UL_noBF
    [documentation]   GNB is configured :
    ...                        4x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${iphy_file_to_use}    Set Variable If   ${topoOK_2} and '${topoUsed}'=='CLOUD_5G_O_E_AP_LOO'   ${iphy_file_8Cells}
    ...                                                                                             ${iphy_file_4Cells}
    # ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_4Cells}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_to_use}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_to_use}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...                      Run Keywords     Dated log          default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_to_use}]
    ...                          AND          Dated log          Begin of TL preparation...
    ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_to_use} /tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    ...                          AND          Dated log             End of TL preparation
    ${iphy_file_name_4Cells_wo_BSR}     remove ulFeatures from AP file if present in /tmp     iphy_file=${iphy_file_to_use}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_file_name_4Cells_wo_BSR}
    ${text}=     Set Variable   copy custom iphy file [/tmp/${iphy_file_name_4Cells_wo_BSR}] to AirPhone
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_file_name_4Cells_wo_BSR}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_file_name_4Cells_wo_BSR}]
    ${num_of_cells}=    Get Cell Number
    # if topo CLOUD_5G_O_E_AP_LOO and VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD is used
    # need to Lock last FDD 4 Cells
    Run Keyword If  ${num_of_cells} > ${4}     Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   4DL-4UL BeamSet_1 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 4 and 44 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 4 and 44 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   4DL-4UL BeamSet_1 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 4DL 4UL 4Cells CFG 1    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_4Cells_CFG1_4DL_4UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_4Cells_4DL_2UL_w_SubSector
    [documentation]   GNB is configured :
    ...                        4x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${topoOK_1}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO_8DL8UL
    ${topoOK_2}    ${topoUsed}=    check topology used is CLOUD_5G_O_E_AP_LOO
    dated log     Topology is ${topoUsed}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_4Cells_AZQJ}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_4Cells_AZQJ}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [${iphy_filename}]
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...                      Run Keywords     Dated log    default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_4Cells_AZQJ}]
    ...                          AND          Dated log    Begin of TL preparation...
    ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_4Cells_AZQJ} /tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    ...                          AND          Dated log             End of TL preparation
    ${num_of_cells}=    Get Cell Number
    # if topo CLOUD_5G_O_E_AP_LOO and VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD is used
    # need to Lock last FDD 4 Cells
    Run Keyword If  ${num_of_cells} > ${4}     Lock_last_4_Cells
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 4Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_w_2_SubSector}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${Cells_delta_file_w_2_SubSector}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cells_delta_file_actAdaptiveReTxResMcs_4_Cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 4 and 44 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 4 and 44 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-4/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           timeout=300
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL 4Cells with subSector
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 4DL 2UL 2_SubSector 4Cells woBSR    input_scf=${current_scf_fullname}
    ...                                                               output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_4Cells_8DL_8UL_w_SubSector Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_6Cells_8DL_8UL
    [documentation]   GNB is configured :
    ...                        6x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_6Cells}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_6Cells}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                     AND           Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...                      Run Keywords     Dated log         default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_6Cells}]
    ...                          AND          Dated log         Begin of TL preparation...
    ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_6Cells} /tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    ...                          AND          Dated log         End of TL preparation
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 6Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    # OperatingSystem.Run     cp ${block_cell4_delta_file} ${LOG_PATH}/block_cell4_Cell5_Cell6_delta_file_modified.json
    # gNB_ModifyBtsName   json_path=${log_path}/block_cell4_Cell5_Cell6_delta_file_modified.json
    # ...                 btsname_original=btsNameToChange
    # ...                 btsname_new=${FullbtsName}
    # first block Cell4 if needed
    # Check if cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    # ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=administrativeState
    # ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-4
    # ...                           connection=coam_gnb

    # Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-4 is set to ${rmod_adminstate}
    # Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    # ...                           coam_parameter.perform_scf_delta_commission
    # ...                           delta_file=${log_path}/block_cell4_Cell5_Cell6_delta_file_modified.json
    # ...                           connection=coam_gnb
    ## Wait end of commissioning
    # ...                           AND
    # ...                           OAM wait available
    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    dated log       ======> perform delta commissioning with ${6Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${6Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    ${Online_Param}=     Create List    NRCELL-1:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-2:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-3:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-4:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-5:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-6:ulPtrs:actUlPtrs=false
    Dev_lib.delta_commission_parameters      ${Online_Param}
    OAM wait available     # instead of 'Cells Should Be Onair' Kw Call

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 7 and 77 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 7 and 77 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_ABIP}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 6Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 8DL 8UL 6Cells 8DL8UL   input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                               btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_6Cells_8DL_8UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_6Cells_8DL_8UL_wo_BSR
    [documentation]   GNB is configured :
    ...                        6x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]       ${output_scf}    ${log_path}=${LOG_PATH}
    ${fileExists}=    nps_9836_tools.file_exists   ${iphy_file_6Cells}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file_6Cells}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_filename}
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_filename}
    ...                                                       AND         Dated log      copy custom iphy file [/tmp/${iphy_filename}] to AirPhone
    # verify that fragmentationCapabilities is present or not in ap iphy xml file
    ${AP fragmentationCapabilities}=     is fragmentationCapabilities present in AP iphy xml file
    Run Keyword if  '${W_CUSTOMCONFIG}'=='1' and ${fileExists}==${True} and ${fileiphyExistsInTmp}==${False} and not ${AP fragmentationCapabilities}
    ...                      Run Keywords     Dated log         default_test_strategy : install AP iphy.xml file [CUSTOMCONFIG: ${iphy_file_6Cells}]
    ...                          AND          Dated log         Begin of TL preparation...
    ...                          AND          OperatingSystem.Run         cp -p ${iphy_file_6Cells} /tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Add Simulator     sim_type=airphone    config=/tmp/${iphy_filename}
    ...                          AND          taf.ul.ue.sim.env_setup.Configure Environment
    ...                          AND          Dated log         End of TL preparation

    ${iphy_file_name_6Cells_wo_BSR}     remove ulFeatures from AP file if present in /tmp     iphy_file=${iphy_file_6Cells}
    ${fileiphyExistsInTmp}=    nps_9836_tools.file_exists   /tmp/${iphy_file_name_6Cells_wo_BSR}
    ${text}=     Set Variable   copy custom iphy file [/tmp/${iphy_file_name_6Cells_wo_BSR}] to AirPhone
    Run Keyword if    ${fileiphyExistsInTmp}==${True}    Run Keywords     Setup.copy custom iphy file     file=/tmp/${iphy_file_name_6Cells_wo_BSR}
    ...                                                      AND          Dated log      ${text}

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 6Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}

    dated log       ======> perform delta commissioning with ${6Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${6Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Online_Param}=     Create List    NRCELL-1:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-2:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-3:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-4:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-5:ulPtrs:actUlPtrs=false
    ...                                 NRCELL-6:ulPtrs:actUlPtrs=false
    Dev_lib.delta_commission_parameters      ${Online_Param}
    OAM wait available     # instead of 'Cells Should Be Onair' Kw Call

    OperatingSystem.Run     cp ${update_cipher_delta_file} ${LOG_PATH}/update_cipher_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${log_path}/update_cipher_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # update cipher if needed
    # Check if cipher are already set.
    ${original_Cipher}=         Get Cipher Parameters From gNB
    ${higher_cipher}=           get_higher_value_from_dict  ${original_Cipher}
    Dated Log                  original_Cipher for MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID} is set to ${original_Cipher}
    Dated Log                  higher_cipher is ${higher_cipher}
    Run Keyword If                '${higher_cipher}'!='nea0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${log_path}/update_cipher_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    dated log       ======> perform delta commissioning with ${6Cells_delta_file}...
    Run Keywords                  coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${6Cells_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 2 and 22 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 2 and 22 - TdLte 3 ms Bell Canada
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 7 and 77 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 7 and 77 - TdLte 3 ms Bell Canada - BW 80Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW80_TdLte_3_Canada_delta_file_ABIP}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 55 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 5 and 55 - TdLte 3 ms Bell Canada - BW 60Mhz
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW60_TdLte_3_Canada_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 3 and 33 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    # PDCCH Profile 3 and 33 - 5GC001208 SemiStatic 1:4
    # PDCCH Profile 6 and 66 - 5GC001208 SemiStatic 1:4
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${PDCCHProfile_BW100_1208_SemiStatic_1_4_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL BeamSet_6 6Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9836}    SCF Enable CB009836 8DL 8UL 6Cells 8DL8UL woBSR   input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                                     btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_6Cells_8DL_8UL Kw : SCF To commit ${scf_update_9836}
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

Set OnLine maxCsirsNumber
    ${Online_Param}=     Create List    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-5:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-5:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-5:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-5:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-6:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-6:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-6:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-6:beamSet:nrBtsBeamRefinementP2=false
    Dev_lib.delta_commission_parameters      ${Online_Param}
    Dev_lib.start_to_capture_infomodel_log
    CB009836-Keywords.All Cells Should Be Onair
    Dev_lib.stop_to_capture_infomodel_log
    # OAM wait available     # instead of 'Cells Should Be Onair' Kw Call
    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}

Set OnLine maxCsirsNumber on ASOE 4 Cells
    ${Online_Param}=     Create List    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=1
    ...                                 NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=1
    ...                                 NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
    Dev_lib.delta_commission_parameters      ${Online_Param}
    # Dev_lib.start_to_capture_infomodel_log
    # CB009836-Keywords.All Cells Should Be Onair
    # Dev_lib.stop_to_capture_infomodel_log
    OAM wait available     # instead of 'Cells Should Be Onair' Kw Call
    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}

Set OnLine maxCsirsNumber on ASOE 3 Cells
    ${Online_Param}=     Create List    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-2:periodicCsiAcquisition:maxCsirsNumber=1
    ...                                 NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-2:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-3:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-3:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
    ...                                 NRCELL-4:periodicCsiAcquisition:maxCsirsNumber=4
    ...                                 NRCELL-4:periodicCsiAcquisition:csiReportPeriodicity=slots160
    ...                                 NRCELL-4:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
    ...                                 NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
    Dev_lib.delta_commission_parameters      ${Online_Param}
    # Dev_lib.start_to_capture_infomodel_log
    # CB009836-Keywords.All Cells Should Be Onair
    # Dev_lib.stop_to_capture_infomodel_log
    OAM wait available     # instead of 'Cells Should Be Onair' Kw Call
    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}

Get bwpDN Parameters From gNB
    [Arguments]      ${CellId}=1   ${listindex}=0     ${nodeType}=Classical
    BuiltIn.log     nodeType is ${nodeType}
    ${cellBwpList_params_list}    Create List    actPdcchCceFragmentControl    actUpperThrAckNackFiltering
    ...                                          actUpperThrAckNackHrFiltering    bwpDN    cellBwpId    pdcchResourcePreference
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${cellBwpList_params_list_result}    nps_9836_tools.get_feature_paramters_from_scf    ${scf_path}    ${cellBwpList_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}    cellBwpList    index=${listindex}
   [Return]    ${cellBwpList_params_list_result}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1}
    # ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_BL}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-7, BWP_PROFILE-77 and BWP_PROFILE-70)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    # ${nrRTPMMeasurementsList}=        coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=nrRTPMMeasurementsList
    # ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    # ...                           connection=coam_gnb
    # Dated Log                     nrRTPMMeasurementsList is set to ${nrRTPMMeasurementsList}

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_wo_10544
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_10544}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_10544}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-1, BWP_PROFILE-17 and BWP_PROFILE-10)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-1'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_wo_10544_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    # ${nrRTPMMeasurementsList}=        coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=nrRTPMMeasurementsList
    # ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    # ...                           connection=coam_gnb
    # Dated Log                     nrRTPMMeasurementsList is set to ${nrRTPMMeasurementsList}

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_wo_10544_Static
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_Static_wo_10544}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_Static_wo_10544}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-3, BWP_PROFILE-37 and BWP_PROFILE-30)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-3'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_Static_wo_10544_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    # ${nrRTPMMeasurementsList}=        coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=nrRTPMMeasurementsList
    # ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    # ...                           connection=coam_gnb
    # Dated Log                     nrRTPMMeasurementsList is set to ${nrRTPMMeasurementsList}

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_BLE_5_wo_10544_Static
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_BLE5_Static_wo_10544}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_BLE5_Static_wo_10544}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-103, BWP_PROFILE-137 and BWP_PROFILE-130)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-103'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_BLE5_Static_wo_10544_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    # ${nrRTPMMeasurementsList}=        coam_parameter.get_single_value_from_scf_file
    # ...                           parameter=nrRTPMMeasurementsList
    # ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    # ...                           connection=coam_gnb
    # Dated Log                     nrRTPMMeasurementsList is set to ${nrRTPMMeasurementsList}

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_2Cells_w_PSBWP_Cell1_BLE_55_BHE_0_Cell2_BLE_25_BHE_20
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1}
    # ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_BL}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell2_BLE_25_BHE_20}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available


    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-9, BWP_PROFILE-97 and BWP_PROFILE-90)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9  for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-9'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_PSBWP_BLE_25_BHE_20_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-7, BWP_PROFILE-77 and BWP_PROFILE-70)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_cell1_w_PSBWP_w_Multiple_BWP_BLE_0_BHE_55_Cell2_wo_PSBWP_wo_Multiple_BWP
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_Multiple_BWP_activate_delta_file_Cell1}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_Multiple_BWP_activate_delta_file_Cell1}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-2, BWP_PROFILE-27, BWP_PROFILE-23 and BWP_PROFILE-20)
    # PS-BWP + Multiple-BWP => BWP_PROFILE-2, BWP_PROFILE-27, BWP_PROFILE-23 and BWP_PROFILE-20
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2 for Cell1 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-2'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_Multiple_BWP_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 for Cell2 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Prepare Logs Directory Path    subdir=pdcch_profiles
    OperatingSystem.run     cp ${actPowerSavingBWP_Multiple_BWP_activate_delta_file_Cell1} ${testCaseDir}/pdcch_profiles
    OperatingSystem.run     cp ${Cell1_CellBwpListUpdate_PSBWP_Multiple_BWP_delta_file} ${testCaseDir}/pdcch_profiles
    OperatingSystem.run     cp ${Cell2_CellBwpListUpdate_delta_file} ${testCaseDir}/pdcch_profiles

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_wo_BL
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If     ${result}==${False}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If    not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    # ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1}
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_BL}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-7, BWP_PROFILE-77 and BWP_PROFILE-70)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If    '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available


    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_BLE_0_BHE_55
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if   not ${result}
    ...       dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                not ${result}         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If                '${result}'=='False'          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...         dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1}
    # ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_BL}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/
    run keyword if   not ${result}
    ...                dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8/ not PRESENT in SCF => perform Delta commission
    Run Keyword If   not ${result}           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_BLE_0_BHE_55}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-8, BWP_PROFILE-87 and BWP_PROFILE-80)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-8'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_BLE_0_BHE_55_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If                '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # NRBTS/act5gRTPM
    ${nrRTPMMeasurementsList}  catenate  SEPARATOR=
    ...    [55351 NR Dynamic BWP,
    ...    55305 NR Beamforming]
    dated log       RTPM activate and Configure nrRTPMMeasurementsList with ${nrRTPMMeasurementsList}
    ta_emss.RTPM activate
    ta_emss.Configure  [{'MOC': 'NRPMRNL', 'ID': '1', 'nrRTPMMeasurementsList': '${nrRTPMMeasurementsList}'}]

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_IWK19_4Cells_w_PSBWP_wo_BL_Cell1
    [documentation]   GNB is configured :
    ...                        2x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   IWK19
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    OperatingSystem.Run     cp ${block_cell3_cell4_delta_file} ${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    gNB_ModifyBtsName   json_path=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                 btsname_original=btsNameToChange
    ...                 btsname_new=${FullbtsName}
    # first block Cell3 and Cell4 if needed
    # Check if cell3/cell4 are already blocked. Otherwise, adding block cells will fail
    # as they are already there.
    ${rmod_adminstate}        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=administrativeState
    ...                           dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
    ...                           connection=coam_gnb

    Dated Log                     administrativeState for MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3 is set to ${rmod_adminstate}

    Run Keyword If                '${rmod_adminstate}'!='Locked'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${testCaseDir}/block_cell3_cell4_delta_file_modified.json
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # Check if PDCCH Profile 5 and 57 for Cell1 are already present. Otherwise, adding these profiles will fail
    # as they are already there.
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/
    run keyword if    not ${result}
    ...                  dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-5/ not PRESENT in SCF => perform Delta commission
    Run Keyword If    not ${result}         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    Run Keyword If                ${result}==False          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/
    run keyword if    not ${result}
    ...                   dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6/ not PRESENT in SCF => perform Delta commission

    Run Keyword If                not ${result}          Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_PDCCHProfile_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    run keyword if    '${is_actPowerSavingBWP_enabled}'=='false'
    ...                      dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7/ not PRESENT in SCF => perform Delta commission
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_Cell1_wo_BL}
    ...                           timeout=180s
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell1 already done (cell1 should use BWP_PROFILE-7, BWP_PROFILE-77 and BWP_PROFILE-70)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-7'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_CellBwpListUpdate_PSBWP_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    # add check if CellBwpListUpdate for cell2 already done (cell2 should use BWP_PROFILE-6, BWP_PROFILE-67)
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    run Keyword if     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'
    ...       dated log    bwpDN not egal to MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6 => perform Delta commission
    Run Keyword If     '${cellBwpList_params_list['bwpDN']}'!='MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/BWP_PROFILE-6'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_CellBwpListUpdate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${actLongPucchResourceOpt}=        coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actLongPucchResourceOpt
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actLongPucchResourceOpt flag is set to ${actLongPucchResourceOpt}
    run keyword if    '${actLongPucchResourceOpt}'=='false'   dated log    => perform Delta commission to activate actLongPucchResourceOpt

    Run Keyword If                '${actLongPucchResourceOpt}'=='false'         Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell1_Cell2_actLongPucchResourceOpt_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${scf_update_9836}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    set suite variable     ${test_scf_file}   ${scf_update_9836}
    [Return]     ${scf_update_9836}

TL_Preparation_CB009836_SCF_CB006915_CFG_4
    [documentation]   GNB is configured with profile:
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    BuiltIn.log    output_scf=${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8x4 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB009836 CB006915 CFG 4    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_4 Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

TL_Preparation_CB009836_SCF_CB006915_CFG_4_woBSR
    [documentation]   GNB is configured with profile:
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8x4 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB011018 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB011028 CB006915 CFG 4_woBSR    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_4_woBSR Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

TL_Preparation_CB011028_SCF_CFG_4_woBSR_wRIMRs
    [documentation]   GNB is configured with profile:
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    # first add RIMRS obj if not present
    # Check if RIMRS is already enabled. Otherwise, adding RIMRS structures will fail
    # as they are already there.
    ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actNrRim
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actNrRim flag is set to ${is_rimrs_enabled}

    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${rimrs_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actNrRim_activate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actNrRim
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Run Keyword If                '${is_rimrs_enabled}'=='framework-0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_numRbForRs_96_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8x4 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB011018 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB011028.xml
    ${scf_update_11028}    SCF Enable CB011028 CB006915 CFG 4_woBSR    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB011028_SCF_CFG_4_woBSR_wRIMRs Kw : SCF To commit ${scf_update_11028}
    set suite variable     ${test_scf_file}   ${scf_update_11028}
    [Return]     ${scf_update_11028}

TL_Preparation_CB011028_SCF_CFG_4_woBSR_wRIMRs_wPSBWP
    [documentation]   GNB is configured with profile:
    ...               CB006915-N#1 CFG#4
    ...               CFG#4	"Three cells are configured on each BB board"
    ...                         3x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    # first add RIMRS obj if not present
    # Check if RIMRS is already enabled. Otherwise, adding RIMRS structures will fail
    # as they are already there.
    ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actNrRim
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb

    Dated Log                     actNrRim flag is set to ${is_rimrs_enabled}

    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${rimrs_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available
    Run Keyword If                '${is_rimrs_enabled}'=='disabled'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actNrRim_activate_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_rimrs_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actNrRim
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Run Keyword If                '${is_rimrs_enabled}'=='framework-0'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${Cell2_numRbForRs_96_delta_file}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log                     actPowerSavingBWP flag is set to ${is_actPowerSavingBWP_enabled}
    Run Keyword If                '${is_actPowerSavingBWP_enabled}'=='false'           Run Keywords
    ...                           coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${actPowerSavingBWP_activate_delta_file_3Cells}
    ...                           connection=coam_gnb
    # Wait end of commissioning
    ...                           AND
    ...                           OAM wait available

    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8x4 CL DL MIMO BeamSet_6 3Cells
    ${FullbtsName}=      set Variable   CB011018 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB011028.xml
    ${scf_update_11028}    SCF Enable CB011028 CB006915 CFG 4_woBSR    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB011028_SCF_CFG_4_woBSR_wRIMRs_wPSBWP Kw : SCF To commit ${scf_update_11028}
    set suite variable     ${test_scf_file}   ${scf_update_11028}
    [Return]     ${scf_update_11028}

TL_Preparation_CB009836_SCF_CB006915_CFG_6
    [documentation]   GNB is configured with profile:
    ...              FG#6	"Three cells are configured and setup as the below order
    ...              1x100MHz 8DL-8UL streams NR TDD FR1 BF cell (with any TDD eCPRI 64T64R radio)
    ...              1x100MHz 4DL-4UL streams NR TDD FR1 BF cell (with any TDD eCPRI 32T32R radio)
    ...              1x100MHz 8DL-4UL streams NR TDD FR1 BF cell (with any TDD eCPRI 64T64R radio)
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8x8 1Cell - 4x4 1Cell - 8X4 1 Cell - CL DL MIMO BeamSet_6
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB009836 CB006915 CFG 6    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                         btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_6 Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

TL_Preparation_CB009836_SCF_CB006915_CFG_10
    [documentation]   GNB is configured :
    ...               CB006915-N#1 CFG#10
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   8DL-8UL 2Cells 4DL-4UL 1Cell BeamSet_6
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB009836 CB006915 CFG 10    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                          btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_10 Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

TL_Preparation_CB009836_SCF_CB006915_CFG_12
    [documentation]   GNB is configured :
    ...               CB006915-N#1 CFG#12
    ...                        1x100MHz 4DL-4UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-4UL streams NR TDD FR1 BF cell"
    ...                        1x100MHz 8DL-8UL streams NR TDD FR1 BF cell"
    [Arguments]    ${output_scf}
    ${Current_btsName}=   set Variable   ${Host Name}
    ${PartOfBtsName}=    set Variable   4DL-4UL 1Cell 8DL-4UL 1Cell 8DL-8UL 1Cell BeamSet_6
    ${FullbtsName}=      set Variable   CB009836 - ${Current_btsName} - ${PartOfBtsName}
    ${test_scf_file}           COAM Get SCF      file=SCF.xml    w_setup_admin=False   alias=coam_gnb
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    ${CsvFilename}      Remove String      ${current_scf_fullname}     .xml
    ${output_scf}       set Variable       ${CsvFilename}_modified_for_CB009836.xml
    ${scf_update_9890}    SCF Enable CB009836 CB006915 CFG 12    input_scf=${current_scf_fullname}    output_scf=${output_scf}
    ...                                                          btsName=${FullbtsName[0:78]}
    dated log   TL_Preparation_CB009836_SCF_CB006915_CFG_12 Kw : SCF To commit ${scf_update_9890}
    set suite variable     ${test_scf_file}   ${scf_update_9890}
    [Return]     ${scf_update_9890}

# ------------------------------------------------------------------------------------------------------------------------------------
# Vendor file management

Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity
    [Documentation]
    ...     Conditions:     it is based on the argument ${vendor_param}
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${vendor_param}

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
    # ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Symm
    ...                               maxNumLayerPrbL1Sp=2184
    ...                               maxNumStreamPrbL1Sp=2184
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.maxNumLayerPrbL1Sp}=         Run Keyword If    ${vendor_param.maxNumLayerPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumLayerPrbL1Sp}

    ${vendor_param.maxNumStreamPrbL1Sp}=        Run Keyword If    ${vendor_param.maxNumStreamPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumStreamPrbL1Sp}
    ${vendor_param.maxNumWbStreamPrbL1Sp}=      Run Keyword If    ${vendor_param.maxNumWbStreamPrbL1Sp} == None    Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumWbStreamPrbL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=DL
    # ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Symm
    ...                               maxNumLayerPrbL1Sp=${vendor_param.maxNumLayerPrbL1Sp}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.maxNumStreamPrbL1Sp}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.maxNumWbStreamPrbL1Sp}
    # ...                               maxNumWbStreamPrbL1Sp=1092
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    # bbPoolCapacity
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=24
    ...                               maxNumScheUePdschL1Sp=18
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40

    ${vendor_param.maxNumScheUePdschL1Pool}=    Run Keyword If    ${vendor_param.maxNumScheUePdschL1Pool} == None    Set Variable    24
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Pool}
    ${vendor_param.maxNumScheUePdschL1Sp}=      Run Keyword If    ${vendor_param.maxNumScheUePdschL1Sp} == None    Set Variable    18
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Sp}
    ${vendor_param.maxNumDlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumDlSubcellL1Pool} == None    Set Variable    6
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Pool}
    ${vendor_param.maxNumDlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumDlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Sp}
    ${vendor_param.maxNumUlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumUlSubcellL1Pool} == None    Set Variable    6
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Pool}
    ${vendor_param.maxNumUlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumUlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=4
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=${vendor_param.maxNumScheUePdschL1Pool}
    ...                               maxNumScheUePdschL1Sp=${vendor_param.maxNumScheUePdschL1Sp}
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=${vendor_param.maxNumDlSubcellL1Pool}
    ...                               maxNumDlSubcellL1Sp=${vendor_param.maxNumDlSubcellL1Sp}
    ...                               maxNumUlSubcellL1Pool=${vendor_param.maxNumUlSubcellL1Pool}
    ...                               maxNumUlSubcellL1Sp=${vendor_param.maxNumUlSubcellL1Sp}
    ...                               maxNumOfCAUserL2SubPool=40
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbPoolCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=14
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=full_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=24
    ...                               maxNumScheUePdschL1Sp=18
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=6
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=6
    ...                               maxNumUlSubcellL1Sp=4
    ...                               maxNumOfCAUserL2SubPool=40

    ${vendor_param.maxNumScheUePdschL1Pool}=    Run Keyword If    ${vendor_param.maxNumScheUePdschL1Pool} == None    Set Variable    24
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Pool}
    ${vendor_param.maxNumScheUePdschL1Sp}=      Run Keyword If    ${vendor_param.maxNumScheUePdschL1Sp} == None    Set Variable    18
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Sp}
    ${vendor_param.maxNumDlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumDlSubcellL1Pool} == None    Set Variable    6
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Pool}
    ${vendor_param.maxNumDlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumDlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Sp}
    ${vendor_param.maxNumUlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumUlSubcellL1Pool} == None    Set Variable    6
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Pool}
    ${vendor_param.maxNumUlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumUlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=14
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=full_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=${vendor_param.maxNumScheUePdschL1Pool}
    ...                               maxNumScheUePdschL1Sp=${vendor_param.maxNumScheUePdschL1Sp}
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4368
    ...                               maxNumDlSubcellL1Pool=${vendor_param.maxNumDlSubcellL1Pool}
    ...                               maxNumDlSubcellL1Sp=${vendor_param.maxNumDlSubcellL1Sp}
    ...                               maxNumUlSubcellL1Pool=${vendor_param.maxNumUlSubcellL1Pool}
    ...                               maxNumUlSubcellL1Sp=${vendor_param.maxNumUlSubcellL1Sp}
    ...                               maxNumOfCAUserL2SubPool=40
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbPoolCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    #    <item>
    #      <p name="bbHwVariant">ABIO</p>
    #      <p name="csSize">32</p>
    #      <p name="direction">UL</p>
    #      <p name="l1PoolType">NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm</p>
    #      <p name="maxNumLayerPrbL1Sp">546</p>
    #      <p name="maxNumStreamPrbL1Sp">1092</p>
    #      <p name="maxNumWbStreamPrbL1Sp">1092</p>
    #    </item>

    # UL Only case csSize=32
    # Original value should be related to <!-- 32 CS, only UL -->
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=32
    ...                               direction=UL
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               maxNumLayerPrbL1Sp=546
    ...                               maxNumStreamPrbL1Sp=1092
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize32}=  Run Keyword If    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize32} == None    Set Variable    546
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize32}

    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize32}=    Run Keyword If    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize32} == None
    ...                                                                                                                   Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize32}
    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize32}=  Run Keyword If    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize32} == None
    ...                                                                                                                   Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize32}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=32
    ...                               direction=UL
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               maxNumLayerPrbL1Sp=${vendor_param.ul_maxNumLayerPrbL1Sp_csSize32}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.ul_maxNumStreamPrbL1Sp_csSize32}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize32}
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    # <!-- 64 CS, only UL -->
    #     <item>
    #       <p name="bbHwVariant">ABIO</p>
    #       <p name="csSize">64</p>
    #       <p name="direction">UL</p>
    #       <p name="l1PoolType">NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm</p>
    #       <p name="maxNumLayerPrbL1Sp">1092</p>
    #       <p name="maxNumStreamPrbL1Sp">2184</p>
    #       <p name="maxNumWbStreamPrbL1Sp">1092</p>
    #     </item>
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=64
    ...                               direction=UL
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               maxNumLayerPrbL1Sp=1092
    ...                               maxNumStreamPrbL1Sp=2184
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize64}=         Run Keyword If    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize64} == None
    ...                                                                                                                  Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumLayerPrbL1Sp_csSize64}

    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize64}=        Run Keyword If    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize64} == None
    ...                                                                                                                  Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumStreamPrbL1Sp_csSize64}
    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize64}=      Run Keyword If    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize64} == None
    ...                                                                                                                  Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize64}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=64
    ...                               direction=UL
    ...                               l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                               maxNumLayerPrbL1Sp=${vendor_param.ul_maxNumLayerPrbL1Sp_csSize64}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.ul_maxNumStreamPrbL1Sp_csSize64}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.ul_maxNumWbStreamPrbL1Sp_csSize64}
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    ScfVendorOperations.save back toxml                   ${modified_vendor_file}
    ${Tmp_file_ls}          OperatingSystem.run           ls -altr ${modified_vendor_file}
    Dated log               Obtained file ${Tmp_file_ls}
    &{args}                 Create Dictionary             vendor_file="${modified_vendor_file}"
    OAM Run Command         cmd=set_vendor_file           cmd_args=${args}

Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity For ABIP
    [Documentation]
    ...     Conditions:     it is based on the argument ${vendor_param}
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${vendor_param}

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
    ...                               l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI
    ...                               maxNumLayerPrbL1Sp=2184
    ...                               maxNumStreamPrbL1Sp=2184
    ...                               maxNumWbStreamPrbL1Sp=1092

    ${vendor_param.maxNumLayerPrbL1Sp}=         Run Keyword If    ${vendor_param.maxNumLayerPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumLayerPrbL1Sp}

    ${vendor_param.maxNumStreamPrbL1Sp}=        Run Keyword If    ${vendor_param.maxNumStreamPrbL1Sp} == None    Set Variable    2184
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumStreamPrbL1Sp}
    ${vendor_param.maxNumWbStreamPrbL1Sp}=      Run Keyword If    ${vendor_param.maxNumWbStreamPrbL1Sp} == None    Set Variable    1092
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumWbStreamPrbL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               csSize=48
    ...                               direction=DL
    ...                               l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI
    ...                               maxNumLayerPrbL1Sp=${vendor_param.maxNumLayerPrbL1Sp}
    ...                               maxNumStreamPrbL1Sp=${vendor_param.maxNumStreamPrbL1Sp}
    ...                               maxNumWbStreamPrbL1Sp=${vendor_param.maxNumWbStreamPrbL1Sp}
    # ...                               maxNumWbStreamPrbL1Sp=1092
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbL1SpPrbInitCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    # bbPoolCapacity
    &{original_values}      Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=12
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=24
    ...                               maxNumScheUePdschL1Sp=18
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4428
    ...                               maxNumDlSubcellL1Pool=8
    ...                               maxNumDlSubcellL1Sp=4
    ...                               maxNumUlSubcellL1Pool=8
    ...                               maxNumUlSubcellL1Sp=4

    ${vendor_param.maxNumScheUePdschL1Pool}=    Run Keyword If    ${vendor_param.maxNumScheUePdschL1Pool} == None    Set Variable    24
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Pool}
    ${vendor_param.maxNumScheUePdschL1Sp}=      Run Keyword If    ${vendor_param.maxNumScheUePdschL1Sp} == None    Set Variable    18
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumScheUePdschL1Sp}
    ${vendor_param.maxNumDlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumDlSubcellL1Pool} == None    Set Variable    8
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Pool}
    ${vendor_param.maxNumDlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumDlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumDlSubcellL1Sp}
    ${vendor_param.maxNumUlSubcellL1Pool}=      Run Keyword If    ${vendor_param.maxNumUlSubcellL1Pool} == None    Set Variable    8
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Pool}
    ${vendor_param.maxNumUlSubcellL1Sp}=        Run Keyword If    ${vendor_param.maxNumUlSubcellL1Sp} == None    Set Variable    4
    ...                                                     ELSE    Set Variable    ${vendor_param.maxNumUlSubcellL1Sp}

    &{new_values}           Create Dictionary
    ...                               bbHwVariant=${vendor_param.bbHwVariant}
    ...                               bbPoolCapacityId=12
    ...                               confDuplexMode=TDD
    ...                               l1DeploymentVariant=half_mode
    ...                               maxNumOfDRBL2Pool=9000
    ...                               maxNumOfGBRL2Pool=1104
    ...                               maxNumOfUserL2Pool=4500
    ...                               maxNumPucchF1HarqL1Pool=90
    ...                               maxNumPucchF1SRPerSlotL1Pool=96
    ...                               maxNumPucchF3HarqL1Pool=18
    ...                               maxNumPucchF3PCSIPerSlotL1Pool=48
    ...                               maxNumScheUePdschL1Pool=${vendor_param.maxNumScheUePdschL1Pool}
    ...                               maxNumScheUePdschL1Sp=${vendor_param.maxNumScheUePdschL1Sp}
    ...                               maxNumScheUePdschL2Sp=18
    ...                               maxNumScheUePuschL1Pool=24
    ...                               maxNumScheUePuschL1Sp=18
    ...                               maxNumScheUePuschL2Sp=18
    ...                               maxNumFHStreamPRBULL1Pool=4428
    ...                               maxNumDlSubcellL1Pool=${vendor_param.maxNumDlSubcellL1Pool}
    ...                               maxNumDlSubcellL1Sp=${vendor_param.maxNumDlSubcellL1Sp}
    ...                               maxNumUlSubcellL1Pool=${vendor_param.maxNumUlSubcellL1Pool}
    ...                               maxNumUlSubcellL1Sp=${vendor_param.maxNumUlSubcellL1Sp}
    @{original_items_list}=           Create List         ${original_values}
    @{new_items_list}=                Create List         ${new_values}
    ${list_name}            Set Variable                  bbPoolCapacity
    ${modified_mo}=         ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}    ${list_name}    ${mo_dict}

    ScfVendorOperations.save back toxml                   ${modified_vendor_file}
    ${Tmp_file_ls}          OperatingSystem.run           ls -altr ${modified_vendor_file}
    Dated log               Obtained file ${Tmp_file_ls}
    &{args}                 Create Dictionary             vendor_file="${modified_vendor_file}"
    OAM Run Command         cmd=set_vendor_file           cmd_args=${args}

Deploy Vendor File Config
    [Documentation]
    ...     Conditions:     it is based on the arguments ${vendor_param} ${is_perform_full_commissioning}
    ...     Actions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${vendor_param}
    ...                     ${is_perform_full_commissioning}=${True}

    # OAM Perform Full Commissioning is mandatory to apply vendor configuration
    CB009836-Keywords.Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity     ${vendor_param}
    # Force the full commissioning when it is requested
    Run Keyword if    ${is_perform_full_commissioning}    Run Keywords     OAM Perform Full Commissioning    scf_file=${test_scf_file}
    ...                                                       AND          OAM wait available    wait_time=300

Deploy Vendor File to activate CB009836
    [Documentation]
    ...     Conditions:     it is based on the arguments ${PARAMS_IN_VENDOR} ${is_perform_full_commissioning}
    ...     Actions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${PARAMS_IN_VENDOR}
    ...                     ${is_perform_full_commissioning}=${True}

    # OAM Perform Full Commissioning is mandatory to apply vendor configuration
    # Dev_lib.start_to_capture_infomodel_log
    ${modified_vendor_file}=    Dev_lib.change_vendor_parameters    ${PARAMS_IN_VENDOR}
    # Run Keyword And Ignore Error      Dev_lib.stop_to_capture_infomodel_log
    &{args}    Create Dictionary         vendor_file="${modified_vendor_file}"
    dated log   apply set_vendor_file with cmd_args=${args}
    # due to some SOAM architecture particularities, use same ADMIN instance for both set_vendor command and commissioning command
    coam.set_vendor_file    vendor_file=${modified_vendor_file}   connection=coam_gnb
    # Force the full commissioning when it is requested
    Run Keyword if    ${is_perform_full_commissioning}    Run Keywords     dated log      coam.perform_commissioning ${test_scf_file}
    ...                                                       AND          coam.perform_commissioning    scf_file=${test_scf_file}
    ...                                                                                                  connection=coam_gnb
    ...                                                       AND          OAM wait available    wait_time=300
    # OAM Run Command    cmd=set_vendor_file    cmd_args=${args}
    # Run Keyword if    ${is_perform_full_commissioning}    Run Keywords     OAM Perform Full Commissioning    scf_file=${test_scf_file}
    # ...                                                       AND          OAM wait available    wait_time=300

update params List for VendorFile
    [Arguments]             ${vendor_custom}    ${PARAMS_IN_VENDOR}
    ${maxNumLayerPrbL1Sp}=    Run Keyword If   ${vendor_custom.maxNumLayerPrbL1Sp} == None    Set Variable    2184
    ...                           ELSE                                                        Set Variable    ${vendor_custom.maxNumLayerPrbL1Sp}
    ${maxNumStreamPrbL1Sp}=   Run Keyword If   ${vendor_custom.maxNumStreamPrbL1Sp} == None   Set Variable    2184
    ...                           ELSE                                                        Set Variable    ${vendor_custom.maxNumStreamPrbL1Sp}
    ${maxNumWbStreamPrbL1Sp}=  Run Keyword If   ${vendor_custom.maxNumWbStreamPrbL1Sp} == None  Set Variable    1092
    ...                           ELSE                                                      Set Variable    ${vendor_custom.maxNumWbStreamPrbL1Sp}
    ${bbHwVariant}=     set variable     ${vendor_custom.bbHwVariant}
    ${l1PoolType}       Set Variable If     '${bbHwVariant}'=='ABIO'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                                     '${bbHwVariant}'=='ABIP'        NR_L1Pool_Thor_TDD_FR1_eCPRI
    ...                                     '${bbHwVariant}'=='ASOE'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                                     '${bbHwVariant}'=='ABIQ'        NR_L1Pool_Thor_TDD_FR1_eCPRI
    ...                                                                     NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ${csSize}       Set Variable If     '${bbHwVariant}'=='ABIO'        64
    ...                                 '${bbHwVariant}'=='ABIP'        48
    ...                                 '${bbHwVariant}'=='ASOE'        48
    ...                                 '${bbHwVariant}'=='ABIQ'        48
    ...                                                                 48
    ${direction}=     set variable     DL
    # ABIP case : csSize=48, direction=DL, l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI
    # ASOE case : csSize=48, direction=DL, l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    # ABIO case : csSize=64, direction=DL, l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ${bbL1SpPrbInitCapacity1}     Catenate    bbL1SpPrbInitCapacity:maxNumLayerPrbL1Sp=${maxNumLayerPrbL1Sp}|
    ...                                       bbHwVariant=${bbHwVariant}&&csSize=${csSize}&&direction=${direction}&&l1PoolType=${l1PoolType}
    ${bbL1SpPrbInitCapacity2}     Catenate    bbL1SpPrbInitCapacity:maxNumStreamPrbL1Sp=${maxNumStreamPrbL1Sp}|
    ...                                       bbHwVariant=${bbHwVariant}&&csSize=${csSize}&&direction=${direction}&&l1PoolType=${l1PoolType}
    Run Keyword If   ${vendor_custom.maxNumLayerPrbL1Sp} != None    append to List     ${PARAMS_IN_VENDOR}    ${bbL1SpPrbInitCapacity1}
    Run Keyword If   ${vendor_custom.maxNumStreamPrbL1Sp} != None   append to List     ${PARAMS_IN_VENDOR}    ${bbL1SpPrbInitCapacity2}
    [return]     ${PARAMS_IN_VENDOR}

update params List for VendorFile v2
    [Arguments]             ${vendor_custom}    ${PARAMS_IN_VENDOR_OUT}
    ${maxNumLayerPrbL1Sp}=    Run Keyword If   ${vendor_custom.maxNumLayerPrbL1Sp} == None    Set Variable    2184
    ...                           ELSE                                                        Set Variable    ${vendor_custom.maxNumLayerPrbL1Sp}
    ${maxNumStreamPrbL1Sp}=   Run Keyword If   ${vendor_custom.maxNumStreamPrbL1Sp} == None   Set Variable    2184
    ...                           ELSE                                                        Set Variable    ${vendor_custom.maxNumStreamPrbL1Sp}
    ${maxNumWbStreamPrbL1Sp}=  Run Keyword If   ${vendor_custom.maxNumWbStreamPrbL1Sp} == None  Set Variable    1092
    ...                           ELSE                                                      Set Variable    ${vendor_custom.maxNumWbStreamPrbL1Sp}
    ${vendorElement1}     Run Keyword If   ${vendor_custom.maxNumLayerPrbL1Sp} != None
    ...                     Create Dictionary     bbHwVariant    ${vendor_custom.bbHwVariant}
    ...                                           csSize         ${48}
    ...                                           direction      DL
    ...                                           maxNumLayerPrbL1Sp      ${vendor_custom.maxNumLayerPrbL1Sp}
    ...                           ELSE         Create Dictionary
    ${vendorElement2}     Run Keyword If   ${vendor_custom.maxNumStreamPrbL1Sp} != None
    ...                     Create Dictionary     bbHwVariant    ${vendor_custom.bbHwVariant}
    ...                                           csSize         ${48}
    ...                                           direction      DL
    ...                                           maxNumStreamPrbL1Sp     ${vendor_custom.maxNumStreamPrbL1Sp}
    ...                           ELSE         Create Dictionary
    ${vendorElement3}     Run Keyword If   ${vendor_custom.maxNumWbStreamPrbL1Sp} != None
    ...                     Create Dictionary     bbHwVariant    ${vendor_custom.bbHwVariant}
    ...                                           csSize         ${48}
    ...                                           direction      DL
    ...                                           maxNumWbStreamPrbL1Sp     ${vendor_custom.maxNumWbStreamPrbL1Sp}
    ...                           ELSE         Create Dictionary
    ${MaxSpPRB}            Create List       ${vendorElement1}    ${vendorElement2}    ${vendorElement3}
    FOR     ${item}     IN  @{MaxSpPRB}
            ${PARAMS_IN_VENDOR_OUT}       Add Items To Vendor Params List     ${PARAMS_IN_VENDOR_OUT}       ${item}
    END
    [return]     ${PARAMS_IN_VENDOR_OUT}

update params List for VendorFile v3
    [Arguments]             ${argumentsList}    ${PARAMS_IN_VENDOR}
    FOR     ${item}     IN  @{argumentsList}
            ${PARAMS_IN_VENDOR}       Add Items To Vendor Params List        ${PARAMS_IN_VENDOR}       ${item}
    END
    [return]     ${PARAMS_IN_VENDOR}

Deploy Vendor File Config For ABIP
    [Documentation]
    ...     Conditions:     it is based on the arguments ${vendor_param} ${is_perform_full_commissioning}
    ...     Actions:
    ...     Actions:
    ...     Checks:
    ...     Verdict:
    [Arguments]             ${vendor_param}
    ...                     ${is_perform_full_commissioning}=${True}

    # OAM Perform Full Commissioning is mandatory to apply vendor configuration
    Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity For ABIP     ${vendor_param}
    # Force the full commissioning when it is requested
    Run Keyword if    ${is_perform_full_commissioning}    Run Keywords     OAM Perform Full Commissioning    scf_file=${test_scf_file}
    ...                                                       AND          OAM wait available    wait_time=300

Update Vendor File
    [Arguments]     ${argumentsList}

    ${vendor_response}     coam.download_vendor_file       target_file_name=/tmp/vendor_lte.xml    connection=coam_gnb
    ${vendor_file_parsed}       Parse xml       /tmp/vendor_lte.xml
    FOR     ${item}     IN  @{argumentsList}
            ${vendor_file_parsed}       Add Items To Vendor File        ${vendor_file_parsed}       ${item}
    END

    Save Xml        source=${vendor_file_parsed}         path=/tmp/vendor_lte_modif.xml
    coam.set_vendor_file    vendor_file=/tmp/vendor_lte_modif.xml   connection=coam_gnb

Reset Vendor File
    [Arguments]

    ${vendor_response}     coam.download_vendor_file       target_file_name=/tmp/vendor_lte.xml    connection=coam_gnb
    coam.set_vendor_file    vendor_file=/tmp/vendor_lte.xml   connection=coam_gnb

Add Items To Vendor File
    [Arguments]        ${vendor_file_parsed}      ${item}
    ${VendorParams}    	Get Dictionary Keys 	${item}
    ${l1PoolType}       Set Variable If     '${bbmod_model}'=='ABIO'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...          '${bbmod_model}'=='ABIQ'        NR_L1Pool_Thor_TDD_FR1_eCPRI
    FOR     ${param}     IN     @{VendorParams[2:]}
        ${valueparam}     Convert To String     ${item['${param}']}

        ${modifs_xml}       catenate
        ...     .//managedObject[@class='NRBTS']//list[@name="bbL1SpPrbInitCapacity"]//item[
        ...     p[@name="bbHwVariant" and text()="${bbmod_model}"] and
        ...     p[@name="direction" and text()="${item['direction']}"] and
        ...     p[@name="csSize" and text()="${item['csSize']}"] and
        ...     p[@name="l1PoolType" and text()="${l1PoolType}"]]//p[@name="${param}"]

        ${vendor_file_parsed}       Set Element Text       source=${vendor_file_parsed}
        ...      text=${valueparam}     xpath=${modifs_xml}
   END
   [Return]        ${vendor_file_parsed}

Add Items To Vendor Params List
   [Arguments]        ${params_in_vendor}      ${item}
   ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${item}
   Return From Keyword If     ${isEmpty}     ${params_in_vendor}
   ${VendorParams}     Get Dictionary Keys 	${item}
   ${bbHwVariant}      Set Variable         ${item['bbHwVariant']}
   ${l1PoolType}       Set Variable If     '${bbHwVariant}'=='ABIO'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
   ...                                     '${bbHwVariant}'=='ABIP'        NR_L1Pool_Thor_TDD_FR1_eCPRI
   ...                                     '${bbHwVariant}'=='ASOE'        NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
   ...                                     '${bbHwVariant}'=='ABIQ'        NR_L1Pool_Thor_TDD_FR1_eCPRI
   ...                                                                     NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
   FOR     ${param}     IN     @{VendorParams[3:]}
        ${valueparam}     Convert To String     ${item['${param}']}
        ${bbL1SpPrbInitCapacity}     Catenate    SEPARATOR=    bbL1SpPrbInitCapacity:${param}=${valueparam}|
        ...        bbHwVariant=${bbHwVariant}&&csSize=${item['csSize']}&&direction=${item['direction']}&&l1PoolType=${l1PoolType}
        append to List     ${params_in_vendor}    ${bbL1SpPrbInitCapacity}
   END
   [Return]        ${params_in_vendor}

# End Of Vendor file management
# --------------------------------------------------------------------------------------------------------------------------------------------------
