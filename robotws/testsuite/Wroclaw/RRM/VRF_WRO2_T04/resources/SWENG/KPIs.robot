*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage computation of constraints on a KPI or a counter
...
...             == Description ==
...             *Concepts:*.
...
...             A counter is a basic measure on a network object produced by OAM and regularly pushed in PM files.
...             A KPI is an enhanced indicator supporting a mathematic formula using basic counters.
...             For each branch (TRUNK or other), a counter file and a KPI file are set in SWENG/config/KPI/<Branch> directory.
...             A constraint is a set of thresholds (min and max) associated to a parameter (counter or KPI) and an oam object.
...             Some constraints files can be built for any tests in a feature.
...
...             Then, after a test, some SWENG services allows to check those constraints, meaning to parse a PM file,
...             and check for each constraint, that kpi for the targetted oam object is inside thresholds.
...
...
...             Also, to ease management of collecting PM at pertinent moment, the concept of ZOI (Zone Of Interest) is introduced.
...             A ZOI is composed of :
...             | Guard                | Guard Delay before PM evaluation period                                             |
...             | GP                   | Granularity Period for PM generation                                                |
...             | PM Availability      | Additional delay to ensure PM files are properly generated and retrieved by test VM |
...
...             *Services:*.
...
...             Main services are :
...             | ZOI Start            | To start a ZOI                                              |
...             | ZOI Remaining Sec    | To compute number of seconds remaining before end of a ZOI  |
...             | ZOI Wait End         | To loop and wait until expiration of a ZOI                  |
...             | ZOI Repeat Until End | To loop and execute a KW until epiration of a ZOI           |
...             | KPI Evaluate         | to evaluate constraints associated to a test                |
...
...             Typical sequence to use these services is as follows:
...               ${zoi}                          ZOI Start
...               ZOI Wait End                    zoi=${zoi}
...               # retrieving PM file -> ${PM_FILE}
...               KPI Evaluate                    pmFile=${PM_FILE}
...               ...                             constraintsFile=${CONSTRAINTS_FILE}
...               ...                             failOnError=${True}
...     6.02.25 - CloudRan TCs + KPIs resource copied from NPS to WRO_2_4 (regression takeover), whole resources replaced

Library             taf.sw.reporting_portal
Library            KPIs.py

*** Variables ***
${GUARD_DELAY_DEF}                  40
${GP_DEF}                           300
${PM_AVAIL_DELAY_DEF}               60
${PRINT_PERIOD}                     30

*** Keywords ***
## ==================================
## Services for ZOI (Zone Of Interest)
## ==================================
ZOI Start
    [Documentation]                 Create an instance of ZOI (Zone Of Interest), and start it.
    ...                             It computes date for next GP start after a guard delay,
    ...                             then add GP period and an additional period for PM files availability.
    ...                             Example : let say we set : GuardDelay=40s, GP=5mn, PM_AVAIL_DELAY=1mn.
    ...                             - at 11:54:00, it will set end time to 12:01 (GP period will run from 11:55 to 12:00).
    ...                             - at 11:54:30, it will set end time to 12:06
    ...                             (after Guard delay [11:55:10], GP period for 11:55 has already start, so waiting for next one)
    [Arguments]                     ${guardDelay}=${GUARD_DELAY_DEF}
    ...                             ${gp}=${GP_DEF}
    ...                             ${pmAvailDelay}=${PM_AVAIL_DELAY_DEF}
    ${zoi}                          KPIs.newZOI
    ...                               guardDelay=${guardDelay}
    ...                               gp=${gp}
    ...                               pmAvailDelay=${pmAvailDelay}
    call method                     ${zoi}                                  start
    [Return]                        ${zoi}

ZOI Remaining Sec
    [Documentation]                 Return the current number of seconds remaining before expiration of a ZOI.
    [Arguments]                     ${zoi}
    ${sec}                          call method                             ${zoi}
    ...                             remainingTime
    [Return]                        ${sec}

ZOI Wait End
    [Documentation]                 Loop and wait until expiration of a ZOI.
    ...                             Optionnally, a reminder message can be printed regularly, with remaining time.
    [Arguments]                     ${zoi}                                  ${printPeriod}=${PRINT_PERIOD}
    call method                     ${zoi}                                  waitEnd
    ...                             printPeriod=${printPeriod}

ZOI Repeat Until End
    [Documentation]                 Loop on execution of a KW until the ZOI is expired
    ...                             If at ZOI expiration, KW is still in progress, it will end until the end of it
    ...                             in order to ensure it ends properly.
    [Arguments]                     ${zoi}                                  ${kw}
    ...                             @{args}
    ${sec}                          ZOI Remaining Sec                       zoi=${zoi}
    repeat keyword                  ${sec} sec
    ...                             ${kw}                                   @{args}

# ==================================
# Services for KPI
# ==================================
KPI Evaluate
    [Documentation]                 Parse a PM file and evaluate all constraints embedded in a Constraint file,
    ...                             to check they are respected (inside thresholds).
    ...                             if some errors appear during constraint file parsing, constraints are put in drop list
    ...                             with a particular status: CSV_ERROR (error in CSV file), NO_KPI (kpi not found),
    ...                             OUT_OF_SCOPE (constraint scope not in line with current branch of TL),
    ...                             NOT_GENERIC_FORMAT (constraint name ends with a version char).
    ...                             After evaluation, each kept constraint is display with a status, that can be :
    ...                             - NOT_CHECKED : No occurence of (oam object id/PM) found matching this constraint.
    ...                             - PASSED      : PM inside threshold.
    ...                             - FAILED      : PM outside threshold.
    ...                             - KEY_ERROR   : kpi/counter not found in PM file.
    ...                             If some errors occur and ${failOnError} flag is set to ${True}, Test will fail.
    [Arguments]                     ${pmFile}
    ...                             ${constraintsFile}
    ...                             ${failOnError}=${False}
    ${isOk}=                        KPIs.evaluateConstraints        pmFile=${pmFile}
    ...                             constraintsFile=${constraintsFile}
    ...                             failOnError=${failOnError}
    [Return]                        ${isOk}
