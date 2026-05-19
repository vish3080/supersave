-- =============================================
-- FinanceTrack — Supabase Database Schema
-- Run this in your Supabase SQL Editor
-- =============================================

-- Enable UUID extension
create extension if not exists "pgcrypto";

-- -----------------------------------------------
-- Income Entries
-- -----------------------------------------------
create table public.income_entries (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users(id) on delete cascade,
    amount      numeric(12, 2) not null check (amount > 0),
    month       smallint not null check (month between 1 and 12),
    year        int not null check (year > 2000),
    source      text not null default 'Salary',
    created_at  timestamptz not null default now()
);

alter table public.income_entries enable row level security;
create policy "Users can manage their own income"
    on public.income_entries for all
    using (auth.uid() = user_id);

-- -----------------------------------------------
-- Categories
-- -----------------------------------------------
create table public.categories (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid not null references auth.users(id) on delete cascade,
    name         text not null,
    color_hex    text not null default '5B8DEF',
    icon_name    text not null default 'tag.fill',
    budget_limit numeric(12, 2),
    created_at   timestamptz not null default now()
);

alter table public.categories enable row level security;
create policy "Users can manage their own categories"
    on public.categories for all
    using (auth.uid() = user_id);

create index idx_categories_user_id on public.categories(user_id);

-- -----------------------------------------------
-- Expenses
-- -----------------------------------------------
create table public.expenses (
    id                  uuid primary key default gen_random_uuid(),
    user_id             uuid not null references auth.users(id) on delete cascade,
    category_id         uuid not null references public.categories(id) on delete cascade,
    amount              numeric(12, 2) not null check (amount > 0),
    note                text not null default '',
    date                date not null default current_date,
    is_recurring        boolean not null default false,
    recurring_interval  text check (recurring_interval in ('weekly', 'monthly', 'yearly')),
    created_at          timestamptz not null default now()
);

alter table public.expenses enable row level security;
create policy "Users can manage their own expenses"
    on public.expenses for all
    using (auth.uid() = user_id);

create index idx_expenses_user_id       on public.expenses(user_id);
create index idx_expenses_date          on public.expenses(date);
create index idx_expenses_category_id   on public.expenses(category_id);

-- -----------------------------------------------
-- Savings Goals
-- -----------------------------------------------
create table public.savings_goals (
    id              uuid primary key default gen_random_uuid(),
    user_id         uuid not null references auth.users(id) on delete cascade,
    name            text not null,
    target_amount   numeric(12, 2) not null check (target_amount > 0),
    current_amount  numeric(12, 2) not null default 0 check (current_amount >= 0),
    deadline        date,
    is_completed    boolean not null default false,
    created_at      timestamptz not null default now()
);

alter table public.savings_goals enable row level security;
create policy "Users can manage their own savings goals"
    on public.savings_goals for all
    using (auth.uid() = user_id);

create index idx_savings_goals_user_id on public.savings_goals(user_id);
