use RecruitmentAnalytics;
-- What is the overall application-to-interview progression?
-- What is the application-to-offer progression?
-- What is the offer acceptance rate?
-- WHY?
-- Establishes the overall scale of recruitment activity.
-- Provides the baseline KPIs that later analyses can be compared against.
-- Helps management understand the size of the recruitment pipeline.



-- What percentage of interviewed candidates receive a job offer?
-- If 100 people are interviewed, but only 2 get offers, interviewers might be spending too much time talking to unqualified candidates.

select count(distinct a.application_id) as total_applications,
        count(distinct i.application_id) as interviewed_applications,
        count(distinct o.application_id) as offered_applications,
        round(cast(count(distinct o.application_id) as float) / count(distinct i.application_id) * 100,2) as pct_offered_interviews,
        round(cast(count(distinct i.application_id) as float) / count(distinct a.application_id) * 100,2) as pct_intervewed_applications,
        round(cast(count(distinct o.application_id) as float) / count(distinct a.application_id) * 100,2) as pct_offered_applications
from applications a
left join interviews i
on a.application_id = i.application_id
left join offers o
on a.application_id = o.application_id  



-- What is the offer acceptance rate?
-- A low acceptance rate usually points to salary offers below market rate, superior competing offers, or poor candidate experience late in the process.
-- Knowing your acceptance rate helps recruiters determine how many total offers need to be extended to hit hiring targets.
select 
    count(offer_id) as total_offers,
    sum(case when accepted = 1 then 1 else 0 end) as accepted_offers,
    round(cast(sum(case when accepted = 1 then 1 else 0 end) as float) / count(offer_id) * 100, 2) as offer_acceptance_rate_pct
from dbo.offers;

-- Candidate Analysis
-- How much experience do candidates have?
-- Which skill areas are most common?
-- How many applications does each candidate submit?
-- Which candidates have submitted the most applications?
-- Candidate-level recruitment progression
-- Shows how many applications each candidate submitted and how many progressed to interviews and offers
-- WHY?
-- Helps understand the candidate pool and identify differences in candidate engagement
-- and progression through the recruitment process.

select year_experience,
       count(*) as candidate_count
from candidates
group by year_experience
order by year_experience desc;

select top 10
       top_skill_area,
       count(*) as candidate_count
from candidates
group by top_skill_area
order by candidate_count desc;

select top 10 c.candidate_id, 
       c.candidate_name, 
       count(a.application_id) as application_count
from applications a
inner join candidates c
    on a.candidate_id = c.candidate_id
group by c.candidate_id, c.candidate_name 
order by application_count desc

-- Which candidates have progressed to interviews?
-- Which candidates have received offers?

select c.candidate_id, 
       c.candidate_name, 
       count(distinct a.application_id) as applications,
       count(distinct i.application_id) as interviewed_applications, 
       count(distinct o.application_id) as offered_applications
from Candidates c
inner join applications a
    on c.candidate_id = a.candidate_id
left join interviews i
on a.application_id = i.application_id
left join offers o
    on a.application_id = o.application_id
group by c.candidate_id, c.candidate_name
order by interviewed_applications desc;



-- Department Analysis
-- Which departments have the most jobs? JOBS
-- Which receive the most applications? APPLICATIONS
-- Which produce the most interviews? INTERVIEWS 
-- Which produce the most offers? OFFERS
-- WHY?
-- Compares recruitment volume and candidate progression across departments.
-- Helps identify departments with high hiring demand and different recruitment outcomes.

select d.department_name,
       count(distinct j.job_id) as total_jobs,
       count(distinct a.application_id) as total_applications,
       count(distinct i.interview_id) as total_interviews,
       count(distinct o.offer_id) as total_offers,
       count(distinct case when o.accepted = 1 then o.offer_id end) as accepted_offers
from departments d
left join jobs j
    on d.department_id = j.department_id
left join applications a
    on j.job_id = a.job_id
left join interviews i
    on a.application_id = i.application_id
left join offers o
    on a.application_id = o.application_id
group by d.department_name
order by total_jobs desc


-- Job Analysis
-- Which roles attract the most applications? APPLICATIONS
-- Which role families receive the most applications? JOBS
-- Which levels attract the most candidates? CANDIDATES
-- Which location types receive the most applications?
-- Which jobs have no applications?
-- Identifies open roles that have received no candidate interest.
-- WHY?
-- Identifies which job characteristics attract candidate interest.
-- Helps recruitment teams understand demand across roles, seniority and work arrangements.

    
select top 10 j.title,
       count(distinct j.job_id) as total_jobs,
       count(distinct a.application_id) as total_applications,
       count(distinct c.candidate_id) as total_candidates
from jobs j
left join applications a
    on j.job_id = a.job_id
left join candidates c
    on a.candidate_id = c.candidate_id
group by j.title
order by total_applications desc
    

select j.role_family,
       count(distinct j.job_id) as total_jobs,
       count(a.application_id) as total_applications,
       count(c.candidate_id) as total_candidates
from jobs j
left join applications a
    on j.job_id = a.job_id
left join candidates c
    on a.candidate_id = c.candidate_id
group by j.role_family
order by total_applications desc


select j.level,
    count(distinct j.job_id) as total_jobs,
    count(distinct a.candidate_id) as total_candidates,
    count(distinct a.application_id) as total_applications
from dbo.jobs j
join dbo.applications a on j.job_id = a.job_id
group by j.level
order by total_candidates desc;


select j.location_type,
       count(distinct j.job_id) as total_jobs,
       count(distinct a.application_id) as total_applications,
       count(distinct c.candidate_id) as total_candidates
from jobs j
left join applications a
    on j.job_id = a.job_id
left join candidates c
    on a.candidate_id = c.candidate_id
group by j.location_type
order by total_applications desc


-- which jobs have no applications
select  j.job_id,
        j.title,
        j.role_family,
        j.posted_at
from jobs j

EXCEPT

select  j.job_id,
        j.title,
        j.role_family,
        j.posted_at
from jobs j
inner join applications a
    on j.job_id = a.job_id;


-- Source Analysis
-- How many applications come from each source?
-- Which source generates interviews?
-- Which source generates offers?
-- Which source has the highest offer rate?
-- WHY?
-- Compares recruitment channels based on candidate volume and progression.
-- This helps evaluate the observable performance of different acquisition sources.

select a.source,
       count(distinct a.application_id) as total_applications,
       count(distinct i.application_id) as total_interviews,
       count(distinct o.application_id) as total_offers,
       count(distinct case when o.accepted = 1 then o.application_id end) as accepted_offers,
       round(cast(count(distinct o.application_id) as float) / nullif(count(distinct a.application_id), 0) * 100, 2) as pct_offer_rate,
       round(cast(count(distinct case when o.accepted = 1 then o.application_id end) as float) / nullif(count(distinct o.application_id), 0) * 100, 2) as pct_accepted_offers
from applications a
left join interviews i
    on a.application_id = i.application_id
left join offers o
    on a.application_id = o.application_id
group by a.source
order by total_applications desc



-- Recruiter analysis
-- How many applications does each recruiter manage?
-- How many interviews are associated with those applications?
-- How many offers?
-- How many accepted offers?
-- Which recruiters handle the highest application workload?
-- WHY?
-- Examines recruiter workload and associated recruitment outcomes.
-- Helps identify differences in workload and candidate progression across recruiters.

select r.recruiter_id, r.recruiter_name, r.company_id,
       count(distinct a.application_id) as total_applications,
       count(distinct i.interview_id) as total_interviews,
       count(distinct o.offer_id) as total_offers,
       count(distinct case when o.accepted = 1 then o.offer_id end) as accepted_offers
from recruiters r
left join applications a
    on r.recruiter_id = a.recruiter_id
left join interviews i
    on a.application_id = i.application_id
left join offers o
    on a.application_id = o.application_id
group by r.recruiter_id, r.recruiter_name, r.company_id
order by total_applications desc

-- Which recruiters handle the highest application workload?
select top 10 r.recruiter_id, r.recruiter_name,
       count(distinct a.application_id) as applications_managed
from recruiters r
inner join applications a
    on r.recruiter_id = a.recruiter_id
group by r.recruiter_id, r.recruiter_name
order by applications_managed desc


-- Interview Analysis
-- How many interviews occur per round?
-- What are the interview outcomes?
-- Which rounds have the most candidates?
-- How many interviews does an application typically have?
-- WHY?
-- Examines the interview stage of the recruitment process.
-- Helps identify candidate progression and potential drop-off across interview rounds.

select i.round_name,
       count(i.interview_id) as total_interviews
from interviews i
group by round_name
order by total_interviews desc


select i.result, 
       count(i.interview_id) as total_interviews
from interviews i
group by result


-- Shows how many applications go through one, two, three or more interview records.
select interview_count, 
       count(*) as application_count
from (
    select application_id,
           count(*) as interview_count
    from interviews 
    group by application_id
) sub
group by interview_count
order by application_count desc


-- Assessment Analysis
-- Which assessment types are used most?
-- What are the average scores?
-- What percentage passes?
-- How does performance vary by assessment type?
-- WHY?
-- Evaluates assessment activity and candidate performance.
-- Helps identify assessment types associated with different score and pass patterns.

select a.assessment_type,
       count(*) as total_assessments,
       avg(a.score) as avg_score,
       min(a.score) as min_score,
       max(a.score) as max_score,
       sum( case when result = 'Pass' then 1 else 0 end) as 'passed_assessments',
       sum( case when result = 'Fail' then 1 else 0 end) as 'failed_assessments',
       round(cast(sum( case when result = 'Pass' then 1 else 0 end) as float) / nullif(count(*), 0) * 100,2) as pct_pass
from Assessments a
group by a.assessment_type
order by total_assessments desc


-- Offer Analysis
-- What is the offer volume?
-- How many offers were accepted?
-- What are the salary statistics?
-- How do offers differ by acceptance status?
-- WHY?
-- Examines the final observable stage of the recruitment process.
-- Helps understand offer outcomes and compensation patterns.


select case 
            when o.accepted = 1 then 'accepted'
            when o.accepted = 0 then 'not accepted'
            else 'unknown'
       end as offer_status,
       count(*) as total_offers,
       sum(case when accepted = 1 then 1 else 0 end) as accepted_offers,
       avg(o.base_salary) as avg_offered_salary,
       min(o.base_salary) as min_offered_salary,
       max(o.base_salary) as max_offered_salary
from offers o
group by accepted


