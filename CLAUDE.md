# CLAUDE.md: Org Attendance QR

Context for AI coding agents working in this repo. Read this before making changes.

## ⚠️ Most Important Rules — Always Follow These

1. **Never write or change code without my permission.** Before creating or editing ANY file (pages, widgets, providers, services, models, `pubspec.yaml`, files under `android/`), tell me:
   - what you want to do and why
   - which files you will create or change

   Then **wait for me to say "yes"**. Nothing else in this file counts as permission — not the planned screens, the progress checklist, or the current step.
2. **One small step at a time.** One change per step (one widget, one method, one part of a screen). Never build several things at once.
3. **Explain, then stop.** After each approved change:
   - tell me the file path and the class or method name, so I can open it
   - explain what the code does and why, walking through the important lines
   - tell me how it connects to other files (e.g., page → provider → service → Firestore)
   - then **stop** and wait until I say I understand and tell you to continue. Answer my questions first.
4. **Ask before new topics.** In CC 105 I've covered: Dart basics, stateless and stateful widgets, navigation, forms and validation, atomic design, Futures and Streams with APIs, local storage (SharedPreferences, sqflite), and Firebase Auth, Cloud Firestore and security rules. Ask me before using any concept outside that list, and briefly explain new concepts when you use them. Explain how Provider works the first time you use it.
5. **Always ask first before:** deleting files, adding/removing/upgrading packages, changing the Firestore data model or anything that needs a security-rules change, running `flutterfire configure`, editing files under `android/`, big refactors, any git command, or touching files outside this project folder.
6. **Only work on the files I name.** Read, create or edit only the files I tell you to work on for the current step. If you think another file needs to change, tell me which file and why, then wait for my "yes" before opening or changing it.
7. **Always ask permission before adding or deleting any file or package.**
   - Files: tell me the file name, where it will go (or where it is), and why it's needed. Wait for my "yes" before creating or deleting it.
   - Packages: tell me the package name, what it does, and why we need it instead of what we already have. Wait for my "yes" before running `flutter pub add` or `flutter pub remove`, or editing `pubspec.yaml`.

## What this app is

Org Attendance QR replaces paper attendance sheets at school org events.
Any user can create an org and becomes its admin. Others join with the org's join code (like a Google Classroom class code).
The admin picks members to become officers, and the member accepts in the app. Officers and the admin take attendance by scanning each member's QR code.
Every user has a QR code, a list of their orgs and a history of the events they attended.

- Course: CC 105 Final Project (group, up to 4 members)
- Platform: **Android only** (release build is an APK)
- Package ID: `com.cc105.org_attendance_qr`
- Firebase project: `org-attendance-qr` (Spark plan, Firestore in `asia-southeast1`)

### Accounts and roles

- **One account type for everyone.** Roles are per org, so one user can be an admin in one org and a member in another.
- The org creator is automatically its **admin**.
- Officers are picked from the **Members** list. The member gets an in-app invitation (no push notifications) and must **accept** it.
- Scanning the QR code of someone who isn't a member shows "Not a member of this org" and records nothing.

| Can do | Member | Officer | Admin |
| --- | --- | --- | --- |
| See the org and its events, show My QR, see own History | ✅ | ✅ | ✅ |
| Take attendance (create a session, scan QR codes) | | ✅ | ✅ |
| See members and attendance lists | | ✅ | ✅ |
| See and share the join code | | | ✅ |
| Make or remove officers | | | ✅ |

## Current Step

- Phase 2 is done and tested: theme, atoms, molecules, all models, `AuthService` / `AuthProvider` (login, register, logout, `uidChanges`, `loadUser`), `FirestoreService` (`createUser`, `getUser`), Login, Register, Auth Gate, `MainPage` with the bottom navigation, and Profile (Log out only).
- Phase 3 is done and tested: `joinCode` validator, `FirestoreService` (`createOrg`, `joinOrg`, `watchMemberships`, `watchOrg`), `OrgProvider`, Home (live list of my orgs), Add organization and Join organization dialogs (`OrgForm`, `JoinOrgForm`), and the Org Page (join code card for the admin; sessions list is a placeholder).
- Phase 4 is done and tested: `FirestoreService` (`watchMembers`, `inviteOfficer`, `watchInvites`, `respondToInvite`, `removeOfficer`, `removeMember`), `OrgProvider` methods, Members page (tap = make / remove officer, icon = remove member), Invitations page, real invite badge on Home.
- Phase 5 is done and tested: `AttendanceProvider`, `FirestoreService` (sessions, `recordAttendance`, attendance lists, counts, history), My QR, History, Take Attendance, Scan QR (with `_busy` flag, Mark me present, Close session), Attendance List, sessions on the Org Page.
- Next is Phase 6: testing (replace the default counter test), polish, release keystore and APK, documentation. Wait for my "yes" before each part.

## Tech stack

| Package | Version (major) | Used for |
| --- | --- | --- |
| firebase_core | 5.x | `Firebase.initializeApp` in `main.dart` |
| firebase_auth | 7.x | Email/password register, login, logout |
| cloud_firestore | 7.x | All app data, live streams |
| provider | 6.x | State management layer |
| qr_flutter | 4.x | `QrImageView` on the student's My QR screen |
| mobile_scanner | 7.x | `MobileScanner` widget on the Scan QR screen |
| intl | 0.20.x | Date and time formatting |

Use the current APIs for these major versions. Don't add, remove or upgrade packages without asking first.

## Commands

```bash
flutter pub get                 # install dependencies
flutter analyze                 # must pass with no errors before you finish a task
flutter test                    # run tests
flutter run                     # run on emulator or phone
flutter build apk --release     # release APK -> build/app/outputs/flutter-apk/
flutterfire configure           # only if Firebase platforms/products change
```

See **Setup & Gotchas** below for Windows and emulator notes.

## Architecture

**Rule #1: pages never talk to Firebase directly.**

```
pages  ->  providers  ->  services  ->  Firebase (Auth, Firestore)
```

- **Pages** (`lib/ui/pages/`) build UI and call provider methods. They never import `firebase_auth` or `cloud_firestore`.
- **Providers** (`lib/providers/`) hold app state and call services. Registered once in `main.dart` with `MultiProvider`.
  - `AuthProvider`: current user and profile, listens to `authStateChanges()`.
  - `OrgProvider`: my orgs, create org, join org by code, members, officer invites.
  - `AttendanceProvider`: sessions, scanning, attendance lists, my history.
- **Services** (`lib/services/`) are the only files that import Firebase packages.
  - `AuthService`: register, login, logout.
  - `FirestoreService`: every Firestore read and write.
- **Models** (`lib/models/`) are plain Dart classes with `fromMap` / `toMap`.

### Folder structure (atomic design)

```
lib/
  main.dart                 # Firebase.initializeApp, MultiProvider, runApp(OrgAttendanceApp)
  firebase_options.dart     # generated by flutterfire configure, never edit by hand
  app.dart                  # MaterialApp, theme, named routes
  models/                   # app_user.dart, org.dart, member.dart, membership.dart, invite.dart, event.dart, attendance.dart, attendance_history.dart, scan_result.dart
  services/                 # auth_service.dart, firestore_service.dart
  providers/                # auth_provider.dart, org_provider.dart, attendance_provider.dart
  theme/                    # app_theme.dart: AppColors (all app colors)
  utils/                    # validators.dart: shared form validators
  ui/
    atoms/                  # AppText, AppButton, AppChip, AppLoader
    molecules/              # AppTextField, LabeledField, StatusMessage, EventCard, AttendeeTile, AttendanceHistoryTile, OrgCard, JoinCodeCard, MemberTile, InviteCard, QrCard, ScanResultCard, AttendanceCountCard, SelfCheckInButton
    organisms/              # LoginForm, RegisterForm, EventForm, OrgForm, JoinOrgForm, ConfirmDialog, QrScanner
    templates/              # AuthTemplate (Login and Register layout)
    pages/                  # one file per screen; MainPage holds the bottom navigation
```

Put new widgets at the smallest level that fits. A page should mostly assemble organisms.

### Screens and routes

Bottom navigation for every user: **Home, My QR, History, Profile**.

| Screen | Route | Who | What it does |
| --- | --- | --- | --- |
| Auth Gate | `/` | Everyone | `StreamBuilder` on `authStateChanges()` → Login or Home |
| Login | `/login` | Everyone | Email and password |
| Register | `/register` | Everyone | Full name, student ID, email, password (one account type) |
| Home (My Orgs) | `/home` | Everyone | My orgs with my role; **Add organization** and **Join organization** buttons; Invitations badge |
| Add Organization | dialog on Home | Everyone | Org name → creates the org and makes me admin; the join code is shown on the Org Page |
| Join Organization | dialog on Home | Everyone | Enter a join code |
| Org Page | `/orgs/details` | Members | Org name, my role, sessions; **Take attendance** for officers and admin; join code and **Members** for admin |
| Members | `/orgs/members` | Admin | Member list; tap a member → **Make officer** / **Remove officer**; remove icon → **Remove member** (not the admin) |
| Invitations | `/invitations` | Everyone | Officer invites with **Accept** / **Decline** |
| Take Attendance | `/attendance/new` | Officer, Admin | Event name, venue, date and time → starts a session |
| Scan QR | `/attendance/scan` | Officer, Admin | Scan members' QR codes; checks membership; live count; **Mark me present** button for my own attendance; **Close** ends the session (`isOpen: false`) |
| Attendance List | `/attendance/list` | Officer, Admin | Who attended a session; self check-ins show a **Self check-in** label |
| My QR | `/my-qr` | Everyone | My QR code (contains my uid), name, student ID |
| History | `/history` | Everyone | Events I attended, newest first, with the org name |
| Profile | `/profile` | Everyone | Account details and log out (settings live here for now) |

The app has no named-route table. Pages open with `Navigator.push(MaterialPageRoute(...))`, and IDs (`orgId`, `eventId`) are passed as constructor arguments. The route column above is just a name for each screen.

## Design (follow docs/design/org_attendance_ui.png)

- Style: simple and clean, green and white. No gradients, no heavy shadows.
- Define all colors once in `lib/theme/app_theme.dart`. Never hard-code colors in widgets.

| Name | Color | Used for |
| --- | --- | --- |
| Green (primary) | `0xFF15803D` | App bars, buttons, active nav item, "New event" button |
| Dark green | `0xFF166534` | Small emphasis text ("128 attended") |
| Light green | `0xFFE8F5EC` | "Open" chip, success messages |
| Background | `0xFFF6FAF7` | Page background behind cards |
| White | `0xFFFFFFFF` | Cards, inputs, Login screen |
| Text | `0xFF1F2937` | Main text |
| Muted | `0xFF6B7280` | Secondary text (venue, date) |
| Border | `0xFFE5E7EB` | Card and input borders |

- Shapes: buttons and inputs radius 12, cards radius 16, the My QR card radius 22. Main buttons are full width and 50 tall.
- App bar: green background, white bold title, small subtitle under it (e.g., "Officer").
- Cards: white, 1px border, padding 16.
- Status chip: "Open" = light green with green text; "Closed" = gray.
- Bottom nav: white, active item green.
- Font: Flutter's default font, unless I approve the `google_fonts` package for Inter.

### Screens

The image shows an earlier version of the app (an officer "Events" screen). Follow its colors, shapes and style; **Screens and routes** above is the current screen list.

- Login and Register: white page, green logo square, app name, fields, green full-width button.
- Home (My Orgs): green app bar, white org cards (org name, role chip: Admin / Officer / Member), green **Add organization** and **Join organization** buttons, Invitations badge.
- Org Page: green header with the org name and my role; for the admin, a card with the join code and a Copy button; list of sessions; green **Take attendance** button for officers and admin.
- Scan QR: dark camera box with green corners, hint text, green-bordered success message ("Juan Dela Cruz recorded"), green count card. "Not a member" and "Already scanned" use the same card style in gray. Below the camera box, a green outlined **Mark me present** button; after one tap it becomes a light green "You're marked present" label.
- My QR: green header, white card with the QR code, name, student ID and a tip.
- History: white cards with event name, org name and time scanned.

## Firestore data model

```
users/{uid}
  fullName, studentId, email, createdAt

users/{uid}/memberships/{orgId}                  # copy for the Home list
  orgName, role: 'admin' | 'officer' | 'member', joinedAt

users/{uid}/invites/{orgId}                      # in-app officer invitations
  orgName, invitedBy (admin uid), createdAt

users/{uid}/attendance/{eventId}                 # copy for the History screen
  orgId, orgName, eventTitle, scannedAt

joinCodes/{code}                                 # code -> org; read one code at a time
  orgId, orgName

orgs/{orgId}
  name, joinCode, createdBy (uid), createdAt

orgs/{orgId}/members/{uid}                       # the real role lives here
  name, studentId, role: 'admin' | 'officer' | 'member', joinCode (when joined by code), joinedAt

orgs/{orgId}/events/{eventId}                    # one attendance session
  title, venue, startsAt, isOpen, createdBy (uid), createdAt

orgs/{orgId}/events/{eventId}/attendance/{uid}   # doc ID = member uid -> no duplicate scans
  name, studentId, scannedBy (uid), method: 'scan' | 'self', scannedAt
```

How the main actions write (each in **one batch**):

- **Create org:** make a 6-character code (letters and digits, no 0/O/1/I), check `joinCodes/{code}` doesn't exist, then write `orgs/{orgId}`, `orgs/{orgId}/members/{myUid}` (role `admin`), `users/{myUid}/memberships/{orgId}` and `joinCodes/{code}`.
- **Join org:** read `joinCodes/{code}`, then write `orgs/{orgId}/members/{myUid}` (role `member`, with `joinCode`) and `users/{myUid}/memberships/{orgId}`.
- **Make officer:** the admin writes `users/{memberUid}/invites/{orgId}`.
- **Accept invite:** the member sets their role to `officer` in both `orgs/{orgId}/members/{uid}` and `users/{uid}/memberships/{orgId}`, and deletes the invite. **Decline** just deletes the invite.
- **Remove officer:** the admin sets the role back to `member` in both places.
- **Scan:** the QR code contains the member's uid. Check `orgs/{orgId}/members/{uid}` exists (else "Not a member"), check the attendance doc doesn't exist (else "Already scanned"), then write `orgs/{orgId}/events/{eventId}/attendance/{uid}` (with `method: 'scan'`) and `users/{uid}/attendance/{eventId}`.
- **Mark me present (officers and admin):** the same two writes as a scan, for my own uid, with `method: 'self'` and `scannedBy` = my uid. Only while the session is open. Disable the button once my attendance doc exists.
- Use `FieldValue.serverTimestamp()` for every `createdAt`, `joinedAt` and `scannedAt`.

## Security rules

Rules are published in the Firebase console (Firestore > Rules), not stored in this repo. Summary:

- Everything requires a signed-in user. Users can only read and edit their own profile, memberships, invites and history.
- An org and its sessions are readable only by its members. The members list and attendance lists are readable only by officers and the admin.
- A user can create an org only as its admin, and join an org only with a join code that belongs to it. Join codes can be read one at a time but never listed.
- Only the admin can invite officers, and only members can be invited. A member becomes an officer only by accepting an invite. The admin can remove an officer role; the admin can't be removed.
- Only officers and the admin can create sessions and record attendance, only for members, and only while the session is open. Attendance records can't be changed or deleted (this also blocks double scans).

If you change a collection path or field the rules check, say exactly which rule must change. **Never suggest `allow read, write: if true` or test-mode rules.**

## Security

- Validate all user input with form validators before saving anything to Firestore.
- Never commit or expose secrets: passwords, service account JSON files, keystore files. `firebase_options.dart` is fine to commit; it only identifies the project.
- Never edit generated files: `firebase_options.dart`, or anything in `build/` or `.dart_tool/`.
- Don't use deprecated packages or APIs.

## Code conventions

- Files `snake_case.dart`, classes `PascalCase`, variables and methods `camelCase`. Root widget is `OrgAttendanceApp`.
- Prefer `StatelessWidget`; use `StatefulWidget` only for local UI state (form controllers, the scanner's `_busy` flag). Dispose controllers.
- Use `const` constructors wherever possible.
- Build widgets as classes, not helper functions that return widgets.
- Every form uses `Form` + `TextFormField` validators (required fields, valid email, password at least 6 characters).
- Live data uses `StreamBuilder` on Firestore `snapshots()`; handle loading, empty and error states.
- Catch `FirebaseAuthException` and show friendly messages in a `SnackBar` (`email-already-in-use`, `invalid-email`, `weak-password`, `invalid-credential`). Never show raw errors.
- On the Scan QR screen, ignore new detections while one is being processed (`_busy` flag).
- Use `debugPrint`, not `print`.
- Comments explain *why*, not *what*; add `///` doc comments on public methods in services and providers.
- Prefer simple, readable code over clever code. Point out my mistakes and tell me why they're mistakes.

## Testing

- Tests go in `test/`. Use fake data and test accounts, never real accounts, passwords or user data.
- Replace Flutter's default counter test in `test/widget_test.dart` with tests for this app.
- Unit-test models (`fromMap` / `toMap`) and validators; widget-test forms and screens that don't need Firebase.
- After an approved change, you may run `flutter analyze` and `flutter test` on your own. If something breaks, tell me what broke and propose the fix (fixes follow the same ask-first rule).
- You can't tap the emulator, so when a change needs checking in the app, tell me what to run (`flutter run`), which screen to open, and what I should see. I'll report back.
- Tests go in the documentation's Test Log (feature, steps, expected, actual, fix/status, written by Student or AI). Tell me when a test you wrote should be logged as "AI".

## Setup & Gotchas

- Windows PowerShell blocks `npm` and `firebase` scripts on this machine: use `npm.cmd` and `firebase.cmd`.
- `flutterfire` is installed in `%LOCALAPPDATA%\Pub\Cache\bin`, which must be on PATH. Open a new terminal if it says "not recognized".
- `minSdk = 24` in `android/app/build.gradle.kts`, because Firebase needs Android 7.0+. Don't lower it.
- The emulator (Medium_Phone) uses a Google Play image, which Firebase needs. Test QR scanning on a real phone; the emulator camera is hard to scan with.
- VS Code's Java extension shows Gradle/Java warnings for `android/`. Ignore them unless `flutter run` itself fails.
- The first build after adding Firebase takes several minutes. Don't cancel it.
- Common errors (from the CC 105 Firebase lesson):
  - `[cloud_firestore/permission-denied]` → rules not published, not signed in, or wrong path
  - `[core/no-app]` → `Firebase.initializeApp` missing or not awaited before `runApp()`
  - `[firebase_auth/operation-not-allowed]` → Email/Password not enabled in the console
  - `[firebase_auth/invalid-credential]` → wrong email or password, or the account was never created (check Authentication > Users)
  - Gradle/build errors after setup → `flutter clean`, `flutter pub get`, then `flutterfire configure`

## Other rules for the agent

- Don't refactor code that isn't part of the current step.
- If something needs a Firebase console change (rules, indexes, enabling a provider), say so instead of working around it.
- Every group member must be able to explain the code in a live demo, so keep it simple enough to explain.
- After each approved change, add a short summary for the team's AI Usage Log:
  1. What you changed and which files
  2. Anything I should test or double-check
  3. Any assumption you made, and any mistake you caught or I should watch for

## Progress (don't start a phase until I say so)

- [x] Phase 1: Firebase project, Auth (Email/Password), Firestore and rules set up; app connected (`main.dart` shows a temporary "Firebase connected" screen)
- [x] Phase 2: Theme, atoms, molecules, models, services, providers, Register, Login, Auth Gate, Profile, bottom navigation
- [x] Phase 3: Orgs: Home (My Orgs), Add organization with join code, Join organization, Org Page
- [x] Phase 4: Roles: Members list, Make / Remove officer, Invitations (accept / decline)
- [x] Phase 5: Attendance: My QR, Take attendance, Scan QR with membership check, Attendance List, History
- [ ] Phase 6: Testing, polish, release APK and documentation

Only if there's time: leave org, change join code, edit, delete or reopen sessions. (Remove member is done.)

Ask me before ticking a phase.
