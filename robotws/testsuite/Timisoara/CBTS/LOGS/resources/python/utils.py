import os


def strip_prompt(content, remove_last_line=True, remove_first_line=True, return_list=False):
    """
    [Documentation]  Strip Prompt
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   11.12.2021,chris.l.cao@nokia-sbell.com, convert robot KW to python KW
    ...   26.12.2023,lingting.sun@nokia-sbell.com, adaption for different CU OCP version
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | content          | yes | content |
    ...	   | remove_last_line | no | remove_last_line, default is True, type is bool |
    ...	   | remove_first_line | no | remove_first_line, default is True, type is bool |
    ...	   | return_list      | no | return_list, default is False, type is bool |
    ...
    ...    *RETURN VALUE*
    ...    string or list
    ...
    ...    Example
    ...    | ${my_content} | Strip Prompt | aaaaa\nbbbb\nccccc |
    ...
    """
    lines = [i.strip() for i in content.split('\n')]
    length = len(lines)
    if length >= 1 and remove_last_line:
        lines.pop(-1)

    if length > 2 and remove_first_line:
        lines.pop(0)

    if return_list is True:
        return lines
    return "\n".join(lines)
