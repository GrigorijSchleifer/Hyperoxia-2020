-- create time_weighted_pao2 temporary view

drop materialized view if exists time_weighted_pao2; 
create materialized view time_weighted_pao2 as
-- create temporary view time_weighted_pao2 as
(
    
    with subset_pao2 as
    (
        select c.icustay_id,c.charttime,c.valuenum,i.intime
        from mimiciii.chartevents c
        join mimiciii.icustays i
        on i.icustay_id = c.icustay_id
        where c.itemid in (490,779) 
            and c.valuenum is not null 
            and c.charttime<i.intime + interval '1' day    
        order by c.icustay_id,c.charttime
    )

    , pao2_time as
    (
        select icustay_id,
            max(charttime)-min(charttime) as TotalTimeDiff,
            count(*) as count
        from subset_pao2
        group by icustay_id
    )

    select icustay_id, 
        case when count>1 then
            total_sum/TotalInter 
            else total_sum
        end as time_weighted_24hr_pao2 
    from
    (
        select icustay_id, sum(temp_sum) as total_sum, avg(totaltime) as TotalInter, avg(count) as count
        from
        (
            select *,
                case when rn>1 then
                        (beforevalue+valuenum)*TimeDiff/2
                    else valuenum 
                end as temp_sum
                

            from    
            (
                select *,
                    case when rn>1 then
                            cast(DATE_PART('day', difftime) as integer)*24*60*60+
                            cast(DATE_PART('hour', difftime) as integer)*60*60+
                            cast(DATE_PART('minute', difftime) as integer)*60+
                            cast(DATE_PART('second', difftime) as integer)
                        else 0 
                    end as TimeDiff
                    
                from
                    
                (      
                    

                    select *,charttime-beforetime as difftime 

                    from
                    (
                        select *, 

                            lag(charttime) over (order by icustay_id,charttime) as beforetime,
                            lag(valuenum) over (order by icustay_id,charttime) as beforevalue,
                            cast(DATE_PART('day', TotalTimeDiff) as integer)*24*60*60+
                            cast(DATE_PART('hour', TotalTimeDiff) as integer)*60*60+
                            cast(DATE_PART('minute', TotalTimeDiff) as integer)*60+
                            cast(DATE_PART('second', TotalTimeDiff) as integer) as TotalTime
                        from
                        (
                            select c.icustay_id,c.charttime,c.valuenum,c.intime,
                                row_number() over (partition by c.icustay_id order by c.charttime asc) as rn,
                                s.TotalTimeDiff,s.count
                            from subset_pao2 c
                            left join pao2_time s
                            on c.icustay_id=s.icustay_id

                        ) temp1
--                        where count=1 or rn>1
                    ) temp2
                    where (charttime-beforetime<interval '1' day  and charttime>beforetime) or count=1

                ) temp22
            ) temp3
        ) temp4
    group by icustay_id
    
    ) temp5
 
    
)
