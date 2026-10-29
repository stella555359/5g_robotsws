from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB008661.A.resources.test_specific_keywords import \
    perform_ping_test_on_ue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import assign_release_version
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore


@logged_keyword
def activate_micro_dtx_and_optimized_scheduler_specific_version_w(nr_delta, nrbts_dist_name, nrcell_dist_name):
    ds = DeltaStore()
    ds.initialise_delta_store(name=nr_delta)

    ds.add_parameters_to_delta(nrbts_dist_name, actMicroDTX='true')
    ds.add_parameters_to_delta(nrcell_dist_name, actDtxOptimizedScheduler='true')

    if assign_release_version() not in ['SBTS22R4', 'SBTS23R1']:
        ds.add_complex_item_to_delta(nrcell_dist_name, 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='10',
                                     dtxPrbThreshold='100',
                                     caSupportEnabled='false',
                                     drbDifferentiationEnabled='false',
                                     drxSupportEnabled='false',
                                     multiCellSyncEnabled='false',
                                     rlcStatusPduSupportEnabled='false')
    else:
        ds.add_complex_item_to_delta(nrcell_dist_name, 'dtxOptimizedScheduler',
                                     dtxDelaySinceLastScheduling='0',
                                     dtxMaxRetentionDelay='10',
                                     dtxPrbThreshold='100')

    delta_store = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_store)


def perform_ping_latency_test_for_8238(ue_serial_number, count, packet_size, ip, latency_threshold):
    perform_ping_test_on_ue(ue_serial_number, count, packet_size, ip, latency_threshold)
