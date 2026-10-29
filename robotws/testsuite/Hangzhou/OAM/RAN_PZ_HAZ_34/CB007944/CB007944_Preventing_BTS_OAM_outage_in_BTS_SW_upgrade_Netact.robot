# *** Settings ***
# Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB007944/Preventing_BTS_OAM_outage_in_BTS_SW_upgrade.robot
# 
# 
# Suite Setup   Suite Setup Steps   webui_tool=COAM    upgrade_tool=netact
# Suite Teardown   Suite Teardown Steps
# 
# Force Tags    CRT  SG_07    CA_5G_OAM    AUTHOR_casbo.xing@nokia-sbell.com
# 
# *** Test Cases ***
# CB007944_Preventing_BTS_OAM_outage_in_BTS_SW_upgrade
#     [Setup]    Test common setup   upgrade_tool=netact   webui_tool=COAM   action=upgrade
#     Preventing_BTS_OAM_outage_in_BTS_SW_upgrade
#     [Teardown]    Test common teardown
# 
