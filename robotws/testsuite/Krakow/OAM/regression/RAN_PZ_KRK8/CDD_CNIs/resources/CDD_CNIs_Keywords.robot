*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Keywords for CDD features: CNI-105082, CNI-103190, CNI-103193 and CNI-115365


Library      taf.rfrl.utilities.logger.custom_logger                   WITH NAME    logger
Library      on_air_tl_preparation.testline_preparation                WITH NAME    tl_prep
Library      taf.rfrl.bts.commissioning
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnbscf
Library      taf.rfrl.bts.devices.du.du_operations.GnbDuOperations     WITH NAME    GnbDuOp
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    CDD_CNIs_Keywords.py

*** Variables ***
${cdd_file_path}        ${cdd_project_path}/${CDD_directory}
${cdd_project_path}     /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CDD_CNIs
${CDD_directory}        CDD_backups_v6.10.1.110
${CDD_artifactory_URL}  https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/jdziedzi/CDD_CNIs
@{cdd_configs_list}     CDD-config_B66_CNI-103193.zip    CDD-config_n41_CNI-103190.zip
...                     CDD-config_n77_CNI-115365.zip    CDD-config_n78_CNI-105082.zip
${CDD_url}              https://10.253.176.168/
@{scf_prefix_tags}      TSPY074_B66_CNI-103193    TSPY074_n41_CNI-103190
...                     TSPY074_n77_CNI-115365    TSPY074_n78_CNI-105082
${ue_alias1}=           UE_1
${ue_alias2}=           UE_2
${duration}=            90s
${sw_config_path}       commissionings/Krakow/swconfig/default_swconfig.txt

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
    Restart Ue Proxy On Ue PC
    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_path}
    Download CDD configuration files    ${cdd_file_path}    ${CDD_artifactory_URL}    ${cdd_configs_list}
    ...                                 ${cdd_project_path}    ${CDD_directory}
    Perform CDD and BTS Commissioning    file_name=${cdd_file_path}/${cdd_configs_list}[0]    cdd_url=${CDD_url}
    ...                                  prefix_tag=${scf_prefix_tags}[0]
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup
    logger.log_info_to_console    --Test Suite Setup DONE--\n

Attach UE
    [Arguments]     ${ue_alias}    ${cap}    ${prepareUE}=${True}
    ...             ${earfcn}=${None}
    Run Keyword If      '${prepareUE}'=='${True}'
    ...                      ue.Require Ue       ${ue_alias}      capabilities=${cap}
    logger.log_info_to_console    \n\n-------------------- Attach ${ue_alias} ${cap}\n
    ${status}=    Run Keyword And Return Status    Run Keywords
    ...               ue.Detach UE    ${ue_alias}    AND
    ...               Run Keyword If  '${earfcn}'!='${None}'    Set Earfcn Lock On UE   ${earfcn}   ${ue_alias}   AND
    ...               ue.Attach Ue    ${ue_alias}
    IF    not ${status}
        logger.log_info_to_console    Initial attach failed. Attach again ${ue_alias}...
        ue.Detach UE    ${ue_alias}
        ue.Attach Ue    ${ue_alias}
        Run Keyword If  '${earfcn}'!='${None}'    Set Earfcn Lock On UE   ${earfcn}   ${ue_alias}
    END
    ${5G_CELL}      ue.Get Ue Info    ${ue_alias}    ALL
    ${5G_CELL_ID}   ue.Get Ue Info    ${ue_alias}    cell_id
    ${5G_CELL}      ue.Get Ue Info    ${ue_alias}    cell_info
    @{cells}=  Create List  ${nr_cell_id_PCI_809}  ${nr_cell_id_PCI_810}  ${nr_cell_id_PCI_149}  ${lte_cell_id_PCI_98}
    ${cell_match}=    Evaluate    ${5G_CELL_ID} in @{cells}
    Run Keyword If    ${cell_match}
    ...             logger.log_info_to_console    UE attached properly to the cell: ${5G_CELL}[PCID] (PCID)
    ...     ELSE    Fail And Log Error   msg= UE cannot attach to proper cell. UE attached to a cell: ${5G_CELL_ID}
    [Teardown]    Run Keyword If  '${earfcn}' == '${earfcn_PCI_98_B66}'
                  ...    Set Earfcn Lock On UE    earfcn=0    ue_alias=${ue_alias}    network_mode=lte
                  ...  ELSE IF    '${earfcn}'!='${None}'
                  ...    Set Earfcn Lock On UE    earfcn=0    ue_alias=${ue_alias}    network_mode=nr5g

L3 Call DL and UL
    [Arguments]    ${dl_throughput}    ${dl_deviation}    ${ul_throughput}    ${ul_deviation}    ${ue_alias}    ${cap}
    ...            ${earfcn}=${None}    ${prepareUE}=${True}
    Attach UE    ue_alias=${ue_alias}    cap=${cap}    earfcn=${earfcn}    prepareUE=${prepareUE}
    ${status}=    Run Keyword And Return Status
    ...           L3 Call    direction=DL    tput=${dl_throughput}    deviation=${dl_deviation}    ue_alias=${ue_alias}
    IF    not ${status}
        L3 Call    direction=DL    tput=${dl_throughput}    deviation=${dl_deviation}    ue_alias=${ue_alias}
    END
    ${status}=    Run Keyword And Return Status
    ...           L3 Call    direction=UL    tput=${ul_throughput}    deviation=${ul_deviation}    ue_alias=${ue_alias}
    IF    not ${status}
        L3 Call    direction=UL    tput=${ul_throughput}    deviation=${ul_deviation}    ue_alias=${ue_alias}
    END
    BuiltIn.Sleep     5s
    [Teardown]      Run Keywords    logger.log_info_to_console    Detach ${ue_alias} ${cap}\n    AND
    ...                             ue.Detach Ue    ${ue_alias}

L3 Call
    [Arguments]  ${direction}  ${tput}  ${deviation}  ${ue_alias}  ${protocol}=tcp  ${parallel_streams}=1
    logger.log_info to console      Start transfer in direction: ${direction}\n
    Start Data Transfer and Verify Troughput   direction=${direction}  duration=${duration}  tput=${tput}
    ...    deviation=${deviation}  parallel_streams=${parallel_streams}  alias=${ue_alias}  protocol=${protocol}

Set Earfcn Lock On UE
    [Arguments]    ${earfcn}    ${ue_alias}    ${network_mode}=nr5g
    IF    ${earfcn} == ${earfcn_PCI_98_B66}
        logger.log_info_to_console    \n\nSet on ${ue_alias} EARFCN Lock for LTE cell: DL earfcn = ${earfcn}\n
        ue.Set Earfcn Lock    ${ue_alias}    network_mode=lte    earfcn=${earfcn}
    ELSE IF    ${earfcn} == 0
        ue.Set Earfcn Lock    ${ue_alias}    network_mode=${network_mode}    earfcn=0
    ELSE
        logger.log_info_to_console    \n\nSet on ${ue_alias} EARFCN Lock for NR cell: arfcnSsbPbch = ${earfcn}\n
        ue.Set Earfcn Lock    ${ue_alias}    network_mode=nr5g    earfcn=${earfcn}    scs=30
    END
    BuiltIn.Sleep     15s

Test Setup with configs loading
    [Arguments]    ${file_name}    ${prefix_tag}    ${radio_unit_id}=1
    Run Keywords
    ...    Perform CDD and BTS Commissioning  file_name=${file_name}  cdd_url=${CDD_url}  radio_unit_id=${radio_unit_id}
           ...                                prefix_tag=${prefix_tag}    AND
    ...    Test Setup

GNB Get Param Value
    [Arguments]    ${param_name}    ${dist_name}=${None}
    ${result}=    Run Keyword And Ignore Error    GnbDuOp.get_param_value    param_name=${param_name}

    IF    '${result[0]}' != 'PASS'
        ${result}=    Run Keyword And Ignore Error    gnbscf.Get Parameters By Dist Name    ${dist_name}    ${{["${param_name}"]}}
        ${status}=    Set Variable    ${result[0]}
        ${value}=     Set Variable    ${result[1]}
        ${is_valid}=    Evaluate    isinstance($value, dict) and bool($value)
        IF    '${status}' != 'PASS' or not ${is_valid}
            ${param_value}=    Set Variable    ${None}
        ELSE
            ${param_value}=    Set Variable    ${value['parameters']['${param_name}']}
        END
    ELSE
        ${param_value}=    Set Variable    ${result[1]}
    END
    [Return]    ${param_value}

Get all needed params values
    Set Param Suite Var    arfcnSsbPbch_PCI_809_n41    arfcnSsbPbch    MRBTS-{}/NRBTS-{}/NRCELL-1
    Set Param Suite Var    arfcnSsbPbch_PCI_810_n41    arfcnSsbPbch    MRBTS-{}/NRBTS-{}/NRCELL-2
    Set Param Suite Var    arfcnSsbPbch_PCI_149_n77    arfcnSsbPbch    MRBTS-{}/NRBTS-{}/NRCELL-10
    Set Param Suite Var    arfcnSsbPbch_PCI_809_n78    arfcnSsbPbch    MRBTS-{}/NRBTS-{}/NRCELL-1
    Set Param Suite Var    arfcnSsbPbch_PCI_810_n78    arfcnSsbPbch    MRBTS-{}/NRBTS-{}/NRCELL-2
    Set Param Suite Var    earfcn_PCI_98_B66     earfcnDL
    Set Param Suite Var    lte_cell_id_PCI_98    eutraCelId        MRBTS-{}/LNBTS-79144/LNCEL-0
    Set Param Suite Var    nr_cell_id_PCI_809    nrCellIdentity    MRBTS-{}/NRBTS-{}/NRCELL-1
    Set Param Suite Var    nr_cell_id_PCI_810    nrCellIdentity    MRBTS-{}/NRBTS-{}/NRCELL-2
    Set Param Suite Var    nr_cell_id_PCI_149    nrCellIdentity    MRBTS-{}/NRBTS-{}/NRCELL-10

Set Param Suite Var
    [Arguments]    ${var_name}    ${param_name}    ${dist_name}=${None}
    ${value}=    GNB Get Param Value    param_name=${param_name}    dist_name=${dist_name}
    Set Suite Variable    ${${var_name}}    ${value}
    logger.log_info_to_console    \nThe '${var_name}' parameter value is: ${value}\n
