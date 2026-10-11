use RecruitmentAnalytics;
-- 1. NULL and Missing-Value Analysis

-- Candidates table
select 
    sum(case when candidate_id is null then 1 else 0 end) as null_candidate_id,
    sum(case when candidate_name is null or trim(candidate_name) = '' then 1 else 0 end) as missing_name,
    sum(case when year_experience is null then 1 else 0 end) as null_year_experience,
    sum(case when top_skill_area is null or trim(top_skill_area) = '' then 1 else 0 end) as missing_top_skill_area,
    sum(case when summary is null or trim(summary) = '' then 1 else 0 end) as missing_summary
from dbo.candidates;

-- Applications table
select
    sum(case when application_id is null then 1 else 0 end) as null_application_id,
    sum(case when job_id is null then 1 else 0 end) as null_job_id,
    sum(case when recruiter_id is null then 1 else 0 end) as null_recruiter_id,
    sum(case when candidate_id is null then 1 else 0 end) as null_candidate_id,
    sum(case when applied_at is null then 1 else 0 end) as missing_applied_at,
    sum(case when source is null or trim(source) = '' then 1 else 0 end) as missing_source,
    sum(case when stage is null or trim(stage) = '' then 1 else 0 end) as missing_stage,
    sum(case when score is null then 1 else 0 end) as missing_score
from dbo.Applications

-- Companies table
select 
    sum(case when company_id is null then 1 else 0 end) as null_company_id,
    sum(case when company_name is null or trim(company_name) = '' then 1 else 0 end) as missing_company_name,
    sum(case when industry is null or trim(industry) = '' then 1 else 0 end) as missing_industry,
    sum(case when company_size is null or trim(company_size) = '' then 1 else 0 end) as missing_company_size,
    sum(case when hq_city is null or trim(hq_city) = '' then 1 else 0 end) as missing_hq_city
from dbo.companies;

-- Interviews table
select 
    sum(case when interview_id is null then 1 else 0 end) as null_interview_id,
    sum(case when application_id is null then 1 else 0 end) as null_application_id,
    sum(case when scheduled_at is null then 1 else 0 end) as null_scheduled_at,
    sum(case when round_name is null or trim(round_name) = '' then 1 else 0 end) as missing_round_name,
    sum(case when result is null or trim(result) = '' then 1 else 0 end) as missing_result
from dbo.interviews;

-- Jobs table
select 
    sum(case when job_id is null then 1 else 0 end) as null_job_id,
    sum(case when company_id is null then 1 else 0 end) as null_company_id,
    sum(case when department_id is null then 1 else 0 end) as null_department_id,
    sum(case when title is null or trim(title) = '' then 1 else 0 end) as missing_title,
    sum(case when level is null or trim(level) = '' then 1 else 0 end) as missing_level,
    sum(case when location_type is null or trim(location_type) = '' then 1 else 0 end) as missing_location_type,
    sum(case when employment_type is null or trim(employment_type) = '' then 1 else 0 end) as missing_employment_type,
    sum(case when role_family is null or trim(role_family) = '' then 1 else 0 end) as missing_role_family,
    sum(case when salary_low is null then 1 else 0 end) as null_salary_low,
    sum(case when salary_high is null then 1 else 0 end) as null_salary_high,
    sum(case when posted_at is null then 1 else 0 end) as null_posted_at,
    sum(case when status is null or trim(status) = '' then 1 else 0 end) as missing_status
from dbo.jobs;

-- Offers table
select 
    sum(case when offer_id is null then 1 else 0 end) as null_offer_id,
    sum(case when application_id is null then 1 else 0 end) as null_application_id,
    sum(case when offered_at is null then 1 else 0 end) as null_offered_at,
    sum(case when base_salary is null then 1 else 0 end) as null_base_salary,
    sum(case when accepted is null then 1 else 0 end) as null_accepted,
    sum(case when accepted_at is null then 1 else 0 end) as null_accepted_at
from dbo.offers;

-- Departments table
select 
    sum(case when department_id is null then 1 else 0 end) as null_department_id,
    sum(case when company_id is null then 1 else 0 end) as null_company_id,
    sum(case when department_name is null or trim(department_name) = '' then 1 else 0 end) as missing_department_name
from dbo.departments;

-- Recruiters table
select 
    sum(case when recruiter_id is null then 1 else 0 end) as null_recruiter_id,
    sum(case when company_id is null then 1 else 0 end) as null_company_id,
    sum(case when recruiter_name is null or trim(recruiter_name) = '' then 1 else 0 end) as missing_recruiter_name,
    sum(case when hire_date is null then 1 else 0 end) as null_hire_date,
    sum(case when termination_date is null then 1 else 0 end) as null_termination_date
from dbo.recruiters;




-- 2. Duplicate and Uniqueness Checks

-- Applications table
select application_id, count(*) as duplicate_count
from Applications
group by application_id
having count(*) > 1

-- Assessments table
select assessment_id, count(*) as duplicate_count
from Assessments
group by assessment_id
having count(*) > 1

-- Candidates table
select candidate_id, count(*) as duplicate_count
from candidates
group by candidate_id
having count(*) > 1

-- Companies table
select company_id, count(*) as duplicate_count
from Companies
group by company_id
having count(*) > 1

-- Departments table
select department_id, count(*) as duplicate_count
from Departments
group by department_id
having count(*) > 1

-- Interviews table
select interview_id, count(*) as duplicate_count
from Interviews
group by interview_id
having count(*) > 1

-- Jobs table
select job_id, count(*) as duplicate_count
from Jobs
group by job_id
having count(*) > 1

-- Offers table
select offer_id, count(*) as duplicate_count
from Offers
group by offer_id
having count(*) > 1

-- Recruiters table
select recruiter_id, count(*) as duplicate_count
from Recruiters
group by recruiter_id
having count(*) > 1


-- Check for multiple applications from the same candidate to the same job.
-- These records may indicate duplicate applications or legitimate re-applications.
select candidate_id, job_id, count(*) as applications_per_job
from dbo.applications
group by candidate_id, job_id
having count(*) > 1;

-- Check for applications associated with multiple offer records.
-- Multiple offers may indicate duplicate records or legitimate offer revisions.
select application_id, count(*) as offers_per_application
from dbo.offers
group by application_id
having count(*) > 1;

-- Check for potential duplicate candidate profiles
-- Same candidate name, skill area, and summary may indicate duplicate records.
select candidate_name, top_skill_area, summary, count(*) as potential_duplicate_count
from Candidates
group by candidate_name, top_skill_area, summary
having count(*) > 1;

-- check for potential duplicate company profiles
-- identical company attributes may indicate duplicate records.
select company_name, industry, company_size, hq_city,  count(*) as potential_duplicate_count
from dbo.companies
group by  company_name, industry, company_size, hq_city
having count(*) > 1;


-- Check for potentially duplicated interview records
-- based on application, scheduled time, round, and result.
select application_id, 
       scheduled_at, 
       round_name, 
       result, 
       count(*) as duplicate_count
from Interviews
group by 
       application_id, 
       scheduled_at, 
       round_name, 
       result
having count(*) > 1
order by duplicate_count desc


-- 3. Date and Timeline Anomalies

-- Timeline Anomalies
-- Identifies recruitment events occurring in an impossible chronological order.
select 'accepted before offered' as check_type, count(*) as issue_count
from offers
where accepted_at is not null
and offered_at > accepted_at
union all
-- 2. Interview scheduled before Candidate applied
select 'interview before application', count(*)
from applications a
inner join interviews i
on a.application_id = i.application_id
where a.applied_at > i.scheduled_at
union all
-- 3. Application submitted before Job was posted
select 'application before job posting', count(*)
from applications a
inner join jobs j
on a.job_id = j.job_id  
where j.posted_at > a.applied_at
union all
-- 4. Offers before Application submitted
select 'offers before application submitted', count(*)
from Applications a
join offers o
on a.application_id = o.application_id
where a.applied_at > o.offered_at




-- 4. Business Rule and Funnel Consistency

-- Applications marked 'Offer' in Stage, but missing an Offer record

select a.application_id, a.job_id, a.stage, o.offer_id, o.application_id
from applications a
left join offers o
on a.application_id = o.application_id
where o.offer_id is null and a.stage = 'offer'

-- Offer marked accepted = 1, but missing accepted_at timestamp
select *
from offers
where accepted = 1 and accepted_at is null

-- Offer marked as not accepted, but an acceptance timestamp exists.
select *
from offers
where accepted = 0
  and accepted_at is not null;


-- 5. Recruiter Timeline Validation

-- Checking how many applications were managed by a recruiter before that recruiter’s recorded hire_date

select *
from applications a
inner join recruiters r
on a.recruiter_id = r.recruiter_id
where r.hire_date > a.applied_at

-- Checking for applications managed by a recruiter after the recruiter's recorded termination date.
select
    a.application_id,
    a.recruiter_id,
    a.applied_at,
    r.termination_date
from dbo.Applications a
inner join dbo.Recruiters r
    on a.recruiter_id = r.recruiter_id
where r.termination_date is not null
  and a.applied_at > r.termination_date;


-- 6. Blank-Space Analysis / Text Consistency
select 'Unwanted spaces in candidate name or skill' as check_type, count(*) as issue_count
from dbo.Candidates
where candidate_name <> trim(candidate_name) 
   or top_skill_area <> trim(top_skill_area)

union all

select 'Unwanted spaces in jobs title or role family', count(*)
from dbo.Jobs
where title <> trim(title) 
   or role_family <> trim(role_family);


-- 7. Categorical Value Validation
select 'Invalid Application Stages' as check_type, count(*) as issue_count
from dbo.Applications
where stage not in ('interview', 'screened', 'applied', 'offer')

union all

select 'Invalid Job Location Types', count(*)
from dbo.Jobs
where location_type not in ('onsite', 'hybrid', 'remote');


-- 8. Numerical Validation

-- Years of work experience cannot be negative
select 'Negative Work Experience' as 'check_type', count(*) as 'issue_count' 
from candidates
where year_experience < 0

union all

-- Salary range should not be negative
select 'Inverted Job Salary Ranges', count(*)
from jobs
where salary_low >  salary_high 
or salary_low < 0 
or salary_high < 0

union all

-- Offer base salary should not be negative.
select 'Negative Offer Base Salary', count(*)
from offers 
where base_salary < 0

union all

-- Assessment scores should fall within a valid bounded scale (0 to 100).
select 'Score Out Of Bounds (0-100)', count(*)
from Assessments
where score < 0 
or score > 100



-- 9. Referential Integrity Checks

select
    'Jobs without valid company' AS check_type,
    count(*) AS issue_count
from dbo.Jobs j
left join dbo.Companies c
    on j.company_id = c.company_id
where c.company_id is null

union all

select
    'Jobs without valid department',
    count(*)
from dbo.Jobs j
left join dbo.Departments d
    on j.department_id = d.department_id
where d.department_id is null

union all

select
    'Applications without valid job',
    count(*)
from dbo.Applications a
left join dbo.Jobs j
    on a.job_id = j.job_id
where j.job_id is null

union all

select
    'Applications without valid candidate',
    count(*)
from dbo.Applications a
left join dbo.Candidates c
    on a.candidate_id = c.candidate_id
where c.candidate_id is null

union all

select
    'Applications without valid recruiter',
    count(*)
from dbo.Applications a
left join dbo.Recruiters r
    on a.recruiter_id = r.recruiter_id
where r.recruiter_id is null

union all

select
    'Interviews without valid application',
    count(*)
from dbo.Interviews i
left join dbo.Applications a
    on i.application_id = a.application_id
where a.application_id is null

union all

select
    'Assessments without valid application',
    count(*)
from dbo.Assessments ass
left join dbo.Applications a
    on ass.application_id = a.application_id
where a.application_id is null

union all

select
    'Offers without valid application',
    count(*)
from dbo.Offers o
left join dbo.Applications a
    on o.application_id = a.application_id
where a.application_id is null

union all

select
    'Departments without valid company',
    count(*)
from dbo.Departments d
left join dbo.Companies c
    on d.company_id = c.company_id
where c.company_id is null

union all

select
    'Recruiters without valid company',
    count(*)
from dbo.Recruiters r
left join dbo.Companies c
    on r.company_id = c.company_id
where c.company_id is null;


