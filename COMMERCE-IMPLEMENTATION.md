# AKCIEBI Marketplace Commerce — draft implementation

**Status: NOT ACTIVE.** This work is isolated on branch `feature/marketplace-commerce-draft`.
No production deployment, Supabase migration, bank connection, payment capture, payout, or customer-facing checkout has been enabled.

## Existing project findings
- The site already has a browser-local cart UI, but its current copy explicitly tells customers to contact the seller; it is not a checkout.
- The production Supabase project currently has listings, profiles, stores, favorites, messages, etc., but no order/payment/dispute tables and no Edge Functions.
- Therefore a real multi-seller checkout cannot safely be switched on just by changing the cart button.

## Commerce model prepared
- A parent order belongs to one buyer.
- A checkout can create separate seller orders so each merchant can accept, reject, ship, and track their own part.
- Item names, photos, prices and quantities are snapshotted at purchase time.
- All money values are integer tetri (GEL) to avoid floating-point rounding.
- Payment provider references and idempotency keys are recorded; raw card data is never stored.
- Buyer/seller access is protected with RLS. Client-side writes are intentionally absent.
- Disputes, evidence, refund requests, verification state and payout ledger are represented.
- No platform-held funds are assumed. Any delayed seller payout / escrow-like flow requires a written agreement with a licensed bank/payment provider and legal review.

## Activation blockers (must remain off until owner approval)
1. Select a bank/payment provider and obtain merchant approval, API credentials and webhook configuration.
2. Confirm the supported marketplace/split-settlement or delayed-payout model with the provider.
3. Confirm company/individual seller onboarding, KYC/AML responsibilities, fees, refund and chargeback responsibilities.
4. Configure shipping partners, delivery pricing and tracking integration.
5. Configure private evidence storage and retention policy.
6. Implement and test trusted Edge Functions: create checkout, verify provider webhooks, idempotent state transitions, seller order actions, dispute/refund handling, payout reconciliation.
7. Add frontend checkout and buyer/seller/admin dashboards, then run security review and test transactions in sandbox.
8. Obtain explicit owner approval before any production migration, deployment or payment activation.

## Database draft
The file `supabase/migrations/202611230001_marketplace_commerce.sql` is a proposal only. It has not been run against the production database.
