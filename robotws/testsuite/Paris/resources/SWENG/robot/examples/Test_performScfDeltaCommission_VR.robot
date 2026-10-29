*** Settings ***
Documentation                       Suite description

Library                             taf.sbts.oam.coam.admin             WITH NAME       coam_admin
Library                             taf.gnb.oam.coam.cu                 WITH NAME       coam_cu
Library                             taf.gnb.oam.coam.vdu                WITH NAME       coam_du
Library                             ../../python/CoamParameter.py       WITH NAME       coam_param

Resource                            ../Oam.robot
Resource                            ../Setup.robot
Resource                            ../Tools.robot

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
...                                                     keepAllUeDataInCfgFile=${True}
# Suite Teardown                      Suite teardown


*** Variables ***
# ===> ATTENTION: CES FICHERS JSON SONT A AJOUTER MANUELLEMENT SUR LA VM DE LA TL !!!
# fichiers json tres tres simplistes:
${vduJsonStep1}                     /home/ute/CrtRoot/DU_Delta_JSON_Set_actPdschAtSsbSlots_To_True.json
${vduJsonStep2}                     /home/ute/CrtRoot/DU_Delta_JSON_Set_actPdschAtSsbSlots_To_False.json
${vcuJsonStep1}                     /home/ute/CrtRoot/CU_Delta_JSON_Set_actAperCsi_To_True.json
${vcuJsonStep2}                     /home/ute/CrtRoot/CU_Delta_JSON_Set_actAperCsi_To_False.json


*** Test Cases ***
Test display TL topology
    Dated Log New Line                  "================================================================================="
    Dated Log                           TOPO is: ${TLConfig.topo}


Test the Delta JSON
    Run Keyword if                      not ${isAic}                    Test The Classical Case
    Run Keyword if                      ${isAic}                        Test The VRAN Case With Krk Tools
    Run Keyword if                      ${isAic}                        Test The VRAN Case With Krk Tools and Errors
#   Run Keyword if                      ${isAic}                        Test The VRAN Case With CoamParameter


*** Keywords ***

Test The VRAN Case With Krk Tools
    Dated Log New Line                  "================================================================================="
    Pass Execution if                   not ${isAic}                    ${TEST NAME} not executed because TL is Classical

    Dated Log New Line                  vDU CASE : set to TRUE the MRBTS-1/NRBTS-1/NRCELL-1/actPdschAtSsbSlots
    # as we don't know the current value of this parameter, we use the "run keyword and ignore error"
    # by this way, either the current value is already at True and then the request will be failed but the next step will set it to False
    #              or     the current value is False and then we will successfuly set it to True
    Run Keyword And Ignore Error        OAM Send DU delta commissioning     input_filepath=${vduJsonStep1}

    traced sleep                        duration=10s                    msg=take some time before to set param to False

    Dated Log New Line                  vDU CASE : set to FALSE the MRBTS-1/NRBTS-1/NRCELL-1/actPdschAtSsbSlots
    OAM Send DU delta commissioning     input_filepath=${vduJsonStep2}

    Dated Log New Line                  vCU CASE : set to TRUE the MRBTS-1/NRBTS-1/NRCELL-1/actAperCsi
    # as we don't know the current value of this parameter, we use the "run keyword and ignore error"
    # by this way, either the current value is already at True and then the request will be failed but the next step will set it to False
    #              or     the current value is False and then we will successfuly set it to True
    Run Keyword And Ignore Error        OAM Send CU delta commissioning     input_filepath=${vcuJsonStep1}

    traced sleep                        duration=10s                    msg=take some time before to set param to False

    Dated Log New Line                  vCU CASE : set to FALSE the MRBTS-1/NRBTS-1/NRCELL-1/actAperCsi
    OAM Send CU delta commissioning     input_filepath=${vcuJsonStep2}


Test The VRAN Case With Krk Tools and Errors
    Dated Log New Line                  "================================================================================="
    Pass Execution if                   not ${isAic}                    ${TEST NAME} not executed because TL is Classical

    Dated Log New Line                  vDU CASE : set to TRUE the MRBTS-1/NRBTS-1/NRCELL-1/actPdschAtSsbSlots
    # as we don't know the current value of this parameter, we use the "run keyword and ignore error"
    # by this way, either the current value is already at True and then the request will be failed but the next step will set it to False
    #              or     the current value is False and then we will successfuly set it to True
    Run Keyword And Ignore Error        OAM Send DU delta commissioning     input_filepath=${vduJsonStep1}
    traced sleep                        duration=10s                        msg=sleep before to set again param to True and generate an error
    Dated Log New Line                  vDU CASE : set again to TRUE to generate an error case
    Run Keyword And Ignore Error        OAM Send DU delta commissioning     input_filepath=${vduJsonStep1}
    traced sleep                        duration=10s                        msg=sleep before to set param to default value (false)
    Dated Log New Line                  vDU CASE : set to FALSE
    Run Keyword And Ignore Error        OAM Send DU delta commissioning     input_filepath=${vduJsonStep2}

    Dated Log New Line                  vCU CASE : set to TRUE the MRBTS-1/NRBTS-1/NRCELL-1/actAperCsi
    # as we don't know the current value of this parameter, we use the "run keyword and ignore error"
    # by this way, either the current value is already at True and then the request will be failed but the next step will set it to False
    #              or     the current value is False and then we will successfuly set it to True
    Run Keyword And Ignore Error        OAM Send CU delta commissioning     input_filepath=${vcuJsonStep1}
    traced sleep                        duration=10s                        msg=sleep before to set again param to True and generate an error
    Dated Log New Line                  vDU CASE : set again to TRUE to generate an error case
    Run Keyword And Ignore Error        OAM Send CU delta commissioning     input_filepath=${vcuJsonStep1}
    traced sleep                        duration=10s                        msg=sleep before to set param to default value (false)
    Dated Log New Line                  vDU CASE : set to FALSE
    Run Keyword And Ignore Error        OAM Send CU delta commissioning     input_filepath=${vcuJsonStep2}


Test The Classical Case
    Dated Log New Line              "================================================================================="
    Pass Execution if               ${isAic}                        ${TEST NAME} not executed because TL is VRAN
    Dated Log                       CLASSICAL CASE
    ${aliasGNB}                     OAM Connect                     oam=${TGNB_DU[0].oam}
    ${result}                       coam_param.perform_scf_delta_commission
    ...                                                             delta_file=${vduJsonVeryBasic}
    ...                                                             connection=${aliasGNB}
    # ...                                                             scope=Classical     # optional as it is the default value
    # ...                                                             aic_entity=None     # optional as it is the default value
    Dated Log                       result=${result}
    OAM wait available              oam=${TGNB_DU[0].oam}
    Dated Log                       YOU HAVE 30 SEC TO CHECK IF DELTA PLAN IS OR NOT APPLIED
    sleep                           30
    OAM Disconnect                  oam=${TGNB_DU[0].oam}


Test The VRAN Case With CoamParameter
    Dated Log New Line              ""
    Pass Execution if               not ${isAic}                    ${TEST NAME} not executed because TL is Classical
    Dated Log                       vDU CASE
    ${aliasGNB_DU}                  Connect to OAM DU
    ${result}                       coam_param.perform_scf_delta_commission
    ...                                                             delta_file=${vduJsonVeryBasic}
    ...                                                             connection=${aliasGNB_DU}
    ...                                                             scope=AIC
    ...                                                             aic_entity=VDU
    Dated Log                       result=${result}
    Disconnect from OAM DU
    Dated Log                       YOU HAVE 30 SEC TO CHECK IF DELTA PLAN IS OR NOT APPLIED
    sleep                           30
    Dated Log New Line              ""
    Pass Execution if               not ${isAic}                    ${TEST NAME} not executed because TL is Classical
    Dated Log New Line              vCU CASE
    ${aliasGNB_CU}                  Connect to OAM CU
    ${result}                       coam_param.perform_scf_delta_commission
    ...                                                             delta_file=${vcuJsonVeryBasic}
    ...                                                             connection=${aliasGNB_CU}
    ...                                                             scope=AIC
    ...                                                             aic_entity=VCU
    Dated Log                       result=${result}
    Disconnect from OAM CU
    Dated Log                       YOU HAVE 30 SEC TO CHECK IF DELTA PLAN IS OR NOT APPLIED
    sleep                           30


Connect to OAM CU
    [Documentation]
    ...
    ...     Creates a Session to connect to OAM CU.
    ...     If no alias given in `alias` an alias is constructed in following way: gnb-`gnb_id`-oam-cu.
    ...
    ...     | gnb_id | Id of gnb                         |
    ...     | alias  | optional: only if you want to use several connections |
    ...
    ...     *Returns*   oam session to CU for specified gNB
    ...
    [Arguments]     ${gnb_id}=${0}   ${alias}=gnb-${gnb_id}-oam-cu
    # check if we can re-use the alias
    ${status}                   Run Keyword And Return Status   coam_cu.get_sessions_list   connection=${alias}
    Return From Keyword If      ${status}   ${alias}

    ${cu_oam_session}           coam_cu.connect to      host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...                                                 port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    ...                                                 username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...                                                 password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...                                                 secure=${True}
    ...                                                 alias=${alias}
    coam_cu.get_sessions_list   connection=${alias}
    [Return]                    ${alias}


Disconnect from OAM CU
    [Documentation]
    ...
    ...     Releases the connection to OAM CU.
    ...
    ...     | gnb_id | Id of gnb                       |
    ...
    [Arguments]  ${gnb_id}=0
    Run Keyword And Ignore Error   coam_cu.disconnect   gnb-${gnb_id}-oam-cu


Connect to OAM DU
    [Documentation]
    ...
    ...     Creates a Session to connect to OAM vDU.
    ...     If no alias given in `alias` an alias is constructed in following way: gnb-`gnb_id`-du-`du_id`-oam-vdu
    ...
    ...     | gnb_id | Id of gnb                         |
    ...     | du_id  | Id of du                          |
    ...     | alias  | optional: use it only if you want to use several sessions |
    ...
    ...     *Returns*   oam session to specified vDU
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}    ${alias}=gnb-${gnb_id}-du-${du_id}-oam-vdu
    # check if we can re-use the alias
    ${status}                   Run Keyword And Return Status   coam_du.get_sessions_list   vdu_connection=${alias}
    Return From Keyword If      ${status}               ${alias}

    ${du_oam_session}           coam_du.connect to      host=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.addr}
    ...                                                 port=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.port}
    ...                                                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.username}
    ...                                                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details.password}
    ...                                                 secure=${True}
    ...                                                 connection_name=${alias}
    coam_du.get_sessions_list   vdu_connection=${alias}
    [Return]                    ${alias}


Disconnect from OAM DU
    [Documentation]
    ...
    ...     Releases the connection to OAM vDU.
    ...
    ...     | gnb_id | Id of gnb                         |
    ...     | du_id  | Id of du                          |
    ...
    [Arguments]  ${gnb_id}=${0}    ${du_id}=${0}
    Run Keyword And Ignore Error   coam_du.disconnect   gnb-${gnb_id}-du-${du_id}-oam-vdu
