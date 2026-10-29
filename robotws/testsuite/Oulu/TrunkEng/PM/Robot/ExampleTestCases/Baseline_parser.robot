*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  pekka.lonnakko@nokia.com

...   The BaselineParser is used to parse the baseline files and combine them into one file.

Library     testsuite.Oulu.TrunkEng.PM.Python.Interfaces.BaselineParser      WITH NAME  BaselineParser

*** Variables ***
@{BASELINES}             testsuite/Oulu/TrunkEng/PM/Resources/5GCounters.xml
...                      testsuite/Oulu/TrunkEng/PM/Resources/SBTSCounters.xml
...                      testsuite/Oulu/TrunkEng/PM/Resources/LTECounters.xml
${SAVE_LOCATION}         testsuite/Oulu/TrunkEng/PM/Resources/Baseline_combined.xml

*** Test Cases ***
Baseline Parser
    BaselineParser.Parse Baseline Files    ${BASELINES}  ${SAVE_LOCATION}
