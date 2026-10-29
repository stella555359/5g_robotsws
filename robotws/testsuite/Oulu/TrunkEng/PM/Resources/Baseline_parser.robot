*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

...   The BaselineParser is used to parse the baseline files and combine them into one file.

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.BaselineParser      WITH NAME  BaselineParser

*** Variables ***
@{BASELINES}             testsuite/Oulu/TrunkEng/PM/Resources/LTE_Counters.xml
...                      testsuite/Oulu/TrunkEng/PM/Resources/SOAM_Counters.xml
${SAVE_LOCATION}         testsuite/Oulu/TrunkEng/PM/Resources/baseline_SBTS25R2.xml

*** Test Cases ***
Baseline Parser
    BaselineParser.Parse Baseline Files    ${BASELINES}  ${SAVE_LOCATION}
