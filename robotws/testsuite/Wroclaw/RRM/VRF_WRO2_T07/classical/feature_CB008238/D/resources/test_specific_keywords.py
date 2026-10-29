from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher


scf_params_d1 = {'actPdschAtSsbSlots': 'false', 'actPdschRmCsirsForTracking': 'false', 'actMicroDTX': 'true',
                 'actDtxOptimizedScheduler': 'true', 'dtxDelaySinceLastScheduling': '0',
                 'dtxMaxRetentionDelay': '10', 'dtxPrbThreshold': '80',
                 'maxNumOfRrcSA': '275', 'maxNumOfRrcCGRPSA': '275'}

swconfig_flags_8238_d = {'0x580578': ('2', 'rdDtxCS1SizeThreshold for CB008238-D')}

CSI_SIZE_THRESHOLD = '2'
EXPECTED_CSI_SIZE_REACHED_PERCENT = 50


def verify_csi_size_threshold_is_reached(tti_logs):
    """
        csiSize threshold is hardcoded to 2 using a special swconfig flag. The parameter is otherwise unchangeable and
        set to 10.
        """
    with LogHelper() as lh:
        tti_finder = lh.add_tti(log_files=tti_logs)
        tdSched_data_matcher = TTIMessageMatcher('dlTdSchedSubcellData')
        relevant_tdSchedData = tti_finder.find_all(tdSched_data_matcher)
        threshold_reached = 0
        for msg in relevant_tdSchedData:
            if msg.get('cs1Size') == CSI_SIZE_THRESHOLD:
                threshold_reached += 1
                blog(msg('cs1Size'))
    threshold_reached_percent = 100 * float(threshold_reached) / len(relevant_tdSchedData)
    blog('Percent of cases where csiSize threshold was reached: {}%'.format(threshold_reached_percent))
    assert threshold_reached_percent >= EXPECTED_CSI_SIZE_REACHED_PERCENT, \
        'csiSize threshold reached too few times. Expected occurrence: {}%. Current occurrence: {}%'.format(
            EXPECTED_CSI_SIZE_REACHED_PERCENT, threshold_reached_percent)
