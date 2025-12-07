-- 1. Menambahkan kolom image_url (Jalankan jika belum)
ALTER TABLE users ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE attendance_logs ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Membuat Storage Bucket 'avatars'
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- 3. Mengatur Permission / Policy untuk Bucket 'avatars'
-- Mengizinkan akses Publik (SELECT/VIEW)
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'avatars' );

-- Mengizinkan Upload oleh siapa saja (Untuk keperluan Prototype/Testing tanpa Auth User)
-- Di Production, sebaiknya batasi hanya user terautentikasi (auth.uid() = owner)
create policy "Public Upload"
  on storage.objects for insert
  with check ( bucket_id = 'avatars' );
