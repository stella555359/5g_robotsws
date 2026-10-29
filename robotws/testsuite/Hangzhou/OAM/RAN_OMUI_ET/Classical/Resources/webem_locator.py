# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: BOAM RD OM OMUI EIT
:contact: yingguo.ying@nokia-sbell.com
:maintainer: BOAM RD OM OMUI EIT
:contact: yingguo.ying@nokia-sbell.com
"""
from __future__ import absolute_import

# login page
INPUT_USERNAME = "//input[@id='login-username']"
INPUT_PASSWORD = "//input[@id='login-password']"
LOGIN_BUTTON = "//span[text()='Login']"
CONFIRM_BUTTON = "//ui-button[@a-text='Confirm']"

# Diagnostic Page
DIAGNOSTIC = "//span[@ui-tooltip='Diagnostic']"
RF_MONITORING = "xpath=//span[text()='RF Monitoring']"
RF_SCAN_AHBCC = "//wf-tabs[@class='rf-monitoring-tabs ng-isolate-scope']/ul/li[4]"
RF_SCAN_AHCA = "//wf-tabs[@class='rf-monitoring-tabs ng-isolate-scope']/ul/li[3]"
SELECT_NR = "//input[@value='NR']"

# Procedures Page
PROCEDURES = "//span[@ui-tooltip='Procedures']"

# On air status
ONAIR = "//div[text()='On air']"
