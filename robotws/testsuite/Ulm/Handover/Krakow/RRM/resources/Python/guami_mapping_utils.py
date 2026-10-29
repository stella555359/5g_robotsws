# -*- coding: utf-8 -*-
import os
import pprint

from ta_egate_cmd_parser import ta_egate_cmd_parser

SUPPORTED_GUAMI_TYPE = ['native', 'mapped']
ALLOWED_OUTPUT_TYPE = ['wts', 'bit']
AMF_IDENTIFIER_DEC_MAX = 2 ** 24
AMF_REGION_DEC_MAX = 255
AMF_REGION_BITLENGTH = 8

AMF_SET_DEC_MAX = 1023
AMF_SET_BITLENGTH = 10

AMF_POINTER_DEC_MAX = 63
AMF_POINTER_BITLENGTH = 6

MME_GROUP_ID_BITLENGTH = 16
MME_GROUP_ID_REGION_PART_BITLENGTH = 8
MME_GROUP_ID_SET_PART_BITLENGTH = 8
MME_CODE_BITLENGTH = 8
MME_CODE_AMF_SET_PART_BITLENGTH = 2

ta_egate_cmd_parser_instance = ta_egate_cmd_parser()


def get_available_wts_slice_ids():
    """
    Invokes nwslice_disp command on egate
    Return dict of ids and sst/sd values, e.g. {'1':{'sst':'1', 'sd':'2'}, '2':{'sst':3, 'sd':4}
    """
    nwslice_disp_cmd = ta_egate_cmd_parser_instance.get_command('nwslice_disp')
    ret = {}
    cmd_out = nwslice_disp_cmd.without_id().execute_and_parse()
    """ Returns:
            {'1':
                {'Id': '1',
                 'Qos Flow Ids': '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16',
                 'Qos Rule Ids': '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16',
                 'SD': 'D143A5',
                 'SST': '01'}
             }"""
    for nwslice_id in cmd_out:
        ret[str(nwslice_id)] = {'sst': str(cmd_out[nwslice_id]['SST']),
                                'sd': str(cmd_out[nwslice_id]['SD'])}
    print('Returning mapping:\n{}'.format(pprint.pformat(ret)))
    return ret


def amf_region_set_pointer_to_amf_identifier(region, amfset, pointer, guami_type, output_type='wts'):
    """
    Converts decimal value of region, set and pointer according to 5G_CP_IF_RRC_930
    If value is set to:
    - mapped:
    amf-Identifier = E-UTRAN <MME Group ID><MME Code>
        E‑UTRAN <MME Group ID> maps to 5GS <AMF Region ID> and part of 5GS <AMF Set ID> as follows:
    -    8 bits of the E‑UTRAN <MME Group ID> starting at bit 15 and down to bit 8 are mapped into bit 7
    and down to bit 0 of the 5GS <AMF Region ID>;
    -    8 bits of the E‑UTRAN <MME Group ID> starting at bit 7 and down to bit 0 are mapped into bit 9 and
    down to bit 2 of the 5GS <AMF Set ID>;E-UTRAN <MME Code> maps to 5GS <AMF Set ID> and 5GS <AMF Pointer> as follows:
    -    2 bits of the E‑UTRAN <MME Code> starting at bit 7 and down to bit 6 are mapped into bit 1 and
    down to bit 0 of the 5GS <AMF Set ID>;
    -    6 bits of the E‑UTRAN <MMEC Code> starting at bit 5 and down to bit 0 are mapped into bit 5 and
    down to bit 0 of the 5GS <AMF Pointer >;
    - native:
    amf-Identifier = <AMF Region ID><AMF Set ID><AMF Pointer>
    - AMF Region ID shall be of 8 bits length.
    - AMF Set ID shall be of 10 bits length.
    - AMF Pointer shall be of 6 bits length.
    """
    assert output_type in ALLOWED_OUTPUT_TYPE, 'Output type: {} not supported. Allowed: {}'\
        .format(output_type, ALLOWED_OUTPUT_TYPE)
    assert guami_type in SUPPORTED_GUAMI_TYPE, 'Guami Type: {} not supported. Allowed: {}' \
        .format(guami_type, SUPPORTED_GUAMI_TYPE)
    assert int(region) <= AMF_REGION_DEC_MAX, 'Region value: {} out of range: {}'.format(
        region, AMF_REGION_DEC_MAX)
    assert int(amfset) <= AMF_SET_DEC_MAX, 'Set value: {} out of range: {}'.format(
        region, AMF_SET_DEC_MAX)
    assert int(pointer) <= AMF_POINTER_DEC_MAX, 'Pointer value: {} out of range: {}'\
        .format(region, AMF_POINTER_DEC_MAX)
    amf_region_bit = "".join(list(bin(int(region)))[
                             2:]).zfill(AMF_REGION_BITLENGTH)
    assert len(amf_region_bit) == AMF_REGION_BITLENGTH
    amf_set_bit = "".join(list(bin(int(amfset)))[2:]).zfill(AMF_SET_BITLENGTH)
    assert len(amf_set_bit) == AMF_SET_BITLENGTH
    amf_pointer_bit = "".join(list(bin(int(pointer)))[
                              2:]).zfill(AMF_POINTER_BITLENGTH)
    assert len(amf_pointer_bit) == AMF_POINTER_BITLENGTH

    if guami_type == 'native':
        if output_type == 'wts':
            return "{}:{}:{}".format(region, amfset, pointer)
        elif output_type == 'bit':
            return "{}{}{}".format(amf_region_bit, amf_set_bit, amf_pointer_bit)
    elif guami_type == 'mapped':
        # all ids are just glued and then cut in different place
        whole_id_no_cut = "{}{}{}".format(
            amf_region_bit, amf_set_bit, amf_pointer_bit)
        mme_group_id = whole_id_no_cut[:MME_GROUP_ID_BITLENGTH]
        mme_code = whole_id_no_cut[MME_GROUP_ID_BITLENGTH:]
        if output_type == 'wts':
            return "{}:{}".format(int(mme_group_id, 2), int(mme_code, 2))
        elif output_type == 'bit':
            return "{}{}".format(mme_group_id, mme_code)


def amf_identifier_to_region_set_pointer(identifier, guami_type):
    """
    Converts back the amf identifier to region and pointer based on guami type value
    """
    # TO DO: check type of identifier - string/bit/hex ?
    assert guami_type in SUPPORTED_GUAMI_TYPE, 'Guami Type: {} not supported. Allowed: {}'\
        .format(guami_type, SUPPORTED_GUAMI_TYPE)
    assert int(identifier, 2) <= AMF_IDENTIFIER_DEC_MAX, 'Wrong value of identifier, got dec: {}, max dec is: {}'\
        .format(int(identifier, 2), AMF_IDENTIFIER_DEC_MAX)
    # decoding based on bits does not depend on guami type value
    region_bit = identifier[:AMF_REGION_BITLENGTH]
    amf_region = int(region_bit, 2)
    set_bit = identifier[AMF_REGION_BITLENGTH:AMF_REGION_BITLENGTH +
                         AMF_SET_BITLENGTH]
    amf_set = int(set_bit, 2)
    pointer_bit = identifier[AMF_REGION_BITLENGTH + AMF_SET_BITLENGTH:]
    amf_pointer = int(pointer_bit, 2)
    return amf_region, amf_set, amf_pointer


# test native
(reg, amf_set, pointer) = (2, 4, 8)
amf_id_native = amf_region_set_pointer_to_amf_identifier(reg, amf_set, pointer,
                                                         guami_type='native', output_type='bit')
dec_reg, dec_amf_set, dec_pointer = amf_identifier_to_region_set_pointer(
    amf_id_native, guami_type='native')
assert (dec_reg, dec_amf_set, dec_pointer) == (reg, amf_set, pointer)

# test mapped

amf_id_mapped = amf_region_set_pointer_to_amf_identifier(reg, amf_set, pointer,
                                                         guami_type='mapped', output_type='bit')
print(amf_id_mapped)
dec_reg, dec_amf_set, dec_pointer = amf_identifier_to_region_set_pointer(
    amf_id_mapped, guami_type='mapped')
assert (dec_reg, dec_amf_set, dec_pointer) == (reg, amf_set, pointer)
