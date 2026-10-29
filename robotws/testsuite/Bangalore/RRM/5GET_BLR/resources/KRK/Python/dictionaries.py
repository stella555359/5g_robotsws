import json
import pprint


class DictDifferentValues(Exception):
    pass


class DictDifferentKeys(Exception):
    pass


def _is_dict(value):
    if isinstance(value, dict):
        return True
    return False


def _format_for_exc(value):
    if _is_dict(value):
        return json.dumps(sorted(list(value.keys())))
    else:
        return value


def compare_dicts(received, expected):
    if received == expected:
        return
    elif _is_dict(received) and len(received) == len(expected) and \
            sorted(list(received.keys())) == sorted(list(expected.keys())):
        for dict_top_key in received:
            print("{}\nkey:\n{}\nreceived:\n{}\nexpected:\n{}"
                  .format('-' * 40, dict_top_key,
                          json.dumps(received[dict_top_key]),
                          json.dumps(expected[dict_top_key])))
            if expected[dict_top_key] != received[dict_top_key]:
                if isinstance(expected[dict_top_key], list) or isinstance(expected[dict_top_key], dict):
                    compare_dicts(received[dict_top_key], expected[dict_top_key])
                else:
                    raise DictDifferentValues('Values for key: {} do not match.\nReceived: {}\nExpected: {}'
                                              .format(dict_top_key,
                                                      pprint.pformat(json.dumps(received[dict_top_key])),
                                                      pprint.pformat(json.dumps(expected[dict_top_key]))))
    else:
        exc_type = DictDifferentKeys if _is_dict(received) else DictDifferentValues
        raise exc_type("\nReceived keys:\n {}\ndoes not match expected keys:\n {}"
                       .format(_format_for_exc(received), _format_for_exc(expected)))
