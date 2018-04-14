## WARNING

You shouldn't be using this. It does not make use of best practices, it intentionally leaves keys unencrypted, and the use-case is a very narrow one, where a user controlling the CA needs to generate signed certificates for short-term or development use. That said, if this can be useful for you, go for it.

## First things first

Create the virtual environment by running `make && source venv/bin/activate`

This will give you a virtual environment with Jinja2 and PyYAML installed as these are both required dependencies

## Why this tool was created

This tool was created for development use. A need arose where I needed to issue certificates used for mutually authenticated TLS. Because these were not standard "server" certificates, it made no sense to use a public CA, nor did it make sense to use a general purpose CA. It made more sense to create a very limited, dedicated CA. As a quick example, let's say you have 500 systems and you need them to send system logs to a TLS enabled logstash endpoint. You don't want random garbage to be sent into this endpoint and you would prefer to reduce attack surface overall from any stranger able to hit the endpoint. You could use this tool to generate a CA called "Log Infrastructure Root CA" and generate a "Log Client" and "Logstash Server" keypair set. All in one or two commands, with no real hassle. If you need to add another certificate later, the CA will still be present on your disk and you can just copy the initial YaML file, modify it to your needs, and issue another one. The tool becomes more useful when you have 3-4 different scenarios like this and don't want to use the same CA for all of them. There's overhead involved in creating a CA and when a CA will only ever issue 3-4 certificates, this is a good way to do it quickly in a maintainable fashion.

## How to Use

The tool makes heavy use of YaML and Jinja2 to create a CA and to create openssl.cnf files for creating and signing certificates. This means you will need to edit some YaML files. Luckily, there are already samples included. You can look around at them if you're curious about how things work, or what parameters are being used with the CA and other certificate/key generation commands

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
...
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'hostname.private'
stateOrProvinceName   :ASN.1 12:'NJ'
localityName          :ASN.1 12:'Hoboken'
countryName           :PRINTABLE:'US'
emailAddress          :IA5STRING:'root@domain.com'
organizationName      :ASN.1 12:'WidgetsInc'
organizationalUnitName:ASN.1 12:'Round Widgets Division'
Certificate is to be certified until Apr 13 02:58:36 2023 GMT (1825 days)

Write out database with 1 new entries
Data Base Updated
Certificate and private key have been generated and signed by CA !!
  Key:         /home/debian/CA/widgetsInc/requested/request.2018-04-13.1523674715/server.key
  Certificate: /home/debian/CA/widgetsInc/requested/request.2018-04-13.1523674715/server.crt
  Combined:    /home/debian/CA/widgetsInc/requested/request.2018-04-13.1523674715/server.pem
$ ls -l requested/
```
You will notice that the openssl.cnf file generated by the template and your YaML file is also preserved alongside the key and certificate files, in case you want to use it later or manually inspect it

### Distributing / using the CA certificate

The CA certificate is located in the root of the CA named `cacert.pem` and is hard to miss

### Final notes

I am aware there are many, many, many, many, many CA automation applications, scripts and frameworks in the open-source world. However I had a hard time fitting the exact requirements I had- extremely simple and allowing for easy addition of subject alternative names. I would be really happy to hear about what could replace this as I admit the code is a mess and the overall design is poor by my usual standards. Please create an issue with a link to a similar (but better) tool if you have the time! This was only a day's worth of work for me so I won't hesitate to drop it and use someone else's more well thought out tool instead!

### License / Copyright

Copyright copyright@mzpqnxow.com, 3-clause BSD License. See LICENSE or LICENSE.md
