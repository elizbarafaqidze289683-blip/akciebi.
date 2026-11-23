-- AKCIEBI marketplace commerce foundation.
-- Prepared on a feature branch only. NOT applied to production.
-- Payment capture, escrow/holding, payouts and refunds must be implemented
-- through an approved bank/payment partner and trusted Edge Functions.

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_id uuid not null references auth.users(id) on delete restrict,
  currency text not null default 'GEL' check (currency = 'GEL'),
  subtotal_tetri bigint not null check (subtotal_tetri >= 0),
  delivery_tetri bigint not null default 0 check (delivery_tetri >= 0),
  total_tetri bigint not null check (total_tetri >= 0),
  status text not null default 'pending_payment'
    check (status in ('pending_payment','paid','processing','partially_shipped','shipped','delivered','cancelled','disputed','refunded','partially_refunded')),
  payment_status text not null default 'unpaid'
    check (payment_status in ('unpaid','pending','authorized','paid','failed','partially_refunded','refunded')),
  recipient_name text not null,
  recipient_phone text not null,
  delivery_city text not null,
  delivery_address text not null,
  delivery_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.seller_orders (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  seller_id uuid not null references auth.users(id) on delete restrict,
  recipient_name text not null,
  recipient_phone text not null,
  delivery_city text not null,
  delivery_address text not null,
  delivery_note text,
  subtotal_tetri bigint not null check (subtotal_tetri >= 0),
  delivery_tetri bigint not null default 0 check (delivery_tetri >= 0),
  status text not null default 'awaiting_payment'
    check (status in ('awaiting_payment','new','accepted','rejected','preparing','shipped','delivered','cancelled','disputed','refunded','partially_refunded')),
  seller_note text,
  tracking_company text,
  tracking_number text,
  accepted_at timestamptz,
  shipped_at timestamptz,
  delivered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  seller_order_id uuid not null references public.seller_orders(id) on delete restrict,
  offer_id uuid references public.offers(id) on delete set null,
  title_snapshot text not null,
  image_snapshot text,
  unit_price_tetri bigint not null check (unit_price_tetri >= 0),
  quantity integer not null default 1 check (quantity between 1 and 100),
  line_total_tetri bigint not null check (line_total_tetri >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.payment_transactions (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  provider text not null check (provider in ('tbc','bog','other')),
  provider_payment_id text,
  idempotency_key text not null unique,
  amount_tetri bigint not null check (amount_tetri > 0),
  currency text not null default 'GEL' check (currency = 'GEL'),
  status text not null default 'created'
    check (status in ('created','requires_action','authorized','captured','failed','cancelled','partially_refunded','refunded')),
  provider_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(provider, provider_payment_id)
);

create table if not exists public.order_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  seller_order_id uuid references public.seller_orders(id) on delete restrict,
  actor_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.seller_verifications (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null unique references auth.users(id) on delete cascade,
  seller_kind text not null check (seller_kind in ('individual','company')),
  legal_name text not null,
  tax_id text,
  phone text not null,
  status text not null default 'not_submitted'
    check (status in ('not_submitted','pending','verified','rejected','suspended')),
  reviewed_at timestamptz,
  reviewer_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.disputes (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  seller_order_id uuid not null references public.seller_orders(id) on delete restrict,
  opened_by uuid not null references auth.users(id) on delete restrict,
  reason text not null check (reason in ('not_received','damaged','not_as_described','wrong_item','seller_unresponsive','other')),
  description text not null,
  status text not null default 'open'
    check (status in ('open','under_review','resolved_buyer','resolved_seller','closed')),
  resolution_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.dispute_evidence (
  id uuid primary key default gen_random_uuid(),
  dispute_id uuid not null references public.disputes(id) on delete cascade,
  uploaded_by uuid not null references auth.users(id) on delete restrict,
  storage_path text not null,
  media_type text,
  created_at timestamptz not null default now()
);

create table if not exists public.refund_requests (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  seller_order_id uuid references public.seller_orders(id) on delete restrict,
  dispute_id uuid references public.disputes(id) on delete restrict,
  requested_by uuid not null references auth.users(id) on delete restrict,
  amount_tetri bigint not null check (amount_tetri > 0),
  reason text not null,
  status text not null default 'requested'
    check (status in ('requested','under_review','approved','rejected','processing','completed','failed')),
  provider_refund_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.seller_payouts (
  id uuid primary key default gen_random_uuid(),
  seller_order_id uuid not null unique references public.seller_orders(id) on delete restrict,
  seller_id uuid not null references auth.users(id) on delete restrict,
  gross_tetri bigint not null check (gross_tetri >= 0),
  commission_tetri bigint not null default 0 check (commission_tetri >= 0),
  net_tetri bigint not null check (net_tetri >= 0),
  status text not null default 'not_configured'
    check (status in ('not_configured','pending','processing','paid','failed','on_hold')),
  provider_transfer_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists orders_buyer_created_idx on public.orders(buyer_id, created_at desc);
create index if not exists seller_orders_seller_created_idx on public.seller_orders(seller_id, created_at desc);
create index if not exists seller_orders_order_idx on public.seller_orders(order_id);
create index if not exists order_items_seller_order_idx on public.order_items(seller_order_id);
create index if not exists payment_transactions_order_idx on public.payment_transactions(order_id);
create index if not exists order_events_order_created_idx on public.order_events(order_id, created_at);
create index if not exists disputes_order_idx on public.disputes(order_id);
create index if not exists refund_requests_order_idx on public.refund_requests(order_id);

alter table public.orders enable row level security;
alter table public.seller_orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payment_transactions enable row level security;
alter table public.order_events enable row level security;
alter table public.seller_verifications enable row level security;
alter table public.disputes enable row level security;
alter table public.dispute_evidence enable row level security;
alter table public.refund_requests enable row level security;
alter table public.seller_payouts enable row level security;

-- Buyers and participating sellers can read order headers; writes remain server-only.
drop policy if exists "order_participants_read_orders" on public.orders;
create policy "order_participants_read_orders" on public.orders
for select to authenticated
using (buyer_id = (select auth.uid()));

drop policy if exists "seller_reads_own_seller_orders" on public.seller_orders;
create policy "seller_reads_own_seller_orders" on public.seller_orders
for select to authenticated
using (
  seller_id = (select auth.uid())
  or exists (
    select 1 from public.orders o
    where o.id = seller_orders.order_id and o.buyer_id = (select auth.uid())
  )
);

drop policy if exists "participants_read_order_items" on public.order_items;
create policy "participants_read_order_items" on public.order_items
for select to authenticated
using (
  exists (
    select 1 from public.seller_orders so
    where so.id = order_items.seller_order_id
      and (
        so.seller_id = (select auth.uid())
        or exists (select 1 from public.orders o where o.id = so.order_id and o.buyer_id = (select auth.uid()))
      )
  )
);

drop policy if exists "buyers_read_own_payments" on public.payment_transactions;
create policy "buyers_read_own_payments" on public.payment_transactions
for select to authenticated
using (exists (select 1 from public.orders o where o.id = payment_transactions.order_id and o.buyer_id = (select auth.uid())));

drop policy if exists "participants_read_order_events" on public.order_events;
create policy "participants_read_order_events" on public.order_events
for select to authenticated
using (
  exists (select 1 from public.orders o where o.id = order_events.order_id and o.buyer_id = (select auth.uid()))
  or exists (select 1 from public.seller_orders so where so.id = order_events.seller_order_id and so.seller_id = (select auth.uid()))
);

drop policy if exists "seller_reads_own_verification" on public.seller_verifications;
create policy "seller_reads_own_verification" on public.seller_verifications
for select to authenticated using (seller_id = (select auth.uid()));

drop policy if exists "dispute_participants_read" on public.disputes;
create policy "dispute_participants_read" on public.disputes
for select to authenticated
using (
  opened_by = (select auth.uid())
  or exists (select 1 from public.orders o where o.id = disputes.order_id and o.buyer_id = (select auth.uid()))
  or exists (select 1 from public.seller_orders so where so.id = disputes.seller_order_id and so.seller_id = (select auth.uid()))
);

drop policy if exists "dispute_participants_read_evidence" on public.dispute_evidence;
create policy "dispute_participants_read_evidence" on public.dispute_evidence
for select to authenticated
using (
  exists (
    select 1 from public.disputes d
    where d.id = dispute_evidence.dispute_id
      and (
        d.opened_by = (select auth.uid())
        or exists (select 1 from public.orders o where o.id = d.order_id and o.buyer_id = (select auth.uid()))
        or exists (select 1 from public.seller_orders so where so.id = d.seller_order_id and so.seller_id = (select auth.uid()))
      )
  )
);

drop policy if exists "refund_request_participants_read" on public.refund_requests;
create policy "refund_request_participants_read" on public.refund_requests
for select to authenticated
using (
  requested_by = (select auth.uid())
  or exists (select 1 from public.orders o where o.id = refund_requests.order_id and o.buyer_id = (select auth.uid()))
  or exists (select 1 from public.seller_orders so where so.id = refund_requests.seller_order_id and so.seller_id = (select auth.uid()))
);

drop policy if exists "seller_reads_own_payouts" on public.seller_payouts;
create policy "seller_reads_own_payouts" on public.seller_payouts
for select to authenticated using (seller_id = (select auth.uid()));

-- Deliberately no client INSERT/UPDATE/DELETE policies. A trusted server-side
-- function with verified payment webhooks must perform all state transitions.

-- The tables are intentionally unavailable to anon/authenticated clients.
-- When the project is configured for the Data API during approved activation,
-- expose public schema only as needed and keep these grants service-role-only.
revoke all on public.orders, public.seller_orders, public.order_items,
  public.payment_transactions, public.order_events, public.seller_verifications,
  public.disputes, public.dispute_evidence, public.refund_requests,
  public.seller_payouts from anon, authenticated;
grant all on public.orders, public.seller_orders, public.order_items,
  public.payment_transactions, public.order_events, public.seller_verifications,
  public.disputes, public.dispute_evidence, public.refund_requests,
  public.seller_payouts to service_role;
