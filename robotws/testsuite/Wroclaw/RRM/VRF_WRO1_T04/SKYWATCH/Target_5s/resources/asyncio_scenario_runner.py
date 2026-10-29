# from scenarios_list import (prepare_scenario_list, all_scenarios_list, sa_static_scen, gen_sa_ue,
#                             sa_static_scen_without_pdu, nsa_static_scen, gen_nsa_ue, sa_mobility_scen,
#                             background_scenarios_list, prepare_scenario_list_background)
import asyncio
import socket
import random
import time
import subprocess
import sys
import os
from robot.utils import timestr_to_secs
from scenarios_list import (prepare_scenario_list, prepare_scenario_list_background)
from datetime import datetime, timedelta
from RegexWatcher import (watcher, file_logger, set_log_file, reset_watcher, reset_loggers, CSV_FILE_TIMINGS,
                          locks, log_path, cell_map)
from common import setup_ute_egate, ue_id_generator
from Static_SA import Precondition_For_Tests, stop_watcher
from decorators import timed_async, task_timings, run_counts, background_ues_decorator
from plots import generate_active_scenarios_in_time
from tqdm import tqdm
from progress_bar import ConsoleProgressBar

NSA_START_UE_ID = 1121
NSA_MAX_UE_ID = 1200
SA_START_UE_ID = 1
SA_MAX_UE_ID = 199

# One asyncio.Lock per ue_id
# locks = defaultdict(asyncio.Lock)


# START_TIME = datetime.now().strftime('%Y%m%d_%H%M%S')

def get_machine_name():
    return socket.gethostname()


def get_actual_log_path():
    return log_path._get_target()


def reset_all_loggers():
    reset_loggers()


def generate_periods(scenarios):
    """This function generates deterministic random value from
    [700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200] for period parameter,
     goal is to achieve repeatable set of random values for scenarios"""
    random.seed(42)
    new_scenarios = []
    for i, (func, kwargs) in enumerate(scenarios):
        period = random.choice([700, 1200, 1700, 2200, 2700, 3200, 3700, 4200, 4700, 5200])
        new_kwargs = kwargs.copy()
        if new_kwargs.get("vonr") is True:
            new_kwargs["period"] = period
        new_scenarios.append((func, new_kwargs))
    return new_scenarios


async def worker(name, queue):
    while True:
        func, *args = await queue.get()
        await func(*args)
        queue.task_done()


async def precondition_and_background_ue(semaphore, sem_limit):
    gen_nsa_ue = ue_id_generator(NSA_START_UE_ID, NSA_MAX_UE_ID)
    gen_sa_ue = ue_id_generator(SA_START_UE_ID, SA_MAX_UE_ID)
    tasks = []
    merge_scenarios_for_background = prepare_scenario_list_background()
    merge_scenarios_for_background = generate_periods(merge_scenarios_for_background)
    pbar = ConsoleProgressBar(total=len(merge_scenarios_for_background))
    for i, (func, kwargs) in enumerate(merge_scenarios_for_background):
        if i < sem_limit:
            delay = 0
        else:
            delay = 0
        func = background_ues_decorator(func, delay)
        func_name = func.__name__
        if func_name.startswith("SkyWatch_Seq_SA"):
            ue_id = {"ue_id": next(gen_sa_ue)}
        elif func_name.startswith("SkyWatch_Seq_NSA"):
            ue_id = {"ue_id": next(gen_nsa_ue)}
        cell = kwargs.get("target_cell")
        meas_id = cell_map[cell]["meas_id"]
        kwargs = {**kwargs, "semaphore": semaphore, "meas_id": meas_id}
        file_logger.info(f"[SCENARIO] {func.__name__}, {kwargs}, {ue_id}")
        task = asyncio.create_task(progress_bar_wrapper(func, {**kwargs, **ue_id}, pbar))
        tasks.append(task)
    print("Tasks for background UEs created. Waiting for results...")

    results = await asyncio.gather(*tasks)
    pbar.close()


async def run_with_lock(ue_id, func, kwargs, pbar):
    async with locks[ue_id]:
        return await progress_bar_wrapper(func, kwargs, pbar)


async def run_asynch(semaphore, sem_limit, semaphore_background, sem_back_limit, timeout=None):
    tasks = []
    queue = asyncio.Queue()
    await watcher.start_watching_telnet()
    await asyncio.sleep(5)
    await Precondition_For_Tests(watcher=watcher)
    await precondition_and_background_ue(semaphore_background, sem_back_limit)

    merge_scenarios = prepare_scenario_list()

    pbar = ConsoleProgressBar(total=len(merge_scenarios))
    workers = [asyncio.create_task(worker(f"W{i}", queue)) for i in range(sem_limit)]
    for i, (func, kwargs) in enumerate(merge_scenarios):
        if i < sem_limit:
            delay = 0
        else:
            delay = 0

        cell = kwargs.get("target_cell")
        meas_id = cell_map[cell]["meas_id"]
        kwargs = {**kwargs, "semaphore": semaphore, "meas_id": meas_id}

        func = timed_async(func, delay)
        func_name = func.__name__

        file_logger.info(f"[SCENARIO] index={i} {func_name}, {kwargs}")

        # Extract ue_id from kwargs (must be provided)
        ue_id = kwargs.get("ue_id")
        if ue_id is None:
            raise ValueError(f"Scenario {func_name} missing ue_id in kwargs: {kwargs}")
        await queue.put((run_with_lock, ue_id, func, kwargs, pbar))

    print("Scenarios created. Waiting for results...")
    # Await all tasks
    try:
        if timeout in [None, "None", ""]:
            results = await queue.join()
        else:
            results = await asyncio.wait_for(queue.join(), timeout=timestr_to_secs(timeout))
    except asyncio.CancelledError:
        print("GLOBALLY CANCELLED")
    except asyncio.TimeoutError:
        timeout_at = datetime.now()
        timeout_at_str = timeout_at.strftime('%Y-%m-%d %H:%M:%S,%f')
        print(f"GLOBAL TIMEOUT AT: {timeout_at_str}")
        print("GLOBAL TIMEOUT REACHED, CLOSING SKYWATCH...")
    finally:
        for w in workers:
            w.cancel()
        pbar.close()
        while not queue.empty():
            queue.get_nowait()
            queue.task_done()
        await asyncio.gather(*workers, return_exceptions=True)
        await watcher.stop()
        await reset_watcher()


async def progress_bar_wrapper(func, kwargs, pbar):
    async def wrapped():
        result = await func(**kwargs)
        pbar.update(1)
        return result
    return await wrapped()


def csv_timings(file):
    try:
        import pandas as pd
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd
    df = pd.DataFrame(task_timings.values())
    df = df.sort_values(by="Start").reset_index(drop=True)
    df.to_csv(file, index=False)


# WORKING NORMALLY
def main():
    LIMIT_SCEN = 42
    LIMIT_BACKGROUND = 40
    SCEN_LIMIT = asyncio.Semaphore(LIMIT_SCEN)
    BACKGROUND_LIMIT = asyncio.Semaphore(LIMIT_BACKGROUND)
    set_log_file()
    asyncio.run(run_asynch(SCEN_LIMIT, LIMIT_SCEN, BACKGROUND_LIMIT, LIMIT_BACKGROUND))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(CSV_FILE_TIMINGS._get_target())


def run_skywatch_project(timeout=None):
    LIMIT_SCEN = 42
    LIMIT_BACKGROUND = 40
    SCEN_LIMIT = asyncio.Semaphore(LIMIT_SCEN)
    BACKGROUND_LIMIT = asyncio.Semaphore(LIMIT_BACKGROUND)
    set_log_file()
    asyncio.run(run_asynch(SCEN_LIMIT, LIMIT_SCEN, BACKGROUND_LIMIT, LIMIT_BACKGROUND, timeout))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(CSV_FILE_TIMINGS._get_target())


if __name__ == "__main__":
    main()
