"""
KPI Definitions (Maintainer-Controlled)
=======================================

This module contains the definitions of all supported KPIs.

Each KPI entry defines:
- `name` and `description`
- `unit` and `comparison_operator`
- `target` (default value, may be overridden by user in config.py)
- `calculation_formula_inputs` (list of counter IDs used as inputs)
- `calculation_formula` (Python function defining KPI computation)
- `dimension_filter_default` (default dimension scope, may be overridden by user in config.py)
- `reduction_method_default` ("mean" or "sum", may be overridden by user in config.py)

These definitions are referenced by `kpi.py` and `kpi_calculation.py` when
building `KpiCalculation` objects and computing KPI values.

Maintenance Policy
------------------
- This file is **maintained by the KPI framework maintainers**, not by users.
- Users should not modify or extend this file directly.
- Requests for additional KPI definitions should be submitted to the
  maintainers via the standard process.

Data Source
-----------
All KPI definitions are based on reference information from:
**MIND** <https://mind.emea.nsn-net.net>

Any formula or counter mapping used here originates from specifications or
reference material maintained in MIND.
"""

from dataclasses import dataclass
import operator
from typing import Callable, Any


@dataclass
class KpiDefinition(object):
    target: float
    max_kpi_value: float | None
    name: str
    description: str
    category: str
    unit: str
    id: str
    comparison_operator: Callable[[float, float], bool]
    calculation_formula_inputs: dict[str, list[str]]
    dimension_filters: list[list[str]]
    calculation_formula: Callable[..., Any]
    reduction_method: str


KPI_DEFINITION = {
    "CELL_AVAILABILITY": KpiDefinition(
        target=100,
        max_kpi_value=100,
        name="[CBT] 5G Cell Availability Ratio",
        description=(
            "This KPI shows the ratio of time in which services in a cell are available for end users."
        ),
        category="Accessibility",
        unit="%",
        id="NR_5150",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55601C00002"],
            "denom": ["M55601C00001"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "INTRA_FREQ_HO": KpiDefinition(
        target=99,
        max_kpi_value=100,
        name="[CBT] 5G SA intra-frequency intra-gNB intra-DU handover total success ratio",
        description=(
            "This KPI shows the total success ratio of the intra-frequency intra-gNB intra-DU procedure"
            " in standalone operation."
            " It is calculated as the ratio of successful executions over the number of preparation attempts."
        ),
        category="Mobility",
        unit="%",
        id="NR_5177",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55145C00302"],
            "denom": ["M55145C00301", "M55145C00303", "M55145C00304"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "INTER_FREQ_HO": KpiDefinition(
        target=99,
        max_kpi_value=100,
        name="[CBT] 5G SA Intra-gNB intra-DU inter-frequency HO total success ratio per PLMN",
        description=(
            "This KPI shows the handover total success ratio for 5G SA Intra-gNB Intra-DU inter-frequency per PLMN"
        ),
        category="Mobility",
        unit="%",
        id="NR_5429",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55145C00322"],
            "denom": ["M55145C00321", "M55145C00323", "M55145C00324"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "FIVE_QI_ONE_QOS_FLOW_SUCC_SETUP_RATIO": KpiDefinition(
        target=99,
        max_kpi_value=100,
        name="[CBT] 5G SA 5QI-1 QoS flow setup success ratio excluding fallback",
        description=(
            "This KPI shows the success ratio for 5QI-1 QoS flow setup,"
            " excluding the cases when fallback procedure is initiated."
            " Formula excludes fallback cases to exclude impact of UEs not supporting"
            " VoNR and UEs not configured for VoNR."
        ),
        category="Accessibility",
        unit="%",
        id="NR_5576",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55125C09518"],
            "denom1": ["M55125C09517"],
            "denom2": ["M55125C09519"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / (kwargs["denom1"] - kwargs["denom2"])
        ).round(2),
        reduction_method="mean",
    ),
    "VONR_SDU_RATIO_DL": KpiDefinition(
        target=4,
        max_kpi_value=None,
        name="[CBT] 5G SA SDU discard ratio for VoNR in DL",
        description=(
            "This KPI shows the discard ratio of 5QI1 MAC SDUs discarded"
            " because the UE was not able to decode the MAC SDU"
            " after the gNB sent maximum number of HARQ retransmissions."
        ),
        category="Others",
        unit="%",
        id="NR_1311",
        comparison_operator=operator.lt,
        calculation_formula_inputs={
            "num": ["M55300C12001"],
            "denom": ["M55308C24001"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "VONR_SDU_RATIO_UL": KpiDefinition(
        target=4,
        max_kpi_value=None,
        name="[CBT] 5G SA SDU discard ratio for VoNR in UL",
        description=(
            "This KPI shows the discard ratio of uplink 5QI1 MAC SDUs that were not received by the gNB"
            " because the gNB was not able to decode the MAC SDU after maximum uplink HARQ retransmissions."
        ),
        category="Others",
        unit="%",
        id="NR_1312",
        comparison_operator=operator.lt,
        calculation_formula_inputs={
            "num": ["M55302C10001"],
            "denom": ["M55308C24002"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "PDCP_SDU_TPUT_DL": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA PDCP SDU throughput in downlink",
        description=(
            "This KPI shows the SA PDCP SDU throughput in downlink direction, calculated in the measurement period."
        ),
        category="Cell throughput",
        unit="Mbps",
        id="NR_5094",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": [
                "M55319C12001",
                "M55319C12002",
                "M55319C12003",
                "M55319C12004",
                "M55319C12005",
                "M55319C12006",
                "M55319C12007",
                "M55319C12008",
                "M55319C12009",
                "M55319C12010",
                "M55319C12011",
                "M55319C12012",
                "M55319C12013",
                "M55319C12014",
                "M55319C12015",
                "M55319C12016",
                "M55319C12017",
                "M55319C12018",
                "M55319C12019",
                "M55319C12020",
            ],
            "denom": ["M55319C00001"],
        },
        dimension_filters=[["NRBTS-1"]],
        calculation_formula=lambda **kwargs: (
            (8 * kwargs["num"]) / (1000 * kwargs["denom"])
        ).round(2),
        reduction_method="sum",
    ),
    "PDCP_SDU_TPUT_UL": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA PDCP SDU throughput in uplink",
        description=(
            "This KPI shows the SA PDCP SDU throughput in uplink direction, calculated in the measurement period."
        ),
        category="Cell throughput",
        unit="Mbps",
        id="NR_5095",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": [
                "M55319C16001",
                "M55319C16002",
                "M55319C16003",
                "M55319C16004",
                "M55319C16005",
                "M55319C16006",
                "M55319C16007",
                "M55319C16008",
                "M55319C16009",
                "M55319C16010",
                "M55319C16011",
                "M55319C16012",
                "M55319C16013",
                "M55319C16014",
                "M55319C16015",
                "M55319C16016",
                "M55319C16017",
                "M55319C16018",
                "M55319C16019",
                "M55319C16020",
            ],
            "denom": ["M55319C00001"],
        },
        dimension_filters=[["NRBTS-1"]],
        calculation_formula=lambda **kwargs: (
            (8 * kwargs["num"]) / (1000 * kwargs["denom"])
        ).round(2),
        reduction_method="sum",
    ),
    # Sleeping cell detection KPIs, CB008144
    # KPIs are included in the 5G046 Sleeping cell recovery algorithm report
    "SLEEP_CELL_DET_PHASE1_ALARM_SENT": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G Number of phase 1 sleeping cell detections completed - alarm sent",
        description=(
            "This KPI shows the number of time the phase 1 of the sleeping cell recovery procedure has been completed."
            " The phase 1 consists in sending an alarm."
        ),
        category="Others",
        unit="#",
        id="NR_1614",
        comparison_operator=operator.le,
        calculation_formula_inputs={
            "num": [
                "M55601C00003",
                "M55601C00006",
                "M55601C00009",
                "M55601C01503",
                "M55601C01504",
                "M55601C01506",
                "M55601C01508",
                "M55601C01511",
                "M55601C01514",
                "M55601C01517",
                "M55601C01520",
            ]
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: kwargs["num"],
        reduction_method="sum",
    ),
    "SLEEP_CELL_DET_PHASE2_RESET_BASEBAND": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G Number of phase 2 sleeping cell detections completed - reset baseband",
        description=(
            "This KPI shows the number of time the phase 2 of the sleeping cell recovery procedure has been completed."
            " The phase 2 consists of baseband reset (all cells on the card wil be reset)."
        ),
        category="Others",
        unit="#",
        id="NR_1615",
        comparison_operator=operator.le,
        calculation_formula_inputs={
            "num": [
                "M55601C00004",
                "M55601C00007",
                "M55601C00010",
                "M55601C01501",
                "M55601C01509",
                "M55601C01512",
                "M55601C01515",
                "M55601C01518",
            ]
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: kwargs["num"],
        reduction_method="sum",
    ),
    "SLEEP_CELL_DET_PHASE3_RESET_GNB": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G Number of phase 3 sleeping cell detections completed - reset gNB",
        description=(
            "This KPI shows the number of time the phase 3 of the sleeping cell recovery procedure has been completed."
            " The phase 3 consists of gNB reset (all cells on site wil be reset)."
        ),
        category="Others",
        unit="#",
        id="NR_1616",
        comparison_operator=operator.le,
        calculation_formula_inputs={
            "num": [
                "M55601C00005",
                "M55601C00008",
                "M55601C00011",
                "M55601C01502",
                "M55601C01505",
                "M55601C01507",
                "M55601C01510",
                "M55601C01513",
                "M55601C01516",
                "M55601C01519",
                "M55601C01521",
            ]
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: kwargs["num"],
        reduction_method="sum",
    ),
    "AVG_NON_GBR_USERS": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA Average number of SA non-GBR users",
        description=(
            "This KPI shows the average number of non-GBR users having one or more DRBs in stand alone operation."
            " KPI values are aggregated (sum) over the object dimension."
            " Meaning that, if KPI is calculated over PLMN object, it shows the average number of users in all PLMN."
        ),
        category="Others",
        unit="#",
        id="NR_5127",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55138C00012"],
            "denom": ["M55138C00013"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (kwargs["num"] / kwargs["denom"]).round(2),
        reduction_method="sum",
    ),
    "AVG_RRC_CONNECTED_USERS": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA Average number of SA RRC connected users",
        description=(
            "This KPI shows the average number of RRC connected users in stand alone operation."
            " KPI values are aggregated (sum) over the object dimension."
            " Meaning that, if KPI is calculated over PLMN object, it shows the average number of users in all PLMN."
        ),
        category="Others",
        unit="#",
        id="NR_5128",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55138C00008"],
            "denom": ["M55138C00009"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (kwargs["num"] / kwargs["denom"]).round(2),
        reduction_method="sum",
    ),
    "MAX_RRC_CONNECTED_USERS": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA Maximum number of SA RRC connected users",
        description=("This KPI shows the maximum number of SA RRC connected users"),
        category="Others",
        unit="#",
        id="NR_5129",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55138C00014"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: kwargs["num"],
        reduction_method="sum",
    ),
    "QOS_FLOW_SUCC_SETUP_RATIO": KpiDefinition(
        target=99,
        max_kpi_value=100,
        name="[CBT] 5G SA QoS Flow Setup Success Ratio",
        description=("This KPI shows the Success Ratio for QoS Flow setup"),
        category="Accessibility",
        unit="%",
        id="NR_5345",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55125C08502"],
            "denom": ["M55125C08501"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "AVG_NUM_ACTIVE_VONR_UES": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA Average number of active VoNR UEs in selected area",
        description=(
            "This KPI shows the average number of RRC connected VoNR UEs."
            " KPI values are aggregated (sum) over the object dimension."
            " Meaning that, if KPI is calculated over PLMN object, it shows the average number of users in all PLMN."
        ),
        category="Others",
        unit="#",
        id="NR_5333",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55125C09528"],
            "denom": ["M55125C09529"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (kwargs["num"] / kwargs["denom"]).round(2),
        reduction_method="sum",
    ),
    "MAX_NUM_ACTIVE_VONR_UES": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G SA Maximum number of active VoNR UEs",
        description=("This KPI shows the maximum number of RRC connected VoNR UEs"),
        category="Others",
        unit="#",
        id="NR_5334",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55125C09530"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: kwargs["num"],
        reduction_method="sum",
    ),
    "GRB_DRB_ADMISSION_SUCC_RATIO": KpiDefinition(
        target=99,
        max_kpi_value=100,
        name="[CBT] 5G SA GRB DRBs admission control success ratio",
        description=(
            "This KPI shows the success ratio of admission control for GRB DRBs"
        ),
        category="Accessibility",
        unit="#",
        id="NR_1277",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": ["M55138C01002"],
            "denom": ["M55138C01001"],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            (100 * kwargs["num"]) / kwargs["denom"]
        ).round(2),
        reduction_method="mean",
    ),
    "TOTAL_EVENTS_INCL_PAGING": KpiDefinition(
        target=0,
        max_kpi_value=None,
        name="[CBT] 5G Total events per second including paging",
        description=(
            "This KPI shows the total number of events per second including paging. "
            "The events are NSA calls and releases + NSA Handovers + NSA CA configurations "
            "and de-configurations + SA SRBs establishments and releases + SA calls and "
            "releases + SA additional DRB establishments + SA handovers + CA configurations "
            "and de-configurations + pagings + NR-DC connection establishments and releases."
        ),
        category="Others",
        unit="#/s",
        id="NR_2193e",
        comparison_operator=operator.ge,
        calculation_formula_inputs={
            "num": [
                # "M55112C00002",
                # "M55112C00010",
                # "M55112C00007",
                # "M55112C00005",
                # "M55120C00001",
                # "M55120C00501",
                # "M55120C00004",
                # "M55151C00001",
                # "M55151C00002",
                # "M55151C00005",
                # "M55151C00007",
                # "M55151C00008",
                # "M55112C02501",
                # "M55118C02000",
                # "M55118C02001",
                # "M55118C02002",
                # "M55118C02003",
                # "M55118C02004",
                # "M55118C02005",
                # "M55118C02006",
                # "M55118C02007",
                # "M55118C02008",
                # "M55118C02009",
                # "M55118C02010",
                # "M55118C02011",
                # "M55118C02012",
                # "M55118C02013",
                # "M55118C06503",
                # "M55124C01001",
                # "M55124C01002",
                # "M55124C01003",
                # "M55124C01004",
                # "M55124C01005",
                # "M55124C01006",
                # "M55124C01014",
                # "M55124C01015",
                # "M55124C01016",
                # "M55124C01017",
                # "M55124C00008",
                # "M55124C00007",
                # "M55124C00001",
                # "M55125C00014",
                # "M55125C00016",
                # "M55125C00018",
                # "M55125C02504",
                "M55145C00301",
                "M55145C00303",
                "M55145C00304",
                "M55145C00321",
                "M55145C00323",
                "M55145C00324",
                # "M55147C00011",
                # "M55147C00013",
                # "M55147C00014",
                # "M55147C00030",
                # "M55147C00032",
                # "M55147C00033",
                "M55145C00341",
                # "M55125C07501",
                # "M55125C07502",
                # "M55143C00005",
                # "M55125C07503",
                # "M55125C02001",
                "M55145C00351",
                # "M55142C00501",
                # "M55118C05505",
                # "M55118C07004",
                # "M55118C09503",
                # "M55118C02015",
                # "M55118C00001",
                # "M55118C00002",
                # "M55118C00003",
                # "M55118C10001",
                # "M55118C00007",
                # "M55118C00008",
                # "M55118C06501",
                # "M55118C10003",
                # "M55119C01501",
                # "M55116C00038",
                # "M55116C00046",
                # "M55116C00048",
                # "M55116C00052"
            ],
        },
        dimension_filters=[["NRCELL-"]],
        calculation_formula=lambda **kwargs: (
            kwargs["num"] / 300
        ).round(2),
        reduction_method="sum",
    )
}
