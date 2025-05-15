WITH
  account_metrics AS (
    SELECT
      s.date AS date,
      sp.country AS country,
      a.send_interval AS send_interval,
      a.is_verified AS is_verified,
      a.is_unsubscribed AS is_unsubscribed,
      COUNT(DISTINCT a.id) AS account_cnt
    FROM `data-analytics-mate.DA.account` a
    JOIN `data-analytics-mate.DA.account_session` acs
    ON a.id = acs.account_id
    JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id
    GROUP BY
      s.date,
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed
  ),  -- metrics by accounts


  email_metrics AS(
    SELECT
      DATE_ADD(s.date, INTERVAL es.sent_date day) AS sent_date,
      sp.country AS country,
      send_interval,
      is_verified,
      is_unsubscribed,
      COUNT(DISTINCT es.id_message) AS sent_msg,
      COUNT(DISTINCT eo.id_message) AS open_msg,
      COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM `data-analytics-mate.DA.email_sent` es
    JOIN `data-analytics-mate.DA.account_session` acs
    ON es.id_account = acs.account_id
    JOIN `data-analytics-mate.DA.account` a
    ON a.id = acs.account_id
    JOIN `data-analytics-mate.DA.session` s
    ON acs.ga_session_id = s.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id
    LEFT JOIN `data-analytics-mate.DA.email_open`eo
    ON es.id_message = eo.id_message
    LEFT JOIN `data-analytics-mate.DA.email_visit`ev
    ON es.id_message = ev.id_message
    GROUP BY
      DATE_ADD(s.date, INTERVAL es.sent_date day),
      sp.country,
      a.send_interval,
      a.is_verified,
      a.is_unsubscribed
    ), -- metrics by emails


  union_metrics AS (
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      account_cnt,
      0 AS sent_msg,
      0 AS open_msg,
      0 AS visit_msg
    FROM account_metrics
    UNION ALL
    SELECT
      sent_date AS date,
      country,
      send_interval, — - naprawione
      0 AS is_verified,
      0 AS is_unsubscribed,
      0 AS account_cnt,
      sent_msg,
      open_msg,
      visit_msg
    FROM email_metrics
  ), -- Union account and email metrics


  group_guery AS (
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      SUM(account_cnt) AS account_cnt,
      SUM(sent_msg) AS sent_msg,
      SUM(open_msg) AS open_msg,
      SUM(visit_msg) AS visit_msg
    FROM union_metrics
    GROUP BY
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed
    ),


  total_acc_msg AS (
    SELECT
      *,
      SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
      SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
    FROM group_guery
  ), -- calculating the sum of accounts and messages by counties


  rank_guery AS (
    SELECT
      *,
      DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
      DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
    FROM total_acc_msg
  ) -- ranking


    SELECT *
    FROM rank_guery
    WHERE rank_total_country_account_cnt <= 10
      OR rank_total_country_sent_cnt <= 10
    ORDER BY rank_total_country_account_cnt,
    rank_total_country_sent_cnt  
    -- limited to 10
