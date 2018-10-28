## Example Certificate Issuance Configurations (used with `issue-cert` after the CA has been constructed)

These files are examples of configuration files used to request issuance of a signed certificate. The first pair demonstrate "traditional" certificates where the Common Name is a hostname or IP address, and the subjectAltName values contain the same. The second pair demonstrate a non-traditional use of certificates, essentially generating a certificate and key for a fleet, and then issuing a certificate and key for the server(s). As always, the CA certificate should be issued to both parties for mutual authentication

* hostname01-request.yml - A simple certificate with subjectAltNames for a WWW server named hostname01
* hostname02-request.yml - A simple certificate with subjectAltNames for an FTP server named hostname02
* logcollect-client.yml - All client systems in a mobile fleet
* logcollect-server.yml - Logserver

Copy one of these and modify to suit your needs, then use `issue-cert`
