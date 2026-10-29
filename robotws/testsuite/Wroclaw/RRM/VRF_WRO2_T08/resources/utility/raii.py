class RAII:
    def __init__(self, resource_init, resource_args=None):
        self._resource = None
        self._resource_init = resource_init
        self._resource_args = resource_args if resource_args is not None else []

    def _initialize_resource_if_needed(self):
        if self._resource is None:
            self._resource = self._resource_init(*self._resource_args)

    def __getattr__(self, item):
        self._initialize_resource_if_needed()
        return getattr(self._resource, item)

    def __getitem__(self, item):
        self._initialize_resource_if_needed()
        return self._resource[item]

    def __call__(self, *args, **kwargs):
        self._initialize_resource_if_needed()
        return self._resource(*args, **kwargs)

    def __add__(self, other):
        self._initialize_resource_if_needed()
        return self._resource + other
