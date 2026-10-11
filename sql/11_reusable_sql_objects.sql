/*
    11_reusable_sql_objects.sql

    Contains reusable database objects created for the
    RecruitmentAnalytics project:
    - Stored procedures
    - Views
    - Indexes
*/


-- =========================================================
-- 1. STORED PROCEDURES
-- =========================================================

-- Candidate Recruitment Progression
-- Shows the recruitment progression of a specific candidate:
-- applications, interviewed applications, and offered applications.

create or alter procedure dbo.sp_candidate_recruitment_progression
    @candidate_id int
as
begin

    select c.candidate_id, 
           c.candidate_name, 
           count(distinct a.application_id) as applications,
           count(distinct i.application_id) as interviewed_applications, 
           count(distinct o.application_id) as offered_applications
    from candidates c
    inner join applications a
        on c.candidate_id = a.candidate_id
    left join interviews i
        on a.application_id = i.application_id
    left join offers o
        on a.application_id = o.application_id
    where c.candidate_id = @candidate_id
    group by c.candidate_id, c.candidate_name;

end;
-- example execution
exec sp_candidate_recruitment_progression @candidate_id = 157;



-- =========================================================
-- 2. VIEWS
-- =========================================================

-- Company Recruitment Performance
-- Compares recruitment activity across organizations.
-- Helps identify companies with high hiring demand
-- or high recruitment volume.

create or alter view dbo.vw_company_recruitment_performance
as
select c.company_id, 
       c.company_name,
       count(distinct j.job_id) as total_jobs,
       count(distinct a.application_id) as total_applications,
       count(distinct i.interview_id) as total_interviews,
       count(distinct o.offer_id) as total_offers,
       count(distinct case when o.accepted = 1 then o.offer_id end) as accepted_offers,
       round(cast(count(distinct case when o.accepted = 1 then o.offer_id end) as float) / nullif(count(distinct o.offer_id), 0) * 100, 2) as pct_accepted_offers
from companies c
left join jobs j
    on c.company_id = j.company_id
left join applications a
    on j.job_id = a.job_id
left join interviews i
    on a.application_id = i.application_id
left join offers o
    on a.application_id = o.application_id
group by c.company_id, c.company_name;

-- Example usage
select *
from dbo.vw_company_recruitment_performance
order by total_jobs desc;



-- =========================================================
-- 3. INDEXES
-- =========================================================

-- Supports joins and filtering by candidate_id in Applications.

create index idx_applications_candidate_id
on dbo.applications(candidate_id);
