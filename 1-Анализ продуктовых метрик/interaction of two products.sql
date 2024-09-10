SELECT toStartOfDay(toDateTime(time)) AS __timestamp,
       status AS status,
       sum(users_num) AS "SUM(users_num)"
FROM
  (SELECT time,
          'Лента и сообщения' as status,
          COUNT(DISTINCT user_id) as users_num
   FROM
     (SELECT message.time::DATE as time,
             message.user_id
      FROM simulator_20240820.message_actions as message
      INNER JOIN simulator_20240820.feed_actions as feed ON message.user_id = feed.user_id
      WHERE message.time::DATE = feed.time::DATE ) as t1
   GROUP BY time
   ORDER BY time DESC
   UNION ALL SELECT time,
                    'Только сообщения' as status,
                    COUNT(DISTINCT user_id) as users_num
   FROM
     (SELECT message.time::DATE as time,
             message.user_id
      FROM simulator_20240820.message_actions as message
      LEFT JOIN simulator_20240820.feed_actions as feed ON message.user_id = feed.user_id
      WHERE message.time::DATE != feed.time::DATE ) as t2
   GROUP BY time
   ORDER BY time DESC
   UNION ALL SELECT time,
                    'Только лента' as status,
                    COUNT(DISTINCT user_id) as users_num
   FROM
     (SELECT feed.time::DATE as time,
             feed.user_id
      FROM simulator_20240820.feed_actions as feed
      LEFT JOIN simulator_20240820.message_actions as message ON feed.user_id = message.user_id
      WHERE message.time::DATE != feed.time::DATE ) as t3
   GROUP BY time
   ORDER BY time DESC) AS virtual_table
GROUP BY status,
         toStartOfDay(toDateTime(time))
ORDER BY "SUM(users_num)" DESC
LIMIT 10000;