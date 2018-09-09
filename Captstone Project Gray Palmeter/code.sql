WITH months AS
    (SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
       UNION
           SELECT
           '2017-02-01' as first_day,
           '2017-02-28' as last_day
                UNION
                    SELECT
                    '2017-03-01' as first_day,
                    '2017-03-31' as last_day),
cross_join AS
   (SELECT *
       FROM subscriptions
          CROSS JOIN months),
status AS
    (SELECT id, first_day AS month,
        segment,
           CASE
           WHEN (subscription_start < first_day) 
           AND (subscription_end > first_day
           OR subscription_end IS NULL) 
           THEN 1
           ELSE 0
               END AS is_active,
CASE
    WHEN (subscription_end BETWEEN first_day AND            last_day) 
       THEN 1
       ELSE 0
          END AS is_canceled
               FROM cross_join),
status_aggregate AS 
 (SELECT month, 
	SUM(CASE WHEN segment = '87' THEN is_active ELSE 0 END) AS "sum_active_87",
	SUM(CASE WHEN segment = '87' THEN is_canceled ELSE 0 END) AS "sum_canceled_87",
	SUM(CASE WHEN segment = '30' THEN is_active ELSE 0 END) AS "sum_active_30",
	SUM(CASE WHEN segment = '30' THEN is_canceled ELSE 0 END) AS "sum_canceled_30"
  FROM status
  GROUP BY month)
SELECT
 AVG (100.0 * sum_canceled_87 / sum_active_87) AS churn_rate_87, AVG (100.0 * sum_canceled_30 / sum_active_30) AS churn_rate_30
FROM status_aggregate; 