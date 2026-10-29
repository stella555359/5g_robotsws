import random
from core.RegexWatcher import *
from scenarios.Static_SA import *
from scenarios.Static_NSA import *
from scenarios.Mobility_NSA import *
from scenarios.Mobility_SA import *
from scenarios.RF_changing_SA import *
import inspect
import re


def assign_ue_id(scenarios):
    """
    Assigns a unique ue_id to each scenario based on its name pattern (SA or NSA)
    and the target_cell value.

    Rules:
    - SA_xxx_: Extracts a 3-digit number (e.g., "SA_023_").
      - The first digit of ue_id is mapped from target_cell:
          {1 → "7", 21 → "2", 201 → "4", default → "0"}.
      - The remaining 3 digits are taken directly from the pattern (e.g., "023").
      - Example: name="SA_023_", target_cell=21 → ue_id=2023.

    - NSA_xxx: Extracts a 3-digit number (e.g., "NSA_023").
      - For target_cell=1: ue_id = 1000 + number (1001–1061).
      - For target_cell=201: ue_id = 1060 + number (1061–1121).
      - Other target_cell values are ignored.

    - Scenarios without a matching pattern are skipped.

    The assigned ue_id is stored in scenario["args"]["ue_id"].

    Returns:
        list: The input scenarios with ue_id added where applicable.
    """
    for scenario in scenarios:
        name = scenario["name"]
        target_cell = scenario["args"]["target_cell"]

        # Check for SA pattern
        sa_match = re.search(r"_SA_(\d{3})", name)
        # Check for NSA pattern
        nsa_match = re.search(r"_NSA_(\d{3})", name)

        if sa_match:
            num3 = sa_match.group(1)   # e.g. "001", "023", "142"

            # mapping target_cell -> first digit
            cell_map = {1: "7", 21: "2", 201: "4"}
            first_digit = cell_map.get(target_cell, "0")

            # build ue_id
            ue_id = int(first_digit + num3)

        elif nsa_match:
            num3 = int(nsa_match.group(1))  # numeric offset 001 → 1, etc.

            if target_cell == 1:
                base = 1000
                ue_id = base + num3   # 1001–1061 if num3 = 1–61
            elif target_cell == 201:
                base = 1060
                ue_id = base + num3   # 1062–1122 if num3 = 1–61
            else:
                continue  # skip if unsupported target_cell

        else:
            continue  # no match, skip

        # assign it
        scenario["args"]["ue_id"] = ue_id

    return scenarios


def should_run(rate, cycle_index, offset=0):
    """
    Determines whether a scenario should execute on a given cycle index based
    on its occurrence rate. A rate of 0 or below never runs, a rate of 1 or
    above always runs. For fractional rates (e.g. 0.5), an interval is derived
    by rounding 1/rate and the scenario runs only on cycles that land on that
    interval. Accepts an offset to stagger when the scenario
    first becomes active, distributing scenarios with the same rate
    across different cycles instead of synchronizing them all.

    Args:
        rate (float): How often the scenario should run per cycle.
                      - rate <= 0: never runs.
                      - 0 < rate < 1: runs every round(1/rate) cycles.
                      - rate >= 1: always runs.
        cycle_index (int): The current cycle number (0-based).
        offset (int): Per-scenario phase offset, randomized at plan build time.

    Returns:
        bool: True if the scenario should run on this cycle, False otherwise.
    """
    if rate <= 0:
        return False

    if rate >= 1:
        return True

    interval = round(1 / rate)
    return (cycle_index - offset) % interval == 0


def spread_evenly(base_list, extra_items):
    """
    Inserts extra items into a base list at evenly distributed positions.
    Calculates a step size based on the ratio of the base list length to the
    number of extra items, then spaces each extra item at proportional intervals
    throughout the list rather than appending them all at the end.

    Args:
        base_list (list): The original list of items to insert into.
        extra_items (list): The items to distribute evenly across base_list.

    Returns:
        list: A new list with extra items spread evenly throughout. Returns
              a copy of base_list unchanged if extra_items is empty.
    """
    if not extra_items:
        return base_list

    result = base_list.copy()
    step = len(result) / len(extra_items)

    for i, item in enumerate(extra_items):
        index = int((i + 1) * step)
        result.insert(min(index, len(result)), item)

    return result


def assign_cycle_offsets(base_cycle, rng=None):
    """
    Pre-assigns a randomized `_cycle_offset` to each scenario whose rate
    is fractional (<1). The offset is drawn uniformly from [0, interval),
    ensuring scenarios with the same rate are spread across different cycles
    rather than all firing at cycle 0 and then in lockstep.

    Scenarios with rate >= 1 get offset 0 (they always run anyway).

    Args:
        base_cycle (list[dict]): Scenario list, each with optional
                                 "occurrences_per_cycle" key.
        rng (random.Random | None): Optional seeded RNG instance for
                                    reproducibility. Uses random module
                                    directly if None.

    Returns:
        list[dict]: Shallow-copied scenario dicts with `_cycle_offset` added.
    """
    result = []
    for scenario in base_cycle:
        s = scenario.copy()
        rate = s.get("occurrences_per_cycle", 1.0)
        if 0 < rate < 1:
            interval = round(1 / rate)
            offset = rng.randint(0, interval - 1) if rng else random.randint(0, interval - 1)
        else:
            offset = 0
        s["_cycle_offset"] = offset
        result.append(s)
    return result


def build_execution_plan(base_cycle, total_cycles):
    """
    Constructs a flat execution schedule by expanding a base cycle of scenarios
    across a given number of cycle repetitions. For each cycle, determines which
    scenarios should run via should_run() based on their occurrences_per_cycle rate.
    Scenarios with a rate greater than 1 generate additional copies of themselves,
    which are then spread evenly throughout the cycle using spread_evenly() to avoid
    bunching. All cycles are concatenated into a single ordered list.

    Args:
        base_cycle (list[dict]): A list of scenario dicts, each optionally containing
                                 an "occurrences_per_cycle" key (float, default 1.0).
        total_cycles (int): The number of times to repeat and expand the base cycle.

    Returns:
        list: A flat, ordered list of scenarios representing the full execution plan.
    """
    # Assign staggered offsets once, before iterating cycles
    base_cycle = assign_cycle_offsets(base_cycle)
    final_list = []

    for cycle_index in range(total_cycles):
        cycle = []
        extras = []

        for scenario in base_cycle:
            rate = scenario.get("occurrences_per_cycle", 1.0)
            offset = scenario.get("_cycle_offset", 0)
            if not should_run(rate, cycle_index, offset):
                continue

            # normal occurrence
            cycle.append(scenario)

            # extra occurrences if rate > 1
            if rate > 1:
                extra_count = int(rate) - 1
                extras.extend([scenario] * extra_count)

        cycle = spread_evenly(cycle, extras)
        final_list.extend(cycle)

    return final_list


def create_main_scenarios():
    random.seed(42)
    n71_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.5},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_059_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_060", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_061", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_067_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_068_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_069_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_070_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_071_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_072_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_075_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_076_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_079_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_080_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_081_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_082_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_083_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_085_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_086_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_087_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_088_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_089_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_090_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_093_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_094_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_097_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_098_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_099_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_100_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_101_01_n71", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
    ]

    n71_NSA_group = [
        {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_031", "args": {"target_cell": 1}, "occurrences_per_cycle": 1.0},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
    ]
    n71_list = n71_SA_group + n71_NSA_group
    random.shuffle(n71_list)

    n25_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.5},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_059_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_060", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_061", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_067_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_068_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_069_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_070_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_071_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_072_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_075_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_076_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_079_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_080_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_081_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_082_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_083_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_085_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_086_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_087_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_088_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_089_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_090_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_093_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_094_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_097_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_098_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_099_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 2.0},
        {"name": "SkyWatch_Seq_SA_100_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_101_02_n25", "args": {"target_cell": 21}, "occurrences_per_cycle": 1.0},
    ]
    n25_list = n25_SA_group
    random.shuffle(n25_list)

    n41_SA_group = [
        {"name": "SkyWatch_Seq_SA_001", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_002", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_003", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.5},
        {"name": "SkyWatch_Seq_SA_004", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_005", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_006", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_007", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_008", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_009", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_010", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_011", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_012", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_013", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_014", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_015", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_016", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_017", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_018", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_019", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_020", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_021", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_022", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_023", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_024", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_025", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_026", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_027", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_028", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_029", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_030", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_031", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_032", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_033", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_034", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_035", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_036", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_037", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_038", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_039", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_040", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_041", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_042", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_043", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_044", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_045", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_046", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_047", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_048", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_049", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_050", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_051", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_052", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_053", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_054", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_055", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_056", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_057", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_058", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_059_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_060", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_061", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_067_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_068_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_069_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_070_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_071_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_072_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_075_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_076_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_079_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_080_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_081_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_082_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_083_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_085_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_086_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_087_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_088_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_089_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_090_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_093_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_094_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_097_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_098_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        {"name": "SkyWatch_Seq_SA_099_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_SA_100_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 0.2},
        # {"name": "SkyWatch_Seq_SA_101_03_n41", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
    ]

    n41_NSA_group = [
        {"name": "SkyWatch_Seq_NSA_001", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_002", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_003", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_004", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_011", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_012", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_013", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_014", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_021", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_022", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_023", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_024", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        {"name": "SkyWatch_Seq_NSA_031", "args": {"target_cell": 201}, "occurrences_per_cycle": 1.0},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        # {"name": "SkyWatch_Seq_NSA_032", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_033", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        # {"name": "SkyWatch_Seq_NSA_034", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
    ]
    n41_list = n41_SA_group + n41_NSA_group
    random.shuffle(n41_list)

    all_lists = {
        "n41": n41_list,
        "n25": n25_list,
        "n71": n71_list
    }
    for key in all_lists:
        all_lists[key] = assign_ue_id(all_lists[key])
        all_lists[key] = build_execution_plan(base_cycle=all_lists[key], total_cycles=40)

    return all_lists


def create_background_scenarios():
    """
    Construct and interleave background scenarios across n25, n71, and n41 bands.

    The function builds per-band background lists, then round-robins them to form a single
    interleaved list without additional shuffling.

    Returns:
        A list of background scenario dicts interleaved across bands.
    """
    # n71=18UEs n25=20UEs n41=32UEs -> 70 background UEs
    # 3xVoNR + 3xNSA + 2xSA (nearcell) + 5xSA (midcell) + 5xSA (farcell) = 18UEs
    background_n71 = [
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 3, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 2, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 4, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 8, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 3, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 19, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 11, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 10, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 1, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 11, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 19, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 10, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 1, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
    ]
    # 3xVoNR + 3xNSA + 9xSA (nearCell) + 9xSA (midCell) + 8xSA (farCell) = 32UEs
    background_n41 = [
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 2, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 3, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 8, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 3, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 4, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 10, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 8, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 4, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 4, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 11, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 4, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 3, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_NSA_Background", "args": {"target_cell": 201, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 11, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 3, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 10, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 4, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 19, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 19, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 201, "nwslice": 19,
                                                        "rf_condition": 'near_cell'}},
    ]
    # 3xVoNR + 3xSA (nearCell) + 7xSA (midCell) + 7xSA (farCell) = 20UEs
    background_n25 = [
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'far_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 3, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 8, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 8, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 11, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 4, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 11, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 2, "rf_condition": 'near_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'near_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 10, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 4, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 19, "rf_condition": 'mid_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 19, "rf_condition": 'far_cell'}},
        {"name": "SkyWatch_Seq_SA_Background", "args": {"target_cell": 21, "nwslice": 1, "rf_condition": 'mid_cell',
                                                        'default_slice_5qi': 9, "vonr": True}},
    ]
    # Interleave background scenarios
    background_scenarios_list = []
    lists = [background_n25, background_n71, background_n41]
    while any(lists):
        for lst in lists:
            if lst:
                background_scenarios_list.append(lst.pop(0))
    return background_scenarios_list


def list_functions_in_module():
    return {name: obj for name, obj in globals().items() if callable(obj)}
    # return {name: obj for name, obj in locals().items() if callable(obj)}


def prepare_scenario_list_background():
    scen_list = create_background_scenarios()
    func_registry = list_functions_in_module()
    callable_functions = []

    for func_data in scen_list:
        func_name = func_data["name"]
        args = func_data["args"]
        # if semaph:
        #     args["semaphore"] = BACKGROUND_LIMIT

        if func_name in func_registry:
            func = func_registry[func_name]
            sig = inspect.signature(func)
            kwargs = {}
            for pname, param in sig.parameters.items():
                if param.default is inspect._empty:
                    kwargs[pname] = None
                else:
                    kwargs[pname] = param.default
            combined_args = kwargs | args
            callable_functions.append((func, combined_args))
        else:
            logging.error(f"Can't find function {func_name} in current scope")

    return callable_functions


def prepare_scenario_list():
    scen_list = create_main_scenarios()
    func_registry = list_functions_in_module()
    callable_functions = {}
    for key in scen_list:
        for func_data in scen_list[key]:
            func_name = func_data["name"]
            args = func_data["args"]
            # if semaph:
            #     args["semaphore"] = SCEN_LIMIT

            if func_name in func_registry:
                func = func_registry[func_name]
                sig = inspect.signature(func)
                kwargs = {}
                for pname, param in sig.parameters.items():
                    if param.default is inspect._empty:
                        kwargs[pname] = None
                    else:
                        kwargs[pname] = param.default
                combined_args = kwargs | args
                callable_functions.setdefault(key, []).append((func, combined_args))
                # callable_functions.append((func, combined_args))
            else:
                logging.error(f"Can't find function {func_name} in current scope")

    return callable_functions
