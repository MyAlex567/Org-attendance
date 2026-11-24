# Org Attendance QR

A mobile app that replaces paper attendance sheets for student organizations. Officers scan each member's personal QR code, and attendance is saved instantly and shown live on every officer's phone.

## The Problem

Student organizations still record attendance at assemblies, seminars and meetings on paper sheets. This causes several problems:

- **Slow.** Passing sheets around a room takes time.
- **Extra work.** Officers have to type the records up afterward.
- **Easy to fake.** Signatures can be forged for absent friends.
- **No visibility.** Members have no easy way to see which events they attended.

## Our Solution

Org Attendance QR replaces the sheet with a scan.

- **Org join codes.** Each organization has its own join code, so only real members are included.
- **Personal QR codes.** Every member gets a personal QR code in the app.
- **Scan-based attendance.** Officers take attendance by scanning each member's QR code.
- **Fraud protection.** The app refuses non-members and double scans, so nobody can sign in for a friend.
- **Instant, live records.** Records are saved immediately and update in real time on every officer's phone.
- **Attendance history.** Every member can view their own attendance history in the app.

## How It Works

1. An organization is created and receives its own join code.
2. Members join the organization using that code.
3. For each assembly, seminar or meeting, an officer opens the event and starts scanning.
4. The officer scans each member's QR code. The app checks that the person is a member of the org and has not already been scanned for that event.
5. The record is saved and appears right away on all officers' devices.
6. Members open the app to see the events they attended.

## Tech Stack

- [Flutter](https://flutter.dev/) (Dart)
- Firebase Authentication for sign-in
- Cloud Firestore for real-time data storage and syncing
- `provider` for state management
- `qr_flutter` to generate member QR codes
- `mobile_scanner` to scan QR codes with the camera
- `intl` for date and time formatting

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.13.0)
- A Firebase project with Authentication and Cloud Firestore enabled
- An Android device or emulator (a physical device is recommended for testing the camera scanner)

### Run the app

```bash
git clone https://github.com/MyAlex567/Org-attendance.git
cd Org-attendance
flutter pub get
flutter run
```

Connect the app to your own Firebase project before running (for example with the FlutterFire CLI: `flutterfire configure`).

## Contributors

Built by the Org Attendance QR team.
