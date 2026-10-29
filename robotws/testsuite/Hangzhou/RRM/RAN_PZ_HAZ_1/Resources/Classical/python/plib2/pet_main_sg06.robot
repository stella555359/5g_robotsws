*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Library             OperatingSystem
Library             Process

Library             taf.sw.scout    WITH NAME    scout

Library             pet_robot.py
Library             pet_bts.py
Library             pet_feature_kw.py
Library             pet_feature_kw_sg06.py

Library             pkw_gnbtool.py
Library             ../gnb_tool.py
Library             pkw_uc.py
Library             pkw_internal.py
Library             taf.sbts.oam.coam.admin      WITH NAME    coam
Resource            taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***

${admin_master}             ${None}
${admin_slave}              ${None}
${fct_master}               ${None}
${fct_slave}                ${None}

${fct_ip}                   192.168.255.129
${admin_ip}                 192.168.255.129
${fct_username}             toor4nsn
${fct_password}             oZPS0POrRieRtu

${winpc_username}           noklab\csv5-tester
${winpc_password}           Nokia123!
${linuxpc_username}         ute
${linuxpc_password}         qqwweeRR0-

${ue1}                      ${None}
${ue2}                      ${None}
${ue3}                      ${None}
${ue4}                      ${None}

${INSTALL_BUILD}            YES

${CLEAN_LOG}                1     # 1: do nothing, 2: clean log only when case passed; 3: always clean log
${CLEAN_LOG_SIZE}           20    # unit: MB
