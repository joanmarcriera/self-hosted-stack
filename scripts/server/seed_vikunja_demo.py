#!/usr/bin/env python3

from __future__ import annotations

import sqlite3
import sys
from datetime import datetime, timedelta, timezone


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat(sep=" ")


def due(days: int) -> str:
    return (datetime.now(timezone.utc) + timedelta(days=days)).replace(microsecond=0).isoformat(sep=" ")


def ensure_project(
    con: sqlite3.Connection,
    *,
    title: str,
    description: str,
    owner_id: int,
    identifier: str,
    hex_color: str,
) -> tuple[int, str]:
    row = con.execute(
        "select id from projects where title = ? order by id limit 1",
        (title,),
    ).fetchone()
    now = utc_now()
    if row:
        con.execute(
            """
            update projects
               set description = ?, identifier = ?, hex_color = ?, updated = ?, owner_id = ?, is_archived = 0
             where id = ?
            """,
            (description, identifier, hex_color, now, owner_id, row[0]),
        )
        return row[0], "updated"

    cursor = con.execute(
        """
        insert into projects (title, description, identifier, hex_color, owner_id, is_archived, created, updated)
        values (?, ?, ?, ?, ?, 0, ?, ?)
        """,
        (title, description, identifier, hex_color, owner_id, now, now),
    )
    return int(cursor.lastrowid), "created"


def ensure_user_project(
    con: sqlite3.Connection, *, user_id: int, project_id: int, permission: int
) -> None:
    row = con.execute(
        "select id from users_projects where user_id = ? and project_id = ?",
        (user_id, project_id),
    ).fetchone()
    now = utc_now()
    if row:
        con.execute(
            "update users_projects set permission = ?, updated = ? where id = ?",
            (permission, now, row[0]),
        )
        return
    con.execute(
        """
        insert into users_projects (user_id, project_id, permission, created, updated)
        values (?, ?, ?, ?, ?)
        """,
        (user_id, project_id, permission, now, now),
    )


def ensure_task(
    con: sqlite3.Connection,
    *,
    project_id: int,
    title: str,
    description: str,
    created_by_id: int,
    due_date: str,
    priority: int,
    index_value: int,
) -> tuple[int, str]:
    row = con.execute(
        "select id from tasks where project_id = ? and title = ? order by id limit 1",
        (project_id, title),
    ).fetchone()
    now = utc_now()
    if row:
        con.execute(
            """
            update tasks
               set description = ?, due_date = ?, priority = ?, updated = ?, done = 0, percent_done = 0, repeat_mode = 0
             where id = ?
            """,
            (description, due_date, priority, now, row[0]),
        )
        return row[0], "updated"

    cursor = con.execute(
        """
        insert into tasks (
            title, description, done, due_date, project_id, repeat_mode, priority, percent_done,
            "index", created, updated, created_by_id
        ) values (?, ?, 0, ?, ?, 0, ?, 0, ?, ?, ?, ?)
        """,
        (title, description, due_date, project_id, priority, index_value, now, now, created_by_id),
    )
    return int(cursor.lastrowid), "created"


def ensure_task_assignee(con: sqlite3.Connection, *, task_id: int, user_id: int) -> None:
    row = con.execute(
        "select id from task_assignees where task_id = ? and user_id = ?",
        (task_id, user_id),
    ).fetchone()
    if row:
        return
    con.execute(
        "insert into task_assignees (task_id, user_id, created) values (?, ?, ?)",
        (task_id, user_id, utc_now()),
    )


def ensure_task_comment(
    con: sqlite3.Connection, *, task_id: int, author_id: int, comment: str
) -> None:
    row = con.execute(
        "select id from task_comments where task_id = ? and comment = ?",
        (task_id, comment),
    ).fetchone()
    now = utc_now()
    if row:
        con.execute(
            "update task_comments set updated = ? where id = ?",
            (now, row[0]),
        )
        return
    con.execute(
        """
        insert into task_comments (comment, author_id, task_id, created, updated)
        values (?, ?, ?, ?, ?)
        """,
        (comment, author_id, task_id, now, now),
    )


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: seed_vikunja_demo.py <db-path> <base-domain>", file=sys.stderr)
        return 1

    db_path = sys.argv[1]
    base_domain = sys.argv[2]

    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    users = {
        row["username"]: row["id"]
        for row in con.execute("select id, username from users order by id")
    }

    founder_id = users.get("akadmin") or users.get("admin") or next(iter(users.values()), None)
    if founder_id is None:
        print("vikunja skipped:no local user yet")
        return 0

    alex_id = users.get("alex")
    marta_id = users.get("marta")

    projects = [
        {
            "title": "Acme Bakery - Delivery Sprint",
            "description": (
                "Seeded demo project for the consultancy walkthrough.\n"
                f"CRM: https://crm.{base_domain}\n"
                f"Docs: https://docs.{base_domain}\n"
                f"Status: https://status.{base_domain}/d/stack-overview/stack-overview"
            ),
            "identifier": "ACME",
            "hex_color": "#C8613C",
            "tasks": [
                {
                    "title": "Map current lead intake sources",
                    "description": "Alex documents the form, Gmail, and Telegram entry points before automating anything.",
                    "priority": 4,
                    "due_in_days": 2,
                    "assignee_id": alex_id,
                    "comment": "Joan Marc: validate assumptions against the CRM opportunity before implementation.",
                },
                {
                    "title": "Prepare kickoff checklist and client data request",
                    "description": "Marta prepares the shared onboarding packet and confirms who owns each client-side decision.",
                    "priority": 3,
                    "due_in_days": 3,
                    "assignee_id": marta_id,
                    "comment": "Keep the client packet aligned with the BookStack handover page.",
                },
                {
                    "title": "Draft weekly KPI summary workflow",
                    "description": "Use the seeded n8n examples as a base for the bakery KPI digest.",
                    "priority": 4,
                    "due_in_days": 5,
                    "assignee_id": alex_id,
                    "comment": "Keep the Grafana overview aligned with the live client-facing service checks.",
                },
                {
                    "title": "Review scope, pricing, and handover expectations",
                    "description": "Founder review before moving the opportunity from proposal to delivery.",
                    "priority": 5,
                    "due_in_days": 6,
                    "assignee_id": founder_id,
                    "comment": "Tie the final scope back to EspoCRM and the BookStack discovery brief.",
                },
            ],
        },
        {
            "title": "Internal SME Demo Stack",
            "description": "Internal operating tasks that make the demo stack look like a reusable client delivery pattern.",
            "identifier": "DEMO",
            "hex_color": "#28536B",
            "tasks": [
                {
                    "title": "Review status dashboard coverage",
                    "description": "Keep service checks ready for client visibility while preserving the private database and SSH probes.",
                    "priority": 3,
                    "due_in_days": 1,
                    "assignee_id": founder_id,
                    "comment": "Done when the Grafana overview shows the managed app surfaces with live probe data.",
                },
                {
                    "title": "Refresh example docs and screenshots",
                    "description": "Marta checks that the BookStack demo pages match the CRM and task examples.",
                    "priority": 2,
                    "due_in_days": 4,
                    "assignee_id": marta_id,
                    "comment": "Use the demo consultancy blueprint as the narrative baseline.",
                },
                {
                    "title": "Validate restore drill and monitoring coverage",
                    "description": "Alex confirms the rebuild docs still match the live stack and that the Grafana monitoring layer is reproducible.",
                    "priority": 4,
                    "due_in_days": 7,
                    "assignee_id": alex_id,
                    "comment": "Any manual step left here should become a scripted repo action.",
                },
            ],
        },
    ]

    results = []

    with con:
        for project_spec in projects:
            project_id, project_action = ensure_project(
                con,
                title=project_spec["title"],
                description=project_spec["description"],
                owner_id=founder_id,
                identifier=project_spec["identifier"],
                hex_color=project_spec["hex_color"],
            )

            for user_id in (alex_id, marta_id):
                if user_id is not None:
                    ensure_user_project(con, user_id=user_id, project_id=project_id, permission=1)

            task_results = []
            for index_value, task_spec in enumerate(project_spec["tasks"], start=1):
                task_id, task_action = ensure_task(
                    con,
                    project_id=project_id,
                    title=task_spec["title"],
                    description=task_spec["description"],
                    created_by_id=founder_id,
                    due_date=due(task_spec["due_in_days"]),
                    priority=task_spec["priority"],
                    index_value=index_value,
                )
                if task_spec["assignee_id"] is not None:
                    ensure_task_assignee(con, task_id=task_id, user_id=task_spec["assignee_id"])
                ensure_task_comment(
                    con,
                    task_id=task_id,
                    author_id=founder_id,
                    comment=task_spec["comment"],
                )
                task_results.append(f"{task_spec['title']}:{task_action}")

            results.append(f"{project_spec['title']}:{project_action}:{'|'.join(task_results)}")

    print("vikunja " + ",".join(results))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
