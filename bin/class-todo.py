#!/usr/bin/env python3

# Create a project for each class meeting in Things.
# Modify the tasks for each class meeting as appropriate.
# Things URL documentation: https://support.culturedcode.com/customer/en/portal/articles/2803573

import webbrowser
import datetime
import dateutil.parser as dp
import json
import urllib.parse

teaching_area = "D52A2EC8-D9E6-4BC0-8066-D5CDDEFFEE89"  # UUID for todo area
class_title = "DH Practicum"
meeting_dates = [
    "2020-08-25",
    "2020-09-01",
    "2020-09-08",
    "2020-09-15",
    "2020-09-22",
    "2020-09-29",
    "2020-10-06",
    "2020-10-13",
    "2020-10-20",
    "2020-10-27",
    "2020-11-03",
    "2020-11-17",
    "2020-11-24",
    "2020-12-01",
    "2020-12-08",
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
                        "title": f"Do the readings for {class_title}",
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Create notes for {class_title} meeting",
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Review work from previous meeting of {class_title}",
                        "tags": ["teaching"],
                    },
                },
                {
                    "type": "to-do",
                    "attributes": {
                        "title": f"Look ahead for coordinating for {class_title}",
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

