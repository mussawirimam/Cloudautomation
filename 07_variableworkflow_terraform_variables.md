# Terraform Variables — How They Work

## The Golden Rule
```
variables.tf      →  DECLARES the variable (shape/type)
*.tfvars          →  ASSIGNS the actual values
```
These are ALWAYS separate files. Never mix them.

---

## File Roles

```
┌─────────────────────────────────────────────────────┐
│                   variables.tf                      │
│  "I expect a variable called usernames.             │
│   It must be a set of strings."                     │
│                                                     │
│   variable "usernames" {                            │
│       description = "The list of usernames"         │
│       type        = set(string)                     │
│   }                                                 │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│             users_list.auto.tfvars                  │
│  "Here are the actual values for usernames."        │
│                                                     │
│   usernames = ["santosh", "nanda",                  │
│                "asif", "michael"]                   │
└─────────────────────────────────────────────────────┘
```

---

## What Goes Inside a variable {} Block

```
variable "usernames" {
    description = "..."    ✅ allowed — documents the variable
    type        = ...      ✅ allowed — enforces data type
    default     = ...      ✅ allowed — fallback if no value given
    validation  { }        ✅ allowed — custom validation rules
    sensitive   = true     ✅ allowed — hides value in logs

    usernames = [...]      ❌ NOT ALLOWED — values go in .tfvars
}
```

---

## The 'default' Keyword (Optional)

If you want values IN variables.tf, use `default`:

```hcl
variable "usernames" {
    description = "The list of usernames"
    type        = set(string)
    default     = ["santosh", "nanda", "asif", "michael"]
}
```

```
With default:                    Without default:
─────────────────                ──────────────────────────
No .tfvars needed                .tfvars REQUIRED
Values hardcoded                 Values swappable per env
Less flexible                    More flexible ✅
```

---

## Why Keep Them Separate? (Environments)

```
project/
 ├── variables.tf              ← same for ALL environments
 ├── main.tf
 ├── dev.tfvars                ← dev values
 ├── staging.tfvars            ← staging values
 └── prod.tfvars               ← prod values
```

Run with a specific env:
```bash
terraform apply -var-file="prod.tfvars"
```

`.auto.tfvars` files are loaded automatically — no flag needed.

---

## How Values Flow Through Terraform

```
  users_list.auto.tfvars
  ┌─────────────────────────────────┐
  │ usernames = ["santosh","nanda"] │
  └────────────────┬────────────────┘
                   │ Terraform loads this automatically
                   ▼
  variables.tf
  ┌─────────────────────────────────┐
  │ variable "usernames" {          │
  │     type = set(string)  ◄───────┤ validates type matches
  │ }                               │
  └────────────────┬────────────────┘
                   │ now usable as var.usernames
                   ▼
  users.tf
  ┌─────────────────────────────────┐
  │ for_each = var.usernames        │ ← "santosh", "nanda"...
  │   name   = each.value           │ ← sets .name on resource
  └─────────────────────────────────┘
```

---

## The for_each + .name Chain

```
var.usernames = {"santosh", "nanda", "asif", "michael"}
      │
      ▼
aws_iam_user.dev_users resource gets created 4 times:
┌──────────────────────────────────────────────┐
│  key="santosh"  →  object { name="santosh" } │
│  key="nanda"    →  object { name="nanda"   } │
│  key="asif"     →  object { name="asif"    } │
│  key="michael"  →  object { name="michael" } │
└──────────────────────────────────────────────┘
      │
      ▼
aws_iam_user_policy iterates over those objects:
  for_each = aws_iam_user.dev_users
  user     = each.value.name   ← reads .name from the object above
                                  "santosh", "nanda", etc.
```

---

## set(string) vs list(string)

```
list(string)               set(string)
────────────────────        ────────────────────
Ordered                     Unordered
Allows duplicates           No duplicates
["a","a","b"] is fine       {"a","a","b"} → {"a","b"}
Use index: [0],[1]          No index access
Good for ordered data       Good for for_each ✅
```

`for_each` requires a **set or map** — not a list.
That's why `type = set(string)` is used here.

---

## Quick Reference

```
variable "x" { }            →  declares x
var.x                        →  uses x in .tf files
x = "value"  in .tfvars     →  assigns x
default = "value"            →  fallback value inside variable block
*.auto.tfvars                →  auto-loaded, no flag needed
-var-file="file.tfvars"      →  manually load a tfvars file
-var="x=value"               →  pass value inline via CLI
```
