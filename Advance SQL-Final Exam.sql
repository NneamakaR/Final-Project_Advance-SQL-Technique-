-- Q1.1. Write and execute a SQL query to list the school names, 
-- community names and average attendance for communities with a hardship index of 98.

SELECT cps.NAME_OF_SCHOOL, cps.AVERAGE_STUDENT_ATTENDANCE, cps.Average_Teacher_Attendance, csd.COMMUNITY_AREA_NAME
FROM chicago_public_schools cps
LEFT OUTER JOIN chicago_socioeconomic_data csd ON cps.COMMUNITY_AREA_NUMBER = csd.COMMUNITY_AREA_NUMBER
WHERE csd.HARDSHIP_INDEX = 98;

-- Q1.2.  Write and execute a SQL query to list all crimes that took place at a school. 
-- Include case number, crime type and community name'

SELECT cc.LOCATION_DESCRIPTION, cds.COMMUNITY_AREA_NAME, cc.CASE_NUMBER, cc.PRIMARY_TYPE
FROM chicago_crime cc
LEFT OUTER JOIN chicago_socioeconomic_data cds
USING (COMMUNITY_AREA_NUMBER)
WHERE cc.LOCATION_DESCRIPTION LIKE '%school%';

-- Q2.1. Write and execute a SQL statement to create a view showing the columns listed in the following table, 
-- with new column names as shown in the second column.
-- COLUMN NAME chicago_public_schools   Column New Name
-- NAME_OF_SCHOOL						School_Name
-- Safety_Icon							Safety_Rating
-- Family_Involvement_Icon				Family_Rating
-- Environment_Icon						Environment_Rating
-- Instruction_Icon						Instruction_Rating
-- Leaders_Icon							Leaders_Rating
-- Teachers_Icon						Teachers_Rating
-- Q2.2. Write and execute a SQL statement that returns all of the columns from the view.
-- Q2.3.  Write and execute a SQL statement that returns just the school name and leaders rating from the view

CREATE VIEW CPS_ICONS(School_Name, Safety_Rating, Family_Rating, Environment_Rating,Instruction_Rating, Leaders_Rating,Teachers_Rating) AS
SELECT NAME_OF_SCHOOL, Safety_Icon, Family_Involvement_Icon, Environment_Icon, Instruction_Icon, Leaders_Icon, Teachers_Icon
FROM chicago_public_schools;

SELECT * FROM CPS_ICONS;

SELECT School_Name, Leaders_Rating 
FROM CPS_ICONS;

-- Q3.1.  Write the structure of a query to create or replace a stored procedure called UPDATE_LEADERS_SCORE 
-- that takes a in_School_ID parameter as an integer and a in_Leader_Score parameter as an integer.

-- CREATING A STORED PROCEDURE IN MYSQL
DELIMITER //
CREATE  PROCEDURE UPDATE_LEADERS_SCORE(IN in_School_ID INT, IN in_Leader_Score INT)
BEGIN
END//
DELIMITER ;

-- Q3.2 Inside your stored procedure, write a SQL statement to update the Leaders_Score field in the 
-- CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID to the value in the in_Leader_Score parameter.

-- TO UPDATE AN EXISTING STORED PROCEDURE IN MYSQL
DROP PROCEDURE IF EXISTS UPDATE_LEADERS_SCORE;
DELIMITER //
CREATE   PROCEDURE UPDATE_LEADERS_SCORE (in_School_ID  INT, in_Leader_Score INT)
BEGIN
/********Update statement begins********/
 UPDATE CHICAGO_PUBLIC_SCHOOLS
 SET Leaders_Score = in_Leader_Score
 WHERE School_ID = in_School_ID ;
/******Update statement ends******/
END //

-- Q3.3. Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field 
-- in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID using the following information.

/*Complete query of stored procedure*/
DROP PROCEDURE IF EXISTS UPDATE_LEADERS_SCORE;
DELIMITER //
CREATE   PROCEDURE `UPDATE_LEADERS_SCORE` (IN in_School_ID  int,IN in_Leader_Score  int)
BEGIN
 UPDATE CHICAGO_PUBLIC_SCHOOLS
 SET Leaders_Score = in_Leader_Score
 WHERE School_ID = in_School_ID ;
/****If statement begins****/
  IF in_Leader_Score >0 AND in_Leader_Score <20
  THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Icon ='Very Weak'
  WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 40
  THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Icon ='Weak'
  WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 60
  THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Icon ='Average'
  WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 80
  THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Icon ='Strong'
  WHERE School_ID = in_School_ID;
  ELSEIF in_Leader_Score < 100
  THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Icon ='Very Strong'
  WHERE School_ID = in_School_ID;
  
  END IF;
  /****If statement ends****/
END //

-- Q3.4. Run your code to create the stored procedure.
-- Write a query to call the stored procedure, passing a valid school ID and a leader score of 50,
--  to check that the procedure works as expected.

-- Answer --
-- Data type of leaders icon is varchar(4) so an error was given if character longer than 4 was entered.

/*Query to modify data type of column*/
ALTER TABLE CHICAGO_PUBLIC_SCHOOLS MODIFY COLUMN leaders_icon varchar(15);

CALL UPDATE_LEADERS_SCORE(610038,50);
/*To check the result*/
SELECT School_ID, leaders_icon, Leaders_Score from CHICAGO_PUBLIC_SCHOOLS where School_ID=610038;

-- Q4.1. Update your stored procedure definition. 
-- Add a generic ELSE clause to the IF statement that rolls back the current work if the score did not fit any of the preceding categories.

-- Answer--
-- MySQL provides a feature to modify an existing stored procedure so if  applied after the changes it will replace the existing procedure.

CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_LEADERS_SCORE`(in_School_ID  INT,in_Leader_Score  INT)
BEGIN
/*TRANSACTION STATEMENT BEGINS*/ 
START TRANSACTION;
/*Here is the update code*/
   /*ELSE STATEMENT IF ABOVE 100 THEN ROLL BACK*/
   ELSE  
   ROLLBACK;
END IF;
END

-- Q4.2. Update your stored procedure definition again.
--  Add a statement to commit the current unit of work at the end of the procedure.

/*Here is complete query, commit added after if statement ends*/
CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_LEADERS_SCORE`(in_School_ID  int,in_Leader_Score  int)
BEGIN
 START TRANSACTION;
  UPDATE CHICAGO_PUBLIC_SCHOOLS
  SET Leaders_Score = in_Leader_Score
  WHERE School_ID = in_School_ID ;

  IF in_Leader_Score >0 AND in_Leader_Score <20
   THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
   SET Leaders_Icon ='Very Weak'
   WHERE School_ID = in_School_ID;
   ELSEIF in_Leader_Score < 40
   THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
   SET Leaders_Icon ='Weak'
   WHERE School_ID = in_School_ID;
   ELSEIF in_Leader_Score < 60
   THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
   SET Leaders_Icon ='Average'
   WHERE School_ID = in_School_ID;
   ELSEIF in_Leader_Score < 80
   THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
   SET Leaders_Icon ='Strong'
   WHERE School_ID = in_School_ID;
   ELSEIF in_Leader_Score < 100
   THEN UPDATE CHICAGO_PUBLIC_SCHOOLS
   SET Leaders_Icon ='Very Strong'
   WHERE School_ID = in_School_ID;
   ELSE  
   ROLLBACK;
END IF;
  COMMIT;
END //    

-- Q4.3. Run your code to replace the stored procedure.
/*For MYSQL right from the stored procedure section on the schema database, select it, Make the necessary changes to the SQL script in the editor, click on the "Apply"*/

-- Q4.4. Write and run one query to check that 
-- the updated stored procedure works as expected when you use a valid score of 38.

/*Calling the stored procedure*/
CALL UPDATE_LEADERS_SCORE(610038,38);
/*To check the result*/
SELECT School_ID, leaders_icon, Leaders_Score from CHICAGO_PUBLIC_SCHOOLS where School_ID=610038;

-- Q5.1. Write and run another query to check that the updated
--  stored procedure works as expected when you use an invalid score of 101

/*When provided a score of 101 to the function it ran successfully but no changes were made.*/
CALL UPDATE_LEADERS_SCORE(610038,101);
/*To check the result*/
SELECT School_ID, leaders_icon, Leaders_Score from CHICAGO_PUBLIC_SCHOOLS where School_ID=610038;