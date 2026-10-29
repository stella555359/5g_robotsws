# Python script used for 8123 B_22 checks (check RRC IE CGuciOnPUSCH)
# Script author : yann.ah.herve@nokia.com
# Script contact: yann.ah.herve@nokia.com
# Creation Date               : 03-Feb-2022
# Last Modified Date          :
# Last Modified by            : yann.ah.herve@nokia.com
# Modification:
#                           |

import os
import sys


def checkCGuciOnPUSCHIEs(egate_console_path):
    """
    It's better to have alook at egate_console because this the place where RRC messages
    are dumped. I have also not found a way to parse the egate console log like for pdml file
    (i.e.: by using something like rrcReconfiguration/.*/pusch-Config setup/.*).
    So, the strategy is to parse the egate console line by line looking for the expected
    message sequence.
    """
    RRCMessagesSequence = ["message c1 : rrcReconfiguration :",
                           "criticalExtensions rrcReconfiguration :",
                           "bwp-Dedicated",
                           "configuredGrantConfig setup :",
                           "uci-OnPUSCH setup : semiStatic :",
                           "betaOffsetACK-Index1",
                           "betaOffsetACK-Index2",
                           "betaOffsetACK-Index3",
                           "betaOffsetCSI-Part1-Index1",
                           "betaOffsetCSI-Part1-Index2",
                           "betaOffsetCSI-Part2-Index1",
                           "betaOffsetCSI-Part2-Index2"]

    egate_log_file = open(egate_console_path, "rb")
    egate_logs = egate_log_file.readlines()
    egate_log_file.close()

    print(egate_console_path)

    message_index = 0
    for line in egate_logs:
        if (message_index < len(RRCMessagesSequence)):
            if ((RRCMessagesSequence[message_index]) in str(line)):
                print("Found " + RRCMessagesSequence[message_index])
                message_index += 1

    return message_index == len(RRCMessagesSequence)
