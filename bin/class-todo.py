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
class_title = "Computational History"
meeting_dates = [
        "2020-02-03",
        "2020-02-10",
        "2020-02-17",
        "2020-02-24",
        "2020-03-02",
        "2020-03-16",
        "2020-03-23",
        "2020-03-30",
        "2020-04-06",
        "2020-04-13",
        "2020-04-20",
        "2020-04-27",
        "2020-05-04"
]
meeting_dates.reverse()  # Make them appear in Things in the correct order


def create_meeting(class_date):
    class_date = datetime.date.fromisoformat(class_date)
    deadline = class_date
    earlier = class_date
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
                        "title": f"Do the {class_title} readings for next meeting",
                        "when": earlier.isoformat(),
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Prepare the worksheet or assignment for following week",
                        "when": earlier.isoformat(),
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Finish grading previous week assignment",
                        "when": earlier.isoformat(),
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Prepare class notes and demos",
                        "when": earlier.isoformat(),
                        "tags": ["teaching"],
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

