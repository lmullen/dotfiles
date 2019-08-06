#!/usr/bin/env python3

# Create a project for each class meeting in Things.
# Modify the tasks for each class meeting as appropriate.
# Things URL documentation: https://support.culturedcode.com/customer/en/portal/articles/2803573

import webbrowser
import datetime
import dateutil.parser as dp
import json
import urllib.parse

teaching_area = "D1CEB2B2-34AA-480A-BE7B-F55F0DE9C79A"  # UUID for teaching area
class_title = "Black DH"
meeting_dates = [
    "2019-09-04",
    "2019-09-11",
    "2019-09-18",
    "2019-10-09",
    "2019-10-16",
    "2019-10-23",
]
meeting_dates.reverse()  # Make them appear in Things in the correct order


def create_meeting(class_date):
    class_date = datetime.date.fromisoformat(class_date)
    deadline = class_date - datetime.timedelta(days=1)
    earlier = class_date - datetime.timedelta(days=6)
    project = {
        "type": "project",
        "attributes": {
            "title": f"Prep for {class_title} on {class_date.strftime('%a, %b %-d')}",
            "deadline": deadline.isoformat(),
            "area-id": teaching_area,
            "items": [
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Check availability of {class_title} readings for next meeting",
                        "when": earlier.isoformat(),
                        "tags": ["low energy work"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Read the texts for {class_title} before next meeting",
                        "when": deadline.isoformat(),
                        "tags": ["reading"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Read student precis for {class_title} and prepare points for discussion",
                        "when": deadline.isoformat(),
                    },
                },
            ],
        },
    }

    payload = urllib.parse.quote(json.dumps(project, separators=(",", ":")))
    url = f"things:///json?data=[{payload}]"
    webbrowser.open(url)


for meeting in meeting_dates:
    create_meeting(meeting)
