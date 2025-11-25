-- Create the access_logs table
CREATE TABLE IF NOT EXISTS access_logs (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tag_id text,
    name text,
    company text,
    floor text,
    created_at timestamp with time zone DEFAULT now()
);

-- Optional: Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_access_logs_name ON access_logs(name);
CREATE INDEX IF NOT EXISTS idx_access_logs_company ON access_logs(company);
CREATE INDEX IF NOT EXISTS idx_access_logs_floor ON access_logs(floor);
CREATE INDEX IF NOT EXISTS idx_access_logs_tag_id ON access_logs(tag_id);
CREATE INDEX IF NOT EXISTS idx_access_logs_created_at ON access_logs(created_at);