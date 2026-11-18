
# Learning Journey 📚

An iOS app that helps users build a learning habit by setting goals, logging daily progress, and maintaining a learning streak.

## Features

- Set a learning topic and choose a goal duration: a week, month, or year.
- Update your learning goal and start fresh.
- Record daily learning with **Log as Learned**.
- Use **Freeze for a day** to preserve your streak without adding a learning day.
- View your current streak and the number of freezes used.
- Track learned and frozen days in the calendar.
- Receive reminders before your streak resets, with notification permission.
- Store goals and daily records locally using **SwiftData**.

## How Streaks Work

- Logging a learning day increases your streak count.
- Using a freeze preserves an existing streak without increasing its count.
- Your streak resets when **32 hours** have elapsed since your latest Log or Freeze.
- Opening the app alone does not renew this deadline.
- Skipping a calendar day does not break your streak if the gap between activities is **less than 32 hours**.
- After a reset, your next learning log starts a new streak.
- A new calendar day allows a new learning log.
- Duplicate learning logs are prevented within the current goal. Updating the goal allows a fresh log, even on the same day.

### Example

If you log your learning on Tuesday at 10 PM:

- Logging again on Thursday at 1 AM keeps your streak going because only 27 hours have passed.
- Without another Log or Freeze, your streak resets on Thursday at 6 AM, when 32 hours have elapsed.
- If Wednesday has no Learned or Frozen record, it remains a missing day when the goal is evaluated.

## Freeze Allowance

Each goal duration includes a limited number of freezes:

| Goal Duration | Available Freezes |
|---------------|-------------------|
| Week          | 2                 |
| Month         | 8                 |
| Year          | 96                |

A Freeze renews the 32-hour activity deadline. Using a Freeze before any learning logs does not create a learning streak.

## Goal Completion

- Resetting your streak does not end your goal. You can continue logging until the goal period ends.
- Goal periods follow calendar boundaries, with the creation date counted as the first day.
- At the end of the goal, it is marked as **Completed** if every calendar day has a Learned or Frozen record.
- If any calendar day is missing, the goal is marked as **Not Completed**.
- Keeping your streak alive across a skipped calendar day does not make that day count toward goal completion.

## Updating Your Goal

Updating your goal restarts its duration, streak, and freeze allowance.

Previous daily records remain visible in the calendar, but records before the updated start time do not count toward the current goal.

## Reminders

With notification permission enabled:

- A local reminder is scheduled for **24 hours after your latest Log or Freeze**, giving you eight hours before the streak resets.
- Each new activity replaces the previous reminder.
- Updating your goal cancels the previous reminder.
- Reminders are scheduled only when you have a positive streak and its reset deadline falls before the goal ends.

Notification permission is optional. Streak calculations work independently of notifications.

## Built With

- **Swift** — Application logic.
- **SwiftUI** — User interface.
- **SwiftData** — Local data persistence.
- **UserNotifications** — Local reminders.
- **Models, Views, and ViewModels** — Separation of data, interface, and application logic.

## Project Structure

- `Models`: Learning goals, daily records, day statuses, and goal durations.
- `Views`: Onboarding, goal forms, daily activity, calendar, goal results, and goal editing screens.
- `ViewModels`: Goal management, streak calculations, freeze logic, calendar data, and notification scheduling.

## Getting Started

1. Open the project in Xcode.
2. Select an iPhone or simulator compatible with the project's deployment settings.
3. Configure signing if running on a physical iPhone.
4. Build and run the app.
5. Choose your learning topic and goal duration.
6. Allow notifications if you want streak reminders.

## Usage

1. Create a goal for something you want to learn.
2. Choose your goal duration.
3. Tap **Log as Learned** after completing your learning for the day.
4. Use **Freeze for a day** when needed, within your available allowance.
5. Review your progress on the activity screen and calendar.
6. At the end of the goal, review your result and set your next goal.
