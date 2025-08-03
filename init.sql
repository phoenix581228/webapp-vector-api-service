-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create image_analyses table for storing photo analysis JSON data
CREATE TABLE IF NOT EXISTS image_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic metadata from JSON
    image_name TEXT NOT NULL,
    base_image_name TEXT NOT NULL,
    analysis_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    analysis_date TEXT NOT NULL,
    
    -- Event background (may contain long text)
    event_background TEXT,
    
    -- Full JSON data
    full_json JSONB NOT NULL,
    
    -- Analysis data
    caption TEXT,
    caption_embedding vector(1920),
    
    -- Tags as JSONB for flexible querying
    tags JSONB DEFAULT '[]',
    tags_structured JSONB DEFAULT '{}',
    
    -- Summary information
    caption_length INTEGER,
    total_tags INTEGER,
    
    -- System metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_image_name ON image_analyses(image_name);
CREATE INDEX IF NOT EXISTS idx_base_image_name ON image_analyses(base_image_name);
CREATE INDEX IF NOT EXISTS idx_analysis_timestamp ON image_analyses(analysis_timestamp);
CREATE INDEX IF NOT EXISTS idx_tags ON image_analyses USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_tags_structured ON image_analyses USING GIN(tags_structured);
CREATE INDEX IF NOT EXISTS idx_full_json ON image_analyses USING GIN(full_json);

-- Create index for vector similarity search on captions
CREATE INDEX IF NOT EXISTS idx_caption_embedding ON image_analyses 
USING hnsw (caption_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Create documents table (general purpose)
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1920),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS documents_embedding_idx ON documents 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to both tables
CREATE TRIGGER update_image_analyses_updated_at BEFORE UPDATE
    ON image_analyses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE
    ON documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();