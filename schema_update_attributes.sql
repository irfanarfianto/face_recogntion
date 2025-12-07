-- Add face_attributes column to attendance_logs table
ALTER TABLE attendance_logs 
ADD COLUMN face_attributes JSONB;

-- Example usage of inserting:
-- INSERT INTO attendance_logs (..., face_attributes) VALUES (..., '{"yaw": 1.0, "roll": 2.0, "pitch": 3.0, "smiling": 0.9}');
