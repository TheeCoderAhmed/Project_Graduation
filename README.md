# DRAPO - Firebase Project Setup

## Firebase Project Info

| Field | Value |
|---|---|
| **Project ID** | `drapo7` |
| **Project Number** | `986206394751` |
| **Storage Bucket** | `drapo7.firebasestorage.app` |
| **Android App ID** | `1:986206394751:android:e0a1899e51c72245aba24a` |
| **Android Package** | `DRAPO.T7` |

---

## Project Structure

```
DRAPO/
├── firebase.json              # Firebase CLI configuration
├── .firebaserc               # Project aliases
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Composite indexes
├── storage.rules             # Cloud Storage security rules
├── google-services.json      # Android Firebase config
└── google-services-2.json    # Backup Android Firebase config
```

---

## Quick Setup (For Flutter Project)

### 1. Login to the correct Firebase account

```bash
firebase login
# Login with the Google account that owns drapo7
```

### 2. Link this directory to the drapo7 project

```bash
firebase use drapo7
```

### 3. Copy `google-services.json` to your Android app

```bash
cp google-services.json <your_flutter_project>/android/app/google-services.json
```

### 4. Run FlutterFire CLI to generate `firebase_options.dart`

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=drapo7
```

### 5. Deploy Firebase rules and indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

---

## Firestore Collections

| Collection | Description | Auth Required |
|---|---|---|
| `users/{userId}` | User profiles | Read: auth, Write: own |
| `places/{placeId}` | Places/landmarks | Read: public, Write: admin |
| `places/{placeId}/reviews` | Place reviews | Read: public, Write: auth |
| `discussions/{postId}` | Discussion posts | Read: public, Write: auth |
| `discussions/{postId}/comments` | Post comments | Read: public, Write: auth |
| `discussions/{postId}/likes` | Post likes | Read: public, Write: own |
| `discussions/{postId}/reports` | Post reports | Read: admin, Write: auth |
| `announcements/{id}` | App announcements | Read: public, Write: admin |
| `markets/{marketId}` | Market listings | Read: public, Write: admin |
| `markets/{marketId}/products` | Market products | Read: public, Write: admin |
| `restaurants/{id}` | Restaurant listings | Read: public, Write: admin |
| `restaurants/{id}/menu` | Restaurant menus | Read: public, Write: admin |
| `notifications/{userId}/items` | User notifications | Read/Update: own, Create/Delete: functions |
| `fcm_tokens/{userId}` | FCM push tokens | Read/Write: own |
| `categories/{id}` | Content categories | Read: public, Write: admin |
| `app_config/{id}` | Remote app config | Read: public, Write: admin |

---

## Firestore Composite Indexes

- `discussions` → `placeId ASC + createdAt DESC` (place feed)
- `discussions` → `category ASC + createdAt DESC` (filtered feed)
- `discussions` → `userId ASC + createdAt DESC` (user posts)
- `discussions` → `placeId + category + createdAt DESC` (filtered place feed)
- `announcements` → `isActive ASC + createdAt DESC`
- `announcements` → `type ASC + createdAt DESC`
- `places` → `category ASC + name ASC`
- `markets` → `category ASC + name ASC`
- `restaurants` → `category ASC + name ASC`
- `notifications` → `isRead ASC + createdAt DESC`

---

## Storage Structure

```
drapo7.firebasestorage.app/
├── users/{userId}/profile/          # Profile images (max 5MB, images only)
├── discussions/{postId}/            # Post media (max 50MB)
├── places/{placeId}/                # Place photos
├── markets/{marketId}/              # Market images
├── restaurants/{restaurantId}/      # Restaurant images
└── announcements/{announcementId}/  # Announcement media
```

---

## Firebase Services to Enable

1. **Authentication** → Email/Password, Google Sign-In, Anonymous
2. **Firestore Database** → Production mode (rules already configured)
3. **Cloud Storage** → Default bucket
4. **Cloud Messaging (FCM)** → For push notifications
5. **App Check** → reCAPTCHA / Play Integrity
6. **Analytics** → Google Analytics

---

## Admin Role Setup

To make a user an admin, set `role: 'admin'` in their Firestore document:

```
users/{userId} {
  role: "admin",
  ...
}
```

This unlocks write access to places, markets, restaurants, categories, announcements, and app_config.

---

## Deploy Commands

```bash
# Deploy everything
firebase deploy

# Deploy only rules
firebase deploy --only firestore:rules,storage

# Deploy only indexes
firebase deploy --only firestore:indexes

# Emulate locally
firebase emulators:start --only firestore,storage,auth
```
