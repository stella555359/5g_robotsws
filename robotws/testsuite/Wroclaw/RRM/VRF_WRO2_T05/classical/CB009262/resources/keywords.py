from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *


messages_9262_F = [r'"Message_name":\s?"CPRT_CM_SHUTDOWNREQ_ID"',
                   r'IntraGnbSourceHo,\s?targetCellId:\s?830898586[a-zA-Z,\s\\]{1,30}trigger:'
                   r'\s?Handover,\s?result:\s?Success[\d\w\s\\,:]{1,50}IntraGnbTargetHo,\s?sourceCellId:\s?830898576']

messages_9262_I = [r'"nrCellId":\s?"830898576",\s{10,40}"reason":\s?"sCellAdditionBlind"',
                   r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,350}"physCellId":\s?410',
                   r'"User_data":\s?[A-Za-z0-9:",\s\\]{10,70}DuCaConfig,\s?SetupSCellId:\s?830898586']

messages_9262_E = [r'"transformPrecoder":\s?"enabled"',
                   r'"tp-pi2BPSK":\s?"enabled"']


class Filters_mcshark:
    TP_ON_FILTER = 'UlData_puschReceiveReqGrant_t.mcs == 0 && \
    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag == 1'
    PI2BPSK_FLAG = 'UlData_puschReceiveReqGrant_t.modulationOrder'


def create_tshark_command(msg_filter, pcap, parameters, using_mcshark=False):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter(msg_filter) \
            .with_pcap_file(pcap_file=pcap) \
            .inject_additional_parameters('-T fields -e '+parameters)\
            .build()
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter(msg_filter) \
            .with_pcap_file(pcap_file=pcap) \
            .inject_additional_parameters('-T fields -e '+parameters)\
            .build()
        remove_luashark_loading_from_output(output=output)
    return output


if using_mcshark:
    print("MCShark detected")
    Filters = Filters_mcshark


def check_transform_precoder_on(pcap_path):
    result = False
    pcap_data = create_tshark_command(Filters.TP_ON_FILTER, pcap_path, Filters.PI2BPSK_FLAG, using_mcshark)
    print(pcap_data)
    if '1' in pcap_data:
        result = True
    return result
