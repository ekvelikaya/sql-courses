-- 1.
SELECT b.title,
		 g.name_genre,
		 b.price
FROM book b
JOIN author a
	ON b.author_id=a.author_id
JOIN genre g
	ON b.genre_id=g.genre_id
WHERE amount>8
ORDER BY  price desc;

-- 2. 
SELECT name_genre
FROM 
	(SELECT name_genre,
		 book_id
	FROM genre
	LEFT JOIN book using(genre_id)
	WHERE book_id is null) t1;

-- 3.
SELECT name_city,
		 name_author,
		 date_add('2020-01-01', interval FLOOR(RAND()*365) day) AS Дата
FROM author
CROSS JOIN city
ORDER BY  1, 3 desc;

-- 4.
SELECT name_genre,
		 title,
		 name_author
FROM book
INNER JOIN author
	ON book.author_id=author.author_id
INNER JOIN genre
	ON book.genre_id=genre.genre_id
WHERE name_genre='Роман'
ORDER BY  title;

-- 5.
SELECT name_author,
		 sum(amount) AS Количество
FROM author
LEFT JOIN book
	ON author.author_id=book.author_id
GROUP BY  name_author
HAVING sum(amount) < 10
		OR Количество is null
ORDER BY  Количество;

-- 6.
SELECT name_author
FROM book
LEFT JOIN genre
USING (genre_id)
LEFT JOIN author
USING (author_id)
GROUP BY  name_author
HAVING count(distinct name_genre)=1
ORDER BY  name_author;

-- 7. 
SELECT book.title AS Название,
		 author AS Автор,
		 book.amount + supply.amount AS Количество
FROM book
JOIN supply
	ON supply.title = book.title
		AND supply.price = book.price;

-- 8.

SELECT buy.buy_id,
		 book.title,
		 book.price,
		 buy_book.amount
FROM client
INNER JOIN buy
	ON client.client_id=buy.client_id
INNER JOIN buy_book
	ON buy.buy_id=buy_book.buy_id
INNER JOIN book
	ON book.book_id=buy_book.book_id
WHERE client.client_id=1
ORDER BY  buy_id, title;

-- 9.

SELECT name_author,
		 title,
		 count(buy_book.book_id) AS Количество
FROM author
LEFT JOIN book
	ON book.author_id=author.author_id
LEFT JOIN buy_book
	ON buy_book.book_id=book.book_id
WHERE title is not null
GROUP BY  name_author, title
ORDER BY  name_author, title;

-- 10.

SELECT name_city,
		 count(*) AS Количество
FROM buy
INNER JOIN client
	ON client.client_id=buy.client_id
INNER JOIN city
	ON city.city_id=client.city_id
GROUP BY  name_city;

-- 11.

SELECT buy_id,
		 date_step_end
FROM buy_step
WHERE step_id=1
		AND date_step_end is not null;

-- 12.

SELECT buy_id,
		 name_client,
		 sum(buy_book.amount*price) AS Стоимость
FROM buy
LEFT JOIN client using(client_id)
LEFT JOIN buy_book using(buy_id)
LEFT JOIN book using(book_id)
GROUP BY  buy_id, name_client
ORDER BY  buy_id;

SELECT buy.buy_id,
		 name_client,
		 sum(buy_book.amount*book.price) AS Стоимость
FROM buy
JOIN client
	ON buy.client_id=client.client_id
JOIN buy_book
	ON buy_book.buy_id=buy.buy_id
JOIN book
	ON book.book_id=buy_book.book_id
GROUP BY  buy.buy_id, name_client
ORDER BY  buy.buy_id;

-- 13.

WITH genre_totals AS 
		(SELECT genre_id, SUM(amount) AS total_amount
		FROM book
		GROUP BY  genre_id ), 
	most_popular_genre AS 
		(SELECT genre_id
		FROM genre_totals
		WHERE total_amount = (SELECT MAX(total_amount) FROM genre_totals))

SELECT b.title,
		 a.name_author,
		 g.name_genre,
		 b.price,
		 b.amount
FROM book b
INNER JOIN author a
	ON a.author_id = b.author_id
INNER JOIN genre g
	ON b.genre_id = g.genre_id
WHERE b.genre_id IN (SELECT genre_id FROM most_popular_genre)
ORDER BY  b.title; 

-- 14.

SELECT buy_id,
		 name_step
FROM buy_step
JOIN step using(step_id)
WHERE date_step_beg is NOT null
		AND date_step_end is null
ORDER BY  buy_id;

-- 15.

SELECT buy.buy_id,
		 datediff(date_step_end, date_step_beg) AS Количество_дней,	
		 CASE
		 WHEN datediff(date_step_end, date_step_beg)-days_delivery>0 THEN datediff(date_step_end, date_step_beg)-days_delivery
		 ELSE 0
		 END AS Опоздание
FROM buy
LEFT JOIN client using(client_id)
LEFT JOIN city using(city_id)
LEFT JOIN buy_step using(buy_id)
WHERE step_id = 3
		AND date_step_end is NOT null
ORDER BY  buy_id;

-- 16.

SELECT distinct name_client
FROM client
JOIN buy
	ON buy.client_id=client.client_id
JOIN buy_book
	ON buy.buy_id=buy_book.buy_id
JOIN book
	ON book.book_id=buy_book.book_id
WHERE book.author_id=2
ORDER BY  name_client;

-- 17.

SELECT name_genre,
		sum(buy_book.amount) AS Количество
FROM genre
JOIN book using(genre_id)
JOIN buy_book using(book_id)
GROUP BY  name_genre
HAVING sum(buy_book.amount) = 
	(SELECT max(total_count)
	FROM 
		(SELECT genre_id,
				sum(buy_book.amount) AS total_count
		FROM buy_book
		JOIN book using(book_id)
		GROUP BY  genre_id) AS count_table
	);

-- 18.


-- 19.


-- 20.

SELECT name_student,
		 date_attempt,
		 result
FROM attempt
JOIN student using(student_id)
JOIN subject using(subject_id)
WHERE name_subject = 'Основы баз данных'
ORDER BY result desc;

-- 21.

SELECT name_subject,
		 count(result) AS Количество,
		 round(avg(result),
		 2) AS Среднее
FROM subject
LEFT JOIN attempt
	ON subject.subject_id=attempt.subject_id
GROUP BY  name_subject;

-- 22.

SELECT name_student,
		 result
FROM student
JOIN attempt
	ON student.student_id=attempt.student_id
HAVING result IN 
	(SELECT max(result)
	FROM attempt)
ORDER BY  name_student;

-- 23.

SELECT name_student,
		 name_subject,
		 datediff(max(date_attempt),
		 min(date_attempt)) AS Интервал
FROM student
JOIN attempt using(student_id)
JOIN subject using(subject_id)
GROUP BY  name_student, name_subject
HAVING count(attempt_id) > 1
ORDER BY Интервал;

-- 24.

SELECT name_subject,
		 coalesce(count(distinct student_id), 0) AS Количество
FROM subject
LEFT JOIN attempt using(subject_id)
GROUP BY  name_subject
ORDER BY  Количество desc, name_subject;

-- 25.

SELECT question_id,
		 name_question
FROM question
JOIN subject using(subject_id)
WHERE name_subject = 'Основы баз данных'
ORDER BY  RAND() 
LIMIT 3;

-- 26.

SELECT name_question,
		 name_answer,
	CASE
	WHEN is_correct=1 THEN 'Верно'
	ELSE 'Неверно'
	END AS Результат
FROM question
JOIN testing using(question_id)
JOIN answer using(answer_id)
WHERE attempt_id=7;


-- 27.

SELECT name_student,
		 name_subject,
		 date_attempt,
		 round(sum(is_correct)/3*100,2) AS Результат
FROM answer
JOIN testing using(answer_id)
JOIN attempt using(attempt_id)
JOIN subject using(subject_id)
JOIN student using(student_id)
GROUP BY  name_student, name_subject, date_attempt
ORDER BY  name_student, date_attempt DESC;

-- 28.


-- 29.

SELECT name_enrollee
FROM enrollee
LEFT JOIN program_enrollee using(enrollee_id)
LEFT JOIN program using(program_id)
WHERE name_program = 'Мехатроника и робототехника'
ORDER BY  name_enrollee;

-- 30.

SELECT DISTINCT name_program
FROM program
JOIN program_subject using(program_id)
JOIN subject using(subject_id)
WHERE name_subject = 'Информатика';


-- 31.

SELECT name_subject,
		 count(enrollee_id) AS Количество,
		 max(result) AS Максимум,
		 min(result) AS Минимум,
		 round(avg(result), 1) AS Среднее
FROM enrollee_subject
JOIN subject using(subject_id)
GROUP BY  name_subject
ORDER BY  name_subject;

-- 32.

SELECT name_program
FROM program
JOIN program_subject using(program_id)
GROUP BY  name_program
HAVING MIN(min_result) >= 40
ORDER BY  name_program;

-- 33.

SELECT name_program,
		 plan
FROM program
WHERE plan IN 
	(SELECT max(plan)
	FROM program);




