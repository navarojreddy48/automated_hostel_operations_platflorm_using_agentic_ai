-- Expand complaint categories to include carpentry, hvac, and wifi
ALTER TABLE complaints
  MODIFY COLUMN category ENUM(
    'electrical',
    'plumbing',
    'carpentry',
    'hvac',
    'wifi',
    'furniture',
    'internet',
    'cleaning',
    'security',
    'other'
  ) NOT NULL;
