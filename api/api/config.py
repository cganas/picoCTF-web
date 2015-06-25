"""
CTF API Configuration File

Note this is just a python script. It does config things.
"""

import api
import datetime

import api.app

""" FLASK """

api.app.session_cookie_domain = "127.0.0.1"
api.app.session_cookie_path = "/"
api.app.session_cookie_name = "flask"

# KEEP THIS SECRET
api.app.secret_key = "5XVbne3AjPH35eEH8yQI"

""" SECURITY """

api.common.allowed_protocols = ["https", "http"]
api.common.allowed_ports = [8080]

""" MONGO """

api.common.mongo_db_name = "pico"
api.common.mongo_addr = "127.0.0.1"
api.common.mongo_port = 27017

""" TESTING """

testing_mongo_db_name = "ctf_test"
testing_mongo_addr = "127.0.0.1"
testing_mongo_port = 27017

""" CTF SETTINGS """

enable_teachers = True
enable_feedback = True

competition_name = "picoCTF"
competition_urls = ["127.0.0.1:8080"]

# Teams to display on scoreboard graph
api.stats.top_teams = 5

# start and end times!
class EST(datetime.tzinfo):
    def __init__(self, utc_offset):
        self.utc_offset = utc_offset

    def utcoffset(self, dt):
      return datetime.timedelta(hours=-self.utc_offset)

    def dst(self, dt):
        return datetime.timedelta(0)

start_time = datetime.datetime(2000, 10, 27, 12, 13, 0, tzinfo=EST(4))
end_time = datetime.datetime(2055, 11, 7, 23, 59, 59, tzinfo=EST(5))

""" ACHIEVEMENTS """

enable_achievements = True

api.achievement.processor_base_path = "./achievements"

""" SHELL SERVER """

enable_shell = False

shell_host = "127.0.0.1"
shell_username = "vagrant"
shell_password = "vagrant"
shell_port = 22

shell_user_prefixes  = list("abcdefghijklmnopqrstuvwxyz")
shell_password_length = 4
shell_free_acounts = 10
shell_max_accounts = 9999

shell_user_creation = "sudo useradd -m {username} -p {password}"

""" EMAIL (SMTP) """

api.utilities.enable_email = False
api.utilities.smtp_url = ""
api.utilities.email_username = ""
api.utilities.email_password = ""
api.utilities.from_addr = ""
api.utilities.from_name = ""

""" CAPTCHA """
enable_captcha = False
captcha_url = "http://www.google.com/recaptcha/api/verify"
reCAPTCHA_private_key = ""


""" LOGGING """

# Will be emailed any severe internal exceptions!
# Requires email block to be setup.
api.logger.admin_emails = ["ben@example.com", "joe@example.com"]
api.logger.critical_error_timeout = 600
