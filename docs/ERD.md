# RITMA — Entity Relationship Diagram (ERD)

This ERD reflects the normalized PostgreSQL schema spanning Multi-Tenant Identity, Membership & Entitlements, Credit Ledger, Facility Access, and Studio Booking.

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ BRANCHES : "owns"
    ORGANIZATIONS ||--o{ MEMBERS : "registers"
    ORGANIZATIONS ||--o{ PACKAGES : "offers"
    ORGANIZATIONS ||--o{ CLASS_TYPES : "defines"
    ORGANIZATIONS ||--o{ USER_ROLE_ASSIGNMENTS : "scopes"
    ORGANIZATIONS ||--o{ AUDIT_LOGS : "records"

    BRANCHES ||--o{ ROOMS : "contains"
    BRANCHES ||--o{ USER_ROLE_ASSIGNMENTS : "scopes_optional"
    BRANCHES ||--o{ CLASS_SESSIONS : "hosts"
    BRANCHES ||--o{ FACILITY_VISITS : "logs"
    BRANCHES ||--o{ FACILITY_ACCESS_ATTEMPTS : "audits"

    USER_PROFILES ||--o{ USER_ROLE_ASSIGNMENTS : "holds"
    ROLES ||--o{ USER_ROLE_ASSIGNMENTS : "assigned_as"
    ROLES ||--o{ ROLE_PERMISSIONS : "grants"
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : "mapped_to"

    USER_PROFILES |o--o{ MEMBERS : "links_optional"
    BRANCHES ||--o{ MEMBERS : "home_branch"

    PACKAGES ||--o{ PACKAGE_ENTITLEMENT_RULES : "provisions"
    PACKAGES ||--o{ MEMBER_SUBSCRIPTIONS : "sold_as"

    MEMBERS ||--o{ MEMBER_SUBSCRIPTIONS : "subscribes"
    MEMBER_SUBSCRIPTIONS ||--o{ PAYMENT_RECORDS : "settled_by"
    MEMBER_SUBSCRIPTIONS ||--o{ MEMBER_ENTITLEMENTS : "materializes"
    MEMBER_SUBSCRIPTIONS ||--o{ CREDIT_GRANTS : "issues"

    MEMBERS ||--o{ MEMBER_ENTITLEMENTS : "possesses"
    MEMBERS ||--o{ CREDIT_GRANTS : "owns_buckets"
    CREDIT_GRANTS ||--o{ CREDIT_LEDGER_ENTRIES : "tracked_by"
    MEMBERS ||--o{ CREDIT_LEDGER_ENTRIES : "accounted_in"

    MEMBERS ||--o{ FACILITY_VISITS : "visits"
    MEMBER_ENTITLEMENTS |o--o{ FACILITY_VISITS : "authorized_by"

    CLASS_TYPES ||--o{ CLASS_TEMPLATES : "categorizes"
    CLASS_TEMPLATES ||--o{ CLASS_SESSIONS : "schedules"
    ROOMS ||--o{ CLASS_SESSIONS : "occupied_by"
    USER_PROFILES ||--o{ CLASS_SESSIONS : "instructed_by"

    CLASS_SESSIONS ||--o{ CLASS_BOOKINGS : "reserves"
    MEMBERS ||--o{ CLASS_BOOKINGS : "books"
```

## Key Relationship Notes

- **Multi-Role Isolation:** `USER_PROFILES` connects to `ORGANIZATIONS` and `BRANCHES` through `USER_ROLE_ASSIGNMENTS` (many-to-many with role & scope). A single user can be `org_owner` in Org A, `instructor` in Org B Branch 2, and a `member` in Org C.
- **Entitlement Decoupling:** `MEMBER_SUBSCRIPTIONS` is the commercial record; it fans out into `MEMBER_ENTITLEMENTS` (for facility access or unlimited class rights) and/or `CREDIT_GRANTS` + `CREDIT_LEDGER_ENTRIES` (for countable class/PT credits).
- **Access Integrity:** `FACILITY_VISITS` links directly to the exact `MEMBER_ENTITLEMENTS` row that authorized entry, guaranteeing post-hoc auditability even if a package definition changes later.
- **Ledger Integrity:** `CLASS_BOOKINGS` references `CREDIT_LEDGER_ENTRIES` via `(reference_type = 'class_booking', reference_id = booking.id)`, linking every consumption and refund directly to its booking lifecycle.
