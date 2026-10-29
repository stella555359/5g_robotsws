def split_string_and_return_list(inputStr: str = "", delimtr: str = " "):
    """
    Arguments       :
        inputStr    :   Give the string whcih you want to convert in list (it should be string)
        delimtr     :   Delimeter should be given on which we need to split the string and
                        deffault value is " "( it should be string)
    Return          :
        StrList     :   Returns the splitted list item
    """
    try:
        StrList = inputStr.split(delimtr)
    except Exception as e:
        print(f"Please check if the valid string is passed {e}")
    return StrList


def return_nth_element_from_list(inputlist: list = [], n: int = 0):
    """
        Arguments       :
            inputlist   :   Give the list from which you need nth element (it should be list)
            n           :   n is the position or index of the element we need.
                            first element index is Zero which is deffault value "( it should be integer)
        Return          :
            StrList     :   nth element of the list
        Exception       :   Raises Keyerror if wrong key or out of range index is passed
        """
    try:
        nth_element = inputlist[n]
    except KeyError as k:
        print(f"Please enter valid index check the length of list - {inputlist} as key error raised {k}")
    except Exception as e:
        print(f"Something went wrong {e}")
    return nth_element


def add_zero_padding(hexRanId, n=16):
    Hex_RanId = (n - len(hexRanId)) * "0" + hexRanId.lower()
    pcmd_RanId = ':'.join(Hex_RanId[i: i + 2] for i in range(0, len(Hex_RanId), 2))
    return pcmd_RanId
