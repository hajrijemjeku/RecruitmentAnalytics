use recruitmentanalytics;

-- 1. Confirm row counts
select 'Application table' as tables, 
	    count(*) as rownumber 
from Applications
union all 
select 'Assessments table', 
	    count(*) 
from Assessments
union all
select 'Candidates table' , 
	   count(*)
from Candidates
union all 
select 'Companies table', 
	   count(*) 
from Companies
union all
select 'Departments table', 
	   count(*) 
from Departments
union all 
select 'Interviews table', 
	   count(*) 
from Interviews
union all
select 'Jobs table', 
	   count(*) 
from Jobs
union all 
select 'Offers table', 
	   count(*) 
from Offers
union all
select 'Recruiters table', 
	   count(*) 
from Recruiters

-- 2. Identify potential primary keys
-- Compare total values with distinct values to identify
-- columns that may uniquely identify records.
select 'Candidates PK Check' AS Entity, 
	    count(candidate_id) as Total, 
		count(distinct candidate_id) as DistinctPK 
from Candidates
union all 
select 'Companies PK Check', 
	    count(company_id), 
		count(distinct company_id) 
from Companies
union all 
select 'Jobs PK Check', 
	    count(job_id), 
		count(distinct job_id) 
from Jobs
union all 
select 'Applications PK Check', 
	    count(application_id), 
		count(distinct application_id) 
from Applications
union all
select 'Interviews PK Check', 
	    count(interview_id), 
		count(distinct interview_id) 
from Interviews
union all 
select 'Offers PK Check', 
	    count(offer_id), 
		count(distinct offer_id) 
from Offers;


-- 3. Identify potential foreign-key relationships
-- Compare foreign-key values against the referenced primary-key
-- values to understand how the tables are connected.

select
    'Applications -> Candidates' as relationship,
    count(*) as total_records,
    count(c.candidate_id) as matching_parent_records
from Applications a
left join Candidates c
    on a.candidate_id = c.candidate_id

union all

select
    'Applications -> Jobs',
    count(*),
    count(j.job_id)
from Applications a
left join Jobs j
    on a.job_id = j.job_id

union all

select
    'Applications -> Recruiters',
    count(*),
    count(r.recruiter_id)
from Applications a
left join Recruiters r
    on a.recruiter_id = r.recruiter_id

union all

select
    'Jobs -> Companies',
    count(*),
    count(c.company_id)
from Jobs j
left join Companies c
    on j.company_id = c.company_id

union all

select
    'Jobs -> Departments',
    count(*),
    count(d.department_id)
from Jobs j
left join Departments d
    on j.department_id = d.department_id

union all

select
    'Departments -> Companies',
    count(*),
    count(c.company_id)
from Departments d
left join Companies c
    on d.company_id = c.company_id

union all

select
    'Recruiters -> Companies',
    count(*),
    count(c.company_id)
from Recruiters r
left join Companies c
    on r.company_id = c.company_id

union all

select
    'Interviews -> Applications',
    count(*),
    count(a.application_id)
from Interviews i
left join Applications a
    on i.application_id = a.application_id

union all

select
    'Assessments -> Applications',
    count(*),
    count(a.application_id)
from Assessments ass
left join Applications a
    on ass.application_id = a.application_id

union all

select
    'Offers -> Applications',
    count(*),
    count(a.application_id)
from Offers o
left join Applications a
    on o.application_id = a.application_id;


-- 4. Identify source-data limitations

-- Candidates who applied but have no interview or offer records, or offers without corresponding assessment entries.

-- Offers whose applications have no corresponding assessment record
select 
    o.offer_id,
    o.application_id,
    ass.assessment_id
from dbo.offers o
left join dbo.assessments ass 
    on o.application_id = ass.application_id
where ass.application_id is null;


-- Applications with no corresponding interview record
select a.application_id, a.candidate_id, a.source, a.stage
from applications a
left join interviews i
on a.application_id = i.application_id
where i.application_id is null
order by stage

select 
    count(a.application_id) as total_applications_without_interviews
from dbo.applications a
left join dbo.interviews i on a.application_id = i.application_id
where i.application_id is null;

-- Applications with no corresponding offer record
select a.application_id, a.candidate_id, a.source, a.stage
from applications a
left join offers o
on a.application_id = o.application_id
where o.application_id is null

select 
    count(a.application_id) as total_applications_without_offers
from dbo.applications a
left join dbo.offers o on a.application_id = o.application_id
where o.application_id is null;