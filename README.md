## WARNING

You shouldn't be using this. It does not make use of best practices, it intentionally leaves keys unencrypted, and the use-case is a very narrow one, where a user controlling the CA needs to generate signed certificates for short-term or development use. That said, if this can be useful for you, go for it.

## How to Use

The tool makes heavy use of YaML and Jinja2 to create a CA and to create openssl.cnf files for creating and signing certificates. This means you will need to edit some YaML files. Luckily, there are already samples included

### Step 1: Create a CA

Copy the file in conf/ca.yml.j2 to conf/my-test-ca.yml.j2. Edit this file to suit your needs, updating the fields that are common to certificates like the distinguished name values and such. Once complete, you can use create-ca

```
(venv) debian@debian:~/quick-dirty-CA$ ./create-ca -h
usage: create-ca [-h] [-t <templates/openssl.cnf.j2] [-y <etc/config.yml>]

Certificate Authority Generator

optional arguments:
  -h, --help            show this help message and exit
  -t <templates/openssl.cnf.j2, --template <templates/openssl.cnf.j2
                        Name of template in template/ directory
  -y <etc/config.yml>, --yaml-config <etc/config.yml>
                        Name of YaML configuration file in config/ directory
```

By default, `create-ca` will use the sample files. This isn't what you want. You want to specify both parameters here. Try this:

```
$ ./create-ca -t templates/openssl.cnf.j2 -y conf/my-test-ca.yml.j2
```

After running this, you will find your CA in ~/CA/<somename> depending on how you modified the `my-test-ca.yml.j2` file. From this point forward, you can operate out of that directory until you have a need to create another CA in a different location

### Step 2: Issue a certificate and have it signed by the CA

First you should switch into the new CA directory. Modify the examples_request.yml file. This file is very intuitive. It is also very restrictive. It only allows you to set basic distinguished name parameters and subject alternative name values, both DNS and IP based. Make changes to this file and once you are done, you can use `bin/issue-cert`

```
$ bin/issue-cert -i examples_request.yml
$ ls -l requested/
```

You will see (in a not yet neatly postprocessed form) the output of the process. You now have a signed certificate and a private key associated with it.

### Distributing / using the CA certificate

The CA certificate is located in the root of the CA named `cacert.pem` and is hard to miss
