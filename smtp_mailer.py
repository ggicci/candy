#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import smtplib
from argparse import ArgumentParser
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication


class SMTPMailer(object):
    """Email is a simple smtp email wrapper."""

    def __init__(self,
                 username,
                 password,
                 host='smtp.alibaba-inc.com',
                 port=465):
        self.host = host
        self.port = port
        self.username = username
        self.password = password

        self.sender = ''
        self.recipients = []
        self.cc = []
        self.subject = ''
        self.body = ''
        self.attachments = []

    @classmethod
    def build_from_json(cls, rawjs):
        """build_from_json builds an SMTPMailer from a JSON representation string.
        smaple:
        {
            "smtp": {
                "host": "smtp.alibaba-inc.com",
                "port": 465,
                "username": "mingjie.tmj@alibaba-inc.com",
                "password": "******"
            },
            "from": "mingjie.tmj@alibaba-inc.com",
            "to": [ "mingjie.tmj@alibaba-inc.com" ],
            "cc": [],
            "subject": "This is really wonderful",
            "body": "Body Game",
            "attachments": [ "./smtp_mailer.py" ]
        }
        """
        o = cls('', '')
        js = json.loads(rawjs)
        o.host = js['smtp'].get('host', 'smtp.alibaba-inc.com')
        o.port = js['smtp'].get('port', 465)
        o.username = js['smtp']['username']
        o.password = js['smtp']['password']

        o.sender = js['from']
        o.recipients = js['to']
        o.cc = js['cc']
        o.subject = js['subject']
        o.body = js['body']
        o.attachments = js['attachments']

        return o

    def send(self):
        """send sends mail to recipients."""
        outer = MIMEMultipart()
        outer.set_charset('utf-8')
        outer['From'] = self.sender
        outer['To'] = ', '.join(self.recipients)
        outer['CC'] = ', '.join(self.cc)
        outer['Subject'] = Header(self.subject, 'utf-8')

        # attach plain text body
        text_body = MIMEText(self.body, 'plain', _charset='utf-8')
        outer.attach(text_body)

        # attach the files
        for filename in self.attachments:
            if not os.path.isfile(filename):
                raise Exception('attachment "%s" is not a file' % (filename))

            base_filename = os.path.basename(filename)
            fp = open(filename, 'rb')
            attachment = MIMEApplication(fp.read(), Name=base_filename)
            fp.close()
            attachment.add_header(
                'Content-Disposition', 'attachment', filename=base_filename)
            outer.attach(attachment)

        s = smtplib.SMTP_SSL(host=self.host, port=self.port)
        s.login(self.username, self.password)
        s.sendmail(self.sender, self.recipients, outer.as_string())
        s.quit()

    def to_json(self):
        """to_json returns a JSON representation string of this SMTPMailer object."""
        return json.dumps(self.__dict__, indent=4)


def parse_args():
    parser = ArgumentParser(add_help=False)
    parser.add_argument('--json', help='json representation of the SMTP mail')
    args, remaining_argv = parser.parse_known_args()

    if args.json:
        return args

    parent = parser
    parser = ArgumentParser(
        parents=[parent],
        description='Send plain text mail through SMTP protocol.')
    parser.add_argument(
        '-H',
        '--host',
        type=str,
        default='smtp.alibaba-inc.com',
        help='SMTP host')
    parser.add_argument(
        '-P', '--port', type=int, default=465, help='SMTP port')
    parser.add_argument(
        '-u', '--user', type=str, required=True, help='SMTP username')
    parser.add_argument(
        '-p', '--pass', type=str, required=True, help='SMTP password')

    parser.add_argument(
        '-f', '--from', type=str, required=True, help='mail FROM')
    parser.add_argument('-t', '--to', nargs='+', help='mail TO (list)')
    parser.add_argument('-c', '--cc', nargs='*', help='mail CC (list)')
    parser.add_argument(
        '-s', '--subject', type=str, required=True, help='mail SUBJECT')
    parser.add_argument(
        '-b', '--body', type=str, required=True, help='mail BODY')
    parser.add_argument(
        '-a', '--attachment', nargs='*', help='mail ATTACHMENTS (list)')
    return parser.parse_args(remaining_argv)


def main():
    opts = parse_args()

    if opts.json is not None:
        SMTPMailer.build_from_json(opts.json).send()
    else:
        m = SMTPMailer(opts.user, getattr(opts, 'pass'), opts.host, opts.port)
        m.sender = getattr(opts, 'from')
        m.recipients = opts.to
        if opts.cc is not None:
            m.cc = opts.cc
        m.subject = opts.subject
        m.body = opts.body
        if opts.attachment is not None:
            m.attachments = opts.attachment
        m.send()


if __name__ == '__main__':
    main()
