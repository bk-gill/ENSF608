#1 Write a query to list all student names (first and last) and the name of the music studio that they belong to (1 mark). 
SELECT 
    CONCAT(C.LName, ', ', C.FName) AS StudentName,
    S.Name AS StudioName
FROM COMPETITOR C
JOIN TEACHER T ON C.TeacherID = T.TeacherID
JOIN STUDIO S ON T.StudioName = S.Name;

#2 Write a query to count how many students belong to each music studio group (1 mark).
SELECT
    S.Name AS StudioName,
    COUNT(C.CompetitorID) AS StudentCount
FROM STUDIO S
LEFT JOIN TEACHER T ON S.Name = T.StudioName
LEFT JOIN COMPETITOR C ON T.TeacherID = C.TeacherID
GROUP BY S.Name;

#3 Write a query to count how many teachers belong to each music studio group (1 mark)
SELECT
    S.Name AS StudioName,
    COUNT(T.TeacherID) AS TeacherCount
FROM STUDIO S
LEFT JOIN TEACHER T ON S.Name = T.StudioName
GROUP BY S.Name;

#4 Write a query to list the last name of all teachers who have more than one student registered in the competition (1 mark).
SELECT DISTINCT
    T.LName AS TeacherLastName
FROM TEACHER T
JOIN COMPETITOR C ON T.TeacherID = C.TeacherID
GROUP BY T.LName
HAVING COUNT(C.CompetitorID) > 1;

#5 Write a query to list all student names (first and last) who are performing in Romantic genre category, along with the title of their chosen composition (2 marks)
SELECT
    CONCAT(C.LName, ', ', C.FName) AS StudentName,
    CO.Title AS CompositionTitle
FROM COMPETITOR C
JOIN PERFORMANCE P ON C.CompetitorID = P.CompetitorID
JOIN CATEGORY CA ON P.CategoryID = CA.CategoryID
JOIN COMPOSITION CO ON P.MusicID = CO.MusicID
WHERE CA.Genre = 'Romantic';

#6 Students may choose to play any of the compositions from their category’s genre. Not all compositions are currently being played in a category, and some compositions are being played multiple times by different students. Write a query to list all possible compositions and which categories they are currently being performed in (2 marks).
SELECT
    CO.Title AS CompositionTitle,
    CA.Genre AS CategoryGenre
FROM COMPOSITION CO
LEFT JOIN PERFORMANCE P ON CO.MusicID = P.MusicID
LEFT JOIN CATEGORY CA ON P.CategoryID = CA.CategoryID;

#7 The competition organizers have hired a team to analyze the performance results. The external team do not have permission to view all of the data. Create a view called SCORE_ANALYSIS that only lists the ages of each competitor and their final performance score (1 mark).
CREATE VIEW SCORE_ANALYSIS AS
SELECT
    C.Age AS CompetitorAge,
    P.Score AS FinalScore
FROM COMPETITOR C
JOIN PERFORMANCE P ON C.CompetitorID = P.CompetitorID;

#8 Display the rows of SCORE_ANALYSIS from the highest score to the lowest score (1 mark).
SELECT *
FROM SCORE_ANALYSIS
ORDER BY FinalScore DESC;

#9 Write a query to find the highest score, the lowest score, and the average score using SCORE_ANALYSIS (1 mark)
SELECT
    MAX(FinalScore) AS HighestScore,
    MIN(FinalScore) AS LowestScore,
    AVG(FinalScore) AS AverageScore
FROM SCORE_ANALYSIS;

#10 The competition organizers have decided to add copyright information to their list of available compositions. Alter the COMPOSITION table to add a new column called Copyright with a default value ‘SOCAN’. Display all rows in the updated table (2 marks).
-- Add the new column with a default value
ALTER TABLE COMPOSITION
ADD COLUMN Copyright VARCHAR(20) DEFAULT 'SOCAN';
-- Display all rows in the updated table
SELECT * FROM COMPOSITION;

#11 Write a query that uses the NOT EXISTS command to select any competitors who do not meet the age restrictions for their chosen performance category (2 marks)
SELECT
    CONCAT(C.LName, ', ', C.FName) AS CompetitorName,
    C.Age AS CompetitorAge,
    CA.Genre AS CategoryGenre,
    CA.AgeMin AS CategoryMinAge,
    CA.AgeMax AS CategoryMaxAge
FROM COMPETITOR C
JOIN PERFORMANCE P ON C.CompetitorID = P.CompetitorID
JOIN CATEGORY CA ON P.CategoryID = CA.CategoryID
WHERE NOT EXISTS (
    SELECT 1
    FROM CATEGORY CA2
    WHERE C.Age BETWEEN CA2.AgeMin AND CA2.AgeMax
      AND CA.Genre = CA2.Genre
);

#12 Alter the COMPETITOR table to add a CHECK constraint that all competitors must be at least 5 years old and not older than 18 (1 mark)
-- Add CHECK constraint to COMPETITOR table
ALTER TABLE COMPETITOR
ADD CONSTRAINT CHK_CompetitorAge CHECK (Age >= 5 AND Age <= 18);

#13 Harmony Inc. has decided to change their company name to Harmony Studio. Change this information in the database and display results in the STUDIO table. Under the update command, write a comment (#) to explain how this change was updated in all applicable tables (2 marks)
-- Update the name in the STUDIO table
UPDATE STUDIO
SET Name = 'Harmony Studio'
WHERE Name = 'Harmony Inc.';
-- Update the name in the TEACHER table
UPDATE TEACHER
SET StudioName = 'Harmony Studio'
WHERE StudioName = 'Harmony Inc.';
-- Display the updated results in the STUDIO table
SELECT * FROM STUDIO;

#14 Based on the current database state, explain the error message that results from the following deletion statement. Answer using a comment (#) in your .sql file (1 mark)
DELETE FROM COMPOSITION WHERE Composer = 'Beethoven';
# The error message "Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect" indicates that you are trying to perform an update without a WHERE clause on a table in safe update mode, and the table doesn't have a primary key or unique key defined.

#15 All teachers must have a registered certificate number under their current name and studio information. Any changes will require documentation to be submitted to the competition organizers. In your file, use a comment (#) to explain how the following code addresses this issue (1 mark).
CREATE TRIGGER Certification
BEFORE UPDATE ON TEACHER
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Proof of certification must be provided to the main office.';
-- The following trigger code addresses the certification requirement for teachers in the TEACHER table:
-- It creates a BEFORE UPDATE trigger named 'Certification' that fires for each row before an update operation on the TEACHER table.
-- The trigger uses the SIGNAL statement to raise an exception with SQLSTATE '45000' and sets a custom error message.
-- The error message indicates that proof of certification must be provided to the main office, emphasizing the requirement for documentation.


