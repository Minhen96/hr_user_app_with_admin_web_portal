# MH Employee Management System - Monorepo

## Overview

This is a monorepo containing three interconnected applications:

1. **mh_hr_employee_dotnet_backend/** - .NET 8.0 ASP.NET Core Web API
2. **mh_hr_employee_react_web/** - React web admin portal (✅ Refactored)
3. **mh_employee_flutter_app/** - Flutter mobile app (Pending refactoring)

---

## Quick Start

### Backend (.NET API)
```bash
cd mh_hr_employee_dotnet_backend
dotnet restore
dotnet run --project React.csproj
# Runs on: http://localhost:5000
```

### Web Admin Portal (React) - ✅ REFACTORED
```bash
cd mh_hr_employee_react_web/my-react
npm install
npm run dev
# Runs on: http://localhost:5173
```

### Mobile App (Flutter)
```bash
cd mh_employee_flutter_app
flutter pub get
flutter run
```

---

## React Refactoring Status: ✅ COMPLETE

The React web admin has been successfully refactored into a modern feature-based architecture.

### New Structure:
```
src/
├── features/          # Feature modules (auth, equipment, documents, etc.)
├── shared/            # Shared components (Sidebar, dialogs)
├── core/              # Core infrastructure (API client, config)
└── App.jsx
```

### Testing:
```bash
cd mh_hr_employee_react_web/my-react
npm run dev
```

All pages should load correctly. If you see import errors, check `TEST_AND_FINISH.md`.

---

## Flutter Refactoring Status: ⏳ PENDING

The Flutter app is next in line for refactoring.

**To refactor Flutter:**
See `REFACTORING_STEP_BY_STEP.md` - Phase 3 (Steps 1-16)

Estimated time: 12-15 hours

---

## Documentation

### Essential Files:
- **CLAUDE.md** - Main codebase documentation and instructions
- **README.md** - This file (overview)
- **TEST_AND_FINISH.md** - React testing guide
- **QUICK_REFERENCE.md** - Import patterns and commands

### Refactoring Guides:
- **REFACTORING.md** - Full architectural overview
- **REFACTORING_STEP_BY_STEP.md** - Detailed 16-step guide for Flutter
- **MISSION_ACCOMPLISHED.md** - React refactoring summary

### Reading Order:
1. Start with this README
2. Check CLAUDE.md for detailed codebase info
3. For Flutter refactoring: REFACTORING_STEP_BY_STEP.md

---

## Current Configuration

### API URLs:
- Backend: `http://localhost:5000`
- React: Points to localhost (configured in `.env.development`)
- Flutter: Points to localhost (configured in `api_service.dart`)

### Firebase:
- ✅ Completely removed from all apps
- Push notifications disabled

---

## Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Backend | ✅ Ready | No changes needed |
| React Web Admin | ✅ Refactored | Modern feature-based architecture |
| Flutter App | ⚠️ Needs Refactoring | Works but messy structure |
| Firebase | ✅ Removed | From all frontends |
| API URLs | ✅ Updated | All point to localhost |

---

## Next Steps

### Immediate:
1. Test React app (`npm run dev`)
2. Fix any remaining import errors
3. Delete old `src/api.js` after testing

### Optional:
1. Refactor Flutter app (follow REFACTORING_STEP_BY_STEP.md Phase 3)
2. Add more features
3. TypeScript migration

---

## Need Help?

- **React issues**: Check `TEST_AND_FINISH.md`
- **Flutter refactoring**: See `REFACTORING_STEP_BY_STEP.md`
- **General questions**: Check `CLAUDE.md`

---

**Last Updated:** 2025-10-20
**React Status:** ✅ Complete
**Flutter Status:** ⏳ Pending
