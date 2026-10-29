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

Resource            Connect.robot
Resource            Tools.robot
Library            ../python/KPIs.py

*** Variables ***
${GUARD_DELAY_DEF}                  40
${GP_DEF}                           300
${PM_AVAIL_DELAY_DEF}               60
${PRINT_PERIOD}                     30

*** Keywords ***
# ==================================
# Services for ZOI (Zone Of Interest)
# ==================================
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
    [Documentation]    Evaluate a set of Counter / KPI threshold constraints using the SWENG KPIs engine (KPIs.py).
    ...
    ...                *Definitions:*
    ...                - PM file: 5G / RAN Performance Measurement XML file providing raw counters and kpis (loaded internally by KPIs.py).
    ...                - Counter Definitions file (Counter_Definitions.csv): Maps counter IDs to their textual description (selected by branch).
    ...                - KPI Definitions file (KPI_Definitions.csv): Provides KPI formulas (Python expressions referencing counters or other KPIs).
    ...                - Constraint file (CSV): Each data line defines one threshold constraint on either a Counter or a KPI:
    ...                    | oam_id | id_extension(optional / PMQAP) | Counter_or_KPI | Min | Max | Variant | Comment |
    ...                - OAM_ID: Network object (e.g. NRBTS[@id='1'], NRCELL[@id='2'] ...). Used to filter counters in the PM file.
    ...                - PMQAP / id_extension: Optional sub‑scope (NRPMQAP) to refine selection; absent or NA means “no PMQAP filtering”.
    ...                - Variant / scope: Hardware / topology discriminator; only constraints whose variant matches active BB (or ALL) are evaluated.
    ...                - Status codes (life‑cycle):
    ...                    | CSV_ERROR          | Malformed CSV line (dropped) |
    ...                    | NOT_GENERIC_FORMAT | Name ends with a non numeric version letter (dropped) |
    ...                    | OUT_OF_SCOPE       | Variant not matching platform (dropped) |
    ...                    | NO_KPI             | ID not found in counters nor KPI definitions (dropped) |
    ...                    | NOT_CHECKED        | Prepared for evaluation but no matching runtime value |
    ...                    | PASSED             | Value within [Min, Max] |
    ...                    | FAILED             | Value outside thresholds |
    ...                    | KEY_ERROR          | Runtime lookup / formula failure (missing counter/KPI variable, eval error) |
    ...                - KEY_ERROR typical causes:
    ...                    | Counter not present in PM file |
    ...                    | KPI formula references missing counter token |
    ...                    | Division by zero (captured) |
    ...                - Reporting portal: Successful PASSED (and FAILED if any) counters / KPIs may be pushed to the reporting portal.
    ...
    ...                *Processing steps (performed by KPIs.py / evaluateConstraints):*
    ...                1. Read Counter & KPI definition CSVs for the active branch (or SBTS00 fallback).
    ...                2. Parse and classify constraints (drop invalid / out of scope).
    ...                3. For each OAM_ID (and PMQAP if present):
    ...                   - Load only required counters (constraint roots + KPI formula tokens).
    ...                   - Evaluate KPI formulas (Python eval in isolated namespace).
    ...                   - Apply thresholds per constraint.
    ...                4. Aggregate final statuses; write synthesis + details to a .kpi log file under ${LOG_PATH}.
    ...                5. Optionally assert if failures (failOnError flag set in lower layer; default = False in this wrapper).
    ...
    ...                *Arguments:*
    ...                - ${pmFile}: Path to the PM XML file to analyze.
    ...                - ${constraintsFile}: Path to the CSV file defining the constraints to evaluate.
    ...                - ${failOnError} (optional, default = False): If True, raise an exception if any constraint FAILED or KEY_ERROR.
    ...                - ${localKpiFile} (optional, default = None): If set, use this local KPI definitions CSV file instead of the branch default.
    ...                - ${usePMQAP} (optional, default = False): If True, consider PMQAP / id_extension column in constraints for filtering.
    ...
    ...                *Returned value:*
    ...                - Boolean like object (True / False) indicating whether all evaluated constraints PASSED (no FAILED / KEY_ERROR counted for
    ...                  pass condition). Detailed statuses are always stored in the generated *.kpi log file.
    ...
    ...                *Generated artifacts:*
    ...                - KPI detail log: ${LOG_PATH}/${constraint_file_basename}_<timestamp>.kpi
    ...                - Portal entries (if reporting portal library is loaded).
    ...
    ...                *Notes / Tips:*
    ...                - Repeated KEY_ERROR suggests missing counter in Counter_Definitions.csv or wrong rootParam spelling.
    ...                - To debug a KPI formula, temporarily print it or lower the setCounters filtering to ensure all referenced counters load.
    ...                - Min / Max both equal creates an exact match constraint.
    ...                - A constraint with value 0 inside [0,0] is reported but may be filtered from final portal report logic.
    ...
    ...                *Example:*
    ...                | ${ok}= | Evaluate Constraints | ${CURDIR}/constraints/NR_CELL_PM.csv | ${scout_kpis_csv} |
    [Arguments]                     ${pmFile}
    ...                             ${constraintsFile}
    ...                             ${failOnError}=${False}
    ...                             ${localKpiFile}=${None}
    ...                             ${usePMQAP}=${False}
    ${isOk}=                        KPIs.evaluateConstraints        pmFile=${pmFile}
    ...                             constraintsFilePath=${constraintsFile}
    ...                             failOnError=${failOnError}
    ...                             localKpiFile=${localKpiFile}
    ...                             usePMQAP=${usePMQAP}
    [Return]                        ${isOk}
