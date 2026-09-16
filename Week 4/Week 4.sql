-- show databases;
-- create database analyst_lab;
-- use analyst_lab;

-- Dataset Review
select count(*) as total_appointments
from analyst_lab.healthconnect_appointment_data had;

select count(*) as patient_id
from analyst_lab.healthconnect_appointment_data had;

select appointment_outcome, 
	count(*) as appointmeents, 
	round(count(*)*100/ sum(count(*)) Over(), 2) as outcome_rate_pct
from analyst_lab.healthconnect_appointment_data had 
group by appointment_outcome
order by appointmeents desc;

-- missinng/ Null Values

Select 
	sum(case when appointment_id is null then 1 else 0 end)
As missing_appointment_id,
	sum(case when patient_id is null then 1 else 0 end) 
As missing_patient_id, 
	sum(case when gender is null then 1 else 0 end)
As missing_gender, 
	sum(case when age is null then 1 else 0 end)
As missing_age,
	sum(case when appointment_type is null then 1 else 0 end)
As missing_appointment_type,
 	SUM(CASE WHEN booking_date IS NULL THEN 1 ELSE 0 END) 
 AS missing_booking_date,
 	SUM(CASE WHEN appointment_date IS NULL THEN 1 ELSE 0 END) 
 AS missing_appointment_date,
 	SUM(CASE WHEN appointment_day IS NULL THEN 1 ELSE 0 END) 
 AS missing_appointment_day,
 	SUM(CASE WHEN appointment_time IS NULL THEN 1 ELSE 0 END) 
 AS missing_appointment_time,
 	SUM(CASE WHEN booking_lead_days IS NULL THEN 1 ELSE 0 END) 
 AS missing_booking_lead_days,
 	SUM(CASE WHEN previous_appointments IS NULL THEN 1 ELSE 0 END) 
 AS missing_previous_appointments,
 	SUM(CASE WHEN previous_no_shows IS NULL THEN 1 ELSE 0 END) 
 AS missing_previous_no_shows,
 	SUM(CASE WHEN reminder_sent IS NULL THEN 1 ELSE 0 END) 
 AS missing_reminder_sent,
 	SUM(CASE WHEN reminder_channel IS NULL THEN 1 ELSE 0 END) 
 AS missing_reminder_channel,
 	SUM(CASE WHEN distance_to_clinic_km IS NULL THEN 1 ELSE 0 END) 
 AS missing_distance,
	SUM(CASE WHEN waiting_time_minutes IS NULL THEN 1 ELSE 0 END) 
AS missing_waiting_time,
	SUM(CASE WHEN appointment_outcome IS NULL THEN 1 ELSE 0 END) 
AS missing_outcome
from analyst_lab.healthconnect_appointment_data had ;

-- Duplicate Appointmnet ID's
select had.appointment_id, count(*) as duplicate_count
from analyst_lab.healthconnect_appointment_data had 
group by had.appointment_id 
having count(*) > 1
order by duplicate_count desc;

-- Logical Quality Checks
Select Count(*) bookin_after_appointment
From analyst_lab.healthconnect_appointment_data had 
where booking_date > appointment_date;

select count(*) as lead_day_mismatch
from analyst_lab.healthconnect_appointment_data had 
where had.booking_date > had.appointment_date ;

select count(*) as appointment_day_mismatch
from analyst_lab.healthconnect_appointment_data had 
where LOWER(trim(appointment_day)) <> lower(DAYNAME(appointment_date));

select count(*) as previous_no_show_mismatch
from analyst_lab.healthconnect_appointment_data had 
where had.previous_no_shows > had.previous_appointments;

select count(*) as channel_present_withno_reminder
from analyst_lab.healthconnect_appointment_data had 
where had.reminder_sent = "Yes" and had.reminder_channel is null;

select count(*) as channel_missing_when_reminder_yes
from analyst_lab.healthconnect_appointment_data had 
where had.reminder_sent = "Yes" and had.reminder_channel is null;

-- Core KPIs

select 
	round (100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='Attended' THEN 1 ELSE 0 END)/COUNT(*),2) AS attendance_rate_pct,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='Cancelled' THEN 1 ELSE 0 END)/COUNT(*),2) AS cancellation_rate_pct,
 ROUND(100.0 * SUM(CASE WHEN reminder_sent='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS reminder_coverage_pct
FROM analyst_lab.healthconnect_appointment_data had;

-- APPOINTMENT TYPE
SELECT appointment_type, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had 
GROUP BY appointment_type
ORDER BY no_show_rate_pct DESC;

-- REMINDER STATUS
SELECT reminder_sent, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had
GROUP BY reminder_sent
ORDER BY no_show_rate_pct DESC;

-- PREVIOUS NO-SHOW HISTORY
SELECT previous_no_shows, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had
GROUP BY previous_no_shows
ORDER BY previous_no_shows;

-- BOOKING LEAD-TIME BANDS
SELECT
 CASE
   WHEN booking_lead_days=0 THEN '0'
   WHEN booking_lead_days BETWEEN 1 AND 3 THEN '1-3'
   WHEN booking_lead_days BETWEEN 4 AND 7 THEN '4-7'
   WHEN booking_lead_days BETWEEN 8 AND 14 THEN '8-14'
   WHEN booking_lead_days BETWEEN 15 AND 30 THEN '15-30'
   ELSE '31+'
 END AS lead_band,
 COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had
GROUP BY lead_band
ORDER BY CASE lead_band
 WHEN '0' THEN 1 WHEN '1-3' THEN 2 WHEN '4-7' THEN 3
 WHEN '8-14' THEN 4 WHEN '15-30' THEN 5 WHEN '31+' THEN 6 END;

-- DAY / TIME / AGE GROUP
SELECT appointment_day, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had GROUP BY appointment_day ORDER BY no_show_rate_pct DESC;

SELECT appointment_time, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had GROUP BY appointment_time ORDER BY no_show_rate_pct DESC;

SELECT age_group, COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had GROUP BY age_group ORDER BY no_show_rate_pct DESC;

-- DISTANCE BANDS
SELECT
 CASE
   WHEN distance_to_clinic_km <= 5 THEN '0-5 km'
   WHEN distance_to_clinic_km <= 10 THEN '6-10 km'
   WHEN distance_to_clinic_km <= 20 THEN '11-20 km'
   WHEN distance_to_clinic_km <= 50 THEN '21-50 km'
   ELSE '50+ km'
 END AS distance_band,
 COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had
WHERE distance_to_clinic_km IS NOT NULL
GROUP BY distance_band
ORDER BY no_show_rate_pct DESC;

-- WAITING-TIME BANDS
SELECT
 CASE
   WHEN waiting_time_minutes <= 15 THEN '0-15'
   WHEN waiting_time_minutes <= 30 THEN '16-30'
   WHEN waiting_time_minutes <= 45 THEN '31-45'
   WHEN waiting_time_minutes <= 60 THEN '46-60'
   ELSE '61+'
 END AS waiting_band,
 COUNT(*) AS appointments,
 ROUND(100.0 * SUM(CASE WHEN appointment_outcome='No-Show' THEN 1 ELSE 0 END)/COUNT(*),2) AS no_show_rate_pct
FROM analyst_lab.healthconnect_appointment_data had
WHERE waiting_time_minutes IS NOT NULL
GROUP BY waiting_band
ORDER BY no_show_rate_pct DESC;
