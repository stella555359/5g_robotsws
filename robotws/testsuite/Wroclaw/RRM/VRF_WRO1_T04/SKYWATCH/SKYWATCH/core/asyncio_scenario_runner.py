from robot.utils import timestr_to_secs
from datetime import datetime, timezone
from core.RegexWatcher import (watcher, set_log_file, reset_watcher, reset_loggers, CSV_FILE_TIMINGS,
                               log_path, logger, max_reached)
from scenarios.Static_SA import Precondition_For_Tests
from core.engine.plots import generate_active_scenarios_in_time
from core.engine.progress_bar import Status, progress_renderer
from core.engine.scenarios_preparation import precondition_and_background_ue, prepare_main_scenarios, csv_timings
from core.engine.scenarios_runner import run_scenarios, run_background_scenarios
from core.engine.semaphore import DynamicSemaphore, calculate_semaphore_max, wait_for_stabilization_ues
from core.workloads.common import execute_wts_command
from core.scout.kpi_reports import save_test_time
from helpful_scripts.utilities import get_machine_name
import asyncio
import socket


def get_actual_log_path():
    return log_path._get_target()


def reset_all_loggers():
    reset_loggers()


async def run_asynch(semaphore_dict, sem_limit, semaphore_background, sem_back_limit, timeout=None, testname=None):
    start = datetime.now(timezone.utc)
    # connect_to_scout(get_machine_name().replace("-", "_"))
    if timeout is not None:
        timeout = timestr_to_secs(timeout)
    timeout_at = None
    stop = None
    await watcher.start_watching_telnet()
    await asyncio.sleep(5)
    await Precondition_For_Tests(watcher=watcher)
    background_queue, semaphore_background = await precondition_and_background_ue(semaphore_background, sem_back_limit)
    queue_dict = await prepare_main_scenarios(semaphore_dict)
    status = Status(list(queue_dict.keys()))
    asyncio.create_task(wait_for_stabilization_ues(status, sum(sem_limit.values()), sem_back_limit))

    renderer = asyncio.create_task(progress_renderer(timeout, status, list(queue_dict.keys())))
    background_task = asyncio.create_task(run_background_scenarios(background_queue, semaphore_background,
                                                                   sem_back_limit, status))
    # max_reached.set()
    await max_reached.wait()
    # start = datetime.now()
    # max_reached.clear()
    tasks = [asyncio.create_task(
        run_scenarios(queue_dict[cell], semaphore_dict[cell], sem_limit[cell], status, cell)) for cell in queue_dict]

    try:
        await asyncio.wait_for(asyncio.gather(*tasks), timeout=timeout)
        # await asyncio.wait_for(
        #     run_scenarios(queue, semaphore, sem_limit, status), timeout=timeout
        # )
    except asyncio.CancelledError:
        print("GLOBALLY CANCELLED")
    except asyncio.TimeoutError:
        timeout_at = datetime.now()
        # stop = datetime.now().isoformat()
        stop = datetime.now(timezone.utc)
        timeout_at_str = timeout_at.strftime('%Y-%m-%d %H:%M:%S,%f')
        logger.warning(f"GLOBAL TIMEOUT AT: {timeout_at_str}")
        logger.warning(f"Done! Total time:\n")

    finally:
        save_test_time(testname, start, end=stop)
        background_task.cancel()
        renderer.cancel()
        await asyncio.gather(renderer, return_exceptions=True)
        for queue in queue_dict.values():
            while not queue.empty():
                queue.get_nowait()
                queue.task_done()
        await watcher.stop()
        await reset_watcher()
        execute_wts_command(cmd=f"ue_deregister id=1-200 ue_deregister_type=switch_off")
        execute_wts_command(cmd=f"ue_detach id=1001-1200")
        execute_wts_command(cmd=f"ue_deregister id=2001-2104 ue_deregister_type=switch_off")
        execute_wts_command(cmd=f"ue_deregister id=4001-4104 ue_deregister_type=switch_off")
        execute_wts_command(cmd=f"ue_deregister id=7001-7104 ue_deregister_type=switch_off")
        return timeout_at


# WORKING NORMALLY
def main():
    LIMIT_SCEN = 42
    LIMIT_BACKGROUND = 5
    SCEN_LIMIT = asyncio.Semaphore(LIMIT_SCEN)
    BACKGROUND_LIMIT = asyncio.Semaphore(LIMIT_BACKGROUND)
    set_log_file()
    asyncio.run(run_asynch(SCEN_LIMIT, LIMIT_SCEN, BACKGROUND_LIMIT, LIMIT_BACKGROUND))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(CSV_FILE_TIMINGS._get_target())


def run_skywatch_project(timeout=None, testname=None):
    LIMIT_SCEN = 80
    percentage = {
        "n71": "23%",
        "n25": "20%",
        "n41": "57%"
    }

    semaphore_limits = calculate_semaphore_max(LIMIT_SCEN, percentage)
    # semaphore_limits = {'n71': 10, 'n25': 16, 'n41': 45}
    LIMIT_SCEN_START = 0
    LIMIT_BACKGROUND_START = 0
    LIMIT_BACKGROUND = 70
    semaphores_dict = {
        "n41": DynamicSemaphore(LIMIT_SCEN_START),
        "n71": DynamicSemaphore(LIMIT_SCEN_START),
        "n25": DynamicSemaphore(LIMIT_SCEN_START)
    }
    # SCEN_LIMIT = DynamicSemaphore(LIMIT_SCEN_START)
    BACKGROUND_LIMIT = DynamicSemaphore(LIMIT_BACKGROUND_START)
    set_log_file()
    logger.warning(f"semaphores: {semaphore_limits}")
    timeout_at = asyncio.run(run_asynch(semaphores_dict, semaphore_limits, BACKGROUND_LIMIT, LIMIT_BACKGROUND,
                                        timeout, testname))
    csv_timings(CSV_FILE_TIMINGS._get_target())
    generate_active_scenarios_in_time(timeout_at, CSV_FILE_TIMINGS._get_target())


if __name__ == "__main__":
    main()
