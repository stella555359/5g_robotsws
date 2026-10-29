class Tokens:

    def __init__(self):
        self._token = None

    @property
    def authorization_bearer_token(self):
        """
        Retrieves the authorization bearer token for accessing the remote repository.
        The token is read from a file on the VM and cached for future use.
        :rtype: dict
        """
        if self._token is None:
            self._token = {"Authorization": f"Bearer {self.ute_ca_artifactory_token}"}
        return self._token

    @property
    def ute_ca_artifactory_token(self):
        """
        Retrieves the UTE Artifactory token from the saved file on the VM.
        :return: UTE Artifactory token
        :rtype: str
        """
        try:
            with open("/etc/token/ca_ute_artifactory_readonly") as cert_file:
                return cert_file.read().strip()
        except FileNotFoundError:
            raise FileNotFoundError(
                "CA UTE Artifactory token file not found. "
                "Please ensure the file exists at /etc/token/ca_ute_artifactory_readonly "
                "and contains the correct token.")

    def get_ca_ute_artifactory_token(self):
        """
        Retrieves the CA UTE Artifactory token.
        :return: Authorization token without formatting.
        :rtype: str
        """
        return self.ute_ca_artifactory_token
