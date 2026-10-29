import pprint
import re
from testsuite.Krakow.RRM.resources.Python.guami_mapping_utils import amf_region_set_pointer_to_amf_identifier \
    as _amf_region_set_pointer_to_amf_identifier
from testsuite.Krakow.RRM.resources.Python.guami_mapping_utils import get_available_wts_slice_ids \
    as _get_available_wts_slice_ids

PLMN = '311:489'
ALLOWED_OPTIONS = {
    'amf-Identifier': {'regexp': r'(\d+)-(\d+)-(\d+)', 'wts_option': 'registered_amf',
                       'regexp_not_set': r'not_set', 'wts_option_not_set': 'registered_amf=none'},
    'guami-Type': {'regexp': r'(native|mapped)', 'wts_option': 'if_contains=any action=override_ie guami_type',
                   'regexp_not_set': r'not_set', 'wts_option_not_set': 'if_contains=any action=none'},
    's-NSSAI-List': {'regexp': r'(0x\d+)-(0x\w+)', 'wts_option': 'include_nwslice=on',
                     'wts_option_not_set': 'include_nwslice=off'},
    'raw-hex': {'regexp': r'0x(\w+)', 'wts_option': 'if_contains=any action=send_hex hex=rrc_setup_complete:',
                'wts_option_not_set': 'if_contains=any action=none'}
}


def generate_ue_nr_rrc_setup_param_options(fields, field_separator=','):
    options = dict([field.strip().split(':') for field in fields.strip().split(field_separator)])
    param_string = ""
    option_values = {}
    for op in options:
        assert op in ALLOWED_OPTIONS,\
            'Option: {} not allowed, only possible: {}'.format(op, list(ALLOWED_OPTIONS.keys()))
        try:
            value = re.findall(ALLOWED_OPTIONS[op]['regexp'], options[op])[0]
            option_values[op] = value
        except Exception as e:
            if re.findall(ALLOWED_OPTIONS[op]['regexp_not_set'], options[op])[0]:
                print('Value for {} not set, skipping'.format(ALLOWED_OPTIONS[op]))
            else:
                raise Exception('Could not parse value from string: {} for option: {}'.format(options[op], op))
    if 'amf-Identifier' in option_values:
        assert 'guami-Type' in option_values, 'when amf-Identifier is provided, also the guami-Type must be provided'
        reg, a_set, point = option_values['amf-Identifier']
        amf_id = _amf_region_set_pointer_to_amf_identifier(reg, a_set, point, guami_type=option_values['guami-Type'],
                                                           output_type='wts')
        param_string += " {}={}|{}".format(ALLOWED_OPTIONS['amf-Identifier']['wts_option'], PLMN, amf_id)
    else:
        param_string += " {}".format(ALLOWED_OPTIONS['amf-Identifier']['wts_option_not_set'])
    if 'guami-Type' in option_values:
        guami_type = option_values['guami-Type']
        param_string += " {}={}".format(ALLOWED_OPTIONS['guami-Type']['wts_option'], guami_type)
    else:
        param_string += " {}".format(ALLOWED_OPTIONS['guami-Type']['wts_option_not_set'])
    if 's-NSSAI-List' in option_values:
        param_string += " {}".format(ALLOWED_OPTIONS['s-NSSAI-List']['wts_option'])
    else:
        param_string += " {}".format(ALLOWED_OPTIONS['s-NSSAI-List']['wts_option_not_set'])
    if 'raw-hex' in option_values:
        guami_type = option_values['raw-hex']
        param_string += " {}{}".format(ALLOWED_OPTIONS['raw-hex']['wts_option'], guami_type)
    else:
        param_string += " {}".format(ALLOWED_OPTIONS['raw-hex']['wts_option_not_set'])
    print('Returning param string: {}'.format(param_string))
    return param_string


def generate_nr_rrc_setup_verifier(fields, field_separator=','):
    options = dict([field.strip().split(':') for field in fields.strip().split(field_separator)])
    option_values = {}
    verifiers = []
    for op in options:
        assert op in ALLOWED_OPTIONS,\
            'Option: {} not allowed, only possible: {}'.format(op, list(ALLOWED_OPTIONS.keys()))
        try:
            value = re.findall(ALLOWED_OPTIONS[op]['regexp'], options[op])[0]
            option_values[op] = value
        except Exception as e:
            if re.findall(ALLOWED_OPTIONS[op]['regexp_not_set'], options[op])[0]:
                print('Value for {} not set, skipping'.format(ALLOWED_OPTIONS[op]))
            else:
                raise Exception('Could not parse value from string: {} for option: {}'.format(options[op], op))
    if 'amf-Identifier' in option_values:
        assert 'guami-Type' in option_values, 'when amf-Identifier is provided, also the guami-Type must be provided'
        reg, a_set, point = option_values['amf-Identifier']
        amf_id = _amf_region_set_pointer_to_amf_identifier(reg, a_set, point, guami_type=option_values['guami-Type'],
                                                           output_type='bit')
        verifiers.append("(amf-Identifier is present and amf-Identifier eq '0b{}') and"
                         " (guami-Type is present and guami-Type eq '{}')".format(amf_id, option_values['guami-Type']))
    else:
        verifiers.append("(amf-Identifier is not present) and (guami-Type is not present)")
    if 'raw-hex' in option_values:
        verifiers.append("(s-NSSAI-List is present and length(s-NSSAI-List) eq 1)")
    if 's-NSSAI-List' in option_values:
        sst_size = 8
        sd_size = 24
        ssd_sd_size = 32
        sst, sd = option_values['s-NSSAI-List']
        sst_bit = bin(int(sst[2:], 16))[2:].zfill(sst_size)
        sd_bit = bin(int(sd[2:], 16))[2:].zfill(sd_size)
        sst_sd_bit = "{}{}".format(sst_bit, sd_bit)
        assert len(sst_sd_bit) == ssd_sd_size,\
            'sst-SD size should be {}, it is: {}'.format(ssd_sd_size, len(sst_sd_bit))
        ver = "(s-NSSAI-List is present and length(s-NSSAI-List) eq 1" \
              " and sst-SD eq '0b{}')".format(sst_sd_bit)
        verifiers.append(ver)
    verifier = " and ".join(verifiers)
    print('Returning verifier string: {}'.format(verifier))
    return verifier


def generate_ue_register_options(fields, field_separator=','):
    options = dict([field.strip().split(':') for field in fields.strip().split(field_separator)])
    param_string = ""
    option_values = {}
    for op in options:
        assert op in ALLOWED_OPTIONS,\
            'Option: {} not allowed, only possible: {}'.format(op, list(ALLOWED_OPTIONS.keys()))
        try:
            value = re.findall(ALLOWED_OPTIONS[op]['regexp'], options[op])[0]
            option_values[op] = value
        except Exception as e:
            if re.findall(ALLOWED_OPTIONS[op]['regexp_not_set'], options[op])[0]:
                print('Value for {} not set, skipping'.format(ALLOWED_OPTIONS[op]))
            else:
                raise Exception('Could not parse value from string: {} for option: {}'.format(options[op], op))
    if 'amf-Identifier' in option_values:
        pass
    if 'guami-Type' in option_values:
        pass
    if 's-NSSAI-List' in option_values:
        sst, sd = option_values['s-NSSAI-List']
        sst = sst[2:]
        sd = sd[2:]
        slice_mapping = _get_available_wts_slice_ids()
        wts_nwslice_id = None
        for nwslice_id in slice_mapping:
            if slice_mapping[nwslice_id]['sst'] == sst and slice_mapping[nwslice_id]['sd'] == sd:
                wts_nwslice_id = nwslice_id
                break
        assert wts_nwslice_id is not None, \
            'Could not find matching slice Id for sst: {} and sd: {} within mapping:\n{}'\
            .format(sst, sd, pprint.pformat(slice_mapping))
        param_string += " nwslice={}".format(wts_nwslice_id)
    if 'raw-hex' in option_values:
        pass
    print('Returning ue_register param string: {}'.format(param_string))
    return param_string


def map_sst_sd_values_to_int(sst_sd_hex, sep='-'):
    (sst_hex, sd_hex) = sst_sd_hex.split(sep)
    sst_dec = int(sst_hex[2:], 16)
    sd_dec = int(sd_hex[2:], 16)
    print('Mapped sst {}->{}, sd {}->{}'.format(sst_hex, sst_dec, sd_hex, sd_dec))
    return sst_dec, sd_dec
