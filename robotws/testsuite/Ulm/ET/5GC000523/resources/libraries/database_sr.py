class SchedulingRequest_sorted_rnti:
    def __init__(self, new_attrib, event):
        self.attrib = []
        self.add_attrib(new_attrib)
        self.events = {}
        self.process_attrib(event, new_attrib)

    def add_attrib(self, new_attrib):
        self.attrib.append(new_attrib)

    def process_attrib(self, event, new_attrib):
        if event not in self.events:
            self.events[event] = [new_attrib]
        elif event in self.events:
            self.events[event].append(new_attrib)
