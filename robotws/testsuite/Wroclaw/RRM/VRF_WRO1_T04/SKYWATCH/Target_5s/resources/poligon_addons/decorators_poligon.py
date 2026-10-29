# from common import *
import asyncio
import contextvars
from functools import wraps
import time
from common_poligon import add_delay_to_scenario, ue_capa_path, add_exact_delay_to_scenario
from RegexWatcher import file_logger, watcher, task_timings, run_counts, cell_map, current_error_counter
from ue_profiles import activate_beam_profile


# task_timings = {}
# run_counts = {}


def timed_async(func, delay):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        error_counter = {"errors": 0}
        token = current_error_counter.set(error_counter)

        file_logger.info(f"[ARGS] Function {func.__name__}, actual args: {args}, kwargs: {kwargs}, delay: {delay}")
        sem = kwargs["semaphore"]
        ue_id = kwargs["ue_id"]
        cell = kwargs["target_cell"]
        band = cell_map[cell]["band"]
        technology = cell_map[cell]["technology"]
        scenario_type = kwargs.get("scenario_type", "basic")
        if sem is None:
            raise ValueError(f"Missing semaphore in kwargs for {func.__name__}, actual kwargs: {kwargs}")
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            caps = "NSA_S23_UE_CAPA"
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = time.time()
                result = await func(*args, **kwargs)
                # result = None
        elif scenario_type == "special":
            caps = kwargs["caps"]
            async with sem:
                await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                           f"ue_nr_capabilities={caps}")
                await add_exact_delay_to_scenario(delay)
                start = time.time()
                result = await func(*args, **kwargs)
                print(result)
        else:
            caps = kwargs["caps"]
            async with sem:
                await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                           f"ue_nr_capabilities={caps}")
                # await add_delay_to_scenario()
                await add_exact_delay_to_scenario(delay)
                if band == "n41":
                    await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
                start = time.time()
                result = await func(*args, **kwargs)
        stop = time.time()
        duration = stop - start
        count = run_counts.get(func.__name__, 0) + 1
        run_counts[func.__name__] = count
        unique_name = f"{func.__name__}_Run{count}"
        errors = error_counter["errors"]
        notepad_regex = f"UE{ue_id}:|UE-{ue_id}|id={ue_id}|ue={ue_id}"
        # rf_condition = kwargs["rf_condition"]
        task_timings[unique_name] = {"Scenario": func.__name__, "Ue_id": ue_id, "Cell": cell, "Band": band,
                                     "Technology": technology, "Capabilities": caps, "Scenario_type": scenario_type,
                                     "Run_id": count, "Start": start, "Stop": stop, "Duration": duration,
                                     "Errors": errors, "Notepad_regex": notepad_regex}
        current_error_counter.reset(token)
        return result
    return wrapper


def background_ues_decorator(func, delay):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        sem = kwargs["semaphore"]

        if sem is None:
            raise ValueError(f"Missing semaphore in kwargs for {func.__name__}, actual kwargs: {kwargs}")
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            async with sem:
                await add_exact_delay_to_scenario(delay)
                result = await func(*args, **kwargs)

                # result = None
        else:
            async with sem:
                await add_exact_delay_to_scenario(delay)
                result = await func(*args, **kwargs)

        return result
    return wrapper
