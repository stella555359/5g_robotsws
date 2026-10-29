"""
        Keywords Purpose:
            Keywords to replace patterns by values in a file

        AUTHOR (I&V-1):
            Michel Wu       michel.wu@nokia.com
"""


class setPatternValue(object):

    def applicate_pattern_value(self, pattern_list, file_src, file_dst):
        input_file = open(file_src, "r")
        output_file = open(file_dst, "w")
        for line in input_file:
            new_line = line
            for pattern in pattern_list:
                new_line = new_line.replace(pattern[0], pattern[1])
            output_file.writelines(new_line)
        input_file.close()
        output_file.close()
        return True
