# CareerPilot ✈️

Helping you pilot through you job search easily.

![GitHub last commit](https://img.shields.io/github/last-commit/woidthevoid/CareerPilot?display_timestamp=author&style=for-the-badge&logo=git)
![GitHub Created At](https://img.shields.io/github/created-at/woidthevoid/CareerPilot?&style=for-the-badge)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/woidthevoid/CareerPilot/analyze.yaml?style=for-the-badge)

## What is it?
CareerPilot is a Flutter application that aims to make it easier to keep track of your applications and where in the proces they are, since it can be challening searching hundreds of jobs, forgetting which jobs you applied to. The app is made for iOS and macOS.

## Technologies
These following technologies are used in the application:
- ![Flutter](https://img.shields.io/badge/flutter-blue?style=for-the-badge&logo=flutter)
- ![Supabase](https://img.shields.io/badge/supabase-black?style=for-the-badge&logo=supabase)
- ![Postgres](https://img.shields.io/badge/postgres-white?style=for-the-badge&logo=postgresql) in Supabase

## Features
Current versions supports viewing applications as cards, inserting new applications and deleting them. Login is getting reworked and therefore no new user can be added from the app currently. 

### Future features
- Resume and cover letter upload
- Tailored job postings
- Timelines for job postings (applied, respond received etc)
- Goggle and Apple login
- and much more...

## How to install and run
VS Code is recommended to make running the app smoother.

1. Clone the repo.
2. Make sure you have Flutter installed. If you do not have Flutter yet, visit the [Flutter Install Documentation](https://docs.flutter.dev/install).
3. Run the following in a terminal INSIDE the repo:
   ```bash
   flutter pub get
   ```
   And then:
   ```bash
   flutter run
   ```
   This will give you are list of emulators you can run it on.
   
   The app is currently for MacOS and iOS so you will need a physical device running these or a emulator. Works on both macOS 26 and iOS 26.
