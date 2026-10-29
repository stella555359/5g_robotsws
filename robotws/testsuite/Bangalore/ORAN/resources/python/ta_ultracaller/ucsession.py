import requests


class ucsession(object):
    _instance = None

    def __init__(self):
        pass

    @classmethod
    def creation(cls, **options):
        if cls._instance is None:
            cls._urlsession = requests.Session()
            requests.packages.urllib3.disable_warnings()
        if options.get("option") == "POST":
            response = cls._urlsession.post(url=options.get("url"),
                                            headers=options.get("headers"),
                                            data=options.get("data"),
                                            verify=False)
        elif options.get("option") == "GET":
            response = cls._urlsession.get(url=options.get("url"),
                                           headers=options.get("headers"),
                                           verify=False)
        elif options.get("option") == "PUT":
            response = cls._urlsession.put(url=options.get("url"),
                                           headers=options.get("headers"),
                                           data=options.get("data"),
                                           verify=False)
        elif options.get("option") == "DELETE":
            response = cls._urlsession.delete(url=options.get("url"),
                                              headers=options.get("headers"),
                                              verify=False)
        cls._instance = cls.__new__(cls)
        return response
