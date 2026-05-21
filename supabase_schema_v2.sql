-- ─────────────────────────────────────────────────────────────────────────────
-- SuperSave v2 — Extended Schema
-- Run this in your Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Assets (for Net Worth) ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS assets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users NOT NULL,
  name        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'other',
  -- 'bank' | 'investment' | 'property' | 'vehicle' | 'crypto' | 'other'
  value       NUMERIC(14,2) NOT NULL DEFAULT 0,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own assets"
  ON assets FOR ALL USING (auth.uid() = user_id);

-- ── Debts ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS debts (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID REFERENCES auth.users NOT NULL,
  name             TEXT NOT NULL,
  type             TEXT NOT NULL DEFAULT 'other',
  -- 'credit_card' | 'student_loan' | 'mortgage' | 'auto_loan' | 'personal_loan' | 'other'
  balance          NUMERIC(14,2) NOT NULL DEFAULT 0,
  interest_rate    NUMERIC(6,3) NOT NULL DEFAULT 0,   -- APR as percent e.g. 19.99
  minimum_payment  NUMERIC(10,2) NOT NULL DEFAULT 0,
  due_day          SMALLINT,                           -- 1-31
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own debts"
  ON debts FOR ALL USING (auth.uid() = user_id);

-- ── Bills ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bills (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users NOT NULL,
  name        TEXT NOT NULL,
  amount      NUMERIC(10,2) NOT NULL DEFAULT 0,
  due_day     SMALLINT NOT NULL,    -- 1-31, day of month bill is due
  is_autopay  BOOLEAN DEFAULT FALSE,
  notes       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bills ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own bills"
  ON bills FOR ALL USING (auth.uid() = user_id);

-- ── Subscriptions ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subscriptions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID REFERENCES auth.users NOT NULL,
  name             TEXT NOT NULL,
  amount           NUMERIC(10,2) NOT NULL DEFAULT 0,
  billing_cycle    TEXT NOT NULL DEFAULT 'monthly',  -- 'weekly' | 'monthly' | 'yearly'
  is_active        BOOLEAN DEFAULT TRUE,
  next_charge_date DATE,
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own subscriptions"
  ON subscriptions FOR ALL USING (auth.uid() = user_id);

-- ── Net Worth Snapshots (monthly history) ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS net_worth_snapshots (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID REFERENCES auth.users NOT NULL,
  total_assets   NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_debts    NUMERIC(14,2) NOT NULL DEFAULT 0,
  net_worth      NUMERIC(14,2) NOT NULL DEFAULT 0,
  snapshot_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, snapshot_date)
);

ALTER TABLE net_worth_snapshots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own snapshots"
  ON net_worth_snapshots FOR ALL USING (auth.uid() = user_id);

-- ── Linked Bank Accounts (Plaid) ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS linked_accounts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES auth.users NOT NULL,
  plaid_account_id  TEXT,
  plaid_item_id     TEXT,
  institution_name  TEXT NOT NULL,
  account_name      TEXT NOT NULL,
  account_type      TEXT NOT NULL DEFAULT 'checking',
  -- 'checking' | 'savings' | 'credit' | 'investment'
  mask              TEXT,           -- last 4 digits
  current_balance   NUMERIC(14,2),
  available_balance NUMERIC(14,2),
  currency          TEXT DEFAULT 'USD',
  is_active         BOOLEAN DEFAULT TRUE,
  last_synced_at    TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE linked_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own accounts"
  ON linked_accounts FOR ALL USING (auth.uid() = user_id);

-- ── Bank Transactions (from Plaid) ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bank_transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users NOT NULL,
  account_id      UUID REFERENCES linked_accounts(id) ON DELETE CASCADE,
  plaid_txn_id    TEXT UNIQUE,
  merchant_name   TEXT,
  name            TEXT NOT NULL,
  amount          NUMERIC(10,2) NOT NULL,   -- positive = expense, negative = income
  category        TEXT,
  subcategory     TEXT,
  date            DATE NOT NULL,
  is_pending      BOOLEAN DEFAULT FALSE,
  imported_at     TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE bank_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own transactions"
  ON bank_transactions FOR ALL USING (auth.uid() = user_id);

-- ── User Settings ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_settings (
  user_id          UUID PRIMARY KEY REFERENCES auth.users,
  currency         TEXT DEFAULT 'USD',
  is_premium       BOOLEAN DEFAULT FALSE,
  premium_expires  TIMESTAMPTZ,
  notifications    JSONB DEFAULT '{"bills": true, "budget": true, "weekly": true}'::jsonb,
  onboarding_done  BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users manage own settings"
  ON user_settings FOR ALL USING (auth.uid() = user_id);

-- Auto-create user_settings row on signup
CREATE OR REPLACE FUNCTION handle_new_user_settings()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_settings ON auth.users;
CREATE TRIGGER on_auth_user_created_settings
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user_settings();

-- ── Indexes ───────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_assets_user ON assets(user_id);
CREATE INDEX IF NOT EXISTS idx_debts_user ON debts(user_id);
CREATE INDEX IF NOT EXISTS idx_bills_user ON bills(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_bank_txn_user_date ON bank_transactions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_linked_accounts_user ON linked_accounts(user_id);
