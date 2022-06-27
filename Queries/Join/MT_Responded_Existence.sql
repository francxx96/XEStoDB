DECLARE @result TABLE ( Template VARCHAR(50), TaskA VARCHAR(300), TaskB VARCHAR(300), Support FLOAT, min_TD BIGINT, avg_TD BIGINT, max_TD BIGINT);

INSERT @result
SELECT	'RespondedExistence',
		TaskA,
		TaskB,
		(CAST(COUNT(*) AS FLOAT) / CAST( (SELECT COUNT(*) FROM @event WHERE task LIKE TaskA ) AS FLOAT) ),
		MIN(TD) AS min_TD, 
		AVG(TD) AS avg_TD, 
		MAX(TD) AS max_TD
FROM (
	SELECT	a.trace_id,
			a.task AS TaskA,
			b.task AS TaskB,
			MIN(ABS(DATEDIFF_BIG(SECOND, a.[time], b.[time]))) AS TD
	FROM @event a 
	JOIN @event b ON ( a.log_id = b.log_id AND a.trace_id = b.trace_id 
						AND a.task != b.task AND a.[time] < b.[time] )
	GROUP BY a.trace_id, a.task, a.[time], b.task
) discovery
GROUP BY TaskA, TaskB;