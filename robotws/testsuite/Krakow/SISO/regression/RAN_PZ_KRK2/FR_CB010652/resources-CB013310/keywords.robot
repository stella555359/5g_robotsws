*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013310-B
...   author: Przemyslaw Gajewski, przemyslaw.gajewski@nokia.com
...   maintainer: Przemyslaw Gajewski, przemyslaw.gajewski@nokia.com


Library     BuiltIn
Library     taf.sbts.oam.coam.admin     WITH NAME    admin
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME    AsirWebEM
Library     ./keywords_py.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***

${APP_ADMIN_USERNAME}                       BTSApplication
${APP_ADMIN_PASSWORD}                       Krk1234!
${DIR_WITH_SCF}                             /home/ute/scf_directory
${SCF_FILE_NAME}                            ASIR_SCF.xml
${BTS_ADDRESS}                              192.168.255.129
${BTS_PORT}                                 443
${USE_SSL}                                  True
${VIRTUAL_DISPLAY}                          ${True}

&{EXPECTED_GREYED_OUT_BUTTONS_APP_ADMIN}    edit=${True}
...                                         load file=${True}
...                                         load template=${False}
...                                         detect=${False}
...                                         view=${True}
...                                         save=${True}
...                                         reset=${False}
...                                         accounts=${False}

*** Keywords ***
Change ASiR SCF Filename
   Run   cd ${DIR_WITH_SCF}; mv "$(ls -t ${DIR_WITH_SCF} | head -n 1)" ${SCF_FILE_NAME}

Use Scf From Directory
   ${files}=   List Files In Directory   path=${DIR_WITH_SCF}
   ${full_path}=   Join Path   ${DIR_WITH_SCF}   ${files}
