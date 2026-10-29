import re


def create_event_dict(egateOutput: str = ""):
    requiredPattern = r"(\d)+\s+(\w+)\s+(Event[A,B]+\d)\s+((?:\w+\s\w+|\w+\s\w+\s\w+))\s+(\d+)\s+[ ^]"
    try:
        lines = egateOutput.split("\n")
        count = 0
        Events = []
        for line in lines:
            event = re.search(requiredPattern, line)
            if event is not None:
                temp = (event.group(1), event.group(3))
                Events.append(temp)
                count = count + 1
        eventDict = {}
        for tup in Events:
            eventDict[tup[1].lstrip("Event")] = tup[0]
    except Exception as e:
        print(f"Something went wrong. Please check if Evenlis populated correctly in egate console. error here is {e}")
    return eventDict


def get_Event_id(Event: str = "A1", egateOutput: str = "") -> int:
    """
    [Argument]
    Event : it is string type argument and the Value should either A1,A2,A3,or B1,B2,B3 etc as string.
    egateOutput : it is output of egate console string
    [Return]
    eventId : integer will be returned if Value is availble else it will return None
    [Usage]
    example
    getEventid("A3")
    """
    eventId = None
    events = create_event_dict(egateOutput)
    try:
        eventId = events[Event]
    except KeyError as k:
        print(f"Event Not Found Please check {k} ")
    except Exception as e:
        print(f"something went wrong {e}")
    return eventId
