*** Settings ***
Documentation     author: Abderrahmane NEZROUK
...               contact: abderrahmane.nezrouk@Nokia.com
...
...               Sample example of attach/detach QCAT licence to Ue PC.

Library         BuiltIn
Library         ${CURDIR}/../../../resources/ST/python/LK_manager.py    WITH NAME    LK

*** Variables ***
#LK account
${LKC_LOGIN_USER}      abderrahmane.nezrouk@nokia.com
${LKC_LOGIN_PWD}       Nokia2019


*** Keywords ***
Prepare LK
    LK.prepare    	hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    ...    ssh_username=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.login}
    ...    ssh_password=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.password}
    ...    lk_username=${LKC_LOGIN_USER}
    ...    lk_password=${LKC_LOGIN_PWD}


Get QXDM 5G Licence
    LK.get_licence_qxdm_5g    timeout=${30}

Release QXDM 5G Licence
    LK.release_licence_qxdm_5g    timeout=${30}

Get QCAT 5G Licence
    LK.get_licence_qcat_5g    timeout=${30}

Release QCAT 5G Licence
    LK.release_licence_qcat_5g    timeout=${30}

Disconnect keeper
	LK.disconnect

Shutdown keeper
	Release QXDM and QCAT Licence
    LK.disconnect

Get QXDM and QCAT Licence
    Keep QXDM 5G Licence
    Keep QCAT 5G Licence

Release QXDM and QCAT Licence
    Drop QXDM 5G Licence
    Drop QCAT 5G Licence
