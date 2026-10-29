from scenarios_list import (prepare_scenario_list, merge_lists, sa_static_scen, gen_sa_ue, gen_pdu_id,
                            sa_static_scen_without_pdu, nsa_static_scen, gen_nsa_ue)
from datetime import datetime
from RegexWatcher import watcher, regex_watcher, command_sender, sent_commands_queue
from common import setup_ute_egate
from Static_SA import Precondition_For_Tests, stop_watcher
import asyncio


START_TIME = datetime.now().strftime('%Y%m%d_%H%M%S')


async def run_asynch():
    tasks = []
    merge_scenarios = merge_lists(
        prepare_scenario_list(sa_static_scen, gen_sa_ue, gw_gen=gen_pdu_id),
        prepare_scenario_list(sa_static_scen_without_pdu, gen_sa_ue),
        prepare_scenario_list(nsa_static_scen, gen_nsa_ue))
    # asyncio.create_task(watcher.watch_telnet())
    regex_watcher.start()
    command_sender.start()
    # asyncio.run(watcher.manage_tasks())
    watcher.sent_commands_queue = sent_commands_queue
    asyncio.create_task(watcher.manage_tasks())
    await asyncio.sleep(5)
    setup_ute_egate()
    await Precondition_For_Tests(watcher=watcher)
    # prepare_amf_for_inactive_state()
    # await prepare_beam_profiles(watcher=watcher)
    # create_cqi_profile()
    # create_bler_profile()
    # create_timing_advance_profiles()
    # prepare_testmode_far_cell_rf_condition()
    # prepare_testmode_mid_cell_rf_condition()
    # create_no_rrc_setup_req_profile()
    # create_no_rrc_setup_complete_profile()

    for func, kwargs in merge_scenarios:
        print(func.__name__, kwargs)
        # with open(f"CMD_LOG_{START_TIME}.txt", "a") as file:
        #     file.write(f"{func.__name__} args: {kwargs}\n")
        task = asyncio.create_task(func(**kwargs))
        tasks.append(task)

    print("Tasks created. Waiting for results...")
    # Await all tasks
    results = await asyncio.gather(*tasks)
    print(f"All data fetched: {results}")
    regex_watcher.terminate()
    command_sender.terminate()
    watcher.stop()
    # await stop_watcher(watcher=watcher)


def main():
    asyncio.run(run_asynch())


if __name__ == "__main__":
    main()
