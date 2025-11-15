# Password Hash Generator

Generate SHA256 password hashes for the MH HR Employee Backend database.

---

## Usage

```bash
dotnet run --project PasswordHasher/PasswordHasher.csproj
```

Then type any password to get its hash. Press Enter to exit.

---

## Common Hashes

| Password    | SHA256 Hash |
|-------------|-------------|
| `Admin@123` | `e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7` |
| `User@123`  | `3e7c19576488862816f13b512cacf3e4ba97dd97243ea0bd6a2ad1642d86ba72` |

---

## SQL Examples

**Insert new user:**
```sql
INSERT INTO users ([email], [password], [full_name], [role], ...)
VALUES ('user@example.com',
        'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7',
        'John Doe', 'user', ...);
```

**Update password:**
```sql
UPDATE users
SET password = 'e86f78a8a3caf0b60d8e74e5942aa6d86dc150cd3c03338aef25b7d2d7e3acc7'
WHERE email = 'user@example.com';
```

---

## Troubleshooting

**Login fails after updating password?**

Check user status:
```sql
SELECT id, email, status, active_status, LEN(password) as hash_length
FROM users WHERE email = 'your.email@example.com';
```

Required values:
- `status` = `'approved'`
- `active_status` = `'active'`
- `hash_length` = `64`

---

## Security Notes

⚠️ Change default passwords after first login
⚠️ Passwords are case-sensitive
⚠️ Remove spaces before/after passwords
⚠️ Hash length must be exactly 64 characters
