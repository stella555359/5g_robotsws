from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed


def get_number_of_packets_sent(ue=11, id=2, dc_cell_group='mcg'):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    uec_stats = ta5g_ue_wts.execute_egate_command(cmd='bearer_stats ue={} id={} dir=dl dc_cell_group={}'.format(
        ue, id, dc_cell_group), pass_regexp='Total packets sent')
    packets_sent = uec_stats.split("Total packets sent")[1].strip().split(" ")[0]
    return packets_sent


def check_if_number_of_packets_sent_is_bigger_than_given_value(value):
    packets_sent = get_number_of_packets_sent()
    if packets_sent >= value:
        print("Feature works properly")
    else:
        raise ExecutionFailed(message="Too low number of packets {}".format(packets_sent), continue_on_failure=True)
