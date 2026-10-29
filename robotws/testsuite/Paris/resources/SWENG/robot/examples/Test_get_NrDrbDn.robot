
*** Settings ***
Documentation        A test suite with a single test for the OAM library

Library             taf.gnb.oam.coam.cu         WITH NAME               oam_vcu
Library             taf.gnb.oam.coam.vdu        WITH NAME               oam_vdu

Resource            ../Connect.robot
Resource            ../Setup.robot
Resource            ../SetConfig.robot
Resource            ../Oam.robot

Suite Setup         Suite setup                 keepAllUeDataInCfgFile=${True}    # listBackupFiles=${FD_ALL}

*** Variables ***
${NB_ITERATION}         1


*** Test Cases ***
Test
    FOR   ${ii}   IN RANGE   0   ${NB_ITERATION}
        Run keyword if                          ${isAic}
        ...                                     My Get NR DRB DN Test Vran
        ...         ELSE                        My Get NR DRB DN Test Classical
    END
#    [Teardown]      Run keyword if              ${isAic}
#    ...                                         Get Operation History VRAN


*** Keywords ***
My Get NR DRB DN Test Vran
    Dated log New Line                          === VCU CASE - Call with oam=GNB_CU.oam, callType=NSA and bearerId=9
    ${nrDrbDN} =                               set variable                    ${None}
    ${nrDrbDN} =                               Oam.OAM Get nrDrbDN              oam=${GNB_CU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=9
    Dated log                                   =======> NSA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VCU CASE - Call with oam=GNB_CU.oam, callType=NSA and bearerId=7
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_CU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=7
    Dated log                                   =======> NSA BearerId 7 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VCU CASE - Call with oam=GNB_CU.oam, callType=SA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_CU.oam}
    ...                                                                         callType=SA
    ...                                                                         bearerId=9
    Dated log                                   =======> SA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VCU CASE - ERROR CASE - Call with oam=GNB_CU.oam, callType=SA and bearerId=25
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_CU.oam}
    ...                                                                         callType=SA
    ...                                                                         bearerId=25
    Dated log                                   =======> SA BearerId 25 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VDU CASE - Call with no input parameter
    Dated Log                                   ==> Will use the oam=GNB_DU.oam callType=NSA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN
    Dated log                                   =======> NSA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VDU CASE - Call with oam=GNB_DU.oam, callType=NSA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=7
    Dated log                                   =======> NSA BearerId 7 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VDU CASE - Call with oam=GNB_DU.oam, callType=SA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=SA
    ...                                                                         bearerId=9
    Dated log                                   =======> SA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === VDU CASE - ERROR CASE: Call with oam=GNB_DU.oam, callType=NSA and bearerId=25
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=25
    Dated log                                   =======> NSA BearerId 25 -> nrDrbDN = ${nrDrbDN}


My Get NR DRB DN Test Classical
    Dated log New Line                          === Call with no input parameter
    Dated Log                                   ==> Will use the oam=GNB_DU.oam and NRCellId=1
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN
    Dated log                                   =======> NSA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === Call with oam=GNB_DU.oam, callType=NSA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=7
    Dated log                                   =======> NSA BearerId 7 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === Call with oam=GNB_DU.oam, callType=SA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=SA
    ...                                                                         bearerId=9
    Dated log                                   =======> SA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === ERROR CASE: Call with oam=GNB_DU.oam, callType=NSA and bearerId=25
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=25
    Dated log                                   =======> NSA BearerId 25 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === Call with no input parameter
    Dated Log                                   ==> Will use the oam=GNB_DU.oam and NRCellId=1
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN
    Dated log                                   =======> NSA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === Call with oam=GNB_DU.oam, callType=NSA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=7
    Dated log                                   =======> NSA BearerId 7 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === Call with oam=GNB_DU.oam, callType=SA and bearerId=9
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=SA
    ...                                                                         bearerId=9
    Dated log                                   =======> SA BearerId 9 -> nrDrbDN = ${nrDrbDN}

    Dated log New Line                          === ERROR CASE: Call with oam=GNB_DU.oam, callType=NSA and bearerId=25
    ${nrDrbDN} =                                set variable                    ${None}
    ${nrDrbDN} =                                Oam.OAM Get nrDrbDN             oam=${GNB_DU.oam}
    ...                                                                         callType=NSA
    ...                                                                         bearerId=25
    Dated log                                   =======> NSA BearerId 25 -> nrDrbDN = ${nrDrbDN}


Get Operation History VRAN
    Dated log New Line                          === VCU Connect, then Get Operation History, then Reset and Disconnect:
    ${CU_connect}                               oam_vcu.connect_to              host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                                                                         port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...                                                                         username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                                                                         password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                                                                         secure=True
    Dated log                                   ... VCU Connect result is:>>${CU_connect}<<
    Dated Log                                   Get Operation History...
    ${CU_operation_history}                     oam_vcu.get_cu_operation_history
    Dated log                                   Now Do the VCU RESET...
    ${CU_reset}                                 oam_vcu.reset_cu
    Dated log                                   ... VCU Reset result is:>>${CU_reset}<<
    Dated log                                   Now Do the VCU Disconnect:
    ${CU_disconnect}                            oam_vcu.disconnect
    Dated log                                   ... VCU Disconnect result is:>>${CU_disconnect}<<

    Dated log New Line                          === VDU Connect, then Get Operation History, then Reset and Disconnect:
    ${DU_connect}                               oam_vdu.connect_to              host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...                                                                         port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...                                                                         username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...                                                                         password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...                                                                         secure=True
    Dated log                                   ... VDU Connect result is:>>${DU_connect}<<
    Dated Log                                   Get Operation History...
    ${DU_operation_history}                     oam_vdu.get_vdu_operation_history
    Dated log                                   Now Do the VDU RESET...
    ${DU_reset}                                 oam_vdu.reset_vdu
    Dated log                                   ... VCU Reset result is:>>${CU_reset}<<
    Dated log                                   Now Do the VDU Disconnect:
    ${DU_disconnect}                            oam_vdu.disconnect
    Dated log                                   ... VDU Disconnect result is:>>${DU_disconnect}<<

    Dated log New Line                          === VCU DISPLAY OPERATION HISTORY :
    Dated Log                                   ${CU_operation_history}

    Dated log New Line                          === VDU DISPLAY OPERATION HISTORY :
    Dated Log                                   ${DU_operation_history}
