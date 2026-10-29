*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for Spirent manipulation
...
...         last update: 10.06.2020

*** Variables ***
${Spirent_PC_ip}=                   ${custom['spirent_pc_ip']}
${Spirent_PC_login}=                ${custom['spirent_pc_login']}
${Spirent_PC_pwd}=                  ${custom['spirent_pc_passwd']}
${Spirent_ip}=                      ${custom['spirent_ip']}
${Spirent_port}=                    ${custom['spirent_port']}