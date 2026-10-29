*** Settings ***
Documentation     author: Abderrahmane NEZROUK
...               contact: abderrahmane.nezrouk@Nokia.com
...               wiki: https://nokia.sharepoint.com/sites/nps_iv_automation_guild/SitePages/
...                        How-to-use-QPM-Licence-Keeper-in-Automation-code.aspx
...

*** Keywords ***
Attach QCAT 5G Licence with LK
    Connect LK
    Get QCAT 5G Licence
    Disconnect LK

Detach QCAT 5G Licence with LK
    Connect LK
    Release QCAT 5G Licence
    Disconnect LK

Connect LK
    LK_handler.connect    hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}

Get QCAT 5G Licence
    LK_handler.qcat_5g_get_licence    retry=10

Release QCAT 5G Licence
    LK_handler.qcat_5g_release_licence    retry=10

Disconnect LK
	LK_handler.disconnect
