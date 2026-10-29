from core.workloads.common import (ue_capa_path, attach_ue,
                                   prepare_and_register_ue_with_pdu_sessions, deregister_ue_by_switch_off,
                                   trf_stats)
from core.RegexWatcher import (file_logger, watcher, task_timings, run_counts, cell_map, current_error_counter,
                               default_5qi_map)
from core.workloads.ue_profiles import *
from core.workloads.ue_measurements import *
import asyncio
from functools import wraps
from datetime import datetime


def timed_async(func):
    shared_context = {}
    decorated_with_stats = with_stats(shared_context)(func)

    @wraps(func)
    async def wrapper(*args, **kwargs):
        """ Wrapper used for every SkyWatch Scenario to optimize amount of code per Scenario
            Delivers statistics about Scenario to task_timings (then proceed to CSV)"""
        ue_id = kwargs["ue_id"]
        sem = kwargs["semaphore"]
        cell = kwargs["target_cell"]
        scenario_type = kwargs.get("scenario_type", "basic")
        rf_condition = kwargs.get("rf_condition", None)
        beam_id = kwargs.get("beam_id", None)
        default_slice_5qi = kwargs.get("default_slice_5qi", None)
        qos_flow = default_5qi_map[default_slice_5qi]["qos_flow"]
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            # NSA Scenarios handling
            shared_context["caps"] = "NSA_S23_UE_CAPA"
            shared_context["type"] = "NSA"
            # async with sem:
            shared_context["start"] = datetime.now()
            if rf_condition is not None:
                await globals()[f"activate_nsa_{rf_condition}_testmod"](ue_id, cell, watcher)
            await attach_ue(ue_id=ue_id, watcher=watcher)
            result = await decorated_with_stats(*args, **kwargs)
            await watcher.send_command(f"ue_detach id={ue_id}")
        elif scenario_type == "special":
            # Special SA scenarios decorated only with beams
            shared_context["type"] = "SA"
            shared_context["caps"] = kwargs["caps"]
            # async with sem:
            shared_context["start"] = datetime.now()
            await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                       f"ue_nr_capabilities={shared_context['caps']}")
            # if band == "n41":
            if beam_id is not None:
                await activate_beam_profile(ue_id=ue_id, profile_id=beam_id, watcher=watcher)
            result = await decorated_with_stats(*args, **kwargs)
        else:
            # SA Static & Mobility handling
            shared_context["type"] = "SA"
            shared_context["caps"] = kwargs["caps"]
            # async with sem:
            shared_context["start"] = datetime.now()
            await watcher.send_command(f"ue_param capability_file={ue_capa_path} id={ue_id} "
                                       f"ue_nr_capabilities={shared_context['caps']}")
            if beam_id is not None:
                await activate_beam_profile(ue_id=ue_id, profile_id=beam_id, watcher=watcher)
            if default_slice_5qi not in (6, None):
                await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal"
                                           f" default_qos_flow={qos_flow}")
            if rf_condition is not None:
                await globals()[f"activate_sa_{rf_condition}_testmod"](ue_id, cell, watcher)
            await prepare_and_register_ue_with_pdu_sessions(ue_id, cell, watcher, kwargs["nwslice"])
            result = await decorated_with_stats(*args, **kwargs)
            await deregister_ue_by_switch_off(ue_id, watcher)
        return result
    return wrapper


def background_ues_decorator(func):
    shared_context = {}
    decorated_with_stats = with_stats(shared_context)(func)

    @wraps(func)
    async def wrapper(*args, **kwargs):
        sem = kwargs["semaphore"]
        ue_id = kwargs["ue_id"]
        cell = kwargs["target_cell"]
        default_slice_5qi = kwargs.get("default_slice_5qi", None)
        qos_flow = default_5qi_map[default_slice_5qi]["qos_flow"]
        rf_condition = kwargs.get("rf_condition", None)
        beam_id = kwargs.get("beam_id", None)
        meas_id = kwargs.get("meas_id", None)

        if sem is None:
            raise ValueError(f"Missing semaphore in kwargs for {func.__name__}, actual kwargs: {kwargs}")
        if func.__name__.startswith("SkyWatch_Seq_NSA"):
            shared_context["caps"] = kwargs["caps"]
            shared_context["type"] = "NSA"
            # async with sem:
            start = datetime.now()
            shared_context["start"] = start
            result = await decorated_with_stats(*args, **kwargs)
            await watcher.send_command(f"ue_detach id={ue_id}")
        else:
            shared_context["type"] = "SA"
            shared_context["caps"] = kwargs["caps"]
            # async with sem:
            start = datetime.now()
            shared_context["start"] = start
            if beam_id is not None:
                await activate_beam_profile(ue_id=ue_id, profile_id=beam_id, watcher=watcher)
            if default_slice_5qi not in (6, None):
                await watcher.send_command(f"set_pdu_param ue={ue_id} pdu=1 trf_type=internal"
                                           f" default_qos_flow={qos_flow}")
            if rf_condition is not None:
                await globals()[f"activate_sa_{rf_condition}_testmod"](ue_id, cell, watcher)
            await prepare_and_register_ue_with_pdu_sessions(ue_id, cell, watcher, kwargs["nwslice"])
            if meas_id is not None:
                await globals()[f"send_reports_A1_A2_{rf_condition}"](ue_id, meas_id, watcher)
            result = await decorated_with_stats(*args, **kwargs)
            await deregister_ue_by_switch_off(ue_id, watcher)
            await asyncio.sleep(randint(5, 30))
        return result
    return wrapper


def with_stats(shared_context):
    def decorator(func):

        @wraps(func)
        async def wrapper(*args, **kwargs):
            error_counter = {"errors": 0}
            token = current_error_counter.set(error_counter)
            token_stats = trf_stats.set({
                "dl_data": [],
                "ul_data": [],
                "dl_sign": [],
                "ul_sign": [],
                "dl_vonr": [],
                "ul_vonr": [],
                "period": []
            })
            file_logger.info(f"[ARGS] Function {func.__name__}, actual args: {args}, kwargs: {kwargs}")
            ue_id = kwargs["ue_id"]
            cell = kwargs["target_cell"]
            band = cell_map[cell]["band"]
            default_slice_5qi = kwargs.get("default_slice_5qi", None)
            period = kwargs.get("period", None)
            beam_id = kwargs.get("beam_id", None)

            start = shared_context["start"]
            try:
                return await func(*args, **kwargs)
            except asyncio.CancelledError:
                raise
            except Exception as e:
                error = repr(e)
                raise
            finally:
                stop = datetime.now()
                stop_str = stop.strftime('%Y-%m-%d %H:%M:%S,%f')
                real_start = start.strftime('%Y-%m-%d %H:%M:%S,%f')
                duration = stop - start
                count_key = (func.__name__, ue_id)
                count = run_counts.get(count_key, 0) + 1
                run_counts[count_key] = count

                # if kwargs.get("scenario_type", "basic") == "background":
                #     unique_name = f"{func.__name__}_{band}_{ue_id}_Run{count}"
                # else:
                #     unique_name = f"{func.__name__}_{band}_Run{count}"
                unique_name = f"{func.__name__}_{ue_id}_Run{count}"
                file_logger.error(f"[UNIQUE_CHECK] {unique_name}")
                errors = error_counter["errors"]
                collected_trf_stats = trf_stats.get()
                task_timings[unique_name] = {
                     "Scenario": func.__name__,
                     "Ue_id": ue_id,
                     "Cell": cell,
                     "Band": band,
                     "Technology": cell_map[cell]["technology"],
                     "SA/NSA": shared_context["type"],
                     "Capabilities": shared_context["caps"],
                     "Scenario_type": kwargs.get("scenario_type", "basic"),
                     "Run_id": count,
                     "Start": real_start,
                     "Stop": stop_str,
                     "Duration": duration,
                     "Beam_id": beam_id,
                     "5QI": default_slice_5qi,
                     "QoS": default_5qi_map[default_slice_5qi]["qos_flow"],
                     "Meas_id": kwargs.get("meas_id", None),
                     # "nw_slice": nwslice,
                     "nw_slice": kwargs.get("nwslice", None),
                     "RF_condition": kwargs.get("rf_condition", None),
                     "Errors": errors,
                     "Notepad_regex": f"UE{ue_id}:|UE-{ue_id}|id={ue_id}|ue={ue_id}|UE #{ue_id}|Ue:{ue_id}",
                     "VoNR": kwargs.get("vonr", None),
                     "Period": period if period else collected_trf_stats["period"],
                     "data_dl[pdu1_qfi1]": collected_trf_stats["dl_data"],
                     "data_ul[pdu1_qfi1]": collected_trf_stats["ul_data"],
                     "sign_dl[pdu2_qfi1]": collected_trf_stats["dl_sign"],
                     "sign_ul[pdu2_qfi1]": collected_trf_stats["ul_sign"],
                     "vonr_dl[pdu2_qfi2]": collected_trf_stats["dl_vonr"],
                     "vonr_ul[pdu2_qfi2]": collected_trf_stats["ul_vonr"]
                }
                current_error_counter.reset(token)
                trf_stats.reset(token_stats)
        return wrapper
    return decorator
