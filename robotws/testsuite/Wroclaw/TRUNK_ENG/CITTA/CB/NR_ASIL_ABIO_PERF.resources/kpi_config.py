"""
User Configuration File for KPI Verification
============================================

This file defines which KPIs should be verified, along with their targets,
dimension filters, reduction methods, and optional overrides of default settings
defined in `kpi_definition.py`.

Each KPI is configured by name under the dictionary `KPI_CONFIGURATION`.

Structure
---------
KPI_CONFIGURATION = {
    "<KPI_NAME>": {
        "target": <float>,                   # Target used for comparison
        "dimension_filters": [
            ["NRCELL-1", "NRSECTOR-1"],      # AND group → both must match
            ["NRCELL-2"],                    # Another case (single pattern)
            # ... more groups as needed
        ],
        "reduction_method": "mean" or "sum", # Optional; default comes from definitions
        "mandatory": True or False           # Optional; include in failure summary
    },
    ...
}

Notes
-----
- All KPI names must exist in `kpi_definition.py`.
- `target` defines the desired threshold used for comparison.
- If `dimension_filters` contains multiple lists, KPI values are calculated
  separately for each.
- If using a *high-level* filter such as `["NRCELL-"]`, one aggregated KPI is
  calculated across all matching dimensions. Specify a `reduction_method`
  ("sum" or "mean") to define how values are combined; if not provided,
  the default from `kpi_definition.py` is used.
- This configuration is consumed by `verify_kpis` via `KpiCalculation` objects
  and compared against the parsed counters data returned by `get_counters_data()`.
"""

KPIS_CONFIG_DATA = {
    "CELL_AVAILABILITY": {},
    "INTRA_FREQ_HO": {
        "dimension_filters": [
            ["NRCELL-3", "MCC-310", "MNC-260"],
            ["NRCELL-8", "MCC-310", "MNC-260"],
            ["NRCELL-11", "MCC-310", "MNC-260"],
        ],
    },
    "INTER_FREQ_HO": {
        "dimension_filters": [
            ["NRCELL-1", "MCC-310", "MNC-260"],
            ["NRCELL-2", "MCC-310", "MNC-260"],
            ["NRCELL-3", "MCC-310", "MNC-260"],
            ["NRCELL-7", "MCC-310", "MNC-260"],
            ["NRCELL-8", "MCC-310", "MNC-260"],
            ["NRCELL-10", "MCC-310", "MNC-260"],
            ["NRCELL-11", "MCC-310", "MNC-260"],
        ],
    },
    "FIVE_QI_ONE_QOS_FLOW_SUCC_SETUP_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "VONR_SDU_RATIO_DL": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "VONR_SDU_RATIO_UL": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "PDCP_SDU_TPUT_DL": {
        "target": 518.0,
    },
    "PDCP_SDU_TPUT_UL": {
        "target": 245.0,
    },
    "SLEEP_CELL_DET_PHASE1_ALARM_SENT": {},
    "SLEEP_CELL_DET_PHASE2_RESET_BASEBAND": {},
    "SLEEP_CELL_DET_PHASE3_RESET_GNB": {},
    "AVG_NON_GBR_USERS": {
        "target": 880.0,
    },
    "AVG_RRC_CONNECTED_USERS": {
        "target": 880.0,
    },
    "MAX_RRC_CONNECTED_USERS": {
        "target": 880.0,
    },
    "QOS_FLOW_SUCC_SETUP_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "AVG_NUM_ACTIVE_VONR_UES": {
        "target": 19.3,
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "MAX_NUM_ACTIVE_VONR_UES": {
        "target": 20,
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "GRB_DRB_ADMISSION_SUCC_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-3"],
            ["NRCELL-7"],
            ["NRCELL-8"],
            ["NRCELL-10"],
            ["NRCELL-11"],
        ],
    },
    "TOTAL_EVENTS_INCL_PAGING": {
        "is_mandatory": False
    }
}
