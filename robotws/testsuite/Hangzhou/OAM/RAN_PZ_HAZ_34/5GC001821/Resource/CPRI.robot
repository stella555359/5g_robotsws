*** Settings ***
Library    OperatingSystem
Library    ../Library/CPRI.py

*** Variables ***
@{RU_CPRI_KEY}   16DF INF/LTX/Uoam_Cpri, DateTimeManager::update
...   16DF INF/LTX/Uoam_Cpri, DateTimeManager::update, update MO and run Rp1 transaction.
...   16DF INF/LTX/Uoam_Cpri, DateTimeManager::getLocalTimestamp, timestamp:

*** Keywords ***
