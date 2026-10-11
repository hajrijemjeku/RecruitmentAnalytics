-- Interviews
-- How many applications reached an interview?
-- How many interviews were conducted in total?
-- What were the interview results?
-- How many interview rounds did applications have?

select result,
	   count(i.interview_id) as total_interviews,
	   count(distinct i.application_id) as interviewed_applications
from interviews i 
group by result 
order by total_interviews desc



-- Assessments
-- How many applications have assessments?
-- How many assessment records exist?
-- How many assessments passed vs failed?
-- What is the overall pass rate?


-- Assessment result breakdown
select 
       result,
       count(*) as total_assessments,
       count(distinct application_id) as applications_with_assessment
from dbo.assessments
group by result
order by total_assessments desc;

-- Overall assessment pass rate
select 
       count(*) as total_assessments,
       sum(case when result = 'pass' then 1 else 0 end) as passed_assessments,
       sum(case when result = 'fail' then 1 else 0 end) as failed_assessments,
       round(
           cast(sum(case when result = 'pass' then 1 else 0 end) as float)
           / nullif(count(*), 0) * 100,
           2
       ) as assessment_pass_rate
from dbo.assessments;


-- Accepted Offers
-- How many offers were accepted?
-- How many were not accepted?
-- What percentage of offers were accepted?

select count(case when accepted = 1 then offer_id end) as accepted_offers,
       count(case when accepted = 0 then offer_id end) as not_accepted_offers,
       count(offer_id) as total_offers,
       round(convert(float, count(case when accepted = 1 then offer_id end)) / nullif(count(distinct offer_id),0) * 100, 2) as pct_accepted_offers
from offers;

    

-- function to calculate accepted offer percentage

create or alter function dbo.fn_accepted_offer_percentage
(
    @accepted_offers int,
    @total_offers int
)
returns decimal(5,2)
as
begin

    return round(cast(@accepted_offers as float) / nullif(@total_offers, 0) * 100, 2);

end;

select count(case when accepted = 1 then offer_id end) as accepted_offers,
       count(case when accepted = 0 then offer_id end) as not_accepted_offers,
       count(offer_id) as total_offers,
       dbo.fn_accepted_offer_percentage(count(case when accepted = 1 then offer_id end),count(distinct offer_id)) as pct_accepted_offers
from offers;


-- Conversion Rates
-- Application → Assessment
-- Assessment → Interview
-- Interview → Offer
-- Offer → Acceptance


-- Calculate the total count of distinct application_ids at each stage:
-- Total applications (dbo.applications)
-- Total candidates who completed an assessment (dbo.assessments)
-- Total candidates who had an interview (dbo.interviews)
-- Total candidates who received an offer (dbo.offers)
-- Total candidates who accepted an offer (o.accepted = 1 in dbo.offers)
-- Calculate the conversion percentage for each consecutive step:
-- Application -> Assessment Rate:(Assessed \ Applications) * 100
-- Assessment -> Interview Rate: (Interviewed \ Assessed) * 100
-- Interview -> Offer Rate: (Offered \ Interviewed) * 100
-- Offer -> Acceptance Rate: (Accepted \ Offered) * 100
-- Overall Funnel Yield: (Accepted \ Applications) * 100


-- conversion rates using temporary table

drop table if exists #recruitmentfunnel;

create table #recruitmentfunnel
(
    total_applications int,
    total_assessments int,
    total_interviews int,
    total_offers int,
    accepted_offers int
);


insert into #recruitmentfunnel
(
    total_applications,
    total_assessments,
    total_interviews,
    total_offers,
    accepted_offers
)
select 
    count(distinct a.application_id),
    count(distinct ass.application_id),
    count(distinct i.application_id),
    count(distinct o.application_id),
    count(distinct case when o.accepted = 1 then o.application_id end)
from dbo.applications a
left join dbo.assessments ass
    on a.application_id = ass.application_id
left join dbo.interviews i
    on a.application_id = i.application_id
left join dbo.offers o
    on a.application_id = o.application_id;



select total_applications,
       total_assessments,
       total_interviews,
       total_offers,
       accepted_offers,
       round(cast(total_assessments as float) / nullif(total_applications, 0) * 100, 2) as pct_assessed_applications,
       round(cast(total_interviews as float) / nullif(total_assessments, 0) * 100, 2) as pct_interviewed_assessed,
       round(cast(total_offers as float) / nullif(total_interviews, 0) * 100, 2) as pct_offered_interviews,
       round(cast(accepted_offers as float) / nullif(total_offers, 0) * 100, 2) as pct_accepted_offers,
       round(cast(accepted_offers as float) / nullif(total_applications, 0) * 100, 2) as pct_accepted_applications
from #recruitmentfunnel;



-- Funnel Drop-off
-- How many applications disappear between each observable stage?
-- Goal: Measure the candidate loss (drop-off) at each stage to identify where in the pipeline you lose the largest volume of applicants.
-- Using the total candidate counts from each stage (Applications, Assessed, Interviewed, Offered, Accepted), calculate the lost candidate volume between stages:
-- Applications Lost Before Assessment: Applications - Assessed
-- Assessments Lost Before Interview: Assessed - Interviewed
-- Interviews Lost Before Offer: Interviewed - Offered
-- Offers Rejected/Lost: Offered - Accepted
-- Calculate the Drop-Off Rate (%) at each stage:
-- App Drop-Off: ((Applications - Assessed) / Applications) * 100
-- Assessment Drop-Off: ((Assessed - Interviewed) / Assessed) * 100
-- Interview Drop-Off: ((Interviewed - Offered) / Interviewed) * 100
-- Offer Rejection: ((Offered - Accepted) / Offered) * 100

 with cte_dropoff as (
        select 
            count(distinct a.application_id) as total_applications,
            count(distinct ass.application_id) as total_assessments,
            count(distinct i.application_id) as total_interviews,
            count(distinct o.application_id) as total_offers,
            count(distinct case when o.accepted = 1 then o.application_id end) as accepted_offers,
            (count(distinct a.application_id) - count(distinct ass.application_id)) as lost_applications,
            (count(distinct ass.application_id) - count(distinct i.application_id)) as lost_assessments,
            (count(distinct i.application_id) - count(distinct o.application_id)) as lost_interviews,
            (count(distinct o.application_id) - count(distinct case when o.accepted = 1 then o.offer_id end)) as lost_offers
        from applications a
        left join assessments ass
            on a.application_id = ass.application_id
        left join interviews i
            on a.application_id = i.application_id
        left join offers o
            on a.application_id = o.application_id
    )
    select 
        total_applications,
        total_assessments,
        total_interviews,
        total_offers,
        accepted_offers,
        lost_applications,
        lost_assessments,
        lost_interviews,
        lost_offers,
    
        -- stage-by-stage drop-off percentages
        round(cast(lost_applications as float) / nullif(total_applications, 0) * 100, 2) as app_dropoff_pct,
        round(cast(lost_assessments as float) / nullif(total_assessments, 0) * 100, 2) as assessment_dropoff_pct,
        round(cast(lost_interviews as float) / nullif(total_interviews, 0) * 100, 2) as interview_dropoff_pct,
        round(cast(lost_offers as float) / nullif(total_offers, 0) * 100, 2) as offer_rejection_pct
    from cte_dropoff;



-- Bottleneck Identification
-- We want to identify the stage with the largest measurable reduction in candidate volume.
-- WHY?
-- Identifies the recruitment stage with the largest observable candidate-volume drop.
-- This creates a starting point for deeper business investigation.
-- The result is descriptive and does not by itself prove why the bottleneck exists.


with cte_bottleneck as (
    select 
        count(distinct a.application_id) as total_apps,
        count(distinct ass.application_id) as total_assessments,
        count(distinct i.application_id) as total_interviews,
        count(distinct o.application_id) as total_offers,
        count(distinct case when o.accepted = 1 then o.application_id end) as total_accepted
    from dbo.applications a
    left join dbo.assessments ass on a.application_id = ass.application_id
    left join dbo.interviews i on a.application_id = i.application_id
    left join dbo.offers o on a.application_id = o.application_id

)
select '1.Application to Assessment' as stage_transition,
       total_apps as starting_count,
       total_assessments as progressing_count,
       (total_apps - total_assessments) as dropoff_count,
       cast((total_apps - total_assessments) * 100.0 / nullif(total_apps, 0) as decimal(5,2)) as dropoff_rate
from cte_bottleneck
union all
select '2.Assessment to Interview',
       total_assessments,
       total_interviews,
       (total_assessments - total_interviews),
       cast((total_assessments - total_interviews) * 100.0 / nullif(total_assessments, 0) as decimal(5,2))
from cte_bottleneck
union all
select '3.Interview to Offer',
       total_interviews,
       total_offers,
       (total_interviews - total_offers),
       cast((total_interviews - total_offers) * 100.0 / nullif(total_interviews, 0) as decimal(5,2))
from cte_bottleneck
union all
select '4.Offer to Acceptance',
       total_offers,
       total_accepted,
       (total_offers - total_accepted),
       cast((total_offers - total_accepted) * 100.0 / nullif(total_offers, 0) as decimal(5,2))
from cte_bottleneck
order by dropoff_rate desc;


