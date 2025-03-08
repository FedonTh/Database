DROP DATABASE IF EXISTS project2024;
CREATE DATABASE project2024;
USE project2024;

SET @Current_DBA_User = "Kostas7428";

CREATE TABLE user(
	username VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	password VARCHAR(20) NOT NULL,
	name VARCHAR(25),
	lastname VARCHAR(35),
	reg_date DATETIME,
	email VARCHAR(30),
    PRIMARY KEY(username)
	);

CREATE TABLE employee(
	username VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	bio TEXT,
	sistatikes VARCHAR(35),
	certificates VARCHAR(35),
	PRIMARY KEY(username),
    CONSTRAINT ISAUSER1 FOREIGN KEY(username) REFERENCES user(username)
	ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE etairia(
	AFM CHAR(9) NOT NULL,
	DOY VARCHAR(30) NOT NULL,
	name VARCHAR(35),
	tel VARCHAR(10),
	street VARCHAR(15),
	num INT(11),
	city VARCHAR(45),
	country VARCHAR(15),
	PRIMARY KEY(AFM)
	);

CREATE TABLE project(
	candid VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	num TINYINT(4),
	descr TEXT,
	url VARCHAR(60),
	PRIMARY KEY(candid,num),
	CONSTRAINT YLOPOIEI FOREIGN KEY(candid) REFERENCES employee(username)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE languages(
	candid VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	lang SET('EN', 'FR', 'SP', 'GE', 'CH', 'GR') NOT NULL,
	PRIMARY KEY(candid),
	CONSTRAINT GLOSSES FOREIGN KEY(candid) REFERENCES employee(username)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE evaluator(
	username VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	exp_years TINYINT(4),
	firm CHAR(9) DEFAULT 'unknown' NOT NULL,
	PRIMARY KEY(username),
	CONSTRAINT ISAUSER2	FOREIGN KEY(username) REFERENCES user(username)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ERGAZETAI FOREIGN KEY(firm) REFERENCES etairia(AFM)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE job(
	id INT(11) NOT NULL,
	start_date DATE NOT NULL,
	salary FLOAT NOT NULL,
	position VARCHAR(60) NOT NULL,
	edra VARCHAR(60),
    evaluator VARCHAR(30) NOT NULL,
	announce_date DATETIME NOT NULL,
	submission_date DATE NOT NULL,
	PRIMARY KEY(id),
	CONSTRAINT ANAKOINONEI FOREIGN KEY(evaluator) REFERENCES evaluator(username)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE applies(
	cand_usrname VARCHAR(30) DEFAULT 'unknown' NOT NULL,
	job_id INT(11) NOT NULL,
    PRIMARY KEY(cand_usrname, job_id),
	CONSTRAINT YPOBALLON FOREIGN KEY(cand_usrname) REFERENCES employee(username)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT YPOBOLLI FOREIGN KEY(job_id) REFERENCES job(id)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE subject(
	title VARCHAR(36) DEFAULT 'unknown' NOT NULL,
	descr TINYTEXT,
	belongs_to VARCHAR(36),
	PRIMARY KEY(title),
	CONSTRAINT ANIKEISE FOREIGN KEY(belongs_to) REFERENCES subject(title)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE requires(
	job_id INT(11) NOT NULL,
	subject_title VARCHAR(36) NOT NULL,
	PRIMARY KEY(job_id,subject_title),
	CONSTRAINT APAITEITAISE FOREIGN KEY(job_id) REFERENCES job(id)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT APAITEITAI FOREIGN KEY(subject_title) REFERENCES subject(title)
	ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE degree(
	titlos VARCHAR(150) NOT NULL,
	idryma VARCHAR(150) NOT NULL,
	bathmida ENUM('BSc', 'MSc', 'PhD') NOT NULL,
	PRIMARY KEY(titlos,idryma)
	);

CREATE TABLE has_degree(
	degr_title VARCHAR(150) NOT NULL,
	degr_idryma VARCHAR(150) NOT NULL,
	cand_usrname VARCHAR(30) NOT NULL,
	etos YEAR(4) NOT NULL,
	grade FLOAT,
	PRIMARY KEY(degr_title, degr_idryma, cand_usrname),
    CONSTRAINT STOIXEIA FOREIGN KEY(degr_title, degr_idryma) REFERENCES degree(titlos, idryma)
	ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT KATOXOS FOREIGN KEY(cand_usrname) REFERENCES employee(username)
    ON DELETE CASCADE ON UPDATE CASCADE
    );
    
DROP TABLE IF EXISTS Istoriko;
CREATE TABLE Istoriko(

    evaluator1 VARCHAR(30), 
    evaluator2 VARCHAR(30),
    employee VARCHAR(30),
    job_id INT(11),
    state ENUM('Complete') NOT NULL,
    bathmos FLOAT,
    aitisi_id INT(10) AUTO_INCREMENT,
	
    PRIMARY KEY(aitisi_id)
    ); 
    

DROP TABLE IF EXISTS DBA;
CREATE TABLE DBA(

	username VARCHAR(30),
    start_date DATE NOT NULL,
    end_date DATE,
    PRIMARY KEY(username),
    CONSTRAINT ISAUSER3 FOREIGN KEY(username) REFERENCES user(username)
    ON DELETE CASCADE ON UPDATE CASCADE
    );
    
DROP TABLE IF EXISTS log;
CREATE TABLE log(

	action ENUM('Insert', 'Update', 'Delete') NOT NULL,
    pinakas ENUM('job', 'user', 'degree') NOT NULL,
    time DATETIME NOT NULL,
    user_name VARCHAR(30),
    log_id INT AUTO_INCREMENT,
    
    PRIMARY KEY(log_id)
    );

    
    
ALTER TABLE job RENAME COLUMN evaluator TO evaluator1;
ALTER TABLE job ADD evaluator2 VARCHAR(30);
ALTER TABLE job ADD CONSTRAINT EINAIEVAL FOREIGN KEY(evaluator2) REFERENCES evaluator(username);

ALTER TABLE applies ADD status ENUM('Active', 'Complete', 'Canceled') NOT NULL;
ALTER TABLE applies ADD bathmos1 TINYINT(4);
ALTER TABLE applies ADD bathmos2 TINYINT(4);
ALTER TABLE applies ADD apply_date DATE;



DROP PROCEDURE IF EXISTS Evaluation_Check; 
DELIMITER $
CREATE PROCEDURE Evaluation_Check (IN EvaluatorUsr VARCHAR(30), IN EmployeeUsr VARCHAR(30), IN JobID INT, OUT result INT)
BEGIN

 DECLARE points_msc INT;		
 DECLARE points_bsc INT;
 DECLARE points_phd INT;
 DECLARE lang_points INT;
 DECLARE project_points INT;  

 DECLARE num1 INT;
 DECLARE num2 INT;
 DECLARE bathm1 INT;
 DECLARE bathm2 INT;

 SET points_msc = 0;
 SET points_bsc = 0;
 SET points_phd = 0;
 SET lang_points = 0;
 SET project_points = 0; 
 SET result = 0; #Εάν κάνενα if δεν ενεργοποιηθεί το result θα είναι στο τέλος 0

 SELECT COUNT(*) INTO num1 FROM applies INNER JOIN job ON applies.job_id = job.id	#Υπολογισμός ύπαρξης αίτησης, και εάν υπάρχει ατνιστοίχηση με κάποιον evaluator και από τις δύο στήλες evaluator στο job
 WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID AND job.evaluator1 = EvaluatorUsr;
 SELECT COUNT(*) INTO num2 FROM applies INNER JOIN job ON applies.job_id = job.id
 WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID AND job.evaluator2 = EvaluatorUsr;
 
  IF (num1 > 0) THEN  #Εάν υπάρχει αντιστοίχηση από στήλη 1

  SELECT bathmos1 INTO bathm1 FROM applies INNER JOIN job ON applies.job_id = job.id
  WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID AND job.evaluator1 = EvaluatorUsr; 

    IF (bathm1 IS NOT NULL) THEN  #Έλεγχος βαθμού στο αντίστοιχο πεδίο του
   
    SET result = bathm1;
   
    ELSE  #Κριτήριο προσώντων
     SELECT COUNT(*) INTO points_bsc FROM degree
     INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
     INNER JOIN employee ON employee.username = has_degree.cand_usrname
     WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'BSc';
    
     SELECT COUNT(*) INTO points_msc FROM degree
     INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
     INNER JOIN employee ON employee.username = has_degree.cand_usrname
     WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'MSc';
    
     SELECT COUNT(*) INTO points_phd FROM degree
     INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
     INNER JOIN employee ON employee.username = has_degree.cand_usrname
     WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'Phd';
    
     SELECT COUNT(*) INTO project_points FROM project 
     WHERE candid = EmployeeUsr;
	
   	SELECT BIT_COUNT(lang) INTO lang_points FROM languages
     WHERE candid = EmployeeUsr;	
    
     SET result = 1 * points_bsc + 2 * points_msc + 3 *  points_phd + project_points + lang_points;
   
    END IF;
   END IF;
   IF (num2 > 0) THEN #Εάν υπάρχει αντιστοίχηση από στήλη 2

    SELECT bathmos2 INTO bathm2 FROM applies INNER JOIN job ON applies.job_id = job.id
    WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID AND job.evaluator2 = EvaluatorUsr; 

    IF (bathm2 IS NOT NULL) THEN #Έλεγχος βαθμού στο αντίστοιχο πεδίο του
   
     SET result = bathm2;
   
     ELSE #Κριτήριο προσώντων 
      SELECT COUNT(*) INTO points_bsc FROM degree
      INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
      INNER JOIN employee ON employee.username = has_degree.cand_usrname
      WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'BSc';
     
      SELECT COUNT(*) INTO points_msc FROM degree
      INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
      INNER JOIN employee ON employee.username = has_degree.cand_usrname
      WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'MSc';
     
      SELECT COUNT(*) INTO points_phd FROM degree
      INNER JOIN has_degree ON degree.titlos = has_degree.degr_title AND degree.idryma = has_degree.degr_idryma
      INNER JOIN employee ON employee.username = has_degree.cand_usrname
      WHERE has_degree.cand_usrname = EmployeeUsr AND degree.bathmida = 'Phd';
     
      SELECT COUNT(*) INTO project_points FROM project 
      WHERE candid = EmployeeUsr;
 	
    	SELECT BIT_COUNT(lang) INTO lang_points FROM languages
      WHERE candid = EmployeeUsr;	
     
      SET result = 1 * points_bsc + 2 * points_msc + 3 *  points_phd + project_points + lang_points;
    
    END IF;   
 END IF;
 END$
DELIMITER ;



DROP PROCEDURE IF EXISTS Application;
DELIMITER $
CREATE PROCEDURE Application (IN EmployeeUsr VARCHAR(30), IN JobID INT, IN input ENUM('i','c','a'))

BEGIN
DECLARE stat ENUM('Active', 'Complete', 'Canceled'); 
DECLARE eval1 VARCHAR(30); 
DECLARE eval2 VARCHAR(30); 
DECLARE etairia1 CHAR(9);
DECLARE currDate DATE;

SET currDATE = CURDATE(); #Επιλογή σημερινής ημερομηνίας για την αίτηση

SELECT status INTO stat FROM applies WHERE applies.cand_usrname = EmployeeUsr AND job_id = JobID; #Εισαγωγή status της αίτησης
  
SELECT evaluator1, evaluator2 INTO eval1, eval2 FROM job #Εισαγωγή των δύο evaluator της αίτησης από το job (εάν υπάρχουν)
WHERE job.id = JobID; 

CASE (input)
WHEN 'i' THEN
	IF (eval1 IS NOT NULL AND eval2 IS NOT NULL) THEN
 		INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) values (EmployeeUsr, JobID, null, null, null, currDate); #Δημιουργία αίτησης
        SELECT "Your form has been applied successfully";
	ELSEIF (eval1 IS NOT NULL AND eval2 IS NULL) THEN
		SELECT firm INTO etairia1 FROM evaluator WHERE username = eval1; #Εισαγωγή της εταιρίας του evaluator1
		SELECT username INTO eval2 FROM evaluator INNER JOIN etairia ON evaluator.firm = etairia.AFM #Εύρεση του evaluator2 από την ίδια εταιρία με τον evaluator1
        WHERE etairia.AFM = etairia1 LIMIT 1;
        UPDATE job SET evaluator2 = eval2 WHERE job.id = JobID; #Εισαγωγή του evaluator2
        INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) values (EmployeeUsr, JobID, null, null, null, currDate); #Δημιουργία αίτησης
        SELECT "Your form has been applied successfully after additional evaluator assignment";
	END IF;
WHEN 'c' THEN
	IF(stat = 'Canceled' OR stat IS NULL) THEN  #Έλεγχος της αίτησης εάν υπάρχει ή εάν είναι ήδη ακυρωμένη 
		 SIGNAL SQLSTATE VALUE '45000' 
		SET MESSAGE_TEXT = "Your form is already canceled or it may not exist"; 
	ELSEIF(stat = 'Active') THEN
		UPDATE applies SET status = 'Canceled' WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID;	#Ακύρωση της αίτησης
		SELECT "Your form has been canceled" ; #Εκτύπωση μηνύματος ακύρωσης της αίτησης
	END IF;
WHEN 'a' THEN
	IF(stat = 'Active' OR stat IS NULL) THEN
		SIGNAL SQLSTATE VALUE '45000' 
		SET MESSAGE_TEXT = "Your form is already active or it may not exist";
	ELSEIF(stat = 'Canceled') THEN
    UPDATE applies SET status = 'Active' WHERE applies.cand_usrname = EmployeeUsr AND applies.job_id = JobID; #Ενεργοποίηση της αίτησης
		SELECT "Your form has been activated"; #Εκτύπωση μηνύματος ενεργοποίησης της αίτησης
	END IF;
ELSE
	SELECT "Unknown option selected"; 
END CASE;
END$
DELIMITER ;



DROP PROCEDURE IF EXISTS Elegxos_thesis; 
DELIMITER $
CREATE PROCEDURE Elegxos_thesis (IN id_job INT(11), OUT selected_candidate VARCHAR(30))						
BEGIN

DECLARE final_result FLOAT; 
DECLARE max_result FLOAT;

DECLARE result1 INT;
DECLARE result2 INT;
DECLARE eval1 VARCHAR(30); 
DECLARE eval2 VARCHAR(30); 
DECLARE candidate VARCHAR(30);
DECLARE stat ENUM('Active', 'Complete', 'Canceled');
DECLARE finished_flag INT; 

DECLARE cand_cursor CURSOR FOR  #Ορισμός cursor
SELECT cand_usrname,status FROM applies WHERE applies.job_id = id_job;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished_flag = 1;

# Επιλογή των evaluators της ζητούμενης θέσης 
SELECT evaluator1, evaluator2 INTO eval1, eval2 FROM job WHERE job.id = id_job;
SET max_result = 0; 

OPEN cand_cursor;
SET finished_flag = 0;
FETCH cand_cursor INTO candidate,stat;
WHILE (finished_flag = 0) DO

       IF (stat = 'Canceled') THEN   #Σε περίπτωση ακυρωμένης αίτησης, εισαγωγή στο ιστορικό με βαθμό 0
       INSERT INTO Istoriko(evaluator1, evaluator2, employee, job_id, state, bathmos) VALUES (eval1, eval2, candidate, id_job, 'Complete', '0');
       ELSEIF (stat = 'Active') THEN   #Σε περίπτωση ενεργής αίτησης
	   	 CALL Evaluation_Check(eval1, candidate , id_job, result1);  #3.1.3.1.
	     CALL Evaluation_Check(eval2, candidate , id_job, result2);  #3.1.3.1.
     	 SET final_result = (result1 + result2) / 2;
	     IF (final_result > max_result)  THEN  #Εάν βρεθεί μεγαλύτερος βαθμός αντικατάσταση αυτού και του username του υπαλλήλου, και αποθήκευση στο ιστορικό
		  SET max_result = final_result; 
		  SET selected_candidate = candidate;
          INSERT INTO Istoriko(evaluator1, evaluator2, employee, job_id, state, bathmos) VALUES (eval1, eval2, selected_candidate, id_job, 'Complete', final_result);
		  ELSEIF (final_result =  max_result) THEN 	  #Σε περίπτωση ισοβαθμίας επιλογή της νωρίτερης αίτησης, και αποθήκευση στο ιστορικό
	 		  SELECT cand_usrname INTO selected_candidate FROM applies WHERE applies.job_id = id_job 
              AND applies.status = 'Active' AND final_result = max_result
              ORDER BY apply_date ASC LIMIT 1;
              INSERT INTO Istoriko(evaluator1, evaluator2, employee, job_id, state, bathmos) VALUES (eval1, eval2, selected_candidate, id_job, 'Complete', final_result);
         END IF; 		
       END IF;  
FETCH cand_cursor INTO candidate,stat;
END WHILE; 
CLOSE cand_cursor; 
DELETE FROM applies WHERE applies.job_id = id_job; #Διαγραφή των σχετικών αιτήσεων από τον applies μετά την διαδικασία για εκείνη την θέση
END$
DELIMITER ;



DROP PROCEDURE IF EXISTS Eggrafes;
DELIMITER $
CREATE PROCEDURE Eggrafes(IN numRecords INT)
BEGIN
    DECLARE i INT;
    SET i = 0;
    
    WHILE i < numRecords DO
        INSERT INTO Istoriko (evaluator1, evaluator2, employee, job_id, state, bathmos)
        VALUES (
            CONCAT('Evaluator', FLOOR(1 + (RAND() * 10000))),  #Τυχαίο username για evaluator1
            CONCAT('Evaluator', FLOOR(1 + (RAND() * 10000))),  #Τυχαίο username για evaluator2
            CONCAT('Employee', FLOOR(1 + (RAND() * 100000))),  #Τυχαίο username για employee
            FLOOR(1 + (RAND() * 1000000000)),                  #Τυχαίο job_id
            'Complete',                                        #Κατάσταση 'Complete'
            FLOOR(1 + (RAND() * 20))                           #Τυχαίος βαθμός αξιολόγησης
        );
        SET i = i + 1;
    END WHILE;
END$

DELIMITER ;


DROP PROCEDURE IF EXISTS BathmosRange;
DELIMITER $
CREATE PROCEDURE BathmosRange(IN min_bathm FLOAT, IN max_bathm FLOAT)
BEGIN

    SELECT employee, job_id FROM Istoriko WHERE Istoriko.bathmos >= min_bathm AND Istoriko.bathmos <= max_bathm;
    
END$
DELIMITER ;


DROP PROCEDURE IF EXISTS EvalApplications;
DELIMITER $
CREATE PROCEDURE EvalApplications(IN evalusr VARCHAR(30))
BEGIN

	SELECT employee, job_id FROM Istoriko WHERE evaluator1 = evalusr OR evaluator2 = evalusr;
    
END$
DELIMITER ;   
       




DROP TRIGGER IF EXISTS ProjectCounter;
DELIMITER $
CREATE TRIGGER ProjectCounter
BEFORE INSERT ON Project
FOR EACH ROW
BEGIN

DECLARE MaxNum INT(2);
SELECT MAX(num) INTO MaxNum
FROM Project
WHERE candid = NEW.candid;

IF MaxNum is NULL THEN
SET MaxNum = 0;
END iF;

SET NEW.num = MaxNum + 1;
END$
DELIMITER ;

DROP TRIGGER IF EXISTS Nea_Aitisi; #3.1.4.2.
DELIMITER $
CREATE TRIGGER Nea_Aitisi 
BEFORE INSERT ON applies
FOR EACH ROW
BEGIN 

DECLARE NumOfForms INT;
DECLARE diff INT; 
DECLARE start DATE;

SELECT start_date INTO start FROM job WHERE NEW.job_id = job.id;

SET diff = DATEDIFF(start,NEW.apply_date);
IF diff < 15 THEN 
SIGNAL SQLSTATE VALUE '45000' 
SET MESSAGE_TEXT = 'Invalid date! Must be at least 15 days before the start date.';
END IF;

SELECT COUNT(*) INTO NumOfForms FROM applies
WHERE NEW.cand_usrname = cand_usrname AND status = "Active";

IF NumOfForms is NULL THEN
SET NumOfForms = 0;
END iF;

IF NumOfForms >= 3 THEN 
	SIGNAL SQLSTATE VALUE '45000' 
	SET MESSAGE_TEXT = 'Max number of active forms.';
END IF;	

SET NEW.status = "Active";
END$
DELIMITER ;

DROP TRIGGER IF EXISTS Aitisi_check; #3.1.4.3.
DELIMITER $
CREATE TRIGGER Aitisi_check 
BEFORE UPDATE ON applies
FOR EACH ROW
BEGIN 

DECLARE NumOfForms INT;
DECLARE curr_date DATE;
DECLARE diff INT; 
DECLARE start DATE;

SET curr_date = CURDATE();
SELECT start_date INTO start FROM job WHERE NEW.job_id = job.id;
SET diff = DATEDIFF(start,curr_date);

IF NEW.status = "Canceled" AND OLD.status = "Active" THEN
  IF diff < 10 THEN 
  SIGNAL SQLSTATE VALUE '45000' 
  SET MESSAGE_TEXT = 'Invalid date! Must be at least 10 days before the start date to cancel.';
  END IF;
END IF;

SELECT COUNT(*) INTO NumOfForms FROM applies
WHERE NEW.cand_usrname = cand_usrname AND status = "Active";

IF NumOfForms is NULL THEN
SET NumOfForms = 0;
END iF;

IF NEW.status = "Active" AND OLD.status = "Canceled" THEN
  IF NumOfForms >= 3 THEN
  SIGNAL SQLSTATE VALUE '45000' 
  SET MESSAGE_TEXT = 'Max number of active forms, unable to apply more.';
  END IF;  
END IF;

END$
DELIMITER ;




DROP TRIGGER IF EXISTS log_user_insert;
DELIMITER $
CREATE TRIGGER log_user_insert
AFTER INSERT ON user
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Insert', 'user', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_user_update;
DELIMITER $
CREATE TRIGGER log_user_update
AFTER UPDATE ON user
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Update', 'user', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_user_delete;
DELIMITER $
CREATE TRIGGER log_user_delete
AFTER DELETE ON user
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Delete', 'user', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;


DROP TRIGGER IF EXISTS log_job_insert;
DELIMITER $
CREATE TRIGGER log_job_insert
AFTER INSERT ON job
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Insert', 'job', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_job_update;
DELIMITER $
CREATE TRIGGER log_job_update
AFTER UPDATE ON job
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Update', 'job', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_job_delete;
DELIMITER $
CREATE TRIGGER log_job_delete
AFTER DELETE ON job
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Delete', 'job', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;


DROP TRIGGER IF EXISTS log_degree_insert;
DELIMITER $
CREATE TRIGGER log_degree_insert
AFTER INSERT ON degree
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Insert', 'degree', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_degree_update;
DELIMITER $
CREATE TRIGGER log_degree_update
AFTER UPDATE ON degree
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Update', 'degree', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

DROP TRIGGER IF EXISTS log_degree_delete;
DELIMITER $
CREATE TRIGGER log_degree_delete
AFTER DELETE ON degree
FOR EACH ROW
BEGIN

	INSERT INTO log(action, pinakas, time, user_name) VALUES ('Delete', 'degree', NOW(), @Current_DBA_User);
    
END$    
DELIMITER ;

    

DELETE FROM user;
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Tasos32', '24092', 'Tasos', 'Apostolakis', '2012-06-29 13:05:32', 'TasosApol@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Mitsos256', '23652', 'Dimitris', 'Antonopoulos', '2016-08-20 16:47:23', 'DimitrisAnt@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Maria2940', '85930', 'Maria', 'Kanellopoulou', '2017-02-14 18:34:52', 'MariaKan@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Antonis111', '45810', 'Antonis', 'Polixronopoulos', '2013-04-22 12:15:26', 'AntonisPol95@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Basil343', '13513', 'Basilis', 'Georgakopoulos', '2016-11-07 20:38:07', 'BasilisGeorg@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Sofia455', '57380', 'Sofia', 'Foteinopoulou', '2014-05-21 15:42:28', 'SofiaFot35@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Foteini493', '86593', 'Foteini', 'Psaxou', '2015-04-11 21:46:37', 'FoteiniPsax23@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Eleni444', '68392', 'Eleni', 'Paraskeui', '2018-06-15 16:34:49', 'EleniParask212@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Giorge12', '75748', 'Giorgos', 'Papanikolaou', '2011-02-27 22:19:35', 'GiorgosPapanik@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Harris55', '76849', 'Haris', 'Adamopoulos', '2013-08-30 21:01:51', 'HarrisAdam13@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Aris8888', '97393', 'Aristeidis', 'Mpousias', '2014-03-18 17:23:20', 'ArisMpous88@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Ioanna90', '48392', 'Ioanna', 'Rodopoulou', '2017-10-19 17:46:03', 'IoannaRodop@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Koulouris89', '16437', 'Tasos', 'Koulouris', '2019-02-19 14:51:06', 'TasosKoulour@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Baggelis3', '31645', 'Baggelis', 'Toliopoulos', '2018-12-09 16:27:29', 'BaggToliop@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Kostas7428', '16751', 'Kostas', 'Papadopoulos', '2018-11-12 11:06:41', 'KostasPap@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Anna467', '91372', 'Anna', 'Georgakopoulou', '2017-06-14 18:25:52', 'AnnaGeorg@gmail.com');
INSERT INTO user(username, password, name, lastname, reg_date, email) VALUES ('Panos4242', '12749', 'Panagiotis', 'Nikolakopoulos', '2016-12-20 10:59:59', 'PanosNik@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES ('ann','042240' , 'Anna' , 'Georgiou' , '2019-06-30' , 'ann06@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES ('mary', '84266248' , 'Maria' , 'Papadopoulou' , '2015-09-14' , 'marypapad@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('anas', '7899877', 'Georgia', 'Anastasiou', '2019-03-13', 'geanas2019@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('pangian', '52146799', 'Panagiotis', 'Giannopoylos', '2017-12-27', 'gianop2017@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('AndArg', '0511500', 'Andriana', 'Argiropoulou', '2022-2-20', 'andriana22@hotmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('marVas', '973197', 'Maria', 'Vasilopoulou', '2005-8-20', 'maria97@yahoo.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('eirini', '54789', 'Eirini', 'Papadopoulou', '2018-09-14', 'eirinipad@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('ioannap', '123987', 'Ioanna', 'Papadopoulou', '2017-08-31', 'ioanna20@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('spyrosAnas', '54327', 'Spyros', 'Anastasiou', '2020-12-20', 'spirAnas@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('kall', '78513', 'Kalliopi', 'Papandreou', '2018-06-29', 'kalliopi@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('mariel', '47529', 'Eleni', 'Marinou', '2023-07-24', 'mariel@gmail.com');
INSERT INTO user (username , password , name , lastname , reg_date , email ) VALUES('kate', '0359535', 'Katerina', 'Kanelopoulou', '2024-02-01', 'katerina06@gmail.com');

DELETE FROM DBA;
INSERT INTO DBA(username, start_date, end_date) VALUES ('Kostas7428', '2022-03-14', NULL);
INSERT INTO DBA(username, start_date, end_date) VALUES ('Anna467', '2023-02-08', NULL);
INSERT INTO DBA(username, start_date, end_date) VALUES ('Panos4242', '2021-03-14', '2023-12-03');


DELETE FROM employee;
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Tasos32', 'Tasos_cv_gia_MixanikosHY.pdf', 'Sistatiki_gia_Taso.pdf', 'Engilsh Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Mitsos256', 'Mitsos_cv_gia_Oikonomika.docx', 'Sistatiki_gia_Mitso.pdf', 'Engilsh Cert, French Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Maria2940', 'Maria_cv_gia_Pliroforiki.doc', 'Sistatiki_gia_Maria.doc', 'Engilsh Cert, Greek Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Antonis111', 'Antonis_cv_gia_Biologia.pdf', 'Sistatiki_gia_Antoni.pdf', 'Engilsh Cert, Chinese Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Basil343', 'Basil_cv_gia_Pliroforiki.doc', 'Sistatiki_gia_Basil.pdf', 'Engilsh Cert, French Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Sofia455', 'Sofia_cv_gia_Managing.pdf', 'Sistatiki_gia_Sofia.doc', 'Engilsh Cert, Spanish Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('Foteini493', 'Foteini_cv_gia_Iatriki.doc', 'Sistatiki_gia_Foteini.pdf', 'Engilsh Cert, German Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('mary', 'mary.cv', 'Sistatiki_gia_mary.pdf', 'Engilsh Cert, Spanish Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('kall', 'kall.cv', 'Sistatiki_gia_kall.pdf', 'English Cert, Greek Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('mariel', 'mariel.cv', 'Sistatiki_gia_mariel.pdf', 'English Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('kate', 'kate.cv', 'Sistatiki_gia_kate.pdf', 'French Cert, Chinese Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('spyrosAnas', 'spyrosAnas.cv', 'Sistatiki_gia_spyrosAnas.pdf', 'French Cert');
INSERT INTO employee(username, bio, sistatikes, certificates) VALUES ('ioannap', 'ioannap.cv', 'Sistatiki_gia_ioannap.pdf', 'Italian Cert');


DELETE FROM project;
INSERT INTO project(candid, num, descr, url) VALUES ('Tasos32', null, 'Anaptiksi Logismikou gia Analisi Dedomenon', 'https://github.com/tasos32/DataAnalysis/project1');
INSERT INTO project(candid, num, descr, url) VALUES ('Mitsos256', null, 'Meleti Oikonomikon Problepseon gia Etaireies', 'https://github.com/mitsos256/economicPredictionsInBusinesses');
INSERT INTO project(candid, num, descr, url) VALUES ('Maria2940', null, 'Sxediasmos Diktiakon Ipologistikon Sistimaton', 'https://github.com/maria2940/network-design');
INSERT INTO project(candid, num, descr, url) VALUES ('Antonis111', null, 'Melesi Biologikon Leitourgion', 'https://github.com/antonis111/biologic-funtions');
INSERT INTO project(candid, num, descr, url) VALUES ('Basil343', null, 'Programmatismos Mixanismou gia Ananeosimes Piges Energeias', 'https://github.com/basil343/renewable-energy-programm');
INSERT INTO project(candid, num, descr, url) VALUES ('Sofia455', null, 'Provoli kai Organosi Ekdiloseon', 'https://github.com/sofia455/event-management');
INSERT INTO project(candid, num, descr, url) VALUES ('Foteini493', null, 'Meleti kai Anaptiksi Therapeutikon Protipon gia Astheneies', 'https://github.com/foteini493/medical-treatment');
INSERT INTO project(candid, num, descr, url) VALUES ('Foteini493', null, 'Dimosies Sxeseis kai Diaxeirisi Simvanton', 'https://github.com/foteini493/public-relations');
INSERT INTO project(candid, num, descr, url) VALUES ('mary', null, 'Texnologia diaxeirisis epixeiriseon', 'https://github.com/mary/technologyForBusinessManagement');
INSERT INTO project(candid, num, descr, url) VALUES ('ioannap', null, 'analisiOikonomikonDedomenon', 'https://github.com/kall/economics/analysis');
INSERT INTO project(candid, num, descr, url) VALUES ('mariel', null, 'Antimetopisi Agxous se mathites', 'https://github.com/mariel/schoolPsychlogy');
INSERT INTO project(candid, num, descr, url) VALUES ('kate', null, 'Anaptiksi neon farmakeutikon proionton', 'https://github.com/kate/pharmaceuticalProducts');
INSERT INTO project(candid, num, descr, url) VALUES ('spyrosAnas', null, 'Logistiki ypostiriksi se epixeiriseis', 'https://github.com/spyrosAnas/accountancy');
INSERT INTO project(candid, num, descr, url) VALUES ('mary', null, 'Anaptiksi eksipnou logismikou', 'https://github.com/ioannap/softwareDevelopment');
INSERT INTO project(candid, num, descr, url) VALUES ('mariel', null, 'Ereuna se psyxologia', 'https://github.com/mariel/psychologyResearch');



DELETE FROM languages;
INSERT INTO languages(candid, lang) VALUES ('Tasos32', 'EN');
INSERT INTO languages(candid, lang) VALUES ('Mitsos256', 'EN,FR');
INSERT INTO languages(candid, lang) VALUES ('Maria2940', 'EN,GR');
INSERT INTO languages(candid, lang) VALUES ('Antonis111', 'EN,CH');
INSERT INTO languages(candid, lang) VALUES ('Foteini493', 'EN,GR');
INSERT INTO languages(candid, lang) VALUES ('mariel', 'EN,GE,GR');
INSERT INTO languages(candid, lang) VALUES ('kall', 'EN,GE,SP,GR');
INSERT INTO languages(candid, lang) VALUES ('ioannap', 'EN,GE,CH,GR');
INSERT INTO languages(candid, lang) VALUES ('spyrosAnas', 'EN,GR,SP,FR');

DELETE FROM etairia;
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('794615825', 'doy_athinon', 'XalkiasAE' , '2104960394', 'Stadiou', '35' , 'Athina' , 'Ellada');
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('461579813', 'doy_athinon', 'PagourisAE' , '2107986427', 'El.Benizelou', '60' , 'Athina' , 'Ellada');
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('538276491', 'doy_patron', 'BillAE' , '2610658394', 'Korinthou', '100' , 'Patra' , 'Ellada');
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('200344551', 'doy_kritis', 'SuperMarketAE' , '2017855477', 'Epidavrou', '2' , 'Xania' , 'Ellada');
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('339855146', 'doy_patron', 'PharmacyAE' , '2010255855', 'Akrotiriou', '149' , 'Patra' , 'Ellada');
INSERT INTO etairia(AFM, DOY, name, tel, street, num, city, country) VALUES ('126647813', 'doy_thessalinikis', 'FashionAE' , '2016328127', 'Stadiou', '235' , 'Thessaloniki' , 'Ellada');

DELETE FROM evaluator;
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Eleni444', '4', '794615825');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Giorge12', '6', '794615825');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Harris55', '7', '461579813');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Aris8888', '2', '461579813');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Ioanna90', '11', '461579813');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Koulouris89', '15', '538276491');
INSERT INTO evaluator(username, exp_years, firm) VALUES ('Baggelis3', '10', '538276491');
INSERT INTO evaluator(username, exp_years, firm) VALUES('ann', '9', '200344551');	
INSERT INTO evaluator(username, exp_years, firm) VALUES('anas', '8', '200344551');
INSERT INTO evaluator(username, exp_years, firm) VALUES('pangian', '16', '339855146');
INSERT INTO evaluator(username, exp_years, firm) VALUES('AndArg', '1', '339855146');
INSERT INTO evaluator(username, exp_years, firm) VALUES('marVas', '4', '126647813');
INSERT INTO evaluator(username, exp_years, firm) VALUES('eirini', '4', '126647813');


DELETE FROM job;
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('342768', '2024-09-20', '1300', 'Entry-level', 'Patra', 'Eleni444', 'Giorge12', '2019-11-20 23:53:12', '2024-02-01');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('462574', '2024-08-30', '1400', 'Entry-level', 'Athina', 'Giorge12', null, '2018-10-13 21:23:45', '2023-01-09');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('956758', '2024-11-19', '1450', 'Director', 'Thessaloniki', 'Harris55', null, '2020-04-19 16:44:29', '2024-08-17');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('134256', '2024-11-04', '1250', 'Individual Contributor', 'Patra', 'Ioanna90', null, '2019-09-26 14:58:06', '2024-12-07');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('734629', '2024-10-30', '1500', 'Entry-level', 'Patra', 'Aris8888', null, '2019-05-15 18:34:26', '2024-09-08');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('468514', '2024-09-26', '1300', 'Individual Contributor', 'Patra', 'Ioanna90', null, '2021-06-28 20:11:53', '2025-05-24');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('854623', '2024-12-03', '1550', 'Vice-Precident', 'Athina', 'Koulouris89', null, '2019-08-30 17:30:09', '2024-03-04');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES ('234659', '2024-09-29', '1350', 'Entry-level', 'Patra', 'Baggelis3', null, '2018-11-06 11:06:49', '2024-09-10');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('101', '2026-04-10', '1000', 'Marketing Manager', 'Thessaloniki',  'eirini', null, '2026-02-08 12:30:47', '2026-03-09');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('102', '2025-12-10', '1400', 'Director ', 'Xania',  'anas', null, '2025-10-10 17:00:47', '2025-11-10');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('103', '2025-04-29', '1000', 'Entry level', 'Athens', 'pangian', null, '2025-02-28 9:47:59', '2025-03-29');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('104', '2026-07-06', '1500', 'Individual Contributor', 'Pyrgos', 'AndArg', null, '2026-05-06 11:06:20', '2026-06-06');
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('105', '2025-05-14', '2000', 'Director', 'Tripoli', 'ann', null, '2025-03-14 17:35:09', '2025-04-14'); 
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('106', '2024-09-10', '1000', 'Entry level', 'Rodos', 'ann', null, '2025-07-21 20:58:50', '2025-08-21'); 
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('107', '2026-11-03', '1000', 'Entry level', 'Patra', 'anas', null,'2026-09-03 8:30:54', '2026-10-03'); 
INSERT INTO job(id, start_date, salary, position, edra, evaluator1, evaluator2, announce_date, submission_date) VALUES('108', '2025-05-30', '1100', 'Entry level', 'Sparti', 'pangian', null, '2025-04-30 1:49:20', '2025-03-30'); 
 


DELETE FROM applies;
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Tasos32', '342768', null, '11', '14', '2024-08-01');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Mitsos256', '462574', null, null, null, '2024-08-02');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Maria2940', '956758', null, null, null, '2024-08-03');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Antonis111', '134256', null, null, null, '2024-08-04');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Basil343', '734629', null, null, null, '2024-08-05');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Sofia455', '468514', null, null, null, '2024-08-06');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Sofia455', '342768', null, '16', '17', '2024-08-07');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Sofia455', '234659', null, null, null, '2024-08-08');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Sofia455', '134256', null, null, null, '2024-08-09');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Foteini493', '234659', null, null, null, '2024-08-10');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Foteini493', '342768', null, null, null, '2024-08-10');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES ('Antonis111', '342768', null, null, null, '2024-08-04');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('mary', '102', null, null, null, '2013-04-30');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('kall', '103', null, null, null, '2014-06-05');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('mariel', '104', null, null, null, '2018-07-14');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('kate', '105', null, null, null, '2009-03-11');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('kate', '106', null, null, null, '2010-04-27');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('spyrosAnas', '107', null, null, null, '2016-07-26');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('ioannap', '108', null, null, null, '2011-07-18');
INSERT INTO applies(cand_usrname, job_id, status, bathmos1, bathmos2, apply_date) VALUES  ('kall', '104', null, null, null, '2026-07-01');



DELETE FROM degree;
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Mixanikon H/Y', 'Panepistimio Patron', 'MSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Oikonomikon', 'Panepistimio Athinon', 'MSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Pliroforiki', 'Panepistimio Xanion', 'BSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Biologia', 'Panepistimio Ioanninon', 'BSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Iatriki', 'Panepistimio Thesallonikis', 'PhD');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Koinonikon Epistimon', 'Panepistimio Korinthou', 'BSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Computer Engineering', 'Panepistimio Patron', 'BSc'); 
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Chemistry', 'Panepistimio Thessalias', 'MSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Electrical  Engineering', 'Panepistimio Kritis', 'BSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Veterinary', 'Kapodistriako Panepistimio', 'MSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Economics', 'Panepistimio Peloponnisou', 'BSc');
INSERT INTO degree(titlos, idryma, bathmida) VALUES ('Medicine', 'Panepistimio Patron', 'MSc');



DELETE FROM has_degree;
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Mixanikon H/Y', 'Panepistimio Patron', 'Tasos32', '2018', '8.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Oikonomikon', 'Panepistimio Athinon', 'Mitsos256', '2021', '7.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Pliroforiki', 'Panepistimio Xanion', 'Maria2940', '2022', '8');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Biologia', 'Panepistimio Ioanninon', 'Antonis111', '2020', '6.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Iatriki', 'Panepistimio Thesallonikis', 'Foteini493', '2019', '7');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Koinonikon Epistimon', 'Panepistimio Korinthou', 'Foteini493', '2023', '7.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Computer Engineering', 'Panepistimio Patron', 'kall', '2018', '7.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Electrical  Engineering', 'Panepistimio Kritis', 'mary', '2009', '7.5');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Medicine', 'Panepistimio Patron', 'kate', '2000', '7');
INSERT INTO has_degree(degr_title, degr_idryma, cand_usrname, etos, grade) VALUES ('Economics', 'Panepistimio Peloponnisou', 'ioannap', '1996', '7');


DELETE FROM subject;
INSERT INTO subject(title, descr, belongs_to) VALUES ('Pliroforiki', 'Texnologia H/Y kai Logismikou', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Diktia', 'Diktia ypologiston kai Epikoinonion', 'Pliroforiki');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Asfaleia Pliroforion', 'Prostasia Dedomenon kai Kibernoasfaleia', 'Diktia');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Fisiki', 'Epistimi ton Ilikon', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Kataskeui Domon', 'Meleti kai Kataskeui Domon', 'Pliroforiki');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Energeiaki Texnologia', 'Ananeosimes Piges Energeias', 'Fisiki');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Iatriki', 'Meleti kai Therapeia Asthenion', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Xeirourgiki', 'Xeirourgikes Epembaseis kai Therapeia', 'Iatriki');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Data Science', 'Anaptiksi kai analisi dedomenon gia epistimonikes kai epixeirisiakes efarmoges', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Artificial Intelligence', 'Schediasmos kai efarmoges texnites noimosynis', 'Data Science');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Machine Learning', 'Texnikes gia anagnorisi protypwn kai mathisi apo dedomena', 'Artificial Intelligence');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Pharmacy', 'Meleti farmakeftikon proionton kai therapeion', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Economics and Business', 'Meleti oikonomikon theoriwn kai epixeirisiakon prakseon', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Accountancy', 'Diaxeirisi oikonomikon logariasmwn', 'Economics and Business');
INSERT INTO subject(title, descr, belongs_to) VALUES ('First Aid', 'Protes voitheies se epeigouses katastaseis', 'Pharmacy');
INSERT INTO subject(title, descr, belongs_to) VALUES ('Psychology', 'Meleti tou anthropinou nou kai symperiforas', NULL);
INSERT INTO subject(title, descr, belongs_to) VALUES ('Business Management', 'Diaxeirisi kai syntonismos epixeirisiakon praxeon', 'Economics and Business');


DELETE FROM requires;
INSERT INTO requires(job_id, subject_title) VALUES ('342768', 'Pliroforiki');
INSERT INTO requires(job_id, subject_title) VALUES ('462574', 'Diktia');
INSERT INTO requires(job_id, subject_title) VALUES ('956758', 'Fisiki');
INSERT INTO requires(job_id, subject_title) VALUES ('134256', 'Asfaleia Pliroforion');
INSERT INTO requires(job_id, subject_title) VALUES ('854623', 'Fisiki');
INSERT INTO requires(job_id, subject_title) VALUES ('468514', 'Iatriki');
INSERT INTO requires(job_id, subject_title) VALUES ('342768', 'Xeirourgiki');
INSERT INTO requires(job_id, subject_title) VALUES ('234659', 'Energeiaki Texnologia');
INSERT INTO requires(job_id, subject_title) VALUES ('101', 'Data Science');
INSERT INTO requires(job_id, subject_title) VALUES ('102', 'Artificial Intelligence');
INSERT INTO requires(job_id, subject_title) VALUES ('103', 'Machine Learning');
INSERT INTO requires(job_id, subject_title) VALUES ('104', 'Pharmacy');
INSERT INTO requires(job_id, subject_title) VALUES ('105', 'Accountancy');
INSERT INTO requires(job_id, subject_title) VALUES ('106', 'Economics and Business');
INSERT INTO requires(job_id, subject_title) VALUES ('107', 'First Aid');
INSERT INTO requires(job_id, subject_title) VALUES ('108', 'Business Management');


#CALL Eggrafes(60000);  #Inset για τον πίνακα Istoriko

#CREATE INDEX index_bathmos ON Istoriko (bathmos);   
#CREATE INDEX index_eval1 ON Istoriko (evaluator1);
#CREATE INDEX index_eval2 ON Istoriko (evaluator2);