-- 1. Enable UUID extension (biasanya default sudah on, tapi untuk jaga-jaga)
create extension if not exists "uuid-ossp";

-- 2. Buat tabel 'users' untuk menyimpan data wajah
create table public.users (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  face_embedding float8[] not null, -- Array of floats (192 dimensi)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Buat tabel 'attendance_logs' untuk riwayat absen
create table public.attendance_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade not null,
  scan_time timestamp with time zone default timezone('utc'::text, now()) not null,
  match_score double precision -- Menyimpan nilai 'Distance' saat verifikasi
);

-- 4. Pengaturan Keamanan (Row Level Security)
-- Karena ini prototype TANPA Login (Anonim), kita buka aksesnya.
-- PERINGATAN: Jangan gunakan setting ini untuk Production!

alter table public.users enable row level security;
alter table public.attendance_logs enable row level security;

create policy "Enable read/write for all" on public.users
for all using (true) with check (true);

create policy "Enable read/write for all" on public.attendance_logs
for all using (true) with check (true);
