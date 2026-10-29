"""
:copyright: Nokia Networks
:author: Konrad Bem <konrad.bem@nokia.com>
:maintainer: Konrad Bem <konrad.bem@nokia.com>
:Description: Based on input generates query to use with keyword "Verify That Message Fulfills Query"
:Description: Input format: field names separated with . and evaluate value or presence
:Example 1: Input "relaxedMeasurement-r16.lowMobilityEvaluation-r16.s-SearchDeltaP-r16 is set to 'dB9'"
:Example 1: Output "sib2 contains (relaxedMeasurement-r16 contains (lowMobilityEvaluation-r16 contains
:Example 1: (s-SearchDeltaP-r16 eq 'dB9')))
:Example 2: Input "relaxedMeasurement-r16.highPriorityMeasRelax-r16 is not present"
:Example 2: Output "sib2 contains (relaxedMeasurement-r16 contains (highPriorityMeasRelax-r16 is not present))
"""


def make_sib2_query(query_input):
    query_input = query_input.replace("is set to", "eq")
    elements = query_input.split(".")
    query_output = "sib2 contains (" + " contains (".join(elements) + ")" * len(elements)
    return query_output
