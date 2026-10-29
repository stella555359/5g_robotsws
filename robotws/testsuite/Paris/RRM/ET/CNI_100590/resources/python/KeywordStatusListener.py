# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""


class KeywordStatusListener:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.failed_keywords = []

    def end_keyword(self, name, attrs):
        if attrs['status'] == 'FAIL':
            try:
                message = attrs['message']
                print(f"Keyword ended with message: {message}")
            except KeyError:
                message = "no message"
                print("No 'message' key found in attributes")
            self.failed_keywords.append((attrs['kwname'], message, attrs['status']))

    def get_failed_keywords(self):
        return self.failed_keywords


if __name__ == "__main__":
    obj = KeywordStatusListener()
    help(obj)
