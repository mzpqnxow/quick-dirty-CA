## WARNING

You shouldn't be using this unless you have carefully reviewed the `openssl.cnf.yml` file and are an very proficient in OpenSSL and its CA functionality. It does not make use of traditional best practices (see the *Caveat* section) and by default it intentionally leaves keys unencrypted; the use-case is a very narrow one, where a user controlling the CA also controls the components where the various certificates will be placed. This is anathema to those involved in the more traditional CSR -> Authority model, but it is for a different use-case, poorly explained below.

## First things first

Create the virtual environment by running `make && source venv/bin/activate`

This will give you a virtual environment with Jinja2 and PyYAML installed as these are both required dependencies

## Why this tool was created

This tool was created for development use. A need arose where I needed to issue certificates used for mutually authenticated TLS. Because these were not standard "server" certificates, it made no sense to use a public CA, nor did it make sense to use a general purpose CA. It made more sense to create a very limited, dedicated CA, something very close to certificate pinning, but slightly short of that since I didn't control the applications that were enforcing the TLS authentication and they did not all support anything other than verifying the CA was the one that signed the cert- that is, there were no DN checks, etc.. As a quick example, let's say you have 500 systems and you need them to send system logs to a TLS enabled logstash endpoint. You don't want random garbage to be sent into this endpoint and you would prefer to reduce attack surface overall from any stranger able to hit the endpoint. You could use this tool to generate a CA called "Log Infrastructure Root CA" and generate a "Log Client" and "Logstash Server" keypair set. All in one or two commands, with no real hassle. If you need to add another certificate later, the CA will still be present on your disk and you can just copy the initial YaML file, modify it to your needs, and issue another one. The tool becomes more useful when you have 3-4 different scenarios like this and don't want to use the same CA for all of them. There's overhead involved in creating a CA and when a CA will only ever issue 3-4 certificates, this is a good way to do it quickly in a maintainable fashion.

## Caveat

This is not your traditional "Party A generates CSR, sends to Trusted Authority B who signs it and returns it" type of issuance model. There is only one player in this game, the trusted authority. This authority hands out pre-signed and generated certificates and keys. It is instructed to generated signed certififcates along with their keys, all in one shot. It is for infrastructural use, not for use by a traditional CA. Think of this as more closely related to certificate pinning than to a true CA a la the PKI model.

## Yet again

Development use. Not production. If you don't know what you are doing, maybe you shouldn't be using this. If you haven't read the code and the configuration files, you definitely shouldn't be using this. If you're securing real, physical infrastructure or producing an organization-wide CA, you shouldn't be using this. Just saying..

## How to Use

The tool makes heavy use of YaML and Jinja2 to create a CA and to create openssl.cnf files for creating and signing certificates. This means you will need to edit some YaML files. Luckily, there are already samples included. You can look around at them if you're curious about how things work, or what parameters are being used with the CA and other certificate/key generation commands

### Quick Usage

Assume you choose to name your CA directory "MyCA"

1. Copy a file from `./examples/create-ca/` and name it `myca.yml`
2. Modify `myca.yml` with values specific to your CA (i.e. your company, business unit, etc.) and remember that the `ca_short_name` for this example should be `MyCA`
3. Use `./create-ca -y myca.yml`, leaving out the optional template argument since the default CA parameters provided are pretty sane (as far as I know, you should double check the openssl.cnf.j2 file before using)
4. Change directory to `~/CA/MyCA/`, this is the root directory of your new CA
5. Copy an example from `./example_requests/` and specify the path to that new file using `-i` when using `bin/issue-cert`
6. Check under `./requested/` and you will find various forms of your issued certififcate, including the private key which was generated dynamically

The CA certificate can be found in `~/CA/MyCA/requested/`, spotted most easily using `ls -lrt`

### Issuing certs down the line ...

Remember that you need to enter the `quick-dirty-ca` virtualenv each time you want to issue a new certificate from the CA. Either that or you need to install the required libraries system-wide by hand (not recommended)

### Final notes

I am aware there are many, many, many, many, many CA automation applications, scripts and frameworks in the open-source world. However I had a hard time fitting the exact requirements I had- extremely simple and allowing for easy addition of subject alternative names. I would be really happy to hear about what could replace this as I admit the code is a mess and the overall design is poor by my usual standards. Please create an issue with a link to a similar (but better) tool if you have the time! This was only a day's worth of work for me so I won't hesitate to drop it and use someone else's more well thought out tool instead!

### License / Copyright

Copyright copyright@mzpqnxow.com, 3-clause BSD License. See LICENSE or LICENSE.md
