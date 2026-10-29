*** Settings ***
Documentation   TTI and LUA installer script created by WRO_7, modified for WRO_6 purposes.
...
...   Usage:
...       Run: robot -V <path to TL init> -d <log_path> testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/tti_collector_and_lua_installer.robot

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/installers/tti_decoder_installer.py   WITH NAME   tti
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/installers/lua_installer.py   WITH NAME   lua

*** Test Cases ***
TTI Collector And Lua Installer
    tti.installer
    lua.installer
