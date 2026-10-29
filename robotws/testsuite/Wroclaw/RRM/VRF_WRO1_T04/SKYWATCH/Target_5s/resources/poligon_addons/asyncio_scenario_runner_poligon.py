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
from scenarios_list_poligon import (prepare_scenario_list, prepare_scenario_list_background)
from datetime import datetime, timedelta
from RegexWatcher import (watcher, file_logger, set_log_file, reset_watcher, reset_loggers, CSV_FILE_TIMINGS,
                          locks, log_path)
from common_poligon import setup_ute_egate, ue_id_generator
from TA_scenarios import Precondition_For_Tests, stop_watcher
from decorators_poligon import timed_async, task_timings, run_counts, background_ues_decorator
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


async def precondition_and_background_ue(semaphore, sem_limit):
    gen_nsa_ue = ue_id_generator(NSA_START_UE_ID, NSA_MAX_UE_ID)
    gen_sa_ue = ue_id_generator(SA_START_UE_ID, SA_MAX_UE_ID)
    tasks = []
    merge_scenarios_for_background = prepare_scenario_list_background()
    # pbar = tqdm(total=len(merge_scenarios_for_background), desc="Progress",
    #             bar_format="{desc}: {elapsed} {percentage:3.0f}%|{bar} | {n_fmt}/{total_fmt} | {postfix}",
    #             file=sys.stdout, dynamic_ncols=True, disable=False)
    pbar = ConsoleProgressBar(total=len(merge_scenarios_for_background))
    for i, (func, kwargs) in enumerate(merge_scenarios_for_background):
        # if i < LIMIT_BACKGROUND:
        if i < sem_limit:
            delay = i + 1
        else:
            delay = 0.5
        func = background_ues_decorator(func, delay)
        func_name = func.__name__
        if func_name.startswith("SkyWatch_Seq_SA"):
            ue_id = {"ue_id": next(gen_sa_ue)}
        elif func_name.startswith("SkyWatch_Seq_NSA"):
            ue_id = {"ue_id": next(gen_nsa_ue)}
        # semaphore = {"semaphore": semaphore}
        kwargs = {**kwargs, "semaphore": semaphore}
        file_logger.info(f"[SCENARIO] {func.__name__}, {kwargs}, {ue_id}")
        task = asyncio.create_task(progress_bar_wrapper(func, {**kwargs, **ue_id}, pbar))
        tasks.append(task)
    print("Tasks for background UEs created. Waiting for results...")

    results = await asyncio.gather(*tasks)
    pbar.close()
    # print(f"All data fetched: {results}")


async def run_with_lock(ue_id, func, kwargs, pbar):
    async with locks[ue_id]:
        return await progress_bar_wrapper(func, kwargs, pbar)


async def run_asynch(semaphore, sem_limit, semaphore_background, sem_back_limit, timeout=None, profile=None):
    tasks = []
    await watcher.start_watching_telnet()
    # asyncio.create_task(watcher.watch_telnet())
    await asyncio.sleep(5)
    await Precondition_For_Tests(watcher=watcher)
    # await precondition_and_background_ue(semaphore_background, sem_back_limit)

    merge_scenarios = prepare_scenario_list()

    pbar = ConsoleProgressBar(total=len(merge_scenarios))

    for i, (func, kwargs) in enumerate(merge_scenarios):
        # if i < LIMIT_SCEN:
        if i < sem_limit:
            delay = i + 1
        else:
            delay = 0.5

        file_logger.info(f"[SCENARIO][before_timed] {func.__name__}, {kwargs}")
        kwargs = {**kwargs, "semaphore": semaphore, "target_profile": profile}

        func = timed_async(func, delay)
        func_name = func.__name__

        file_logger.info(f"[SCENARIO] {func_name}, {kwargs}")

        # Extract ue_id from kwargs (must be provided)
        ue_id = kwargs.get("ue_id")
        if ue_id is None:
            raise ValueError(f"Scenario {func_name} missing ue_id in kwargs: {kwargs}")

        # Create task wrapped with per-ue_id lock
        task = asyncio.create_task(run_with_lock(ue_id, func, kwargs, pbar))
        tasks.append(task)

    print("Scenarios created. Waiting for results...")

    # Await all tasks
    try:
        # results = await asyncio.gather(*tasks)
        if timeout in [None, "None", ""]:
            results = await asyncio.gather(*tasks)
        else:
            results = await asyncio.wait_for(asyncio.gather(*tasks), timeout=timestr_to_secs(timeout))
    except asyncio.CancelledError:
        for t in tasks:
            t.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
    except asyncio.TimeoutError:
        for t in tasks:
            t.cancel()
        await asyncio.sleep(0)
        await asyncio.gather(*tasks, return_exceptions=True)
    finally:
        pbar.close()
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
    df["Start"] = pd.to_datetime(df["Start"], unit='s').dt.strftime('%Y-%m-%d %H:%M:%S')
    df["Stop"] = pd.to_datetime(df["Stop"], unit='s').dt.strftime('%Y-%m-%d %H:%M:%S')
    # df["Duration"] = pd.to_timedelta(df["Duration"], unit="s")
    df["Duration"] = df["Duration"].map(lambda x: round(x, 1))
    # df["Duration"] = pd.to_timedelta(df["Duration"], unit="s").dt.strftime('%Y-%m-%d %H:%M:%S')
    # df["Start"] = df["Start"].apply(lambda x: time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(x)))
    # df["Stop"] = df["Stop"].apply(lambda x: time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(x)))
    df = df.sort_values(by="Start").reset_index(drop=True)
    df.to_csv(file, index=False)


# WORKING NORMALLY
def main():
    LIMIT_SCEN = 47
    LIMIT_BACKGROUND = 40
    SCEN_LIMIT = asyncio.Semaphore(LIMIT_SCEN)
    BACKGROUND_LIMIT = asyncio.Semaphore(LIMIT_BACKGROUND)
    set_log_file()
    asyncio.run(run_asynch(SCEN_LIMIT, LIMIT_SCEN, BACKGROUND_LIMIT, LIMIT_BACKGROUND))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(CSV_FILE_TIMINGS._get_target())


def run_skywatch_project(timeout=None, profile=None):
    LIMIT_SCEN = 47
    LIMIT_BACKGROUND = 40
    SCEN_LIMIT = asyncio.Semaphore(LIMIT_SCEN)
    BACKGROUND_LIMIT = asyncio.Semaphore(LIMIT_BACKGROUND)
    set_log_file()
    asyncio.run(run_asynch(SCEN_LIMIT, LIMIT_SCEN, BACKGROUND_LIMIT, LIMIT_BACKGROUND, timeout, profile))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(CSV_FILE_TIMINGS._get_target())


if __name__ == "__main__":
    main()
