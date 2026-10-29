from apscheduler.schedulers.background import BackgroundScheduler
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from moler.exceptions import CommandTimeout, ConnectionObserverTimeout
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du, ws_du
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


bg_scheduler = BackgroundScheduler()


@load_moler_configuration_from_tl()
def ping_lmp_address_in_the_background(bts_id=0, du_id=0, lmp_address='192.168.255.129', stop_after=15 * 60):

    ws_du_name = ws_du.format('GNB', bts_id, du_id)
    ws_du_new_name = "{}_PING".format(ws_du_name)
    bts_ws = DeviceFactory.get_cloned_device(source_device=ws_du_name, new_name=ws_du_new_name)
    ping_cmd = bts_ws.get_cmd(cmd_name="ping", cmd_params={'destination': lmp_address})
    try:
        ping_cmd.start(stop_after)
    except (CommandTimeout, ConnectionObserverTimeout):
        pass


def check_admin_process_in_the_background(interval=10):
    bg_scheduler.add_job(func=_check_admin_process, trigger='interval', seconds=interval)
    bg_scheduler.start()


def shutdown_checking_admin_process():
    bg_scheduler.shutdown(wait=False)


@load_moler_configuration_from_tl()
def _check_admin_process(bts_id=0, du_id=0, process_name='BTSOMexe'):
    bts_name = ssh_bts_du.format('GNB', bts_id, du_id)
    bts_new_name = "{}_PROCESS".format(bts_name)
    bts = DeviceFactory.get_cloned_device(source_device=bts_name, new_name=bts_new_name)
    bts.goto_state(state="FCT")
    ps_cmd = bts.get_cmd(cmd_name='ps', cmd_params={'options': '-ef'})
    results = ps_cmd()
    for process in results:
        if process_name in process['CMD']:
            MolerTest.info("Process {} exists".format(process_name))
            return True

    MolerTest.info("Process {} NOT exists".format(process_name))
    return False
