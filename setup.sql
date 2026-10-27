-- HelpNearby database setup for Supabase
-- Paste this whole file into Supabase → SQL Editor → New query → Run.

create table if not exists public.resources (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name        text not null check (char_length(name) between 2 and 80),
  category    text not null check (category in ('food','health','mental','housing','education','jobs','legal','tech')),
  description text not null check (char_length(description) between 1 and 300),
  address     text check (char_length(address) <= 160),
  phone       text check (char_length(phone) <= 30),
  languages   text[] not null default '{English}' check (cardinality(languages) <= 12),
  free        boolean not null default true,
  walk_in     boolean not null default false,
  days        int[] not null default '{1,2,3,4,5}' check (days <@ array[0,1,2,3,4,5,6] and cardinality(days) between 1 and 7),
  open_time   text not null default '09:00' check (open_time ~ '^[0-2][0-9]:[0-5][0-9]$'),
  close_time  text not null default '17:00' check (close_time ~ '^[0-2][0-9]:[0-5][0-9]$'),
  lat         double precision check (lat between -90 and 90),
  lng         double precision check (lng between -180 and 180),
  status      text not null default 'pending' check (status in ('pending','approved','rejected')),
  is_sample   boolean not null default false,
  verified_at timestamptz
);

-- Stamp the verification date automatically when a volunteer approves a listing
create or replace function public.stamp_verified() returns trigger language plpgsql as $$
begin
  if new.status = 'approved' and (old.status is distinct from 'approved') then
    new.verified_at := now();
  end if;
  return new;
end $$;
drop trigger if exists trg_stamp_verified on public.resources;
create trigger trg_stamp_verified before update on public.resources
  for each row execute function public.stamp_verified();

-- Security: the public can ONLY read approved listings and ONLY submit new pending ones.
-- Nobody using the public key can approve, edit or delete anything.
alter table public.resources enable row level security;

drop policy if exists "Anyone can read approved listings" on public.resources;
create policy "Anyone can read approved listings" on public.resources
  for select to anon, authenticated using (status = 'approved');

drop policy if exists "Anyone can suggest a listing for review" on public.resources;
create policy "Anyone can suggest a listing for review" on public.resources
  for insert to anon, authenticated
  with check (status = 'pending' and is_sample = false and verified_at is null);

grant select, insert on public.resources to anon, authenticated;

-- Sample listings (fictional, clearly marked as samples in the app)
insert into public.resources (name,category,description,address,phone,languages,free,walk_in,days,open_time,close_time,lat,lng,status,is_sample,verified_at) values
('Northside Community Pantry', 'food', 'Groceries and fresh produce boxes for anyone who needs them. No ID required.', '120 Elm St', '(555) 010-1100', '{"English","Spanish"}', true, true, '{2,4,6}', '10:00', '14:00', 39.9762, -75.1497, 'approved', true, now()),
('Hope Kitchen Free Dinners', 'food', 'Hot sit-down dinner every evening. Families and students welcome.', '48 Market Ave', '(555) 010-1200', '{"English"}', true, true, '{0,1,2,3,4,5,6}', '17:00', '19:30', 39.9461, -75.1668, 'approved', true, now()),
('Campus Fridge Share', 'food', '24/7 community fridge: take what you need, leave what you can.', 'Student Union, ground floor', '', '{"English"}', true, true, '{0,1,2,3,4,5,6}', '00:00', '23:59', 39.9522, -75.1932, 'approved', true, now()),
('Riverside Free Clinic', 'health', 'Primary care, checkups and prescriptions for uninsured adults.', '900 River Rd', '(555) 010-2100', '{"English","Spanish","Vietnamese"}', true, false, '{1,2,3,4,5}', '08:30', '16:30', 39.9389, -75.1795, 'approved', true, now()),
('SmileBright Sliding-Scale Dental', 'health', 'Cleanings and fillings priced by income.', '33 Oak Plaza', '(555) 010-2200', '{"English","Mandarin"}', false, false, '{1,3,5}', '09:00', '17:00', 39.962, -75.142, 'approved', true, now()),
('Teen & Young Adult Counseling Center', 'mental', 'Free short-term counseling for ages 13–24. Same-week appointments.', '210 Pine St, Suite 4', '(555) 010-3100', '{"English","Spanish"}', true, false, '{1,2,3,4,5}', '11:00', '19:00', 39.9502, -75.1453, 'approved', true, now()),
('Open Door Peer Support Drop-in', 'mental', 'Talk with trained peers in a relaxed space. Just show up.', '77 Library Ln', '(555) 010-3200', '{"English","Arabic"}', true, true, '{1,3,6}', '15:00', '20:00', 39.9585, -75.172, 'approved', true, now()),
('Safe Harbor Emergency Shelter', 'housing', 'Emergency beds, showers and meals. Intake open overnight.', '5 Harbor Way', '(555) 010-4100', '{"English","Spanish"}', true, true, '{0,1,2,3,4,5,6}', '00:00', '23:59', 39.933, -75.155, 'approved', true, now()),
('Tenant Help Desk', 'legal', 'Free advice on leases, repairs and eviction notices.', 'City Hall Annex, Rm 12', '(555) 010-5100', '{"English","Spanish","Haitian Creole"}', true, true, '{2,4}', '13:00', '18:00', 39.953, -75.1636, 'approved', true, now()),
('Homework Help Hub', 'education', 'Volunteer tutors for K–12 math, reading and science.', 'Central Library, 2nd floor', '(555) 010-6100', '{"English","Spanish","Mandarin"}', true, true, '{1,2,3,4}', '15:30', '18:30', 39.9599, -75.171, 'approved', true, now()),
('Adult ESL & GED Classes', 'education', 'Evening English and GED prep classes. Childcare available.', 'Lincoln High, Room 108', '(555) 010-6200', '{"English","Spanish","Portuguese"}', true, false, '{1,3}', '18:00', '20:30', 39.9811, -75.1625, 'approved', true, now()),
('Career Launch Center', 'jobs', 'Resume help, mock interviews and job listings.', '400 Main St', '(555) 010-7100', '{"English"}', true, true, '{1,2,3,4,5}', '09:00', '17:00', 39.9475, -75.152, 'approved', true, now()),
('Digital Access Desk', 'tech', 'Free computer use, Wi-Fi, and help signing up for low-cost internet.', 'Central Library, 1st floor', '(555) 010-8100', '{"English","Spanish"}', true, true, '{1,2,3,4,5,6}', '10:00', '20:00', 39.9605, -75.1695, 'approved', true, now()),
('Laptop Loaner Program', 'tech', 'Borrow a laptop for up to 8 weeks for school or job search.', 'Community College, Bldg C', '(555) 010-8200', '{"English"}', true, false, '{1,2,3,4,5}', '09:00', '15:00', 39.99, -75.155, 'approved', true, now());
