ALTER TABLE %dbprefix%appointment_log ADD appointment_log_id INT NOT NULL AUTO_INCREMENT FIRST ,ADD PRIMARY KEY ( appointment_log_id ) ;
UPDATE %dbprefix%appointment_log SET old_status = 'Appointment' WHERE old_status = 'Appointments';
CREATE OR REPLACE VIEW %dbprefix%view_report AS SELECT appointment.appointment_id, appointment.patient_id, CONCAT(IFNULL(view_patient.first_name,''),' ',IFNULL(view_patient.middle_name,''), ' ',IFNULL(view_patient.last_name,'')) as patient_name, appointment.userid,		users.name doctor_name,		appointment.appointment_date,		min(appointment.start_time) as appointment_time,		max(CASE appointment_log.status WHEN 'Waiting' THEN appointment_log.from_time END) as waiting_in,		max(CASE appointment_log.old_status WHEN 'Consultation' THEN timediff(appointment_log.from_time,appointment_log.to_time) END) as waiting_out,		TIMEDIFF((max(CASE appointment_log.status WHEN 'Consultation' THEN appointment_log.from_time END)),(max(CASE appointment_log.status WHEN 'Waiting' THEN appointment_log.from_time END))) as waiting_duration, 		max(CASE appointment_log.status WHEN 'Consultation' THEN appointment_log.from_time END) as consultation_in,		max(CASE appointment_log.status WHEN 'Complete' THEN appointment_log.from_time END) as consultation_out,		TIMEDIFF((max(CASE appointment_log.status WHEN 'Complete' THEN appointment_log.from_time END)),(max(CASE appointment_log.status WHEN 'Consultation' THEN appointment_log.from_time END))) as consultation_duration,		max(bill.total_amount) as collection_amount  FROM  ck_appointments as appointment         LEFT JOIN ck_view_patient as view_patient ON appointment.patient_id = view_patient.patient_id		LEFT JOIN ck_bill as bill ON appointment.visit_id = bill.visit_id 	   	LEFT JOIN ck_appointment_log as appointment_log ON appointment.appointment_id = appointment_log.appointment_id	   		LEFT JOIN ck_users AS users ON users.userid = appointment.userid   GROUP BY appointment.appointment_id,patient_name;
UPDATE %dbprefix%version SET current_version='0.2.9';