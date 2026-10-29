# from common import *
import asyncio
import contextvars
from functools import wraps
from random import choice
import time
from common import (add_delay_to_scenario, ue_capa_path, add_exact_delay_to_scenario, attach_ue,
                    prepare_and_register_ue_with_pdu_sessions, deregister_ue_by_switch_off,
                    add_fiveqi_1_to_pdu_2)
from RegexWatcher import (file_logger, logger, watcher, task_timings, run_counts, cell_map, current_error_counter,
                          default_5qi_map)
from ue_profiles import (activate_beam_profile, activate_sa_far_cell_testmod, activate_sa_mid_cell_testmod,
                         activate_sa_near_cell_testmod, activate_nsa_far_cell_testmod, activate_nsa_mid_cell_testmod,
                         activate_nsa_near_cell_testmod)
from datetime import datetime
from ue_measurements import send_reports_A1_A2_far_cell, send_reports_A1_A2_mid_cell, send_reports_A1_A2_near_cell


# task_timings = {}
# run_counts = {}

def timed_async(func, delay):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        """ Wrapper used for every SkyWatch Scenario to optimize amount of code per Scenario
            Delivers statistics about Scenario to task_timings (then proceed to CSV)"""
        error_counter = {"errors": 0}
        token = current_error_counter.set(error_counter)
        file_logger.info(f"[ARGS] Function {func.__name__}, actual args: {args}, kwargs: {kwargs}, delay: {delay}")
        sem = kwargs["semaphore"]
        ue_id = kwargs["ue_id"]
        cell = kwargs["target_cell"]
        band = cell_map[cell]["band"]
        technology = cell_map[cell]["technology"]
        scenario_type = kwargs.get("scenario_type", "basic")
        default_slice_5qi = kwargs.get("default_slice_5qi", None)
        qos_flow = default_5qi_map[default_slice_5qi]["qos_flow"]
        rf_condition = kwargs.get("rf_condition", None)
        meas_id = kwargs.get("meas_id", None)
        if sem is None:
            raise ValueError(f"Missing semaphore in kwargs for {func.__name__}, actual kwargs: {kwargs}")
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            # NSA Scenarios handling
            caps = "NSA_S23_UE_CAPA"
            type = "NSA"
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = datetime.now()
                if rf_condition is not None:
                    await globals()[f"activate_nsa_{rf_condition}_testmod"](ue_id, cell, watcher)
                await attach_ue(ue_id=ue_id, watcher=watcher)
                result = await func(*args, **kwargs)
                await watcher.send_command(f"ue_detach id={ue_id}")
        elif scenario_type == "special":
            # Special SA scenarios decorated only with delay and beams
            type = "SA"
            caps = kwargs["caps"]
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = datetime.now()
                await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                           f"ue_nr_capabilities={caps}")
                if band == "n41":
                    await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
                result = await func(*args, **kwargs)
        else:
            # SA Static & Mobility handling
            type = "SA"
            caps = kwargs["caps"]
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = datetime.now()
                await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                           f"ue_nr_capabilities={caps}")
                if band == "n41":
                    await activate_beam_profile(ue_id=ue_id, profile_id='random', watcher=watcher)
                if default_slice_5qi not in (6, None):
                    await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal"
                                               f" default_qos_flow={qos_flow}")
                if rf_condition is not None:
                    await globals()[f"activate_sa_{rf_condition}_testmod"](ue_id, cell, watcher)
                await prepare_and_register_ue_with_pdu_sessions(ue_id, cell, watcher)
                result = await func(*args, **kwargs)
                await deregister_ue_by_switch_off(ue_id, watcher)
        # Below Statistic stuff
        stop = datetime.now()
        stop_str = stop.strftime('%Y-%m-%d %H:%M:%S,%f')
        real_start = start.strftime('%Y-%m-%d %H:%M:%S,%f')
        duration = stop - start
        count_key = (func.__name__, ue_id)
        count = run_counts.get(count_key, 0) + 1
        run_counts[count_key] = count

        unique_name = f"{func.__name__}_{band}_Run{count}"
        errors = error_counter["errors"]
        notepad_regex = f"UE{ue_id}:|UE-{ue_id}|id={ue_id}|ue={ue_id}"
        # rf_condition = kwargs["rf_condition"]
        task_timings[unique_name] = {"Scenario": func.__name__, "Ue_id": ue_id, "Cell": cell, "Band": band,
                                     "Technology": technology, "SA/NSA": type, "Capabilities": caps,
                                     "Scenario_type": scenario_type, "Run_id": count, "Delayed_by": delay,
                                     "Start": real_start, "Stop": stop_str, "Duration": duration,
                                     "5QI": default_slice_5qi, "QoS": qos_flow, "Meas_id": meas_id,
                                     "RF_condition": rf_condition, "Errors": errors, "Notepad_regex": notepad_regex}
        current_error_counter.reset(token)
        return result
    return wrapper


def background_ues_decorator(func, delay):
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
        scenario_type = kwargs.get("scenario_type", "background")
        default_slice_5qi = kwargs.get("default_slice_5qi", None)
        qos_flow = default_5qi_map[default_slice_5qi]["qos_flow"]
        rf_condition = kwargs.get("rf_condition", None)
        meas_id = kwargs.get("meas_id", None)
        vonr = kwargs.get("vonr", None)
        caps = "Default"
        period = kwargs.get("period", None)

        if sem is None:
            raise ValueError(f"Missing semaphore in kwargs for {func.__name__}, actual kwargs: {kwargs}")
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            type = "NSA"
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = datetime.now()
                result = await func(*args, **kwargs)

                # result = None
        else:
            type = "SA"
            async with sem:
                await add_exact_delay_to_scenario(delay)
                start = datetime.now()
                if default_slice_5qi not in (6, None):
                    await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal"
                                               f" default_qos_flow={qos_flow}")
                if rf_condition is not None:
                    await globals()[f"activate_sa_{rf_condition}_testmod"](ue_id, cell, watcher)
                await prepare_and_register_ue_with_pdu_sessions(ue_id, cell, watcher)
                await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=dl kbps=1")
                await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 dir=ul kbps=1")
                if meas_id is not None:
                    await globals()[f"send_reports_A1_A2_{rf_condition}"](ue_id, meas_id, watcher)
                await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=dl kbps=100")
                await watcher.send_command(f"trf_data_start ue={ue_id} pdu=1 dir=ul kbps=50")
                if vonr is not None:
                    await add_fiveqi_1_to_pdu_2(ue_id, watcher)
                    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=dl rtp_codec=custom "
                                               f"period_ms={period} rtp_send_silence_period={period}")
                    await watcher.send_command(f"trf_data_start ue={ue_id} pdu=2 qfi=2 dir=ul rtp_codec=custom "
                                               f"period_ms={period} rtp_send_silence_period={period}")
                result = await func(*args, **kwargs)

        stop = datetime.now()
        stop_str = stop.strftime('%Y-%m-%d %H:%M:%S,%f')
        real_start = start.strftime('%Y-%m-%d %H:%M:%S,%f')
        duration = stop - start
        count_key = (func.__name__, ue_id)
        count = run_counts.get(count_key, 0) + 1
        run_counts[count_key] = count

        unique_name = f"{func.__name__}_{band}_{ue_id}_Run{count}"
        errors = error_counter["errors"]
        notepad_regex = f"UE{ue_id}:|UE-{ue_id}|id={ue_id}|ue={ue_id}"
        # rf_condition = kwargs["rf_condition"]
        task_timings[unique_name] = {"Scenario": func.__name__, "Ue_id": ue_id, "Cell": cell, "Band": band,
                                     "Technology": technology, "SA/NSA": type, "Capabilities": caps,
                                     "Scenario_type": scenario_type, "Run_id": count, "Delayed_by": delay,
                                     "Start": real_start, "Stop": stop_str, "Duration": duration,
                                     "5QI": default_slice_5qi, "QoS": qos_flow, "Meas_id": meas_id,
                                     "RF_condition": rf_condition, "Errors": errors, "Notepad_regex": notepad_regex,
                                     "VoNR": vonr, "Period": period}
        current_error_counter.reset(token)

        return result
    return wrapper
