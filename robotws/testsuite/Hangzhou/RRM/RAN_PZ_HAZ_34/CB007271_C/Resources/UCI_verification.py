from taf.analyzer.pcap import pcap
import logging


def verify_sr_report(sr_period, sr_offset, bip_log_path):
    """
    :param sr_period: periodicity of scheduling request, in slot unit
    :param sr_offset: offset of scheduling request, in slot unit
    :param bip_log_path: full path of bip log
    """

    # Filter out SR report from BIP log and add to list.
    filter = '(((UlData_pucchReceiveRespPsPucchResource_t.srBit == 1) && ' \
             '(UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 1)) ||' \
             '(UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 3)) && uci.sr'
    pcap().setup(infile=bip_log_path, display_filter=filter)
    sfn_list = pcap().get_field_value_by_name(field_name='_3gpp.sfn', attribute_name='show')
    slot_list = pcap().get_field_value_by_name(field_name='_3gpp.slot', attribute_name='show')
    xpath_sr = '//UlData_pucchReceiveRespPsPucchResource_t.srBit[@show!="0"]/' \
               'preceding-sibling::_5g_l1_ul_l2_ps_uldata_pucchep//..//uci.sr'
    sr = pcap().get_field_value_by_xpath(xpath=xpath_sr, attribute_name='show')

    if len(sr) <= 1:
        logging.error("Only 1 SR report in bip log, verification failed.")
        raise Exception()
    if not len(sfn_list) == len(slot_list) == len(sr):
        logging.error("SR report number is not same as filtered packets number, please check")
        raise Exception()
    else:
        sr_list = []
        for i in range(len(sfn_list)):
            cur_sr = dict(sfn=sfn_list[i], slot=slot_list[i], sr_bit=sr[i])
            sr_list.append(cur_sr)
    logging.debug("All sr report in bip log filtered: {} ".format(sr_list))

    sr_period = int(int(sr_period) / 10)  # convert period to frame unit
    sr_slot = int(int(sr_offset) % 10)  # convert offset to slot
    first_sr_sfn = int(sr_list[0]['sfn'])
    last_sr_sfn = int(sr_list[-1]['sfn'])
    actual_sr_num = len(sr_list)
    exp_sr_num = int((last_sr_sfn - first_sr_sfn) / sr_period + 1)

    """
    calculate the interval between 2 consequent sr report from sr list, each interval should be same as
    or multiple of configured sr periodicity.
    If not, raise exception.
    """
    for i in range(actual_sr_num):
        if i == actual_sr_num - 1:
            break
        cur_sfn = int(sr_list[i]['sfn'])
        next_sfn = int(sr_list[i + 1]['sfn'])
        sr_interval = next_sfn - cur_sfn
        if not sr_interval % sr_period == 0:
            logging.error('The interval between 2 SR not match exp interval {}'.format(sr_period))
            raise Exception()
        cur_slot = int(sr_list[i]['slot'])
        if not cur_slot == sr_slot:
            logging.error('The pCSI report on slot {}, does not match exp slot {}'.format(cur_slot, sr_slot))
            raise Exception()

    """
    Check every possible sfn where SR report is expected from UE, if not, log to list missing_sr_position and return.
    If missing_sr_position not empty, raise exception.
    """

    missing_sr_position = []
    if not actual_sr_num == exp_sr_num:
        logging.debug("Checking if SR is missing in expected position.")
        actual_sr_sfn_list = []
        for i in range(actual_sr_num):
            cur_sfn = int(sr_list[i]['sfn'])
            actual_sr_sfn_list.append(cur_sfn)
        for i in range(exp_sr_num):
            exp_sfn = int(first_sr_sfn + sr_period * i)
            if exp_sfn not in actual_sr_sfn_list:
                missing_sr_position.append(exp_sfn)
                logging.debug('There is no SR report on the expect sfn {}'.format(exp_sfn))

    problematic_sfn = []
    for i in missing_sr_position:
        filter_pusch_resp_lo = 'uldata_puschreceiveresplo && 3gpp.sfn==' + str(i) + ' && 3gpp.slot==' + str(sr_slot)
        pcap().setup(infile=bip_log_path, display_filter=filter_pusch_resp_lo)
        try:
            pcap().get_packets()
            logging.info("SR report missing in SFN {} slot {} because UL data is scheduled on this slot".
                         format(i, sr_slot))
        except Exception:
            problematic_sfn.append(i)

    if not problematic_sfn == []:
        logging.error('All expected SFN positions had been checked, SR report missed on:{}, '
                      'and no UL data scheduled at the same time'
                      .format(problematic_sfn))
        raise Exception()


def verify_pcsi_report(pcsi_period, pcsi_offset, bip_log_path):
    pcap().setup(infile=bip_log_path, display_filter='uci.cqi')
    sfn_list = pcap().get_field_value_by_name(field_name='_3gpp.sfn', attribute_name='show')
    slot_list = pcap().get_field_value_by_name(field_name='_3gpp.slot', attribute_name='show')
    cqi = pcap().get_field_value_by_name(field_name='uci.cqi', attribute_name='show')

    if len(cqi) <= 1:
        logging.error("Only 1 pCSI report in bip log, verification failed.")
        raise Exception()
    if not len(sfn_list) == len(slot_list) == len(cqi):
        logging.error("pCSI report number is not same as filtered packets number, please check")
        raise Exception()
    else:
        pcsi_list = []
        for i in range(len(sfn_list)):
            cur_pcsi = dict(sfn=sfn_list[i], slot=slot_list[i], cqi=cqi[i])
            pcsi_list.append(cur_pcsi)
    logging.debug("All pCSI report in bip log filtered: {} ".format(pcsi_list))

    pcsi_period = int(int(pcsi_period) / 10)  # convert period to frame unit
    pcsi_slot = int(int(pcsi_offset) % 10)  # convert offset to slot
    first_pcsi_sfn = int(pcsi_list[0]['sfn'])
    last_pcsi_sfn = int(pcsi_list[-1]['sfn'])
    actual_pcsi_num = len(pcsi_list)
    exp_pcsi_num = int((last_pcsi_sfn - first_pcsi_sfn) / pcsi_period + 1)

    logging.debug("Start to check the sfn and slot position.")
    for i in range(actual_pcsi_num):
        if i == actual_pcsi_num - 1:
            break
        cur_sfn = int(pcsi_list[i]['sfn'])
        next_sfn = int(pcsi_list[i + 1]['sfn'])
        pcsi_interval = next_sfn - cur_sfn
        if not pcsi_interval % pcsi_period == 0:
            logging.error('The interval between 2 pCSI report not match exp interval {}'.format(pcsi_period))
            raise Exception()
        cur_slot = int(pcsi_list[i]['slot'])
        if not cur_slot == pcsi_slot:
            logging.error('The pCSI report on slot {}, does not match exp slot {}'.format(cur_slot, pcsi_slot))
            raise Exception()

    missing_pcsi_position = []
    if not actual_pcsi_num == exp_pcsi_num:
        logging.debug("Checking if pCSI report is missing in expected position.")
        actual_pcsi_sfn_list = []
        for i in range(actual_pcsi_num):
            cur_sfn = int(pcsi_list[i]['sfn'])
            actual_pcsi_sfn_list.append(cur_sfn)
        for i in range(exp_pcsi_num):
            exp_sfn = int(first_pcsi_sfn + pcsi_period * i)
            if exp_sfn not in actual_pcsi_sfn_list:
                missing_pcsi_position.append(exp_sfn)
                logging.debug('There is no pCSI report on the expect sfn {}'.format(exp_sfn))

    if not missing_pcsi_position == []:
        logging.error('All expected SFN positions had been checked, pCSI report missed on SFN:{}.'
                      .format(missing_pcsi_position))
        raise Exception()
    else:
        logging.info("pCSI report verification for log {} succeed.".format(bip_log_path))


def verify_multiple_files(bip_log_list, *xargs):
    """

    :param bip_log_list: a list of bip log path
    :param xargs:
    :return:
    """
    verify_function, period, offset, failure_msg = xargs
    verification_result = 'fail'
    for bip_log_path in bip_log_list:
        logging.info("Verifying bip file {}".format(bip_log_path))
        try:
            verify_function(period, offset, bip_log_path)
        except Exception:
            continue
        else:
            verification_result = 'pass'
            break

    if verification_result == 'fail':
        raise Exception(failure_msg)


def verify_sr_report_in_multiple_files(sr_period, sr_offset, bip_log_list):
    """

    :param sr_period:
    :param sr_offset:
    :param bip_log_list:
    :return:
    """
    verify_multiple_files(bip_log_list, verify_sr_report, sr_period, sr_offset,
                          'SR report verification failed for all bip logs')


def verify_csi_report_in_multiple_files(pcsi_period, pcsi_offset, bip_log_list):
    """

    :param pcsi_period:
    :param pcsi_offset:
    :param bip_log_list:
    :return:
    """
    verify_multiple_files(bip_log_list, verify_pcsi_report, pcsi_period, pcsi_offset,
                          'pCSI report verification failed for all bip logs')
