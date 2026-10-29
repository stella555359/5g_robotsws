"""
Author: Ding Binmei

"""


def is_attribute_exist(obj, attr):
    """
    Author: Ding Binmei
    Check if the object has the attribute
    :param obj: object
    :param attr: attribute name
    :return: True if the object has the attribute, otherwise False
    """
    return hasattr(obj, attr)
