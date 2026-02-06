SELECT 
    DATEPART(HOUR, bet_date) AS bet_hour,
    COUNT(*) AS total_bets,
    SUM(stake) AS total_stake
FROM bets
GROUP BY DATEPART(HOUR, bet_date)
ORDER BY total_stake DESC;


WITH player_activity AS (
    SELECT
        player_id,
        COUNT(DISTINCT CAST(bet_date AS DATE)) AS active_days,
        SUM(stake) AS total_stake,
        SUM(win_amount) AS total_win,
        AVG(stake) AS avg_stake
    FROM bets
    GROUP BY player_id
),
deposits_sum AS (
    SELECT
        player_id,
        SUM(amount) AS total_deposit
    FROM deposits
    WHERE status = 'completed'
    GROUP BY player_id
),
withdrawals_sum AS (
    SELECT
        player_id,
        SUM(amount) AS total_withdrawal
    FROM withdrawals
    WHERE status = 'approved'
    GROUP BY player_id
)

SELECT
    p.player_id,
    p.username,
    c.country_name,
    p.vip_level,
    ISNULL(d.total_deposit,0) AS total_deposit,
    ISNULL(w.total_withdrawal,0) AS total_withdrawal,
    a.total_stake,
    a.total_win,
    (a.total_stake - a.total_win) AS ggr,
    (ISNULL(d.total_deposit,0) - ISNULL(w.total_withdrawal,0)) AS net_cash,
    a.active_days,
    a.avg_stake
FROM players p
JOIN countries c ON p.country_id = c.country_id
LEFT JOIN player_activity a ON p.player_id = a.player_id
LEFT JOIN deposits_sum d ON p.player_id = d.player_id
LEFT JOIN withdrawals_sum w ON p.player_id = w.player_id;
