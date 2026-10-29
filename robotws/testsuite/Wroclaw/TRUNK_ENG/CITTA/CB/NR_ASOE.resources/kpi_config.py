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
            ["NRCELL-1", "MCC-311", "MNC-489"],
            ["NRCELL-2", "MCC-311", "MNC-489"],
            ["NRCELL-3", "MCC-311", "MNC-489"],
            ["NRCELL-4", "MCC-311", "MNC-489"],
            ["NRCELL-5", "MCC-311", "MNC-489"],
            ["NRCELL-6", "MCC-311", "MNC-489"],
        ],
    },
    "FIVE_QI_ONE_QOS_FLOW_SUCC_SETUP_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "VONR_SDU_RATIO_DL": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "VONR_SDU_RATIO_UL": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "PDCP_SDU_TPUT_DL": {
        "target": 340.0,
    },
    "PDCP_SDU_TPUT_UL": {
        "target": 300.0,
    },
    "SLEEP_CELL_DET_PHASE1_ALARM_SENT": {},
    "SLEEP_CELL_DET_PHASE2_RESET_BASEBAND": {},
    "SLEEP_CELL_DET_PHASE3_RESET_GNB": {},
    "AVG_NON_GBR_USERS": {
        "target": 240.0,
    },
    "AVG_RRC_CONNECTED_USERS": {
        "target": 240.0,
    },
    "MAX_RRC_CONNECTED_USERS": {
        "target": 240.0,
    },
    "QOS_FLOW_SUCC_SETUP_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "AVG_NUM_ACTIVE_VONR_UES": {
        "target": 4.8,
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "MAX_NUM_ACTIVE_VONR_UES": {
        "target": 5,
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "GRB_DRB_ADMISSION_SUCC_RATIO": {
        "dimension_filters": [
            ["NRCELL-1"],
            ["NRCELL-2"],
            ["NRCELL-3"],
            ["NRCELL-4"],
            ["NRCELL-5"],
            ["NRCELL-6"],
        ],
    },
    "TOTAL_EVENTS_INCL_PAGING": {
        "is_mandatory": False
    }
}
