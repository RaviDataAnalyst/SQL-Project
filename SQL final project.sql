                                        -- Final Project - Sports Analytics using SQL.
										
   /* In this project, I have performed a job of sports analyst. There are two dataset related to IPL(Indian Premier League)
      creaket matches.One dataset contain ball-by-ball data and other contains match-wise data. I have imported the datasets
	  into an SQL database and perform the tasks to find important insights from the dataset.*/
	  
	  
--1. Create a table named 'matches'.
CREATE TABLE matches (
	id int NOT NULL PRIMARY KEY,
	city VARCHAR(40),
	date DATE,
	player_of_match VARCHAR(40),
	venue VARCHAR(80),
	neutral_venue BIT,
	team1 VARCHAR(40),
	team2 VARCHAR(40),
	toss_winner VARCHAR(40),
	toss_decision VARCHAR(10),
	winner VARCHAR(40),
	result VARCHAR(10),
	result_margin int,
	eliminator VARCHAR(5),
	method VARCHAR(5),
	umpire1 VARCHAR(80),
	umpire2 VARCHAR(80)
	);
	
--2. Creating a table named 'deliveries'. 
CREATE TABLE deliveries (
	id INT,
	FOREIGN KEY(id)
	REFERENCES matches(id),
	inning INT,
	over INT,
	ball INT,
	batsman VARCHAR(80),
	non_striker VARCHAR(80),
	bowler VARCHAR(80),
	batsman_runs INT,
	extra_run INT,
	total_runs INT,
	is_wicket BIT,
	dismissal_kind VARCHAR(50),
	player_dismissed VARCHAR(50),
	fielder VARCHAR(80),
	extra_type VARCHAR(20),
	batting_team VARCHAR(80),
	bowling_team VARCHAR(80)
	);
	
--3. Import data from csv file 'matches.csv' attached in resources to the table 'matches'.
    COPY matches(	id ,city ,date ,player_of_match , venue , neutral_venue,
	                team1 ,team2 ,toss_winner , toss_decision, winner,
	                result ,result_margin ,eliminator ,method ,
	                    umpire1 ,umpire2 )
    FROM 'C:\Program Files\PostgreSQL\15\data\final_project\matches.csv'
    DELIMITER ','
    CSV HEADER;

--4. Import data from csv file 'deliveries'
      COPY deliveries(id ,inning ,over ,ball ,batsman ,
	                 non_striker ,bowler ,batsman_runs,
					 extra_run ,total_runs ,is_wicket ,
	                 dismissal_kind ,player_dismissed ,
					 fielder,extra_type ,batting_team ,
					 bowling_team)
	 FROM 'C:\Program Files\PostgreSQL\15\data\final_project\deliveries.csv'
     DELIMITER ','
     CSV HEADER;

--5. Select the top 20 rows of the deliveries table after ordering them by id,inning,over,ball in ascending order.	
	  SELECT * FROM deliveries
	  ORDER BY id,inning,over,ball ASC
	   LIMIT 20;
	   
--6. Select the top 20 rows of the matches table.
      SELECT * FROM matches
	  LIMIT 20; 
	 
--7. Fetch data of all	the matches played on 2nd May 2013 from the matches table. 
	  SELECT * FROM matches 
	  WHERE DATE = '2013-05-02';
	  
--8. Fetch the data of all the matches where result mode is runs and margin of victory is more than hundred.	  
	  SELECT * FROM matches 
	  WHERE result ='runs' 
	  AND result_margin >=100;
	  
--9. Fetch data of all the matches where the final scores of both the  teams tied and order it in descending order of dates
      -- Using subquery
	 SELECT * FROM matches
	 WHERE id IN (
	 SELECT id from matches
	 WHERE result = 'tie')
	 ORDER BY DATE DESC;
	 
--10. Get count of city that hosted an ipl match.	 
	  SELECT COUNT(DISTINCT city)  AS
	  " Number of city to host IPL matches"
	  FROM matches;
	  
/*11. Create table deliveries_v02 with all the columns of the table 'deliveries' and an additional column ball_result containing value boundary,dot
      or other depending on total_run(boundary for >=4,dot for 0 and other for any other number)*/
	  CREATE TABLE deliveries_v02
	  AS ( SELECT * , CASE
		              WHEN total_runs >=4 THEN 'boundary'
		              WHEN total_runs = 0 THEN 'dot'
		              WHEN total_runs = 1 THEN 'single'
		              WHEN total_runs = 2 THEN 'double'
		              ELSE 'triple'
		              END AS ball_result
		   FROM deliveries
		  )
	   -- Fetch data from deliveries_v02 table.
	      SELECT * FROM deliveries_v02
		  
--12. Write a query to fetch the total no of boundaries and dot balls from the deliveries_v02.		  
	  SELECT COUNT(ball_result)
	  AS "Total no of boundary and dot balls" 
	  FROM deliveries_v02
	  WHERE ball_result IN ('boundary','dot');
	  
--13. Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order.  
	  SELECT batting_team, COUNT(ball_result) AS "No of boundaries"
	  FROM deliveries_v02
	  WHERE ball_result IN ('boundary')
	  GROUP BY batting_team
	  ORDER BY COUNT(ball_result) DESC;
	  
--14. Write a query to fetch the total number of dot balls bowled by each team and order it in descending order. 	  
	  SELECT bowling_team, COUNT(ball_result) AS "No of dot balls"
	  FROM deliveries_v02
	  WHERE ball_result IN ('dot')
	  GROUP BY bowling_team
	  ORDER BY COUNT(ball_result) DESC; 
	  
--15. Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA.
	  SELECT dismissal_kind , COUNT(is_wicket)
	  AS "Total no of dismissal"
	  FROM deliveries_v02
	  WHERE is_wicket = '1'
	  AND NOT dismissal_kind IN ('NA')
	  GROUP BY dismissal_kind;
	  
--16. Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table	  
	  SELECT bowler, COUNT(extra_run) 
	  AS " Maximum extra runs conceded"
	  FROM deliveries
	  GROUP BY bowler
	  ORDER BY COUNT(extra_run) DESC
	  LIMIT 5;

/*17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column 
      (named venue and match_date) of venue and date from table matches. */
	  CREATE TABLE deliveries_v03 AS
      SELECT deliveries_v02.*,
	  matches.venue, matches.date AS match_date
      FROM deliveries_v02 
      INNER JOIN matches 
	  ON deliveries_v02.id = matches.id;
	  
	  --To retrive data from table deliveries_v03.
	    SELECT * FROM deliveries_v03

--18. Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored. 	  
	  SELECT DISTINCT(matches.venue),
	  COUNT(deliveries.total_runs) AS " Total runs scored for each venue"
	  FROM matches INNER JOIN deliveries
		   ON matches.id = deliveries.id
		   GROUP BY DISTINCT(matches.venue)
		   ORDER BY COUNT(deliveries.total_runs) DESC ;
		   
--19. Write a query to fetch the year-wise total runs scored at Eden_garderns and order it in the descending order of total runs scored.		   
	  SELECT 
	  SUM(deliveries.total_runs) AS TOTAL_RUNS,
	  EXTRACT(YEAR FROM  matches.date) AS YEAR
	  FROM matches INNER JOIN deliveries
		   ON matches.id = deliveries.id
	       WHERE matches.venue ='Eden Garderns'
	       GROUP BY EXTRACT(YEAR FROM  matches.date) 
	       ORDER BY TOTAL_RUNS DESC ;

/*20. Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant
      and another one with Rising Pune Supergiants.  Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr
      containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.*/
	  
	  -- Retrive unque team1 from matches table.
	     SELECT DISTINCT(team1) FROM matches;
		 
	  -- Create a matches_corrected table with two additional columns team1_corr and team2_corr.
	     CREATE TABLE matches_corrected AS
		 SELECT *,
		        CASE WHEN team1 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
				     ELSE team1
			    END AS team1_corr,
				CASE WHEN team2 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
                     ELSE team2
                END AS team2_corr
         FROM matches;
		 
	  -- Retrive unque team1_corr data from matches_corrected table.
	     SELECT DISTINCT(team1_corr) FROM matches_corrected;
		 
/*21. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated 
      by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03*/		 
	  CREATE TABLE deliveries_v04 AS
      SELECT (id|| ' - '|| inning || ' - ' || over || ' - ' || ball ) 
	  AS ball_id , deliveries_v03.*
      FROM deliveries_v03;
	  
	  -- Retrive data from deliveries_v04 table.
	     SELECT * FROM deliveries_v04
		 
--22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04.
      SELECT COUNT(DISTINCT ball_id) AS distinct_ball_id_count,
	         COUNT(*) AS total_count
      FROM deliveries_v04;
	  
--23. Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. 	  
	  CREATE TABLE deliveries_v05 AS
      SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ball_id) AS r_num
      FROM deliveries_v04;
	  
	   -- Retrive data from deliveries_v05 table
	      SELECT * FROM deliveries_v05;
	
--24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating.
      select * from deliveries_v05 WHERE r_num=2; -- 10 ball_id`s.
	 
	  select * from deliveries_v05 WHERE r_num=3; -- 0 ball_id. 
	  
	  -- Means only there are only 10 instences in result set where ball_id is repeating.
	  
--25. Use subqueries to fetch data of all the ball_id which are repeating.
      SELECT * FROM deliveries_v05 WHERE ball_id IN 
	  (SELECT ball_id FROM deliveries_v05 WHERE r_num >=2);

		  
	  

	  

		 



		
	  
	  
	  
	  
	  
	


	  


	
	
	
	
	
	
 

	
	
	
	
	
);