import asyncio
import random
import subprocess
import sys
from core.workloads.common import ue_id_generator
from scenarios.scenarios_list import (prepare_scenario_list, prepare_scenario_list_background)
from core.engine.decorators import timed_async, task_timings, background_ues_decorator
from core.RegexWatcher import cell_map, file_logger, logger, locks


NSA_START_UE_ID = 1121
NSA_MAX_UE_ID = 1200
SA_START_UE_ID = 1
SA_MAX_UE_ID = 199


async def precondition_and_background_ue(semaphore, sem_limit):
    queue = asyncio.Queue()
    ue_id = None
    gen_nsa_ue = ue_id_generator(NSA_START_UE_ID, NSA_MAX_UE_ID)
    gen_sa_ue = ue_id_generator(SA_START_UE_ID, SA_MAX_UE_ID)
    merge_scenarios_for_background = prepare_scenario_list_background()
    merge_scenarios_for_background = generate_periods(merge_scenarios_for_background)
    merge_scenarios_for_background = generate_beam_ids(merge_scenarios_for_background)
    for i, (func, kwargs) in enumerate(merge_scenarios_for_background):
        func = background_ues_decorator(func)
        func_name = func.__name__
        if func_name.startswith("SkyWatch_Seq_SA"):
            ue_id = next(gen_sa_ue)
        elif func_name.startswith("SkyWatch_Seq_NSA"):
            ue_id = next(gen_nsa_ue)
        cell = kwargs.get("target_cell")
        meas_id = cell_map[cell]["meas_id"]
        kwargs = {**kwargs, "semaphore": semaphore, "meas_id": meas_id, "ue_id": ue_id}
        file_logger.info(f"[SCENARIO] {func.__name__}, {kwargs}, {ue_id}")
        queue.put_nowait((func, kwargs))
    logger.warning("Tasks for background UEs created. Waiting for results...")
    return queue, semaphore


async def prepare_main_scenarios(semaphore_dict):
    queue_dict: dict[str, asyncio.Queue] = {}
    merge_scenarios = prepare_scenario_list()
    for key in merge_scenarios:
        merge_scenarios[key] = generate_beam_ids(merge_scenarios[key])
        queue_dict[key] = asyncio.Queue()
    # merge_scenarios = generate_beam_ids(merge_scenarios)
        for i, (func, kwargs) in enumerate(merge_scenarios[key]):
            cell = kwargs.get("target_cell")
            meas_id = cell_map[cell]["meas_id"]
            kwargs = {**kwargs, "semaphore": semaphore_dict[key], "meas_id": meas_id}

            func = timed_async(func)
            func_name = func.__name__

            file_logger.info(f"[SCENARIO] index={i} {func_name}, {kwargs}")

            ue_id = kwargs.get("ue_id")
            if ue_id is None:
                raise ValueError(f"Scenario {func_name} missing ue_id in kwargs: {kwargs}")
            await queue_dict[key].put((run_with_lock, ue_id, func, kwargs))

    print("Scenarios created. Waiting for results...")
    return queue_dict


def generate_periods(scenarios):
    """This function generates deterministic random value from
    [700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200] for period parameter,
     goal is to achieve repeatable set of random values for scenarios"""
    random.seed(42)
    new_scenarios = []
    for i, (func, kwargs) in enumerate(scenarios):
        # period = random.choice([1, 2, 3, 4, 5])
        period = random.choice([1, 2])
        new_kwargs = kwargs.copy()
        if new_kwargs.get("vonr") is True:
            new_kwargs["period"] = period
        new_scenarios.append((func, new_kwargs))
    return new_scenarios


def generate_beam_ids(scenarios):
    random.seed(42)
    new_scenarios = []
    for i, (func, kwargs) in enumerate(scenarios):
        cell_id = kwargs["target_cell"]
        cell_type = cell_map[cell_id]["technology"]
        new_kwargs = kwargs.copy()
        if cell_type == "TDD":
            beam_id = random.choice([1, 2, 3, 4, 5, 6])
            new_kwargs["beam_id"] = beam_id
        new_scenarios.append((func, new_kwargs))
    return new_scenarios


def csv_timings(file):
    try:
        import pandas as pd
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd
    df = pd.DataFrame(task_timings.values())
    df = df.sort_values(by="Start").reset_index(drop=True)
    df.to_csv(file, index=False)


async def run_with_lock(ue_id, func, kwargs):
    async with locks[ue_id]:
        return await func(**kwargs)
