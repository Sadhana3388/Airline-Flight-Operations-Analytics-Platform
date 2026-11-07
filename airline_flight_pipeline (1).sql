
CREATE OR REFRESH STREAMING TABLE bronze_airline_flights AS

SELECT
    *,
    _metadata.file_name AS source_file,
    current_timestamp() AS loaded_at

FROM STREAM read_files(
    '/Volumes/aviation_catalog/flights/raw_files/',
    format => 'csv',
    header => true
);


-- Silver_flights_clean

CREATE OR REFRESH MATERIALIZED VIEW silver_flights_clean AS

WITH cleaned AS (
    SELECT
        flight_id,
        flight_number,

        COALESCE(
            INITCAP(TRIM(airline)),
            'Unknown'
        ) AS airline,

        COALESCE(
            TRIM(aircraft_id),
            'Unknown'
        ) AS aircraft_id,

        INITCAP(TRIM(aircraft_type)) AS aircraft_type,

        flight_date,
        INITCAP(TRIM(day_of_week)) AS day_of_week,

        INITCAP(TRIM(origin_city)) AS origin_city,
        INITCAP(TRIM(destination_city)) AS destination_city,
        INITCAP(TRIM(origin_region)) AS origin_region,

        distance_km,
        scheduled_departure,
        actual_departure,

        COALESCE(
            delay_minutes,
            TIMESTAMPDIFF(
                MINUTE,
                scheduled_departure,
                actual_departure
            )
        ) AS delay_minutes,

        COALESCE(
            INITCAP(TRIM(delay_reason)),
            'Unknown'
        ) AS delay_reason,

        seat_capacity,
        passengers,
        avg_fare,

        COALESCE(
            ticket_revenue,
            passengers * avg_fare
        ) AS ticket_revenue,

        fuel_cost

    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY flight_id
                ORDER BY flight_id
            ) AS rn
        FROM bronze_airline_flights
    )
    WHERE rn = 1
)

SELECT *,
    CASE
        WHEN delay_minutes <= 15 THEN 'On Time'
        WHEN delay_minutes <= 60 THEN 'Minor Delay'
        ELSE 'Major Delay'
    END AS delay_category

FROM cleaned

WHERE passengers BETWEEN 0 AND seat_capacity
AND avg_fare >= 0;


-- Silver_flights_rejected

CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected AS

SELECT *,
    CASE
        WHEN passengers > seat_capacity
            THEN 'Passengers more than seats'

        WHEN passengers < 0
            THEN 'Negative passengers'

        WHEN avg_fare < 0
            THEN 'Negative average fare'
    END AS reject_reason

FROM bronze_airline_flights

WHERE passengers > seat_capacity
   OR passengers < 0
   OR avg_fare < 0;


-- ============================= Gold Layer =============================

-- Gold_monthly_flights: monthly operational and financial rollup

CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_flights AS

SELECT
    date_format(flight_date, 'yyyy-MM') AS flight_month,

    COUNT(*) AS total_flights,
    SUM(passengers) AS total_passengers,
    SUM(seat_capacity) AS total_seats,

    ROUND(
        SUM(passengers) / SUM(seat_capacity) * 100,
        2
    ) AS load_factor_pct,

    SUM(ticket_revenue) AS total_ticket_revenue,
    SUM(fuel_cost) AS total_fuel_cost,

    SUM(
        CASE WHEN delay_minutes > 15 THEN 1 ELSE 0 END
    ) AS delayed_flights

FROM silver_flights_clean
GROUP BY ALL;


-- Gold_airline_summary: airline-level operational performance

CREATE OR REFRESH MATERIALIZED VIEW gold_airline_summary AS

SELECT
    airline,

    COUNT(*) AS total_flights,
    SUM(passengers) AS total_passengers,
    SUM(ticket_revenue) AS total_ticket_revenue,

    ROUND(
        SUM(passengers) / SUM(seat_capacity) * 100,
        2
    ) AS load_factor_pct,

    ROUND(
        SUM(CASE WHEN delay_minutes <= 15 THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*),
        2
    ) AS on_time_pct,

    ROUND(AVG(delay_minutes), 2) AS avg_delay_minutes

FROM silver_flights_clean
GROUP BY ALL;


-- Gold_route_summary: city-pair level performance

CREATE OR REFRESH MATERIALIZED VIEW gold_route_summary AS

SELECT
    origin_city,
    destination_city,

    COUNT(*) AS total_flights,
    SUM(passengers) AS total_passengers,
    SUM(ticket_revenue) AS total_ticket_revenue,

    ROUND(
        SUM(passengers) / SUM(seat_capacity) * 100,
        2
    ) AS load_factor_pct

FROM silver_flights_clean
GROUP BY ALL;


-- Gold_delay_summary: delay breakdown by category and reason

CREATE OR REFRESH MATERIALIZED VIEW gold_delay_summary AS

SELECT
    delay_category,
    delay_reason,

    COUNT(*) AS total_flights,
    ROUND(AVG(delay_minutes), 2) AS avg_delay_minutes

FROM silver_flights_clean
GROUP BY ALL;


-- Gold_data_quality: end-to-end row reconciliation

CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS

WITH counts AS (
    SELECT
        (SELECT COUNT(*) FROM bronze_airline_flights)
            AS bronze_rows,
        (SELECT COUNT(DISTINCT flight_id) FROM bronze_airline_flights)
            AS distinct_flight_ids,
        (SELECT COUNT(*) FROM silver_flights_clean)
            AS clean_rows,
        (SELECT COUNT(*) FROM silver_flights_rejected)
            AS rejected_rows
)

SELECT
    bronze_rows,

    bronze_rows - distinct_flight_ids AS duplicate_rows,

    rejected_rows,

    clean_rows,

    clean_rows
        + rejected_rows
        + (bronze_rows - distinct_flight_ids) AS reconciled_rows,

    CASE
        WHEN clean_rows
             + rejected_rows
             + (bronze_rows - distinct_flight_ids) = bronze_rows
            THEN 'BALANCED'
        ELSE 'MISMATCH'
    END AS reconciliation_status

FROM counts;

