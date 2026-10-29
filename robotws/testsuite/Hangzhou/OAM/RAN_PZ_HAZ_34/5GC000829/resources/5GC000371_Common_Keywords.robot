*** Settings ***
Documentation
...    author: Li YIngying
...    contact: yingying.li@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library     taf.sbts.oam.coam.admin   WITH NAME   coam
Library     taf.transport.ssh    WITH NAME    csn
Library     OperatingSystem
Library     Collections
Library     BuiltIn
Library 	DateTime
Library 	String

Resource      ../../../../../testsuite/OAM/Hangzhou/CB005750-5G-EBAO/Resources/CB005750-5G-EBAO_Common_Keywords.robot

*** Variables ***
${Results}		 	/tmp/5GC000371
${ru_sn}    ${tl.gnbs[0].dus[0].rus[0].serial_number}
${ASIL_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIL_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIL_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***


