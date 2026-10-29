# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:contact: yuyan.xu@nokia-sbell.com
:maintainer: I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
:These variables are releated WebUI xpath
"""
from __future__ import absolute_import

# login page
INPUT_USERNAME = "//input[@id='login-username']"
INPUT_PASSWORD = "//input[@id='login-password']"
LOGIN_BUTTON = "//ui-webem-button[@id='login-button']"
CONFIRM_BUTTON = "//span[contains(text(),'Confirm')]"
STARTUP_VIEW = "//span[contains(text(),'Start-up View')]"
STARTUP_VIEW_CLOSE_BUTTON = "//p-button[@id='Close']"
CHANGE_PASSWORD = "//div[contains(text(), 'Change password')]"
INPUT_CURRENT_PASSWD = "//input[@id='current-password']"
INPUT_NEW_PASSWD = "//input[@id='new-password']"
INPUT_CONFIRM_PASSWD = "//input[@id='confirm-password']"
SAVE_PASSWD = "//span[contains(text(),'Save')]"

# ALD Status Page
DASHBOARD_SIDEBAR_STATUS = "//i[contains(@class,'mdi-shield-check')]"
ALD_STATUS_VIEW = "//*[@id='/status/ald-status']"
RET_STATUS_VIEW = "//span[contains(text(),'RET Status View')]"
RET_WIDGET = "//div[@class='ret-tile-view']"
RETU_WIDGET = "//div[@class='retu-view']"
RETU_BODY = "//div[@class='retu-body']"
RAE_STATUS_VIEW = "//span[contains(text(),'RAE Status View')]"
RAE_WIDGET = "//div[@class='rae-tile-view']"
RAE_TILE_BODY = "//div[@class='rae-tile-body']"
RAEU_BODY = "//div[@class='raeu-body']"
MHA_STATUS_VIEW = "//span[contains(text(),'MHA Status View')]"
MHA_WIDGET = "//div[@class='mha-tile-view']"
LNA_WIDGET = "//div[@class='lna-view']"
LNA_BODY = "//div[@class='lna-body']"
ALD_SITE_VIEW = "//span[contains(text(),'Site View')]"
RET_OPERATION_BUTTON = "//div[@class='ret-tile-view']//p-button[@title='Operations']"
LNA_OPERATION_BUTTON = "//div[@class='lna-view']//p-button[@title='Operations']"
CONFIGURE_BUTTON = "//span[contains(text(),'Configure')]"
FILTER_BUTTON = "//span[contains(text(),'Filter')]"
RESTORE_BUTTON = "//span[contains(text(),'Restore Default View')]"
SORT_BUTTON = "//span[contains(text(),'Sort')]"
TABLE_VIEW_BUTTON = "//span[contains(text(),'Table View')]"
WIDGET_VIEW_BUTTON = "//span[contains(text(),'Widget View')]"
EXPORT_BUTTON = "//span[contains(text(),'Export')]"

# Alarm Page
DASHBOARD_SIDEBAR_ALARM = "//i[contains(@class,'mdi-bell')]"
FAULT_TOGGLING_HISTORY = "//span[contains(text(),'Fault Toggling History')]"
ACTIVE_ALARMS = "//span[contains(text(),'Active Alarms')]"
HISTORICAL_ALARMS = "//span[contains(text(),'Historical Alarms')]"
SAVE_FAULT_TOGGLING_HISTORY = "//span[contains(text(),'Save Fault Toggling History')]"

# Diagnostic Page
DASHBOARD_SIDEBAR_DIAGNOSTIC = "//i[contains(@class,'mdi-stethoscope')]"
SFP_MONITORING = "//a[contains(text(),'SFP Monitoring')]"

# Options Page
DASHBOARD_SIDEBAR_OPTIONS = "//i[contains(@class,'mdi-cogs')]"
OPERATIONS_HISTORY = "//a[contains(text(),'Operations History')]"

# Parameter Editor Page
DASHBOARD_SIDEBAR_CONFIGURATION = "//i[contains(@class,'mdi-settings')]"
PARAMETER_EDITOR = "//span[contains(text(),'Parameter Editor')]"
OBJECT_FILTER = "//input[@id='filter-input-field-plans-tree']"
ABBREVIATION_FILTER = "//input[@id='filter-input-field-name']"
PARAMETER_FILTER = "//div[@id='parameter-search-input']/div/input"
PARAMETER_SEARCH = "//span[contains(text(),'Parameter Search')]"

# Dashboard Page
DASHBOARD_SIDEBAR_dashboard = "//i[contains(@class,'mdi-view')]"
