-- Extra database used by Rundeck as its backing store (harmless for other stacks).
CREATE DATABASE IF NOT EXISTS rundeck;
GRANT ALL ON rundeck.* TO 'eval'@'%';
