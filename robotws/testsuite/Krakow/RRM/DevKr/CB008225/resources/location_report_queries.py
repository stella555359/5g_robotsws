import re

from testsuite.Krakow.RRM.resources.Python.utilities import get_bin_value_from_dec as _get_bin_value_from_dec


def generate_query_from_nrcell_ref_id_mapping(mapping, cell_id_to_identity_dict):
    """
    mapping type:    (1:1, 2:3, 4:4)
    returns
    areaOfInterestList contains (nRCellIdentity eq "0b000000000000000000000100000000000010" and
    locationReportingReferenceID eq 2)
    """
    query_parts = []
    for cell_id_ref_id in mapping.strip().split(','):
        (cell_id, ref_id) = cell_id_ref_id.strip().split(':')
        assert 'NRCELL-{}'.format(cell_id) in cell_id_to_identity_dict,\
            'Not prersent cell in :{} '.format(cell_id_to_identity_dict)
        cell_id_full = cell_id_to_identity_dict['NRCELL-{}'.format(cell_id)]
        nRCellIdentity_value = _get_bin_value_from_dec(cell_id_full, 36)
        query_parts.append('areaOfInterestList contains (nRCellIdentity eq "0b{}" '
                           'and locationReportingReferenceID eq {})'.format(nRCellIdentity_value, ref_id))
    full_query = " and ".join(query_parts)
    print('Returning full query: {}'.format(full_query))
    return full_query


def get_procedure_or_name_from_message_name(message_name, what):
    """
    name in LocationReport or [1/2]LocationReport
    """
    allowed_get_types = ['procedure', 'message']
    assert what in allowed_get_types, "Only {} allowed".format(allowed_get_types)
    message_prefix_and_name = re.search(r'(?:\[(\d+)[\/\\](\d+)\])?(\S+)', message_name)
    message_name = message_prefix_and_name.group(3)
    procedure_name = "{}{}".format(message_name[0].lower(), message_name[1:])
    if not message_prefix_and_name.group(1):
        if what == 'message':
            return message_name
        else:
            return procedure_name
    else:
        if not message_prefix_and_name.group(1) or not message_prefix_and_name.group(2):
            raise Exception('Could not extract message number from: {}, should use format: [1/2] or [1\\2]')
        else:
            num = message_prefix_and_name.group(1)
            total = message_prefix_and_name.group(2)
            if what == 'message':
                return "{}_{}".format(message_name, num)
            else:
                return "{}*{}".format(total, procedure_name)


if __name__ == '__main__':
    print(get_procedure_or_name_from_message_name('[2/3]LocationReportControl', 'procedure'))
