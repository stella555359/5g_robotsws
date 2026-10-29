
*** Settings ***
Documentation
...                 author: JF

Library     OperatingSystem
Library     String
Library     Process
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.sw.dcap.rd             WITH NAME    DCAP
Library     ute_wtssim                 WITH NAME    wts
Library     taf.sw.scout               WITH NAME    scout
Library     ute_fsmaccess              WITH NAME    fsmaccess

Library     pet_robot.py
Library     pet_bts.py
Library     pet_feature_kw.py
Library     pet_feature_kw_sg06.py
Library     pkw_gnbtool.py
Library     pkw_uc.py
Library     pkw_asc.py
Library     pkw_ipsl.py
Library     pkw_tm500.py
Library     pkw_shenick.py
Library     pkw_agent.py
Library     pkw_cpc.py
Library     pkw_l2.py
Library     pkw_jenkins.py
Library     pkw_internal.py
Library     ../gnb_tool.py
Library     pkw_ap.py
Library     pkw_aic.py
Library     pkw_cb008441.py
Resource    taf/rfrl/common_resources/common_step/interface.robot

Resource    ../../../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot


*** Variables ***
${ADMIN_MASTER}                     ${None}
${ADMIN_SLAVE}                      ${None}
${FCT_MASTER}                       ${None}
${FCT_SLAVE}                        ${None}
${FCT_IP}                           192.168.255.129
${ADMIN_IP}                         192.168.255.129
${FCT_USERNAME}                     toor4nsn
${FCT_PASSWORD}                     oZPS0POrRieRtu
${WINPC_USERNAME}                   noklab\csv5-tester
${WINPC_PASSWORD}                   Nokia123!
${LINUXPC_USERNAME}                 ute
${LINUXPC_PASSWORD}                 qqwweeRR0-
${UE1}                              ${None}
${UE2}                              ${None}
${UE3}                              ${None}
${UE4}                              ${None}
${DEBUG_MODE}                       NO
${INSTALL_BUILD}                    YES
${CLEAN_LOG}                        1    # 1: do nothing, 2: clean log only when case passed; 3: always clean log
${CLEAN_LOG_SIZE}                   10    # unit: MB
${CASE_DIRE}                        ${EMPTY}
${RESERVE_RESOURCE}                 ${EMPTY}
${JENKINS_PROJECT}                  ${EMPTY}
${JENKINS_PROJECT_PARAMETERS}       ${EMPTY}
${USE_AIRPHONE}                     N


*** Keywords ***
Start capture s1 message
    Run Keyword And Ignore Error    Pet Fct Stop Tshark    ${FCT_MASTER}
    Pet Fct Start Tshark    ${FCT_MASTER}    sctp    any

Stop capture s1 message
    [Arguments]    ${localfile}
    Pet Fct Stop Tshark    ${FCT_MASTER}
    Pet FCT Get File    ${FCT_MASTER}    /tmp/local.pcap    ${localfile}
#    Counter related kw

Clear PM Counter Files
    Pet FCT Exec Command ${FCT_MASTER}    rm -rf /tmp/PM*
    log    done
