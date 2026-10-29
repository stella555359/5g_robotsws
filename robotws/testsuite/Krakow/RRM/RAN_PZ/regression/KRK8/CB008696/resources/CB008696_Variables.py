from testsuite.Krakow.RRM.RAN_PZ.resources.emil_verification.emil_verifier import AwaitedMessage

freq_priority_expected_04a = {700: '6.8', 66984: '7', 2300: '4.6', 68886: '1.6', 8750: '0.6', 68861: '0.6',
                              68811: '0.6',
                              5035: '0.6', 501390: '6.6', 521310: '6.6', 392910: '6.2', 124350: '2.6', 397970: '0.2'}

freq_priority_expected_04b = {700: '7', 66984: '6.8', 2300: '4.6', 68886: '1.6', 8750: '0.6', 68861: '0.6',
                              68811: '0.6',
                              5035: '0.6', 501390: '6.6', 521310: '6.6', 392910: '6.2', 124350: '2.6', 397970: '0.2'}

freq_priority_expected_06a = {68910: "4.6", 5035: "0.6", 521310: "7", 501390: "6"}

freq_priority_expected_06b = {68910: "4.6", 5035: "0.6", 521310: "5", 501390: "7"}

freq_priority_expected_10 = {66984: "6.8", 5035: "3.4", 700: "7", 125400: "6", 501390: "6.6"}

awaited_messages = [
    AwaitedMessage(name="ueCapabilityEnquiry", fields={
        "includeNR-DC": ['true']
    }),
    AwaitedMessage(name="ueCapabilityInformation", fields={
        "includeNR-DC": ['true']
    }),
    AwaitedMessage(name="ueCapabilityEnquiry", fields={
        "includeNR-DC": ['true']
    }),
    AwaitedMessage(name="ueCapabilityInformation", fields={
        "includeNR-DC": ['true']
    }),
    AwaitedMessage(name="rrcReconfiguration", fields={
        "eventA2": []
    }),
    AwaitedMessage(name="rrcReconfiguration", fields={
        "eventA2": []
    }),
    AwaitedMessage(name="rrcReconfiguration", fields={
        "eventA4": []
    })
]
