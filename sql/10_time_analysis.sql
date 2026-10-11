-- This phase is critical because speed in recruitment can influence candidate conversion.
-- High time-to-hire or long delays between stages can contribute to candidate drop-off or candidates accepting competing offers.

-- When are applications happening?
-- When are interviews happening?
-- How long does each recruitment stage take?
-- Is the recruitment process becoming faster or slower over time?


-- Recruitment Activity Over Time
-- Shows how recruitment activity changes month by month across applications, assessments, interviews, offers, and accepted offers.


select
    year_month,
    sum(applications) as applications,
    sum(assessments) as assessments,
    sum(interviews) as interviews,
    sum(offers) as offers,
    sum(accepted_offers) as accepted_offers
from
(
    select 
        format(applied_at, 'yyyy-MM') as year_month,
        count(distinct application_id) as applications,
        0 as assessments,
        0 as interviews,
        0 as offers,
        0 as accepted_offers
    from dbo.applications
    group by format(applied_at, 'yyyy-MM')

    union all

    select 
        format(assessment_date, 'yyyy-MM') as year_month,
        0 as applications,
        count(distinct assessment_id) as assessments,
        0 as interviews,
        0 as offers,
        0 as accepted_offers
    from dbo.assessments
    group by format(assessment_date, 'yyyy-MM')

    union all

    select 
        format(scheduled_at, 'yyyy-MM') as year_month,
        0 as applications,
        0 as assessments,
        count(distinct interview_id) as interviews,
        0 as offers,
        0 as accepted_offers
    from dbo.interviews
    group by format(scheduled_at, 'yyyy-MM')

    union all

    select 
        format(offered_at, 'yyyy-MM') as year_month,
        0 as applications,
        0 as assessments,
        0 as interviews,
        count(distinct offer_id) as offers,
        count(case when accepted = 1 then 1 end) as accepted_offers
    from dbo.offers
    group by format(offered_at, 'yyyy-MM')
) x
group by year_month
order by year_month desc;


-- Time-to-Hire Trend Over Time
-- Measures whether the average time from application to accepted offer is increasing or decreasing across years.
select
    year(a.applied_at) as application_year,
    count(distinct o.offer_id) as total_hires,
    round(avg(cast(datediff(day, a.applied_at, o.accepted_at) as float)), 2) as avg_time_to_hire_days,
    min(datediff(day, a.applied_at, o.accepted_at)) as min_time_to_hire_days,
    max(datediff(day, a.applied_at, o.accepted_at)) as max_time_to_hire_days
from applications a
inner join offers o
    on a.application_id = o.application_id
where o.accepted = 1
      and o.accepted_at is not null
group by year(a.applied_at)
order by application_year desc;



