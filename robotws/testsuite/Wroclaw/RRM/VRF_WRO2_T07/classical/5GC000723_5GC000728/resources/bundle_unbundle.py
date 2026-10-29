from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm


sep = '-'*50


params_20mhz = {
    'chBwUl': '20MHz',
    'chBwDl': '20MHz',
    'type0CoresetConfigurationIndex': '6',
    'srbInactivityTimerSA': '100',  # not sure about value
    'drbInactivityTimerSA': '300',  # not sure about value
}


scf_parameters_ack_for_bundle = {
    'cellTechnology': 'FDD',
    'raContentionResolutionTmr': 'sf64',
    'actSACallProcessingDU': 'true',
}
scf_parameters_ack_for_bundle.update(params_20mhz)


scf_parameters_ack_for_unbundle = {
    'cellTechnology': 'FDD',
    'raContentionResolutionTmr': 'sf8',
    'actSACallProcessingDU': 'true'
}
scf_parameters_ack_for_unbundle.update(params_20mhz)


def get_num_as_str(hex_int_string_value):
    return hex_int_string_value.split('(')[-1][:-1]


def check_PucchReceiveRespHarqD(msg):
    # check supports two software versions
    return (
        pm('PucchReceiveRespHarqD')
        .containing('crc (Enum)', '0*OK*')
        .containing('dtx (Enum)', '0*NON_DTX*')
        .containing('ackNack (Bytes)', '80000000000000')
        (msg)
        or
        pm('PucchReceiveRespHarqD')
        .containing('crc (Enum)', '0*OK*')
        .containing('dtx (Enum)', '0*NON_DTX*')
        .containing('ackNack_item_0 (Uint8)', '0x80*')
        .containing('ackNack_item_1 (Uint8)', '0x00*')
        .containing('ackNack_item_2 (Uint8)', '0x00*')
        .containing('ackNack_item_3 (Uint8)', '0x00*')
        .containing('ackNack_item_4 (Uint8)', '0x00*')
        .containing('ackNack_item_5 (Uint8)', '0x00*')
        .containing('ackNack_item_6 (Uint8)', '0x00*')
        (msg)
    )


def find_m1_in(finder):
    m1 = finder.find_next(pm('UlData_PrachReceiveInd_t', name_line_pattern='empty').containing('peakMetric*', '*'))
    assert m1 is not None, 'no PrachReceiveInd found'
    blog('m1:', m1)
    return m1


def find_m3_in(finder):
    m3 = finder.find_next(pm('UlData_PuschReceiveRespLo_t', name_line_pattern='empty'))
    assert m3 is not None, 'no PuschReceiveRespLo found'
    blog('m3:', m3)
    m3_rnti = m3.find('rnti (Uint16)').first()['val']
    blog('m3: rnti:', m3_rnti)
    m3_sfn = m3.find('sfn (Uint16)').first()['val']
    blog('m3: sfn:', m3_sfn)
    return m3, m3_rnti, m3_sfn


def find_m4_in(finder, m3_rnti):
    m4 = finder.find_next(pm('DlData_PdschPayloadTbSendReq_t',
                             name_line_pattern='empty').containing('rnti (Uint16)', m3_rnti))
    assert m4 is not None, 'no PdschPayloadTbSendReq found'
    blog('m4:', m4)
    m4_rnti = m4.find('rnti (Uint16)').first()['val']
    blog('m4: rnti:', m4_rnti)
    return m4, m4_rnti


def find_m4_resp_settings_in(finder):
    m4_resp_settings = finder.find_next(pm('UlData_PucchReceiveReq_t', name_line_pattern='empty'))
    assert m4_resp_settings is not None, 'no PucchReceiveReq found'
    blog('m4_resp_settings', m4_resp_settings)
    assert (
        pm('UlData_PucchReceiveReq_t',
           name_line_pattern='empty').containing(key_pattern='srBitDetection (l1_common_srBitDetection_t)',
                                                 value_pattern='*DISABLED*)')(m4_resp_settings)
    )
    m4_resp_settings_sfn = m4_resp_settings.find('sfn (Uint16)').first()['val']
    blog('m4_resp_settings: sfn:', m4_resp_settings_sfn)
    m4_resp_settings_slot = m4_resp_settings.find('slot (Uint8)').first()['val']
    blog('m4_resp_settings: slot:', m4_resp_settings_slot)
    m4_resp_settings_start_prb = m4_resp_settings.find(
        'startPrb (Uint16)').filter(['pucchResources*', 'pucchResources_item_0*']).first()['val']
    blog('m4_resp_settings: start_prb:', m4_resp_settings_start_prb)
    m4_resp_settings_first_symbol = m4_resp_settings.find('firstSymbol (Uint8)').first()['val']
    blog('m4_resp_settings: first_symbol:', m4_resp_settings_first_symbol)
    m4_resp_settings_numOfSymbols = m4_resp_settings.find('numOfSymbols (Uint8)').first()['val']
    blog('m4_resp_settings: numOfSymbols:', m4_resp_settings_numOfSymbols)
    m4_resp_settings_frequencyHopping = m4_resp_settings.find('frequencyHopping*').first()['val']
    blog('m4_resp_settings: frequencyHopping: ', m4_resp_settings_frequencyHopping)
    m4_resp_settings_secondHopPrb = m4_resp_settings.find('secondHopPrb (Uint16)').first()['val']
    blog('m4_resp_settings: secondHopPrb: ', m4_resp_settings_secondHopPrb)
    return (
        m4_resp_settings, m4_resp_settings_sfn, m4_resp_settings_slot,
        m4_resp_settings_start_prb, m4_resp_settings_first_symbol,
        m4_resp_settings_numOfSymbols, m4_resp_settings_frequencyHopping,
        m4_resp_settings_secondHopPrb
    )


def find_m4_resp_in(finder, m4_resp_settings_slot, m4_resp_settings_sfn):
    m4_resp = finder.find_next(
        pm('UlData_PucchReceiveRespHarqD_t', name_line_pattern='empty')
        .containing('slot (Uint8)', m4_resp_settings_slot)
        .containing('sfn (Uint16)', m4_resp_settings_sfn)
    )
    assert m4_resp is not None, 'no PucchReceiveRespHarqD found'
    blog('f_m4_resp:', m4_resp)
    assert check_PucchReceiveRespHarqD(m4_resp)
    return m4_resp


def find_m5_req_in(finder, m4_rnti):
    m5_req = finder.find_next_anew(
        pm('UlData_PuschReceiveReq_t', name_line_pattern='empty').containing('rnti (Uint16)', m4_rnti)
    )
    assert m5_req is not None, 'no PuschReceiveReq found'
    blog('m5_req:', m5_req)
    return m5_req


def find_m5_resp_in(finder, m4_rnti):
    m5_resp = finder.find_next(
        pm('UlData_PuschReceiveRespHarqU_t', name_line_pattern='empty').containing('rnti (Uint16)', m4_rnti)
    )
    assert m5_resp is not None, 'no PuschReceiveRespHarqU found'
    blog('m5_resp:', m5_resp)
    assert (
        pm('UlData_PuschReceiveRespHarqU_t', name_line_pattern='empty')
        .containing('crc *', 'OK (0)')
        .containing('dtx *', 'NON_DTX (0)')
        (m5_resp)
    )
    return m5_resp


def find_slottype_req(finder, m4_resp_settings_slot, m4_resp_settings_sfn):
    slot_type_req = finder.find_next_anew(
        pm('SlotTypeReq')
        .containing('slot (Uint8)', m4_resp_settings_slot)
        .containing('sfn (Uint16)', m4_resp_settings_sfn),
    )
    blog('slot_type_req: ', slot_type_req)
    slot_type_req_slot_type = slot_type_req.find('*slotType (Enum)*').first()['val']
    blog('slot_type_req: slot type:', slot_type_req_slot_type)
    return slot_type_req


def find_2_slottype_req(
    finder,
    f_m4_resp_settings_slot, f_m4_resp_settings_sfn,
    s_m4_resp_settings_slot, s_m4_resp_settings_sfn
):
    slot_types = finder.find_all_anew([
        pm('SlotTypeReq', tag='f_slot_type_req')
        .containing('slot (Uint8)', f_m4_resp_settings_slot)
        .containing('sfn (Uint16)', f_m4_resp_settings_sfn),
        pm('SlotTypeReq', tag='s_slot_type_req')
        .containing('slot (Uint8)', s_m4_resp_settings_slot)
        .containing('sfn (Uint16)', s_m4_resp_settings_sfn)
    ], forget_matcher_on_hit=True)
    f_slot_type_req = slot_types['f_slot_type_req'][0]
    s_slot_type_req = slot_types['s_slot_type_req'][0]
    f_slot_type_req_slot_type = f_slot_type_req.find('*slotType (Enum)*').first()['val']
    blog('f_slot_type_req: ', f_slot_type_req)
    blog('first: slot_type_req: slot type:', f_slot_type_req_slot_type)
    s_slot_type_req_slot_type = s_slot_type_req.find('*slotType (Enum)*').first()['val']
    blog('s_slot_type_req: ', s_slot_type_req)
    blog('second: slot_type_req: slot type:', s_slot_type_req_slot_type)
    return f_slot_type_req, s_slot_type_req


def find_cell_setup_req(pcap, lua):
    with LogHelper() as lh:
        cellsetup = lh.add_pcap(
            pcap_file_path=pcap,
            lua=lua,
            shark_filter='itf_l2_ps_cell_cellsetupreq',
            clean_up_tmp_file=True
            # clean_up_tmp_file=False
        )
        # cellsetup = lh.add_tshark_output(ts_output_file=cellsetup_pcap)
        cellsetup_req = cellsetup.find_next(pm('itf_l2_ps_cell_CellSetupReq_t', name_line_pattern='empty'))
        assert cellsetup_req is not None, 'no CellSetupReq found'
        blog('cellsetup_req:', cellsetup_req)
        initialUplinkBwp = cellsetup_req.find('initialUplinkBwp*').first()['val']
        cellsetup_req_first_prb = get_num_as_str(initialUplinkBwp('location (Uint16)'))
        blog('cellsetup_req: first prb:', cellsetup_req_first_prb)
        int_banddwith = int(get_num_as_str(initialUplinkBwp('bandwidth (Uint16)')))
        cellsetup_req_last_prb = str(int_banddwith + int(cellsetup_req_first_prb) - 1)
        blog('cellsetup_req: last prb:', cellsetup_req_last_prb)
        return (cellsetup_req, cellsetup_req_first_prb, cellsetup_req_last_prb)


def analyze_bundle(b_cellsetup, b_communication, lua=None):
    with LogHelper() as lh:
        # communication part
        communication_pcap = '/tmp/723e_bundle_communication.pcap.tmp'
        communication = lh.add_pcap(
            pcap_file_path=b_communication,
            lua=lua,
            shark_filter=None,
            ts_output_data_file_path=communication_pcap,
            clean_up_tmp_file=True
            # clean_up_tmp_file=False
        )
        # communication = lh.add_tshark_output(ts_output_file=communication_pcap)

        blog(sep)
        find_m1_in(communication)
        blog(sep)
        m3, m3_rnti, m3_sfn = find_m3_in(communication)
        blog(sep)
        m4, m4_rnti = find_m4_in(communication, m3_rnti)
        blog(sep)
        (m4_resp_settings,
         m4_resp_settings_sfn,
         m4_resp_settings_slot,
         m4_resp_settings_start_prb,
         m4_resp_settings_first_symbol,
         m4_resp_settings_numOfSymbols,
         m4_resp_settings_frequencyHopping,
         m4_resp_settings_secondHopPrb) = find_m4_resp_settings_in(communication)

        blog(sep)
        find_m5_req_in(communication, m4_rnti)
        blog(sep)
        find_m5_resp_in(communication, m4_rnti)

        blog(sep)
        # slot_type_req = find_slottype_req(
        #     communication, m4_resp_settings_slot, m4_resp_settings_sfn
        # )

        blog(sep)
        (cellsetup_req,
         cellsetup_req_first_prb,
         cellsetup_req_last_prb) = find_cell_setup_req(b_cellsetup, lua)

        blog(sep)
        if m4_resp_settings_numOfSymbols in ['0x01(1)', '0x0e(14)', '14']:
            blog('m4_resp_settings_numOfSymbols is {}'.format(m4_resp_settings_numOfSymbols))
            assert_val = 'DISABLED' if m4_resp_settings_numOfSymbols == '0x01(1)' else 'ENABLED'
            assert assert_val in m4_resp_settings_frequencyHopping

            if m4_resp_settings_first_symbol == '0x0c(12)':
                blog('m4_resp_settings_first_symbol is 12')
                # assert pm('SlotTypeReq').c('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(slot_type_req)
                assert get_num_as_str(m4_resp_settings_start_prb) == cellsetup_req_first_prb

            if m4_resp_settings_first_symbol == '0x0d(13)':
                blog('m4_resp_settings_first_symbol is 13')
                # assert pm('SlotTypeReq').nc('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(slot_type_req)
                assert get_num_as_str(m4_resp_settings_start_prb) == cellsetup_req_last_prb

        elif m4_resp_settings_numOfSymbols == '0x02(2)':
            blog('m4_resp_settings_numOfSymbols is 2')
            assert 'ENABLED' in m4_resp_settings_frequencyHopping
            assert m4_resp_settings_first_symbol == '0x0c(12)'
            assert get_num_as_str(m4_resp_settings_start_prb) == cellsetup_req_first_prb
            assert get_num_as_str(m4_resp_settings_secondHopPrb) == cellsetup_req_last_prb

        else:
            assert False


def analyze_unbundle(u_cellsetup, u_communication, lua=None):
    with LogHelper() as lh:
        # communication part
        communication_pcap = '/tmp/723e_unbundle_communication.pcap.tmp'
        communication = lh.add_pcap(
            pcap_file_path=u_communication,
            lua=lua,
            shark_filter=None,
            ts_output_data_file_path=communication_pcap,
            clean_up_tmp_file=True
            # clean_up_tmp_file=False
        )
        # communication = lh.add_tshark_output(ts_output_file=communication_pcap)

        blog(sep)
        find_m1_in(communication)
        blog(sep)
        m3, m3_rnti, m3_sfn = find_m3_in(communication)

        rest = communication.find_all([
            pm('PdschPayloadTbSendReq', tag='m4'),
            pm('PucchReceiveReq', tag='m4_resp_settings'),
            pm('PucchReceiveRespHarqD', tag='m4_resp'),
            pm('PuschReceiveReq', tag='m5_req'),
            pm('PuschReceiveRespHarqU', tag='m5_resp'),
        ])
        blog(sep)
        blog('found messages:')
        for i in rest:
            blog(len(rest[i]), 'of', i)
        i_m4 = lh.add_iterable(iterable=rest['m4'])
        i_m4_resp_settings = lh.add_iterable(iterable=rest['m4_resp_settings'])
        i_m4_resp = lh.add_iterable(iterable=rest['m4_resp'])
        i_m5_req = lh.add_iterable(iterable=rest['m5_req'])
        i_m5_resp = lh.add_iterable(iterable=rest['m5_resp'])

        blog(sep)
        blog('first m4')
        f_m4, f_m4_rnti = find_m4_in(i_m4, m3_rnti)
        blog(sep)
        blog('second m4')
        s_m4, s_m4_rnti = find_m4_in(i_m4, m3_rnti)

        blog(sep)
        blog('first m4_resp_settings')
        (f_m4_resp_settings,
         f_m4_resp_settings_sfn,
         f_m4_resp_settings_slot,
         f_m4_resp_settings_start_prb,
         f_m4_resp_settings_first_symbol,
         f_m4_resp_settings_numOfSymbols,
         f_m4_resp_settings_frequencyHopping,
         f_m4_resp_settings_secondHopPrb) = find_m4_resp_settings_in(i_m4_resp_settings)
        blog(sep)
        blog('second m4_resp_settings')
        (s_m4_resp_settings,
         s_m4_resp_settings_sfn,
         s_m4_resp_settings_slot,
         s_m4_resp_settings_start_prb,
         s_m4_resp_settings_first_symbol,
         s_m4_resp_settings_numOfSymbols,
         s_m4_resp_settings_frequencyHopping,
         s_m4_resp_settings_secondHopPrb) = find_m4_resp_settings_in(i_m4_resp_settings)

        blog(sep)
        blog('first m4_resp')
        find_m4_resp_in(i_m4_resp, f_m4_resp_settings_slot, f_m4_resp_settings_sfn)
        blog(sep)
        blog('second m4_resp')
        find_m4_resp_in(i_m4_resp, s_m4_resp_settings_slot, s_m4_resp_settings_sfn)

        blog(sep)
        find_m5_req_in(i_m5_req, f_m4_rnti)
        blog(sep)
        find_m5_resp_in(i_m5_resp, f_m4_rnti)

        blog(sep)
        f_slot_type_req, s_slot_type_req = find_2_slottype_req(
            communication,
            f_m4_resp_settings_slot, f_m4_resp_settings_sfn,
            s_m4_resp_settings_slot, s_m4_resp_settings_sfn
        )

        blog(sep)
        (cellsetup_req,
         cellsetup_req_first_prb,
         cellsetup_req_last_prb) = find_cell_setup_req(u_cellsetup, lua)

        blog(sep)
        if (
            f_m4_resp_settings_first_symbol == '0x0c(12)' and
            s_m4_resp_settings_first_symbol == '0x0c(12)'
        ):
            blog('m4_resp_settings_first_symbol is 12')
            assert pm('SlotTypeReq').c('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(f_slot_type_req)
            assert pm('SlotTypeReq').c('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(s_slot_type_req)
            assert f_m4_resp_settings_start_prb == cellsetup_req_first_prb
            assert s_m4_resp_settings_start_prb == cellsetup_req_first_prb

        elif (
            f_m4_resp_settings_first_symbol == '0x0d(13)' and
            s_m4_resp_settings_first_symbol == '0x0d(13)'
        ):
            blog('m4_resp_settings_first_symbol is 13')
            assert pm('SlotTypeReq').nc('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(f_slot_type_req)
            assert pm('SlotTypeReq').nc('*slotType (Enum)*', '32*SLOT_TYPE_C5*')(s_slot_type_req)
            assert f_m4_resp_settings_start_prb == cellsetup_req_last_prb
            assert s_m4_resp_settings_start_prb == cellsetup_req_last_prb

        else:
            em = 'both first symbols need to be 0x0c(12) or 0x0d(13) ' \
                 'actual value: first: {} ,second: {}'
            assert False, em.format(
                f_m4_resp_settings_first_symbol,
                s_m4_resp_settings_first_symbol)
