import re
import shutil


class Banner(object):
    def __init__(self):
        self.title = "Banner"
        self.rows = []
        self.ascii_tag = ''
        self.banner_sign = '*'
        self.wall_sign = '|'
        self.floor_sign = '-'
        self.divider_sign = '-'
        self.joint_sign = '+'
        self._supplied_text_max_width = 6
        self._top_row_header_width = 0
        self._top_row_value_width = 0

    def with_title(self, title, ascii_tag='\033[1m'):
        self.title = decorate_with_ascii_tag(title, ascii_tag)
        if len(self.title) > self._supplied_text_max_width:
            self._supplied_text_max_width = len(self.title)
        return self

    def with_row(self, row_header, row_value, ascii_tag=''):
        row_header = decorate_with_ascii_tag(str(row_header), ascii_tag)
        row_value = decorate_with_ascii_tag(str(row_value), ascii_tag)
        self.rows.append((row_header, row_value))
        if len(row_header) > self._top_row_header_width:
            self._top_row_header_width = len(row_header)
        if len(row_value) > self._top_row_value_width:
            self._top_row_value_width = len(row_value)
        if self._top_row_value_width + self._top_row_header_width > self._supplied_text_max_width:
            self._supplied_text_max_width = self._top_row_value_width + self._top_row_header_width
        return self

    def with_divider(self, divider=None):
        if divider is not None:
            assert isinstance(divider, str), 'Divider should be one-sign string'
            assert len(divider) == 1, 'Divider should be one-sign string'
            self.rows.append(divider)
        else:
            self.rows.append(self.divider_sign)
        return self

    def __str__(self):
        return self.compose_string()

    def __repr__(self):
        return self.compose_string()

    def compose_string(self, max_width=None, l_margin=3, r_margin=3):
        banner = '\n'
        line_width = max_width if max_width is not None else shutil.get_terminal_size()[0] - 4
        banner_width = self._supplied_text_max_width + 2 + l_margin + r_margin
        banner_width = banner_width + 1 + l_margin + r_margin if self.rows else banner_width
        if line_width < banner_width:
            return self.fallback_print()
        banner += self.format_banner_title(line_width, banner_width)
        for row in self.rows:
            banner += self.format_row(row, line_width, banner_width, l_margin, r_margin)
        banner += center_line(self.floor_sign * banner_width, line_width) + '\n'
        return decorate_with_ascii_tag(banner, self.ascii_tag)

    def fallback_print(self):
        banner = '{}:\n'
        for row in self.rows:
            banner += row + '\n'
        return banner

    def format_banner_title(self, line_width, banner_width):
        title = '{}\n{}\n{}\n'\
            .format(center_line(self.banner_sign * banner_width, line_width),
                    center_line('{bs}{bt}{bs}'.format(bs=self.banner_sign,
                                                      bt=center_line(self.title, banner_width - 2)), line_width),
                    center_line(self.banner_sign * banner_width, line_width))
        return title

    def format_row(self, row, line_width, banner_width, l_margin, r_margin):
        extra_spaces = banner_width - (3 + l_margin + r_margin +
                                       self._top_row_header_width + self._top_row_value_width)
        parity_space = extra_spaces & 1
        extra_spaces = int(extra_spaces / 2)
        l_margin_str = ' ' * l_margin
        r_margin_str = ' ' * r_margin
        if isinstance(row, str):
            divl = row * (l_margin + self._top_row_header_width + extra_spaces + parity_space)
            divr = row * (extra_spaces + self._top_row_value_width + r_margin)
            row_str = center_line('{ws}{divl}{js}{divr}{ws}'.format(ws=self.wall_sign, divl=divl, divr=divr,
                                                                    js=self.joint_sign), line_width)
        else:
            row_str = center_line('{ws}{lm}{rh}{els}{ws}{ers}{rv}{rm}{ws}'
                                  .format(ws=self.wall_sign, lm=l_margin_str,
                                          rh=left_align_line(row[0], self._top_row_header_width), rm=r_margin_str,
                                          rv=right_align_line(row[1], self._top_row_value_width),
                                          els=' ' * (extra_spaces + parity_space), ers=' ' * extra_spaces),
                                  line_width)
        return row_str + '\n'


def center_line(text, width):
    text_length = get_text_length(text)
    spaces_to_add = ' ' * int((width - text_length) / 2)
    parity_space = ' ' * (text_length & 1)
    return spaces_to_add + text + parity_space + spaces_to_add


def left_align_line(text, width):
    text_length = get_text_length(text)
    spaces_to_add = ' ' * (width - text_length)
    return text + spaces_to_add


def right_align_line(text, width):
    text_length = get_text_length(text)
    spaces_to_add = ' ' * (width - text_length)
    return spaces_to_add + text


def get_text_length(text):
    text_without_ascii_escape = re.sub(r'\033\[.*?m', '', text)
    return len(text_without_ascii_escape)


def decorate_with_ascii_tag(text, tag):
    if '\033[' in tag:
        text_with_repeated_tag_after_ascii_resets = re.sub(r'\033\[0m', f'\033[0m{tag}', text)
        text = f"{tag}{text_with_repeated_tag_after_ascii_resets}\033[0m"
    return text
