def skip_body(body):
    return {}


def return_unprocessed(body):
    return {'message_body': body}


def strip_and_zip_at(x, array):
    """
    strips x elements from both sides af array
    and zips them together
    it is assumed that len(array) is even
    input :  'currentSlot,currentSfn,66,87'
    output: {'currentSlot': '66', 'currentSfn': '87'}

    IF MESSAGE IS INCOMPLETE, len(arguments) IS NOT len(values)
    THEN RETURN DICT WITCH EVERY AVAILABLE KEY WITH VALUE None
    LIKE {'currentSlot': None, 'currentSfn': None, ...}

    :param x: int
    :param array: list
    :return: dict
    """
    arguments = array[:x]
    values = array[-x:]

    if len(arguments) != len(values):
        return {key: None for key in arguments}

    return dict(zip(arguments, values))


def strip_and_zip_in_middle(array):
    return strip_and_zip_at(int(len(array)/2), array=array)


def default_process_csv_message(message_body):
    """
    splits into keys and args in middle returns a dict like
    input :  'currentSlot,currentSfn,66,87'
    output: {'currentSlot': '66', 'currentSfn': '87'}

    :param message_body: string
    :return: dict
    """
    return strip_and_zip_in_middle(message_body.split(','))


def process_dlTdSchedSubcellData(message_body):
    """
    splits into keys and args in middle returns a dict like
    input :  'currentSlot,currentSfn,66,87'
    output: {'currentSlot': '66', 'currentSfn': '87'}
    but only for the arguments that actually have values assigned,
    it also renames each new set of (rnti, resReqClassSubPrio, resReqClassPrio)args with adding 2,3 etc. to their names

    :param message_body: string
    :return: dict
    """
    message_body = message_body.split(',,')[0]
    message_body = message_body.split(',')
    params_list = []
    numbers = []
    for x in range(0, len(message_body)):
        if message_body[x].isdigit():
            numbers.append(message_body[x])

    for x in range(0, len(numbers)):
        key_to_add = message_body[x]
        number = 0
        while key_to_add in params_list:
            number += 1
            key_to_add += str(number)
            key_to_add.replace(' ', '')
        params_list.append(key_to_add)
    params_list.extend(numbers)
    return strip_and_zip_in_middle(params_list)


def process_array_message(message_body):
    def get_rnti_indexes(param_names):
        rnti_indexes = []
        for ind, name in enumerate(param_names):
            if name == 'rnti':
                rnti_indexes.append(ind)
        return rnti_indexes

    def split_body_into_params_and_values_lists(message_body):
        message_body_list = message_body.split(',')
        for ind, item in enumerate(message_body_list):
            if item.isdigit():
                return message_body_list[:ind], message_body_list[ind:]
        return [], []

    def remove_trailing_commas(message_body):
        return message_body.split(',,')[0]

    message_body = remove_trailing_commas(message_body)
    param_names, param_values = split_body_into_params_and_values_lists(message_body)
    rnti_indexes = get_rnti_indexes(param_names)
    assert len(rnti_indexes) > 2, "This message should not be proccessed as Array messsage. " \
                                  "\nMessage body: {}".format(message_body)
    message_list = []
    common_trunk = strip_and_zip_in_middle(param_names[:rnti_indexes[1]] + param_values[:rnti_indexes[1]])
    common_trunk['nr_cell_id'] = common_trunk.pop("physCellId")
    common_trunk.pop('rnti')
    for ind, rnti_ind in enumerate(rnti_indexes[1:-1]):
        if len(param_values) <= rnti_ind:
            break
        message = strip_and_zip_in_middle(param_names[rnti_ind:rnti_indexes[ind + 2]] +
                                          param_values[rnti_ind:rnti_indexes[ind + 2]])
        message.update(common_trunk)
        message_list.append(message)
    return message_list
