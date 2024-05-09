USE vaccine;
-- The measles-containing-vaccine second-dose (MCV2) is a routine vaccine that is recommended to be given to children between 15 and 18 months of age.
-- the below table contains the data with % of childrens in countries over years who got meningitis vaccine.

SELECT * FROM share_of_children_vaccinated_with_mcv2;

-- The DPT3 vaccine is a combination vaccine that protects against three common infectious diseases: diphtheria, tetanus, and pertussis (whooping cough).
-- The below table contains information about the % of childrens in countries over years who got dpt3 vaccine.
SELECT * FROM share_of_children_immunized_dtp3;

-- In year 2024, how many lives were saved in every continent from different diseases using vaccines.
SELECT * FROM lives_saved_vaccines;

-- Infant Mortality rates with and without vaccines from year 1974 to year 2024
SELECT * FROM infant_mortality_vaccines;

-- From year 1919 to year 2019 over different countries, how many death were caused by vaccine preventable disease for both sex and all ages
SELECT *
FROM
    deaths_caused_by_vaccine_preventable_diseases_over_time;

-- Cumulative numbers of lives saved from year 1974 to 2024 over different continent
SELECT * FROM cumulative_lives_saved_vaccination;

-- Finding out the total number of lives saved across coutries and globally
-- Cumulative does not include cumulative over years, it means cumulative of every country in that region
SELECT entity, MAX(`Lives saved`) AS max_lives_saved
FROM
    cumulative_lives_saved_vaccination
WHERE
    entity <> 'World'
GROUP BY
    Entity
ORDER BY max_lives_saved DESC;

-- In each continent , you have initial year and you have final year of measurement.
-- So, you can have a slider which chooses the range of year and draws a graph of lives
-- saved, absolute change and relative change.
DROP table temp_table;

-- Creating a temporary table for storing absolute change between years
CREATE TEMPORARY TABLE temp_table AS
WITH
    cte AS (
        SELECT
            Entity,
            `Year`,
            `Lives saved`,
            LAG(`Lives saved`, 1, 0) OVER (
                PARTITION BY
                    `Entity`
                ORDER BY `Lives saved` ASC
            ) AS prev_year_lives_saved
        FROM
            cumulative_lives_saved_vaccination
    )
SELECT
    Entity,
    `Year`,
    `Lives saved`,
    prev_year_lives_saved,
    `Lives saved` - prev_year_lives_saved AS absolute_change
FROM cte;
-- Fiding relative change in the lives saved
SELECT
    Entity,
    `Year`,
    `absolute_change` AS absolute_change_lives_saved,
    ifnull(
        absolute_change * 100 / prev_year_lives_saved,
        0
    ) AS relative_change_lives_saved
FROM temp_table;

------------------------------------------------------------------------
-- Looking at from the total population affected how much percentage is covered by which disease
with
    total_death_per_country_by_vaccine_preventable_disease as (
        select
            Entity,
            sum(
                `Deaths - Diphtheria - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_diptheria,
            sum(
                `Deaths - Tetanus - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_tetanus,
            sum(
                `Deaths - Measles - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_measles,
            sum(
                `Deaths - Tuberculosis - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_tb,
            sum(
                `Deaths - Yellow fever - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_yellow_fever,
            sum(
                `Deaths - Whooping cough - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_whooping_cough,
            sum(
                `Deaths - Acute hepatitis B - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_hepatitisB,
            sum(
                `Deaths - Meningitis - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_meningitis,
            sum(
                `Deaths - Cervical cancer - Sex: Both - Age: All Ages (Number)`
            ) as total_death_by_cervical_cancer
        from
            deaths_caused_by_vaccine_preventable_diseases_over_time
        group by
            Entity
        order by Entity
    ),
    total_death_by_vaccine_preventable_disease as (
        select
            Entity,
            total_death_by_diptheria + total_death_by_tetanus + total_death_by_measles + total_death_by_tb + total_death_by_yellow_fever + total_death_by_whooping_cough + total_death_by_hepatitisB + total_death_by_meningitis + total_death_by_cervical_cancer as all_total_death
        from
            total_death_per_country_by_vaccine_preventable_disease
    )
select
    t1.Entity,
    round(
        t1.total_death_by_diptheria * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_diptheria',
    round(
        t1.total_death_by_tetanus * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_tetanus',
    round(
        t1.total_death_by_measles * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_measles',
    round(
        t1.total_death_by_tb * 100 / t2.all_total_death,
        2
    ) as '%_affected _TB',
    round(
        t1.total_death_by_yellow_fever * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_yellow_fever',
    round(
        t1.total_death_by_whooping_cough * 100 / t2.all_total_death,
        2
    ) as '%_affected_by _cough',
    round(
        t1.total_death_by_hepatitisB * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_hepatitisB',
    round(
        t1.total_death_by_meningitis * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_meningitis',
    round(
        t1.total_death_by_cervical_cancer * 100 / t2.all_total_death,
        2
    ) as '%_affected_by_cervical_cancer'
from
    total_death_per_country_by_vaccine_preventable_disease as t1
    inner join total_death_by_vaccine_preventable_disease as t2 on t1.Entity = t2.Entity