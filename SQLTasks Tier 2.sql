/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT 
name,
initialoutlay,
membercost,
monthlymaintenance
FROM `Facilities` 
WHERE
membercost != 0;


/*initialoutlay and monthlymaintenance are never 0*/

/* Q2: How many facilities do not charge a fee to members? */

SELECT 
name,
membercost,
monthlymaintenance
FROM `Facilities` 
WHERE
membercost = 0;

/*  There are 4 facilities that have zero membercost but they all have maintenance cost */


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
facid,
name,
membercost,
monthlymaintenance
FROM `Facilities`
WHERE
membercost < (monthlymaintenance * 20/100);
/*This results in 9 facilities*?


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

(SELECT *
    FROM `Facilities`
	WHERE facid = 1)
 UNION
 (SELECT *
    FROM `Facilities`
	WHERE facid = 5)
ORDER BY facid;

SELECT *
FROM `Facilities`
WHERE facid IN (1,5)




/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT
name,
monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'Expensive'
ELSE 'Cheap' END AS outcome
FROM Facilities 
WHERE monthlymaintenance > 0;



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT 
firstname,
surname,
joindate
FROM Members 
ORDER BY joindate DESC;
/*Get first row only*/
SELECT 
firstname,
surname,
joindate
FROM Members 
WHERE joindate = (Select Max(joindate) FROM Members);
//However Max and Min both return the GUEST GUEST 2012-07-01 00:00:00??



/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/*SELECT 
f.facid,f.name, b.bookid, b.memid, m.firstname,m.surname,m.memid
FROM `Facilities` AS f
JOIN Bookings as b
ON f.facid = b.facid
JOIN Members AS m
on b.bookid = m.memid
WHERE name LIKE 'Tennis%'
ORDER BY m.surname*/
SELECT DISTINCT
f.name,CONCAT ( m.firstname, ' '  ,m.surname)fullname
FROM `Facilities` AS f
JOIN Bookings as b
ON f.facid = b.facid
JOIN Members AS m
on b.memid = m.memid
WHERE name LIKE 'Tennis%'
ORDER BY fullname



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT 
f.name,CONCAT ( m.firstname, ' ' ,m.surname) AS fullname, 
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM `Facilities` AS f
JOIN Bookings as b
ON f.facid = b.facid
JOIN Members AS m
on b.memid = m.memid
WHERE b.starttime >= '2012-09-14' 
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30 
ORDER BY cost


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT subquery.name, subquery.cost
FROM (SELECT 
f.name,CONCAT ( m.firstname, ' ' ,m.surname) AS fullname, 
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM `Facilities` AS f
JOIN Bookings as b
ON f.facid = b.facid
JOIN Members AS m
on b.memid = m.memid
WHERE b.starttime >= '2012-09-14' 
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30 
ORDER BY cost) AS subquery




/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT
name,
revenue
FROM
(SELECT
name,
SUM(CASE WHEN memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS revenue
FROM Bookings INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
GROUP BY name) AS inner_table
WHERE revenue < 1000
ORDER BY revenue;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT 
m1.firstname, m1.surname, m1.memid, m2.firstname, m2.surname
FROM
    Members AS m1
LEFT JOIN Members m2
ON 
    m1.memid = m2.recommendedby
	WHERE m2.recommendedby <>''
ORDER BY 
   m1.surname, m1.firstname;


/* Q12: Find the facilities with their usage by member, but not guests */
SELECT 
f.name, f.facid, m.firstname, m.surname, COUNT(f.name) AS BOOKINGS
FROM `Facilities` AS f
JOIN Bookings as b
ON f.facid = b.facid
JOIN Members AS m
on b.memid = m.memid
WHERE m.memid !=0
GROUP BY f.name, f.facid, m.firstname, m.surname
ORDER BY f.name




/* Q13: Find the facilities usage by month, but not guests */
SELECT
f.name,concat(m.firstname,' ',m.surname) as Member,
count(f.name) as bookings,

sum(case when month(starttime) = 1 then 1 else 0 end) as Jan,
sum(case when month(starttime) = 2 then 1 else 0 end) as Feb,
sum(case when month(starttime) = 3 then 1 else 0 end) as Mar,
sum(case when month(starttime) = 4 then 1 else 0 end) as Apr,
sum(case when month(starttime) = 5 then 1 else 0 end) as May,
sum(case when month(starttime) = 6 then 1 else 0 end) as Jun,
sum(case when month(starttime) = 7 then 1 else 0 end) as Jul,
sum(case when month(starttime) = 8 then 1 else 0 end) as Aug,
sum(case when month(starttime) = 9 then 1 else 0 end) as Sep,
sum(case when month(starttime) = 10 then 1 else 0 end) as Oct,
sum(case when month(starttime) = 11 then 1 else 0 end) as Nov,
sum(case when month(starttime) = 12 then 1 else 0 end) as Decm

FROM Members m
inner join Bookings bk on bk.memid = m.memid
inner join Facilities f on f.facid = bk.facid
where m.memid>0
and year(starttime) = 2012

group by f.name,concat(m.firstname,' ',m.surname)
order by f.name,m.surname,m.firstname 

/*in sqllite*/
/* Q13: Find the facilities usage by month, but not guests */
SELECT
f.name, (m.firstname || ' ' || m.surname) as Member, strftime('%m', starttime) as Month,
count(f.name) as bookings

FROM Members m
inner join Bookings bk on bk.memid = m.memid
inner join Facilities f on f.facid = bk.facid
where m.memid>0
and strftime('%Y', starttime) = '2012'

group by f.name, m.firstname, m.surname
order by f.name,m.surname,m.firstname
        """