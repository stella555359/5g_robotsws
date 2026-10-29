from robot.api import logger
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_all_frames
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.mcs.PuschFrame import PuschFrame


mcs_filter = 'uldata_puschreceivereq'


def get_frames_from_pcap(pcap_file, ts_filter=mcs_filter):
    frames = get_all_frames(pcap_file=pcap_file, lua_attached=False, ts_filter=ts_filter)
    mcs_frames = [PuschFrame(frame) for frame in frames]
    return mcs_frames


def get_mcs_average(frames):
    """
    Frames should be an iterable of PuschFrame instances.
    """
    mcs_values = [f.mcs for f in frames if f.mcs]

    mcs_avg = sum(mcs_values) / float(len(mcs_values))

    logger.info("Average MCS = {}".format(mcs_avg))
    logger.info("Count of mcs values gathered: {}".format(len(frames)))

    return mcs_avg


def get_mcs_table(frames):
    """
        Frames should be an iterable of PuschFrame instances.
    """
    mcs_tables = [f.mcs_table for f in frames if f.mcs_table]
    mcs_table_256_count = mcs_tables.count('256QAM')
    mcs_table_avg = float(mcs_table_256_count) / len(mcs_tables)

    logger.info("Count of gathered packets containing mcs table info : {} ".format(len(mcs_tables)))
    logger.info("Percentage of packets having 256QAM MCS table: {0:.0000000000000%}".format(mcs_table_avg))

    mcs_table = ''
    if mcs_table_avg == 0:
        mcs_table = '64QAM'
    elif mcs_table_avg > 0.99:
        mcs_table = '256QAM'
    else:
        logger.error("The MCS table shouldn't fluctuate.")

        # TODO: correct that message
        # logger.warn("MCS Table values gathered: {}", mcs_tables)

    if mcs_table_avg != 0 and mcs_table_avg != 1:
        logger.warn("Found some deviated packets.")

        # TODO: correct that message
        # logger.warn("MCS Table values gathered: {}", mcs_tables)

    return mcs_table


def filter_frames_by_rnti(frames, rnti):
    """
        frames should be an iterable of PuschFrame instances.
    """
    rnti_frames = list(filter(lambda frame: frame.rnti == rnti, frames))
    return rnti_frames


def is_valid_mcs_c_rnti(rnti):
    return 1 <= rnti <= 65519


def remove_insignificant_rntis(frames_for_rnti, frames_count_treshold):
    for rnti in list(frames_for_rnti):
        if len(frames_for_rnti[rnti]) < frames_count_treshold:
            del frames_for_rnti[rnti]

    return frames_for_rnti


def get_frames_for_rntis_mapping(frames):
    """
        frames should be an iterable of PuschFrame instances.
        Returns an ordered dictionary. The keys are RNTIs, the values are lists of frames.
        Only valid MCS-C-RNTIs are preserved.
        The order of RNTIs is consistent with their chronology in PCAP.
    """
    rntis = [frame.rnti for frame in frames if frame.rnti and is_valid_mcs_c_rnti(frame.rnti)]
    frames_for_rnti = dict.fromkeys(rntis)

    for rnti in frames_for_rnti.keys():
        frames_for_rnti[rnti] = filter_frames_by_rnti(frames, rnti)

    remove_insignificant_rntis(frames_for_rnti, frames_count_treshold=30)

    return frames_for_rnti
