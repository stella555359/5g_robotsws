*** Settings ***
Documentation    author: Deng xueqin
...              Group: HGZ_SG7
...              contact: xueqin.deng@nokia-sbell.com
...              Description

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
#Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Resource    ../../../../../resources/common/asod.robot
Resource    ../../common/robot/ecpri_transport_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
