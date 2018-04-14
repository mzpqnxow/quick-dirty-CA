#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
    Copyright 2018 copyright@mzpqnxow.com

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
       list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this
       list of conditions and the following disclaimer in the documentation and/or other
       materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be
       used to endorse or promote products derived from this software without specific
       prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
    TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
    BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


    What this snippet contains:

    - An OrederedDict YaML loader, for preserving order of YaML files
    - A nested/two-pass Jinja2 templating function working on any type of object

    Very useful in configuration files written in YaML that require re-use of values which
    is better solved using variables within the YaML. The `nested_template` function permits
    the following transformation, as an example:
"""
from __future__ import print_function, unicode_literals
import argparse
from collections import OrderedDict
from json import dumps as json_print, dumps as json_dumps
from os import mkdir
from os.path import (
    dirname,
    expanduser,
    expandvars,
    abspath,
    isfile,
    isdir,
    join as join_path,
    sep as DIRSEP)
from re import search as regex_search
from shutil import copyfile
from os import environ
from subprocess import check_call

from yaml import load as load_yaml_plain

from jinja2 import (
    Template,
    Environment,
    FileSystemLoader)

# Capture our current directory
CURDIR = dirname(abspath(__file__))

TEMPLATE_DIRPATH = 'templates'
YAML_DIRPATH = 'config'

DEFAULT_YAML_CONFIG_PATH = join_path(YAML_DIRPATH, 'configCA.yml')
DEFAULT_TEMPLATE_PATH = join_path(TEMPLATE_DIRPATH, 'opensslCA.cnf.j2')

def json_pretty(obj):
    """Print an object with standard types neatly"""
    print(json_print(obj, indent=2))



def file_write(src, dst, content=None, raise_exception=True, silent_error=False, create_path=False, fail_on_exist=False):
    """Return None on failure, raise exception on failure by default

       If `src` is None, touch the file `dst`
       If `src` is None and content is not None, seed it with the contents of `data`
    """
    if dst and (isfile(dst) or isdir(dst)):
        raise RuntimeError('file already exists, please manually clean out the CA directory !!')
    if create_path is True:
        mkdir_parents(dirname(dst))
    try:
        if src is None:
            with open(dst, 'w') as writefd:
                if content is not None:
                    writefd.write(content)
        else:
            copyfile(src, dst)
    except IOError as (err, msg):
        short_error, long_error = get_string_errno(err)
        if not silent_error or raise_exception is True:
            if src is None:
                print('{0}: {1} (unable to touch "{2}")'.format(short_error, long_error, dst))
            else:
                print('{0}: {1} (unable to copy "{2}" to "{3}")'.format(short_error, long_error, src, dst))
        if raise_exception is True:
            raise
        else:
            return None
    return dst



def mkdir_parents(dirname, fail_on_exist=False):
    """emulate mkdir -p behavior"""
    if fail_on_exist is True:
        if isdir(dirname) or isfile(dirname):
            raise RuntimeError('path already exists, please manually clean out the CA directory !!')
    path_stack = ''
    for element in dirname.split(DIRSEP):
        if not isdir(dirname):
            if not element:
                continue
            path_stack = join_path(DIRSEP, path_stack, element)
            if not isdir(path_stack):
                mkdir(path_stack)


def nested_template(data, template_vars):
    """data is an arbitrary data structure, template_vars is a dict

    The `data` object is traversed and each instance of a Jinja2 variable
    that is found in template_vars is replaced (templated)

    This is a recursive function with the end-case being when the object is
    a simple string or unicode string type
    """

    if isinstance(data, (str, unicode)):
        tmpl = Template(data)
        data = tmpl.render(template_vars)
        return expandvars(expanduser(data))
    elif isinstance(data, dict):
        for key, value in data.iteritems():
            data[key] = nested_template(value, template_vars)
        return data
    elif isinstance(data, list):
        # Not supporting sets and tuples since YaML doesn't support them
        tmp_list = []
        data.reverse()
        while data:
            item = data.pop()
            item = nested_template(item, template_vars)
            tmp_list.append(item)
        return tmp_list
    elif isinstance(data, (int, float)):
        return data
    raise RuntimeError('unexpected and unsupported type "{}" encountered'.format(
        type(data)))


def load_yaml_ordered(filename):
    """Load a YaML file as an OrderedDict

    Inspired by StackOverflow

    This function loads a YaML file, preserving order. It also
    detects duplicates of keys
    """
    with open(filename, 'r') as filefd:
        lines = filefd.read().splitlines()
        top_keys = []
        duped_keys = []
        for line in lines:
            match = regex_search(r'^([A-Za-z0-9_]+) *:', line)
            if match:
                if match.group(1) in top_keys:
                    duped_keys.append(match.group(1))
                else:
                    top_keys.append(match.group(1))
        if duped_keys:
            raise RuntimeError('ERROR: duplicate keys: {}'.format(duped_keys))
    with open(filename, 'r') as filefd:
        print(filefd)
        d_tmp = load_yaml_plain(filefd)
    return OrderedDict([(key, d_tmp[key]) for key in top_keys])


def touch(dst, file_on_exist=False):
    """Functionally equivalent to touch(1)"""
    if file_on_exist is True and (isfile(dst) or isdir(dst)):
        raise RuntimeError('path already exists, please manually clean out the CA directory !!')
    with open(dst, 'a'):
        pass


def build_ca_filesystem(params):
    """Build the filesystem layout for a new CA"""
    # ca_root = params['ca_fullpath_root']
    ca_serial = params['path_serial']
    ca_index = params['path_index']
    path_signed_certs = params['path_signed_certs']
    path_private = params['path_private']
    openssl_cnf_src = params['openssl_cnf_src']
    openssl_cnf_dst = params['openssl_cnf_dst']
    path_ca_pem = params['path_ca_cert']
    path_requests = params['path_requests']
    file_write(None, ca_serial, content='01\n', create_path=True, fail_on_exist=True)
    mkdir_parents(path_signed_certs, fail_on_exist=True)
    mkdir_parents(path_private, fail_on_exist=True)
    file_write(None, ca_index, fail_on_exist=True)
    print(openssl_cnf_src, openssl_cnf_dst)
    file_write(openssl_cnf_src, openssl_cnf_dst, fail_on_exist=True)
    mkdir_parents(path_requests)


    environ['OPENSSL_CONF'] = openssl_cnf_dst
    cmdline = ['/usr/bin/openssl', 'req', '-x509', '-newkey', 'rsa:4096', '-out', path_ca_pem, '-outform', 'PEM', '-days', '1825']
    check_call(cmdline)

#export OPENSSL_CONF=~/CA/ca_config.cnf
#openssl req -x509 -newkey rsa:4096 -out cacert.pem -outform PEM -days 1825



# CA_ROOT={{ ca_fullpath_root | replace("//", "/") }}
# [[ -d "$CA_ROOT/serial" ]] && (echo "CA already has a serial number file.. bailing out"; /bin/false) || echo "Creating new CA ..."
# cd ~/ && mkdir -p "$CA_ROOT/signedcerts" && mkdir -p "$CA_ROOT/private" && cd "$CA_ROOT"
# echo '01' > serial && touch index.txt
# mv ~/ca_config.cnf ~/CA/
# export OPENSSL_CONF=~/CA/ca_config.cnf
# openssl req -x509 -newkey rsa:4096 -out cacert.pem -outform PEM -days 1825


def main():
    parser = argparse.ArgumentParser(description='Certificate Authority openssl.cnf Generator')
    parser.add_argument(
        '-t', '--template',
        default=DEFAULT_TEMPLATE_PATH,
        help='Name of template in template/ directory',
        required=False,
        dest='template_filepath',
        metavar='<templates/opensslCA.cnf.j2')

    parser.add_argument(
        '-y', '--yaml-config',
        default=DEFAULT_YAML_CONFIG_PATH,
        help='Name of YaML configuration file in config/ directory',
        required=False,
        dest='yaml_filepath',
        metavar='<etc/configCA.yml>')

    args = parser.parse_args()
    data = load_yaml_ordered(args.yaml_filepath)
    data['CURDIR'] = CURDIR
    template_input_vars = data
    resolved = nested_template(data, template_input_vars)
    j2_env = Environment(loader=FileSystemLoader(CURDIR), trim_blocks=True)
    openssl_cnf_content = j2_env.get_template(args.template_filepath).render(resolved)
    print(json_dumps(resolved, indent=2))
    ca_short_name = resolved['ca_short_name']
    ca_base_name = resolved['ca_basename']
    out_openssl_cnf_filename = 'opensslCA-{0}.cnf'.format(ca_base_name)
    openssl_cnf = resolved['openssl_cnf']
    with open(join_path('output', openssl_cnf),  'w') as opensslfd:
        opensslfd.write(openssl_cnf_content)

    build_ca_filesystem(resolved)


if __name__ == '__main__':
    main()
