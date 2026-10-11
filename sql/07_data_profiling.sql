use RecruitmentAnalytics;
-- Candidate profile
-- Assesses Talent Supply: Summarizes candidate volume, skill diversity, and the distribution of reported work experience. 
--Identifies Skew & Outliers: Comparing the average experience to the minimum and maximum helps spot unexpected outliers (like negative values or unrealistic years of experience) that could skew downstream analytics.
--Informs Segmentation: Understanding skill distribution helps you decide how to group candidates in later funnel analyses.

select count(*) as total_candidates, 
       count(distinct top_skill_area) as distinct_skills,
       min(year_experience) as min_years_exp,
       max(year_experience) as max_years_exp,
       avg(year_experience) as avg_years_exp
from Candidates

select 
    top_skill_area,
    count(*) as candidate_count
from dbo.Candidates
group by top_skill_area
order by candidate_count desc;


-- Applications Profile
-- Total Applications: Count of all submitted applications.
-- Distinct Candidates & Jobs: Number of unique candidates applying (candidate_id) and unique jobs receiving applications (job_id).
-- Source Breakdown: Count of applications per channel (source).
-- Stage Distribution: Count of applications currently sitting in each pipeline stage (stage).

select count(*) as total_applications, 
       count(distinct job_id) as distinct_jobs,
       count(distinct candidate_id) as distinct_candidates
from Applications

select source, 
       count(*) as application_count,
       cast(100.0 * count(*) / sum(count(*)) over () as decimal(5,2)) as percentage_of_applications
from Applications
group by source
order by application_count desc;

select stage, 
       count(*) as application_count,
       cast(100.0 * count(*) / sum(count(*)) over () as decimal(5,2)) as percentage_of_applications
from Applications
group by stage
order by application_count desc;



-- Assessments Profile
-- WHY? Shows how many candidates reach tests and if scoring is balanced (not too easy/hard).
-- WHY? which tests are given most often so managers know where their team spends the most time grading.
-- WHY? Checks test pass rates to catch pipeline bottlenecks or weak quality gates.

-- How many total assessments exist, and how many unique applications have taken an assessment?
-- What types of assessments exist (e.g., Coding, Behavioral, Technical), and how are candidates distributed across them?
-- What are the Minimum, Maximum, and Average scores across assessments?
-- What is the breakdown and percentage of Pass vs. Fail outcomes?

select
    count(*) as total_assessments,
    count(distinct application_id) as assessed_applications,
    min(score) as min_score,
    max(score) as max_score,
    cast(avg(score) as decimal(10,2)) as avg_score
from Assessments;

select 
    assessment_type,
    count(*) as assessment_count
from dbo.Assessments
group by assessment_type
order by assessment_count desc;

select 
    result,
    count(*) as assessment_count,
    cast(100.0 * count(*) / sum(count(*)) over () as decimal(5,2)) as percentage_of_assessments
from Assessments
group by result
order by assessment_count desc;


-- Interviews Profile
-- WHY? Confirms interview_id uniqueness (no duplicates) and shows how many total applications made it to the interview stage.
-- WHY? Identifies which interview stages (screening, technical, behavioral, final) are conducted most often and where candidate volume sits.
-- WHY? Measures pass vs. fail vs. canceled rates to show where candidates drop off during interviews.
-- WHY? Shows how many rounds candidates typically go through (e.g., 1 round vs. 3+ rounds).

-- Count total rows, unique interview_id, unique application_id.
-- Group by round_name to get row counts and percentages of the total.
-- Group by result to understand interview outcomes.
-- Count how many interviews each application_id has, then group by that count.

select count(*) total_interviews, 
       count(distinct interview_id) as unique_interviews,
       count(distinct application_id) as unique_applications
from interviews

select round_name, count(*) as counted
from interviews
group by round_name

select result, count(*) as counted
from interviews
group by result

select 
    interviews_per_app,
    count(*) as application_count
from (
    select application_id, count(*) as interviews_per_app
    from dbo.interviews
    group by application_id
) sub
group by interviews_per_app
order by interviews_per_app;


-- Departments Profile
-- WHY? Counts total rows, unique department_id, unique company_id, and checks for any NULL values to confirm department_id is a valid Primary Key.
-- WHY? Groups by department_name to get row counts and percentages of the total, helping us see the distribution of department types and spot spelling inconsistencies.
-- WHY? Counts how many departments each company_id has, then groups by that count to see the distribution of company sizes/structures across the dataset.
-- WHY? Checks if the exact same department_name was entered more than once under the same company_id.

-- Primary Key Uniqueness & NULL Audit
-- Department Name Frequency
-- Departments Count per Company
-- Logical Duplicate Check (Company + Department Name)


select count(*) total_count, 
       count(distinct department_id) unique_dept,
       count(distinct company_id) unique_comp,
       sum(case when department_id is null then 1 else 0 end) as null_dept_id,
       sum(case when company_id is null then 1 else 0 end) as null_comp_id 
from Departments

select department_name, count(*) as dept_name_count
from Departments
group by department_name
order by dept_name_count desc

select
    dept_count,
    count(*) as company_count
from (
    select
        company_id,
        count(*) as dept_count
    from dbo.Departments
    group by company_id
) sub
group by dept_count
order by dept_count;

select
    company_id,
    count(*) as departments_number
from dbo.Departments
group by company_id
order by departments_number desc;


select company_id, department_name, count(*) as duplicate_count
from departments
group by company_id, department_name
having count(*) > 1
order by company_id



-- Companies Profile
-- WHY? Confirms company_id uniqueness (no duplicates), counts total companies, and verifies there are no missing values in key profile columns.
-- WHY? Identifies the industry distribution across companies and shows the percentage share of each industry sector in the dataset.
-- WHY? Shows the breakdown of company sizes (e.g., startup, mid-size, enterprise) and their relative proportions.
-- WHY? Identifies top headquarters locations (cities) and spots potential spelling/formatting variations across geographic locations.
-- WHY? Detects exact company duplicates by checking for identical combination entries across company_name, industry, company_size, and hq_city.

-- Count total rows, unique company_id, unique company_name, and check for NULL values across all columns.
-- Group by industry to get row counts and percentages of the total.
-- Group by company_size to get row counts and percentages of the total.
-- Group by hq_city to get row counts and percentages of the total (ordered by highest count).
-- Group by company_name, industry, company_size, and hq_city to find duplicate company profiles where count is greater than 1.



select count(*) as total_rows,
       count(distinct company_id) as unique_company,
       count(distinct company_name) as unique_companyname,
       sum( case when company_id is null then 1 else 0 end) as null_companyid,
       sum( case when company_name is null then 1 else 0 end) as null_companyname,
       sum( case when industry is null then 1 else 0 end) as null_industry,
       sum( case when company_size is null then 1 else 0 end) as null_companysize,      
       sum( case when hq_city is null then 1 else 0 end) as null_hq_city
from companies

select company_name, count(*) as count_company
from companies 
group by company_name 
order by count_company desc;

select industry, count(*) as count_industry
from companies
group by industry 
order by count_industry

select company_size, count(*) as count_size
from companies
group by company_size 
order by count_size


select hq_city, count(*) as count_city
from companies
group by hq_city 
order by count_city desc

select company_name, industry, company_size, hq_city, count(*) as count_duplicates
from companies 
group by company_name, industry, company_size, hq_city
having count(*) > 1
order by count_duplicates desc


-- Jobs Profile
-- WHY? Confirms job_id uniqueness (Primary Key validation), verifies valid company_id and department_id linkages, and detects any missing values in critical job fields.
-- WHY? Identifies the distribution of job titles, role families, career levels, location types (e.g., Onsite, Hybrid, Remote), employment types, and current job statuses across the dataset.
-- WHY? Captures the earliest and latest job posting dates to establish the overall recruitment timeline and verify date ranges.
-- WHY? Audits compensation data to spot anomalies such as negative salary figures, or inverted salary ranges where salary_low > salary_high.
-- WHY? Grouping across key job fields detects identical job postings that might be duplicate entries submitted under the same company and department.

-- Count total rows, unique job_id, unique company_id, unique department_id, and check for NULL values across all columns.
-- Group by role_family, level, location_type, employment_type, and status to understand their distributions.
-- Find MIN(posted_at) and MAX(posted_at) to establish the posting time frame.
-- Check salary metrics: MIN and MAX for salary_low and salary_high, count of negative values, and count where salary_low > salary_high.
-- Group by company_id, department_id, title, level, location_type, and posted_at having COUNT(*) > 1 to catch duplicate job postings.

select count(*) as totalrows,
       count(distinct job_id) as unique_jobid,
       count(distinct company_id) as unique_companyid,
       count(distinct department_id) as unique_departmentid,
       sum(case when job_id is null then 1 else 0 end) as null_jobid,
       sum(case when company_id is null then 1 else 0 end) as null_companyid,
       sum(case when posted_at is null then 1 else 0 end) as null_postedat,
       sum(case when title is null then 1 else 0 end) as null_title,
       sum(case when role_family is null then 1 else 0 end) as null_rolefamily,
       sum(case when level is null then 1 else 0 end) as null_level,
       sum(case when location_type is null then 1 else 0 end) as null_locationtype,
       sum(case when employment_type is null then 1 else 0 end) as null_employmenttype,
       sum(case when salary_low is null then 1 else 0 end) as null_salarylow,
       sum(case when salary_high is null then 1 else 0 end) as null_salaryhigh,
       sum(case when status is null then 1 else 0 end) as null_status,
       sum(case when department_id is null then 1 else 0 end) as null_departmentid
from jobs 

select role_family, count(*) as job_count
from dbo.Jobs
group by role_family
order by job_count desc;

select level, count(*) as job_count
from dbo.Jobs
group by level
order by job_count desc;

select location_type, count(*) as job_count
from dbo.Jobs
group by location_type
order by job_count desc;

select employment_type, count(*) as job_count
from dbo.Jobs
group by employment_type
order by job_count desc;

select status, count(*) as job_count
from dbo.Jobs
group by status
order by job_count desc;


select 'min postedat' as 'column', min(posted_at) as 'value'
from jobs
union all
select 'max postedat', max(posted_at)
from jobs


select 'min salarylow' as 'column', min(salary_low) as 'value'
from jobs
union all
select 'max salarylow', max(salary_low)
from jobs
union all
select 'min salaryhigh', min(salary_high)
from jobs 
union all
select 'max salaryhigh', max(salary_high)
from jobs 
union all 
select 'negative values', count(*)
from jobs
where salary_low < 0 or salary_high < 0
union all
select 'salarylow > salaryhigh', count(*)
from jobs
where salary_low > salary_high



select company_id, department_id, title, level, location_type, posted_at, count(*) as counted
from jobs
group by company_id, department_id, title, level, location_type, posted_at
having count(*) > 1



-- Offers Profile
-- WHY? Confirms offer_id uniqueness (Primary Key validation), verifies valid application_id linkages (Foreign Key), and detects any missing values across all offer fields.
-- WHY? Analyzes overall offer outcomes to calculate conversion rates (offers accepted vs. rejected/pending) and checks the consistency of accepted_at dates (ensuring accepted offers have an acceptance date and rejected ones do not).
-- WHY? Establishes the offer timeline by identifying the earliest and latest offer dates, as well as checking for date logic defects (e.g., accepted_at < offered_at).
-- WHY? Audits financial offer data to detect anomalies such as zero or negative base salaries, unexpected outliers, or invalid compensation entries.
-- WHY? Groups by application_id to ensure candidates do not have multiple conflicting offer records for a single application entry.

-- Count total rows, unique offer_id, unique application_id, and check for NULL values across all columns.
-- Group by accepted status to get row counts and percentages, and check for date consistency (accepted = 1 with NULL accepted_at OR accepted = 0 with non-NULL accepted_at).
-- Find MIN(offered_at), MAX(offered_at), MIN(accepted_at), MAX(accepted_at), and count instances where accepted_at < offered_at.
-- Check salary metrics: MIN(base_salary), MAX(base_salary), AVG(base_salary), and count of zero or negative values (base_salary <= 0).

select count(*) as totalrows,
       count(distinct offer_id) as unique_offerid,
       count(distinct application_id) as unique_applicationid,
       sum(case when offer_id is null then 1 else 0 end) as null_offerid,
       sum(case when application_id is null then 1 else 0 end) as null_applicationid,
       sum(case when offered_at is null then 1 else 0 end) as null_offeredat,
       sum(case when base_salary is null then 1 else 0 end) as null_basesalary,
       sum(case when accepted is null then 1 else 0 end) as null_accepted,
       sum(case when accepted_at is null then 1 else 0 end) as null_acceptedat
from offers 

select accepted, 
       count(*) as counted,
       cast(100.0 * count(*) / sum(count(*)) over () as decimal(5,2)) as percentage_of_offers
from offers
group by accepted 
order by accepted;


select 'min offeredat' as 'column', min(offered_at) as 'value'
from offers
union all
select 'max offeredat', max(offered_at)
from offers
union all
select 'min acceptedat', min(accepted_at)
from offers 
union all
select 'max acceptedat', max(accepted_at)
from offers 

select 'offeredat > acceptedat', count(*)
from offers
where offered_at > accepted_at

select 
    min(base_salary) as min_base_salary,
    max(base_salary) as max_base_salary,
    cast(avg(base_salary) as decimal(12,2)) as avg_base_salary,
    sum(case when base_salary <= 0 then 1 else 0 end) as non_positive_salary_count
from Offers;



-- WHY? Confirms recruiter_id uniqueness (Primary Key validation), verifies valid company_id linkages (Foreign Key), and detects any missing values across all recruiter attributes.
-- WHY? Profiles recruiter status based on termination_date and counts active versus terminated recruiters.
-- WHY? Establishes the hiring and termination historical timeline while checking for date logic defects (e.g., termination_date < hire_date).
-- WHY? Evaluates resource distribution by grouping by company_id to identify staffing imbalances or organizations with disproportionate recruiter coverage.

-- Count total rows, unique recruiter_id, unique company_id, and check for NULL values across all recruiter columns.
-- Group by employment status (Active vs. Terminated) based on termination_date to get headcount totals and percentage of the total pool.
-- Find MIN(hire_date), MAX(hire_date), MIN(termination_date), MAX(termination_date), and count instances where termination_date < hire_date.
-- Group by company_id to count assigned recruiters per organization and order by headcount descending.

select count(*) as totalrows,
       count(distinct recruiter_id) as unique_recruiterid,
       count(distinct company_id) as unique_companyid,
       sum(case when recruiter_id is null then 1 else 0 end) as null_recruiterid,
       sum(case when company_id is null then 1 else 0 end) as null_companyid,
       sum(case when recruiter_name is null then 1 else 0 end) as null_recruitername,
       sum(case when hire_date is null then 1 else 0 end) as null_hiredate,
       sum(case when termination_date is null then 1 else 0 end) as null_terminationdate
from recruiters 

select
    case
        when termination_date is null then 'Active'
        else 'Terminated'
    end as recruiter_status,
    count(*) as recruiter_count
from dbo.Recruiters
group by
    case
        when termination_date is null then 'Active'
        else 'Terminated'
    end
order by recruiter_count desc;


select 'min hiredate' as 'column', min(hire_date) as 'value'
from recruiters
union all
select 'max hiredate', max(hire_date)
from recruiters
union all
select 'min terminationdate', min(termination_date)
from recruiters
union all
select 'max terminationdate', max(termination_date)
from recruiters

select 'terminationdate < hiredate', count(*)
from recruiters 
where hire_date > termination_date

select recruiters_count, 
       count(recruiters_count) as 'company_count' 
from (
        select company_id, count(*) as 'recruiters_count'
        from recruiters 
        group by company_id 
     ) sub
group by recruiters_count 
order by count(recruiters_count) desc 


-- Overall Date Coverage

select 'Jobs' as event_type, min(posted_at) as earliest_date, max(posted_at) as latest_date
from Jobs
union all
select 'Applications', min(applied_at), max(applied_at)
from Applications
union all
select 'Assessments', min(assessment_date), max(assessment_date)
from Assessments
union all
select 'Interviews', min(scheduled_at), max(scheduled_at)
from Interviews
union all
select 'Offers', min(offered_at), max(offered_at)
from Offers
union all
select 'Accepted Offers', min(accepted_at), max(accepted_at)
from Offers
where accepted_at is not null
union all
select 'Recruiters', min(hire_date), max(hire_date)
from Recruiters;







-- check categorical values across all tables
select 
    'applications.source' as field_name, 
    source as category_value, 
    count(*) as total_records
from dbo.applications 
group by source

union all

select 
    'applications.stage' as field_name, 
    stage as category_value, 
    count(*) as total_records
from dbo.applications 
group by stage

union all

select 
    'jobs.status' as field_name, 
    status as category_value, 
    count(*) as total_records
from dbo.jobs 
group by status

union all

select 
    'jobs.role_family' as field_name, 
    role_family as category_value, 
    count(*) as total_records
from dbo.jobs 
group by role_family

union all

select 
    'jobs.location_type' as field_name, 
    location_type as category_value, 
    count(*) as total_records
from dbo.jobs 
group by location_type

union all

select 
    'jobs.employment_type' as field_name, 
    employment_type as category_value, 
    count(*) as total_records
from dbo.jobs 
group by employment_type

union all

select 
    'jobs.level' as field_name, 
    level as category_value, 
    count(*) as total_records
from dbo.jobs 
group by level

union all

select 
    'assessments.result' as field_name, 
    result as category_value, 
    count(*) as total_records
from dbo.Assessments 
group by result

union all

select 
    'candidates.current_city' as field_name, 
    current_city as category_value, 
    count(*) as total_records
from dbo.candidates 
group by current_city

union all

select 
    'companies.hq_city' as field_name, 
    hq_city as category_value, 
    count(*) as total_records
from dbo.companies 
group by hq_city

union all

select 
    'departments.department_name' as field_name, 
    department_name as category_value, 
    count(*) as total_records
from dbo.departments 
group by department_name

union all

select 
    'interviews.round_name' as field_name, 
    round_name as category_value, 
    count(*) as total_records
from dbo.interviews 
group by round_name

union all

select 
    'interviews.result' as field_name, 
    result as category_value, 
    count(*) as total_records
from dbo.interviews 
group by result

order by field_name, category_value;