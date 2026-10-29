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

    # TODO: think how to handle that, maybe return {'incomplete_message': True} ???
    if len(arguments) != len(values):
        return {key: None for key in arguments}

    return dict(zip(arguments, values))


def strip_and_zip_in_middle(array):
    return strip_and_zip_at(x=int(len(array)/2), array=array)


def default_tti_process_message(message_body):
    """
    splits into keys and args in middle returns a dict like
    input :  'currentSlot,currentSfn,66,87'
    output: {'currentSlot': '66', 'currentSfn': '87'}

    :param message_body: string
    :return: dict
    """
    return strip_and_zip_in_middle(message_body.split(','))


def dlTdSchedSubcellData(message_body):
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
    which_set = 2
    which_item_in_set = 0
    for x in range(0, len(numbers)):
        if message_body[x] in params_list:
            param = message_body[x] + str(which_set)
            param.replace(" ", "")
            which_item_in_set += 1
            if which_item_in_set == 3:
                which_set += 1
                which_item_in_set = 0
            params_list.append(param)
        else:
            param = message_body[x]
            params_list.append(param)
    params_list.extend(numbers)
    return strip_and_zip_in_middle(params_list)


tti_body_process_functions = {'dlTdSchedSubcellData': dlTdSchedSubcellData}
