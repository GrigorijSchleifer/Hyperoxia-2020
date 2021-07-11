drop materialized view if exists big_query; 
create materialized view big_query_old_kdigo_creat as

(
-- extract first ICU stay
with FirstICUstay as
(
    select a.subject_id,
        a.hadm_id,
        a.icustay_id,
        a.intime,
        a.outtime,
        a.los
    from mimiciii.icustays a
    join
    (
        select hadm_id,min(INTIME) as MinIntime from mimiciii.icustays
        group by hadm_id
    ) b
    on a.hadm_id = b.hadm_id and a.intime = b.MinInTime
)

-- extract hadm_id with ICD9 800-956 for trauma
,ICD9 as
(

    with int_ICD9 as
    (
        with trauma_ICD9 as
        (
            select * from mimiciii.diagnoses_icd
            where ICD9_CODE like '8__'
                    or ICD9_CODE like '8___' 
                    or ICD9_CODE like '8____'
                    or ICD9_CODE like '9__'
                    or ICD9_CODE like '9___' 
                    or ICD9_CODE like '9____'
        )
        select trauma_ICD9.hadm_ID, 
            cast(trauma_ICD9.ICD9_CODE as integer) as int_icd9
        from trauma_ICD9
    )
    select distinct i.hadm_ID
    from int_ICD9 i
    where (i.int_icd9>=800 and i.int_icd9<=956)
        or (i.int_icd9>=8000 and i.int_icd9<=9570) 
        or (i.int_icd9>=80000 and i.int_icd9<=95700)
)

-- extract hadm_id with ICD9 250 for diabetes
,ICD9_diabetes as
(
    select distinct hadm_id, 1 as diabetes from mimiciii.diagnoses_icd
    where icd9_code like '250%'
)

-- extract hadm_id with ICD9 401-405 for hypertension
,ICD9_hypertension as
(
    select distinct hadm_id, 1 as hypertension from mimiciii.diagnoses_icd
    where icd9_code like '401%' 
        or icd9_code like '402%' 
        or icd9_code like '403%' 
        or icd9_code like '404%' 
        or icd9_code like '405%'
)

-- extract hadm_id for chronic lung conditions
,ICD9_chronic_lung_conditions as
(
    select distinct hadm_id, 1 as lung from mimiciii.diagnoses_icd
    where icd9_code like '1623%' 
        or icd9_code like '1624%' 
        or icd9_code like '1625%' 
        or icd9_code like '27702%' 
        or icd9_code like '32723%'
        or icd9_code like '4160%' 
        or icd9_code like '491%' 
        or icd9_code like '492%' 
        or icd9_code like '493%'
        or icd9_code like '494%' 
        or icd9_code like '496%' 
        or icd9_code like '501%' 
        or icd9_code like '510%'
)

-- extract hadm_id for chronic heart problems
,ICD9_chronic_heart_problems as
(
    select distinct hadm_id, 1 as heart
    from
    (
        select hadm_id,icd9_code from mimiciii.diagnoses_icd
        where icd9_code like '393%' 
            or icd9_code like '394%' 
            or icd9_code like '395%' 
            or icd9_code like '396%' 
            or icd9_code like '397%'
            or icd9_code like '398%' 
            or icd9_code like '412%' 
            or icd9_code like '414%' 
            or icd9_code like '416%'
            or icd9_code like '4231%' 
            or icd9_code like '4232%' 
            or icd9_code like '425%' 
            or icd9_code like '426%'
            or icd9_code like '427%' 
            or icd9_code like '428%' 
    ) icd9_temp
    where icd9_code != '428.21'
        and icd9_code != '428.31'
        and icd9_code != '428.41'
)

-- extract from admission table
,admissions as
(
    select subject_id,
        hadm_id,
        admittime,
        dischtime,
        admission_type
    from mimiciii.admissions
)

-- extract sugery from services table
,services as
(
    select subject_id, hadm_id, transfertime
    from mimiciii.services
    where prev_service like '%SURG%' or curr_service like '%SURG%'
)

-- extract patient demographics
,patients as
(
    select subject_id,gender,dob,dod from mimiciii.patients
)

-- extract pao2 from chartevents table
,pao2_mean_24hr as
(
    select icustay_id, avg(valuenum) as mean_pao2
    from
    (
        select c.icustay_id,c.charttime,c.valuenum,i.intime
        from mimiciii.chartevents c
        join mimiciii.icustays i
        on i.icustay_id = c.icustay_id
        where c.itemid in (490,779) 
            and c.valuenum is not null 
            and c.charttime<i.intime + interval '1' day
    ) temp
    group by icustay_id
)

-- extract spo2 from chartevents table
,spo2_mean_24hr as
(
    select icustay_id, avg(valuenum) as mean_spo2 
    from
    (
        select c.icustay_id,c.charttime,c.valuenum,i.intime
        from mimiciii.chartevents c
        join mimiciii.icustays i
        on i.icustay_id = c.icustay_id
        where c.itemid = 646 
            and c.valuenum is not null 
            and c.charttime<i.intime + interval '1' day
    ) temp
    group by icustay_id
)

-- extract creatinine from labevents table
,creatinine_mean_24hr as
(
    select icustay_id, avg(valuenum) as mean_creatinine 
    from
    (
        select i.icustay_id,c.charttime,c.valuenum,i.intime
        from mimiciii.labevents c
        join mimiciii.icustays i
        on i.hadm_id = c.hadm_id
        where c.itemid = 50912 
            and c.valuenum is not null 
            and c.charttime>=i.intime
            and c.charttime<i.intime + interval '1' day
    ) temp
    group by icustay_id
)

-- extract average creatine by days
,creatinine_days as
(
    select cast(icustay_id as integer) as icustay_id,
        day1,day2,day3,day4,day5,day6,day7
    from mimiciii.crosstab(
        'select * from creatinine_7days',
        'select distinct day_no from creatinine_7days') 
    as (icustay_id character varying, "day1" numeric, "day2" numeric, "day3" numeric, "day4" numeric, 
        "day5" numeric, "day6" numeric, "day7" numeric)
)

-- extract has_creatinine from labevents table
,has_creatinine as
(
    select distinct icustay_id, 1 as has_icu_creatinine 
    from
    (
        select i.icustay_id,c.valuenum
        from mimiciii.labevents c
        join mimiciii.icustays i
        on i.hadm_id = c.hadm_id
        where c.itemid = 50912 
            and c.valuenum is not null 
            and c.charttime>=i.intime
            and c.charttime<=i.outtime
    ) temp
)

-- extract has_urine_output
,has_urine_output as
(
    select distinct icustay_id, 1 as has_icu_urine_output from urineoutput
)

-- extract dialysis onset time 
,first_crrtdurations as
(
    select * from crrtdurations where num =1 
)

-- extract fluid intake for the first 24 hour
,fluid_intake_24hr_sum as
(
    select icustay_id, sum(crystalloid_bolus) as fluid_intake_first24hr
    from fluid_intake_24hr
    group by icustay_id
)

-- extract blood transfusion data
,blood_first_24hr as
(

    with blood as
    (
        select icustay_id,charttime as time,amount 
        from mimiciii.inputevents_cv 
        where itemid in (30179, 30104, 42324, 42588, 30001, 30004, 42239, 
                        45020, 43010, 46407, 46612, 46124, 42740, 42186)  

        union    

        select icustay_id,starttime as time,amount 
        from mimiciii.inputevents_mv 
        where itemid in (225168, 227070, 220996, 226368)
    )
    
    select icustay_id, sum(amount) as blood_amount
    from
    (
        select * from
        (
            select f.icustay_id, f.intime, b.time, b.amount   
            from FirstICUstay f
            left join blood b
            on f.icustay_id = b.icustay_id
        ) temp_b1
        where time<=intime+interval '1' day
    ) temp_b2
    group by icustay_id
    
)

-- extract first provider type of spo2
,first_spo2_provider as
(
    with first_spo2_CGID as
    (
        select icustay_id, CGID
        from
        (
            select *, 
                row_number() over (partition by icustay_id 
                    order by charttime) as row_num
            from
            (
                select c.icustay_id,c.charttime,c.CGID,i.intime
                from mimiciii.chartevents c
                join mimiciii.icustays i
                on i.icustay_id = c.icustay_id
                where c.itemid = 646 
                    and c.valuenum is not null 
                    and c.charttime<i.intime + interval '1' day
                order by c.charttime
            ) temp
        ) tt
        where row_num=1
    )
    select spo2_CGID.icustay_id,care.LABEL as provider
    from mimiciii.caregivers care
    join first_spo2_CGID spo2_CGID
    on spo2_CGID.CGID = care.CGID
    
)

-- extract first provider type of pao2
,first_pao2_provider as
(
    with first_pao2_CGID as
    (
        select icustay_id, CGID
        from
        (
            select *, 
                row_number() over (partition by icustay_id 
                    order by charttime) as row_num
            from
            (
                select c.icustay_id,c.charttime,c.CGID,i.intime
                from mimiciii.chartevents c
                join mimiciii.icustays i
                on i.icustay_id = c.icustay_id
                where c.itemid in (490,779)
                    and c.valuenum is not null 
                    and c.charttime<i.intime + interval '1' day
                order by c.charttime
            ) temp
        ) tt
        where row_num=1
    )
    select pao2_CGID.icustay_id,care.LABEL as provider
    from mimiciii.caregivers care
    join first_pao2_CGID pao2_CGID
    on pao2_CGID.CGID = care.CGID
    
)


select *,
    case when transfertime is null then 0
        else 1
    end as SURG
from
(
    select f.subject_id, 
        f.hadm_id, 
        f.icustay_id, 
        f.intime,
        f.outtime,
        f.los,
        
        a.admittime,
        a.dischtime,
        a.admission_type,
        
        s.transfertime,
        
        f.intime-a.admittime as interval,
        case when f.intime-a.admittime < interval '6' hour then 1
            else NULL
        end as transfer_within_6hr,
        
        p.gender,
        p.dod,
        cast(DATE_PART('day', f.intime-p.dob)/365 as integer) as age,
        case when p.dod <= a.dischtime then 1
            else 0
        end as hospital_mortality,
        case when p.dod <= f.outtime then 1
            else 0
        end as icu_mortality,        
        case when p.dod <= a.admittime + interval '30' day then 1
            else 0 
        end as HospMort30day,
        case when p.dod <= a.admittime + interval '1' year then 1
            else 0 
        end as HospMort1yr,
        
        pa.mean_pao2 as mean_pao2_24hr,        
        wp.time_weighted_24hr_pao2 as time_weighted_24hr_pao2,
        
        so.mean_spo2 as mean_spo2_24hr,
        ws.time_weighted_24hr_spo2 as time_weighted_24hr_spo2,
        
        creat.mean_creatinine as mean_creatinine_24hr, 
        
        first_crrt.starttime as crrt_starttime,
        
        creat_days.day1 as mean_creatinine_day1,
        creat_days.day2 as mean_creatinine_day2,
        creat_days.day3 as mean_creatinine_day3,
        creat_days.day4 as mean_creatinine_day4,
        creat_days.day5 as mean_creatinine_day5,
        creat_days.day6 as mean_creatinine_day6,
        creat_days.day7 as mean_creatinine_day7,
        
        has_creat.has_icu_creatinine,
        has_urine.has_icu_urine_output,
        
        kdigo_cr.admcreat,
        kdigo_cr.admcreattime,        
        
        kdigo_48hr.aki_stage_48hr,
        case when kdigo_48hr.aki_stage_48hr >0 then 1
            else 0
        end as aki_48hr,
        
        kdigo_7day.aki_stage_7day,
        case when kdigo_7day.aki_stage_7day >0 then 1
            else 0
        end as aki_7day,
        
        b.blood_amount as transfusion_first_24hr,
        
        lung.lung as has_chronic_lung_conditions,
        heart.heart as has_chronic_heart_problems,
        diabetes.diabetes as has_diabetes,
        hypertension.hypertension as has_hypertension,
        
        p_pro.provider as first_pao2_provider,
        s_pro.provider as first_spo2_provider,
        
        oas.oasis,
        sap.saps,
        sof.sofa,
        
        fi.fluid_intake_first24hr as fluid_intake_first24hr
        
    from FirstICUstay f
    join ICD9 i
    on i.hadm_id = f.hadm_id
    
    join admissions a
    on f.hadm_id = a.hadm_id
    
    join patients p
    on p.subject_id = f.subject_id
    
    left join pao2_mean_24hr pa
    on pa.icustay_id = f.icustay_id
    
    left join time_weighted_pao2 wp
    on wp.icustay_id = f.icustay_id
    
    left join spo2_mean_24hr so
    on so.icustay_id = f.icustay_id
    
    left join time_weighted_spo2 ws
    on ws.icustay_id = f.icustay_id
    
    left join creatinine_mean_24hr creat
    on creat.icustay_id = f.icustay_id  
    
    left join creatinine_days creat_days
    on creat_days.icustay_id = f.icustay_id 
    
    left join has_creatinine has_creat
    on has_creat.icustay_id = f.icustay_id
    -- the kdigo_creat query has no columns admcreat and admcreattime
    -- because the query that created the kdigo_creat view was updated
    -- I saved two views of kdigo_creat, an old one (kdgigo_creat_old) that was created from an older query
    -- and just kdigo_creat that used the new/updated query from github
    -- the kdgigo_creat_old will still have the admcreat and admcreattime and be the dataset used in the course
    left join kdigo_creat_old kdigo_cr
    on kdigo_cr.icustay_id = f.icustay_id
    
    left join has_urine_output has_urine
    on has_urine.icustay_id = f.icustay_id 
    
    left join first_crrtdurations first_crrt
    on first_crrt.icustay_id = f.icustay_id
    
    left join kdigo_stages_48hr kdigo_48hr
    on kdigo_48hr.icustay_id = f.icustay_id
    
    left join kdigo_stages_7day kdigo_7day
    on kdigo_7day.icustay_id = f.icustay_id
    
    left join blood_first_24hr b
    on f.icustay_id=b.icustay_id
    
    left join ICD9_chronic_heart_problems heart
    on heart.hadm_id = f.hadm_id
    
    left join ICD9_chronic_lung_conditions lung
    on lung.hadm_id = f.hadm_id 
    
    left join ICD9_diabetes diabetes
    on diabetes.hadm_id = f.hadm_id
    
    left join ICD9_hypertension hypertension
    on hypertension.hadm_id = f.hadm_id
    
    left join first_pao2_provider p_pro
    on p_pro.icustay_id = f.icustay_id
    
    left join first_spo2_provider s_pro
    on s_pro.icustay_id = f.icustay_id
    
    left join oasis oas
    on oas.icustay_id=f.icustay_id
    
    left join saps sap
    on sap.icustay_id=f.icustay_id
    
    left join sofa sof
    on sof.icustay_id=f.icustay_id
    
    left join fluid_intake_24hr_sum fi
    on fi.icustay_id=f.icustay_id
    
    left join services s
    on f.hadm_id = s.hadm_id and s.transfertime<=f.intime
)temp
)
